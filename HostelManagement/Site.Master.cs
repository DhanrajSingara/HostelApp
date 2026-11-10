using System;

namespace HostelManagement
{
    public partial class SiteMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Central auth guard for every page that uses this master.
            if (Session["Username"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // A branch must be selected before any module is accessible.
            if (Session["BranchId"] == null)
            {
                Response.Redirect("SelectBranch.aspx");
                return;
            }

            // Single-session enforcement: if a newer login happened elsewhere,
            // this session's token no longer matches the DB -> sign out.
            if (!IsSessionStillValid())
            {
                Session.Clear();
                Session.Abandon();
                Response.Redirect("Login.aspx?kicked=1");
                return;
            }

            // Populate the top bar.
            string username = Session["Username"].ToString();
            litUser.Text = username;
            litRole.Text = Session["Role"] != null ? Session["Role"].ToString() : "";
            litBranch.Text = Session["BranchName"] != null ? Session["BranchName"].ToString() : "";
            litInitial.Text = string.IsNullOrEmpty(username)
                              ? "U" : username.Substring(0, 1).ToUpper();

            // Staff module is admin-only: hide the nav link for everyone else.
            bool isAdmin = string.Equals(Session["Role"] as string, "Admin",
                                         StringComparison.OrdinalIgnoreCase);
            navStaff.Visible = isAdmin;

            // Notification bell = count of pending monthly bills for this branch.
            litNotif.Text = BuildNotifBadge();
        }

        /// <summary>
        /// True if this session's token is still the current one in the DB.
        /// Returns false when the same user has logged in on another device.
        /// </summary>
        private bool IsSessionStillValid()
        {
            object token = Session["SessionToken"];
            object uid = Session["UserId"];
            if (token == null || uid == null) return true;   // nothing to check yet

            try
            {
                string cs = System.Configuration.ConfigurationManager
                              .ConnectionStrings["HostelDB"].ConnectionString;
                using (var con = new System.Data.SqlClient.SqlConnection(cs))
                using (var cmd = new System.Data.SqlClient.SqlCommand("sp_IsSessionValid", con))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@UserId", Convert.ToInt32(uid));
                    cmd.Parameters.AddWithValue("@SessionId", token.ToString());
                    con.Open();
                    object r = cmd.ExecuteScalar();
                    return r != null && Convert.ToInt32(r) == 1;
                }
            }
            catch
            {
                return true;   // never lock users out on a transient DB error
            }
        }

        private string BuildNotifBadge()
        {
            try
            {
                int branchId = Convert.ToInt32(Session["BranchId"]);
                string cs = System.Configuration.ConfigurationManager
                              .ConnectionStrings["HostelDB"].ConnectionString;
                int count = 0;
                using (var con = new System.Data.SqlClient.SqlConnection(cs))
                using (var cmd = new System.Data.SqlClient.SqlCommand(
                    "SELECT COUNT(*) FROM MonthlyBills WHERE BranchId=@b AND Status='Pending'", con))
                {
                    cmd.Parameters.AddWithValue("@b", branchId);
                    con.Open();
                    count = Convert.ToInt32(cmd.ExecuteScalar());
                }
                if (count <= 0) return "";
                string text = count > 99 ? "99+" : count.ToString();
                return "<span class=\"notif-badge\">" + text + "</span>";
            }
            catch
            {
                return "";   // never let the badge break the page
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