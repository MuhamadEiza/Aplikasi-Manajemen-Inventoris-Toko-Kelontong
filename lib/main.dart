import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';

// Dummy Repositories
import 'data/dummy/dummy_product_repository.dart';
import 'data/dummy/dummy_vendor_repository.dart';
import 'data/dummy/dummy_customer_repository.dart';
import 'data/dummy/dummy_stock_repository.dart';
import 'data/dummy/dummy_opname_repository.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/vendor_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/stock_provider.dart';
import 'providers/opname_provider.dart';

// Pages
import 'ui/pages/splash_page.dart';

void main() {
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

        // Product — inject DummyProductRepository
        ChangeNotifierProvider(
          create: (_) => ProductProvider(DummyProductRepository())..loadProducts(),
        ),

        // Vendor — inject DummyVendorRepository
        ChangeNotifierProvider(
          create: (_) => VendorProvider(DummyVendorRepository())..loadAll(),
        ),

        // Customer — inject DummyCustomerRepository
        ChangeNotifierProvider(
          create: (_) => CustomerProvider(DummyCustomerRepository())..loadAll(),
        ),

        // Stock — inject DummyStockRepository
        ChangeNotifierProvider(
          create: (_) => StockProvider(DummyStockRepository())..loadAll(),
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