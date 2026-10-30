import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_colors.dart';

// Dummy Repositories
import 'data/repositories/supabase_product_repository.dart';
import 'data/dummy/dummy_vendor_repository.dart';

import 'data/repositories/supabase_stock_repository.dart';
import 'data/dummy/dummy_opname_repository.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/vendor_provider.dart';

import 'providers/stock_provider.dart';
import 'providers/opname_provider.dart';

// Pages
import 'ui/pages/splash_page.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Wajib: init binding untuk async di main
  WidgetsFlutterBinding.ensureInitialized();

  // Init locale Indonesia untuk format tanggal & Rupiah
  await initializeDateFormatting('id_ID', null);
  // ==========================================
  // INISIALISASI SUPABASE
  // ==========================================
  await Supabase.initialize(
    url: 'https://xddivwsltbpbqwhtpnae.supabase.co',
    anonKey: 'sb_publishable_SQWQNOA12dMkianoh9EYDg_8WJ_agot',
  );

  runApp(const WarungStockApp());
}

class WarungStockApp extends StatelessWidget {
  const WarungStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Product — inject SupabaseProductRepository
        ChangeNotifierProvider(
          create: (_) =>
              ProductProvider(SupabaseProductRepository())..loadProducts(),
        ),

        // Vendor — inject DummyVendorRepository
        ChangeNotifierProvider(
          create: (_) => VendorProvider(DummyVendorRepository())..loadAll(),
        ),

        // Customer — inject DummyCustomerRepository

        // Stock — inject
        // SupabaseStockRepository
        ChangeNotifierProvider(
          create: (_) => StockProvider(SupabaseStockRepository())..loadAll(),
        ),

        // Opname — inject DummyOpnameRepository
        ChangeNotifierProvider(
          create: (_) => OpnameProvider(DummyOpnameRepository())..loadAll(),
        ),
      ],
      child: MaterialApp(
        title: 'WarungStock',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const SplashPage(),
      ),
    );
  }
}
