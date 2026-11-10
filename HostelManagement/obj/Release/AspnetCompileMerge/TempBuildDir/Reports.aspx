<%@ Page Title="Reports" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Reports.aspx.cs" Inherits="HostelManagement.Reports" %>

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

        /* tabs */
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

        .filters {
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
            align-items: flex-end;
            margin-bottom: 20px;
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

        .btn-run {
            padding: 10px 22px;
            border: none;
            border-radius: 9px;
            background: var(--primary-grad);
            color: #fff;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            height: 41px;
        }

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

        .btn-print, .btn-excel {
            padding: 9px 18px;
            border-radius: 9px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            font-family: inherit;
            height: 41px;
        }
        .btn-excel { background: #16a34a; color: #fff; border: none; }
        .btn-excel:hover { background: #15803d; }
        .btn-print { background: transparent; color: var(--text-muted); border: 1.5px solid var(--border); }
        .btn-print:hover { border-color: var(--primary); color: var(--primary); }

        .tbl {
            width: 100%;
            border-collapse: collapse;
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

            .tbl .num {
                text-align: right;
            }

            .tbl tfoot td {
                font-weight: 700;
                border-top: 2px solid var(--border);
                color: var(--text);
            }

        .rcpt {
            color: var(--primary);
            font-weight: 600;
        }

        .pos {
            color: #16a34a;
            font-weight: 600;
        }

        .neg {
            color: #dc2626;
            font-weight: 600;
        }

        .pill {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
        }

            .pill.due {
                background: rgba(216,90,48,.15);
                color: #d85a30;
            }

        .empty {
            text-align: center;
            color: var(--text-muted);
            padding: 30px;
            font-size: 14px;
        }

        .hide {
            display: none !important;
        }

        .toolbar {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-bottom: 14px;
        }

        @media print {
            .sidebar, .topbar, .tabs, .filters, .toolbar, .app-footer {
                display: none !important;
            }

            .content {
                margin-left: 0 !important;
            }

            .card {
                box-shadow: none;
                border: none;
            }
        }

        .btn-excel {
            background: #16a34a;
            color: #fff;
            border: none;
            padding: 9px 18px;
            border-radius: 9px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
        }

            .btn-excel:hover {
                background: #15803d;
            }

        .btn-print {
            background: transparent;
            color: var(--text-muted);
            border: 1.5px solid var(--border);
            padding: 9px 18px;
            border-radius: 9px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
        }

            .btn-print:hover {
                border-color: var(--primary);
                color: var(--primary);
            }
    </style>
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-head">
        <h2>Reports</h2>
        <p>View collections, dues, expenses, occupancy and profit.</p>
    </div>

    <asp:HiddenField ID="hfTab" runat="server" Value="collections" />

    <div class="tabs">
        <asp:LinkButton ID="tabCollections" runat="server" CssClass="tab" OnClick="Tab_Click" CommandArgument="collections">Collections</asp:LinkButton>
        <asp:LinkButton ID="tabDues" runat="server" CssClass="tab" OnClick="Tab_Click" CommandArgument="dues">Dues / Outstanding</asp:LinkButton>
        <asp:LinkButton ID="tabExpenses" runat="server" CssClass="tab" OnClick="Tab_Click" CommandArgument="expenses">Expenses</asp:LinkButton>
        <asp:LinkButton ID="tabOccupancy" runat="server" CssClass="tab" OnClick="Tab_Click" CommandArgument="occupancy">Occupancy</asp:LinkButton>
        <asp:LinkButton ID="tabIncome" runat="server" CssClass="tab" OnClick="Tab_Click" CommandArgument="income">Income vs Expense</asp:LinkButton>
        <asp:LinkButton ID="tabRoomHist" runat="server" CssClass="tab" OnClick="Tab_Click" CommandArgument="roomhist">Room History</asp:LinkButton>
    </div>

    <div class="card">

        <!-- ============ COLLECTIONS ============ -->
        <asp:Panel ID="pnlCollections" runat="server">
            <div class="card-title">Collections</div>
            <div class="filters">
                <div class="fg">
                    <label>From</label><asp:TextBox ID="colFrom" runat="server" TextMode="Date"></asp:TextBox>
                </div>
                <div class="fg">
                    <label>To</label><asp:TextBox ID="colTo" runat="server" TextMode="Date"></asp:TextBox>
                </div>
                <asp:Button ID="btnColRun" runat="server" CssClass="btn-run" Text="View" OnClick="btnColRun_Click" />
                <button type="button" class="btn-print" onclick="printReport()">Print</button>
                <asp:Button ID="btnColXls" runat="server" CssClass="btn-excel" Text="Excel" OnClick="btnColXls_Click" />
            </div>
            <asp:Repeater ID="rptCol" runat="server">
                <HeaderTemplate>
                    <table class="tbl">
                        <thead>
                            <tr>
                                <th>Receipt No</th>
                                <th>Date</th>
                                <th>Resident</th>
                                <th>Room/Bed</th>
                                <th>Mode</th>
                                <th class="num">Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td class="rcpt"><%# Eval("ReceiptNo") %></td>
                        <td><%# Eval("PaymentDate","{0:dd/MM/yyyy}") %></td>
                        <td><%# Eval("PersonName") %></td>
                        <td><%# Eval("RoomNumber") %> / <%# Eval("BedNo") %></td>
                        <td><%# Eval("PaymentMode") %></td>
                        <td class="num"><%# Eval("AmountPaid","{0:N0}") %></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </tbody>
                   
                    <tfoot>
                        <tr>
                            <td colspan="5">Total Collected</td>
                            <td class="num">
                                <asp:Literal ID="litColTotal" runat="server"></asp:Literal></td>
                        </tr>
                    </tfoot>
                    </table>
               
                </FooterTemplate>
            </asp:Repeater>
            <asp:Panel ID="pnlColEmpty" runat="server" Visible="false">
                <div class="empty">No payments in this range.</div>
            </asp:Panel>
        </asp:Panel>

        <!-- ============ DUES ============ -->
        <asp:Panel ID="pnlDues" runat="server" Visible="false">
            <div class="card-title">Dues / Outstanding</div>
            <div class="toolbar">
                <button type="button" class="btn-print" onclick="printReport()">Print</button>
                <asp:Button ID="btnDuesXls" runat="server" CssClass="btn-excel" Text="Excel" OnClick="btnDuesXls_Click" />
            </div>
            <asp:Repeater ID="rptDues" runat="server">
                <HeaderTemplate>
                    <table class="tbl">
                        <thead>
                            <tr>
                                <th>Resident</th>
                                <th>Phone</th>
                                <th>Room/Bed</th>
                                <th>Period</th>
                                <th class="num">Amount</th>
                                <th class="num">Paid</th>
                                <th class="num">Pending</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("PersonName") %></td>
                        <td><%# Eval("Phone") %></td>
                        <td><%# Eval("RoomNumber") %> / <%# Eval("BedNo") %></td>
                        <td><%# Eval("PeriodFrom","{0:dd MMM}") %> &ndash; <%# Eval("PeriodTo","{0:dd MMM yyyy}") %></td>
                        <td class="num"><%# Eval("ActualAmount","{0:N0}") %></td>
                        <td class="num"><%# Eval("Paid","{0:N0}") %></td>
                        <td class="num"><span class="pill due"><%# Eval("Pending","{0:N0}") %></span></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </tbody>
                   
                    <tfoot>
                        <tr>
                            <td colspan="6">Total Outstanding</td>
                            <td class="num">
                                <asp:Literal ID="litDuesTotal" runat="server"></asp:Literal></td>
                        </tr>
                    </tfoot>
                    </table>
               
                </FooterTemplate>
            </asp:Repeater>
            <asp:Panel ID="pnlDuesEmpty" runat="server" Visible="false">
                <div class="empty">No outstanding dues. </div>
            </asp:Panel>
        </asp:Panel>

        <!-- ============ EXPENSES ============ -->
        <asp:Panel ID="pnlExpenses" runat="server" Visible="false">
            <div class="card-title">Expenses</div>
            <div class="filters">
                <div class="fg">
                    <label>From</label><asp:TextBox ID="expFrom" runat="server" TextMode="Date"></asp:TextBox>
                </div>
                <div class="fg">
                    <label>To</label><asp:TextBox ID="expTo" runat="server" TextMode="Date"></asp:TextBox>
                </div>
                <asp:Button ID="btnExpRun" runat="server" CssClass="btn-run" Text="View" OnClick="btnExpRun_Click" />
                <button type="button" class="btn-print" onclick="printReport()">Print</button>
                <asp:Button ID="btnExpXls" runat="server" CssClass="btn-excel" Text="Excel" OnClick="btnExpXls_Click" />
            </div>
            <asp:Repeater ID="rptExp" runat="server">
                <HeaderTemplate>
                    <table class="tbl">
                        <thead>
                            <tr>
                                <th>Item</th>
                                <th class="num">Total Qty</th>
                                <th class="num">Entries</th>
                                <th class="num">Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("ItemName") %></td>
                        <td class="num"><%# Eval("TotalQty","{0:N0}") %></td>
                        <td class="num"><%# Eval("Entries") %></td>
                        <td class="num"><%# Eval("TotalAmount","{0:N0}") %></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </tbody>
                   
                    <tfoot>
                        <tr>
                            <td colspan="3">Total Expense</td>
                            <td class="num">
                                <asp:Literal ID="litExpTotal" runat="server"></asp:Literal></td>
                        </tr>
                    </tfoot>
                    </table>
               
                </FooterTemplate>
            </asp:Repeater>
            <asp:Panel ID="pnlExpEmpty" runat="server" Visible="false">
                <div class="empty">No expenses in this range.</div>
            </asp:Panel>
        </asp:Panel>

        <!-- ============ OCCUPANCY ============ -->
        <asp:Panel ID="pnlOccupancy" runat="server" Visible="false">
            <div class="card-title">Occupancy</div>
            <div class="toolbar">
                <button type="button" class="btn-print" onclick="printReport()">Print</button>
                <asp:Button ID="btnOccXls" runat="server" CssClass="btn-excel" Text="Excel" OnClick="btnOccXls_Click" />
            </div>
            <asp:Repeater ID="rptOcc" runat="server">
                <HeaderTemplate>
                    <table class="tbl">
                        <thead>
                            <tr>
                                <th>Floor</th>
                                <th>Room</th>
                                <th class="num">Total Beds</th>
                                <th class="num">Occupied</th>
                                <th class="num">Vacant</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("FloorName") %></td>
                        <td><%# Eval("RoomNumber") %></td>
                        <td class="num"><%# Eval("TotalBeds") %></td>
                        <td class="num"><%# Eval("Occupied") %></td>
                        <td class="num"><%# Eval("Vacant") %></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </tbody>
                   
                    <tfoot>
                        <tr>
                            <td colspan="2">Total</td>
                            <td class="num">
                                <asp:Literal ID="litOccBeds" runat="server"></asp:Literal></td>
                            <td class="num">
                                <asp:Literal ID="litOccOcc" runat="server"></asp:Literal></td>
                            <td class="num">
                                <asp:Literal ID="litOccVac" runat="server"></asp:Literal></td>
                        </tr>
                    </tfoot>
                    </table>
               
                </FooterTemplate>
            </asp:Repeater>
            <asp:Panel ID="pnlOccEmpty" runat="server" Visible="false">
                <div class="empty">No rooms found.</div>
            </asp:Panel>
        </asp:Panel>

        <!-- ============ INCOME vs EXPENSE ============ -->
        <asp:Panel ID="pnlIncome" runat="server" Visible="false">
            <div class="card-title">Income vs Expense</div>
            <div class="filters">
                <div class="fg">
                    <label>Year</label><asp:DropDownList ID="ddlYear" runat="server"></asp:DropDownList>
                </div>
                <asp:Button ID="btnIncRun" runat="server" CssClass="btn-run" Text="View" OnClick="btnIncRun_Click" />
                <button type="button" class="btn-print" onclick="printReport()">Print</button>
                <asp:Button ID="btnIncXls" runat="server" CssClass="btn-excel" Text="Excel" OnClick="btnIncXls_Click" />
            </div>
            <asp:Repeater ID="rptInc" runat="server">
                <HeaderTemplate>
                    <table class="tbl">
                        <thead>
                            <tr>
                                <th>Month</th>
                                <th class="num">Income</th>
                                <th class="num">Expense</th>
                                <th class="num">Staff Salary</th>
                                <th class="num">Net</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("MonthName") %></td>
                        <td class="num"><%# Eval("Income","{0:N0}") %></td>
                        <td class="num"><%# Eval("Expense","{0:N0}") %></td>
                        <td class="num"><%# Eval("StaffSalary","{0:N0}") %></td>
                        <td class="num"><span class='<%# Convert.ToDecimal(Eval("Net"))>=0 ? "pos" : "neg" %>'><%# Eval("Net","{0:N0}") %></span></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </tbody>
                   
                    <tfoot>
                        <tr>
                            <td>Total</td>
                            <td class="num">
                                <asp:Literal ID="litIncInc" runat="server"></asp:Literal></td>
                            <td class="num">
                                <asp:Literal ID="litIncExp" runat="server"></asp:Literal></td>
                            <td class="num">
                                <asp:Literal ID="litIncSal" runat="server"></asp:Literal></td>
                            <td class="num">
                                <asp:Literal ID="litIncNet" runat="server"></asp:Literal></td>
                        </tr>
                    </tfoot>
                    </table>
               
                </FooterTemplate>
            </asp:Repeater>
        </asp:Panel>

        <!-- ============ ROOM HISTORY ============ -->
        <asp:Panel ID="pnlRoomHist" runat="server" Visible="false">
            <div class="card-title">Room History</div>
            <div class="filters">
                <div class="fg">
                    <label>From</label><asp:TextBox ID="rhFrom" runat="server" TextMode="Date"></asp:TextBox>
                </div>
                <div class="fg">
                    <label>To</label><asp:TextBox ID="rhTo" runat="server" TextMode="Date"></asp:TextBox>
                </div>
                <div class="fg">
                    <label>Floor</label>
                    <asp:DropDownList ID="rhFloor" runat="server" AutoPostBack="true" OnSelectedIndexChanged="rhFloor_Changed"></asp:DropDownList>
                </div>
                <div class="fg">
                    <label>Room</label>
                    <asp:DropDownList ID="rhRoom" runat="server"></asp:DropDownList>
                </div>
                <asp:Button ID="btnRhRun" runat="server" CssClass="btn-run" Text="Submit" OnClick="btnRhRun_Click" />
                <button type="button" class="btn-print" onclick="printReport()">Print</button>
                <asp:Button ID="btnRhXls" runat="server" CssClass="btn-excel" Text="Excel" OnClick="btnRhXls_Click" />
            </div>

            <asp:Panel ID="pnlRhResult" runat="server" Visible="false">
                <div class="card-title" style="font-size: 14px;">
                    <asp:Literal ID="litRhHead" runat="server"></asp:Literal>
                </div>
                <asp:Repeater ID="rptBeds" runat="server" OnItemDataBound="rptBeds_ItemDataBound">
                    <ItemTemplate>
                        <div style="margin: 16px 0 6px; font-weight: 700; color: var(--primary); font-size: 15px;">
                            Bed <%# Eval("BedNo") %>
                        </div>
                        <asp:Repeater ID="rptResidents" runat="server">
                            <HeaderTemplate>
                                <table class="tbl">
                                    <thead>
                                        <tr>
                                            <th>Resident</th>
                                            <th>Phone</th>
                                            <th>Joined</th>
                                            <th>Exit</th>
                                            <th>Status</th>
                                            <th>Type</th>
                                            <th class="num">Paid (in period)</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td><%# Eval("PersonName") %></td>
                                    <td><%# Eval("Phone") %></td>
                                    <td><%# Eval("DateOfJoining","{0:dd/MM/yyyy}") %></td>
                                    <td><%# Eval("ExitDate") == DBNull.Value ? "&mdash;" : Convert.ToDateTime(Eval("ExitDate")).ToString("dd/MM/yyyy") %></td>
                                    <td><%# Eval("Status") %></td>
                                    <td><%# Eval("RentType") %></td>
                                    <td class="num"><%# Eval("PaidInRange","{0:N0}") %></td>
                                </tr>
                                <tr>
                                    <td colspan="7" style="padding: 0 12px 12px 24px; border: none;">
                                        <asp:Repeater ID="rptPays" runat="server" DataSource='<%# GetPayments(Eval("AllocationId")) %>'>
                                            <HeaderTemplate>
                                                <table class="tbl" style="margin-top: 4px;">
                                                    <thead>
                                                        <tr>
                                                            <th>Payment Date</th>
                                                            <th>Receipt No</th>
                                                            <th>Mode</th>
                                                            <th>Received By</th>
                                                            <th class="num">Amount</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <tr>
                                                    <td><%# Eval("PaymentDate","{0:dd/MM/yyyy}") %></td>
                                                    <td class="rcpt"><%# Eval("ReceiptNo") %></td>
                                                    <td><%# Eval("PaymentMode") %></td>
                                                    <td><%# Eval("ReceivedBy") %></td>
                                                    <td class="num"><%# Eval("AmountPaid","{0:N0}") %></td>
                                                </tr>
                                            </ItemTemplate>
                                            <FooterTemplate></tbody></table></FooterTemplate>
                                        </asp:Repeater>
                                        <div class='<%# GetPayments(Eval("AllocationId")).Count == 0 ? "" : "hide" %>' style="color: var(--text-muted); font-size: 13px; padding: 6px 0;">
                                            <%# GetPayments(Eval("AllocationId")).Count == 0 ? "No payments in this period." : "" %>
                                        </div>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate></tbody></table></FooterTemplate>
                        </asp:Repeater>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>
            <asp:Panel ID="pnlRhEmpty" runat="server" Visible="false">
                <div class="empty">No residents in this room for the selected period.</div>
            </asp:Panel>
        </asp:Panel>

    </div>

    <script>
        function printReport() { window.print(); }
    </script>

</asp:Content>
