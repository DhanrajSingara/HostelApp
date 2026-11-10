using iTextSharp.text;
using iTextSharp.text.pdf;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;

namespace HostelManagement
{
    /// <summary>
    /// Payslip / wage-sheet PDF.
    ///   A) One employee : PayslipPdf.aspx?staffId={id}&yr={yyyy}&mon={m}
    ///   B) Whole sheet   : PayslipPdf.aspx?staffId=0&yr={yyyy}&mon={m}
    /// Uses iTextSharp 5.5.13.3 (same as ReceiptPdf).
    /// </summary>
    public partial class PayslipPdf : System.Web.UI.Page
    {
        private readonly string connString =
            ConfigurationManager.ConnectionStrings["HostelDB"].ConnectionString;

        private static readonly BaseColor Purple = new BaseColor(79, 70, 229);
        private static readonly BaseColor Grey = new BaseColor(107, 114, 128);
        private static readonly BaseColor Dark = new BaseColor(31, 41, 55);
        private static readonly BaseColor Line = new BaseColor(229, 229, 235);
        private static readonly BaseColor Light = new BaseColor(245, 243, 255);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Username"] == null) { Response.Redirect("Login.aspx"); return; }
            if (Session["BranchId"] == null) { Response.Redirect("SelectBranch.aspx"); return; }

            int branchId = Convert.ToInt32(Session["BranchId"]);
            int.TryParse(Request.QueryString["staffId"], out int staffId);   // 0 = whole sheet
            int yr = int.TryParse(Request.QueryString["yr"], out int y) ? y : DateTime.Today.Year;
            int mon = int.TryParse(Request.QueryString["mon"], out int m) ? m : DateTime.Today.Month;

            DataTable dt = RunProc("sp_GetPaysheet", new[]
            {
                new SqlParameter("@BranchId", branchId),
                new SqlParameter("@Yr", yr),
                new SqlParameter("@Mon", mon)
            });

            if (dt.Rows.Count == 0) { Response.Redirect("Staff.aspx"); return; }

            string branchName = Session["BranchName"]?.ToString() ?? "";
            string monthName = MonthName(mon) + " " + yr;

            byte[] pdf = staffId > 0
                ? BuildPayslip(FindRow(dt, staffId), branchName, monthName)
                : BuildWageSheet(dt, branchName, monthName);

            if (pdf == null) { Response.Redirect("Staff.aspx"); return; }

            Response.Clear();
            Response.ContentType = "application/pdf";
            string fname = staffId > 0
                ? "Payslip_" + monthName.Replace(" ", "_")
                : "WageSheet_" + monthName.Replace(" ", "_");
            Response.AddHeader("Content-Disposition", "inline; filename=" + fname + ".pdf");
            Response.BinaryWrite(pdf);
            Response.End();
        }

        // ---------- A) single employee payslip ----------
        private byte[] BuildPayslip(DataRow r, string branch, string month)
        {
            if (r == null) return null;

            using (MemoryStream ms = new MemoryStream())
            {
                Document doc = new Document(PageSize.A5, 34, 34, 30, 30);
                PdfWriter.GetInstance(doc, ms);
                doc.Open();

                Font hFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 15, Purple);
                Font sub = FontFactory.GetFont(FontFactory.HELVETICA, 9, Grey);
                Font lbl = FontFactory.GetFont(FontFactory.HELVETICA, 9, Grey);
                Font val = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 10, Dark);

                doc.Add(new Paragraph(branch, hFont));
                doc.Add(new Paragraph("Payslip for " + month, sub));
                doc.Add(new Paragraph(" ", sub));

                // employee details
                PdfPTable info = new PdfPTable(2) { WidthPercentage = 100 };
                info.SetWidths(new float[] { 1, 1 });
                InfoCell(info, "Emp ID", Str(r, "EmpId"), lbl, val);
                InfoCell(info, "Name", Str(r, "StaffName"), lbl, val);
                InfoCell(info, "Designation", Str(r, "Designation"), lbl, val);
                InfoCell(info, "Days in Month", Str(r, "DaysInMonth"), lbl, val);
                InfoCell(info, "Duties", Str(r, "Duties"), lbl, val);
                InfoCell(info, "OTs", Str(r, "OTs"), lbl, val);
                doc.Add(info);
                doc.Add(new Paragraph(" ", sub));

