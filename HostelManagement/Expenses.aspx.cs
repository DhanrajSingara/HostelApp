using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;

namespace HostelManagement
{
    public partial class Expenses : System.Web.UI.Page
    {
        private readonly string connString =
            ConfigurationManager.ConnectionStrings["HostelDB"].ConnectionString;

        private int BranchId { get { return Convert.ToInt32(Session["BranchId"]); } }
        private string CurrentUser { get { return Session["Username"]?.ToString() ?? ""; } }
        private bool IsAdmin
        {
            get { return string.Equals(Session["Role"]?.ToString(), "Admin", StringComparison.OrdinalIgnoreCase); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            BindItems();
            if (!IsPostBack)
            {
                txtDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                LoadDate(DateTime.Today);
            }
        }

        // ---------- Item master list for the searchable dropdown ----------
        private void BindItems()
        {
            DataTable dt = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("sp_GetExpenseItems", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            }

            var names = new List<string>();
            var supplierMap = new Dictionary<string, string>();
            foreach (DataRow r in dt.Rows)
            {
                string name = r["ItemName"].ToString();
                names.Add(name);
                supplierMap[name] = dt.Columns.Contains("Supplier") ? r["Supplier"].ToString() : "";
            }

            var js = new JavaScriptSerializer();
            litItems.Text = "<script>var ITEMS=" + js.Serialize(names) +
                            ";var ITEM_SUPPLIER=" + js.Serialize(supplierMap) + ";</script>";
        }

        protected void txtDate_Changed(object sender, EventArgs e)
        {
            DateTime d = DateTime.TryParse(txtDate.Text, out DateTime dt) ? dt : DateTime.Today;
            LoadDate(d);
            lblMsg.Text = "";
        }

        // ---------- Load a date's rows + decide edit permission ----------
        private void LoadDate(DateTime date)
        {
            DataTable dt = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("sp_GetExpensesByDate", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@BranchId", BranchId);
                cmd.Parameters.AddWithValue("@ExpenseDate", date.Date);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            }

            bool hasData = dt.Rows.Count > 0;
            bool canEdit = !hasData || IsAdmin;   // existing day -> admin only

            var rows = new List<object>();
            foreach (DataRow r in dt.Rows)
            {
                rows.Add(new
                {
                    item = r["ItemName"].ToString(),
                    supplier = r["Supplier"] == DBNull.Value ? "" : r["Supplier"].ToString(),
                    qty = Convert.ToDecimal(r["Quantity"]),
                    price = Convert.ToDecimal(r["Price"])
                });
            }

            string json = new JavaScriptSerializer().Serialize(rows);
            litData.Text = "<script>var LOADED=" + json + ";var CAN_EDIT=" + (canEdit ? "true" : "false") + ";</script>";

            btnSave.Visible = canEdit;   // hide Save for non-admin on an existing date
        }

        // ---------- Save / Update ----------
        protected void btnSave_Click(object sender, EventArgs e)
        {
            DateTime date = DateTime.TryParse(txtDate.Text, out DateTime dt) ? dt : DateTime.Today;

            // Parse the grid rows sent from the browser.
            var list = new JavaScriptSerializer()
                .Deserialize<List<Dictionary<string, object>>>(
                    string.IsNullOrEmpty(hfRows.Value) ? "[]" : hfRows.Value);

            DataTable rows = new DataTable();
            rows.Columns.Add("ItemName", typeof(string));
            rows.Columns.Add("Supplier", typeof(string));
            rows.Columns.Add("Quantity", typeof(decimal));
            rows.Columns.Add("Price", typeof(decimal));
            rows.Columns.Add("Amount", typeof(decimal));

            foreach (var r in list)
            {
                string item = r.ContainsKey("item") ? Convert.ToString(r["item"]) : "";
                if (string.IsNullOrWhiteSpace(item)) continue;
                string supplier = r.ContainsKey("supplier") ? Convert.ToString(r["supplier"]) : "";
                if (string.IsNullOrWhiteSpace(supplier))
                {
                    // server-side guard: supplier is mandatory for any item row
                    LoadDate(date);
                    lblMsg.Text = "Supplier is required for every item.";
                    lblMsg.CssClass = "msg error";
                    return;
                }
                decimal qty = r.ContainsKey("qty") ? ToDec(r["qty"]) : 0;
                decimal price = r.ContainsKey("price") ? ToDec(r["price"]) : 0;
                rows.Rows.Add(item.Trim(), supplier.Trim(), qty, price, qty * price);
            }

            string result;
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("sp_SaveExpenses", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@BranchId", BranchId);
                cmd.Parameters.AddWithValue("@ExpenseDate", date.Date);
                cmd.Parameters.AddWithValue("@User", CurrentUser);
                cmd.Parameters.AddWithValue("@IsAdmin", IsAdmin ? 1 : 0);
                SqlParameter tvp = cmd.Parameters.AddWithValue("@Rows", rows);
                tvp.SqlDbType = SqlDbType.Structured;
                tvp.TypeName = "ExpenseTVP";

                con.Open();
                result = Convert.ToString(cmd.ExecuteScalar());
            }

            LoadDate(date);   // refresh grid + permissions

            if (result == "Denied")
            {
                lblMsg.Text = "This date already has expenses. Only an admin can update them.";
                lblMsg.CssClass = "msg error";
            }
            else if (result == "Success")
            {
                lblMsg.Text = "Expenses saved.";
                lblMsg.CssClass = "msg success";
            }
            else
            {
                lblMsg.Text = "Could not save. Please try again.";
                lblMsg.CssClass = "msg error";
            }
        }

        private decimal ToDec(object o)
        {
            return decimal.TryParse(Convert.ToString(o), out decimal d) ? d : 0m;
        }
    }
}
