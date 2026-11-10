<%@ Page Title="Expenses" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Expenses.aspx.cs" Inherits="HostelManagement.Expenses" %>

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

        .card {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 22px;
            box-shadow: var(--shadow);
        }

        .date-row {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 8px;
        }

            .date-row label {
                font-size: 14px;
                font-weight: 600;
                color: var(--text);
            }

            .date-row input {
                padding: 10px 13px;
                border: 1.5px solid var(--border);
                border-radius: 9px;
                font-size: 14px;
                color: var(--text);
                background: var(--bg);
                outline: none;
                font-family: inherit;
            }

        .lock-note {
            font-size: 13px;
            font-weight: 600;
            color: #d85a30;
            margin-bottom: 14px;
            display: none;
        }

            .lock-note.show {
                display: block;
            }

        .exp-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }

            .exp-table th {
                text-align: left;
                font-size: 12px;
                text-transform: uppercase;
                letter-spacing: .4px;
                color: var(--text-muted);
                font-weight: 600;
                padding: 11px 12px;
                border-bottom: 1px solid var(--border);
            }

            .exp-table td {
                padding: 7px 10px;
                border-bottom: 1px solid var(--border);
            }

            .exp-table .sl {
                text-align: center;
                font-weight: 600;
                color: var(--text-muted);
                width: 52px;
            }

            .exp-table input {
                width: 100%;
                padding: 9px 11px;
                border: 1.5px solid var(--border);
                border-radius: 8px;
                font-size: 14px;
                color: var(--text);
                background: var(--bg);
                outline: none;
                font-family: inherit;
            }

                .exp-table input:focus {
                    border-color: var(--primary);
                    box-shadow: 0 0 0 3px rgba(124,58,237,.15);
                }

                .exp-table input.amt {
                    background: var(--hover);
                    color: var(--text);
                    font-weight: 600;
                    text-align: right;
                }

                .exp-table input:disabled {
                    opacity: .7;
                    cursor: not-allowed;
                }

            .exp-table td.num {
                width: 130px;
            }

            .exp-table td.act {
                width: 44px;
                text-align: center;
            }

        .rm {
            background: none;
            border: none;
            color: #dc2626;
            font-size: 18px;
            line-height: 1;
            cursor: pointer;
            padding: 4px 8px;
        }

            .rm:hover {
                opacity: .7;
            }

        tfoot td {
            padding: 14px 12px;
            font-size: 15px;
            font-weight: 700;
            color: var(--text);
            border-top: 2px solid var(--border);
        }

        tfoot .total-label {
            text-align: right;
        }

        tfoot .total-val {
            text-align: right;
            color: var(--primary);
        }

        .footer-actions {
            margin-top: 18px;
            display: flex;
            gap: 12px;
            align-items: center;
        }

        .btn-add {
            padding: 11px 20px;
            border: 1.5px dashed var(--primary);
            border-radius: 10px;
            background: transparent;
            color: var(--primary);
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
        }

            .btn-add:hover {
                background: var(--hover);
            }

        .btn-save {
            padding: 11px 26px;
            border: none;
            border-radius: 10px;
            background: var(--primary-grad);
            color: #fff;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
        }

        .msg {
            font-size: 13px;
            font-weight: 600;
        }

            .msg.success {
                color: #16a34a;
            }

            .msg.error {
                color: #dc2626;
            }
    </style>
</asp:Content>