                // earnings table
                PdfPTable t = new PdfPTable(2) { WidthPercentage = 100 };
                t.SetWidths(new float[] { 3, 2 });
                HeadRow(t, "Component", "Amount (Rs.)");
                Row(t, "Basic", Money(r, "Basic"));
                Row(t, "DA", Money(r, "DA"));
                Row(t, "HRA", Money(r, "HRA"));
                Row(t, "Other Allowance", Money(r, "OtherAllowance"));
                Row(t, "Other Deduction", "- " + Money(r, "OtherDeduction"));
                Row(t, "Net Salary (full month)", Money(r, "NetSalary"), true);
                Row(t, "Payable (" + Str(r, "Duties") + " / " + Str(r, "DaysInMonth") + " days)", Money(r, "Payable"));
                Row(t, "OT Amount (" + Str(r, "OTs") + " x " + Money(r, "OtRate") + ")", Money(r, "OtAmount"));
                doc.Add(t);

                // final pay banner
                PdfPTable f = new PdfPTable(2) { WidthPercentage = 100, SpacingBefore = 8 };
                f.SetWidths(new float[] { 3, 2 });
                PdfPCell a = new PdfPCell(new Phrase("NET PAYABLE",
                    FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 11, BaseColor.WHITE)))
                {
                    BackgroundColor = Purple,
                    Border = Rectangle.NO_BORDER,
                    Padding = 8,
                    HorizontalAlignment = Element.ALIGN_LEFT
                };
                PdfPCell b = new PdfPCell(new Phrase("Rs. " + Money(r, "FinalPay"),
                    FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 12, BaseColor.WHITE)))
                {
                    BackgroundColor = Purple,
                    Border = Rectangle.NO_BORDER,
                    Padding = 8,
                    HorizontalAlignment = Element.ALIGN_RIGHT
                };
                f.AddCell(a); f.AddCell(b);
                doc.Add(f);

                doc.Add(new Paragraph(" ", sub));
                doc.Add(new Paragraph("This is a computer-generated payslip.", sub));

                doc.Close();
                return ms.ToArray();
            }
        }

        // ---------- B) whole-branch wage sheet ----------
        private byte[] BuildWageSheet(DataTable dt, string branch, string month)
        {
            using (MemoryStream ms = new MemoryStream())
            {
                Document doc = new Document(PageSize.A4.Rotate(), 28, 28, 28, 28);
                PdfWriter.GetInstance(doc, ms);
                doc.Open();

                Font hFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 15, Purple);
                Font sub = FontFactory.GetFont(FontFactory.HELVETICA, 9, Grey);

                doc.Add(new Paragraph(branch + " - Wage Sheet", hFont));
                doc.Add(new Paragraph(month, sub));
                doc.Add(new Paragraph(" ", sub));

                PdfPTable t = new PdfPTable(11) { WidthPercentage = 100 };
                t.SetWidths(new float[] { 1.2f, 2.2f, 1.6f, 1.3f, 0.8f, 0.9f, 1.3f, 0.7f, 1f, 1f, 1.3f });

                string[] heads = { "Emp ID", "Name", "Designation", "Net Sal", "Days", "Duties",
                                   "Payable", "OTs", "OT Rate", "OT Amt", "Final Pay" };
                foreach (string h in heads) HeadCell(t, h);

                decimal grand = 0;
                foreach (DataRow r in dt.Rows)
                {
                    Cell(t, Str(r, "EmpId"), false);
                    Cell(t, Str(r, "StaffName"), false);
                    Cell(t, Str(r, "Designation"), false);
                    Cell(t, Money(r, "NetSalary"), true);
                    Cell(t, Str(r, "DaysInMonth"), true);
                    Cell(t, Str(r, "Duties"), true);
                    Cell(t, Money(r, "Payable"), true);
                    Cell(t, Str(r, "OTs"), true);
                    Cell(t, Money(r, "OtRate"), true);
                    Cell(t, Money(r, "OtAmount"), true);
                    Cell(t, Money(r, "FinalPay"), true);
                    grand += Dec(r, "FinalPay");
                }

                // total row
                PdfPCell tc = new PdfPCell(new Phrase("Total",
                    FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 9, Dark)))
                {
                    Colspan = 10,
                    HorizontalAlignment = Element.ALIGN_RIGHT,
                    Padding = 5,
                    BackgroundColor = Light,
                    BorderColor = Line
                };
                t.AddCell(tc);
                PdfPCell tv = new PdfPCell(new Phrase(grand.ToString("N0"),
                    FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 9, Dark)))
                {
                    HorizontalAlignment = Element.ALIGN_RIGHT,
                    Padding = 5,
                    BackgroundColor = Light,
                    BorderColor = Line
                };
                t.AddCell(tv);

                doc.Add(t);
                doc.Close();
                return ms.ToArray();
            }
        }

        // ---------- pdf helpers ----------
        private void InfoCell(PdfPTable t, string label, string value, Font lbl, Font val)
        {
            PdfPCell c = new PdfPCell { Border = Rectangle.NO_BORDER, PaddingBottom = 5 };
            c.AddElement(new Phrase(label, lbl));
            c.AddElement(new Phrase(value, val));
            t.AddCell(c);
        }

        private void HeadRow(PdfPTable t, string a, string b)
        {
            t.AddCell(HCell(a, Element.ALIGN_LEFT));
            t.AddCell(HCell(b, Element.ALIGN_RIGHT));
        }
        private PdfPCell HCell(string s, int align)
        {
            return new PdfPCell(new Phrase(s, FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 9, Purple)))
            { BackgroundColor = Light, BorderColor = Line, Padding = 6, HorizontalAlignment = align };
        }

        private void Row(PdfPTable t, string label, string amount, bool strong = false)
        {
            Font lf = FontFactory.GetFont(FontFactory.HELVETICA, 9, Dark);
            Font af = FontFactory.GetFont(strong ? FontFactory.HELVETICA_BOLD : FontFactory.HELVETICA, 9, Dark);
            t.AddCell(new PdfPCell(new Phrase(label, lf))
            { BorderColor = Line, Padding = 5, HorizontalAlignment = Element.ALIGN_LEFT });
            t.AddCell(new PdfPCell(new Phrase(amount, af))
            { BorderColor = Line, Padding = 5, HorizontalAlignment = Element.ALIGN_RIGHT });
        }

        private void HeadCell(PdfPTable t, string s)
        {
            t.AddCell(new PdfPCell(new Phrase(s, FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 8.5f, Purple)))
            {
                BackgroundColor = Light,
                BorderColor = Line,
                Padding = 5,
                HorizontalAlignment = Element.ALIGN_CENTER
            });
        }
        private void Cell(PdfPTable t, string s, bool num)
        {
            t.AddCell(new PdfPCell(new Phrase(s, FontFactory.GetFont(FontFactory.HELVETICA, 8.5f, Dark)))
            {
                BorderColor = Line,
                Padding = 4,
                HorizontalAlignment = num ? Element.ALIGN_RIGHT : Element.ALIGN_LEFT
            });
        }

        // ---------- data helpers ----------
        private DataRow FindRow(DataTable dt, int staffId)
        {
            foreach (DataRow r in dt.Rows)
                if (Convert.ToInt32(r["StaffId"]) == staffId) return r;
            return null;
        }
        private string Str(DataRow r, string col)
        {
            return r[col] == DBNull.Value ? "" : r[col].ToString();
        }
        private decimal Dec(DataRow r, string col)
        {
            return r[col] == DBNull.Value ? 0 : Convert.ToDecimal(r[col]);
        }
        private string Money(DataRow r, string col)
        {
            return Dec(r, col).ToString("N0");
        }
        private string MonthName(int m)
        {
            return (m >= 1 && m <= 12)
                ? CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(m) : m.ToString();
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
