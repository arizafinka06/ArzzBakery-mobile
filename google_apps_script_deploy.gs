// ============================================================
// ARZZ BAKERY - Google Apps Script Backend  v2
// ============================================================
// PERUBAHAN v2:
//   - Sheet Pesanan: 1 baris per order, kolom "Items JSON" menyimpan
//     seluruh item dalam satu sel → tidak ada masalah urutan data lagi.
//   - Sheet Users: satu baris per user (sama seperti sebelumnya).
//   - Sheet Laporan dihapus → fitur cetak PDF cukup dari data Pesanan.
//
// Cara deploy (ulang):
//   1. Buka Google Spreadsheet baru (kosong), Extensions > Apps Script.
//   2. Paste kode ini, Save, lalu jalankan setupSheet() satu kali.
//   3. Deploy > New deployment > Web app.
//      Execute as: Me, Who has access: Anyone.
//   4. Copy URL baru ke GoogleSheetsService.scriptUrl di Flutter.
//
// Admin default: username=admin, password=admin123
// ============================================================

const USERS_SHEET_NAME  = 'Users';
const ORDERS_SHEET_NAME = 'Pesanan';

// ---------- Headers ----------
const USER_HEADERS = [
  'User ID',     // A
  'Nama',        // B
  'Username',    // C
  'Password',    // D
  'Role',        // E
  'Created At',  // F
];

// Satu baris = satu order penuh. Items disimpan sebagai JSON string di kolom terakhir.
const ORDER_HEADERS = [
  'No',                 // A – nomor urut otomatis
  'Order ID',           // B
  'Timestamp',          // C
  'User ID',            // D
  'Username',           // E
  'Nama Pemesan',       // F
  'Nomor Meja',         // G
  'Total Pesanan',      // H
  'Metode Pembayaran',  // I
  'Items JSON',         // J  ← JSON: [{productId,productName,quantity,price,total}]
];

// ============================================================
// SETUP
// ============================================================
function setupSheet() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const usersSheet  = _getOrCreateSheet(ss, USERS_SHEET_NAME,  USER_HEADERS);
  const ordersSheet = _getOrCreateSheet(ss, ORDERS_SHEET_NAME, ORDER_HEADERS);

  _ensureDefaultAdmin(usersSheet);
  usersSheet.autoResizeColumns(1, USER_HEADERS.length);
  ordersSheet.autoResizeColumns(1, ORDER_HEADERS.length);

  Logger.log('Setup v2 selesai. Sheet Users & Pesanan (skema baru) siap.');
}

// ============================================================
// HTTP ENTRY POINTS
// ============================================================
function doGet(e)  { return _handleRequest(e); }
function doPost(e) { return _handleRequest(e); }

function _handleRequest(e) {
  try {
    const params = _readParams(e);
    const action = params.action || 'ping';

    setupSheet();

    if (action === 'ping')         return _json({ status: 'success', message: 'Arzz Bakery API v2 running' });
    if (action === 'register')     return _register(params);
    if (action === 'login')        return _login(params);
    if (action === 'create_order') return _createOrder(params);
    if (action === 'orders')       return _getOrders(params);
    if (action === 'users')        return _getUsers();

    return _json({ status: 'error', message: 'Action tidak dikenali: ' + action });
  } catch (err) {
    return _json({ status: 'error', message: String(err) });
  }
}

// ============================================================
// AUTH
// ============================================================
function _register(params) {
  _require(params, ['name', 'username', 'password']);

  const username = String(params.username).trim();
  if (_findUserByUsername(username)) {
    return _json({ status: 'error', message: 'Username sudah terdaftar' });
  }

  const user = {
    id:        Utilities.getUuid(),
    name:      String(params.name).trim(),
    username,
    password:  String(params.password),
    role:      'pelanggan',
    createdAt: _now(),
  };

  _sheet(USERS_SHEET_NAME).appendRow([
    user.id, user.name, user.username,
    user.password, user.role, user.createdAt,
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
    user: { id: user.id, name: user.name, username: user.username,
            password: user.password, role: user.role },
  });
}

