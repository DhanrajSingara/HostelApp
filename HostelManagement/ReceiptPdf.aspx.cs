using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.pdf.draw;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;

namespace HostelManagement
{
    /// <summary>
    /// Streams a single payment as a PDF receipt.
    /// NuGet: Install-Package iTextSharp -Version 5.5.13.3
    /// Usage: ReceiptPdf.aspx?lineId={LineId}
    /// </summary>
    public partial class ReceiptPdf : System.Web.UI.Page
    {
        private readonly string connString =
            ConfigurationManager.ConnectionStrings["HostelDB"].ConnectionString;

        private static readonly BaseColor Purple = new BaseColor(79, 70, 229);
        private static readonly BaseColor Grey = new BaseColor(107, 114, 128);
        private static readonly BaseColor Dark = new BaseColor(31, 41, 55);
        private static readonly BaseColor Red = new BaseColor(220, 38, 38);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Username"] == null) { Response.Redirect("Login.aspx"); return; }
            if (!int.TryParse(Request.QueryString["lineId"], out int lineId)) { Response.Redirect("Receipts.aspx"); return; }

            DataTable dt = RunProc("sp_GetLineReceipt", new[] { new SqlParameter("@LineId", lineId) });
            if (dt.Rows.Count == 0) { Response.Redirect("Receipts.aspx"); return; }

            byte[] pdf = BuildPdf(dt.Rows[0]);

            Response.Clear();
            Response.ContentType = "application/pdf";
            string safeNo = dt.Rows[0]["ReceiptNo"].ToString().Replace("/", "-");
            Response.AddHeader("Content-Disposition", "inline; filename=Receipt_" + safeNo + ".pdf");
            Response.BinaryWrite(pdf);
            Response.End();
        }

