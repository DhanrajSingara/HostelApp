using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace HostelManagement
{
    public partial class Staff : System.Web.UI.Page
    {
        private readonly string connString =
            ConfigurationManager.ConnectionStrings["HostelDB"].ConnectionString;

        private int BranchId { get { return Convert.ToInt32(Session["BranchId"]); } }
        private string CurrentUser { get { return Session["Username"]?.ToString() ?? "system"; } }

        private bool IsAdmin
        {
            get { return string.Equals(Session["Role"]?.ToString(), "Admin", StringComparison.OrdinalIgnoreCase); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!IsAdmin)
                {
                    pnlRestricted.Visible = true;
                    pnlMain.Visible = false;
                    return;
                }

                BindMonthYear();
                ClearForm();
                BindDesignations();
                ShowTab("employees");
                LoadStaff();
            }
        }

        // ---------- Tabs ----------
        protected void Tab_Click(object sender, EventArgs e)
        {
            if (!IsAdmin) return;
            string tab = ((LinkButton)sender).CommandArgument;
            hfTab.Value = tab;
            ShowTab(tab);

            switch (tab)
            {
                case "employees": LoadStaff(); break;
                case "salary": BindSalaryStaff(); LoadSalaryList(); break;
                case "attendance": LoadAttendance(); break;
                case "paysheet": LoadPaysheet(); break;
            }
        }

        private void ShowTab(string tab)
        {
            pnlEmployees.Visible = tab == "employees";
            pnlSalary.Visible = tab == "salary";
            pnlAtt.Visible = tab == "attendance";
            pnlPay.Visible = tab == "paysheet";

            tabEmployees.CssClass = "tab" + (tab == "employees" ? " active" : "");
            tabSalary.CssClass = "tab" + (tab == "salary" ? " active" : "");
            tabAtt.CssClass = "tab" + (tab == "attendance" ? " active" : "");
            tabPay.CssClass = "tab" + (tab == "paysheet" ? " active" : "");
        }

        private void BindMonthYear()
        {
            string[] months = DateTimeFormatInfo.InvariantInfo.MonthNames;
            for (int m = 1; m <= 12; m++)
            {
                ddlAttMonth.Items.Add(new ListItem(months[m - 1], m.ToString()));
                ddlPayMonth.Items.Add(new ListItem(months[m - 1], m.ToString()));
            }
            int year = DateTime.Today.Year;
            for (int y = year; y >= year - 4; y--)
            {
                ddlAttYear.Items.Add(y.ToString());
                ddlPayYear.Items.Add(y.ToString());
            }
            ddlAttMonth.SelectedValue = DateTime.Today.Month.ToString();
            ddlPayMonth.SelectedValue = DateTime.Today.Month.ToString();
        }

        /* ================= EMPLOYEES ================= */
        private void BindDesignations()
        {
            DataTable dt = RunProc("sp_GetDesignations", null);
            ddlDesignation.Items.Clear();
            ddlDesignation.Items.Add(new ListItem("-- Select --", ""));
            foreach (DataRow r in dt.Rows)
                ddlDesignation.Items.Add(new ListItem(
                    r["DesignationName"].ToString(), r["DesignationName"].ToString()));
        }

        private void LoadStaff()
        {
            DataTable dt = RunProc("sp_GetStaffByBranch", new[]
            {
                new SqlParameter("@BranchId", BranchId)
            });
            rptStaff.DataSource = dt;
            rptStaff.DataBind();
            pnlEmpty.Visible = dt.Rows.Count == 0;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!IsAdmin) { Msg("Only admins can manage staff.", false); return; }
            ShowTab("employees");

            if (string.IsNullOrWhiteSpace(txtName.Text))
            {
                LoadStaff();
                Msg("Enter the employee name.", false);
                return;
            }

            DataTable res = RunProc("sp_SaveStaff", new[]
            {
                new SqlParameter("@StaffId", string.IsNullOrEmpty(hfStaffId.Value) ? 0 : Convert.ToInt32(hfStaffId.Value)),
                new SqlParameter("@BranchId", BranchId),
                new SqlParameter("@StaffName", txtName.Text.Trim()),
                new SqlParameter("@Phone", txtPhone.Text.Trim()),
                new SqlParameter("@Aadhar", txtAadhar.Text.Trim()),
                new SqlParameter("@Gender", ddlGender.SelectedValue),
                new SqlParameter("@Designation", ddlDesignation.SelectedValue),
                new SqlParameter("@Address", txtAddress.Text.Trim()),
                new SqlParameter("@DateOfJoining", ParseDate(txtDoj.Text)),
                new SqlParameter("@IsActive", chkActive.Checked ? 1 : 0),
                new SqlParameter("@ExitDate", ParseDate(txtExitDate.Text)),
                new SqlParameter("@ExitReason", string.IsNullOrWhiteSpace(txtExitReason.Text)
                                                ? (object)DBNull.Value : txtExitReason.Text.Trim()),
                new SqlParameter("@User", CurrentUser)
            });

            string result = res.Rows.Count > 0 ? res.Rows[0]["Result"].ToString() : "";
            string empId = res.Rows.Count > 0 && res.Columns.Contains("EmpId")
                           ? res.Rows[0]["EmpId"].ToString() : "";

            ClearForm();
            LoadStaff();

            if (result == "Duplicate") Msg("That employee already exists in this branch.", false);
            else if (empId != "") Msg("Employee saved. Emp ID: " + empId, true);
            else Msg("Employee saved.", true);
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ShowTab("employees");
            ClearForm();
            LoadStaff();
            lblMsg.Text = "";
        }

        protected void rptStaff_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "EditStaff") return;
            ShowTab("employees");

            DataTable dt = RunProc("sp_GetStaffById", new[]
            {
                new SqlParameter("@StaffId", Convert.ToInt32(e.CommandArgument))
            });

            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                hfStaffId.Value = r["StaffId"].ToString();
                txtEmpId.Text = r["EmpId"].ToString();
                txtName.Text = r["StaffName"].ToString();
                txtPhone.Text = r["Phone"].ToString();
                txtAadhar.Text = r["Aadhar"].ToString();
                SetList(ddlGender, r["Gender"].ToString());
                SetList(ddlDesignation, r["Designation"].ToString());
                txtAddress.Text = r["Address"].ToString();
                txtDoj.Text = r["DateOfJoining"] == DBNull.Value
                    ? "" : Convert.ToDateTime(r["DateOfJoining"]).ToString("yyyy-MM-dd");
                txtExitDate.Text = r["ExitDate"] == DBNull.Value
                    ? "" : Convert.ToDateTime(r["ExitDate"]).ToString("yyyy-MM-dd");
                txtExitReason.Text = r["ExitReason"] == DBNull.Value ? "" : r["ExitReason"].ToString();
                chkActive.Checked = Convert.ToBoolean(r["IsActive"]);
            }

            LoadStaff();
            lblMsg.Text = "";
        }

        /* ================= SALARY STRUCTURE ================= */
        private void BindSalaryStaff()
        {
            string keep = ddlSalStaff.SelectedValue;
            DataTable dt = RunProc("sp_GetStaffForSalary", new[]
            {
                new SqlParameter("@BranchId", BranchId)
            });
            ddlSalStaff.Items.Clear();
            ddlSalStaff.Items.Add(new ListItem("-- Select Employee --", ""));
            foreach (DataRow r in dt.Rows)
                ddlSalStaff.Items.Add(new ListItem(
                    r["EmpId"] + " - " + r["StaffName"] + " (" + r["Designation"] + ")",
                    r["StaffId"].ToString()));

            ListItem li = ddlSalStaff.Items.FindByValue(keep ?? "");
            if (li != null) { ddlSalStaff.ClearSelection(); li.Selected = true; }
        }

        private void LoadSalaryList()
        {
            DataTable dt = RunProc("sp_GetSalaryStructureList", new[]
            {
                new SqlParameter("@BranchId", BranchId)
            });
            rptSalary.DataSource = dt;
            rptSalary.DataBind();
            pnlSalEmpty.Visible = dt.Rows.Count == 0;
        }

        protected void ddlSalStaff_Changed(object sender, EventArgs e)
        {
            ShowTab("salary");
            hfStructureId.Value = "0";
            ClearSalaryAmounts();
            LoadSalaryList();
        }

        protected void btnSalSave_Click(object sender, EventArgs e)
        {
            if (!IsAdmin) { MsgSal("Only admins can manage salary structures.", false); return; }
            ShowTab("salary");

            if (ddlSalStaff.SelectedValue == "")
            {
                BindSalaryStaff(); LoadSalaryList();
                MsgSal("Please select an employee.", false);
                return;
            }

            DataTable res = RunProc("sp_SaveSalaryStructure", new[]
            {
                new SqlParameter("@StructureId", string.IsNullOrEmpty(hfStructureId.Value) ? 0 : Convert.ToInt32(hfStructureId.Value)),
                new SqlParameter("@StaffId", Convert.ToInt32(ddlSalStaff.SelectedValue)),
                new SqlParameter("@Basic", Num(txtBasic.Text)),
                new SqlParameter("@DA", Num(txtDA.Text)),
                new SqlParameter("@HRA", Num(txtHRA.Text)),
                new SqlParameter("@OtherAllowance", Num(txtOtherAllow.Text)),
                new SqlParameter("@OtherDeduction", Num(txtOtherDeduct.Text)),
                new SqlParameter("@EffectiveFrom", ParseDate(txtEffFrom.Text)),
                new SqlParameter("@EffectiveTo", ParseDate(txtEffTo.Text)),
                new SqlParameter("@User", CurrentUser)
            });

            string result = res.Rows.Count > 0 ? res.Rows[0]["Result"].ToString() : "";

            BindSalaryStaff();
            LoadSalaryList();

            if (result == "Success")
            {
                hfStructureId.Value = "0";
                ClearSalaryAmounts();
                MsgSal("Salary structure saved.", true);
            }
            else if (result == "Overlap") MsgSal("This period overlaps an existing structure for that employee.", false);
            else if (result == "BadRange") MsgSal("Effective To cannot be before Effective From.", false);
            else if (result == "NoFrom") MsgSal("Please enter the Effective From date.", false);
            else MsgSal("Could not save the salary structure.", false);
        }

        protected void btnSalClear_Click(object sender, EventArgs e)
        {
            ShowTab("salary");
            hfStructureId.Value = "0";
            ddlSalStaff.ClearSelection();
            ClearSalaryAmounts();
            BindSalaryStaff();
            LoadSalaryList();
            lblSalMsg.Text = "";
        }

        protected void rptSalary_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "EditSal") return;
            ShowTab("salary");
            BindSalaryStaff();

            // guard: skip if there's no valid structure id (e.g. employee with no structure)
            if (e.CommandArgument == null ||
                !int.TryParse(e.CommandArgument.ToString(), out int structureId) || structureId <= 0)
            {
                LoadSalaryList();
                MsgSal("This employee has no saved structure yet. Select them above to add one.", false);
                return;
            }

            DataTable dt = RunProc("sp_GetStructureById", new[]
            {
                new SqlParameter("@StructureId", structureId)
            });

            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                hfStructureId.Value = r["StructureId"].ToString();

                ListItem li = ddlSalStaff.Items.FindByValue(r["StaffId"].ToString());
                ddlSalStaff.ClearSelection();
                if (li != null) li.Selected = true;

                txtBasic.Text = Dec(r["Basic"]);
                txtDA.Text = Dec(r["DA"]);
                txtHRA.Text = Dec(r["HRA"]);
                txtOtherAllow.Text = Dec(r["OtherAllowance"]);
                txtOtherDeduct.Text = Dec(r["OtherDeduction"]);

                // Gross / Net computed here (the proc doesn't return them)
                decimal basic = ToDec(r["Basic"]), da = ToDec(r["DA"]), hra = ToDec(r["HRA"]),
                        oa = ToDec(r["OtherAllowance"]), od = ToDec(r["OtherDeduction"]);
                decimal gross = basic + da + hra + oa;
                txtGross.Text = gross.ToString("0.##");
                txtNet.Text = (gross - od).ToString("0.##");

                txtEffFrom.Text = r["EffectiveFrom"] == DBNull.Value
                    ? "" : Convert.ToDateTime(r["EffectiveFrom"]).ToString("yyyy-MM-dd");
                txtEffTo.Text = r["EffectiveTo"] == DBNull.Value
                    ? "" : Convert.ToDateTime(r["EffectiveTo"]).ToString("yyyy-MM-dd");
            }

            LoadSalaryList();
            lblSalMsg.Text = "";
        }

        // safe decimal parse from a DataRow value
        private decimal ToDec(object o)
        {
            return o == null || o == DBNull.Value ? 0m : Convert.ToDecimal(o);
        }

        private void ClearSalaryAmounts()
        {
            txtBasic.Text = txtDA.Text = txtHRA.Text = "0";
            txtOtherAllow.Text = txtOtherDeduct.Text = "0";
            txtGross.Text = txtNet.Text = "0";
            txtEffFrom.Text = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1).ToString("yyyy-MM-dd");
            txtEffTo.Text = "";
        }

        /* ================= ATTENDANCE ================= */
        // First entry to the tab: just show the month/year pickers (no grid yet).
        private void LoadAttendance()
        {
            pnlAttGrid.Visible = false;
        }

        // Submit -> bind the grid for the chosen month.
        protected void btnAttLoad_Click(object sender, EventArgs e)
        {
            ShowTab("attendance");
            BindAttendanceGrid();
            lblAttMsg.Text = "";
        }

        private void BindAttendanceGrid()
        {
            DataTable dt = RunProc("sp_GetAttendance", new[]
            {
                new SqlParameter("@BranchId", BranchId),
                new SqlParameter("@Yr", Convert.ToInt32(ddlAttYear.SelectedValue)),
                new SqlParameter("@Mon", Convert.ToInt32(ddlAttMonth.SelectedValue))
            });
            rptAtt.DataSource = dt;
            rptAtt.DataBind();
            pnlAttGrid.Visible = true;
            pnlAttEmpty.Visible = dt.Rows.Count == 0;
        }

        protected void btnAttSave_Click(object sender, EventArgs e)
        {
            if (!IsAdmin) { MsgAtt("Only admins can save attendance.", false); return; }
            ShowTab("attendance");

            int yr = Convert.ToInt32(ddlAttYear.SelectedValue);
            int mon = Convert.ToInt32(ddlAttMonth.SelectedValue);
            int saved = 0;

            foreach (RepeaterItem item in rptAtt.Items)
            {
                var hf = item.FindControl("hfAttStaffId") as HiddenField;
                var duties = item.FindControl("txtDuties") as TextBox;
                var ots = item.FindControl("txtOTs") as TextBox;
                var otRate = item.FindControl("txtOtRate") as TextBox;
                if (hf == null) continue;

                RunProc("sp_SaveAttendance", new[]
                {
                    new SqlParameter("@BranchId", BranchId),
                    new SqlParameter("@StaffId", Convert.ToInt32(hf.Value)),
                    new SqlParameter("@Yr", yr),
                    new SqlParameter("@Mon", mon),
                    new SqlParameter("@Duties", Num(duties == null ? "" : duties.Text)),
                    new SqlParameter("@OTs", Num(ots == null ? "" : ots.Text)),
                    new SqlParameter("@OtRate", Num(otRate == null ? "" : otRate.Text)),
                    new SqlParameter("@User", CurrentUser)
                });
                saved++;
            }

            BindAttendanceGrid();
            MsgAtt(saved > 0 ? "Attendance saved for " + saved + " employees." : "Nothing to save.", saved > 0);
        }


        /* ================= PAYSHEET ================= */
        private void LoadPaysheet()
        {
            pnlPayEmpty.Visible = false;
        }

        protected void btnPayShow_Click(object sender, EventArgs e)
        {
            ShowTab("paysheet");
            lblPayMsg.Text = "";
            BindPaysheet();
        }

        // exposed to the grid so each row's PDF link carries the month
        protected int PayYear { get { return Convert.ToInt32(ddlPayYear.SelectedValue); } }
        protected int PayMonth { get { return Convert.ToInt32(ddlPayMonth.SelectedValue); } }

        private DataTable BindPaysheet()
        {
            DataTable dt = RunProc("sp_GetPaysheet", new[]
            {
                new SqlParameter("@BranchId", BranchId),
                new SqlParameter("@Yr", PayYear),
                new SqlParameter("@Mon", PayMonth)
            });

            rptPay.DataSource = dt;
            rptPay.DataBind();
            pnlPayEmpty.Visible = dt.Rows.Count == 0;

            if (dt.Rows.Count > 0)
            {
                decimal total = 0;
                foreach (DataRow r in dt.Rows)
                    if (r["FinalPay"] != DBNull.Value) total += Convert.ToDecimal(r["FinalPay"]);
                var lit = rptPay.Controls[rptPay.Controls.Count - 1].FindControl("litPayTotal") as Literal;
                if (lit != null) lit.Text = total.ToString("N0");
            }
            else
            {
                MsgPay("No attendance saved for this month. Save attendance first.", false);
            }
            return dt;
        }

        // B) whole wage sheet as one PDF
        protected void btnPayPdf_Click(object sender, EventArgs e)
        {
            Response.Redirect("PayslipPdf.aspx?staffId=0&yr=" + PayYear + "&mon=" + PayMonth);
        }

        // Excel export of the full wage sheet
        protected void btnPayXls_Click(object sender, EventArgs e)
        {
            DataTable dt = RunProc("sp_GetPaysheet", new[]
            {
                new SqlParameter("@BranchId", BranchId),
                new SqlParameter("@Yr", PayYear),
                new SqlParameter("@Mon", PayMonth)
            });

            if (dt.Rows.Count == 0) { ShowTab("paysheet"); BindPaysheet(); return; }

            string month = ddlPayMonth.SelectedItem.Text + "_" + PayYear;
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            sb.Append("<table border='1'><tr>")
              .Append("<th>Emp ID</th><th>Name</th><th>Designation</th><th>Net Salary</th>")
              .Append("<th>Days</th><th>Duties</th><th>Payable</th><th>OTs</th>")
              .Append("<th>OT Rate</th><th>OT Amount</th><th>Final Pay</th></tr>");

            decimal grand = 0;
            foreach (DataRow r in dt.Rows)
            {
                sb.Append("<tr>")
                  .Append("<td>").Append(r["EmpId"]).Append("</td>")
                  .Append("<td>").Append(r["StaffName"]).Append("</td>")
                  .Append("<td>").Append(r["Designation"]).Append("</td>")
                  .Append("<td>").Append(r["NetSalary"]).Append("</td>")
                  .Append("<td>").Append(r["DaysInMonth"]).Append("</td>")
                  .Append("<td>").Append(r["Duties"]).Append("</td>")
                  .Append("<td>").Append(r["Payable"]).Append("</td>")
                  .Append("<td>").Append(r["OTs"]).Append("</td>")
                  .Append("<td>").Append(r["OtRate"]).Append("</td>")
                  .Append("<td>").Append(r["OtAmount"]).Append("</td>")
                  .Append("<td>").Append(r["FinalPay"]).Append("</td>")
                  .Append("</tr>");
                grand += r["FinalPay"] == DBNull.Value ? 0 : Convert.ToDecimal(r["FinalPay"]);
            }
            sb.Append("<tr><td colspan='10' align='right'><b>Total</b></td><td><b>")
              .Append(grand.ToString("N0")).Append("</b></td></tr></table>");

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=WageSheet_" + month + ".xls");
            Response.ContentType = "application/vnd.ms-excel";
            Response.Write("<html><head><meta charset='utf-8'></head><body>" + sb + "</body></html>");
            Response.Flush();
            Response.End();
        }

        /* ================= helpers ================= */
        private void ClearForm()
        {
            hfStaffId.Value = "0";
            txtEmpId.Text = "";
            txtName.Text = txtPhone.Text = txtAadhar.Text = txtAddress.Text = "";
            txtExitDate.Text = txtExitReason.Text = "";
            txtDoj.Text = DateTime.Today.ToString("yyyy-MM-dd");
            ddlGender.SelectedIndex = 0;
            if (ddlDesignation.Items.Count > 0) ddlDesignation.SelectedIndex = 0;
            chkActive.Checked = true;
        }

        private void SetList(DropDownList ddl, string value)
        {
            ListItem li = ddl.Items.FindByValue(value ?? "");
            ddl.ClearSelection();
            if (li != null) li.Selected = true;
            else if (ddl.Items.Count > 0) ddl.SelectedIndex = 0;
        }

        private object ParseDate(string s)
        {
            return DateTime.TryParse(s, out DateTime d) ? (object)d : DBNull.Value;
        }

        private decimal Num(string s)
        {
            return decimal.TryParse(s, out decimal v) ? v : 0m;
        }

        private string Dec(object o)
        {
            return o == DBNull.Value ? "0" : Convert.ToDecimal(o).ToString("0.##");
        }

        private void Msg(string text, bool ok)
        {
            lblMsg.Text = text;
            lblMsg.CssClass = ok ? "msg success" : "msg error";
        }
        private void MsgSal(string text, bool ok)
        {
            lblSalMsg.Text = text;
            lblSalMsg.CssClass = ok ? "msg success" : "msg error";
        }
        private void MsgAtt(string text, bool ok)
        {
            lblAttMsg.Text = text;
            lblAttMsg.CssClass = ok ? "msg success" : "msg error";
        }
        private void MsgPay(string text, bool ok)
        {
            lblPayMsg.Text = text;
            lblPayMsg.CssClass = ok ? "msg success" : "msg error";
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
    }
}