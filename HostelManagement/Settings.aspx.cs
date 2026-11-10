using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace HostelManagement
{
    public partial class Settings : System.Web.UI.Page
    {
        private readonly string connString =
            ConfigurationManager.ConnectionStrings["HostelDB"].ConnectionString;

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
                BindBranchDropdown();
                ShowTab("branches");
                LoadBranches();
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
                case "branches": LoadBranches(); break;
                case "floors": LoadFloors(); break;
                case "items": LoadItems(); break;
                case "desig": LoadDesig(); break;
            }
        }

        private void ShowTab(string tab)
        {
            pnlBranches.Visible = tab == "branches";
            pnlFloors.Visible = tab == "floors";
            pnlItems.Visible = tab == "items";
            pnlDesig.Visible = tab == "desig";
            tabBranches.CssClass = "tab" + (tab == "branches" ? " active" : "");
            tabFloors.CssClass = "tab" + (tab == "floors" ? " active" : "");
            tabItems.CssClass = "tab" + (tab == "items" ? " active" : "");
            tabDesig.CssClass = "tab" + (tab == "desig" ? " active" : "");
        }

        /* ================= BRANCHES ================= */
        private void LoadBranches()
        {
            rptBranches.DataSource = RunProc("sp_GetAllBranches", null);
            rptBranches.DataBind();
        }

        protected void btnBSave_Click(object sender, EventArgs e)
        {
            var res = RunProc("sp_SaveBranch", new[]
            {
                new SqlParameter("@BranchId", string.IsNullOrEmpty(hfBranchId.Value) ? 0 : Convert.ToInt32(hfBranchId.Value)),
                new SqlParameter("@BranchName", txtBName.Text.Trim()),
                new SqlParameter("@City", txtBCity.Text.Trim()),
                new SqlParameter("@Address", txtBAddress.Text.Trim()),
                new SqlParameter("@Phone", txtBPhone.Text.Trim()),
                new SqlParameter("@ReceiptPrefix", txtBPrefix.Text.Trim()),
                new SqlParameter("@IsActive", chkBActive.Checked ? 1 : 0)
            });
            ShowTab("branches");
            ClearBranchForm();
            LoadBranches();
            BindBranchDropdown();
            Msg(lblBMsg, "Branch saved.", true);
        }

        protected void btnBClear_Click(object sender, EventArgs e) { ShowTab("branches"); ClearBranchForm(); LoadBranches(); }

        protected void rptBranches_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "EditBranch") return;
            DataTable dt = RunProc("sp_GetAllBranches", null);
            DataRow r = FindRow(dt, "BranchId", e.CommandArgument);
            if (r == null) return;
            hfBranchId.Value = r["BranchId"].ToString();
            txtBName.Text = r["BranchName"].ToString();
            txtBCity.Text = r["City"].ToString();
            txtBAddress.Text = r["Address"].ToString();
            txtBPhone.Text = r["Phone"].ToString();
            txtBPrefix.Text = r["ReceiptPrefix"].ToString();
            chkBActive.Checked = Convert.ToBoolean(r["IsActive"]);
            ShowTab("branches");
            LoadBranches();
        }

        private void ClearBranchForm()
        {
            hfBranchId.Value = "0";
            txtBName.Text = txtBCity.Text = txtBAddress.Text = txtBPhone.Text = txtBPrefix.Text = "";
            chkBActive.Checked = true;
        }

        /* ================= FLOORS ================= */
        private void BindBranchDropdown()
        {
            DataTable dt = RunProc("sp_GetAllBranches", null);
            ddlFloorBranch.Items.Clear();
            foreach (DataRow r in dt.Rows)
                ddlFloorBranch.Items.Add(new ListItem(r["BranchName"].ToString(), r["BranchId"].ToString()));
        }

        protected void ddlFloorBranch_Changed(object sender, EventArgs e) { ShowTab("floors"); ClearFloorForm(); LoadFloors(); }

        private void LoadFloors()
        {
            if (ddlFloorBranch.Items.Count == 0) return;
            rptFloors.DataSource = RunProc("sp_GetFloorsByBranch", new[]
                { new SqlParameter("@Branch", Convert.ToInt32(ddlFloorBranch.SelectedValue)) });
            rptFloors.DataBind();
        }

        protected void btnFSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtFloorName.Text))
            { ShowTab("floors"); LoadFloors(); Msg(lblFMsg, "Enter floor name.", false); return; }

            var res = RunProc("sp_SaveFloor", new[]
            {
                new SqlParameter("@FloorId", hfFloorId.Value == "" ? 0 : Convert.ToInt32(hfFloorId.Value)),
                new SqlParameter("@FloorName", txtFloorName.Text.Trim()),
                new SqlParameter("@Branch", Convert.ToInt32(ddlFloorBranch.SelectedValue)),
                new SqlParameter("@Mode", hfFloorMode.Value)
            });
            string result = res.Rows.Count > 0 ? res.Rows[0]["Result"].ToString() : "";
            ShowTab("floors");
            ClearFloorForm();
            LoadFloors();
            if (result == "Duplicate") Msg(lblFMsg, "That floor name already exists for this branch.", false);
            else Msg(lblFMsg, "Floor saved.", true);
        }

        protected void btnFClear_Click(object sender, EventArgs e) { ShowTab("floors"); ClearFloorForm(); LoadFloors(); }

        protected void rptFloors_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            ShowTab("floors");
            int branch = Convert.ToInt32(ddlFloorBranch.SelectedValue);

            if (e.CommandName == "EditFloor")
            {
                DataTable dt = RunProc("sp_GetFloorsByBranch", new[] { new SqlParameter("@Branch", branch) });
                DataRow r = FindRow(dt, "FloorId", e.CommandArgument);
                if (r != null)
                {
                    hfFloorId.Value = r["FloorId"].ToString();
                    txtFloorName.Text = r["FloorName"].ToString();
                    hfFloorMode.Value = "update";
                }
                LoadFloors();
            }
            else if (e.CommandName == "DeleteFloor")
            {
                var res = RunProc("sp_DeleteFloor", new[]
                {
                    new SqlParameter("@FloorId", Convert.ToInt32(e.CommandArgument)),
                    new SqlParameter("@Branch", branch)
                });
                string result = res.Rows.Count > 0 ? res.Rows[0]["Result"].ToString() : "";
                ClearFloorForm();
                LoadFloors();
                if (result == "InUse") Msg(lblFMsg, "Can't delete: rooms are using this floor.", false);
                else Msg(lblFMsg, "Floor deleted.", true);
            }
        }

        private void ClearFloorForm()
        {
            txtFloorName.Text = "";
            hfFloorId.Value = "";
            hfFloorMode.Value = "insert";
        }

        /* ================= EXPENSE ITEMS ================= */
        private void LoadItems()
        {
            rptItems.DataSource = RunProc("sp_GetAllExpenseItems", null);
            rptItems.DataBind();
        }

        protected void btnISave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtItemName.Text))
            { ShowTab("items"); LoadItems(); Msg(lblIMsg, "Enter an item name.", false); return; }

            var res = RunProc("sp_SaveExpenseItem", new[]
            {
                new SqlParameter("@ItemId", string.IsNullOrEmpty(hfItemId.Value) ? 0 : Convert.ToInt32(hfItemId.Value)),
                new SqlParameter("@ItemName", txtItemName.Text.Trim()),
                new SqlParameter("@Supplier", txtItemSupplier.Text.Trim()),
                new SqlParameter("@IsActive", chkIActive.Checked ? 1 : 0)
            });
            string result = res.Rows.Count > 0 ? res.Rows[0]["Result"].ToString() : "";
            ShowTab("items");
            ClearItemForm();
            LoadItems();
            if (result == "Duplicate") Msg(lblIMsg, "That item already exists.", false);
            else Msg(lblIMsg, "Item saved.", true);
        }

        protected void btnIClear_Click(object sender, EventArgs e) { ShowTab("items"); ClearItemForm(); LoadItems(); }

        protected void rptItems_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "EditItem") return;
            DataTable dt = RunProc("sp_GetAllExpenseItems", null);
            DataRow r = FindRow(dt, "ItemId", e.CommandArgument);
            if (r != null)
            {
                hfItemId.Value = r["ItemId"].ToString();
                txtItemName.Text = r["ItemName"].ToString();
                txtItemSupplier.Text = r["Supplier"].ToString();
                chkIActive.Checked = Convert.ToBoolean(r["IsActive"]);
            }
            ShowTab("items");
            LoadItems();
        }

        private void ClearItemForm()
        {
            hfItemId.Value = "0";
            txtItemName.Text = "";
            txtItemSupplier.Text = "";
            chkIActive.Checked = true;
        }

        /* ================= DESIGNATIONS ================= */
        private void LoadDesig()
        {
            rptDesig.DataSource = RunProc("sp_GetAllDesignations", null);
            rptDesig.DataBind();
        }

        protected void btnDSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtDesigName.Text))
            { ShowTab("desig"); LoadDesig(); Msg(lblDMsg, "Enter a designation name.", false); return; }

            var res = RunProc("sp_SaveDesignation", new[]
            {
                new SqlParameter("@DesignationId", string.IsNullOrEmpty(hfDesigId.Value) ? 0 : Convert.ToInt32(hfDesigId.Value)),
                new SqlParameter("@DesignationName", txtDesigName.Text.Trim()),
                new SqlParameter("@IsActive", chkDActive.Checked ? 1 : 0)
            });
            string result = res.Rows.Count > 0 ? res.Rows[0]["Result"].ToString() : "";
            ShowTab("desig");
            ClearDesigForm();
            LoadDesig();
            if (result == "Duplicate") Msg(lblDMsg, "That designation already exists.", false);
            else Msg(lblDMsg, "Designation saved.", true);
        }

        protected void btnDClear_Click(object sender, EventArgs e) { ShowTab("desig"); ClearDesigForm(); LoadDesig(); }

        protected void rptDesig_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "EditDesig") return;
            DataTable dt = RunProc("sp_GetAllDesignations", null);
            DataRow r = FindRow(dt, "DesignationId", e.CommandArgument);
            if (r != null)
            {
                hfDesigId.Value = r["DesignationId"].ToString();
                txtDesigName.Text = r["DesignationName"].ToString();
                chkDActive.Checked = Convert.ToBoolean(r["IsActive"]);
            }
            ShowTab("desig");
            LoadDesig();
        }

        private void ClearDesigForm()
        {
            hfDesigId.Value = "0";
            txtDesigName.Text = "";
            chkDActive.Checked = true;
        }

        /* ================= helpers ================= */
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

        private DataRow FindRow(DataTable dt, string col, object val)
        {
            string s = Convert.ToString(val);
            foreach (DataRow r in dt.Rows) if (r[col].ToString() == s) return r;
            return null;
        }

        private void Msg(Label l, string text, bool ok)
        {
            l.Text = text;
            l.CssClass = ok ? "msg success" : "msg error";
        }
    }
}
