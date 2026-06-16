import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app/my_app.dart';
part 'services/storage_service.dart';
part 'models/models.dart';
part 'services/google_sheets_service.dart';
part 'providers/cart_provider.dart';
part 'features/auth/signup_screen.dart';
part 'features/auth/login_screen.dart';
part 'features/pelanggan/main_menu_screen.dart';
part 'features/pelanggan/product_list_screen.dart';
part 'features/pelanggan/cart_screen.dart';
part 'features/pelanggan/order_history_screen.dart';
part 'features/admin/report_screen.dart';
part 'features/admin/user_management_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const MyApp());
}
