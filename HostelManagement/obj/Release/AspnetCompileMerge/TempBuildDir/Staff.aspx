<%@ Page Title="Staff" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Staff.aspx.cs" Inherits="HostelManagement.Staff" %>

<asp:Content ID="cphHead" ContentPlaceHolderID="head" runat="server">
    <style>
        .page-head { margin-bottom:18px; }
        .page-head h2 { font-size:22px; font-weight:700; color:var(--text); }
        .page-head p  { font-size:13px; color:var(--text-muted); margin-top:4px; }

        .card { background:var(--card-bg); border:1px solid var(--border); border-radius:14px;
            padding:22px; box-shadow:var(--shadow); }
        .card-title { font-size:15px; font-weight:600; color:var(--text); margin-bottom:16px; }

        .form-row { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr));
            gap:14px; align-items:end; margin-bottom:10px; }
        .fg { display:flex; flex-direction:column; }
        .fg label { font-size:13px; font-weight:600; color:var(--text); margin-bottom:6px; }
        .fg input, .fg select, .fg textarea { padding:10px 13px; border:1.5px solid var(--border);
            border-radius:9px; font-size:14px; color:var(--text); background:var(--bg);
            outline:none; font-family:inherit; }
        .fg input:focus, .fg select:focus, .fg textarea:focus {
            border-color:var(--primary); box-shadow:0 0 0 3px rgba(124,58,237,.15); }
        .fg.chk { flex-direction:row; align-items:center; gap:8px; }
        .fg.chk input { width:16px; height:16px; }

        .btn-primary { padding:10px 22px; border:none !important; border-radius:9px;
            background:linear-gradient(135deg,#4f46e5,#7c3aed) !important;
            color:#fff !important; font-size:14px; font-weight:600; cursor:pointer; height:41px; }
        .btn-primary:hover { opacity:.92; }
        .btn-x { padding:10px 16px; border:1.5px solid var(--border); border-radius:9px;
            background:transparent; color:var(--text-muted); font-size:13px; font-weight:600;
            cursor:pointer; height:41px; }

        .btn-print, .btn-excel, .btn-purple { padding:9px 18px; border-radius:9px; font-size:13px;
            font-weight:600; cursor:pointer; font-family:inherit; height:41px; }
        .btn-excel { background:#16a34a !important; color:#fff !important; border:none !important; }
        .btn-excel:hover { background:#15803d !important; }
        .btn-purple { background:linear-gradient(135deg,#4f46e5,#7c3aed) !important; color:#fff !important; border:none !important; }
        .btn-purple:hover { opacity:.92; }
        .btn-print { background:transparent !important; color:var(--text-muted); border:1.5px solid var(--border); }
        .btn-print:hover { border-color:#7c3aed; color:#7c3aed; }
        .pdf-pill { display:inline-block; padding:4px 12px; border-radius:6px; background:#dc2626 !important;
            color:#fff !important; font-size:12px; font-weight:600; text-decoration:none; }
        .pdf-pill:hover { background:#b91c1c !important; color:#fff !important; }

        .msg { font-size:13px; font-weight:600; margin-left:4px; }
        .msg.success { color:#16a34a; }
        .msg.error { color:#dc2626; }

        .tbl { width:100%; border-collapse:collapse; margin-top:18px; }
        .tbl th { text-align:left; font-size:12px; text-transform:uppercase; letter-spacing:.4px;
            color:var(--text-muted); font-weight:600; padding:11px 12px; border-bottom:1px solid var(--border); }
        .tbl td { padding:11px 12px; font-size:14px; color:var(--text); border-bottom:1px solid var(--border); }

        .act { font-size:13px; font-weight:600; text-decoration:none; margin-right:12px; cursor:pointer; }
        .act-edit { color:var(--primary); }

        .badge { display:inline-block; padding:3px 10px; border-radius:20px; font-size:12px; font-weight:700; }
        .badge.on { background:rgba(22,163,74,.15); color:#16a34a; }
        .badge.off { background:rgba(107,114,128,.18); color:var(--text-muted); }

        .tabs { display:flex; gap:6px; flex-wrap:wrap; margin-bottom:20px;
            border-bottom:1px solid var(--border); }
        .tab { padding:11px 18px; border:none; background:transparent; cursor:pointer;
            font-family:inherit; font-size:14px; font-weight:600; color:var(--text-muted);
            border-bottom:2.5px solid transparent; text-decoration:none; }
        .tab:hover { color:var(--text); }
        .tab.active { color:var(--primary); border-bottom-color:var(--primary); }

        .tbl .num { text-align:right; }
        .picker { padding:10px 13px; border:1.5px solid var(--border); border-radius:9px;
            font-size:14px; color:var(--text); background:var(--bg); outline:none; font-family:inherit; }
        .picker:focus { border-color:var(--primary); box-shadow:0 0 0 3px rgba(124,58,237,.15); }
        .tbl .mini { width:90px; padding:6px 8px; border:1.5px solid var(--border);
            border-radius:7px; font-size:13px; text-align:right; color:var(--text); background:var(--bg); }
        .tbl .mini:focus { border-color:var(--primary); outline:none; }
        .tbl input { padding:7px 9px; border:1.5px solid var(--border); border-radius:7px;
            font-size:13px; color:var(--text); background:var(--bg); outline:none;
            font-family:inherit; width:100%; }
        .tbl input.mini { width:80px; text-align:right; }
        .tbl tfoot td { padding:12px; font-size:14px; border-top:2px solid var(--border); }

        .empty { text-align:center; color:var(--text-muted); padding:26px; font-size:14px; }

        .restricted { text-align:center; padding:50px 20px; color:var(--text-muted); }
        .restricted svg { width:44px; height:44px; opacity:.5; margin-bottom:12px; }
    </style>
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-head">
        <h2>Staff</h2>
        <p>Employees, salary structure, attendance and paysheet.</p>
    </div>

    <asp:Panel ID="pnlRestricted" runat="server" Visible="false">
        <div class="card">
            <div class="restricted">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="11" width="18" height="11" rx="2" />
                    <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                </svg>
                <p>Staff management is available to administrators only.</p>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlMain" runat="server">

        <asp:HiddenField ID="hfTab" runat="server" Value="employees" />
        <div class="tabs">
            <asp:LinkButton ID="tabEmployees" runat="server" CssClass="tab" OnClick="Tab_Click" CommandArgument="employees">Employees</asp:LinkButton>
            <asp:LinkButton ID="tabSalary"    runat="server" CssClass="tab" OnClick="Tab_Click" CommandArgument="salary">Salary Structure</asp:LinkButton>
            <asp:LinkButton ID="tabAtt"       runat="server" CssClass="tab" OnClick="Tab_Click" CommandArgument="attendance">Attendance</asp:LinkButton>
            <asp:LinkButton ID="tabPay"       runat="server" CssClass="tab" OnClick="Tab_Click" CommandArgument="paysheet">Paysheet</asp:LinkButton>
        </div>

        <!-- ============ EMPLOYEES ============ -->
        <asp:Panel ID="pnlEmployees" runat="server">
        <div class="card">
            <div class="card-title">Employee Details</div>
            <asp:HiddenField ID="hfStaffId" runat="server" Value="0" />

            <div class="form-row">
                <div class="fg">
                    <label>Employee ID</label>
                    <asp:TextBox ID="txtEmpId" runat="server" ReadOnly="true"
                        placeholder="auto-generated" style="background:var(--hover); color:var(--text-muted);"></asp:TextBox></div>
                <div class="fg">
                    <label>Employee Name</label>
                    <asp:TextBox ID="txtName" runat="server" placeholder="Full name"></asp:TextBox></div>
                <div class="fg">
                    <label>Phone</label>
                    <asp:TextBox ID="txtPhone" runat="server" MaxLength="10" placeholder="10-digit number"></asp:TextBox></div>
                <div class="fg">
                    <label>Aadhar No</label>
                    <asp:TextBox ID="txtAadhar" runat="server" MaxLength="14" placeholder="xxxx xxxx xxxx"></asp:TextBox></div>
                <div class="fg">
                    <label>Gender</label>
                    <asp:DropDownList ID="ddlGender" runat="server">
                        <asp:ListItem Value="Male">Male</asp:ListItem>
                        <asp:ListItem Value="Female">Female</asp:ListItem>
                    </asp:DropDownList></div>
            </div>

            <div class="form-row">
                <div class="fg">
                    <label>Designation</label>
                    <asp:DropDownList ID="ddlDesignation" runat="server"></asp:DropDownList></div>
                <div class="fg">
                    <label>Date of Joining</label>
                    <asp:TextBox ID="txtDoj" runat="server" TextMode="Date"></asp:TextBox></div>
                <div class="fg" style="grid-column: span 2;">
                    <label>Address</label>
                    <asp:TextBox ID="txtAddress" runat="server" placeholder="Address"></asp:TextBox></div>
            </div>

            <div class="form-row">
                <div class="fg">
                    <label>Date of Exit</label>
                    <asp:TextBox ID="txtExitDate" runat="server" TextMode="Date"></asp:TextBox></div>
                <div class="fg" style="grid-column: span 2;">
                    <label>Reason for Exit</label>
                    <asp:TextBox ID="txtExitReason" runat="server" placeholder="Reason (if the employee has left)"></asp:TextBox></div>
            </div>

            <div class="form-row">
                <div class="fg chk">
                    <asp:CheckBox ID="chkActive" runat="server" Checked="true" /><label>Active</label></div>
                <div class="fg" style="flex-direction:row; gap:10px;">
                    <asp:Button ID="btnSave" runat="server" CssClass="btn-primary" Text="Save"
                        OnClick="btnSave_Click" OnClientClick="return validateStaff();" />
                    <asp:Button ID="btnClear" runat="server" CssClass="btn-x" Text="Clear"
                        OnClick="btnClear_Click" CausesValidation="false" />
                </div>
                <asp:Label ID="lblMsg" runat="server" CssClass="msg"></asp:Label>
            </div>

            <asp:Repeater ID="rptStaff" runat="server" OnItemCommand="rptStaff_ItemCommand">
                <HeaderTemplate>
                    <table class="tbl">
                        <thead>
                            <tr>
                                <th>Emp ID</th><th>Name</th><th>Designation</th><th>Phone</th>
                                <th>Joined</th><th>Exit</th><th>Status</th><th></th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td style="font-weight:600; color:var(--primary);"><%# Eval("EmpId") %></td>
                        <td><%# Eval("StaffName") %></td>
                        <td><%# Eval("Designation") %></td>
                        <td><%# Eval("Phone") %></td>
                        <td><%# Eval("DateOfJoining") == DBNull.Value ? "&mdash;" : Convert.ToDateTime(Eval("DateOfJoining")).ToString("dd/MM/yyyy") %></td>
                        <td><%# Eval("ExitDate") == DBNull.Value ? "&mdash;" : Convert.ToDateTime(Eval("ExitDate")).ToString("dd/MM/yyyy") %></td>
                        <td><span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge on" : "badge off" %>'><%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Exited" %></span></td>
                        <td>
                            <asp:LinkButton runat="server" CssClass="act act-edit" CommandName="EditStaff"
                                CommandArgument='<%# Eval("StaffId") %>'>Edit</asp:LinkButton></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate></tbody></table></FooterTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
                <div class="empty">No staff added for this branch yet.</div>
            </asp:Panel>
        </div>
        </asp:Panel>

        <!-- ============ SALARY STRUCTURE ============ -->
        <asp:Panel ID="pnlSalary" runat="server" Visible="false">
            <div class="card">
                <div class="card-title">Salary Structure</div>
                <asp:HiddenField ID="hfStructureId" runat="server" Value="0" />

                <div class="form-row">
                    <div class="fg" style="grid-column: span 2;">
                        <label>Employee (type to search)</label>
                        <input type="text" id="salEmpPick" list="salEmpList" placeholder="Type emp id or name, then pick"
                            autocomplete="off" onchange="pickSalEmp()" class="picker" />
                        <datalist id="salEmpList"></datalist>
                        <asp:HiddenField ID="hfSalStaffId" runat="server" Value="" />
                        <asp:DropDownList ID="ddlSalStaff" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="ddlSalStaff_Changed" style="display:none;"></asp:DropDownList></div>
                    <div class="fg">
                        <label>Effective From</label>
                        <asp:TextBox ID="txtEffFrom" runat="server" TextMode="Date"></asp:TextBox></div>
                    <div class="fg">
                        <label>Effective To (blank = ongoing)</label>
                        <asp:TextBox ID="txtEffTo" runat="server" TextMode="Date"></asp:TextBox></div>
                </div>

                <div class="form-row">
                    <div class="fg">
                        <label>Basic (&#8377;)</label>
                        <asp:TextBox ID="txtBasic" runat="server" TextMode="Number" oninput="calcSal()" Text="0"></asp:TextBox></div>
                    <div class="fg">
                        <label>DA (&#8377;)</label>
                        <asp:TextBox ID="txtDA" runat="server" TextMode="Number" oninput="calcSal()" Text="0"></asp:TextBox></div>
                    <div class="fg">
                        <label>HRA (&#8377;)</label>
                        <asp:TextBox ID="txtHRA" runat="server" TextMode="Number" oninput="calcSal()" Text="0"></asp:TextBox></div>
                    <div class="fg">
                        <label>Other Allowance (&#8377;)</label>
                        <asp:TextBox ID="txtOtherAllow" runat="server" TextMode="Number" oninput="calcSal()" Text="0"></asp:TextBox></div>
                    <div class="fg">
                        <label>Other Deduction (&#8377;)</label>
                        <asp:TextBox ID="txtOtherDeduct" runat="server" TextMode="Number" oninput="calcSal()" Text="0"></asp:TextBox></div>
                </div>

                <div class="form-row">
                    <div class="fg">
                        <label>Gross (&#8377;)</label>
                        <asp:TextBox ID="txtGross" runat="server" ReadOnly="true"
                            style="background:var(--hover); font-weight:700;"></asp:TextBox></div>
                    <div class="fg">
                        <label>Net Salary (&#8377;)</label>
                        <asp:TextBox ID="txtNet" runat="server" ReadOnly="true"
                            style="background:var(--hover); font-weight:700; color:var(--primary);"></asp:TextBox></div>
                    <div class="fg" style="flex-direction:row; gap:10px;">
                        <asp:Button ID="btnSalSave" runat="server" CssClass="btn-primary" Text="Save"
                            OnClick="btnSalSave_Click" OnClientClick="return validateSal();" />
                        <asp:Button ID="btnSalClear" runat="server" CssClass="btn-x" Text="Clear"
                            OnClick="btnSalClear_Click" CausesValidation="false" />
                    </div>
                    <asp:Label ID="lblSalMsg" runat="server" CssClass="msg"></asp:Label>
                </div>

                <asp:Repeater ID="rptSalary" runat="server" OnItemCommand="rptSalary_ItemCommand">
                    <HeaderTemplate>
                        <table class="tbl">
                            <thead>
                                <tr>
                                    <th>Emp ID</th><th>Name</th><th>Period</th>
                                    <th class="num">Basic</th><th class="num">DA</th><th class="num">HRA</th>
                                    <th class="num">Other Allow.</th><th class="num">Other Deduct.</th>
                                    <th class="num">Net</th><th></th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td style="font-weight:600; color:var(--primary);"><%# Eval("EmpId") %></td>
                            <td><%# Eval("StaffName") %></td>
                            <td><%# Eval("EffectiveFrom","{0:dd/MM/yyyy}") %> &ndash;
                                <%# Eval("EffectiveTo") == DBNull.Value ? "ongoing" : Convert.ToDateTime(Eval("EffectiveTo")).ToString("dd/MM/yyyy") %></td>
                            <td class="num"><%# Eval("Basic","{0:N0}") %></td>
                            <td class="num"><%# Eval("DA","{0:N0}") %></td>
                            <td class="num"><%# Eval("HRA","{0:N0}") %></td>
                            <td class="num"><%# Eval("OtherAllowance","{0:N0}") %></td>
                            <td class="num"><%# Eval("OtherDeduction","{0:N0}") %></td>
                            <td class="num" style="font-weight:700;"><%# Eval("NetSalary","{0:N0}") %></td>
                            <td>
                                <asp:LinkButton runat="server" CssClass="act act-edit" CommandName="EditSal"
                                    CommandArgument='<%# Eval("StructureId") %>'
                                    Visible='<%# Convert.ToInt32(Eval("HasStructure")) == 1 %>'>Edit</asp:LinkButton>
                                <asp:Label runat="server" CssClass="act" Style="color:var(--text-muted);"
                                    Visible='<%# Convert.ToInt32(Eval("HasStructure")) == 0 %>'>No structure</asp:Label></td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate></tbody></table></FooterTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlSalEmpty" runat="server" Visible="false">
                    <div class="empty">No salary structures defined yet.</div>
                </asp:Panel>
            </div>
        </asp:Panel>

        <!-- ============ ATTENDANCE ============ -->
        <asp:Panel ID="pnlAtt" runat="server" Visible="false">
            <div class="card">
                <div class="card-title">Monthly Attendance</div>
                <div class="form-row">
                    <div class="fg">
                        <label>Month</label>
                        <asp:DropDownList ID="ddlAttMonth" runat="server"></asp:DropDownList></div>
                    <div class="fg">
                        <label>Year</label>
                        <asp:DropDownList ID="ddlAttYear" runat="server"></asp:DropDownList></div>
                    <div class="fg" style="flex-direction:row; gap:10px; align-items:flex-end;">
                        <asp:Button ID="btnAttLoad" runat="server" CssClass="btn-primary" Text="Submit" OnClick="btnAttLoad_Click" />
                    </div>
                </div>

                <asp:Panel ID="pnlAttGrid" runat="server" Visible="false">
                    <asp:Repeater ID="rptAtt" runat="server">
                        <HeaderTemplate>
                            <table class="tbl">
                                <thead>
                                    <tr>
                                        <th>Emp ID</th><th>Name</th><th>Designation</th>
                                        <th class="num">Duties</th>
                                        <th class="num">OTs</th>
                                        <th class="num">OT Rate</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td style="font-weight:600; color:var(--primary);"><%# Eval("EmpId") %>
                                    <asp:HiddenField ID="hfAttStaffId" runat="server" Value='<%# Eval("StaffId") %>' /></td>
                                <td><%# Eval("StaffName") %></td>
                                <td><%# Eval("Designation") %></td>
                                <td class="num"><asp:TextBox ID="txtDuties" runat="server" TextMode="Number"
                                    CssClass="mini" Text='<%# Eval("Duties","{0:0.##}") %>'></asp:TextBox></td>
                                <td class="num"><asp:TextBox ID="txtOTs" runat="server" TextMode="Number"
                                    CssClass="mini" Text='<%# Eval("OTs","{0:0.##}") %>'></asp:TextBox></td>
                                <td class="num"><asp:TextBox ID="txtOtRate" runat="server" TextMode="Number"
                                    CssClass="mini" Text='<%# Eval("OtRate","{0:0.##}") %>'></asp:TextBox></td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate></tbody></table></FooterTemplate>
                    </asp:Repeater>

                    <div style="margin-top:16px; display:flex; gap:12px; align-items:center;">
                        <asp:Button ID="btnAttSave" runat="server" CssClass="btn-primary" Text="Save Attendance" OnClick="btnAttSave_Click" />
                        <asp:Label ID="lblAttMsg" runat="server" CssClass="msg"></asp:Label>
                    </div>

                    <asp:Panel ID="pnlAttEmpty" runat="server" Visible="false">
                        <div class="empty">No employees with a salary structure yet. Add salary structures first.</div>
                    </asp:Panel>
                </asp:Panel>

            </div>
        </asp:Panel>

        <!-- ============ PAYSHEET ============ -->
        <asp:Panel ID="pnlPay" runat="server" Visible="false">
            <div class="card">
                <div class="card-title">Paysheet</div>
                <div class="form-row">
                    <div class="fg">
                        <label>Month</label>
                        <asp:DropDownList ID="ddlPayMonth" runat="server"></asp:DropDownList></div>
                    <div class="fg">
                        <label>Year</label>
                        <asp:DropDownList ID="ddlPayYear" runat="server"></asp:DropDownList></div>
                    <div class="fg" style="flex-direction:row; gap:10px; align-items:flex-end;">
                        <asp:Button ID="btnPayShow" runat="server" CssClass="btn-primary" Text="Show" OnClick="btnPayShow_Click" />
                        <asp:Button ID="btnPayPdf" runat="server" CssClass="btn-purple" Text="Wage Sheet PDF" OnClick="btnPayPdf_Click" />
                        <asp:Button ID="btnPayXls" runat="server" CssClass="btn-excel" Text="Excel" OnClick="btnPayXls_Click" />
                        <button type="button" class="btn-print" onclick="window.print()">Print</button>
                    </div>
                    <asp:Label ID="lblPayMsg" runat="server" CssClass="msg"></asp:Label>
                </div>

                <asp:Repeater ID="rptPay" runat="server">
                    <HeaderTemplate>
                        <table class="tbl">
                            <thead>
                                <tr>
                                    <th>Emp ID</th><th>Name</th><th>Designation</th>
                                    <th class="num">Net Salary</th>
                                    <th class="num">Days</th>
                                    <th class="num">Duties</th>
                                    <th class="num">Payable</th>
                                    <th class="num">OTs</th>
                                    <th class="num">OT Rate</th>
                                    <th class="num">OT Amt</th>
                                    <th class="num">Final Pay</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td style="font-weight:600; color:var(--primary);"><%# Eval("EmpId") %></td>
                            <td><%# Eval("StaffName") %></td>
                            <td><%# Eval("Designation") %></td>
                            <td class="num"><%# Eval("NetSalary","{0:N0}") %></td>
                            <td class="num"><%# Eval("DaysInMonth") %></td>
                            <td class="num"><%# Eval("Duties","{0:0.##}") %></td>
                            <td class="num"><%# Eval("Payable","{0:N0}") %></td>
                            <td class="num"><%# Eval("OTs","{0:0.##}") %></td>
                            <td class="num"><%# Eval("OtRate","{0:N0}") %></td>
                            <td class="num"><%# Eval("OtAmount","{0:N0}") %></td>
                            <td class="num" style="font-weight:700;"><%# Eval("FinalPay","{0:N0}") %></td>
                            <td><a class="pdf-pill" target="_blank"
                                href='<%# "PayslipPdf.aspx?staffId=" + Eval("StaffId") + "&yr=" + PayYear + "&mon=" + PayMonth %>'>PDF</a></td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        </tbody>
                        <tfoot>
                            <tr>
                                <td colspan="10" style="text-align:right; font-weight:700;">Total</td>
                                <td class="num" style="font-weight:700;"><asp:Literal ID="litPayTotal" runat="server"></asp:Literal></td>
                                <td></td>
                            </tr>
                        </tfoot>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlPayEmpty" runat="server" Visible="false">
                    <div class="empty">No attendance saved for this month. Save attendance first, then click Show.</div>
                </asp:Panel>
            </div>
        </asp:Panel>

    </asp:Panel>

    <script>
        // ---- searchable employee dropdown (datalist-backed) ----
        // Populate the datalist from the hidden dropdown's options, then let the
        // user type to filter. Selecting a value syncs the real (hidden) dropdown
        // and triggers its server-side change so the structure loads.
        function initEmpOpts() {
            var sel = document.getElementById('<%= ddlSalStaff.ClientID %>');
            var list = document.getElementById('salEmpList');
            if (!sel || !list) return;
            list.innerHTML = '';
            for (var i = 0; i < sel.options.length; i++) {
                if (sel.options[i].value === '') continue;
                var op = document.createElement('option');
                op.value = sel.options[i].text;   // shown/typed text
                op.setAttribute('data-val', sel.options[i].value);
                list.appendChild(op);
            }
            // reflect current selection into the input box
            var pick = document.getElementById('salEmpPick');
            if (pick && sel.selectedIndex > 0) pick.value = sel.options[sel.selectedIndex].text;
        }

        function pickSalEmp() {
            var pick = document.getElementById('salEmpPick');
            var sel = document.getElementById('<%= ddlSalStaff.ClientID %>');
            if (!pick || !sel) return;
            var typed = pick.value.trim().toLowerCase();
            var matched = '';
            for (var i = 0; i < sel.options.length; i++) {
                if (sel.options[i].text.toLowerCase() === typed) { matched = sel.options[i].value; break; }
            }
            // also allow matching by Emp ID prefix if exact text not found
            if (matched === '') {
                for (var j = 0; j < sel.options.length; j++) {
                    if (sel.options[j].value !== '' &&
                        sel.options[j].text.toLowerCase().indexOf(typed) === 0) { matched = sel.options[j].value; break; }
                }
            }
            if (matched !== '') {
                sel.value = matched;
                // fire the server-side SelectedIndexChanged (AutoPostBack)
                if (typeof __doPostBack === 'function') {
                    __doPostBack(sel.name, '');
                }
            }
        }
        window.addEventListener('load', initEmpOpts);

        // ---- salary live totals ----
        function calcSal() {
            var n = function (id) { var el = document.getElementById(id); return el ? (parseFloat(el.value) || 0) : 0; };
            var gross = n('<%= txtBasic.ClientID %>') + n('<%= txtDA.ClientID %>') +
                        n('<%= txtHRA.ClientID %>') + n('<%= txtOtherAllow.ClientID %>');
            var net = gross - n('<%= txtOtherDeduct.ClientID %>');
            var g = document.getElementById('<%= txtGross.ClientID %>');
            var t = document.getElementById('<%= txtNet.ClientID %>');
            if (g) g.value = gross.toFixed(2);
            if (t) t.value = net.toFixed(2);
        }

        function validateSal() {
            var s = document.getElementById('<%= ddlSalStaff.ClientID %>');
            if (s && s.value === '') { alert('Please select an employee.'); return false; }
            var f = document.getElementById('<%= txtEffFrom.ClientID %>').value;
            if (!f) { alert('Please enter the Effective From date.'); return false; }
            var b = parseFloat(document.getElementById('<%= txtBasic.ClientID %>').value) || 0;
            if (b <= 0) { alert('Please enter the Basic amount.'); return false; }
            return true;
        }

        function validateStaff() {
            var n = document.getElementById('<%= txtName.ClientID %>').value.trim();
            if (n === '') { alert('Please enter the employee name.'); return false; }
            var d = document.getElementById('<%= ddlDesignation.ClientID %>').value;
            if (d === '') { alert('Please select a designation.'); return false; }
            var ex = document.getElementById('<%= txtExitDate.ClientID %>').value;
            var rs = document.getElementById('<%= txtExitReason.ClientID %>').value.trim();
            if (ex !== '' && rs === '') { alert('Please enter the reason for exit.'); return false; }
            return true;
        }
    </script>

</asp:Content>
