// ============================================================
// ARZZ BAKERY - Google Apps Script Backend
// ============================================================
// CARA DEPLOY:
// 1. Buka Google Spreadsheet baru, beri nama "Arzz Bakery Orders"
// 2. Klik Extensions > Apps Script
// 3. Hapus kode default, paste seluruh kode ini
// 4. Klik Save (Ctrl+S)
// 5. Klik Deploy > New Deployment
//    - Type        : Web App
//    - Execute as  : Me
//    - Who access  : Anyone
// 6. Klik Deploy > copy URL yang muncul
// 7. Paste URL ke main.dart pada variabel 'scriptUrl'
//
// CARA TEST MANUAL (dari editor GAS):
//   - Jalankan fungsi: setupSheet   (bukan initHeaders langsung)
//   - Jalankan fungsi: testDoGet    (simulasi order masuk)
// ============================================================

const SHEET_NAME = 'Pesanan';

// ─── Setup awal: buat/inisialisasi sheet ───────────────────
// Jalankan fungsi ini SATU KALI dari editor GAS setelah paste kode,
// sebelum deploy. Fungsi ini aman dijalankan berulang kali.
function setupSheet() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  let sheet = ss.getSheetByName(SHEET_NAME);

  if (!sheet) {
    sheet = ss.insertSheet(SHEET_NAME);
    Logger.log('Sheet "' + SHEET_NAME + '" dibuat baru.');
  } else {
    Logger.log('Sheet "' + SHEET_NAME + '" sudah ada.');
  }

  if (sheet.getLastRow() === 0) {
    _initHeaders(sheet);
    Logger.log('Header berhasil dibuat.');
  } else {
    Logger.log('Header sudah ada, dilewati.');
  }

  Logger.log('Setup selesai! Silakan Deploy sekarang.');
}

// ─── Fungsi internal inisialisasi header (jangan jalankan langsung) ──
function _initHeaders(sheet) {
  const headers = [
    'No',
    'Timestamp',
    'Nama Pemesan',
    'Nomor Meja',
    'Nama Produk',
    'Jumlah',
    'Harga Satuan',
    'Total Item',
    'Total Pesanan',
    'Metode Pembayaran',
  ];
  sheet.appendRow(headers);

  // Format header: warna coklat, teks putih, bold, center
  const headerRange = sheet.getRange(1, 1, 1, headers.length);
  headerRange.setBackground('#6D4C41');
  headerRange.setFontColor('#FFFFFF');
  headerRange.setFontWeight('bold');
  headerRange.setHorizontalAlignment('center');
  sheet.setFrozenRows(1);
  sheet.autoResizeColumns(1, headers.length);
}

// ─── Helper: ambil atau buat sheet ──────────────────────────
function _getOrCreateSheet() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  let sheet = ss.getSheetByName(SHEET_NAME);

  if (!sheet) {
    sheet = ss.insertSheet(SHEET_NAME);
    _initHeaders(sheet);
  } else if (sheet.getLastRow() === 0) {
    _initHeaders(sheet);
  }

  return sheet;
}

// ─── Helper: simpan baris data ke sheet ─────────────────────
function _saveRows(sheet, params) {
  const items     = JSON.parse(decodeURIComponent(params.items));
  const timestamp = new Date().toLocaleString('id-ID', { timeZone: 'Asia/Jakarta' });
  const total     = parseFloat(params.total_amount);
  const name      = params.customer_name;
  const table     = params.table_number;
  const payment   = params.payment_method || 'Tunai';

  let rowNo = sheet.getLastRow(); // baris 1 = header

  items.forEach((item, i) => {
    rowNo++;
    sheet.appendRow([
      rowNo,
      i === 0 ? timestamp : '',
      i === 0 ? name      : '',
      i === 0 ? table     : '',
      item.product_name,
      item.quantity,
      item.price,
      item.total,
      i === 0 ? total   : '',
      i === 0 ? payment : '',
    ]);
  });

  sheet.autoResizeColumns(1, 10);
  return items.length;
}

// ─── GET handler (dipanggil Flutter via http.get) ───────────
function doGet(e) {
  try {
    const params = e.parameter;

    // Ping / health-check
    if (params.action === 'ping') {
      return _json({ status: 'ok', message: 'Arzz Bakery API running' });
    }

    // Validasi field wajib
    const required = ['customer_name', 'table_number', 'total_amount', 'items'];
    for (const f of required) {
      if (!params[f]) {
        return _json({ status: 'error', message: 'Parameter "' + f + '" tidak ada' });
      }
    }

    const sheet = _getOrCreateSheet();
    const count = _saveRows(sheet, params);

    return _json({ status: 'success', message: 'Pesanan tersimpan', order_count: count });

  } catch (err) {
    return _json({ status: 'error', message: err.toString() });
  }
}

// ─── POST handler (fallback) ─────────────────────────────────
function doPost(e) {
  try {
    let params;
    if (e.postData && e.postData.contents) {
      const data = JSON.parse(e.postData.contents);
      // normalisasi: konversi items array ke JSON string jika perlu
      params = {
        customer_name : data.customer_name,
        table_number  : data.table_number,
        total_amount  : String(data.total_amount),
        payment_method: data.payment_method,
        items         : encodeURIComponent(JSON.stringify(data.items || [])),
      };
    } else {
      params = e.parameter;
    }

    const sheet = _getOrCreateSheet();
    const count = _saveRows(sheet, params);

    return _json({ status: 'success', message: 'Data tersimpan', order_count: count });

  } catch (err) {
    return _json({ status: 'error', message: err.toString() });
  }
}

// ─── Utility: buat JSON response ────────────────────────────
function _json(obj) {
  return ContentService
    .createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}

// ─── Test manual dari editor GAS ────────────────────────────
// Pilih fungsi ini di dropdown lalu klik Run untuk simulasi order masuk
function testDoGet() {
  const fakeItems = JSON.stringify([
    { product_name: 'Croissant', quantity: 2, price: 25000, total: 50000 },
    { product_name: 'Mango Cheesecake', quantity: 1, price: 35000, total: 35000 },
  ]);

  const fakeEvent = {
    parameter: {
      customer_name : 'Tes User',
      table_number  : '5',
      total_amount  : '85000',
      payment_method: 'QRIS',
      items         : encodeURIComponent(fakeItems),
    }
  };

  const result = doGet(fakeEvent);
  Logger.log(result.getContent());
}