// ============================================================
// ORDERS  –  1 BARIS PER ORDER
// ============================================================
function _createOrder(params) {
  _require(params, ['user_id','username','customer_name',
                    'table_number','total_amount','payment_method','items']);

  const sheet    = _sheet(ORDERS_SHEET_NAME);
  const orderId  = Utilities.getUuid();
  const timestamp = _now();
  const total    = Number(params.total_amount);
  const items    = JSON.parse(decodeURIComponent(params.items));

  // Nomor urut = baris data terakhir + 1 (baris 1 = header)
  const nextNo = sheet.getLastRow();   // header is row 1, so lastRow = count of data + 1 before append

  sheet.appendRow([
    nextNo,                          // No
    orderId,                         // Order ID
    timestamp,                       // Timestamp (ISO string)
    String(params.user_id),          // User ID
    String(params.username),         // Username
    String(params.customer_name),    // Nama Pemesan
    String(params.table_number),     // Nomor Meja
    total,                           // Total Pesanan
    String(params.payment_method),   // Metode Pembayaran
    JSON.stringify(items),           // Items JSON
  ]);

  sheet.autoResizeColumns(1, ORDER_HEADERS.length);
  return _json({ status: 'success', message: 'Pesanan tersimpan', order_id: orderId });
}

function _getOrders(params) {
  const rows = _rowsAsObjects(_sheet(ORDERS_SHEET_NAME));

  const orders = rows
    .filter(row => row['Order ID'])   // skip empty rows
    .map(row => {
      // Konversi timestamp ke ISO string
      let ts = row['Timestamp'];
      if (ts instanceof Date) {
        ts = ts.toISOString();
      } else {
        const parsed = new Date(String(ts || ''));
        ts = !isNaN(parsed.getTime()) ? parsed.toISOString() : new Date().toISOString();
      }

      // Parse items JSON
      let items = [];
      try {
        const raw = String(row['Items JSON'] || '[]');
        items = JSON.parse(raw);
      } catch (_) { items = []; }

      return {
        id:            String(row['Order ID']          || ''),
        timestamp:     ts,
        userId:        String(row['User ID']           || ''),
        username:      String(row['Username']          || ''),
        customerName:  String(row['Nama Pemesan']      || ''),
        tableNumber:   String(row['Nomor Meja']        || ''),
        totalAmount:   Number(row['Total Pesanan']     || 0),
        paymentMethod: String(row['Metode Pembayaran'] || ''),
        items,
      };
    });

  // Filter per user jika diminta
  let result = params.user_id
    ? orders.filter(o => o.userId === params.user_id)
    : orders;

  // Urutkan: terbaru dulu
  result.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

  return _json({ status: 'success', orders: result });
}

// ============================================================
// USERS
// ============================================================
function _getUsers() {
  const users = _rowsAsObjects(_sheet(USERS_SHEET_NAME))
    .filter(row => row['User ID'])
    .map(row => ({
      id:       String(row['User ID']  || ''),
      name:     String(row['Nama']     || ''),
      username: String(row['Username'] || ''),
      password: String(row['Password'] || ''),
      role:     String(row['Role']     || 'pelanggan'),
    }));
  return _json({ status: 'success', users });
}

// ============================================================
// HELPERS
// ============================================================
function _getOrCreateSheet(ss, name, headers) {
  let sheet = ss.getSheetByName(name);
  if (!sheet) sheet = ss.insertSheet(name);

  if (sheet.getLastRow() === 0) {
    sheet.appendRow(headers);
  } else {
    // Update header jika berubah
    const cur = sheet.getRange(1, 1, 1, headers.length).getValues()[0];
    if (headers.some((h, i) => cur[i] !== h)) {
      sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
    }
  }

  const rng = sheet.getRange(1, 1, 1, headers.length);
  rng.setBackground('#6D4C41');
  rng.setFontColor('#FFFFFF');
  rng.setFontWeight('bold');
  rng.setHorizontalAlignment('center');
  sheet.setFrozenRows(1);

  return sheet;
}

