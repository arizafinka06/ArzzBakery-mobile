part of '../../main.dart';

// ==================== SCREEN: REPORT (ADMIN) ====================
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  int _selectedReportType = 2; // 0=Harian, 1=Mingguan, 2=Bulanan, 3=Tahunan
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  String? _errorMessage;

  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  static const _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // ----------------------------------------------------------------
  // Data loading & filtering
  // ----------------------------------------------------------------
  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _allOrders = await GoogleSheetsService.fetchOrders();
      _applyFilter();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      switch (_selectedReportType) {
        case 0:
          _filteredOrders = _allOrders
              .where((o) =>
                  o.timestamp.year == _selectedDate.year &&
                  o.timestamp.month == _selectedDate.month &&
                  o.timestamp.day == _selectedDate.day)
              .toList();
          break;
        case 1:
          final start = _selectedDate
              .subtract(Duration(days: _selectedDate.weekday - 1));
          final end = start.add(const Duration(days: 7));
          _filteredOrders = _allOrders
              .where((o) =>
                  o.timestamp.isAfter(
                      start.subtract(const Duration(seconds: 1))) &&
                  o.timestamp.isBefore(end))
              .toList();
          break;
        case 2:
          _filteredOrders = _allOrders
              .where((o) =>
                  o.timestamp.year == _selectedDate.year &&
                  o.timestamp.month == _selectedDate.month)
              .toList();
          break;
        case 3:
          _filteredOrders = _allOrders
              .where((o) => o.timestamp.year == _selectedDate.year)
              .toList();
          break;
      }
    });
  }

  String _getPeriodLabel() {
    switch (_selectedReportType) {
      case 0:
        return '${_selectedDate.day} ${_months[_selectedDate.month - 1]} ${_selectedDate.year}';
      case 1:
        final start = _selectedDate
            .subtract(Duration(days: _selectedDate.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return '${start.day} ${_monthsShort[start.month - 1]} – '
            '${end.day} ${_monthsShort[end.month - 1]} ${end.year}';
      case 2:
        return '${_months[_selectedDate.month - 1]} ${_selectedDate.year}';
      case 3:
        return 'Tahun ${_selectedDate.year}';
      default:
        return '';
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.brown),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _applyFilter();
    }
  }

  // ----------------------------------------------------------------
  // Stats helpers
  // ----------------------------------------------------------------
  double get _totalRevenue =>
      _filteredOrders.fold(0.0, (s, o) => s + o.totalAmount);

  Map<String, int> _salesByProduct() {
    final Map<String, int> map = {};
    for (final o in _filteredOrders) {
      for (final i in o.items) {
        map[i.product.name] = (map[i.product.name] ?? 0) + i.quantity;
      }
    }
    return Map.fromEntries(
        map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
  }

  Map<String, int> _countByPayment() {
    final Map<String, int> map = {};
    for (final o in _filteredOrders) {
      map[o.paymentMethod] = (map[o.paymentMethod] ?? 0) + 1;
    }
    return map;
  }

  // ----------------------------------------------------------------
  // PDF builder — dipakai untuk preview & cetak
  // ----------------------------------------------------------------
  Future<pw.Document> _buildPdf() async {
    final pdf = pw.Document();

    // Baris tabel: 1 order = 1 baris ringkasan + sub-baris per item
    final tableRows = <List<String>>[];
    for (final order in _filteredOrders) {
      for (var i = 0; i < order.items.length; i++) {
        final item = order.items[i];
        final ts = order.timestamp;
        final dateStr =
            '${ts.day.toString().padLeft(2,'0')}/'
            '${ts.month.toString().padLeft(2,'0')}/'
            '${ts.year} '
            '${ts.hour.toString().padLeft(2,'0')}:'
            '${ts.minute.toString().padLeft(2,'0')}';
        tableRows.add([
          i == 0 ? (tableRows.length + 1).toString() : '',
          i == 0 ? dateStr : '',
          i == 0 ? order.customerName : '',
          i == 0 ? order.tableNumber : '',
          item.product.name,
          item.quantity.toString(),
          'Rp ${_fmt(item.product.price)}',
          'Rp ${_fmt(item.totalPrice)}',
          i == 0 ? 'Rp ${_fmt(order.totalAmount)}' : '',
          i == 0 ? order.paymentMethod : '',
        ]);
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'ARZZ BAKERY',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.brown800,
                  ),
                ),
                pw.Text(
                  'Laporan Pesanan',
                  style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                ),
              ],
            ),
            pw.Divider(color: PdfColors.brown300, thickness: 1.5),
            pw.Row(children: [
              _pdfChip('Periode', _getPeriodLabel()),
              pw.SizedBox(width: 24),
              _pdfChip('Total Pesanan', '${_filteredOrders.length}'),
              pw.SizedBox(width: 24),
              _pdfChip('Total Pendapatan', 'Rp ${_fmt(_totalRevenue)}'),
            ]),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Dicetak: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
            ),
            pw.Text(
              'Halaman ${ctx.pageNumber} / ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
            ),
          ],
        ),
        build: (ctx) => [
          if (tableRows.isEmpty)
            pw.Center(
              child: pw.Text('Tidak ada pesanan pada periode ini.'),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: const [
                'No', 'Waktu', 'Nama', 'Meja',
                'Produk', 'Qty', 'Harga Satuan',
                'Total Item', 'Total Pesanan', 'Bayar',
              ],
              data: tableRows,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 8,
                color: PdfColors.white,
              ),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.brown700),
              cellStyle: const pw.TextStyle(fontSize: 7.5),
              cellAlignments: {
                0: pw.Alignment.center,
                3: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.centerRight,
                7: pw.Alignment.centerRight,
                8: pw.Alignment.centerRight,
                9: pw.Alignment.center,
              },
              rowDecoration: const pw.BoxDecoration(),
              oddRowDecoration:
                  const pw.BoxDecoration(color: PdfColors.brown50),
              border: pw.TableBorder.all(
                  color: PdfColors.brown200, width: 0.5),
            ),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _pdfChip(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  String _fmt(double v) =>
      v.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  // ----------------------------------------------------------------
  // Preview PDF → buka halaman PdfPreviewPage
  // ----------------------------------------------------------------
  void _previewPdf() async {
    final pdf = await _buildPdf();
    final bytes = await pdf.save();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfPreviewPage(
          pdfBytes: bytes,
          title: 'Preview Laporan – ${_getPeriodLabel()}',
        ),
      ),
    );
  }

  // Cetak langsung tanpa preview
  void _printPdf() async {
    final pdf = await _buildPdf();
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  // ----------------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.brown)),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadOrders,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        color: Colors.brown,
        child: CustomScrollView(
          slivers: [
            // ── Filter bar ──────────────────────────────────────────
            SliverToBoxAdapter(child: _buildFilterBar()),

            // ── Stat cards ──────────────────────────────────────────
            SliverToBoxAdapter(child: _buildStatCards()),

            // ── Payment distribution ─────────────────────────────────
            if (_countByPayment().isNotEmpty)
              SliverToBoxAdapter(child: _buildPaymentCard()),

            // ── Top products ─────────────────────────────────────────
            if (_salesByProduct().isNotEmpty)
              SliverToBoxAdapter(child: _buildTopProductsCard()),

            // ── Order detail list ─────────────────────────────────────
            SliverToBoxAdapter(child: _buildOrderList()),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  // ── Filter bar ───────────────────────────────────────────────────
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented button
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Harian')),
              ButtonSegment(value: 1, label: Text('Mingguan')),
              ButtonSegment(value: 2, label: Text('Bulanan')),
              ButtonSegment(value: 3, label: Text('Tahunan')),
            ],
            selected: {_selectedReportType},
            onSelectionChanged: (sel) {
              setState(() => _selectedReportType = sel.first);
              _applyFilter();
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? Colors.brown
                      : null),
              foregroundColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? Colors.white
                      : Colors.brown),
            ),
          ),

          const SizedBox(height: 10),

          // Tanggal + tombol PDF
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _getPeriodLabel(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.brown,
                    side: const BorderSide(color: Colors.brown),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Preview button
              OutlinedButton.icon(
                onPressed: _filteredOrders.isEmpty ? null : _previewPdf,
                icon: const Icon(Icons.preview, size: 16),
                label: const Text('Preview', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  side: BorderSide(
                    color: _filteredOrders.isEmpty
                        ? Colors.grey.shade300
                        : Colors.indigo,
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 14),
                ),
              ),
              const SizedBox(width: 8),
              // Print button
              ElevatedButton.icon(
                onPressed: _filteredOrders.isEmpty ? null : _printPdf,
                icon: const Icon(Icons.print, size: 16),
                label: const Text('Cetak', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stat cards ───────────────────────────────────────────────────
  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              'Total Pesanan',
              '${_filteredOrders.length}',
              Icons.receipt_long,
              Colors.indigo,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              'Total Pendapatan',
              'Rp ${_fmt(_totalRevenue)}',
              Icons.payments_outlined,
              Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Payment distribution ──────────────────────────────────────────
  Widget _buildPaymentCard() {
    final map = _countByPayment();
    final total = _filteredOrders.length;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Metode Pembayaran',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            ...map.entries.map((e) {
              final pct = e.value / total;
              final isQris = e.key.toLowerCase().contains('qris');
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Icon(
                            isQris
                                ? Icons.qr_code_scanner
                                : Icons.payments_outlined,
                            size: 16,
                            color: isQris ? Colors.blue : Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Text(e.key,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ]),
                        Text(
                          '${e.value}x  (${(pct * 100).toStringAsFixed(1)}%)',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 7,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            isQris ? Colors.blue : Colors.green),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Top products ──────────────────────────────────────────────────
  Widget _buildTopProductsCard() {
    final sorted = _salesByProduct().entries.take(5).toList();
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Produk Terlaris',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            ...sorted.asMap().entries.map((e) {
              final rank = e.key + 1;
              final name = e.value.key;
              final qty = e.value.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: rank == 1
                            ? Colors.amber
                            : rank == 2
                                ? Colors.blueGrey.shade300
                                : Colors.brown.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(name,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.brown.shade200),
                      ),
                      child: Text(
                        '$qty terjual',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown.shade700),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Order detail list ──────────────────────────────────────────────
  Widget _buildOrderList() {
    if (_filteredOrders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'Tidak ada pesanan pada periode ini',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Detail Pesanan (${_filteredOrders.length})',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredOrders.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, i) {
              final order = _filteredOrders[i];
              final ts = order.timestamp;
              return ExpansionTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.brown.shade100,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.brown.shade700),
                  ),
                ),
                title: Text(
                  order.customerName.isNotEmpty
                      ? order.customerName
                      : order.username,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                subtitle: Text(
                  '${ts.day.toString().padLeft(2, '0')}/${ts.month.toString().padLeft(2, '0')}/${ts.year}  '
                  '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}  •  '
                  'Rp ${_fmt(order.totalAmount)}',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade600),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailRow(Icons.table_restaurant, 'Meja',
                            order.tableNumber),
                        _detailRow(Icons.payments_outlined, 'Pembayaran',
                            order.paymentMethod),
                        _detailRow(Icons.person_outline, 'Username',
                            order.username),
                        const Divider(height: 16),
                        const Text('Item Pesanan',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 6),
                        ...order.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.product.name}  ×${item.quantity}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                Text(
                                  'Rp ${_fmt(item.totalPrice)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.brown,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              'Rp ${_fmt(order.totalAmount)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Text('$label: ',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ==================== SCREEN: PDF PREVIEW ====================
class PdfPreviewPage extends StatelessWidget {
  final Uint8List pdfBytes;
  final String title;

  const PdfPreviewPage({
    super.key,
    required this.pdfBytes,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.brown.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Tombol cetak langsung dari preview
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Cetak',
            onPressed: () async {
              await Printing.layoutPdf(
                onLayout: (_) async => pdfBytes,
              );
            },
          ),
          // Tombol share / simpan
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share / Simpan',
            onPressed: () async {
              await Printing.sharePdf(
                bytes: pdfBytes,
                filename: 'laporan_arzzbakery.pdf',
              );
            },
          ),
        ],
      ),
      body: PdfPreview(
        // Gunakan bytes yang sudah digenerate agar tidak generate ulang
        build: (_) async => pdfBytes,
        allowPrinting: false,   // sudah ada tombol custom di AppBar
        allowSharing: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName: 'laporan_arzzbakery.pdf',
        // Styling area preview
        previewPageMargin: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
