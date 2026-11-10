<%@ Page Title="Beds Allocation" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BedAllocation.aspx.cs" Inherits="HostelManagement.BedAllocation" %>

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
            min-width: 240px;
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

        .msg {
            font-size: 13px;
            font-weight: 600;
            margin-left: auto;
        }

            .msg.success {
                color: #16a34a;
            }

            .msg.error {
                color: #dc2626;
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
            width: 46px;
            height: 46px;
            margin: 0 auto 10px;
            border-radius: 11px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

            .bed-icon svg {
                width: 24px;
                height: 24px;
            }

        .bed-no {
            font-size: 14px;
            font-weight: 700;
            color: var(--text);
        }

        .bed-name {
            font-size: 12px;
            color: var(--text-muted);
            margin-top: 3px;
            min-height: 16px;
        }

        .bed-badge {
            display: inline-block;
            margin-top: 10px;
            padding: 3px 12px;
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
            padding: 36px;
            font-size: 14px;
        }

        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,.5);
            z-index: 1000;
            display: none;
            align-items: center;
            justify-content: center;
            padding: 18px;
        }

            .modal-overlay.show {
                display: flex;
            }

        .modal {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 16px;
            width: 100%;
            max-width: 440px;
            padding: 24px;
            box-shadow: 0 24px 60px rgba(0,0,0,.35);
            max-height: 92vh;
            overflow-y: auto;
        }

            .modal h3 {
                font-size: 17px;
                font-weight: 700;
                color: var(--text);
                margin-bottom: 4px;
            }

            .modal .sub {
                font-size: 13px;
                color: var(--text-muted);
                margin-bottom: 18px;
            }

        .detail-row {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            padding: 11px 0;
            border-bottom: 1px solid var(--border);
            font-size: 14px;
        }

            .detail-row .k {
                color: var(--text-muted);
            }

            .detail-row .v {
                color: var(--text);
                font-weight: 600;
                text-align: right;
            }

        .m-group {
            display: flex;
            flex-direction: column;
            margin-bottom: 14px;
        }

            .m-group label {
                font-size: 13px;
                font-weight: 600;
                color: var(--text);
                margin-bottom: 6px;
            }

            .m-group input, .m-group select, .m-group textarea {
                padding: 11px 13px;
                border: 1.5px solid var(--border);
                border-radius: 9px;
                font-size: 14px;
                color: var(--text);
                background: var(--bg);
                outline: none;
                font-family: inherit;
            }

            .m-group textarea {
                resize: vertical;
                min-height: 64px;
            }

                .m-group input:focus, .m-group select:focus, .m-group textarea:focus {
                    border-color: var(--primary);
                    box-shadow: 0 0 0 3px rgba(124,58,237,.15);
                }

            .m-group input[readonly] {
                background: var(--hover);
                color: var(--text-muted);
                cursor: not-allowed;
            }

        .modal-footer {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            margin-top: 20px;
            padding-top: 18px;
            border-top: 1px solid var(--border);
        }

        .btn {
            padding: 10px 20px;
            border-radius: 9px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            border: none;
        }

        .btn-primary {
            background: var(--primary-grad);
            color: #fff;
        }

        .btn-danger {
            background: #dc2626;
            color: #fff;
        }

        .btn-ghost {
            background: transparent;
            border: 1px solid var(--border);
            color: var(--text-muted);
        }
    </style>
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-head">
        <h2>Beds Allocation</h2>
        <p>Select a floor and room, then click a bed to view or allocate.</p>
    </div>

    <asp:HiddenField ID="hfBedNo" runat="server" />
    <asp:HiddenField ID="hfAllocationId" runat="server" />

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
            <asp:Label ID="lblMessage" runat="server" CssClass="msg"></asp:Label>
        </div>
    </div>

    <div class="card">
        <div class="card-title">Beds</div>
        <div class="legend">
            <span><i class="dot green"></i>Available</span>
            <span><i class="dot red"></i>Occupied</span>
        </div>
        <asp:Literal ID="litBeds" runat="server"></asp:Literal>
        <asp:Literal ID="litBedData" runat="server"></asp:Literal>
    </div>

    <!-- ===== Modal: Occupied details + Exit ===== -->
    <div class="modal-overlay" id="modalDetails">
        <div class="modal">
            <h3>Bed Details</h3>
            <div class="sub" id="detailSub"></div>
            <div class="detail-row"><span class="k">Name</span><span class="v" id="dName"></span></div>
            <div class="detail-row"><span class="k">Aadhar No</span><span class="v" id="dAadhar"></span></div>
            <div class="detail-row"><span class="k">Phone</span><span class="v" id="dPhone"></span></div>
            <div class="detail-row"><span class="k">Gender</span><span class="v" id="dGender"></span></div>
            <div class="detail-row"><span class="k">Profession</span><span class="v" id="dProfession"></span></div>
            <div class="detail-row"><span class="k">Date of Joining</span><span class="v" id="dDoj"></span></div>
            <div class="detail-row"><span class="k">Amount</span><span class="v" id="dAmount"></span></div>
            <div class="detail-row"><span class="k">Admission Fees</span><span class="v" id="dAdmission"></span></div>
            <%--<div class="detail-row"><span class="k">Amount Paid</span><span class="v" id="dPaid"></span></div>--%>

            <asp:Panel ID="pnlEditAdmin" runat="server" Visible="false">
                <div class="card-title" style="margin-top: 18px; margin-bottom: 8px;">Edit Details (Admin)</div>
                <div class="m-group">
                    <label>Person Name</label>
                    <asp:TextBox ID="eName" runat="server"></asp:TextBox>
                </div>
                <div class="m-group">
                    <label>Aadhar No</label>
                    <asp:TextBox ID="eAadhar" runat="server" MaxLength="14"></asp:TextBox>
                </div>
                <div class="m-group">
                    <label>Phone</label>
                    <asp:TextBox ID="ePhone" runat="server" MaxLength="10"></asp:TextBox>
                </div>
                <div class="m-group">
                    <label>Gender</label>
                    <asp:DropDownList ID="eGender" runat="server">
                        <asp:ListItem Value="Male">Male</asp:ListItem>
                        <asp:ListItem Value="Female">Female</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="m-group">
                    <label>Profession</label>
                    <asp:TextBox ID="eProfession" runat="server"></asp:TextBox>
                </div>
                <div class="m-group">
                    <label>Date of Joining</label>
                    <asp:TextBox ID="eDoj" runat="server" TextMode="Date"></asp:TextBox>
                </div>
                <div class="m-group">
                    <label>Admission Fees (&#8377;)</label>
                    <asp:TextBox ID="eAdmission" runat="server" TextMode="Number"></asp:TextBox>
                </div>
                <asp:Button ID="btnUpdate" runat="server" CssClass="btn btn-primary" Text="Update Details"
                    OnClick="btnUpdate_Click" OnClientClick="return validateUpdate();" />
            </asp:Panel>

            <div class="m-group" style="margin-top: 16px;">
                <label>Exit Date</label>
                <asp:TextBox ID="iExitDate" runat="server" TextMode="Date"></asp:TextBox>
            </div>
            <div class="m-group">
                <label>Remarks</label>
                <asp:TextBox ID="iRemarks" runat="server" TextMode="MultiLine"
                    placeholder="Reason for exit / notes"></asp:TextBox>
            </div>
            <div class="m-group" style="flex-direction: row; align-items: center; gap: 8px;">
                <asp:CheckBox ID="chkRefund" runat="server" />
                <label style="margin: 0;">Admission fee refunded (<span id="dRefundAmt"></span>)</label>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('modalDetails')">Close</button>
                <asp:Button ID="btnExit" runat="server" CssClass="btn btn-danger" Text="Exit (Vacate)"
                    OnClick="btnExit_Click" OnClientClick="return validateExit();" />
            </div>
        </div>
    </div>

    <!-- ===== Modal: Allocate ===== -->
    <div class="modal-overlay" id="modalAllocate">
        <div class="modal">
            <h3>Allocate Bed</h3>
            <div class="sub" id="allocSub"></div>
            <div class="m-group">
                <label>Person Name</label>
                <asp:TextBox ID="iName" runat="server" autocomplete="off" placeholder="Full name"></asp:TextBox>
            </div>
            <div class="m-group">
                <label>Aadhar No</label>
                <asp:TextBox ID="iAadhar" runat="server" autocomplete="off" TextMode="Number"  placeholder="xxxx xxxx xxxx" MaxLength="14"></asp:TextBox>
            </div>
            <div class="m-group">
                <label>Phone</label>
                <asp:TextBox ID="iPhone" runat="server" autocomplete="off" TextMode="Number" placeholder="10-digit number" MaxLength="10"></asp:TextBox>
            </div>
            <div class="m-group">
                <label>Gender</label>
                <asp:DropDownList ID="iGender" runat="server">
                    <asp:ListItem Value="Male">Male</asp:ListItem>
                    <asp:ListItem Value="Female">Female</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="m-group">
                <label>Profession</label>
                <asp:TextBox ID="iProfession" autocomplete="off" runat="server" placeholder="e.g. Student, Employee"></asp:TextBox>
            </div>
            <div class="m-group">
                <label>Date of Joining</label>
                <asp:TextBox ID="iDoj" runat="server" TextMode="Date"></asp:TextBox>
            </div>

            <div class="m-group">
                <label>Rent Type</label>
                <asp:DropDownList ID="iRentType" runat="server" onchange="toggleRent()">
                    <asp:ListItem Value="Monthly">Monthly</asp:ListItem>
                    <asp:ListItem Value="Daily">Daily</asp:ListItem>
                </asp:DropDownList>
            </div>

            <!-- Monthly: fixed amount from the room -->
            <div class="m-group" id="monthlyBox">
                <label>Amount (&#8377;) &mdash; fixed (monthly)</label>
                <asp:TextBox ID="iAmount" runat="server" TextMode="Number" ReadOnly="true"></asp:TextBox>
            </div>

            <!-- Daily: days x per-day -->
            <div id="dailyBox" style="display: none;">
                <div class="m-group">
                    <label>Number of Days</label>
                    <asp:TextBox ID="iDays" runat="server" TextMode="Number" oninput="calcDaily()"></asp:TextBox>
                </div>
                <div class="m-group">
                    <label>Amount / Day (&#8377;)</label>
                    <asp:TextBox ID="iPerDay" runat="server" TextMode="Number" oninput="calcDaily()"></asp:TextBox>
                </div>
                <div class="m-group">
                    <label>Total Amount (&#8377;)</label>
                    <asp:TextBox ID="iDailyTotal" runat="server" TextMode="Number" ReadOnly="true"></asp:TextBox>
                </div>
            </div>

            <div class="m-group">
                <label>Admission Fees (&#8377;)</label>
                <asp:TextBox ID="iAdmissionFees" runat="server" TextMode="Number" placeholder="One-time admission fee"></asp:TextBox>
            </div>
            <div class="m-group">
                <label>Pay Now (&#8377;) &mdash; optional</label>
                <asp:TextBox ID="iPayNow" runat="server" TextMode="Number" placeholder="Amount received now (shows on Receipts)"></asp:TextBox>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal('modalAllocate')">Cancel</button>
                <asp:Button ID="btnSave" runat="server" CssClass="btn btn-primary" Text="Save"
                    OnClick="btnSave_Click" OnClientClick="return validateAllocate();" />
            </div>
        </div>
    </div>

    <script>
        // Preserve values already set by the bed-data script above (don't reset them).
        window.BEDS = window.BEDS || [];
        window.ROOM_AMOUNT = window.ROOM_AMOUNT || 0;
        window.ROOM_LABEL = window.ROOM_LABEL || '';

        function today() {
            var d = new Date();
            return d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2) + '-' + ('0' + d.getDate()).slice(-2);
        }
        function findBed(no) { return BEDS.find(function (b) { return b.no === no; }); }
        function showModal(id) { document.getElementById(id).classList.add('show'); }
        function closeModal(id) { document.getElementById(id).classList.remove('show'); }

        // set a value only if the control exists (admin edit fields aren't rendered for others)
        function setVal(id, val) { var el = document.getElementById(id); if (el) el.value = (val == null ? '' : val); }

        // "26 Jun 2026" -> "2026-06-26" for a date input
        function toDateInput(s) {
            if (!s) return '';
            var d = new Date(s);
            if (isNaN(d.getTime())) return '';
            return d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2) + '-' + ('0' + d.getDate()).slice(-2);
        }

        function openBed(no) {
            var b = findBed(no);
            if (!b) return;
            if (b.occupied) {
                document.getElementById('detailSub').innerText = ROOM_LABEL + ' \u00B7 Bed ' + no;
                document.getElementById('dName').innerText = b.name;
                document.getElementById('dAadhar').innerText = b.aadhar || '\u2014';
                document.getElementById('dPhone').innerText = b.phone || '\u2014';
                document.getElementById('dGender').innerText = b.gender || '\u2014';
                document.getElementById('dProfession').innerText = b.profession || '\u2014';
                document.getElementById('dDoj').innerText = b.doj || '\u2014';
                document.getElementById('dAmount').innerText = '\u20B9 ' + b.amount;
                document.getElementById('dAdmission').innerText = '\u20B9 ' + b.admission;
                var ra = document.getElementById('dRefundAmt'); if (ra) ra.innerText = '\u20B9 ' + b.admission;
                var rc = document.getElementById('<%= chkRefund.ClientID %>'); if (rc) rc.checked = false;
                // document.getElementById('dPaid').innerText = '\u20B9 ' + b.paid;
                document.getElementById('<%= hfAllocationId.ClientID %>').value = b.allocationId;
                document.getElementById('<%= iExitDate.ClientID %>').value = today();
                document.getElementById('<%= iRemarks.ClientID %>').value = '';
                // admin edit fields (present only for admins)
                setVal('<%= eName.ClientID %>', b.name);
                setVal('<%= eAadhar.ClientID %>', b.aadhar);
                setVal('<%= ePhone.ClientID %>', b.phone);
                setVal('<%= eGender.ClientID %>', b.gender || 'Male');
                setVal('<%= eProfession.ClientID %>', b.profession);
                setVal('<%= eDoj.ClientID %>', toDateInput(b.doj));
                setVal('<%= eAdmission.ClientID %>', b.admission);
                showModal('modalDetails');
            } else {
                document.getElementById('allocSub').innerText = ROOM_LABEL + ' \u00B7 Bed ' + no;
                document.getElementById('<%= hfBedNo.ClientID %>').value = no;
                document.getElementById('<%= iName.ClientID %>').value = '';
                document.getElementById('<%= iAadhar.ClientID %>').value = '';
                document.getElementById('<%= iPhone.ClientID %>').value = '';
                document.getElementById('<%= iGender.ClientID %>').value = 'Male';
                document.getElementById('<%= iProfession.ClientID %>').value = '';
                document.getElementById('<%= iDoj.ClientID %>').value = today();
                document.getElementById('<%= iAmount.ClientID %>').value = ROOM_AMOUNT;
                document.getElementById('<%= iAdmissionFees.ClientID %>').value = '';
                document.getElementById('<%= iRentType.ClientID %>').value = 'Monthly';
                document.getElementById('<%= iDays.ClientID %>').value = '';
                document.getElementById('<%= iPerDay.ClientID %>').value = '';
                document.getElementById('<%= iDailyTotal.ClientID %>').value = '';
                document.getElementById('<%= iPayNow.ClientID %>').value = '';
                toggleRent();
                showModal('modalAllocate');
            }
        }

        // show/hide daily vs monthly amount fields
        function toggleRent() {
            var t = document.getElementById('<%= iRentType.ClientID %>').value;
            var daily = (t === 'Daily');
            document.getElementById('dailyBox').style.display = daily ? 'block' : 'none';
            document.getElementById('monthlyBox').style.display = daily ? 'none' : 'flex';
            calcDaily();
        }
        function calcDaily() {
            var days = parseFloat(document.getElementById('<%= iDays.ClientID %>').value) || 0;
            var per = parseFloat(document.getElementById('<%= iPerDay.ClientID %>').value) || 0;
            document.getElementById('<%= iDailyTotal.ClientID %>').value = (days * per) ? (days * per).toFixed(2) : '';
        }

        function validateAllocate() {
            var n = document.getElementById('<%= iName.ClientID %>').value.trim();
            if (n === '') { alert('Please enter the person name.'); return false; }
            var t = document.getElementById('<%= iRentType.ClientID %>').value;
            if (t === 'Daily') {
                var days = parseFloat(document.getElementById('<%= iDays.ClientID %>').value) || 0;
                var per = parseFloat(document.getElementById('<%= iPerDay.ClientID %>').value) || 0;
                if (days <= 0) { alert('Enter number of days.'); return false; }
                if (per <= 0) { alert('Enter amount per day.'); return false; }
            }
            return true;
        }
        function validateExit() {
            var d = document.getElementById('<%= iExitDate.ClientID %>').value;
            if (!d) { alert('Please select the exit date.'); return false; }
            return true;
        }
        function validateUpdate() {
            var el = document.getElementById('<%= eName.ClientID %>');
            if (el && el.value.trim() === '') { alert('Please enter the person name.'); return false; }
            return true;
        }
    </script>

</asp:Content>
