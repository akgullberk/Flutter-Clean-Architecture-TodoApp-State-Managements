// 1. İMPORTLAR (Kütüphane eklemeleri)
// ---------------------------------------------------------

// Flutter'ın temel Material Design bileşenlerini (Butonlar, Renkler, Textler vb.) içeri aktarır.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Tarih ve saat formatlama işlemleri için yerel ayarları (Localization) yükleyen paket.
// Örneğin: "27 Kasım 2025" gibi Türkçe formatlar için gereklidir.
import 'package:intl/date_symbol_data_local.dart';
// Bağımlılık Enjeksiyonu (Dependency Injection - DI) yapılandırmasını içeri aktarır.
// 'as di' diyerek bu dosyaya 'di' takma adıyla erişeceğimizi belirtiyoruz.
// Bu, veritabanı veya servislerin uygulama başlarken hazırlanmasını sağlar.
import 'package:taskly/core/di/injection_container.dart' as di;
import 'package:taskly/core/routes/app_router.dart';
import 'package:taskly/core/routes/app_routes.dart';
import 'package:taskly/features/todo/presentation/providers/todo_provider.dart';

// 2. ANA FONKSİYON (Main)
// ---------------------------------------------------------

// Uygulamanın çalışmaya başladığı giriş kapısıdır.
// 'async' anahtar kelimesi, içeride bekleme gerektiren (await) işlemler yapılacağını belirtir.
void main() async {
  // Flutter motoru ile widget ağacını birbirine bağlar.
  // 'runApp' çalışmadan önce veritabanı veya servis başlatacaksak bu satır ZORUNLUDUR.
  WidgetsFlutterBinding.ensureInitialized();
  // Tarih formatlaması için Türkçe ('tr_TR') verilerini asenkron olarak yükler.
  // Bu sayede tarihleri "Monday" yerine "Pazartesi" olarak gösterebiliriz.
  await initializeDateFormatting('tr_TR', null);
  // Uygulamanın bağımlılıklarını (Service Locator, Repository, Bloc vb.) başlatır.
  // Bu işlem bitmeden uygulama arayüzü çizilmez.
  await di.init();
  // Hazırlıklar tamamlandıktan sonra 'MyApp' widget'ını Provider ile sarıp başlatır.
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (_) => TodoProvider(
                getAllTodos: di.sl(),
                addTodo: di.sl(),
                updateTodo: di.sl(),
                deleteTodo: di.sl(),
                toggleTodo: di.sl(),
              )..loadTodos(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// 3. UYGULAMA KÖK WIDGET'I (Root Widget)
// ---------------------------------------------------------

// MyApp, uygulamanın temel yapı taşıdır. Durum (State) tutmadığı için StatelessWidget'tır.
class MyApp extends StatelessWidget {
  // Constructor (Kurucu metod). 'const' olması performans için iyidir (yeniden derlenmez).
  const MyApp({super.key});

  // Arayüzün çizildiği yer.
  @override
  Widget build(BuildContext context) {
    // MaterialApp: Uygulamanın genel temasını, rotalarını ve başlığını yöneten ana kapsayıcıdır.
    return MaterialApp(
      // Uygulamanın adı (Android'de son kullanılanlarda görünür).
      title: 'Taskly',
      // Sağ üst köşedeki kırmızı "Debug" şeridini kaldırır.
      debugShowCheckedModeBanner: false,
      // --- TEMA AYARLARI (ThemeData) ---
      theme: ThemeData(
        // Renk Şeması: 'Colors.blue' rengini baz alarak uyumlu bir renk paleti oluşturur.
        // Material 3, bu tohum (seed) renkten açık/koyu mod için tüm renkleri türetir.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light, // Açık tema kullanacağımızı belirtir.
        ),
        // Google'ın en yeni tasarım dili olan Material 3'ü aktif eder.
        useMaterial3: true,
        // AppBar (Üst Çubuk) için özel ayarlar.
        appBarTheme: AppBarTheme(
          centerTitle:
              false, // Başlık ortada değil, solda (default iOS tarzı) olsun.
          elevation: 0, // Çubuğun altındaki gölgeyi kaldırır (düz görünüm).
        ),
        cardTheme: CardTheme(
          // Kartlar (Card) için özel ayarlar.
          elevation: 0, // Kartların gölgesini sıfırlar (daha flat/düz tasarım).
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              16,
            ), // Kart köşelerini 16px yuvarlar.
          ),
        ),
        // Yuvarlak Eylem Butonu (FAB) için özel ayarlar.
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 4, // Butonun gölgesini belirler.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              16,
            ), // Buton köşelerini karemsi-yuvarlak yapar.
          ),
        ),
      ),
      initialRoute: AppRoutes.todoList,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