        private byte[] BuildPdf(DataRow h)
        {
            using (MemoryStream ms = new MemoryStream())
            {
                Document doc = new Document(PageSize.A5, 34, 34, 30, 30);
                PdfWriter.GetInstance(doc, ms);
                doc.Open();

                Font hostelFont = FontFactory.GetFont("Helvetica", 16, Font.BOLD, Purple);
                Font smallGrey = FontFactory.GetFont("Helvetica", 8, Grey);
                Font titleFont = FontFactory.GetFont("Helvetica", 11, Font.BOLD, Dark);
                Font label = FontFactory.GetFont("Helvetica", 9, Grey);
                Font value = FontFactory.GetFont("Helvetica", 9, Font.BOLD, Dark);

                string hostelName = Str(h["HostelName"]); if (hostelName == "") hostelName = "Hostel";
                doc.Add(new Paragraph(hostelName, hostelFont) { Alignment = Element.ALIGN_CENTER });

                string addr = BuildAddress(h);
                if (addr != "")
                    doc.Add(new Paragraph(addr, smallGrey) { Alignment = Element.ALIGN_CENTER, SpacingAfter = 8f });

                doc.Add(new Chunk(new LineSeparator(1f, 100f, Purple, Element.ALIGN_CENTER, -2)));
                doc.Add(new Paragraph("PAYMENT RECEIPT", titleFont)
                { Alignment = Element.ALIGN_CENTER, SpacingBefore = 8f, SpacingAfter = 10f });

                // Receipt no + date
                PdfPTable meta = new PdfPTable(2) { WidthPercentage = 100 };
                meta.AddCell(KV("Receipt No:", Str(h["ReceiptNo"]), label, value, Element.ALIGN_LEFT));
                meta.AddCell(KV("Date:", Convert.ToDateTime(h["PaymentDate"]).ToString("dd MMM yyyy"), label, value, Element.ALIGN_RIGHT));
                doc.Add(meta);

                // Resident
                PdfPTable info = new PdfPTable(2) { WidthPercentage = 100, SpacingBefore = 6f, SpacingAfter = 6f };
                info.AddCell(KV("Received From:", Str(h["PersonName"]), label, value, Element.ALIGN_LEFT));
                info.AddCell(KV("Room / Bed:", Str(h["RoomNumber"]) + " / Bed " + Str(h["BedNo"]), label, value, Element.ALIGN_RIGHT));
                info.AddCell(KV("Billing Period:",
                    Convert.ToDateTime(h["PeriodFrom"]).ToString("dd MMM yyyy") + " - " +
                    Convert.ToDateTime(h["PeriodTo"]).ToString("dd MMM yyyy"), label, value, Element.ALIGN_LEFT));
                info.AddCell(KV("Mode:", Str(h["PaymentMode"]), label, value, Element.ALIGN_RIGHT));
                doc.Add(info);

                // Amounts box
                PdfPTable amt = new PdfPTable(2) { WidthPercentage = 100, SpacingBefore = 8f };
                amt.AddCell(KV("Monthly Amount:", "Rs. " + Money(h["ActualAmount"]), label, value, Element.ALIGN_LEFT));
                amt.AddCell(KV("Amount Paid:", "Rs. " + Money(h["AmountPaid"]),
                    label, FontFactory.GetFont("Helvetica", 11, Font.BOLD, Purple), Element.ALIGN_RIGHT));
                amt.AddCell(KV("Pending After:", "Rs. " + Money(h["PendingAfter"]),
                    label, FontFactory.GetFont("Helvetica", 9, Font.BOLD, Red), Element.ALIGN_LEFT));
                amt.AddCell(KV("", "", label, value, Element.ALIGN_RIGHT));
                doc.Add(amt);

                // Audit
                PdfPTable audit = new PdfPTable(1) { WidthPercentage = 100, SpacingBefore = 16f };
                audit.AddCell(Plain("Generated by: " + Str(h["GeneratedBy"]) +
                    (h["GeneratedOn"] == DBNull.Value ? "" : "  on " + Convert.ToDateTime(h["GeneratedOn"]).ToString("dd MMM yyyy HH:mm")), smallGrey));
                if (h["ModifiedBy"] != DBNull.Value && Str(h["ModifiedBy"]) != "")
                    audit.AddCell(Plain("Modified by: " + Str(h["ModifiedBy"]) +
                        (h["ModifiedOn"] == DBNull.Value ? "" : "  on " + Convert.ToDateTime(h["ModifiedOn"]).ToString("dd MMM yyyy HH:mm")), smallGrey));
                doc.Add(audit);

                doc.Add(new Paragraph("Authorized Signature", smallGrey)
                { Alignment = Element.ALIGN_RIGHT, SpacingBefore = 26f });

                doc.Close();
                return ms.ToArray();
            }
        }

        // ---- helpers ----
        private PdfPCell KV(string k, string v, Font kf, Font vf, int align)
        {
            Phrase p = new Phrase();
            if (k != "") p.Add(new Chunk(k + "  ", kf));
            p.Add(new Chunk(v, vf));
            return new PdfPCell(p) { Border = Rectangle.NO_BORDER, HorizontalAlignment = align, PaddingBottom = 4f };
        }
        private PdfPCell Plain(string text, Font f)
        {
            return new PdfPCell(new Phrase(text, f)) { Border = Rectangle.NO_BORDER, PaddingBottom = 3f };
        }
        private string BuildAddress(DataRow h)
        {
            string[] parts = { Str(h["Address"]), Str(h["City"]), Str(h["State"]), Str(h["Pincode"]) };
            string line = string.Join(", ", Array.FindAll(parts, p => p != ""));
            string ph = Str(h["WardenPhone"]);
            if (ph != "") line += (line == "" ? "" : "  |  ") + "Ph: " + ph;
            return line;
        }
        private string Str(object o) { return o == null || o == DBNull.Value ? "" : o.ToString(); }
        private string Money(object o) { return o == DBNull.Value ? "0" : Convert.ToDecimal(o).ToString("N0"); }

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
