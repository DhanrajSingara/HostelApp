using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;

namespace HostelManagement
{
    public partial class BedAllocation : System.Web.UI.Page
    {
        private readonly string connString =
            ConfigurationManager.ConnectionStrings["HostelDB"].ConnectionString;

        private const string BedSvg =
            "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M3 18v-6a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v6'/><line x1='3' y1='14' x2='21' y2='14'/><path d='M7 10V8a1 1 0 0 1 1-1h3v3'/></svg>";

        private int BranchId { get { return Convert.ToInt32(Session["BranchId"]); } }
        private string CurrentUser { get { return Session["Username"]?.ToString() ?? "system"; } }
        private bool IsAdmin
        {
            get { return string.Equals(Session["Role"]?.ToString(), "Admin", StringComparison.OrdinalIgnoreCase); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            pnlEditAdmin.Visible = IsAdmin;   // admin-only edit on occupied beds
            if (!IsPostBack)
            {
                BindFloors();
                ShowPlaceholder("Select a floor and room to view beds.");
            }
        }

        // ---------- Dropdowns ----------
        private void BindFloors()
        {
            DataTable dt = RunProc("sp_GetFloors", new[]
            {
                new SqlParameter("@Branchid", BranchId)
            });
            ddlFloor.Items.Clear();
            ddlFloor.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select Floor --", ""));
            foreach (DataRow r in dt.Rows)
                ddlFloor.Items.Add(new System.Web.UI.WebControls.ListItem(
                    r["FloorName"].ToString(), r["FloorId"].ToString()));
        }

        protected void ddlFloor_Changed(object sender, EventArgs e)
        {
            ddlRoom.Items.Clear();
            ddlRoom.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select Room --", ""));

            if (ddlFloor.SelectedValue == "")
            {
                ddlRoom.Enabled = false;
                ShowPlaceholder("Select a floor and room to view beds.");
                return;
            }

            DataTable dt = RunProc("sp_GetRoomsByFloor", new[]
            {
                new SqlParameter("@BranchId", BranchId),
                new SqlParameter("@FloorId", Convert.ToInt32(ddlFloor.SelectedValue))
            });

            foreach (DataRow r in dt.Rows)
                ddlRoom.Items.Add(new System.Web.UI.WebControls.ListItem(
                    r["RoomNumber"] + " (" + r["NumberOfBeds"] + " beds)", r["RoomId"].ToString()));

            ddlRoom.Enabled = true;
            ShowPlaceholder("Select a room to view beds.");
        }

        protected void ddlRoom_Changed(object sender, EventArgs e)
        {
            if (ddlRoom.SelectedValue == "")
                ShowPlaceholder("Select a room to view beds.");
            else
                BindBeds(Convert.ToInt32(ddlRoom.SelectedValue));
        }

        // ---------- Beds ----------
        private void BindBeds(int roomId)
        {
            DataTable dt = RunProc("sp_GetRoomBeds", new[] { new SqlParameter("@RoomId", roomId) });

            decimal amount = GetRoomAmount(roomId);
            string roomLabel = ddlRoom.SelectedItem != null ? ddlRoom.SelectedItem.Text.Split('(')[0].Trim() : "";

            var grid = new StringBuilder("<div class='bed-grid'>");
            var data = new StringBuilder();

            foreach (DataRow r in dt.Rows)
            {
                int no = Convert.ToInt32(r["BedNo"]);
                bool occ = Convert.ToInt32(r["Occupied"]) == 1;

                if (occ)
                {
                    grid.Append("<div class='bed occupied' onclick='openBed(" + no + ")'>")
                        .Append("<div class='bed-icon'>" + BedSvg + "</div>")
                        .Append("<div class='bed-no'>Bed " + no + "</div>")
                        .Append("<div class='bed-name'>" + Server.HtmlEncode(r["PersonName"].ToString()) + "</div>")
                        .Append("<span class='bed-badge'>Occupied</span></div>");

                    data.Append("BEDS.push({no:" + no + ",occupied:true,allocationId:" + r["AllocationId"] +
                        ",name:'" + Js(r["PersonName"]) + "',aadhar:'" + Js(r["Aadhar"]) + "',phone:'" + Js(r["Phone"]) +
                        "',gender:'" + Js(r["Gender"]) + "',profession:'" + Js(r["Profession"]) +
                        "',doj:'" + DateStr(r["DateOfJoining"]) + "',amount:" + Dec(r["Amount"]) +
                        ",admission:" + Dec(r["AdmissionFees"]) +
                        ",paid:" + Dec(r["AmountPaid"]) + "});");
                }
                else
                {
                    grid.Append("<div class='bed available' onclick='openBed(" + no + ")'>")
                        .Append("<div class='bed-icon'>" + BedSvg + "</div>")
                        .Append("<div class='bed-no'>Bed " + no + "</div>")
                        .Append("<div class='bed-name'>&mdash;</div>")
                        .Append("<span class='bed-badge'>Available</span></div>");

                    data.Append("BEDS.push({no:" + no + ",occupied:false});");
                }
            }
            grid.Append("</div>");

            litBeds.Text = grid.ToString();
            litBedData.Text = "<script>BEDS=[];" + data +
                "ROOM_AMOUNT=" + amount.ToString(CultureInfo.InvariantCulture) +
                ";ROOM_LABEL='" + Js(roomLabel) + "';</script>";
        }

        private void ShowPlaceholder(string msg)
        {
            litBeds.Text = "<div class='placeholder'>" + Server.HtmlEncode(msg) + "</div>";
            litBedData.Text = "<script>BEDS=[];ROOM_AMOUNT=0;ROOM_LABEL='';</script>";
        }

        // ---------- Allocate ----------
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (ddlRoom.SelectedValue == "" || hfBedNo.Value == "")
            {
                ShowMessage("Please select a room and bed.", false);
                return;
            }

            int roomId = Convert.ToInt32(ddlRoom.SelectedValue);
            decimal amount = GetRoomAmount(roomId);   // fixed monthly charge from the room

            bool isDaily = iRentType.SelectedValue == "Daily";
            int days = 0; decimal perDay = 0m;
            if (isDaily)
            {
                int.TryParse(iDays.Text, out days);
                decimal.TryParse(iPerDay.Text, out perDay);
            }
            decimal payNow = ParseDecimal(iPayNow.Text);

            try
            {
                DataTable dt = RunProc("sp_AllocateBed", new[]
                {
                    new SqlParameter("@BranchId", BranchId),
                    new SqlParameter("@RoomId", roomId),
                    new SqlParameter("@BedNo", Convert.ToInt32(hfBedNo.Value)),
                    new SqlParameter("@PersonName", iName.Text.Trim()),
                    new SqlParameter("@Aadhar", iAadhar.Text.Trim()),
                    new SqlParameter("@Phone", iPhone.Text.Trim()),
                    new SqlParameter("@Gender", iGender.SelectedValue),
                    new SqlParameter("@Profession", iProfession.Text.Trim()),
                    new SqlParameter("@DateOfJoining", ParseDate(iDoj.Text)),
                    new SqlParameter("@Amount", amount),
                    new SqlParameter("@AdmissionFees", ParseDecimal(iAdmissionFees.Text)),
                    new SqlParameter("@RentType", iRentType.SelectedValue),
                    new SqlParameter("@NumberOfDays", isDaily ? (object)days : DBNull.Value),
                    new SqlParameter("@PerDayAmount", isDaily ? (object)perDay : DBNull.Value),
                    new SqlParameter("@PayNow", payNow),
                    new SqlParameter("@User", CurrentUser)
                });

                string result = dt.Rows.Count > 0 ? dt.Rows[0]["Result"].ToString() : "";
                int lineId = dt.Rows.Count > 0 && dt.Columns.Contains("LineId") ? Convert.ToInt32(dt.Rows[0]["LineId"]) : 0;

                if (result == "Occupied")
                    ShowMessage("That bed is already occupied.", false);
                else if (result == "Error")
                    ShowMessage("An error occurred while allocating.", false);
                else
                {
                    ShowMessage("Bed allocated successfully.", true);
                    // if a payment was taken, open its receipt PDF in a new tab
                    if (lineId > 0)
                        ClientScript.RegisterStartupScript(GetType(), "recpt",
                            "window.open('ReceiptPdf.aspx?lineId=" + lineId + "','_blank');", true);
                }
            }
            catch (Exception)
            {
                ShowMessage("An error occurred while allocating.", false);
            }

            BindBeds(roomId);
        }

