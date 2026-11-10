<%@ Page Title="Rooms" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Rooms.aspx.cs" Inherits="HostelManagement.Rooms" %>

<asp:Content ID="cphHead" ContentPlaceHolderID="head" runat="server">
    <style>
        .page-head {
            margin-bottom: 22px;
        }

            .page-head h2 {
                font-size: 22px;
                font-weight: 700;
                color: var(--text);
            }

            .page-head p {
                font-size: 13px;
                color: var(--text-muted);
                margin-top: 4px;
            }

        .card {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 24px;
            box-shadow: var(--shadow);
            margin-bottom: 22px;
        }

            .card h3 {
                font-size: 15px;
                font-weight: 600;
                color: var(--text);
                margin-bottom: 18px;
            }

        .form-row {
            display: grid;
            grid-template-columns: repeat(auto-fit,minmax(180px,1fr));
            gap: 16px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

            .form-group label {
                font-size: 13px;
                font-weight: 600;
                color: var(--text);
                margin-bottom: 6px;
            }

            .form-group input, .form-group select {
                padding: 11px 13px;
                border: 1.5px solid var(--border);
                border-radius: 9px;
                font-size: 14px;
                color: var(--text);
                background: var(--bg);
                outline: none;
                transition: all .18s ease;
                font-family: inherit;
            }

                .form-group input:focus, .form-group select:focus {
                    border-color: var(--primary);
                    box-shadow: 0 0 0 3px rgba(124,58,237,.15);
                }

                .form-group input[readonly] {
                    background: var(--hover);
                    color: var(--text-muted);
                    cursor: not-allowed;
                }

        .actions {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-top: 20px;
        }

        .btn-primary {
            padding: 11px 26px;
            border: none;
            border-radius: 10px;
            background: var(--primary-grad);
            color: #fff;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all .2s ease;
        }

            .btn-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 10px 22px rgba(124,58,237,.35);
            }

        .btn-cancel {
            padding: 11px 20px;
            border: 1px solid var(--border);
            border-radius: 10px;
            background: transparent;
            color: var(--text-muted);
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
        }

            .btn-cancel:hover {
                color: var(--text);
                border-color: var(--text-muted);
            }

        .msg {
            font-size: 13px;
            font-weight: 600;
        }

            .msg.success {
                color: #16a34a;
            }

            .msg.error {
                color: #dc2626;
            }

        /* ---- Rooms table ---- */
        .rooms-table {
            width: 100%;
            border-collapse: collapse;
        }

            .rooms-table th {
                text-align: left;
                font-size: 12px;
                text-transform: uppercase;
                letter-spacing: .4px;
                color: var(--text-muted);
                font-weight: 600;
                padding: 12px 14px;
                border-bottom: 1px solid var(--border);
            }

            .rooms-table td {
                padding: 13px 14px;
                font-size: 14px;
                color: var(--text);
                border-bottom: 1px solid var(--border);
            }

            .rooms-table tr:hover td {
                background: var(--hover);
            }

        .badge {
            display: inline-block;
            padding: 4px 11px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .badge-available {
            background: rgba(22,163,74,.14);
            color: #16a34a;
        }

        .badge-occupied {
            background: rgba(216,90,48,.14);
            color: #d85a30;
        }

        .badge-maintenance {
            background: rgba(226,75,74,.14);
            color: #e24b4a;
        }

        .act-link {
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            margin-right: 14px;
        }

        .act-edit {
            color: var(--primary);
        }

        .act-del {
            color: #dc2626;
        }

        .empty {
            text-align: center;
            color: var(--text-muted);
            padding: 30px;
            font-size: 14px;
        }
    </style>
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-head">
        <h2>Rooms</h2>
        <p>Add and manage rooms for this hostel branch.</p>
    </div>

    <!-- ===== Add / Edit form ===== -->
    <div class="card">
        <h3>
            <asp:Literal ID="litFormTitle" runat="server" Text="Add a Room"></asp:Literal></h3>

        <asp:HiddenField ID="hdnRoomId" runat="server" Value="0" />

        <div class="form-row">
            <div class="form-group">
                <label>Room Number</label>
                <asp:TextBox ID="txtRoomNumber" runat="server" autocomplete="off" placeholder="e.g. A-101"></asp:TextBox>
            </div>
            <div class="form-group">
                <label>Floor</label>
                <asp:DropDownList ID="ddlFloor" runat="server"></asp:DropDownList>
            </div>
            <div class="form-group">
                <label>Number of Beds</label>
                <asp:TextBox ID="txtBeds" runat="server" TextMode="Number" placeholder="e.g. 4"
                    onkeyup="calcRent()" onchange="calcRent()"></asp:TextBox>
            </div>
            <div class="form-group">
                <label>Amount (&#8377; per bed)</label>
                <asp:TextBox ID="txtAmount" runat="server" TextMode="Number" placeholder="e.g. 2000"
                    onkeyup="calcRent()" onchange="calcRent()"></asp:TextBox>
            </div>
            <div class="form-group">
                <label>Rent / Month (&#8377;)</label>
                <asp:TextBox ID="txtRent" runat="server" TextMode="Number"
                    ReadOnly="true" placeholder="Auto-calculated"></asp:TextBox>
            </div>
            <div class="form-group">
                <label>Status</label>
                <asp:DropDownList ID="ddlStatus" runat="server">
                    <asp:ListItem Text="Available" Value="Available"></asp:ListItem>
                    <asp:ListItem Text="Occupied" Value="Occupied"></asp:ListItem>
                    <asp:ListItem Text="Maintenance" Value="Maintenance"></asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>

        <div class="actions">
            <asp:Button ID="btnSave" runat="server" CssClass="btn-primary"
                Text="Add Room" OnClick="btnSave_Click" />
            <asp:Button ID="btnCancel" runat="server" CssClass="btn-cancel"
                Text="Cancel" OnClick="btnCancel_Click" Visible="false" CausesValidation="false" />
            <asp:Label ID="lblMessage" runat="server" CssClass="msg"></asp:Label>
        </div>
    </div>

    <!-- ===== Rooms list ===== -->
    <div class="card">
        <h3>Existing Rooms</h3>

        <asp:GridView ID="gvRooms" runat="server" AutoGenerateColumns="false"
            CssClass="rooms-table" GridLines="None" Width="100%"
            OnRowCommand="gvRooms_RowCommand">
            <Columns>
                <asp:BoundField DataField="RoomNumber" HeaderText="Room" />
                <asp:BoundField DataField="FloorName" HeaderText="Floor" />
                <asp:BoundField DataField="NumberOfBeds" HeaderText="Beds" />
                <asp:BoundField DataField="Amount" HeaderText="Amount" DataFormatString="{0:N0}" />
                <asp:BoundField DataField="RentPerMonth" HeaderText="Rent/Month" DataFormatString="{0:N0}" />
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate>
                        <span class='badge badge-<%# Eval("Status").ToString().ToLower() %>'>
                            <%# Eval("Status") %></span>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <asp:LinkButton runat="server" CssClass="act-link act-edit"
                            CommandName="EditRoom" CommandArgument='<%# Eval("RoomId") %>'>Edit</asp:LinkButton>
                        <asp:LinkButton runat="server" CssClass="act-link act-del" Visible="false"
                            CommandName="DeleteRoom" CommandArgument='<%# Eval("RoomId") %>'
                            OnClientClick="return confirm('Delete this room?');">Delete</asp:LinkButton>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
            <EmptyDataTemplate>
                <div class="empty">No rooms added yet for this branch.</div>
            </EmptyDataTemplate>
        </asp:GridView>
    </div>

    <script>
        function calcRent() {
            var beds = parseFloat(document.getElementById('<%= txtBeds.ClientID %>').value) || 0;
            var amount = parseFloat(document.getElementById('<%= txtAmount.ClientID %>').value) || 0;
            document.getElementById('<%= txtRent.ClientID %>').value = (beds * amount) || '';
        }
    </script>

</asp:Content>
