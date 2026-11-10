<%@ Page Title="Receipts" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Receipts.aspx.cs" Inherits="HostelManagement.Receipts" %>

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
            padding: 22px;
            box-shadow: var(--shadow);
            margin-bottom: 22px;
        }

        .card-title {
            font-size: 15px;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 16px;
        }

        .selectors {
            display: flex;
            gap: 18px;
            flex-wrap: wrap;
            align-items: flex-end;
        }

        .field {
            display: flex;
            flex-direction: column;
            min-width: 230px;
        }

            .field label {
                font-size: 13px;
                font-weight: 600;
                color: var(--text);
                margin-bottom: 6px;
            }

            .field select {
                padding: 11px 13px;
                border: 1.5px solid var(--border);
                border-radius: 9px;
                font-size: 14px;
                color: var(--text);
                background: var(--bg);
                outline: none;
                font-family: inherit;
            }

                .field select:disabled {
                    opacity: .55;
                    cursor: not-allowed;
                }

        .legend {
            display: flex;
            gap: 18px;
            margin-bottom: 16px;
            font-size: 13px;
            color: var(--text-muted);
        }

            .legend span {
                display: flex;
                align-items: center;
                gap: 7px;
            }

        .dot {
            width: 12px;
            height: 12px;
            border-radius: 50%;
        }

            .dot.red {
                background: #dc2626;
            }

            .dot.green {
                background: #16a34a;
            }

        .bed-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill,minmax(150px,1fr));
            gap: 16px;
        }

        .bed {
            display: block;
            text-decoration: none;
            border: 1.5px solid var(--border);
            border-radius: 14px;
            padding: 18px 14px;
            text-align: center;
            cursor: pointer;
            transition: transform .15s ease, box-shadow .15s ease;
        }

            .bed:hover {
                transform: translateY(-3px);
                box-shadow: 0 8px 20px rgba(0,0,0,.12);
            }

        .bed-icon {
            width: 44px;
            height: 44px;
            margin: 0 auto 9px;
            border-radius: 11px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

            .bed-icon svg {
                width: 23px;
                height: 23px;
            }

        .bed-no {
            font-size: 14px;
            font-weight: 700;
            color: var(--text);
            display: block;
        }

        .bed-name {
            font-size: 12px;
            color: var(--text-muted);
            margin-top: 3px;
            display: block;
            min-height: 15px;
        }

        .bed-badge {
            display: inline-block;
            margin-top: 9px;
            padding: 3px 11px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
        }

        .bed.occupied {
            border-color: rgba(220,38,38,.5);
            background: rgba(220,38,38,.07);
        }

            .bed.occupied .bed-icon {
                background: rgba(220,38,38,.15);
                color: #dc2626;
            }

            .bed.occupied .bed-badge {
                background: rgba(220,38,38,.15);
                color: #dc2626;
            }

        .bed.available {
            border-color: rgba(22,163,74,.5);
            background: rgba(22,163,74,.07);
        }

            .bed.available .bed-icon {
                background: rgba(22,163,74,.15);
                color: #16a34a;
            }

            .bed.available .bed-badge {
                background: rgba(22,163,74,.15);
                color: #16a34a;
            }

        .placeholder {
            text-align: center;
            color: var(--text-muted);
            padding: 30px;
            font-size: 14px;
        }

        .bill-head {
            display: grid;
            grid-template-columns: repeat(auto-fit,minmax(150px,1fr));
            gap: 14px;
            margin-bottom: 18px;
        }

        .bbox {
            background: var(--hover);
            border-radius: 11px;
            padding: 13px 15px;
        }

            .bbox .lbl {
                font-size: 12px;
                color: var(--text-muted);
                font-weight: 600;
            }

            .bbox .val {
                font-size: 16px;
                font-weight: 700;
                color: var(--text);
                margin-top: 4px;
            }

            .bbox.due .val {
                color: var(--primary);
            }

        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
        }

            .status-badge.pending {
                background: rgba(216,90,48,.15);
                color: #d85a30;
            }

            .status-badge.cleared {
                background: rgba(22,163,74,.15);
                color: #16a34a;
            }

        .tbl {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 6px;
        }

            .tbl th {
                text-align: left;
                font-size: 12px;
                text-transform: uppercase;
                letter-spacing: .4px;
                color: var(--text-muted);
                font-weight: 600;
                padding: 11px 13px;
                border-bottom: 1px solid var(--border);
            }

            .tbl td {
                padding: 12px 13px;
                font-size: 14px;
                color: var(--text);
                border-bottom: 1px solid var(--border);
            }

        .rcpt-no {
            font-weight: 600;
            color: var(--primary);
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

        .act-pdf {
            color: #dc2626;
        }

        .form-row {
            display: grid;
            grid-template-columns: repeat(auto-fit,minmax(170px,1fr));
            gap: 14px;
            align-items: end;
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
                font-family: inherit;
            }

        .btn-primary {
            padding: 11px 24px;
            border: none;
            border-radius: 10px;
            background: var(--primary-grad);
            color: #fff;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            height: 42px;
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
            height: 42px;
        }

        .btn-next {
            padding: 11px 24px;
            border: none;
            border-radius: 10px;
            background: #16a34a;
            color: #fff;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
        }

        .msg {
            font-size: 13px;
            font-weight: 600;
            margin-left: 12px;
        }

            .msg.success {
                color: #16a34a;
            }

            .msg.error {
                color: #dc2626;
            }

        .cleared-note {
            font-size: 14px;
            color: #16a34a;
            font-weight: 600;
            margin-bottom: 14px;
        }
    </style>
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-head">
        <h2>Receipts</h2>
        <p>Select floor, room and bed, then record the monthly payment.</p>
    </div>

    <asp:HiddenField ID="hfAllocationId" runat="server" />
    <asp:HiddenField ID="hfBillId" runat="server" />

    <!-- Floor + Room -->
    <div class="card">
        <div class="selectors">
            <div class="field">
                <label>Floor</label>
                <asp:DropDownList ID="ddlFloor" runat="server" AutoPostBack="true"
                    OnSelectedIndexChanged="ddlFloor_Changed">
                </asp:DropDownList>
            </div>
            <div class="field">
                <label>Room</label>
                <asp:DropDownList ID="ddlRoom" runat="server" AutoPostBack="true"
                    OnSelectedIndexChanged="ddlRoom_Changed" Enabled="false">
                </asp:DropDownList>
            </div>
        </div>
    </div>

    <!-- Beds -->
    <div class="card">
        <div class="card-title">Beds</div>
        <div class="legend">
            <span><i class="dot red"></i>Occupied (click to take payment)</span>
            <span><i class="dot green"></i>Vacant</span>
        </div>
        <asp:Panel ID="pnlBedPlaceholder" runat="server">
            <div class="placeholder">Select a floor and room to view beds.</div>
        </asp:Panel>
        <asp:Repeater ID="rptBeds" runat="server" OnItemCommand="rptBeds_ItemCommand">
            <HeaderTemplate>
                <div class="bed-grid">
            </HeaderTemplate>
            <ItemTemplate>
                <asp:LinkButton runat="server" CommandName="SelectBed"
                    CommandArgument='<%# Eval("AllocationId") %>'
                    CssClass='<%# Convert.ToInt32(Eval("Occupied"))==1 ? "bed occupied" : "bed available" %>'>
                    <span class="bed-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 18v-6a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v6"/><line x1="3" y1="14" x2="21" y2="14"/><path d="M7 10V8a1 1 0 0 1 1-1h3v3"/></svg></span>
                    <span class="bed-no">Bed <%# Eval("BedNo") %></span>
                    <span class="bed-name"><%# Convert.ToInt32(Eval("Occupied"))==1 ? Eval("PersonName") : "&mdash;" %></span>
                    <span class="bed-badge"><%# Convert.ToInt32(Eval("Occupied"))==1 ? "Occupied" : "Vacant" %></span>
                </asp:LinkButton>
            </ItemTemplate>
            <FooterTemplate></div></FooterTemplate>
        </asp:Repeater>
    </div>

    <!-- Bill + installments -->
    <asp:Panel ID="pnlBill" runat="server" Visible="false">
        <div class="card">
            <div class="card-title">
                Current Month &nbsp;<asp:Literal ID="litStatus" runat="server"></asp:Literal>
            </div>

            <div class="bill-head">
                <div class="bbox">
                    <div class="lbl">Resident</div>
                    <div class="val" style="font-size: 14px;">
                        <asp:Literal ID="litResident" runat="server"></asp:Literal>
                    </div>
                </div>
                <div class="bbox">
                    <div class="lbl">Room / Bed</div>
                    <div class="val" style="font-size: 14px;">
                        <asp:Literal ID="litRoomBed" runat="server"></asp:Literal>
                    </div>
                </div>
                <div class="bbox">
                    <div class="lbl">Period</div>
                    <div class="val" style="font-size: 13px;">
                        <asp:Literal ID="litPeriod" runat="server"></asp:Literal>
                    </div>
                </div>
                <div class="bbox">
                    <div class="lbl">Actual Amount</div>
                    <div class="val">
                        <asp:Literal ID="litActual" runat="server"></asp:Literal>
                    </div>
                </div>
                <div class="bbox due">
                    <div class="lbl">Pending</div>
                    <div class="val">
                        <asp:Literal ID="litPending" runat="server"></asp:Literal>
                    </div>
                </div>
            </div>

            <table class="tbl">
                <thead>
                    <tr>
                        <th>S.No</th>
                        <th>Receipt No</th>
                        <th>Payment Date</th>
                        <th>Actual</th>
                        <th>Paid</th>
                        <th>Pending</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptLines" runat="server" OnItemCommand="rptLines_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td><%# Eval("Sno") %></td>
                                <td class="rcpt-no"><%# Eval("ReceiptNo") %></td>
                                <td><%# Eval("PaymentDate","{0:dd/MM/yyyy}") %></td>
                                <td><%# Eval("ActualAmount","{0:N0}") %></td>
                                <td><%# Eval("AmountPaid","{0:N0}") %></td>
                                <td><%# Eval("PendingAmount","{0:N0}") %></td>
                                <td>
                                    <asp:LinkButton runat="server" CssClass="act act-edit" CommandName="EditLine"
                                        CommandArgument='<%# Eval("LineId") %>'>Edit</asp:LinkButton>
                                    <a class="act act-pdf" target="_blank" href='<%# "ReceiptPdf.aspx?lineId=" + Eval("LineId") %>'>PDF</a>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>

        <!-- Edit a payment -->
        <asp:Panel ID="pnlEditLine" runat="server" CssClass="card" Visible="false">
            <div class="card-title">Edit Payment</div>
            <asp:HiddenField ID="hfLineId" runat="server" />
            <div class="form-row">
                <div class="form-group">
                    <label>Payment Date</label><asp:TextBox ID="txtEditDate" runat="server" TextMode="Date"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>Amount Paid (&#8377;)</label><asp:TextBox ID="txtEditAmount" runat="server" TextMode="Number"></asp:TextBox>
                </div>
                <div class="form-group">
                    <asp:Button ID="btnUpdateLine" runat="server" CssClass="btn-primary" Text="Update" OnClick="btnUpdateLine_Click" />
                </div>
                <div class="form-group">
                    <asp:Button ID="btnCancelEdit" runat="server" CssClass="btn-cancel" Text="Cancel" OnClick="btnCancelEdit_Click" CausesValidation="false" />
                </div>
            </div>
            <asp:Label ID="lblEditMsg" runat="server" CssClass="msg"></asp:Label>
        </asp:Panel>

        <!-- Add installment -->
        <asp:Panel ID="pnlAddPayment" runat="server" CssClass="card">
            <div class="card-title">Add Payment</div>
            <div class="form-row">
                <div class="form-group">
                    <label>Payment Date</label><asp:TextBox ID="txtPayDate" runat="server" TextMode="Date"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>Amount Paid (&#8377;)</label><asp:TextBox ID="txtAmount" runat="server" TextMode="Number"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>Mode</label>
                    <asp:DropDownList ID="ddlMode" runat="server">
                        <asp:ListItem>Cash</asp:ListItem>
                        <asp:ListItem>UPI</asp:ListItem>
                        <asp:ListItem>Card</asp:ListItem>
                        <asp:ListItem>NetBanking</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="form-group">
                    <label>Remarks</label><asp:TextBox ID="txtRemarks" runat="server"></asp:TextBox>
                </div>
                <div class="form-group">
                   <asp:Button ID="btnAddPayment" runat="server" CssClass="btn-primary"
    Text="&#8377; Add Payment" OnClick="btnAddPayment_Click"
    style="background:#7c3aed;color:#fff;border:none;" />
                </div>
            </div>
            <asp:Label ID="lblBillMsg" runat="server" CssClass="msg"></asp:Label>
        </asp:Panel>

        <!-- Generate next month -->
        <asp:Panel ID="pnlNextMonth" runat="server" CssClass="card" Visible="false">
            <div class="cleared-note">This month is fully paid (Cleared).</div>
            <asp:Button ID="btnNextMonth" runat="server" CssClass="btn-next" Text="Generate Next Month" OnClick="btnNextMonth_Click" />
            <asp:Label ID="lblNextMsg" runat="server" CssClass="msg"></asp:Label>
        </asp:Panel>

        <asp:Panel ID="pnlClearedWait" runat="server" CssClass="card" Visible="false">
            <div class="cleared-note">
                <asp:Label ID="lblClearedWait" runat="server"></asp:Label>
            </div>
        </asp:Panel>

        <!-- History: any past period PDF -->
        <div class="card">
            <div class="card-title">Payment History (all periods)</div>
            <table class="tbl">
                <thead>
                    <tr>
                        <th>Receipt No</th>
                        <th>Period</th>
                        <th>Date</th>
                        <th>Paid</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptHistory" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td class="rcpt-no"><%# Eval("ReceiptNo") %></td>
                                <td><%# Eval("PeriodFrom","{0:dd MMM}") %> &ndash; <%# Eval("PeriodTo","{0:dd MMM yyyy}") %></td>
                                <td><%# Eval("PaymentDate","{0:dd/MM/yyyy}") %></td>
                                <td><%# Eval("AmountPaid","{0:N0}") %></td>
                                <td><a class="act act-pdf" target="_blank" href='<%# "ReceiptPdf.aspx?lineId=" + Eval("LineId") %>'>PDF</a></td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate></FooterTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>

</asp:Content>
