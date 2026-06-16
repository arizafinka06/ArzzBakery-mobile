part of '../../main.dart';

// ==================== SCREEN: REPORT ====================
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  int _selectedReportType = 0; // 0=Daily, 1=Weekly, 2=Monthly, 3=Yearly
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilter() {
    setState(() {
      switch (_selectedReportType) {
        case 0: // Daily
          _filteredOrders = _getOrdersByDay(_selectedDate);
          break;
        case 1: // Weekly
          _filteredOrders = _getOrdersByWeek(_selectedDate);
          break;
        case 2: // Monthly
          _filteredOrders = _getOrdersByMonth(_selectedDate);
          break;
        case 3: // Yearly
          _filteredOrders = _getOrdersByYear(_selectedDate);
          break;
      }
    });
  }

  List<Order> _getOrdersByDay(DateTime date) {
    return _allOrders
        .where((order) =>
            order.timestamp.year == date.year &&
            order.timestamp.month == date.month &&
            order.timestamp.day == date.day)
        .toList();
  }

  List<Order> _getOrdersByWeek(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return _allOrders
        .where((order) =>
            order.timestamp.isAfter(startOfWeek) &&
            order.timestamp.isBefore(endOfWeek.add(const Duration(days: 1))))
        .toList();
  }

  List<Order> _getOrdersByMonth(DateTime date) {
    return _allOrders
        .where((order) =>
            order.timestamp.year == date.year &&
            order.timestamp.month == date.month)
        .toList();
  }

  List<Order> _getOrdersByYear(DateTime date) {
    return _allOrders
        .where((order) => order.timestamp.year == date.year)
        .toList();
  }

  String _getDateRangeText() {
    switch (_selectedReportType) {
      case 0:
        return 'Tanggal: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
      case 1:
        final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return 'Minggu: ${startOfWeek.day}/${startOfWeek.month} - ${endOfWeek.day}/${endOfWeek.month}/${endOfWeek.year}';
      case 2:
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return 'Bulan: ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
      case 3:
        return 'Tahun: ${_selectedDate.year}';
      default:
        return '';
    }
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _selectedDate = picked;
      _applyFilter();
    }
  }

  Map<String, double> _getRevenueByProduct() {
    Map<String, double> revenue = {};
    for (var order in _filteredOrders) {
      for (var item in order.items) {
        revenue[item.product.name] = (revenue[item.product.name] ?? 0) + item.totalPrice;
      }
    }
    return revenue;
  }

  Map<String, int> _getOrderCountByPaymentMethod() {
    Map<String, int> count = {};
    for (var order in _filteredOrders) {
      count[order.paymentMethod] = (count[order.paymentMethod] ?? 0) + 1;
    }
    return count;
  }

  Future<void> _printPdf() async {
    final pdf = pw.Document();
    final rows = <List<String>>[];

    for (final order in _filteredOrders) {
      for (var i = 0; i < order.items.length; i++) {
        final item = order.items[i];
        rows.add([
          i == 0 ? order.id : '',
          i == 0 ? _getDateRangeText() : '',
          i == 0 ? order.username : '',
          i == 0 ? order.customerName : '',
          i == 0 ? order.tableNumber : '',
          item.product.name,
          item.quantity.toString(),
          item.product.price.toStringAsFixed(0),
          item.totalPrice.toStringAsFixed(0),
          i == 0 ? order.totalAmount.toStringAsFixed(0) : '',
          i == 0 ? order.paymentMethod : '',
        ]);
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          pw.Text(
            'Laporan Pesanan Arzz Bakery',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(_getDateRangeText()),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Order ID',
              'Periode',
              'Username',
              'Nama',
              'Meja',
              'Produk',
              'Qty',
              'Harga',
              'Total Item',
              'Total Pesanan',
              'Bayar',
            ],
            data: rows,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.brown200),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_off,
                            size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _loadOrders,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: SingleChildScrollView(
        child: Column(
          children: [
            // Report Type Selector
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.brown.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Jenis Laporan:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(label: Text('Harian'), value: 0),
                            ButtonSegment(label: Text('Mingguan'), value: 1),
                            ButtonSegment(label: Text('Bulanan'), value: 2),
                            ButtonSegment(label: Text('Tahunan'), value: 3),
                          ],
                          selected: {_selectedReportType},
                          onSelectionChanged: (Set<int> newSelection) {
                            _selectedReportType = newSelection.first;
                            _applyFilter();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _selectDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_getDateRangeText()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _filteredOrders.isEmpty ? null : _printPdf,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Cetak PDF'),
                    ),
                  ),
                ],
              ),
            ),
            // Summary Stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Pesanan',
                      '${_filteredOrders.length}',
                      Icons.shopping_cart,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Pendapatan',
                      'Rp ${_filteredOrders.fold(0.0, (sum, order) => sum + order.totalAmount).toStringAsFixed(0)}',
                      Icons.attach_money,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            // Payment Method Distribution
            if (_getOrderCountByPaymentMethod().isNotEmpty)
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Distribusi Metode Pembayaran',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ..._getOrderCountByPaymentMethod().entries.map((entry) {
                        final percentage = (_getOrderCountByPaymentMethod()[entry.key]! /
                            _filteredOrders.length *
                            100);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key),
                                  Text('${entry.value} (${percentage.toStringAsFixed(1)}%)'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: percentage / 100,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    entry.key == 'QRIS' ? Colors.blue : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            // Top Products
            if (_getRevenueByProduct().isNotEmpty)
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Produk dengan Penjualan Tertinggi',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ..._getRevenueByProduct()
                          .entries
                          .toList()
                          .asMap()
                          .entries
                          .take(5)
                          .map((mapEntry) {
                        final index = mapEntry.key;
                        final entry = mapEntry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.brown.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Rp ${entry.value.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            // Detail Orders List
            if (_filteredOrders.isNotEmpty)
              Card(
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        'Detail Pesanan',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = _filteredOrders[index];
                        return ExpansionTile(
                          title: Text('Pesanan #${index + 1} - ${order.customerName}'),
                          subtitle: Text(
                            '${order.timestamp.day}/${order.timestamp.month}/${order.timestamp.year} - Rp ${order.totalAmount.toStringAsFixed(0)}',
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('Meja', order.tableNumber),
                                  _buildDetailRow('Metode Pembayaran', order.paymentMethod),
                                  _buildDetailRow('Username', order.username),
                                  _buildDetailRow('Waktu', '${order.timestamp.hour}:${order.timestamp.minute.toString().padLeft(2, '0')}'),
                                  const Divider(),
                                  const Text('Detail Item:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  ...order.items.map((item) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text('${item.product.name} x${item.quantity}'),
                                        ),
                                        Text(
                                          'Rp ${item.totalPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada pesanan untuk periode ini',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
                  ),
                ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          Expanded(
            flex: 1,
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

