<%@ Page Title="Guidelines" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Guidelines.aspx.cs" Inherits="HostelManagement.Guidelines" %>

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

        .g-card {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 22px 24px;
            box-shadow: var(--shadow);
            margin-bottom: 18px;
        }

        .g-head {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-bottom: 14px;
        }

        .g-icon {
            width: 44px;
            height: 44px;
            border-radius: 11px;
            flex-shrink: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            background: var(--hover);
            color: var(--primary);
        }

            .g-icon svg {
                width: 22px;
                height: 22px;
            }

        .g-title {
            font-size: 16px;
            font-weight: 700;
            color: var(--text);
        }

            .g-title small {
                display: block;
                font-size: 12px;
                font-weight: 500;
                color: var(--text-muted);
                margin-top: 2px;
            }

        .g-steps {
            list-style: none;
            counter-reset: step;
            padding: 0;
            margin: 0;
        }

            .g-steps li {
                position: relative;
                padding: 8px 0 8px 40px;
                font-size: 14px;
                color: var(--text);
                line-height: 1.55;
                border-bottom: 1px dashed var(--border);
            }

                .g-steps li:last-child {
                    border-bottom: none;
                }

                .g-steps li::before {
                    counter-increment: step;
                    content: counter(step);
                    position: absolute;
                    left: 0;
                    top: 8px;
                    width: 26px;
                    height: 26px;
                    border-radius: 50%;
                    background: var(--primary-grad);
                    color: #fff;
                    font-size: 12px;
                    font-weight: 700;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                }

            .g-steps b {
                color: var(--text);
                font-weight: 700;
            }

        .tag {
            display: inline-block;
            padding: 2px 9px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            background: rgba(124,58,237,.12);
            color: var(--primary);
            margin-left: 4px;
        }

            .tag.admin {
                background: rgba(226,75,74,.14);
                color: #e24b4a;
            }

        .note {
            display: flex;
            gap: 12px;
            align-items: flex-start;
            background: var(--hover);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 14px 16px;
            margin-bottom: 18px;
        }

            .note svg {
                width: 20px;
                height: 20px;
                color: var(--primary);
                flex-shrink: 0;
                margin-top: 1px;
            }

            .note p {
                font-size: 13px;
                color: var(--text);
                line-height: 1.5;
            }

        .flow {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            align-items: center;
            margin-top: 6px;
        }

            .flow .chip {
                background: var(--hover);
                border: 1px solid var(--border);
                border-radius: 8px;
                padding: 6px 12px;
                font-size: 12.5px;
                font-weight: 600;
                color: var(--text);
            }

            .flow .arr {
                color: var(--text-muted);
                font-weight: 700;
            }
    </style>
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-head">
        <h2>Guidelines</h2>
        <p>A quick guide to using the Hostel Management System.</p>
    </div>

    <div class="note">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10" />
            <line x1="12" y1="16" x2="12" y2="12" />
            <line x1="12" y1="8" x2="12.01" y2="8" />
        </svg>
        <p>Steps marked <span class="tag admin">Admin</span> are available only to administrators. After signing in you first pick a branch &mdash; everything you see and enter belongs to that branch. Each account can be signed in on <b>one device at a time</b>; logging in elsewhere signs the earlier device out.</p>
    </div>

    <!-- Typical flow -->
    <div class="g-card">
        <div class="g-head">
            <div class="g-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="22 12 18 12 15 21 9 3 6 12 2 12" />
                </svg>
            </div>
            <div class="g-title">The usual daily flow<small>How the modules connect</small></div>
        </div>
        <div class="flow">
            <span class="chip">Rooms</span><span class="arr">&rarr;</span>
            <span class="chip">Beds Allocation</span><span class="arr">&rarr;</span>
            <span class="chip">Receipts</span><span class="arr">&rarr;</span>
            <span class="chip">Expenses</span><span class="arr">&rarr;</span>
            <span class="chip">Staff</span><span class="arr">&rarr;</span>
            <span class="chip">Reports</span>
        </div>
    </div>

    <!-- First-time setup -->
    <div class="g-card">
        <div class="g-head">
            <div class="g-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="3" />
                    <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" />
                </svg>
            </div>
            <div class="g-title">First-time setup <span class="tag admin">Admin</span><small>Do these once, under Settings</small></div>
        </div>
        <ol class="g-steps">
            <li>Open <b>Settings &rarr; Branches</b> and add each hostel branch. Set its <b>Receipt Prefix</b> (e.g. AM) &mdash; receipt numbers and staff Emp IDs use it.</li>
            <li>Go to <b>Settings &rarr; Floors</b>, pick a branch, and add its floors (just the <b>Floor Name</b> &mdash; the Floor ID is assigned automatically).</li>
            <li>Under <b>Settings &rarr; Expense Items</b>, add the items you buy daily (milk, gas, vegetables&hellip;) and each item's <b>Supplier</b>. These fill the Expenses dropdown and auto-fill the supplier.</li>
            <li>Under <b>Settings &rarr; Designations</b>, add the staff roles you use (Warden, Cook, Security&hellip;). These fill the Staff designation dropdown.</li>
            <li>Open <b>Hostel Info</b> and fill in the branch profile (name, address, warden, contact) &mdash; this appears on printed receipts.</li>
            <li>Add the rooms in <b>Rooms</b> (room number, floor, number of beds, amount per bed).</li>
        </ol>
    </div>

    <!-- Rooms -->
    <div class="g-card">
        <div class="g-head">
            <div class="g-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />
                    <polyline points="9 22 9 12 15 12 15 22" />
                </svg>
            </div>
            <div class="g-title">Rooms<small>Set up rooms and their rent</small></div>
        </div>
        <ol class="g-steps">
            <li>Click <b>Add Room</b>, choose the floor, enter the room number and number of beds.</li>
            <li>Enter the <b>Amount</b> (rent) per bed &mdash; the monthly rent is calculated automatically.</li>
            <li>Use <b>Edit</b> to change a room or <b>Delete</b> to remove one that has no residents.</li>
        </ol>
    </div>

    <!-- Beds Allocation -->
    <div class="g-card">
        <div class="g-head">
            <div class="g-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M3 18v-6a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v6" />
                    <line x1="3" y1="14" x2="21" y2="14" />
                    <path d="M7 10V8a1 1 0 0 1 1-1h3v3" />
                </svg>
            </div>
            <div class="g-title">Beds Allocation<small>Move residents in and out</small></div>
        </div>
        <ol class="g-steps">
            <li>Pick a <b>Floor</b> and <b>Room</b>. Beds show <b>green</b> (vacant) or <b>red</b> (occupied).</li>
            <li>Click a <b>green</b> bed to allocate: enter the person's name, Aadhar, phone, gender, profession and date of joining.</li>
            <li>Choose the <b>Rent Type</b>. <b>Monthly</b> uses the room's rent. <b>Daily</b> lets you enter number of days and amount per day &mdash; the total is worked out and the stay is one-time (no monthly renewal).</li>
            <li>Optionally enter a <b>Pay Now</b> amount &mdash; a receipt number is generated at once and the receipt PDF opens for you to print or download.</li>
            <li>Click a <b>red</b> bed to view that resident's details.</li>
            <li>To move someone out, set the <b>Exit Date</b> and remarks. Tick <b>Admission fee refunded</b> if you returned the deposit, then click <b>Exit (Vacate)</b> &mdash; the bed turns green again.</li>
            <li>To correct a resident's details on an occupied bed, use <b>Edit Details</b>. <span class="tag admin">Admin</span></li>
        </ol>
    </div>

    <!-- Receipts -->
    <div class="g-card">
        <div class="g-head">
            <div class="g-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                    <polyline points="14 2 14 8 20 8" />
                    <line x1="16" y1="13" x2="8" y2="13" />
                    <line x1="16" y1="17" x2="8" y2="17" />
                </svg>
            </div>
            <div class="g-title">Receipts<small>Collect rent and print receipts</small></div>
        </div>
        <ol class="g-steps">
            <li>Choose the floor and room, then click the <b>red bed</b> of the resident who is paying.</li>
            <li>The current month's bill appears. In <b>Add Payment</b>, enter the amount and date &mdash; you can take part payments; the pending balance updates each time.</li>
            <li>Each payment gets its own receipt number (e.g. <b>AM/2026/00001</b>). Click <b>PDF</b> on a row to print or download that receipt. A payment taken at allocation (Pay Now) already appears here with its receipt.</li>
            <li>When the month is fully paid it turns <b>Cleared</b>. The <b>Generate Next Month</b> button appears only after the current period has ended (daily stays are one-time and are not renewed).</li>
            <li>Use <b>Payment History</b> to reprint a receipt for any earlier month. Editing a payment amount is <span class="tag admin">Admin</span>.</li>
        </ol>
    </div>

    <!-- Expenses -->
    <div class="g-card">
        <div class="g-head">
            <div class="g-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M21 12V7H5a2 2 0 0 1 0-4h14v4" />
                    <path d="M3 5v14a2 2 0 0 0 2 2h16v-5" />
                    <path d="M18 12a2 2 0 0 0 0 4h4v-4z" />
                </svg>
            </div>
            <div class="g-title">Expenses<small>Record daily spending</small></div>
        </div>
        <ol class="g-steps">
            <li>Pick the <b>Date</b> at the top (today by default).</li>
            <li>For each row, choose the <b>Item</b> from the dropdown (type to search). The <b>Supplier</b> fills in automatically from the item master &mdash; you can change it if needed. Supplier is required.</li>
            <li>Enter <b>Quantity</b> and <b>Price</b> &mdash; the Amount and Total are worked out for you.</li>
            <li>Use <b>+ Add New Row</b> for more items, then click <b>Save</b>.</li>
            <li>A day that already has expenses can only be changed by an admin. <span class="tag admin">Admin</span></li>
        </ol>
    </div>

    <!-- Staff / Payroll -->
    <div class="g-card">
        <div class="g-head">
            <div class="g-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                    <circle cx="9" cy="7" r="4" />
                    <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                    <path d="M16 3.13a4 4 0 0 1 0 7.75" />
                </svg>
            </div>
            <div class="g-title">Staff &amp; Payroll <span class="tag admin">Admin</span><small>Employees, salary, attendance and paysheet</small></div>
        </div>
        <ol class="g-steps">
            <li><b>Employees:</b> add each staff member (name, phone, Aadhar, designation, joining date). The <b>Emp ID</b> is generated automatically using the branch prefix (e.g. AM00001). Set an <b>Exit Date</b> and reason when someone leaves.</li>
            <li><b>Salary Structure:</b> search and pick an employee, then enter <b>Basic, DA, HRA, Other Allowance</b> and <b>Other Deduction</b> with an <b>Effective From</b> date. Gross and Net are calculated. Adding a new dated structure automatically closes the previous one, so you keep a salary history.</li>
            <li><b>Attendance:</b> choose a month and click <b>Submit</b> to load all employees who have a salary structure. Enter <b>Duties</b> (days worked), <b>OTs</b> and <b>OT Rate</b>, then <b>Save</b>.</li>
            <li><b>Paysheet:</b> pick a month and click <b>Show</b>. Pay is worked out as Net &times; Duties &divide; days-in-month, plus OT (OTs &times; OT Rate). Download an individual <b>payslip PDF</b> per employee, the whole <b>wage sheet PDF</b>, or export to <b>Excel</b>.</li>
        </ol>
    </div>

    <!-- Reports & Dashboard -->
    <div class="g-card">
        <div class="g-head">
            <div class="g-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="6" y1="20" x2="6" y2="14" />
                    <line x1="12" y1="20" x2="12" y2="4" />
                    <line x1="18" y1="20" x2="18" y2="10" />
                </svg>
            </div>
            <div class="g-title">Dashboard &amp; Reports<small>See how things stand</small></div>
        </div>
        <ol class="g-steps">
            <li>The <b>Dashboard</b> shows live counts (rooms, beds, occupancy), an <b>Income vs Expense</b> graph, and the longest-pending payments &mdash; click <b>Make Payment</b> on any of them to jump straight to that resident's receipt. The <b>bell</b> at the top shows how many bills are due.</li>
            <li><b>Reports</b> has tabs: <b>Collections</b>, <b>Dues</b>, <b>Expenses</b>, <b>Occupancy</b>, <b>Income vs Expense</b> (now including staff salary) and <b>Room History</b>.</li>
            <li><b>Room History</b> shows, for a chosen room and date range, every resident who stayed in each bed and their payments in that period.</li>
            <li>Pick a date range (or year), then use <b>Print</b> or <b>Excel</b> to export any report.</li>
        </ol>
    </div>

    <!-- General tips -->
    <div class="g-card">
        <div class="g-head">
            <div class="g-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M9 18h6" />
                    <path d="M10 22h4" />
                    <path d="M12 2a7 7 0 0 0-4 12.7c.5.4.8 1 .9 1.6h6.2c.1-.6.4-1.2.9-1.6A7 7 0 0 0 12 2z" />
                </svg>
            </div>
            <div class="g-title">Handy tips<small>Small things worth knowing</small></div>
        </div>
        <ol class="g-steps">
            <li>Switch <b>branch</b> from the chip at the top &mdash; the whole app then shows that branch's data.</li>
            <li>Use the <b>moon/sun</b> button to switch between dark and light themes.</li>
            <li>Always <b>Sign out</b> (top-right power icon) when you're done, especially on a shared computer.</li>
        </ol>
    </div>

</asp:Content>
