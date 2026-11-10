using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace HostelManagement
{
    public partial class Receipts : System.Web.UI.Page
    {
        private readonly string connString =
            ConfigurationManager.ConnectionStrings["HostelDB"].ConnectionString;

        private int BranchId { get { return Convert.ToInt32(Session["BranchId"]); } }
        private string CurrentUser { get { return Session["Username"]?.ToString() ?? ""; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindFloors();

                // Came from Dashboard "Make Payment" -> open this resident's bill directly.
                string aid = Request.QueryString["allocationId"];
                if (!string.IsNullOrEmpty(aid) && int.TryParse(aid, out int allocId))
                {
                    LoadBill(allocId);
                    // focus the amount box so they can pay straight away
                    if (pnlAddPayment.Visible)
                        ScriptManagerFocus();
                }
            }
        }

        private void ScriptManagerFocus()
        {
            ClientScript.RegisterStartupScript(GetType(), "focusPay",
                "var b=document.getElementById('" + pnlBill.ClientID + "'); if(b){b.scrollIntoView({behavior:'smooth'});}", true);
        }

        // ---------- Floor / Room / Beds ----------
        private void BindFloors()
        {
            DataTable dt = RunProc("sp_GetFloors", new[] { new SqlParameter("@Branchid", BranchId) });
            ddlFloor.Items.Clear();
            ddlFloor.Items.Add(new ListItem("-- Select Floor --", ""));
            foreach (DataRow r in dt.Rows)
                ddlFloor.Items.Add(new ListItem(r["FloorName"].ToString(), r["FloorId"].ToString()));
        }

        protected void ddlFloor_Changed(object sender, EventArgs e)
        {
            ddlRoom.Items.Clear();
            ddlRoom.Items.Add(new ListItem("-- Select Room --", ""));
            pnlBill.Visible = false;
            rptBeds.DataSource = null; rptBeds.DataBind();
            pnlBedPlaceholder.Visible = true;

            if (ddlFloor.SelectedValue == "") { ddlRoom.Enabled = false; return; }

            DataTable dt = RunProc("sp_GetRoomsByFloor", new[]
            {
                new SqlParameter("@BranchId", BranchId),
                new SqlParameter("@FloorId", Convert.ToInt32(ddlFloor.SelectedValue))
            });
            foreach (DataRow r in dt.Rows)
                ddlRoom.Items.Add(new ListItem(r["RoomNumber"] + " (" + r["NumberOfBeds"] + " beds)", r["RoomId"].ToString()));
            ddlRoom.Enabled = true;
        }

        protected void ddlRoom_Changed(object sender, EventArgs e)
        {
            pnlBill.Visible = false;
            if (ddlRoom.SelectedValue == "")
            {
                rptBeds.DataSource = null; rptBeds.DataBind();
                pnlBedPlaceholder.Visible = true;
                return;
            }
            BindBeds(Convert.ToInt32(ddlRoom.SelectedValue));
        }

        private void BindBeds(int roomId)
        {
            DataTable dt = RunProc("sp_GetRoomBeds", new[] { new SqlParameter("@RoomId", roomId) });
            pnlBedPlaceholder.Visible = dt.Rows.Count == 0;
            rptBeds.DataSource = dt;
            rptBeds.DataBind();
        }

        protected void rptBeds_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "SelectBed") return;
            string arg = Convert.ToString(e.CommandArgument);
            if (string.IsNullOrEmpty(arg)) { pnlBill.Visible = false; return; }
            LoadBill(Convert.ToInt32(arg));
        }

        // ---------- Load current bill ----------
        private void LoadBill(int allocationId)
        {
            hfAllocationId.Value = allocationId.ToString();
            pnlEditLine.Visible = false;

            DataTable dt = RunProc("sp_GetCurrentBill", new[] { new SqlParameter("@AllocationId", allocationId) });
            if (dt.Rows.Count == 0) { pnlBill.Visible = false; return; }

            DataRow r = dt.Rows[0];
            int billId = Convert.ToInt32(r["BillId"]);
            hfBillId.Value = billId.ToString();

            decimal actual = Convert.ToDecimal(r["ActualAmount"]);
            decimal pending = Convert.ToDecimal(r["Pending"]);
            string status = r["Status"].ToString();

            litResident.Text = r["PersonName"].ToString();
            litRoomBed.Text = r["RoomNumber"] + " / Bed " + r["BedNo"];
            litPeriod.Text = Convert.ToDateTime(r["PeriodFrom"]).ToString("dd MMM yyyy") + " – " +
                               Convert.ToDateTime(r["PeriodTo"]).ToString("dd MMM yyyy");
            litActual.Text = "₹ " + actual.ToString("N0");
            litPending.Text = "₹ " + pending.ToString("N0");
            litStatus.Text = "<span class='status-badge " + status.ToLower() + "'>" + status + "</span>";

            rptLines.DataSource = RunProc("sp_GetBillGrid", new[] { new SqlParameter("@BillId", billId) });
            rptLines.DataBind();

            rptHistory.DataSource = RunProc("sp_GetResidentPayments", new[] { new SqlParameter("@AllocationId", allocationId) });
            rptHistory.DataBind();

            bool cleared = status == "Cleared";
            DateTime periodTo = Convert.ToDateTime(r["PeriodTo"]);
            bool periodOver = DateTime.Today >= periodTo.Date;

            pnlAddPayment.Visible = !cleared;
            // Next month only after the bill is cleared AND the current period has ended.
            pnlNextMonth.Visible = cleared && periodOver;
            pnlClearedWait.Visible = cleared && !periodOver;

            if (cleared && !periodOver)
                lblClearedWait.Text = "This month is fully paid. You can generate the next month on or after "
                                    + periodTo.ToString("dd MMM yyyy") + ".";

            if (!cleared)
            {
                txtPayDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtAmount.Text = pending.ToString("0");
                lblBillMsg.Text = "";
            }
            lblNextMsg.Text = "";
            pnlBill.Visible = true;
        }

        // ---------- Add payment ----------
        protected void btnAddPayment_Click(object sender, EventArgs e)
        {
            if (hfBillId.Value == "") return;
            int billId = Convert.ToInt32(hfBillId.Value);

            decimal amount = decimal.TryParse(txtAmount.Text, out decimal a) ? a : 0m;
            DateTime payDate = DateTime.TryParse(txtPayDate.Text, out DateTime d) ? d : DateTime.Today;

            DataTable res = RunProc("sp_AddPayment", new[]
            {
                new SqlParameter("@BillId", billId),
                new SqlParameter("@PaymentDate", payDate),
                new SqlParameter("@AmountPaid", amount),
                new SqlParameter("@Mode", ddlMode.SelectedValue),
                new SqlParameter("@User", CurrentUser),
                new SqlParameter("@Remarks", (object)txtRemarks.Text.Trim() ?? DBNull.Value)
            });
            string result = res.Rows.Count > 0 ? res.Rows[0]["Result"].ToString() : "";

            LoadBill(Convert.ToInt32(hfAllocationId.Value));

            if (result == "Overpay") { lblBillMsg.Text = "Amount is more than the pending balance."; lblBillMsg.CssClass = "msg error"; }
            else if (result == "Invalid") { lblBillMsg.Text = "Enter a valid amount."; lblBillMsg.CssClass = "msg error"; }
            else { lblBillMsg.Text = "Payment added."; lblBillMsg.CssClass = "msg success"; }
        }

        // ---------- Edit payment ----------
        protected void rptLines_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "EditLine") return;
            int lineId = Convert.ToInt32(e.CommandArgument);

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("SELECT AmountPaid, PaymentDate FROM PaymentLines WHERE LineId=@id", con))
            {
                cmd.Parameters.AddWithValue("@id", lineId);
                con.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        hfLineId.Value = lineId.ToString();
                        txtEditAmount.Text = Convert.ToDecimal(r["AmountPaid"]).ToString("0");
                        txtEditDate.Text = Convert.ToDateTime(r["PaymentDate"]).ToString("yyyy-MM-dd");
                    }
                }
            }
            // keep the bill visible while editing
            if (hfAllocationId.Value != "") LoadBill(Convert.ToInt32(hfAllocationId.Value));
            pnlEditLine.Visible = true;
            lblEditMsg.Text = "";
        }

        protected void btnUpdateLine_Click(object sender, EventArgs e)
        {
            if (hfLineId.Value == "") return;

            decimal amount = decimal.TryParse(txtEditAmount.Text, out decimal a) ? a : 0m;
            DateTime payDate = DateTime.TryParse(txtEditDate.Text, out DateTime d) ? d : DateTime.Today;

            DataTable res = RunProc("sp_UpdatePayment", new[]
            {
                new SqlParameter("@LineId", Convert.ToInt32(hfLineId.Value)),
                new SqlParameter("@AmountPaid", amount),
                new SqlParameter("@PaymentDate", payDate),
                new SqlParameter("@ModifiedBy", CurrentUser)
            });
            string result = res.Rows.Count > 0 ? res.Rows[0]["Result"].ToString() : "";

            if (result == "Success")
            {
                LoadBill(Convert.ToInt32(hfAllocationId.Value));
                pnlEditLine.Visible = false;
                lblBillMsg.Text = "Payment updated."; lblBillMsg.CssClass = "msg success";
            }
            else
            {
                LoadBill(Convert.ToInt32(hfAllocationId.Value));
                pnlEditLine.Visible = true;
                lblEditMsg.Text = result == "Overpay" ? "Amount exceeds the month's total." : "Could not update.";
                lblEditMsg.CssClass = "msg error";
            }
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            if (hfAllocationId.Value != "") LoadBill(Convert.ToInt32(hfAllocationId.Value));
            pnlEditLine.Visible = false;
        }

        // ---------- Next month ----------
        protected void btnNextMonth_Click(object sender, EventArgs e)
        {
            if (hfAllocationId.Value == "") return;
            int allocationId = Convert.ToInt32(hfAllocationId.Value);

            DataTable res = RunProc("sp_GenerateNextMonth", new[] { new SqlParameter("@AllocationId", allocationId) });
            string result = res.Rows.Count > 0 ? res.Rows[0]["Result"].ToString() : "";

            LoadBill(allocationId);

            if (result == "Blocked") { lblNextMsg.Text = "Clear the current month first."; lblNextMsg.CssClass = "msg error"; }
            else if (result == "PeriodNotOver") { lblNextMsg.Text = "The current period is not over yet."; lblNextMsg.CssClass = "msg error"; }
            else { lblBillMsg.Text = "Next month generated."; lblBillMsg.CssClass = "msg success"; }
        }

        // ---------- helper ----------
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
    }
}