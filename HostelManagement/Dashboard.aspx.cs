using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace HostelManagement
{
    public partial class Dashboard : System.Web.UI.Page
    {
        private readonly string connString =
            ConfigurationManager.ConnectionStrings["HostelDB"].ConnectionString;

        private int BranchId { get { return Convert.ToInt32(Session["BranchId"]); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["Username"] != null)
                    litWelcome.Text = Session["Username"].ToString();

                LoadStats();
                LoadChart();
                LoadPending(false);   // default: 5 most overdue
            }
        }

        private void LoadStats()
        {
            DataTable dt = RunStats();
            if (dt.Rows.Count == 0) return;
            DataRow r = dt.Rows[0];

            int totalRooms = Convert.ToInt32(r["TotalRooms"]);
            int totalBeds = Convert.ToInt32(r["TotalBeds"]);
            int occupied = Convert.ToInt32(r["Occupied"]);
            int available = totalBeds - occupied;
            int pending = Convert.ToInt32(r["PendingBills"]);

            litTotalRooms.Text = totalRooms.ToString();
            litTotalBeds.Text = totalBeds.ToString();
            litOccupied.Text = occupied.ToString();
            litAvailable.Text = available.ToString();
            litStudents.Text = occupied.ToString();   // total persons = active residents
            litPendingBills.Text = pending.ToString();

            int pct = totalBeds > 0 ? (int)Math.Round(occupied * 100.0 / totalBeds) : 0;
            litOccPct.Text = pct.ToString();
            litOccSub.Text = occupied + " of " + totalBeds + " beds occupied";
            occFill.Style["width"] = pct + "%";
        }

        private decimal _chartMax = 1;   // largest bar value, for scaling

        private void LoadChart()
        {
            DataTable dt = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("sp_GetIncomeExpenseChart", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@BranchId", BranchId);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            }

            foreach (DataRow r in dt.Rows)
            {
                decimal inc = Convert.ToDecimal(r["Income"]);
                decimal exp = Convert.ToDecimal(r["Expense"]);
                if (inc > _chartMax) _chartMax = inc;
                if (exp > _chartMax) _chartMax = exp;
            }

            rptChart.DataSource = dt;
            rptChart.DataBind();
        }

        // Height as a percentage of the tallest bar (min 2% so zero is visible).
        protected string BarHeight(object val)
        {
            decimal v = Convert.ToDecimal(val);
            int pct = _chartMax > 0 ? (int)Math.Round(v * 100m / _chartMax) : 0;
            if (pct < 2) pct = 2;
            return pct.ToString();
        }

        // showAll = false -> top 5 overdue; true -> everything
        private void LoadPending(bool showAll)
        {
            ViewState["all"] = showAll;

            DataTable dt = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("sp_GetPendingPayments", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@BranchId", BranchId);
                cmd.Parameters.AddWithValue("@Top", showAll ? 0 : 5);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            }

            rptPending.DataSource = dt;
            rptPending.DataBind();
            pnlPendEmpty.Visible = dt.Rows.Count == 0;

            btnShowAll.Text = showAll ? "Show Less" : "Show All";
            btnShowAll.Visible = dt.Rows.Count > 0 || showAll;
        }

        protected void btnShowAll_Click(object sender, EventArgs e)
        {
            bool cur = (ViewState["all"] as bool?) ?? false;
            LoadPending(!cur);
        }

        // Friendly overdue label for the markup.
        protected string OverdueText(object daysObj)
        {
            int d = Convert.ToInt32(daysObj);
            if (d > 0) return d + " day" + (d == 1 ? "" : "s") + " overdue";
            if (d == 0) return "due today";
            return "due in " + (-d) + " day" + (-d == 1 ? "" : "s");
        }

        private DataTable RunStats()
        {
            DataTable dt = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("sp_GetDashboardStats", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@BranchId", BranchId);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            }
            return dt;
        }
    }
}
