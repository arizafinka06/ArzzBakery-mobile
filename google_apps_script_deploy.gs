// ============================================================
// ARZZ BAKERY - Google Apps Script Backend
// ============================================================
// Cara deploy:
// 1. Buka Google Spreadsheet, lalu Extensions > Apps Script.
// 2. Paste kode ini, Save, lalu jalankan setupSheet() satu kali.
// 3. Deploy > New deployment > Web app.
//    Execute as: Me, Who has access: Anyone.
// 4. Copy Web App URL ke GoogleSheetsService.scriptUrl di Flutter.
//
// Admin default dibuat saat setupSheet():
// username: admin
// password: admin123
// ============================================================

const USERS_SHEET_NAME = 'Users';
const ORDERS_SHEET_NAME = 'Pesanan';

const USER_HEADERS = [
  'User ID',
  'Nama',
  'Username',
  'Password',
  'Role',
  'Created At',
];

const ORDER_HEADERS = [
  'Order ID',
  'Timestamp',
  'User ID',
  'Username',
  'Nama Pemesan',
  'Nomor Meja',
  'Product ID',
  'Nama Produk',
  'Jumlah',
  'Harga Satuan',
  'Total Item',
  'Total Pesanan',
  'Metode Pembayaran',
];

function setupSheet() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const usersSheet = _getOrCreateSheet(ss, USERS_SHEET_NAME, USER_HEADERS);
  const ordersSheet = _getOrCreateSheet(ss, ORDERS_SHEET_NAME, ORDER_HEADERS);

  _ensureDefaultAdmin(usersSheet);
  usersSheet.autoResizeColumns(1, USER_HEADERS.length);
  ordersSheet.autoResizeColumns(1, ORDER_HEADERS.length);

  Logger.log('Setup selesai. Sheet Users dan Pesanan siap dipakai.');
}

function doGet(e) {
  return _handleRequest(e);
}

function doPost(e) {
  return _handleRequest(e);
}

function _handleRequest(e) {
  try {
    const params = _readParams(e);
    const action = params.action || 'create_order';

    setupSheet();

    if (action === 'ping') {
      return _json({ status: 'success', message: 'Arzz Bakery API running' });
    }
    if (action === 'register') return _register(params);
    if (action === 'login') return _login(params);
    if (action === 'create_order') return _createOrder(params);
    if (action === 'orders') return _getOrders(params);
    if (action === 'users') return _getUsers();

    return _json({ status: 'error', message: 'Action tidak dikenali' });
  } catch (err) {
    return _json({ status: 'error', message: String(err) });
  }
}

function _register(params) {
  _require(params, ['name', 'username', 'password']);

  const sheet = _sheet(USERS_SHEET_NAME);
  const username = String(params.username).trim();
  const existing = _findUserByUsername(username);

  if (existing) {
    return _json({ status: 'error', message: 'Username sudah terdaftar' });
  }

  const user = {
    id: Utilities.getUuid(),
    name: String(params.name).trim(),
    username,
    password: String(params.password),
    role: 'pelanggan',
    createdAt: _now(),
  };

  sheet.appendRow([
    user.id,
    user.name,
    user.username,
    user.password,
    user.role,
    user.createdAt,
  ]);

  return _json({ status: 'success', message: 'Akun berhasil dibuat', user });
}

function _login(params) {
  _require(params, ['username', 'password']);

  const user = _findUserByUsername(String(params.username).trim());
  if (!user || user.password !== String(params.password)) {
    return _json({ status: 'error', message: 'Username atau password salah' });
  }

  return _json({
    status: 'success',
    user: {
      id: user.id,
      name: user.name,
      username: user.username,
      password: user.password,
      role: user.role,
    },
  });
}

function _createOrder(params) {
  _require(params, [
    'user_id',
    'username',
    'customer_name',
    'table_number',
    'total_amount',
    'payment_method',
    'items',
  ]);

  const sheet = _sheet(ORDERS_SHEET_NAME);
  const items = JSON.parse(decodeURIComponent(params.items));
  const orderId = Utilities.getUuid();
  const timestamp = _now();
  const total = Number(params.total_amount);

  items.forEach((item, index) => {
    sheet.appendRow([
      orderId,
      index === 0 ? timestamp : '',
      index === 0 ? params.user_id : '',
      index === 0 ? params.username : '',
      index === 0 ? params.customer_name : '',
      index === 0 ? params.table_number : '',
      item.product_id || '',
      item.product_name,
      Number(item.quantity),
      Number(item.price),
      Number(item.total),
      index === 0 ? total : '',
      index === 0 ? params.payment_method : '',
    ]);
  });

  sheet.autoResizeColumns(1, ORDER_HEADERS.length);
  return _json({ status: 'success', message: 'Pesanan tersimpan', order_id: orderId });
}

