using HostelManagement.DAL;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace HostelManagement
{
    public partial class Login : System.Web.UI.Page
    {
        private readonly string connString =
            ConfigurationManager.ConnectionStrings["HostelDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // If already logged in, send to the right place:
                // dashboard if a branch is already chosen, otherwise branch selection.
                if (Session["Username"] != null)
                {
                    if (Session["BranchId"] != null)
                        Response.Redirect("Dashboard.aspx");
                    else
                        Response.Redirect("SelectBranch.aspx");
                }

                // Show confirmation after a successful password reset.
                if (Request.QueryString["reset"] == "success")
                {
                    lblMessage.Text = "Password reset successful. Please sign in.";
                    lblMessage.Style["color"] = "#16a34a";
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            // --- Basic input validation ---
            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                lblMessage.Text = "Please enter both username and password.";
                return;
            }

            try
            {
                int userId = 0;
                string storedHash = null;
                string role = null;

                // --- 1. Fetch the user via stored procedure ---
                using (SqlConnection con = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand("sp_GetUserForLogin", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Username", username);

                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            userId = Convert.ToInt32(reader["UserId"]);
                            storedHash = reader["PasswordHash"].ToString();
                            role = reader["Role"].ToString();
                        }
                    }
                }

                // --- 2. Verify ---
                if (storedHash == null)
                {
                    lblMessage.Text = "Invalid username or password.";
                    return;
                }

                bool isValid = PasswordHelper.VerifyPassword(password, storedHash);

                if (!isValid)
                {
                    lblMessage.Text = "Invalid username or password.";
                    return;
                }

                // --- 3. Successful login: set session ---
                Session["UserId"] = userId;
                Session["Username"] = username;
                Session["Role"] = role;

                // --- 3b. Single-session: make THIS login the only valid one ---
                string sessionToken = Guid.NewGuid().ToString();
                Session["SessionToken"] = sessionToken;
                SetUserSession(userId, sessionToken);   // overwrites -> ends all other devices

                // --- 4. Update last-login timestamp ---
                UpdateLastLogin(userId);

                // --- 5. Remember-me cookie (7 days) ---
                if (chkRemember.Checked)
                {
                    HttpCookie cookie = new HttpCookie("HostelUser", username)
                    {
                        Expires = DateTime.Now.AddDays(7),
                        HttpOnly = true
                    };
                    Response.Cookies.Add(cookie);
                }

                // --- 6. Go to branch selection first, then dashboard ---
                Response.Redirect("SelectBranch.aspx");
            }
            catch (Exception)
            {
                lblMessage.Text = "An error occurred. Please try again.";
                // For debugging only:
                // System.Diagnostics.Debug.WriteLine(ex.Message);
            }
        }

        /// <summary>Records the login timestamp via sp_UpdateLastLogin.</summary>
        private void UpdateLastLogin(int userId)
        {
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("sp_UpdateLastLogin", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UserId", userId);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>Stores this login's token as the only valid session for the user.</summary>
        private void SetUserSession(int userId, string sessionToken)
        {
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("sp_SetUserSession", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@SessionId", sessionToken);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }
}