        // ---------- Exit ----------
        protected void btnExit_Click(object sender, EventArgs e)
        {
            if (hfAllocationId.Value == "")
            {
                ShowMessage("No allocation selected.", false);
                return;
            }

            int roomId = ddlRoom.SelectedValue == "" ? 0 : Convert.ToInt32(ddlRoom.SelectedValue);

            try
            {
                RunProc("sp_ExitBed", new[]
                {
                    new SqlParameter("@AllocationId", Convert.ToInt32(hfAllocationId.Value)),
                    new SqlParameter("@ExitDate", ParseDate(iExitDate.Text)),
                    new SqlParameter("@Remarks", (object)iRemarks.Text.Trim() ?? DBNull.Value),
                    new SqlParameter("@AdmissionRefunded", chkRefund.Checked ? 1 : 0)
                });
                ShowMessage(chkRefund.Checked
                    ? "Resident exited; admission fee marked refunded. Bed is now available."
                    : "Resident exited; bed is now available.", true);
            }
            catch (Exception)
            {
                ShowMessage("An error occurred during exit.", false);
            }

            if (roomId > 0) BindBeds(roomId);
        }

        // ---------- Update (admin only) ----------
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (!IsAdmin) { ShowMessage("Only admins can edit resident details.", false); return; }
            if (hfAllocationId.Value == "") { ShowMessage("No allocation selected.", false); return; }

