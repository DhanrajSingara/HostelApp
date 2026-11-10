<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="HostelManagement.Login" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Login | Hostel Management System</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 50%, #9333ea 100%);
            padding: 20px;
        }

        .login-wrapper {
            background: #ffffff;
            width: 100%;
            max-width: 420px;
            border-radius: 18px;
            box-shadow: 0 25px 60px rgba(0, 0, 0, 0.25);
            padding: 40px 35px;
            animation: fadeIn 0.5s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(15px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .brand {
            text-align: center;
            margin-bottom: 28px;
        }

        .brand .logo {
            width: 64px;
            height: 64px;
            margin: 0 auto 14px;
            background: linear-gradient(135deg, #4f46e5, #9333ea);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 30px;
            color: #fff;
            box-shadow: 0 8px 20px rgba(79, 70, 229, 0.4);
        }

        .brand h1 {
            font-size: 22px;
            color: #1f2937;
            font-weight: 700;
        }

        .brand p {
            font-size: 13px;
            color: #6b7280;
            margin-top: 4px;
        }

        .form-group {
            margin-bottom: 18px;
        }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #374151;
            margin-bottom: 6px;
        }

        .input-icon {
            position: relative;
        }

        .input-icon span {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 16px;
            color: #9ca3af;
        }

        .input-icon input {
            width: 100%;
            padding: 12px 14px 12px 42px;
            border: 1.5px solid #e5e7eb;
            border-radius: 10px;
            font-size: 14px;
            color: #1f2937;
            transition: all 0.2s ease;
            outline: none;
        }

        .input-icon input:focus {
            border-color: #7c3aed;
            box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.15);
        }

        .row-between {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 22px;
            font-size: 13px;
        }

        .row-between label {
            color: #4b5563;
            display: flex;
            align-items: center;
            gap: 6px;
            cursor: pointer;
        }

        .row-between a {
            color: #7c3aed;
            text-decoration: none;
            font-weight: 600;
        }

        .row-between a:hover { text-decoration: underline; }

        .btn-login {
            width: 100%;
            padding: 13px;
            border: none;
            border-radius: 10px;
            background: linear-gradient(135deg, #4f46e5, #9333ea);
            color: #fff;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.25s ease;
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(124, 58, 237, 0.4);
        }

        .msg {
            text-align: center;
            font-size: 13px;
            margin-top: 14px;
            min-height: 16px;
            color: #dc2626;
        }

        .footer-text {
            text-align: center;
            font-size: 13px;
            color: #6b7280;
            margin-top: 22px;
        }

        .footer-text a {
            color: #7c3aed;
            text-decoration: none;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-wrapper">
            <div class="brand">
                <div class="logo">&#127979;</div>
                <h1>Hostel Management</h1>
                <p>Sign in to continue to your dashboard</p>
            </div>

            <div class="form-group">
                <label for="txtUsername">Username</label>
                <div class="input-icon">
                    <span>&#128100;</span>
                    <asp:TextBox ID="txtUsername" runat="server" autocomplete="off" MaxLength="50" placeholder="Enter your username"></asp:TextBox>
                </div>
            </div>

            <div class="form-group">
                <label for="txtPassword">Password</label>
                <div class="input-icon">
                    <span>&#128274;</span>
                    <asp:TextBox ID="txtPassword" runat="server" autocomplete="off" MaxLength="50" TextMode="Password" placeholder="Enter your password"></asp:TextBox>
                </div>
            </div>

            <div class="row-between">
                <label  style="display:none;">
                    <asp:CheckBox ID="chkRemember" runat="server" />
                    Remember me
                </label>
                <a href="ForgotPassword.aspx">Forgot password?</a>
            </div>

            <asp:Button ID="btnLogin" runat="server" CssClass="btn-login" Text="Sign In" OnClick="btnLogin_Click" />

            <asp:Label ID="lblMessage" runat="server" CssClass="msg"></asp:Label>

            <div class="footer-text" >
                Don't have an account? <a href="Register.aspx">Contact Admin</a>
            </div>
        </div>
    </form>
</body>
</html>
