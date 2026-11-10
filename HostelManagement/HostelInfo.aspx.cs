using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace HostelManagement
{
    public partial class HostelInfo : System.Web.UI.Page
    {
        private readonly string connString =
            ConfigurationManager.ConnectionStrings["HostelDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Auth/branch guard lives in Site.master.cs, so a branch is guaranteed here.
            if (!IsPostBack)
            {
                LoadInfo();
            }
        }

        private int BranchId
        {
            get { return Convert.ToInt32(Session["BranchId"]); }
        }

        private void LoadInfo()
        {
            bool found = false;

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("sp_GetHostelInfo", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@BranchId", BranchId);
                con.Open();

                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        found = true;
                        txtHostelName.Text = r["HostelName"].ToString();
                        ddlHostelType.SelectedValue = SafeListValue(r["HostelType"].ToString());
                        txtWardenName.Text = r["WardenName"].ToString();
                        txtWardenPhone.Text = r["WardenPhone"].ToString();
                        txtEmail.Text = r["Email"].ToString();
                        txtAddress.Text = r["Address"].ToString();
                        txtCity.Text = r["City"].ToString();
                        txtState.Text = r["State"].ToString();
                        txtPincode.Text = r["Pincode"].ToString();
                        txtEstablishedYear.Text = r["EstablishedYear"] == DBNull.Value ? "" : r["EstablishedYear"].ToString();
                        txtTotalCapacity.Text = r["TotalCapacity"] == DBNull.Value ? "" : r["TotalCapacity"].ToString();
                        txtDescription.Text = r["Description"].ToString();
                        txtFacilities.Text = r["Facilities"].ToString();
                        txtRules.Text = r["Rules"].ToString();
                    }
                }
            }

            // First time on this branch: prefill the name from the selected branch.
            if (!found && Session["BranchName"] != null)
            {
                txtHostelName.Text = Session["BranchName"].ToString();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtHostelName.Text))
            {
                ShowMessage("Hostel name is required.", false);
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand("sp_SaveHostelInfo", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@BranchId", BranchId);
                    cmd.Parameters.AddWithValue("@HostelName", txtHostelName.Text.Trim());
                    cmd.Parameters.AddWithValue("@HostelType", ddlHostelType.SelectedValue);
                    cmd.Parameters.AddWithValue("@WardenName", txtWardenName.Text.Trim());
                    cmd.Parameters.AddWithValue("@WardenPhone", txtWardenPhone.Text.Trim());
                    cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                    cmd.Parameters.AddWithValue("@Address", txtAddress.Text.Trim());
                    cmd.Parameters.AddWithValue("@City", txtCity.Text.Trim());
                    cmd.Parameters.AddWithValue("@State", txtState.Text.Trim());
                    cmd.Parameters.AddWithValue("@Pincode", txtPincode.Text.Trim());
                    cmd.Parameters.AddWithValue("@EstablishedYear", ParseIntOrNull(txtEstablishedYear.Text));
                    cmd.Parameters.AddWithValue("@TotalCapacity", ParseIntOrNull(txtTotalCapacity.Text));
                    cmd.Parameters.AddWithValue("@Description", txtDescription.Text.Trim());
                    cmd.Parameters.AddWithValue("@Facilities", txtFacilities.Text.Trim());
                    cmd.Parameters.AddWithValue("@Rules", txtRules.Text.Trim());

                    con.Open();
                    string result = cmd.ExecuteScalar()?.ToString();

                    if (result == "Success")
                        ShowMessage("Hostel information saved successfully.", true);
                    else
                        ShowMessage("Could not save. Please try again.", false);
                }
            }
            catch (Exception)
            {
                ShowMessage("An error occurred while saving.", false);
            }
        }

        // ---------- helpers ----------

        private object ParseIntOrNull(string text)
        {
            if (int.TryParse(text, out int value))
                return value;
            return DBNull.Value;
        }

        private string SafeListValue(string value)
        {
            // Avoid an exception if the stored value isn't one of the list items.
            foreach (System.Web.UI.WebControls.ListItem item in ddlHostelType.Items)
                if (item.Value == value) return value;
            return "";
        }

        private void ShowMessage(string text, bool success)
        {
            lblMessage.Text = text;
            lblMessage.CssClass = success ? "msg success" : "msg error";
        }
    }
}
