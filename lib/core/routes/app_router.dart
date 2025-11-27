// 1. İMPORTLAR
// ---------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:taskly/core/routes/app_routes.dart'; // Adres defterimiz (sabit rotalar).
import 'package:taskly/features/todo/domain/entities/todo.dart'; // Veri taşıma için Todo modeli.
import 'package:taskly/features/todo/presentation/pages/todo_add_page.dart'; // Sayfalar...
import 'package:taskly/features/todo/presentation/pages/todo_edit_page.dart';
import 'package:taskly/features/todo/presentation/pages/todo_list_page.dart';

class AppRouter {
  // 2. ROTA ÜRETİCİ (GENERATE ROUTE)
  // ---------------------------------------------------------
  // Bu fonksiyon, uygulama içinde ne zaman bir sayfa değişikliği istenirse tetiklenir.
  // Girdi olarak 'RouteSettings' alır. Bu ayarların içinde iki kritik bilgi vardır:
  // 1. settings.name: Gidilmek istenen adres (Örn: "/todo/edit")
  // 2. settings.arguments: Yanımızda götürdüğümüz bavul/veri (Örn: Düzenlenecek Todo nesnesi)
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    
    // Adrese göre karar ver (Switch-Case):
    switch (settings.name) {
      
      // --- DURUM 1: ANA SAYFA ---
      case AppRoutes.todoList:
        // MaterialPageRoute: Android ve iOS'un kendi standart sayfa geçiş 
        // animasyonlarını (Android'de alttan yukarı/yandan, iOS'ta sağdan sola) sağlar.
        return MaterialPageRoute(
          builder: (_) => const TodoListPage(),
        );

      // --- DURUM 2: EKLEME SAYFASI ---
      case AppRoutes.todoAdd:
        return MaterialPageRoute(
          builder: (_) => const TodoAddPage(),
        );

      // --- DURUM 3: DÜZENLEME SAYFASI (VERİ TAŞIMA) ---
      case AppRoutes.todoEdit:
        // Burası çok önemlidir. 
        // Ana sayfadan buraya gelirken gönderilen veriyi (arguments) yakalarız.
        // Gelen veriyi 'Todo' tipine zorlarız (cast işlemi: 'as Todo').
        final todo = settings.arguments as Todo;
        
        // Yakaladığımız bu veriyi, açılacak olan sayfanın (TodoEditPage) içine atarız.
        return MaterialPageRoute(
          builder: (_) => TodoEditPage(todo: todo),
        );

      // --- DURUM 4: HATALI/BİLİNMEYEN ADRES (404) ---
      // Eğer yukarıdaki case'lerin hiçbiri tutmazsa (yanlış adres yazıldıysa),
      // uygulama çökmesin diye kullanıcıya bir "Hata Sayfası" gösteririz.
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Sayfa bulunamadı'),
            ),
          ),
        );
    }
  }
}