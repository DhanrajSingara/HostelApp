using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace HostelManagement
{
    public partial class Rooms : System.Web.UI.Page
    {
        private readonly string connString =
            ConfigurationManager.ConnectionStrings["HostelDB"].ConnectionString;

        private int BranchId
        {
            get { return Convert.ToInt32(Session["BranchId"]); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindFloors();
                BindRooms();
            }
        }

        // ---------- Load floors dropdown ----------
        private void BindFloors()
        {
            DataTable dt = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("sp_GetFloors", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Branchid", BranchId);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
            ddlFloor.DataSource = dt;
            ddlFloor.DataValueField = "FloorId";
            ddlFloor.DataTextField = "FloorName";
            ddlFloor.DataBind();
        }

        // ---------- Load list ----------
        private void BindRooms()
        {
            DataTable dt = new DataTable();
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("sp_GetRoomsByBranch", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@BranchId", BranchId);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
            gvRooms.DataSource = dt;
            gvRooms.DataBind();
        }

        // ---------- Add / Update ----------
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtRoomNumber.Text))
            {
                ShowMessage("Room number is required.", false);
                return;
            }

            int roomId = Convert.ToInt32(hdnRoomId.Value);

            try
            {
                string result;
                using (SqlConnection con = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand("sp_SaveRoom", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@RoomId", roomId);
                    cmd.Parameters.AddWithValue("@BranchId", BranchId);
                    cmd.Parameters.AddWithValue("@RoomNumber", txtRoomNumber.Text.Trim());
                    cmd.Parameters.AddWithValue("@FloorId", Convert.ToInt32(ddlFloor.SelectedValue));
                    cmd.Parameters.AddWithValue("@NumberOfBeds", ParseInt(txtBeds.Text));
                    cmd.Parameters.AddWithValue("@Amount", ParseDecimal(txtAmount.Text));
                    cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);

                    // RentPerMonth is computed inside the stored procedure (Beds * Amount).

                    con.Open();
                    result = cmd.ExecuteScalar()?.ToString();
                }

                if (result == "Duplicate")
                {
                    ShowMessage("A room with that number already exists in this branch.", false);
                    return;
                }

                ShowMessage(roomId == 0 ? "Room added successfully." : "Room updated successfully.", true);
                ClearForm();
                BindRooms();
            }
            catch (Exception)
            {
                ShowMessage("An error occurred while saving.", false);
            }
        }

        // ---------- Grid actions ----------
        protected void gvRooms_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int roomId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditRoom")
            {
                LoadRoomForEdit(roomId);
            }
            else if (e.CommandName == "DeleteRoom")
            {
                using (SqlConnection con = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand("sp_DeleteRoom", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@RoomId", roomId);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
                ShowMessage("Room deleted.", true);
                ClearForm();
                BindRooms();
            }
        }

        private void LoadRoomForEdit(int roomId)
        {
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("sp_GetRoomById", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@RoomId", roomId);
                con.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        hdnRoomId.Value = roomId.ToString();
                        txtRoomNumber.Text = r["RoomNumber"].ToString();
                        string floorId = r["FloorId"] == DBNull.Value ? "" : r["FloorId"].ToString();
                        if (ddlFloor.Items.FindByValue(floorId) != null)
                            ddlFloor.SelectedValue = floorId;
                        else
                            ddlFloor.SelectedIndex = 0;
                        txtBeds.Text = r["NumberOfBeds"].ToString();
                        txtAmount.Text = r["Amount"] == DBNull.Value ? "" : Convert.ToDecimal(r["Amount"]).ToString("0");
                        txtRent.Text = r["RentPerMonth"] == DBNull.Value ? "" : Convert.ToDecimal(r["RentPerMonth"]).ToString("0");
                        ddlStatus.SelectedValue = r["Status"].ToString();
                    }
                }
            }

            litFormTitle.Text = "Edit Room";
            btnSave.Text = "Update Room";
            btnCancel.Visible = true;
            lblMessage.Text = "";
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        // ---------- helpers ----------
        private void ClearForm()
        {
            hdnRoomId.Value = "0";
            txtRoomNumber.Text = "";
            if (ddlFloor.Items.Count > 0) ddlFloor.SelectedIndex = 0;
            txtBeds.Text = "";
            txtAmount.Text = "";
            txtRent.Text = "";
            ddlStatus.SelectedValue = "Available";

            litFormTitle.Text = "Add a Room";
            btnSave.Text = "Add Room";
            btnCancel.Visible = false;
        }

        private int ParseInt(string text)
        {
            return int.TryParse(text, out int v) ? v : 0;
        }

        private decimal ParseDecimal(string text)
        {
            return decimal.TryParse(text, out decimal v) ? v : 0m;
        }

        private void ShowMessage(string text, bool success)
        {
            lblMessage.Text = text;
            lblMessage.CssClass = success ? "msg success" : "msg error";
        }
    }
}