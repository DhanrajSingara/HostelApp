<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="HostelManagement.ForgotPassword" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Forgot Password | Hostel Management System</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box;
            font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }

        body { min-height:100vh; display:flex; align-items:center; justify-content:center;
               background:linear-gradient(135deg,#4f46e5 0%,#7c3aed 50%,#9333ea 100%); padding:20px; }

        .card { background:#fff; width:100%; max-width:420px; border-radius:18px;
                box-shadow:0 25px 60px rgba(0,0,0,.25); padding:40px 35px; animation:fadeIn .5s ease; }

        @keyframes fadeIn { from{opacity:0;transform:translateY(15px);} to{opacity:1;transform:translateY(0);} }

        .brand { text-align:center; margin-bottom:24px; }
        .brand .logo { width:64px; height:64px; margin:0 auto 14px;
            background:linear-gradient(135deg,#4f46e5,#9333ea); border-radius:16px;
            display:flex; align-items:center; justify-content:center; font-size:28px; color:#fff;
            box-shadow:0 8px 20px rgba(79,70,229,.4); }
        .brand h1 { font-size:21px; color:#1f2937; font-weight:700; }
        .brand p  { font-size:13px; color:#6b7280; margin-top:6px; line-height:1.4; }

        .form-group { margin-bottom:18px; }
        .form-group label { display:block; font-size:13px; font-weight:600; color:#374151; margin-bottom:6px; }

        .input-icon { position:relative; }
        .input-icon span { position:absolute; left:14px; top:50%; transform:translateY(-50%);
            font-size:16px; color:#9ca3af; }
        .input-icon input { width:100%; padding:12px 14px 12px 42px; border:1.5px solid #e5e7eb;
            border-radius:10px; font-size:14px; color:#1f2937; transition:all .2s ease; outline:none; }
        .input-icon input:focus { border-color:#7c3aed; box-shadow:0 0 0 3px rgba(124,58,237,.15); }

        .btn { width:100%; padding:13px; border:none; border-radius:10px;
            background:linear-gradient(135deg,#4f46e5,#9333ea); color:#fff; font-size:15px;
            font-weight:600; cursor:pointer; transition:all .25s ease; }
        .btn:hover { transform:translateY(-2px); box-shadow:0 10px 25px rgba(124,58,237,.4); }

        .msg { text-align:center; font-size:13px; margin-top:14px; min-height:16px; color:#dc2626; }
        .msg.success { color:#16a34a; }

        .links { text-align:center; font-size:13px; color:#6b7280; margin-top:20px; }
        .links a { color:#7c3aed; text-decoration:none; font-weight:600; }
        .links a:hover { text-decoration:underline; }

        .step-tag { text-align:center; font-size:12px; color:#9ca3af; margin-bottom:18px;
            letter-spacing:.5px; text-transform:uppercase; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="card">

            <div class="brand">
                <div class="logo">&#128274;</div>
                <h1>Reset Password</h1>
                <p>We'll help you get back into your account.</p>
            </div>

            <!-- STEP 1: Enter email -->
            <asp:Panel ID="pnlEmail" runat="server">
                <div class="step-tag">Step 1 of 3</div>
                <div class="form-group">
                    <label for="txtEmail">Registered Email</label>
                    <div class="input-icon">
                        <span>&#9993;</span>
                        <asp:TextBox ID="txtEmail" runat="server" TextMode="Email"
                                     placeholder="you@example.com"></asp:TextBox>
                    </div>
                </div>
                <asp:Button ID="btnSendOtp" runat="server" CssClass="btn"
                            Text="Send OTP" OnClick="btnSendOtp_Click" />
            </asp:Panel>

            <!-- STEP 2: Enter OTP -->
            <asp:Panel ID="pnlOtp" runat="server" Visible="false">
                <div class="step-tag">Step 2 of 3</div>
                <div class="form-group">
                    <label for="txtOtp">Enter OTP</label>
                    <div class="input-icon">
                        <span>&#128273;</span>
                        <asp:TextBox ID="txtOtp" runat="server" MaxLength="6"
                                     placeholder="6-digit code"></asp:TextBox>
                    </div>
                </div>
                <asp:Button ID="btnVerifyOtp" runat="server" CssClass="btn"
                            Text="Verify OTP" OnClick="btnVerifyOtp_Click" />
                <div class="links">
                    Didn't get it?
                    <asp:LinkButton ID="btnResendOtp" runat="server"
                                    OnClick="btnResendOtp_Click">Resend OTP</asp:LinkButton>
                </div>
            </asp:Panel>

            <!-- STEP 3: Set new password -->
            <asp:Panel ID="pnlReset" runat="server" Visible="false">
                <div class="step-tag">Step 3 of 3</div>
                <div class="form-group">
                    <label for="txtNewPassword">New Password</label>
                    <div class="input-icon">
                        <span>&#128274;</span>
                        <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password"
                                     placeholder="At least 8 characters"></asp:TextBox>
                    </div>
                </div>
                <div class="form-group">
                    <label for="txtConfirmPassword">Confirm Password</label>
                    <div class="input-icon">
                        <span>&#128274;</span>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password"
                                     placeholder="Re-enter new password"></asp:TextBox>
                    </div>
                </div>
                <asp:Button ID="btnResetPassword" runat="server" CssClass="btn"
                            Text="Reset Password" OnClick="btnResetPassword_Click" />
            </asp:Panel>

            <asp:Label ID="lblMessage" runat="server" CssClass="msg"></asp:Label>

            <div class="links">
                <a href="Login.aspx">&#8592; Back to Login</a>
            </div>

        </div>
    </form>
</body>
</html>
