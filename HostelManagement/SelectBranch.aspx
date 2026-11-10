<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SelectBranch.aspx.cs" Inherits="HostelManagement.SelectBranch" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Select Branch | Hostel Management System</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box;
            font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }

        body { min-height:100vh; display:flex; align-items:center; justify-content:center;
               background:linear-gradient(135deg,#4f46e5 0%,#7c3aed 50%,#9333ea 100%); padding:20px; }

        .card { background:#fff; width:100%; max-width:680px; border-radius:18px;
                box-shadow:0 25px 60px rgba(0,0,0,.25); padding:40px 35px; animation:fadeIn .5s ease; }

        @keyframes fadeIn { from{opacity:0;transform:translateY(15px);} to{opacity:1;transform:translateY(0);} }

        .header { text-align:center; margin-bottom:30px; }
        .header .logo { width:60px; height:60px; margin:0 auto 14px;
            background:linear-gradient(135deg,#4f46e5,#9333ea); border-radius:16px;
            display:flex; align-items:center; justify-content:center; font-size:28px; color:#fff;
            box-shadow:0 8px 20px rgba(79,70,229,.4); }
        .header h1 { font-size:22px; color:#1f2937; font-weight:700; }
        .header p  { font-size:13px; color:#6b7280; margin-top:6px; }

        .branch-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(180px,1fr)); gap:16px; }

        .branch-card { display:block; text-decoration:none; text-align:center;
            border:1.5px solid #e5e7eb; border-radius:14px; padding:22px 16px;
            transition:all .2s ease; cursor:pointer; background:#fff; }
        .branch-card:hover { border-color:#7c3aed; box-shadow:0 8px 22px rgba(124,58,237,.18);
            transform:translateY(-3px); }

        .branch-icon { font-size:30px; margin-bottom:10px; }
        .branch-name { font-size:15px; font-weight:600; color:#1f2937; }
        .branch-city { font-size:12px; color:#6b7280; margin-top:4px; }

        .logout-link { text-align:center; font-size:13px; color:#6b7280; margin-top:28px; }
        .logout-link a { color:#7c3aed; text-decoration:none; font-weight:600; }
        .logout-link a:hover { text-decoration:underline; }

        .empty { text-align:center; color:#9ca3af; font-size:14px; padding:20px 0; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="card">
            <div class="header">
                <div class="logo">&#127970;</div>
                <h1>Select a Branch</h1>
                <p>Choose the hostel branch you want to manage.</p>
            </div>

            <asp:Repeater ID="rptBranches" runat="server" OnItemCommand="rptBranches_ItemCommand">
                <HeaderTemplate>
                    <div class="branch-grid">
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:LinkButton runat="server" CssClass="branch-card"
                        CommandName="PickBranch"
                        CommandArgument='<%# Eval("BranchId") %>'>
                        <div class="branch-icon">&#127970;</div>
                        <div class="branch-name"><%# Eval("BranchName") %></div>
                        <div class="branch-city"><%# Eval("City") %></div>
                        <asp:HiddenField runat="server" ID="hdnBranchName"
                            Value='<%# Eval("BranchName") %>' />
                    </asp:LinkButton>
                </ItemTemplate>
                <FooterTemplate>
                    </div>
                </FooterTemplate>
            </asp:Repeater>

            <asp:Label ID="lblEmpty" runat="server" CssClass="empty" Visible="false"
                Text="No active branches found. Please contact the administrator."></asp:Label>

            <div class="logout-link">
                <asp:LinkButton ID="btnLogout" runat="server"
                    OnClick="btnLogout_Click">Sign out</asp:LinkButton>
            </div>
        </div>
    </form>
</body>
</html>