function _getOrders(params) {
  const rows = _rowsAsObjects(_sheet(ORDERS_SHEET_NAME));
  const ordersById = {};
  let activeHeader = null;

  rows.forEach((row) => {
    if (row['Order ID']) {
      activeHeader = row;
    }
    if (!activeHeader || !row['Nama Produk']) return;

    const orderId = activeHeader['Order ID'];
    if (!ordersById[orderId]) {
      ordersById[orderId] = {
        id: orderId,
        timestamp: activeHeader['Timestamp'],
        userId: activeHeader['User ID'],
        username: activeHeader['Username'],
        customerName: activeHeader['Nama Pemesan'],
        tableNumber: activeHeader['Nomor Meja'],
        totalAmount: Number(activeHeader['Total Pesanan'] || 0),
        paymentMethod: activeHeader['Metode Pembayaran'],
        items: [],
      };
    }

    ordersById[orderId].items.push({
      productId: row['Product ID'],
      productName: row['Nama Produk'],
      quantity: Number(row['Jumlah'] || 0),
      price: Number(row['Harga Satuan'] || 0),
      total: Number(row['Total Item'] || 0),
    });
  });

  let orders = Object.keys(ordersById).map((id) => ordersById[id]);
  if (params.user_id) {
    orders = orders.filter((order) => order.userId === params.user_id);
  }

  orders.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
  return _json({ status: 'success', orders });
}

function _getUsers() {
  const users = _rowsAsObjects(_sheet(USERS_SHEET_NAME)).map((row) => ({
    id: row['User ID'],
    name: row['Nama'],
    username: row['Username'],
    password: row['Password'],
    role: row['Role'],
  }));
  return _json({ status: 'success', users });
}

function _getOrCreateSheet(ss, name, headers) {
  let sheet = ss.getSheetByName(name);
  if (!sheet) sheet = ss.insertSheet(name);

  if (sheet.getLastRow() === 0) {
    sheet.appendRow(headers);
  } else {
    const currentHeaders = sheet.getRange(1, 1, 1, headers.length).getValues()[0];
    const isDifferent = headers.some((header, index) => currentHeaders[index] !== header);
    if (isDifferent) {
      sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
    }
  }

  const headerRange = sheet.getRange(1, 1, 1, headers.length);
  headerRange.setBackground('#6D4C41');
  headerRange.setFontColor('#FFFFFF');
  headerRange.setFontWeight('bold');
  headerRange.setHorizontalAlignment('center');
  sheet.setFrozenRows(1);

  return sheet;
}

function _ensureDefaultAdmin(sheet) {
  if (_findUserByUsername('admin')) return;
  sheet.appendRow([
    Utilities.getUuid(),
    'Administrator',
    'admin',
    'admin123',
    'admin',
    _now(),
  ]);
}

function _findUserByUsername(username) {
  const users = _rowsAsObjects(_sheet(USERS_SHEET_NAME));
  const normalized = String(username).toLowerCase();
  return users.find((user) => String(user['Username']).toLowerCase() === normalized)
    ? {
        id: users.find((user) => String(user['Username']).toLowerCase() === normalized)['User ID'],
        name: users.find((user) => String(user['Username']).toLowerCase() === normalized)['Nama'],
        username: users.find((user) => String(user['Username']).toLowerCase() === normalized)['Username'],
        password: users.find((user) => String(user['Username']).toLowerCase() === normalized)['Password'],
        role: users.find((user) => String(user['Username']).toLowerCase() === normalized)['Role'],
      }
    : null;
}

function _rowsAsObjects(sheet) {
  const values = sheet.getDataRange().getValues();
  if (values.length <= 1) return [];

  const headers = values[0];
  return values.slice(1).map((row) => {
    const obj = {};
    headers.forEach((header, index) => {
      obj[header] = row[index];
    });
    return obj;
  });
}

function _sheet(name) {
  return SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name);
}

function _readParams(e) {
  if (e && e.postData && e.postData.contents) {
    const body = String(e.postData.contents).trim();
    if (body.charAt(0) === '{' || body.charAt(0) === '[') {
      return JSON.parse(body);
    }
  }
  return (e && e.parameter) || {};
}

function _require(params, fields) {
  fields.forEach((field) => {
    if (params[field] === undefined || params[field] === null || params[field] === '') {
      throw new Error('Parameter "' + field + '" wajib diisi');
    }
  });
}

function _now() {
  return new Date().toISOString();
}

function _json(obj) {
  return ContentService
    .createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}

function testDoGet() {
  const result = doGet({
    parameter: {
      action: 'ping',
    },
  });
  Logger.log(result.getContent());
}
