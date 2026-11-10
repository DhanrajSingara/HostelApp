<%@ Page Title="Hostel Info" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="HostelInfo.aspx.cs" Inherits="HostelManagement.HostelInfo" %>

<asp:Content ID="cphHead" ContentPlaceHolderID="head" runat="server">
    <style>
        .page-head { margin-bottom:22px; }
        .page-head h2 { font-size:22px; font-weight:700; color:var(--text); }
        .page-head p  { font-size:13px; color:var(--text-muted); margin-top:4px; }

        .form-card { background:var(--card-bg); border:1px solid var(--border); border-radius:14px;
            padding:26px; box-shadow:var(--shadow); max-width:920px; }

        .section-title { font-size:15px; font-weight:600; color:var(--primary);
            margin:8px 0 16px; padding-bottom:8px; border-bottom:1px solid var(--border); }
        .section-title:not(:first-child){ margin-top:30px; }

        .form-row { display:grid; grid-template-columns:repeat(auto-fit,minmax(240px,1fr));
            gap:18px; margin-bottom:4px; }
        .form-group { margin-bottom:16px; display:flex; flex-direction:column; }
        .form-group.full { grid-column:1 / -1; }
        .form-group label { font-size:13px; font-weight:600; color:var(--text); margin-bottom:6px; }

        .form-group input, .form-group select, .form-group textarea {
            width:100%; padding:11px 13px; border:1.5px solid var(--border); border-radius:9px;
            font-size:14px; color:var(--text); background:var(--bg);
            transition:all .18s ease; outline:none; font-family:inherit; }
        .form-group textarea { resize:vertical; min-height:80px; }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
            border-color:var(--primary); box-shadow:0 0 0 3px rgba(124,58,237,.15); }

        .actions { display:flex; align-items:center; gap:16px; margin-top:24px;
            padding-top:20px; border-top:1px solid var(--border); }
        .btn-save { padding:12px 28px; border:none; border-radius:10px;
            background:var(--primary-grad); color:#fff; font-size:14px; font-weight:600;
            cursor:pointer; transition:all .2s ease; }
        .btn-save:hover { transform:translateY(-2px); box-shadow:0 10px 22px rgba(124,58,237,.35); }

        .msg { font-size:13px; font-weight:600; }
        .msg.success { color:#16a34a; }
        .msg.error   { color:#dc2626; }
    </style>
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-head">
        <h2>Hostel Information</h2>
        <p>Manage the profile and details for this hostel branch.</p>
    </div>

    <div class="form-card">

        <!-- ===== Basic details ===== -->
        <div class="section-title">Basic Details</div>
        <div class="form-row">
            <div class="form-group">
                <label>Hostel Name</label>
                <asp:TextBox ID="txtHostelName" runat="server" placeholder="e.g. Sunrise Boys Hostel"></asp:TextBox>
            </div>
            <div class="form-group">
                <label>Hostel Type</label>
                <asp:DropDownList ID="ddlHostelType" runat="server">
                    <asp:ListItem Text="-- Select --" Value=""></asp:ListItem>
                    <asp:ListItem Text="Boys" Value="Boys"></asp:ListItem>
                    <asp:ListItem Text="Girls" Value="Girls"></asp:ListItem>
                    <asp:ListItem Text="Co-ed" Value="Co-ed"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="form-group">
                <label>Established Year</label>
                <asp:TextBox ID="txtEstablishedYear" runat="server" TextMode="Number" placeholder="e.g. 2015"></asp:TextBox>
            </div>
            <div class="form-group">
                <label>Total Capacity (beds)</label>
                <asp:TextBox ID="txtTotalCapacity" runat="server" TextMode="Number" placeholder="e.g. 200"></asp:TextBox>
            </div>
        </div>

        <!-- ===== Contact ===== -->
        <div class="section-title">Warden &amp; Contact</div>
        <div class="form-row">
            <div class="form-group">
                <label>Warden Name</label>
                <asp:TextBox ID="txtWardenName" runat="server" placeholder="Full name"></asp:TextBox>
            </div>
            <div class="form-group">
                <label>Warden Phone</label>
                <asp:TextBox ID="txtWardenPhone" runat="server" placeholder="10-digit number"></asp:TextBox>
            </div>
            <div class="form-group">
                <label>Email</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" placeholder="hostel@example.com"></asp:TextBox>
            </div>
        </div>

        <!-- ===== Address ===== -->
        <div class="section-title">Address</div>
        <div class="form-row">
            <div class="form-group full">
                <label>Street Address</label>
                <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" Rows="2"
                    placeholder="Building, street, area"></asp:TextBox>
            </div>
            <div class="form-group">
                <label>City</label>
                <asp:TextBox ID="txtCity" runat="server" placeholder="City"></asp:TextBox>
            </div>
            <div class="form-group">
                <label>State</label>
                <asp:TextBox ID="txtState" runat="server" placeholder="State"></asp:TextBox>
            </div>
            <div class="form-group">
                <label>Pincode</label>
                <asp:TextBox ID="txtPincode" runat="server" placeholder="6-digit pincode"></asp:TextBox>
            </div>
        </div>

        <!-- ===== About ===== -->
        <div class="section-title">About &amp; Facilities</div>
        <div class="form-row">
            <div class="form-group full">
                <label>Description</label>
                <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="3"
                    placeholder="A short description of the hostel"></asp:TextBox>
            </div>
            <div class="form-group full">
                <label>Facilities</label>
                <asp:TextBox ID="txtFacilities" runat="server" TextMode="MultiLine" Rows="2"
                    placeholder="e.g. Wi-Fi, Mess, Laundry, 24x7 Security, Gym"></asp:TextBox>
            </div>
        </div>

        <!-- ===== Rules ===== -->
        <div class="section-title">Rules &amp; Regulations</div>
        <div class="form-row">
            <div class="form-group full">
                <label>Rules</label>
                <asp:TextBox ID="txtRules" runat="server" TextMode="MultiLine" Rows="4"
                    placeholder="List the hostel rules and regulations"></asp:TextBox>
            </div>
        </div>

        <div class="actions">
            <asp:Button ID="btnSave" runat="server" CssClass="btn-save"
                Text="Save Information" OnClick="btnSave_Click" />
            <asp:Label ID="lblMessage" runat="server" CssClass="msg"></asp:Label>
        </div>

    </div>

</asp:Content>