<asp:Content ID="cphMain" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-head">
        <h2>Expenses</h2>
        <p>Record day-wise expenses.</p>
    </div>

    <asp:HiddenField ID="hfRows" runat="server" />

    <div class="card">
        <div class="date-row">
            <label>Date:</label>
            <asp:TextBox ID="txtDate" runat="server" TextMode="Date" AutoPostBack="true"
                OnTextChanged="txtDate_Changed"></asp:TextBox>
        </div>
        <div id="lockNote" class="lock-note">This date already has expenses. Only an admin can edit them.</div>

        <table class="exp-table">
            <thead>
                <tr>
                    <th class="sl">Sl.No</th>
                    <th>Item Name</th>
                    <th>Supplier</th>
                    <th>Quantity</th>
                    <th>Price</th>
                    <th>Amount</th>
                    <th></th>
                </tr>
            </thead>
            <tbody id="expBody"></tbody>
            <tfoot>
                <tr>
                    <td colspan="5" class="total-label">Total</td>
                    <td class="total-val"><span id="grandTotal">0</span></td>
                    <td></td>
                </tr>
            </tfoot>
        </table>

        <datalist id="itemsList"></datalist>

        <div class="footer-actions">
            <button type="button" id="btnAddRow" class="btn-add" onclick="addRow()">+ Add New Row</button>
            <asp:Button ID="btnSave" runat="server" CssClass="btn-save" Text="Save"
                OnClientClick="return collectAndSave();" OnClick="btnSave_Click" />
            <asp:Label ID="lblMsg" runat="server" CssClass="msg"></asp:Label>
        </div>
    </div>

    <!-- Server injects: var LOADED = [...]; var CAN_EDIT = true/false; -->
    <asp:Literal ID="litData" runat="server"></asp:Literal>
    <!-- Server injects: var ITEMS = [...]; (searchable dropdown source) -->
    <asp:Literal ID="litItems" runat="server"></asp:Literal>

    <script>
        function rowHtml() {
            return '<td class="sl"></td>' +
                '<td><input type="text" class="item" list="itemsList" placeholder="Select item" onchange="fillSupplier(this)" /></td>' +
                '<td><input type="text" class="supplier" placeholder="Supplier" /></td>' +
                '<td class="num"><input type="number" class="qty" min="0" oninput="calcRow(this)" /></td>' +
                '<td class="num"><input type="number" class="price" min="0" step="0.01" oninput="calcRow(this)" /></td>' +
                '<td class="num"><input type="number" class="amt" readonly /></td>' +
                '<td class="act"><button type="button" class="rm" onclick="removeRow(this)">&times;</button></td>';
        }

        function addRow(item, supplier, qty, price) {
            var tr = document.createElement('tr');
            tr.innerHTML = rowHtml();
            var body = document.getElementById('expBody');
            body.appendChild(tr);
            if (item !== undefined) tr.querySelector('.item').value = item;
            if (supplier !== undefined && supplier !== null) tr.querySelector('.supplier').value = supplier;
            if (qty !== undefined && qty !== null) tr.querySelector('.qty').value = qty;
            if (price !== undefined && price !== null) tr.querySelector('.price').value = price;
            calcRow(tr.querySelector('.qty'));
            renumber();
            applyEditable();
        }

        function removeRow(btn) {
            btn.closest('tr').remove();
            renumber();
            calcTotal();
        }

        function calcRow(input) {
            var tr = input.closest('tr');
            var qty = parseFloat(tr.querySelector('.qty').value) || 0;
            var price = parseFloat(tr.querySelector('.price').value) || 0;
            tr.querySelector('.amt').value = (qty * price) ? (qty * price).toFixed(2) : '';
            calcTotal();
        }

        function calcTotal() {
            var total = 0;
            document.querySelectorAll('#expBody .amt').forEach(function (a) { total += parseFloat(a.value) || 0; });
            document.getElementById('grandTotal').innerText = total.toLocaleString('en-IN', { minimumFractionDigits: 0 });
        }

        function renumber() {
            document.querySelectorAll('#expBody tr').forEach(function (tr, i) { tr.querySelector('.sl').innerText = (i + 1); });
        }

        // Disable everything when the current user can't edit this date.
        function applyEditable() {
            if (typeof CAN_EDIT !== 'undefined' && CAN_EDIT === false) {
                document.querySelectorAll('#expBody input').forEach(function (i) { i.disabled = true; });
                document.querySelectorAll('#expBody .rm').forEach(function (b) { b.style.display = 'none'; });
                var add = document.getElementById('btnAddRow'); if (add) add.style.display = 'none';
            }
        }

        // Serialize grid -> hidden field before the Save postback.
        function collectAndSave() {
            var rows = [];
            var missingSupplier = false;
            document.querySelectorAll('#expBody tr').forEach(function (tr) {
                var item = tr.querySelector('.item').value.trim();
                var supplier = tr.querySelector('.supplier').value.trim();
                var qty = tr.querySelector('.qty').value;
                var price = tr.querySelector('.price').value;
                var hasAny = (item !== '' || supplier !== '' || qty !== '' || price !== '');
                if (!hasAny) return;                 // skip fully empty rows
                if (item !== '' && supplier === '') { missingSupplier = true; }
                rows.push({ item: item, supplier: supplier, qty: parseFloat(qty) || 0, price: parseFloat(price) || 0 });
            });

            if (missingSupplier) {
                alert('Supplier is required for every item row.');
                return false;
            }

            document.getElementById('<%= hfRows.ClientID %>').value = JSON.stringify(rows);
            return true;
        }

        // Auto-fill the supplier from the item master when an item is chosen.
        // Only fills when supplier is empty, so a manual change isn't overwritten.
        function fillSupplier(itemInput) {
            var tr = itemInput.closest('tr');
            var sup = tr.querySelector('.supplier');
            if (!sup) return;
            var name = itemInput.value.trim();
            if (typeof ITEM_SUPPLIER !== 'undefined' && ITEM_SUPPLIER.hasOwnProperty(name)) {
                if (sup.value.trim() === '') sup.value = ITEM_SUPPLIER[name];
            }
        }

        function fillItems() {
            var dl = document.getElementById('itemsList');
            if (!dl || typeof ITEMS === 'undefined') return;
            dl.innerHTML = '';
            ITEMS.forEach(function (name) {
                var o = document.createElement('option');
                o.value = name;
                dl.appendChild(o);
            });
        }

        function buildGrid() {
            fillItems();
            var body = document.getElementById('expBody');
            body.innerHTML = '';
            if (typeof LOADED !== 'undefined' && LOADED.length) {
                LOADED.forEach(function (r) { addRow(r.item, r.supplier, r.qty, r.price); });
            } else {
                for (var i = 0; i < 5; i++) addRow();
            }
            if (typeof CAN_EDIT !== 'undefined' && CAN_EDIT === false) {
                document.getElementById('lockNote').classList.add('show');
            }
            applyEditable();
            calcTotal();
        }

        buildGrid();
    </script>

</asp:Content>