function _ensureDefaultAdmin(sheet) {
  if (_findUserByUsername('admin')) return;
  sheet.appendRow([
    Utilities.getUuid(), 'Administrator', 'admin', 'admin123', 'admin', _now(),
  ]);
}

function _findUserByUsername(username) {
  const normalized = String(username).toLowerCase();
  const found = _rowsAsObjects(_sheet(USERS_SHEET_NAME))
    .find(u => String(u['Username']).toLowerCase() === normalized);
  if (!found) return null;
  return {
    id: found['User ID'], name: found['Nama'],
    username: found['Username'], password: found['Password'], role: found['Role'],
  };
}

function _rowsAsObjects(sheet) {
  const values = sheet.getDataRange().getValues();
  if (values.length <= 1) return [];
  const headers = values[0];
  return values.slice(1).map(row => {
    const obj = {};
    headers.forEach((h, i) => { obj[h] = row[i]; });
    return obj;
  });
}

function _sheet(name) {
  return SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name);
}

function _readParams(e) {
  if (e && e.postData && e.postData.contents) {
    const body = String(e.postData.contents).trim();
    if (body[0] === '{' || body[0] === '[') return JSON.parse(body);
  }
  return (e && e.parameter) || {};
}

function _require(params, fields) {
  fields.forEach(f => {
    if (params[f] === undefined || params[f] === null || String(params[f]).trim() === '') {
      throw new Error('Parameter "' + f + '" wajib diisi');
    }
  });
}

function _now() {
  // Format waktu sesuai zona waktu script (default Asia/Jakarta jika diatur di script properties)
  return Utilities.formatDate(new Date(), Session.getScriptTimeZone(), "yyyy-MM-dd HH:mm:ss");
}

function _json(obj) {
  return ContentService
    .createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}

// ============================================================
// TEST
// ============================================================
function testPing() {
  Logger.log(doGet({ parameter: { action: 'ping' } }).getContent());
}

