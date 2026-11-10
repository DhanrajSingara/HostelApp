<%@ Page Title="Settings" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Settings.aspx.cs" Inherits="HostelManagement.Settings" %>

<asp:Content ID="cphHead" ContentPlaceHolderID="head" runat="server">
    <style>
        .page-head {
            margin-bottom: 18px;
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

        .tabs {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
            margin-bottom: 20px;
            border-bottom: 1px solid var(--border);
        }

        .tab {
            padding: 11px 18px;
            border: none;
            background: transparent;
            cursor: pointer;
            font-family: inherit;
            font-size: 14px;
            font-weight: 600;
            color: var(--text-muted);
            border-bottom: 2.5px solid transparent;
        }

            .tab:hover {
                color: var(--text);
            }

            .tab.active {
                color: var(--primary);
                border-bottom-color: var(--primary);
            }

        .card {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 22px;
            box-shadow: var(--shadow);
        }

        .card-title {
            font-size: 15px;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 16px;
        }

        .form-row {
            display: grid;
            grid-template-columns: repeat(auto-fit,minmax(170px,1fr));
            gap: 14px;
            align-items: end;
            margin-bottom: 8px;
        }

        .fg {
            display: flex;
            flex-direction: column;
        }

            .fg label {
                font-size: 13px;
                font-weight: 600;
                color: var(--text);
                margin-bottom: 6px;
            }

            .fg input, .fg select {
                padding: 10px 13px;
                border: 1.5px solid var(--border);
                border-radius: 9px;
                font-size: 14px;
                color: var(--text);
                background: var(--bg);
                outline: none;
                font-family: inherit;
            }

            .fg.chk {
                flex-direction: row;
                align-items: center;
                gap: 8px;
            }

                .fg.chk input {
                    width: 16px;
                    height: 16px;
                }

        .btn-primary {
            padding: 10px 22px;
            border: none !important;
            border-radius: 9px;
            background: linear-gradient(135deg,#4f46e5,#7c3aed) !important;
            color: #fff !important;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            height: 41px;
        }
        .btn-primary:hover { opacity: .92; }

        .btn-x {
            padding: 10px 16px;
            border: 1.5px solid var(--border);
            border-radius: 9px;
            background: transparent;
            color: var(--text-muted);
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            height: 41px;
        }

        .msg {
            font-size: 13px;
            font-weight: 600;
            margin-left: 4px;
        }

            .msg.success {
                color: #16a34a;
            }

            .msg.error {
                color: #dc2626;
            }

        .tbl {
            width: 100%;
            border-collapse: collapse;
            margin-top: 18px;
        }

            .tbl th {
                text-align: left;
                font-size: 12px;
                text-transform: uppercase;
                letter-spacing: .4px;
                color: var(--text-muted);
                font-weight: 600;
                padding: 11px 12px;
                border-bottom: 1px solid var(--border);
            }

            .tbl td {
                padding: 11px 12px;
                font-size: 14px;
                color: var(--text);
                border-bottom: 1px solid var(--border);
            }

        .act {
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            margin-right: 12px;
            cursor: pointer;
        }

        .act-edit {
            color: var(--primary);
        }

        .act-del {
            color: #dc2626;
        }

        .badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
        }

            .badge.on {
                background: rgba(22,163,74,.15);
                color: #16a34a;
            }

            .badge.off {
                background: rgba(107,114,128,.18);
                color: var(--text-muted);
            }

        .restricted {
            text-align: center;
            padding: 50px 20px;
            color: var(--text-muted);
        }

            .restricted svg {
                width: 44px;
                height: 44px;
                opacity: .5;
                margin-bottom: 12px;
            }

        .divider {
            border: none;
            border-top: 1px solid var(--border);
            margin: 4px 0 0;
        }
    </style>
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-head">
        <h2>Settings</h2>
        <p>Manage branches, floors and expense items.</p>
    </div>

    <asp:Panel ID="pnlRestricted" runat="server" Visible="false">
        <div class="card">
            <div class="restricted">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="11" width="18" height="11" rx="2" />
                    <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                </svg>
                <p>Settings are available to administrators only.</p>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlMain" runat="server">

        <asp:HiddenField ID="hfTab" runat="server" Value="branches" />

        <div class="tabs">
            <asp:LinkButton ID="tabBranches" runat="server" CssClass="tab" OnClick="Tab_Click" CommandArgument="branches">Branches</asp:LinkButton>
            <asp:LinkButton ID="tabFloors" runat="server" CssClass="tab" OnClick="Tab_Click" CommandArgument="floors">Floors</asp:LinkButton>
            <asp:LinkButton ID="tabItems" runat="server" CssClass="tab" OnClick="Tab_Click" CommandArgument="items">Expense Items</asp:LinkButton>
            <asp:LinkButton ID="tabDesig" runat="server" CssClass="tab" OnClick="Tab_Click" CommandArgument="desig">Designations</asp:LinkButton>
        </div>

        <div class="card">

            <!-- ============ BRANCHES ============ -->
            <asp:Panel ID="pnlBranches" runat="server">
                <div class="card-title">Branches</div>
                <asp:HiddenField ID="hfBranchId" runat="server" Value="0" />
                <div class="form-row">
                    <div class="fg">
                        <label>Branch Name</label><asp:TextBox ID="txtBName" runat="server"></asp:TextBox></div>
                    <div class="fg">
                        <label>City</label><asp:TextBox ID="txtBCity" runat="server"></asp:TextBox></div>
                    <div class="fg">
                        <label>Phone</label><asp:TextBox ID="txtBPhone" runat="server"></asp:TextBox></div>
                    <div class="fg">
                        <label>Receipt Prefix</label><asp:TextBox ID="txtBPrefix" runat="server" MaxLength="10"></asp:TextBox></div>
                </div>
                <div class="form-row">
                    <div class="fg" style="grid-column: span 2;">
                        <label>Address</label><asp:TextBox ID="txtBAddress" runat="server"></asp:TextBox></div>
                    <div class="fg chk">
                        <asp:CheckBox ID="chkBActive" runat="server" Checked="true" /><label>Active</label></div>
                    <div class="fg" style="flex-direction: row; gap: 10px;">
                        <asp:Button ID="btnBSave" runat="server" CssClass="btn-primary" Text="Save" OnClick="btnBSave_Click" />
                        <asp:Button ID="btnBClear" runat="server" CssClass="btn-x" Text="Clear" OnClick="btnBClear_Click" CausesValidation="false" />
                    </div>
                </div>
                <asp:Label ID="lblBMsg" runat="server" CssClass="msg"></asp:Label>
                <asp:Repeater ID="rptBranches" runat="server" OnItemCommand="rptBranches_ItemCommand">
                    <HeaderTemplate>
                        <table class="tbl">
                            <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>City</th>
                                    <th>Phone</th>
                                    <th>Prefix</th>
                                    <th>Status</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td><%# Eval("BranchName") %></td>
                            <td><%# Eval("City") %></td>
                            <td><%# Eval("Phone") %></td>
                            <td><%# Eval("ReceiptPrefix") %></td>
                            <td><span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge on" : "badge off" %>'><%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %></span></td>
                            <td>
                                <asp:LinkButton runat="server" CssClass="act act-edit" CommandName="EditBranch" CommandArgument='<%# Eval("BranchId") %>'>Edit</asp:LinkButton></td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate></tbody></table></FooterTemplate>
                </asp:Repeater>
            </asp:Panel>

            <!-- ============ FLOORS ============ -->
            <asp:Panel ID="pnlFloors" runat="server" Visible="false">
                <div class="card-title">Floors (branch-wise)</div>
                <asp:HiddenField ID="hfFloorMode" runat="server" Value="insert" />
                <asp:HiddenField ID="hfFloorId" runat="server" />
                <div class="form-row">
                    <div class="fg">
                        <label>Branch</label>
                        <asp:DropDownList ID="ddlFloorBranch" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFloorBranch_Changed"></asp:DropDownList>
                    </div>
                    <div class="fg">
                        <label>Floor Name</label><asp:TextBox ID="txtFloorName" runat="server"></asp:TextBox></div>
                    <div class="fg" style="flex-direction: row; gap: 10px;">
                        <asp:Button ID="btnFSave" runat="server" CssClass="btn-primary" Text="Save" OnClick="btnFSave_Click" />
                        <asp:Button ID="btnFClear" runat="server" CssClass="btn-x" Text="Clear" OnClick="btnFClear_Click" CausesValidation="false" />
                    </div>
                </div>
                <asp:Label ID="lblFMsg" runat="server" CssClass="msg"></asp:Label>
                <asp:Repeater ID="rptFloors" runat="server" OnItemCommand="rptFloors_ItemCommand">
                    <HeaderTemplate>
                        <table class="tbl">
                            <thead>
                                <tr>
                                    <th>Floor ID</th>
                                    <th>Floor Name</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td><%# Eval("FloorId") %></td>
                            <td><%# Eval("FloorName") %></td>
                            <td>
                                <asp:LinkButton runat="server" CssClass="act act-edit" CommandName="EditFloor" CommandArgument='<%# Eval("FloorId") %>'>Edit</asp:LinkButton>
                                <asp:LinkButton runat="server" CssClass="act act-del" CommandName="DeleteFloor" Visible="false" CommandArgument='<%# Eval("FloorId") %>'
                                    OnClientClick="return confirm('Delete this floor?');">Delete</asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate></tbody></table></FooterTemplate>
                </asp:Repeater>
            </asp:Panel>

            <!-- ============ EXPENSE ITEMS ============ -->
            <asp:Panel ID="pnlItems" runat="server" Visible="false">
                <div class="card-title">Expense Items</div>
                <asp:HiddenField ID="hfItemId" runat="server" Value="0" />
                <div class="form-row">
                    <div class="fg">
                        <label>Item Name</label><asp:TextBox ID="txtItemName" runat="server"></asp:TextBox></div>
                    <div class="fg">
                        <label>Supplier</label><asp:TextBox ID="txtItemSupplier" runat="server"></asp:TextBox></div>
                    <div class="fg chk">
                        <asp:CheckBox ID="chkIActive" runat="server" Checked="true" /><label>Active</label></div>
                    <div class="fg" style="flex-direction: row; gap: 10px;">
                        <asp:Button ID="btnISave" runat="server" CssClass="btn-primary" Text="Save" OnClick="btnISave_Click" />
                        <asp:Button ID="btnIClear" runat="server" CssClass="btn-x" Text="Clear" OnClick="btnIClear_Click" CausesValidation="false" />
                    </div>
                </div>
                <asp:Label ID="lblIMsg" runat="server" CssClass="msg"></asp:Label>
                <asp:Repeater ID="rptItems" runat="server" OnItemCommand="rptItems_ItemCommand">
                    <HeaderTemplate>
                        <table class="tbl">
                            <thead>
                                <tr>
                                    <th>Item Name</th>
                                    <th>Supplier</th>
                                    <th>Status</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td><%# Eval("ItemName") %></td>
                            <td><%# Eval("Supplier") %></td>
                            <td><span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge on" : "badge off" %>'><%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %></span></td>
                            <td>
                                <asp:LinkButton runat="server" CssClass="act act-edit" CommandName="EditItem" CommandArgument='<%# Eval("ItemId") %>'>Edit</asp:LinkButton></td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate></tbody></table></FooterTemplate>
                </asp:Repeater>
            </asp:Panel>

            <!-- ============ DESIGNATIONS ============ -->
            <asp:Panel ID="pnlDesig" runat="server" Visible="false">
                <div class="card-title">Designations (used by the Staff page)</div>
                <asp:HiddenField ID="hfDesigId" runat="server" Value="0" />
                <div class="form-row">
                    <div class="fg" style="grid-column: span 2;">
                        <label>Designation Name</label><asp:TextBox ID="txtDesigName" runat="server"></asp:TextBox></div>
                    <div class="fg chk">
                        <asp:CheckBox ID="chkDActive" runat="server" Checked="true" /><label>Active</label></div>
                    <div class="fg" style="flex-direction: row; gap: 10px;">
                        <asp:Button ID="btnDSave" runat="server" CssClass="btn-primary" Text="Save" OnClick="btnDSave_Click" />
                        <asp:Button ID="btnDClear" runat="server" CssClass="btn-x" Text="Clear" OnClick="btnDClear_Click" CausesValidation="false" />
                    </div>
                </div>
                <asp:Label ID="lblDMsg" runat="server" CssClass="msg"></asp:Label>
                <asp:Repeater ID="rptDesig" runat="server" OnItemCommand="rptDesig_ItemCommand">
                    <HeaderTemplate>
                        <table class="tbl">
                            <thead>
                                <tr>
                                    <th>Designation</th>
                                    <th>Status</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td><%# Eval("DesignationName") %></td>
                            <td><span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge on" : "badge off" %>'><%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %></span></td>
                            <td>
                                <asp:LinkButton runat="server" CssClass="act act-edit" CommandName="EditDesig" CommandArgument='<%# Eval("DesignationId") %>'>Edit</asp:LinkButton></td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate></tbody></table></FooterTemplate>
                </asp:Repeater>
            </asp:Panel>

        </div>
    </asp:Panel>

</asp:Content>
