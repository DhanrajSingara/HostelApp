using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Net;
using System.Net.Mail;
using HostelManagement.DAL;

namespace HostelManagement
{
    public partial class ForgotPassword : System.Web.UI.Page
    {
        private readonly string connString =
            ConfigurationManager.ConnectionStrings["HostelDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e) { }

        // ---------- STEP 1: send OTP ----------
        protected void btnSendOtp_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();

            if (string.IsNullOrEmpty(email))
            {
                ShowMessage("Please enter your registered email.", false);
                return;
            }

            int userId = 0;
            string username = null;

            // Look up the account by email.
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("sp_GetUserByEmail", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Email", email);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        userId = Convert.ToInt32(reader["UserId"]);
                        username = reader["Username"].ToString();
                    }
                }
            }

            // NOTE: revealing whether an email exists is fine for an internal tool.
            // For a public site, show a generic message instead.
            if (userId == 0)
            {
                ShowMessage("No account found with that email.", false);
                return;
            }

            string otp = GenerateOtp();
            SaveOtp(userId, otp);

            if (SendOtpEmail(email, username, otp))
            {
                // Remember who we're resetting for the next steps.
                Session["ResetUserId"] = userId;
                Session["ResetEmail"] = email;

                pnlEmail.Visible = false;
                pnlOtp.Visible = true;
                pnlReset.Visible = false;
                ShowMessage("An OTP has been sent to your email.", true);
            }
            else
            {
                ShowMessage("Could not send the email. Please try again later.", false);
            }
        }

        // ---------- STEP 2: verify OTP ----------
        protected void btnVerifyOtp_Click(object sender, EventArgs e)
        {
            if (Session["ResetUserId"] == null)
            {
                ResetFlow("Session expired. Please start again.");
                return;
            }

            int userId = (int)Session["ResetUserId"];
            string otp = txtOtp.Text.Trim();

            if (string.IsNullOrEmpty(otp))
            {
                ShowMessage("Please enter the OTP.", false);
                return;
            }

            string result;
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("sp_ValidateResetOTP", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@OtpCode", otp);
                con.Open();
                result = cmd.ExecuteScalar()?.ToString();
            }

            if (result == "Valid")
            {
                pnlEmail.Visible = false;
                pnlOtp.Visible = false;
                pnlReset.Visible = true;
                ShowMessage("OTP verified. Set your new password.", true);
            }
            else if (result == "Expired")
            {
                ShowMessage("This OTP has expired. Please resend a new one.", false);
            }
            else
            {
                ShowMessage("Invalid OTP. Please try again.", false);
            }
        }

        // ---------- Resend OTP ----------
        protected void btnResendOtp_Click(object sender, EventArgs e)
        {
            if (Session["ResetUserId"] == null || Session["ResetEmail"] == null)
            {
                ResetFlow("Session expired. Please start again.");
                return;
            }

            int userId = (int)Session["ResetUserId"];
            string email = Session["ResetEmail"].ToString();
            string otp = GenerateOtp();

            SaveOtp(userId, otp);

            if (SendOtpEmail(email, null, otp))
                ShowMessage("A new OTP has been sent.", true);
            else
                ShowMessage("Could not resend the OTP. Try again later.", false);
        }

        // ---------- STEP 3: reset password ----------
        protected void btnResetPassword_Click(object sender, EventArgs e)
        {
            if (Session["ResetUserId"] == null)
            {
                ResetFlow("Session expired. Please start again.");
                return;
            }

            int userId = (int)Session["ResetUserId"];
            string newPass = txtNewPassword.Text.Trim();
            string confirm = txtConfirmPassword.Text.Trim();

            if (newPass.Length < 8)
            {
                ShowMessage("Password must be at least 8 characters.", false);
                return;
            }
            if (newPass != confirm)
            {
                ShowMessage("Passwords do not match.", false);
                return;
            }

            // Re-collect the OTP so the SP can confirm it one last time.
            string otp = txtOtp.Text.Trim();
            string newHash = PasswordHelper.HashPassword(newPass);

            string result;
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("sp_ResetPassword", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@OtpCode", otp);
                cmd.Parameters.AddWithValue("@NewPasswordHash", newHash);
                con.Open();
                result = cmd.ExecuteScalar()?.ToString();
            }

            if (result == "Success")
            {
                Session.Remove("ResetUserId");
                Session.Remove("ResetEmail");
                Response.Redirect("Login.aspx?reset=success");
            }
            else if (result == "Expired")
            {
                ShowMessage("Your OTP expired. Please restart the process.", false);
            }
            else
            {
                ShowMessage("Could not reset the password. Please try again.", false);
            }
        }

        // ================= Helpers =================

        private void SaveOtp(int userId, string otp)
        {
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("sp_SaveResetOTP", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@OtpCode", otp);
                cmd.Parameters.AddWithValue("@ExpiryMinutes", 10);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private string GenerateOtp()
        {
            // 6-digit numeric OTP.
            return new Random().Next(100000, 999999).ToString();
        }

        private bool SendOtpEmail(string toEmail, string username, string otp)
        {
            try
            {
                // SMTP settings come from <appSettings> in Web.config.
                string host = ConfigurationManager.AppSettings["SmtpHost"];
                int port = int.Parse(ConfigurationManager.AppSettings["SmtpPort"]);
                string user = ConfigurationManager.AppSettings["SmtpUser"];
                string pass = ConfigurationManager.AppSettings["SmtpPassword"];
                string from = ConfigurationManager.AppSettings["SmtpFrom"];
                bool ssl = bool.Parse(ConfigurationManager.AppSettings["SmtpEnableSsl"] ?? "true");

                string body =
                    "Hello " + (string.IsNullOrEmpty(username) ? "" : username) + ",\r\n\r\n" +
                    "Your password reset OTP is: " + otp + "\r\n" +
                    "This code is valid for 10 minutes.\r\n\r\n" +
                    "If you did not request this, please ignore this email.\r\n\r\n" +
                    "- Hostel Management System";

                using (MailMessage mail = new MailMessage(from, toEmail))
                {
                    mail.Subject = "Your Password Reset OTP";
                    mail.Body = body;

                    using (SmtpClient smtp = new SmtpClient(host, port))
                    {
                        smtp.Credentials = new NetworkCredential(user, pass);
                        smtp.EnableSsl = ssl;
                        smtp.Send(mail);
                    }
                }
                return true;
            }
            catch (Exception)
            {
                // For debugging: System.Diagnostics.Debug.WriteLine(ex.Message);
                return false;
            }
        }

        private void ShowMessage(string text, bool success)
        {
            lblMessage.Text = text;
            lblMessage.CssClass = success ? "msg success" : "msg";
        }

        private void ResetFlow(string text)
        {
            pnlEmail.Visible = true;
            pnlOtp.Visible = false;
            pnlReset.Visible = false;
            ShowMessage(text, false);
        }
    }
}
