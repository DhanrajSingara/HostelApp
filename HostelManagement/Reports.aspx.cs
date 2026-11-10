using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace HostelManagement
{
    public partial class Reports : System.Web.UI.Page
    {
        private readonly string connString =
            ConfigurationManager.ConnectionStrings["HostelDB"].ConnectionString;

        private int BranchId { get { return Convert.ToInt32(Session["BranchId"]); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                DateTime today = DateTime.Today;
                DateTime first = new DateTime(today.Year, today.Month, 1);
                colFrom.Text = first.ToString("yyyy-MM-dd"); colTo.Text = today.ToString("yyyy-MM-dd");
                expFrom.Text = first.ToString("yyyy-MM-dd"); expTo.Text = today.ToString("yyyy-MM-dd");

                for (int y = today.Year; y >= today.Year - 4; y--) ddlYear.Items.Add(y.ToString());

                ShowTab("collections");
                LoadCollections();
            }
        }

        // ---------- Tabs ----------
        protected void Tab_Click(object sender, EventArgs e)
        {
            string tab = ((LinkButton)sender).CommandArgument;
            hfTab.Value = tab;
            ShowTab(tab);

            switch (tab)
            {
                case "collections": LoadCollections(); break;
                case "dues": LoadDues(); break;
                case "expenses": LoadExpenses(); break;
                case "occupancy": LoadOccupancy(); break;
                case "income": LoadIncome(); break;
                case "roomhist": PrepRoomHist(); break;
            }
        }

        private void ShowTab(string tab)
        {
            pnlCollections.Visible = tab == "collections";
            pnlDues.Visible = tab == "dues";
            pnlExpenses.Visible = tab == "expenses";
            pnlOccupancy.Visible = tab == "occupancy";
            pnlIncome.Visible = tab == "income";
            pnlRoomHist.Visible = tab == "roomhist";

            tabCollections.CssClass = "tab" + (tab == "collections" ? " active" : "");
            tabDues.CssClass = "tab" + (tab == "dues" ? " active" : "");
            tabExpenses.CssClass = "tab" + (tab == "expenses" ? " active" : "");
            tabOccupancy.CssClass = "tab" + (tab == "occupancy" ? " active" : "");
            tabIncome.CssClass = "tab" + (tab == "income" ? " active" : "");
            tabRoomHist.CssClass = "tab" + (tab == "roomhist" ? " active" : "");
        }

        // ---------- Loaders ----------
        private DataTable dtCol, dtDues, dtExp, dtOcc, dtInc;

        private void LoadCollections()
        {
            dtCol = RunProc("sp_Report_Collections", new[] {
                new SqlParameter("@BranchId", BranchId),
                new SqlParameter("@FromDate", Date(colFrom.Text)),
                new SqlParameter("@ToDate", Date(colTo.Text)) });
            rptCol.DataSource = dtCol; rptCol.DataBind();
            pnlColEmpty.Visible = dtCol.Rows.Count == 0;
            SetFooter(rptCol, "litColTotal", Sum(dtCol, "AmountPaid"));
        }

        protected void btnColRun_Click(object sender, EventArgs e) { ShowTab("collections"); LoadCollections(); }

        private void LoadDues()
        {
            dtDues = RunProc("sp_Report_Dues", new[] { new SqlParameter("@BranchId", BranchId) });
            rptDues.DataSource = dtDues; rptDues.DataBind();
            pnlDuesEmpty.Visible = dtDues.Rows.Count == 0;
            SetFooter(rptDues, "litDuesTotal", Sum(dtDues, "Pending"));
        }

        private void LoadExpenses()
        {
            dtExp = RunProc("sp_Report_Expenses", new[] {
                new SqlParameter("@BranchId", BranchId),
                new SqlParameter("@FromDate", Date(expFrom.Text)),
                new SqlParameter("@ToDate", Date(expTo.Text)) });
            rptExp.DataSource = dtExp; rptExp.DataBind();
            pnlExpEmpty.Visible = dtExp.Rows.Count == 0;
            SetFooter(rptExp, "litExpTotal", Sum(dtExp, "TotalAmount"));
        }

        protected void btnExpRun_Click(object sender, EventArgs e) { ShowTab("expenses"); LoadExpenses(); }

        private void LoadOccupancy()
        {
            dtOcc = RunProc("sp_Report_Occupancy", new[] { new SqlParameter("@BranchId", BranchId) });
            rptOcc.DataSource = dtOcc; rptOcc.DataBind();
            pnlOccEmpty.Visible = dtOcc.Rows.Count == 0;
            if (dtOcc.Rows.Count > 0)
            {
                SetLit(rptOcc, "litOccBeds", Sum(dtOcc, "TotalBeds").ToString("N0"));
                SetLit(rptOcc, "litOccOcc", Sum(dtOcc, "Occupied").ToString("N0"));
                SetLit(rptOcc, "litOccVac", Sum(dtOcc, "Vacant").ToString("N0"));
            }
        }

        private void LoadIncome()
        {
            dtInc = RunProc("sp_Report_IncomeExpense", new[] {
                new SqlParameter("@BranchId", BranchId),
                new SqlParameter("@Year", Convert.ToInt32(ddlYear.SelectedValue)) });
            rptInc.DataSource = dtInc; rptInc.DataBind();
            SetLit(rptInc, "litIncInc", Sum(dtInc, "Income").ToString("N0"));
            SetLit(rptInc, "litIncExp", Sum(dtInc, "Expense").ToString("N0"));
            SetLit(rptInc, "litIncSal", Sum(dtInc, "StaffSalary").ToString("N0"));
            SetLit(rptInc, "litIncNet", Sum(dtInc, "Net").ToString("N0"));
        }

        protected void btnIncRun_Click(object sender, EventArgs e) { ShowTab("income"); LoadIncome(); }

        // ---------- Room History ----------
        private DataTable _rhPayments;   // all in-range payments for the selected room

        private void PrepRoomHist()
        {
            if (rhFrom.Text == "")
            {
                DateTime today = DateTime.Today;
                rhFrom.Text = new DateTime(today.Year, today.Month, 1).ToString("yyyy-MM-dd");
                rhTo.Text = today.ToString("yyyy-MM-dd");
            }
            if (rhFloor.Items.Count == 0)
            {
                DataTable f = RunProc("sp_GetFloors", new[] { new SqlParameter("@Branchid", BranchId) });
                rhFloor.Items.Clear();
                rhFloor.Items.Add(new ListItem("-- Select Floor --", ""));
                foreach (DataRow r in f.Rows)
                    rhFloor.Items.Add(new ListItem(r["FloorName"].ToString(), r["FloorId"].ToString()));
                rhRoom.Items.Clear();
                rhRoom.Items.Add(new ListItem("-- Select Room --", ""));
            }
        }

        protected void rhFloor_Changed(object sender, EventArgs e)
        {
            ShowTab("roomhist");
            rhRoom.Items.Clear();
            rhRoom.Items.Add(new ListItem("-- Select Room --", ""));
            if (rhFloor.SelectedValue == "") return;

            DataTable dt = RunProc("sp_GetRoomsForReport", new[]
            {
                new SqlParameter("@BranchId", BranchId),
                new SqlParameter("@FloorId", Convert.ToInt32(rhFloor.SelectedValue))
            });
            foreach (DataRow r in dt.Rows)
                rhRoom.Items.Add(new ListItem(r["RoomNumber"].ToString(), r["RoomId"].ToString()));
        }

        protected void btnRhRun_Click(object sender, EventArgs e)
        {
            ShowTab("roomhist");
            LoadRoomHist();
        }

        private void LoadRoomHist()
        {
            pnlRhResult.Visible = false;
            pnlRhEmpty.Visible = false;

            if (rhRoom.SelectedValue == "")
            {
                pnlRhEmpty.Visible = true;
                return;
            }

            int roomId = Convert.ToInt32(rhRoom.SelectedValue);
            DateTime from = Date(rhFrom.Text), to = Date(rhTo.Text);

            DataTable residents = RunProc("sp_Report_RoomHistory", new[]
            {
                new SqlParameter("@BranchId", BranchId),
                new SqlParameter("@RoomId", roomId),
                new SqlParameter("@FromDate", from),
                new SqlParameter("@ToDate", to)
            });

            _rhPayments = RunProc("sp_Report_RoomHistoryPayments", new[]
            {
                new SqlParameter("@BranchId", BranchId),
                new SqlParameter("@RoomId", roomId),
                new SqlParameter("@FromDate", from),
                new SqlParameter("@ToDate", to)
            });

            if (residents.Rows.Count == 0) { pnlRhEmpty.Visible = true; return; }

            litRhHead.Text = rhRoom.SelectedItem.Text + " &mdash; " + rhFloor.SelectedItem.Text +
                             " (" + from.ToString("dd MMM yyyy") + " to " + to.ToString("dd MMM yyyy") + ")";

            // group residents by bed for the outer repeater
            var beds = residents.DefaultView.ToTable(true, "BedNo");
            beds.DefaultView.Sort = "BedNo ASC";
            _rhResidents = residents;

            rptBeds.DataSource = beds.DefaultView.ToTable();
            rptBeds.DataBind();
            pnlRhResult.Visible = true;
        }

        private DataTable _rhResidents;

        protected void rptBeds_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            int bedNo = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "BedNo"));
            var inner = e.Item.FindControl("rptResidents") as Repeater;
            if (inner == null || _rhResidents == null) return;

            DataRow[] rows = _rhResidents.Select("BedNo = " + bedNo);
            DataTable bedResidents = _rhResidents.Clone();
            foreach (DataRow r in rows) bedResidents.ImportRow(r);

            inner.DataSource = bedResidents;
            inner.DataBind();
        }

        // Called from markup: payments for one resident (already filtered to range).
        public DataView GetPayments(object allocationIdObj)
        {
            int allocationId = Convert.ToInt32(allocationIdObj);
            if (_rhPayments == null) return new DataTable().DefaultView;
            DataView dv = new DataView(_rhPayments) { RowFilter = "AllocationId = " + allocationId };
            return dv;
        }

        // ---------- Excel exports ----------
        protected void btnColXls_Click(object sender, EventArgs e)
        {
            var dt = RunProc("sp_Report_Collections", new[] {
                new SqlParameter("@BranchId", BranchId),
                new SqlParameter("@FromDate", Date(colFrom.Text)),
                new SqlParameter("@ToDate", Date(colTo.Text)) });
            ExportExcel(dt, "Collections");
        }
        protected void btnDuesXls_Click(object sender, EventArgs e)
        {
            var dt = RunProc("sp_Report_Dues", new[] { new SqlParameter("@BranchId", BranchId) });
            ExportExcel(dt, "Dues");
        }
        protected void btnExpXls_Click(object sender, EventArgs e)
        {
            var dt = RunProc("sp_Report_Expenses", new[] {
                new SqlParameter("@BranchId", BranchId),
                new SqlParameter("@FromDate", Date(expFrom.Text)),
                new SqlParameter("@ToDate", Date(expTo.Text)) });
            ExportExcel(dt, "Expenses");
        }
        protected void btnOccXls_Click(object sender, EventArgs e)
        {
            var dt = RunProc("sp_Report_Occupancy", new[] { new SqlParameter("@BranchId", BranchId) });
            ExportExcel(dt, "Occupancy");
        }
        protected void btnIncXls_Click(object sender, EventArgs e)
        {
            var dt = RunProc("sp_Report_IncomeExpense", new[] {
                new SqlParameter("@BranchId", BranchId),
                new SqlParameter("@Year", Convert.ToInt32(ddlYear.SelectedValue)) });
            ExportExcel(dt, "IncomeExpense");
        }

        protected void btnRhXls_Click(object sender, EventArgs e)
        {
            if (rhRoom.SelectedValue == "") { ShowTab("roomhist"); LoadRoomHist(); return; }
            int roomId = Convert.ToInt32(rhRoom.SelectedValue);
            DateTime from = Date(rhFrom.Text), to = Date(rhTo.Text);

            var pays = RunProc("sp_Report_RoomHistoryPayments", new[]
            {
                new SqlParameter("@BranchId", BranchId),
                new SqlParameter("@RoomId", roomId),
                new SqlParameter("@FromDate", from),
                new SqlParameter("@ToDate", to)
            });
            ExportExcel(pays, "RoomHistory");
        }

        // Simple, dependency-free Excel export (HTML table -> .xls).
        private void ExportExcel(DataTable dt, string name)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("<table border='1'><tr>");
            foreach (DataColumn c in dt.Columns) sb.Append("<th>" + c.ColumnName + "</th>");
            sb.Append("</tr>");
            foreach (DataRow r in dt.Rows)
            {
                sb.Append("<tr>");
                foreach (DataColumn c in dt.Columns)
                {
                    object v = r[c];
                    if (c.DataType == typeof(DateTime) && v != DBNull.Value)
                        sb.Append("<td>" + Convert.ToDateTime(v).ToString("dd/MM/yyyy") + "</td>");
                    else
                        sb.Append("<td>" + (v == DBNull.Value ? "" : v.ToString()) + "</td>");
                }
                sb.Append("</tr>");
            }
            sb.Append("</table>");

            Response.Clear();
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition",
                "attachment; filename=" + name + "_" + DateTime.Now.ToString("yyyyMMdd") + ".xls");
            Response.Write(sb.ToString());
            Response.End();
        }

        // ---------- helpers ----------
        private DataTable RunProc(string proc, SqlParameter[] ps)
        {
            DataTable dt = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(proc, con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                if (ps != null) cmd.Parameters.AddRange(ps);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            }
            return dt;
        }

        private decimal Sum(DataTable dt, string col)
        {
            decimal t = 0;
            if (dt != null) foreach (DataRow r in dt.Rows) if (r[col] != DBNull.Value) t += Convert.ToDecimal(r[col]);
            return t;
        }

        private void SetFooter(Repeater rpt, string litId, decimal total)
        {
            if (rpt.Items.Count == 0) return;
            var lit = rpt.Controls[rpt.Controls.Count - 1].FindControl(litId) as Literal;
            if (lit != null) lit.Text = total.ToString("N0");
        }
        private void SetLit(Repeater rpt, string litId, string text)
        {
            if (rpt.Items.Count == 0) return;
            var lit = rpt.Controls[rpt.Controls.Count - 1].FindControl(litId) as Literal;
            if (lit != null) lit.Text = text;
        }

        private DateTime Date(string s) { return DateTime.TryParse(s, out DateTime d) ? d : DateTime.Today; }
    }
}