// ============================================================
// SEED DATA – Jalankan SATU KALI dari editor Apps Script
// (Run > seedDummyData)
// Mengisi 15 pesanan dummy di berbagai Hari Minggu lintas bulan.
// ============================================================
function seedDummyData() {
  setupSheet();

  // ── 1. SEED USERS ────────────────────────────────────────────────
  const usersSheet = _sheet(USERS_SHEET_NAME);
  const DUMMY_USERS = [
    { id:'uid-nanda-001',  name:'Nanda',  username:'nanda01',  password:'nanda123',  role:'pelanggan' },
    { id:'uid-ariza-002',  name:'Ariza',  username:'ariza02',  password:'ariza123',  role:'pelanggan' },
    { id:'uid-fira-003',   name:'Fira',   username:'fira03',   password:'fira123',   role:'pelanggan' },
    { id:'uid-cipung-004', name:'Cipung', username:'cipung04', password:'cipung123', role:'pelanggan' },
    { id:'uid-anggih-005', name:'Anggih', username:'anggih05', password:'anggih123', role:'pelanggan' },
    { id:'uid-nnanda-006', name:'Nnanda', username:'nnanda06', password:'nnanda123', role:'pelanggan' },
    { id:'uid-rona-007',   name:'Rona',   username:'rona07',   password:'rona123',   role:'pelanggan' },
  ];

  let usersAdded = 0;
  DUMMY_USERS.forEach(u => {
    // Cek duplikat sebelum insert
    if (!_findUserByUsername(u.username)) {
      usersSheet.appendRow([u.id, u.name, u.username, u.password, u.role, _now()]);
      usersAdded++;
    }
  });
  usersSheet.autoResizeColumns(1, USER_HEADERS.length);
  Logger.log('Users ditambahkan: ' + usersAdded);

  // ── 2. SEED ORDERS ───────────────────────────────────────────────
  const sheet = _sheet(ORDERS_SHEET_NAME);

  // Daftar nama pelanggan (rotasi)
  const names = ['Nanda', 'Ariza', 'Fira', 'Cipung', 'Anggih', 'Nnanda', 'Rona'];

  // Daftar username masing-masing (lebih pendek)
  const usernames = ['nanda01', 'ariza02', 'fira03', 'cipung04', 'anggih05', 'nnanda06', 'rona07'];

  // User ID dummy (cukup fixed uuid-like string)
  const userIds = [
    'uid-nanda-001', 'uid-ariza-002', 'uid-fira-003',
    'uid-cipung-004', 'uid-anggih-005', 'uid-nnanda-006', 'uid-rona-007',
  ];

  // Menu produk Arzz Bakery (id, nama, harga)
  const PRODUCTS = [
    { id:'1',  name:'Danish Blueberry',           price:25000 },
    { id:'2',  name:'Kouign-Amann',                price:30000 },
    { id:'3',  name:'Pain Suisse',                 price:27000 },
    { id:'4',  name:'Chocolate Ganache Tart',       price:35000 },
    { id:'5',  name:'Financier',                   price:20000 },
    { id:'8',  name:'Almond Croissant',             price:28000 },
    { id:'10', name:'Cinnamon Roll',                price:22000 },
    { id:'11', name:'Banana Bread',                 price:18000 },
    { id:'13', name:'Chicken Mayo Sandwich',        price:30000 },
    { id:'15', name:'Blueberry Muffin',             price:35000 },
    { id:'17', name:'Taro Cake',                    price:25000 },
    { id:'19', name:'New York Cheesecake',          price:55000 },
    { id:'21', name:'Chocolate Indulgence',         price:30000 },
    { id:'22', name:'Japanese Cotton Cheesecake',   price:35000 },
    { id:'26', name:'Oreo Cheesecake',              price:45000 },
    { id:'28', name:'Red Velvet Cake',              price:25000 },
    { id:'30', name:'Cherry Cake',                  price:25000 },
  ];

  // 15 pesanan dummy — hari Minggu dari bulan berbeda (2025-2026)
  // Format timestamp: ISO string dengan jam yang bervariasi
  const ORDERS_SEED = [
    // ── Januari 2026 ─────────────────────────────────────────────
    {
      date: '2026-01-04T08:32:00.000Z', meja: '3',
      payment: 'Tunai',
      items: [
        { idx:0, qty:2 }, { idx:4, qty:1 }, { idx:7, qty:3 },
      ],
    },
    {
      date: '2026-01-11T10:15:00.000Z', meja: '1',
      payment: 'QRIS',
      items: [
        { idx:11, qty:1 }, { idx:9, qty:2 },
      ],
    },
    {
      date: '2026-01-25T09:05:00.000Z', meja: '5',
      payment: 'Tunai',
      items: [
        { idx:15, qty:2 }, { idx:6, qty:1 }, { idx:2, qty:2 },
      ],
    },
    // ── Februari 2026 ────────────────────────────────────────────
    {
      date: '2026-02-01T11:40:00.000Z', meja: '2',
      payment: 'QRIS',
      items: [
        { idx:8, qty:1 }, { idx:13, qty:2 }, { idx:5, qty:1 },
      ],
    },
    {
      date: '2026-02-08T13:20:00.000Z', meja: '4',
      payment: 'Tunai',
      items: [
        { idx:3, qty:1 }, { idx:14, qty:1 }, { idx:10, qty:2 },
      ],
    },
    {
      date: '2026-02-22T09:50:00.000Z', meja: '6',
      payment: 'QRIS',
      items: [
        { idx:16, qty:2 }, { idx:1, qty:1 },
      ],
    },
    // ── Maret 2026 ───────────────────────────────────────────────
    {
      date: '2026-03-08T10:00:00.000Z', meja: '1',
      payment: 'Tunai',
      items: [
        { idx:0, qty:1 }, { idx:9, qty:1 }, { idx:12, qty:2 },
      ],
    },
    {
      date: '2026-03-15T14:30:00.000Z', meja: '3',
      payment: 'QRIS',
      items: [
        { idx:4, qty:3 }, { idx:7, qty:1 },
      ],
    },
    {
      date: '2026-03-29T08:10:00.000Z', meja: '2',
      payment: 'Tunai',
      items: [
        { idx:11, qty:1 }, { idx:15, qty:2 }, { idx:6, qty:1 },
      ],
    },
    // ── April 2026 ───────────────────────────────────────────────
    {
      date: '2026-04-05T12:00:00.000Z', meja: '7',
      payment: 'QRIS',
      items: [
        { idx:13, qty:2 }, { idx:8, qty:1 }, { idx:2, qty:1 },
      ],
    },
    {
      date: '2026-04-12T10:45:00.000Z', meja: '4',
      payment: 'Tunai',
      items: [
        { idx:3, qty:1 }, { idx:16, qty:3 },
      ],
    },
    {
      date: '2026-04-26T09:25:00.000Z', meja: '2',
      payment: 'QRIS',
      items: [
        { idx:14, qty:1 }, { idx:10, qty:2 }, { idx:0, qty:2 },
      ],
    },
    // ── Mei 2026 ─────────────────────────────────────────────────
    {
      date: '2026-05-03T11:10:00.000Z', meja: '5',
      payment: 'Tunai',
      items: [
        { idx:1, qty:2 }, { idx:9, qty:1 }, { idx:5, qty:2 },
      ],
    },
    {
      date: '2026-05-17T13:55:00.000Z', meja: '3',
      payment: 'QRIS',
      items: [
        { idx:12, qty:1 }, { idx:7, qty:2 }, { idx:15, qty:1 },
      ],
    },
    // ── Juni 2026 ────────────────────────────────────────────────
    {
      date: '2026-06-07T09:00:00.000Z', meja: '1',
      payment: 'Tunai',
      items: [
        { idx:11, qty:1 }, { idx:4, qty:2 }, { idx:13, qty:1 },
      ],
    },
  ];

  let insertedCount = 0;

  ORDERS_SEED.forEach((order, orderIdx) => {
    const nameIdx  = orderIdx % names.length;
    const custName = names[nameIdx];
    const username = usernames[nameIdx];
    const userId   = userIds[nameIdx];

    // Hitung items
    const itemsArr = order.items.map(it => {
      const prod = PRODUCTS[it.idx];
      return {
        product_id:   prod.id,
        product_name: prod.name,
        quantity:     it.qty,
        price:        prod.price,
        total:        prod.price * it.qty,
      };
    });

    const total = itemsArr.reduce((sum, i) => sum + i.total, 0);
    const orderId = Utilities.getUuid();
    const nextNo  = sheet.getLastRow(); // rows already in sheet (header = row 1)

    sheet.appendRow([
      nextNo,                         // No
      orderId,                        // Order ID
      order.date,                     // Timestamp (ISO string – hari Minggu)
      userId,                         // User ID
      username,                       // Username
      custName,                       // Nama Pemesan
      order.meja,                     // Nomor Meja
      total,                          // Total Pesanan
      order.payment,                  // Metode Pembayaran
      JSON.stringify(itemsArr),       // Items JSON
    ]);

    insertedCount++;
  });

  sheet.autoResizeColumns(1, ORDER_HEADERS.length);
  Logger.log('✅ seedDummyData selesai: ' + insertedCount + ' pesanan ditambahkan.');
  SpreadsheetApp.getUi().alert(
    '✅ Seed Data Selesai!\n\n' +
    '👤 Users ditambahkan : ' + usersAdded + '\n' +
    '🛒 Pesanan ditambahkan: ' + insertedCount
  );
}