            int roomId = ddlRoom.SelectedValue == "" ? 0 : Convert.ToInt32(ddlRoom.SelectedValue);
            try
            {
                RunProc("sp_UpdateAllocation", new[]
                {
                    new SqlParameter("@AllocationId", Convert.ToInt32(hfAllocationId.Value)),
                    new SqlParameter("@PersonName", eName.Text.Trim()),
                    new SqlParameter("@Aadhar", eAadhar.Text.Trim()),
                    new SqlParameter("@Phone", ePhone.Text.Trim()),
                    new SqlParameter("@Gender", eGender.SelectedValue),
                    new SqlParameter("@Profession", eProfession.Text.Trim()),
                    new SqlParameter("@DateOfJoining", ParseDate(eDoj.Text)),
                    new SqlParameter("@AdmissionFees", ParseDecimal(eAdmission.Text))
                });
                ShowMessage("Resident details updated.", true);
            }
            catch (Exception)
            {
                ShowMessage("An error occurred while updating.", false);
            }

            if (roomId > 0) BindBeds(roomId);
        }
        private decimal GetRoomAmount(int roomId)
        {
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(Amount,0) FROM Rooms WHERE RoomId=@id", con))
            {
                cmd.Parameters.AddWithValue("@id", roomId);
                con.Open();
                object o = cmd.ExecuteScalar();
                return o == null || o == DBNull.Value ? 0m : Convert.ToDecimal(o);
            }
        }

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

        private object ParseDate(string s)
        {
            return DateTime.TryParse(s, out DateTime d) ? (object)d : DBNull.Value;
        }
        private decimal ParseDecimal(string s)
        {
            return decimal.TryParse(s, out decimal v) ? v : 0m;
        }
        private string DateStr(object o)
        {
            return o == DBNull.Value ? "" : Convert.ToDateTime(o).ToString("dd MMM yyyy");
        }
        private string Dec(object o)
        {
            return o == DBNull.Value ? "0" : Convert.ToDecimal(o).ToString("0", CultureInfo.InvariantCulture);
        }
        private string Js(object o)
        {
            if (o == null || o == DBNull.Value) return "";
            return o.ToString().Replace("\\", "\\\\").Replace("'", "\\'").Replace("\r", " ").Replace("\n", " ");
        }
        private void ShowMessage(string text, bool success)
        {
            lblMessage.Text = text;
            lblMessage.CssClass = success ? "msg success" : "msg error";
        }
    }
}