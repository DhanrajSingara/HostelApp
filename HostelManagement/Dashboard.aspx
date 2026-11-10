<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="HostelManagement.Dashboard" %>

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

        /* ---- Stat cards ---- */
        .stat-grid {
            display: grid;
            grid-template-columns: repeat(6, 1fr);
            gap: 18px;
            margin-bottom: 24px;
        }

        @media (max-width: 1100px) {
            .stat-grid { grid-template-columns: repeat(3, 1fr); }
        }

        @media (max-width: 700px) {
            .stat-grid { grid-template-columns: repeat(2, 1fr); }
        }

        @media (max-width: 480px) {
            .stat-grid { grid-template-columns: 1fr; }
        }

        .stat-card {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 18px 16px;
            display: flex;
            align-items: center;
            gap: 12px;
            box-shadow: var(--shadow);
            transition: transform .18s ease, box-shadow .18s ease;
        }

            .stat-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 10px 24px rgba(0,0,0,.10);
            }

        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            flex-shrink: 0;
            display: flex;
            align-items: center;
            justify-content: center;
        }

            .stat-icon svg {
                width: 24px;
                height: 24px;
            }

        .stat-info {
            display: flex;
            flex-direction: column;
        }

        .stat-label {
            font-size: 13px;
            color: var(--text-muted);
            font-weight: 500;
        }

        .stat-value {
            font-size: 26px;
            font-weight: 700;
            color: var(--text);
            line-height: 1.2;
        }

        /* ---- Panels ---- */
        .panel-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 18px;
        }

        @media (max-width:900px) {
            .panel-grid {
                grid-template-columns: 1fr;
            }
        }

        .panel {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 20px;
            box-shadow: var(--shadow);
        }

            .panel h3 {
                font-size: 15px;
                font-weight: 600;
                color: var(--text);
                margin-bottom: 14px;
            }

        .empty-state {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            padding: 40px 16px;
            color: var(--text-muted);
        }

            .empty-state svg {
                width: 40px;
                height: 40px;
                margin-bottom: 12px;
                opacity: .55;
            }

            .empty-state p {
                font-size: 13px;
            }

        /* ---- Occupancy bar ---- */
        .occ-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            margin-bottom: 12px;
        }

        .occ-pct {
            font-size: 34px;
            font-weight: 800;
            color: var(--primary);
            line-height: 1;
        }

        .occ-sub {
            font-size: 13px;
            color: var(--text-muted);
        }

        .bar {
            height: 16px;
            background: var(--hover);
            border-radius: 9px;
            overflow: hidden;
        }

        .bar-fill {
            height: 100%;
            background: var(--primary-grad);
            border-radius: 9px;
            width: 0;
            transition: width .6s ease;
        }

        .occ-legend {
            display: flex;
            gap: 20px;
            margin-top: 14px;
            font-size: 13px;
            color: var(--text-muted);
        }

            .occ-legend span {
                display: flex;
                align-items: center;
                gap: 7px;
            }

            .occ-legend .dot {
                width: 11px;
                height: 11px;
                border-radius: 50%;
            }

        .dot.occ {
            background: #7c3aed;
        }

        .dot.vac {
            background: var(--hover);
            border: 1px solid var(--border);
        }

        /* ---- Pending payments list ---- */
        .panel-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 14px;
        }

            .panel-head h3 {
                margin-bottom: 0;
            }

        .show-all {
            font-size: 13px;
            font-weight: 600;
            color: var(--primary);
            text-decoration: none;
        }

            .show-all:hover {
                text-decoration: underline;
            }

        .pend-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 11px 0;
            border-bottom: 1px solid var(--border);
            font-size: 13px;
        }

            .pend-item:last-child {
                border-bottom: none;
            }

            .pend-item .who {
                color: var(--text);
                font-weight: 600;
            }

            .pend-item .sub {
                color: var(--text-muted);
                font-size: 12px;
                margin-top: 2px;
            }

        .pend-right {
            text-align: right;
        }

        .pend-item .amt {
            color: #dc2626;
            font-weight: 700;
        }

        .pend-item .overdue {
            font-size: 11px;
            color: var(--text-muted);
            margin-top: 2px;
        }

        .pay-link {
            display: inline-block;
            margin-top: 5px;
            font-size: 11px;
            font-weight: 600;
            color: #fff;
            background: var(--primary-grad);
            padding: 3px 10px;
            border-radius: 6px;
            text-decoration: none;
        }

            .pay-link:hover {
                opacity: .9;
            }

        /* ---- Income vs Expense chart ---- */
        .chart-wrap {
            margin-top: 6px;
        }

        .chart {
            display: flex;
            align-items: flex-end;
            gap: 18px;
            height: 200px;
            padding: 10px 4px 0;
            border-bottom: 2px solid var(--border);
        }

        .cbar-group {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
            height: 100%;
            justify-content: flex-end;
        }

        .cbars {
            display: flex;
            align-items: flex-end;
            gap: 6px;
            height: 100%;
            width: 100%;
            justify-content: center;
        }

        .cbar {
            width: 26px;
            border-radius: 6px 6px 0 0;
            transition: height .5s ease;
            position: relative;
        }

            .cbar.income {
                background: linear-gradient(180deg,#22c55e,#16a34a);
            }

            .cbar.expense {
                background: linear-gradient(180deg,#f87171,#dc2626);
            }

            .cbar span {
                position: absolute;
                top: -18px;
                left: 50%;
                transform: translateX(-50%);
                font-size: 10px;
                font-weight: 600;
                color: var(--text-muted);
                white-space: nowrap;
            }

        .cbar-label {
            font-size: 11px;
            color: var(--text-muted);
            font-weight: 500;
        }

        .chart-legend {
            display: flex;
            gap: 20px;
            margin-top: 14px;
            font-size: 13px;
            color: var(--text-muted);
        }

            .chart-legend span {
                display: flex;
                align-items: center;
                gap: 7px;
            }

            .chart-legend .dot {
                width: 11px;
                height: 11px;
                border-radius: 3px;
            }

        .dot.inc {
            background: #16a34a;
        }

        .dot.exp {
            background: #dc2626;
        }
    </style>
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-head">
        <h2>Dashboard Overview</h2>
        <p>
            Welcome back,
            <asp:Literal ID="litWelcome" runat="server" Text="Admin"></asp:Literal>.
           Here's a snapshot of your hostel branch.
        </p>
    </div>

    <!-- ===== Stat cards ===== -->
    <div class="stat-grid">

        <div class="stat-card">
            <div class="stat-icon" style="background: rgba(124,58,237,.12); color: #7c3aed;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />
                    <polyline points="9 22 9 12 15 12 15 22" />
                </svg>
            </div>
            <div class="stat-info">
                <span class="stat-label">Total Rooms</span>
                <span class="stat-value">
                    <asp:Literal ID="litTotalRooms" runat="server" Text="0"></asp:Literal></span>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background: rgba(55,138,221,.12); color: #378add;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M3 18v-6a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v6" />
                    <line x1="3" y1="14" x2="21" y2="14" />
                    <path d="M7 10V8a1 1 0 0 1 1-1h3v3" />
                </svg>
            </div>
            <div class="stat-info">
                <span class="stat-label">Total Beds</span>
                <span class="stat-value">
                    <asp:Literal ID="litTotalBeds" runat="server" Text="0"></asp:Literal></span>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background: rgba(216,90,48,.12); color: #d85a30;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" />
                    <circle cx="9" cy="7" r="4" />
                    <polyline points="17 11 19 13 23 9" />
                </svg>
            </div>
            <div class="stat-info">
                <span class="stat-label">Occupied Beds</span>
                <span class="stat-value">
                    <asp:Literal ID="litOccupied" runat="server" Text="0"></asp:Literal></span>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background: rgba(29,158,117,.12); color: #1d9e75;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
                    <polyline points="22 4 12 14.01 9 11.01" />
                </svg>
            </div>
            <div class="stat-info">
                <span class="stat-label">Available Beds</span>
                <span class="stat-value">
                    <asp:Literal ID="litAvailable" runat="server" Text="0"></asp:Literal></span>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background: rgba(15,110,86,.12); color: #0f6e56;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                    <circle cx="9" cy="7" r="4" />
                    <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                    <path d="M16 3.13a4 4 0 0 1 0 7.75" />
                </svg>
            </div>
            <div class="stat-info">
                <span class="stat-label">Total Persons</span>
                <span class="stat-value">
                    <asp:Literal ID="litStudents" runat="server" Text="0"></asp:Literal></span>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background: rgba(226,75,74,.12); color: #e24b4a;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="2" y="5" width="20" height="14" rx="2" />
                    <line x1="2" y1="10" x2="22" y2="10" />
                </svg>
            </div>
            <div class="stat-info">
                <span class="stat-label">Pending Bills</span>
                <span class="stat-value">
                    <asp:Literal ID="litPendingBills" runat="server" Text="0"></asp:Literal></span>
            </div>
        </div>

    </div>

    <!-- ===== Income vs Expense chart ===== -->
    <div class="panel" style="margin-bottom: 18px;">
        <h3>Income vs Expense (last 6 months)</h3>
        <div class="chart-wrap">
            <asp:Repeater ID="rptChart" runat="server">
                <headertemplate>
                    <div class="chart">
                </headertemplate>
                <itemtemplate>
                    <div class="cbar-group">
                        <div class="cbars">
                            <div class="cbar income" style='height: <%# BarHeight(Eval("Income")) %>%'>
                                <span>&#8377;<%# Eval("Income","{0:N0}") %></span>
                            </div>
                            <div class="cbar expense" style='height: <%# BarHeight(Eval("Expense")) %>%'>
                                <span>&#8377;<%# Eval("Expense","{0:N0}") %></span>
                            </div>
                        </div>
                        <div class="cbar-label"><%# Eval("Label") %></div>
                    </div>
                </itemtemplate>
                <footertemplate>
        </div>
        </FooterTemplate>
            </asp:Repeater>
           
        <div class="chart-legend">
            <span><i class="dot inc"></i>Income (payments received)</span>
            <span><i class="dot exp"></i>Expense</span>
        </div>
    </div>
    </div>

   

    <!-- ===== Panels ===== -->
    <div class="panel-grid">
        <div class="panel">
            <h3>Occupancy Overview</h3>
            <div class="occ-top">
                <div class="occ-pct">
                    <asp:Literal ID="litOccPct" runat="server" Text="0">0</asp:Literal>%</div>
                <div class="occ-sub">
                    <asp:Literal ID="litOccSub" runat="server"></asp:Literal></div>
            </div>
            <div class="bar">
                <div id="occFill" runat="server" class="bar-fill"></div>
            </div>
            <div class="occ-legend">
                <span><i class="dot occ"></i>Occupied</span>
                <span><i class="dot vac"></i>Available</span>
            </div>
        </div>

        <div class="panel">
            <div class="panel-head">
                <h3>Pending Payments</h3>
                <asp:LinkButton ID="btnShowAll" runat="server" CssClass="show-all"
                    OnClick="btnShowAll_Click">
                    Show All</asp:LinkButton>
            </div>
            <asp:Repeater ID="rptPending" runat="server">
                <itemtemplate>
                    <div class="pend-item">
                        <div>
                            <div class="who"><%# Eval("PersonName") %></div>
                            <div class="sub">
                                <%# Eval("RoomNumber") %> / Bed <%# Eval("BedNo") %>
                                &middot; due <%# Eval("PeriodTo","{0:dd MMM}") %>
                            </div>
                            <a class="pay-link" href='<%# "Receipts.aspx?allocationId=" + Eval("AllocationId") %>'>Make Payment</a>
                        </div>
                        <div class="pend-right">
                            <div class="amt">&#8377; <%# Eval("Pending","{0:N0}") %></div>
                            <div class="overdue"><%# OverdueText(Eval("DaysOverdue")) %></div>
                        </div>
                    </div>
                </itemtemplate>
            </asp:Repeater>
            <asp:Panel ID="pnlPendEmpty" runat="server" Visible="false">
                <div class="empty-state">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
                        <polyline points="22 4 12 14.01 9 11.01" />
                    </svg>
                    <p>No pending payments. All cleared!</p>
                </div>
            </asp:Panel>
        </div>
    </div>

</asp:Content>
