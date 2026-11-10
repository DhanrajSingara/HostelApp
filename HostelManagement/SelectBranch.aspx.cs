using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace HostelManagement
{
    public partial class SelectBranch : System.Web.UI.Page
    {
        private readonly string connString =
            ConfigurationManager.ConnectionStrings["HostelDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Must be logged in to reach this page.
            if (Session["Username"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadBranches();
            }
        }

        private void LoadBranches()
        {
            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("sp_GetActiveBranches", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            if (dt.Rows.Count == 0)
            {
                rptBranches.Visible = false;
                lblEmpty.Visible = true;
            }
            else
            {
                rptBranches.DataSource = dt;
                rptBranches.DataBind();
            }
        }

        protected void rptBranches_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "PickBranch")
            {
                int branchId = Convert.ToInt32(e.CommandArgument);

                string branchName = "";
                HiddenField hdn = (HiddenField)e.Item.FindControl("hdnBranchName");
                if (hdn != null) branchName = hdn.Value;

                // Store the selected branch for the rest of the session.
                Session["BranchId"] = branchId;
                Session["BranchName"] = branchName;

                Response.Redirect("Dashboard.aspx");
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}
