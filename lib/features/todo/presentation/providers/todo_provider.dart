// 1. İMPORTLAR
// ---------------------------------------------------------
import 'dart:collection'; // 'UnmodifiableListView' kullanmak için (Listeyi korumak adına).
import 'package:flutter/material.dart'; // ChangeNotifier sınıfı buradadır.
// Entity ve UseCase'leri içeri alıyoruz. Provider bu sınıfları kullanarak iş yapacak.
import 'package:taskly/features/todo/domain/entities/todo.dart';
import 'package:taskly/features/todo/domain/usecases/add_todo.dart';
import 'package:taskly/features/todo/domain/usecases/delete_todo.dart';
import 'package:taskly/features/todo/domain/usecases/get_all_todos.dart';
import 'package:taskly/features/todo/domain/usecases/toggle_todo.dart';
import 'package:taskly/features/todo/domain/usecases/update_todo.dart';

// 2. SINIF TANIMI (ChangeNotifier)
// ---------------------------------------------------------
// ChangeNotifier: Flutter'ın yerleşik bir sınıfıdır. "Ben değiştim, beni dinleyen herkes ekranını yenilesin!" 
// (notifyListeners) deme yeteneğine sahiptir.
class TodoProvider extends ChangeNotifier {
  
  // 3. BAĞIMLILIKLAR VE KURUCU (CONSTRUCTOR)
  // ---------------------------------------------------------
  // Provider, işi yapabilmek için UseCase'lere ihtiyaç duyar.
  // Bunları dışarıdan (Dependency Injection) alır.
  TodoProvider({
    required GetAllTodos getAllTodos,
    required AddTodo addTodo,
    required UpdateTodo updateTodo,
    required DeleteTodo deleteTodo,
    required ToggleTodo toggleTodo,
  }) : _getAllTodos = getAllTodos,
       _addTodo = addTodo,
       _updateTodo = updateTodo,
       _deleteTodo = deleteTodo,
       _toggleTodo = toggleTodo;

  // UseCase'leri sakladığımız özel (private) değişkenler.
  final GetAllTodos _getAllTodos;
  final AddTodo _addTodo;
  final UpdateTodo _updateTodo;
  final DeleteTodo _deleteTodo;
  final ToggleTodo _toggleTodo;

  // 4. DURUM DEĞİŞKENLERİ (STATE)
  // ---------------------------------------------------------
  // Uygulamanın o anki "fotoğrafı"nı oluşturan veriler.
  
  List<Todo> _todos = const []; // Görev listesi.
  bool _isLoading = false;      // Sayfa ilk açılışta yükleniyor mu?
  bool _isSubmitting = false;   // Kaydet butonuna basınca dönen çember için.
  String? _errorMessage;        // Hata varsa mesajı burada tutulur.

  // 5. GETTER METODLARI (KAPSÜLLEME)
  // ---------------------------------------------------------
  // Dışarıdaki sınıflar (UI), içerideki '_todos' listesini doğrudan değiştiremesin diye
  // 'UnmodifiableListView' (Değiştirilemez Liste) olarak dışarı sunuyoruz.
  // Bu sayede UI'da yanlışlıkla "provider.todos.add(...)" denirse hata verir.
  // Ekleme yapmak isteyen "provider.addTodo()" metodunu kullanmak ZORUNDA kalır.
  UnmodifiableListView<Todo> get todos => UnmodifiableListView(_todos);
  
  // Diğer değişkenlerin de sadece okunabilir hallerini dışarı açıyoruz.
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  // 6. LİSTEYİ YÜKLEME (LOAD)
  // ---------------------------------------------------------
  Future<void> loadTodos({bool showLoadingIndicator = true}) async {
    // Eğer istenirse (sayfa ilk açılışıysa) yükleniyor işaretini aç.
    if (showLoadingIndicator) {
      _isLoading = true;
      _errorMessage = null; // Eski hataları temizle.
      notifyListeners(); // UI'ya haber ver: "Yükleniyor çemberini göster!"
    }

    // UseCase'i çağır ve veriyi iste.
    final result = await _getAllTodos();

    // Sonucu işle (Either yapısı: Sol=Hata, Sağ=Veri)
    result.fold(
      (failure) {
        // HATA:
        _errorMessage = failure.message ?? 'Bir hata oluştu';
        _todos = const []; // Hata varsa listeyi boşalt.
      },
      (todos) {
        // BAŞARI:
        _todos = todos; // Gelen veriyi içeri al.
        _errorMessage = null;
      },
    );

    // İşlem bitti, yükleniyor işaretini kapat.
    _isLoading = false;
    notifyListeners(); // UI'ya haber ver: "Veriler geldi, listeyi çiz!"
  }

  // 7. EKLEME İŞLEMİ (ADD)
  // ---------------------------------------------------------
  // Geriye 'String?' dönüyor. 
  // Eğer hata varsa hata mesajını, başarıysa 'null' döner. UI buna göre SnackBar gösterir.
  Future<String?> addTodo(Todo todo) async {
    _setSubmitting(true); // Butonu kilitle (Dönen çember).
    
    final result = await _addTodo(todo); // UseCase'i çağır.

    return result.fold(
      (failure) {
        _setSubmitting(false); // Buton kilidini aç.
        return Future.value(failure.message ?? 'Todo eklenirken hata oluştu'); // Hatayı döndür.
      },
      (_) async {
        // BAŞARILIYSA:
        await loadTodos(showLoadingIndicator: false); // Listeyi veritabanından tekrar çek (Tazele).
        _setSubmitting(false); // Buton kilidini aç.
        return null; // Başarılı, hata yok.
      },
    );
  }

  // 8. GÜNCELLEME İŞLEMİ (UPDATE)
  // ---------------------------------------------------------
  Future<String?> updateTodo(Todo todo) async {
    _setSubmitting(true); // Kaydediliyor...
    final result = await _updateTodo(todo);

    return result.fold(
      (failure) {
        _setSubmitting(false);
        return Future.value(failure.message ?? 'Todo güncellenirken hata oluştu');
      },
      (_) async {
        await loadTodos(showLoadingIndicator: false); // Listeyi tazele.
        _setSubmitting(false);
        return null;
      },
    );
  }

  // 9. TOGGLE VE DELETE İŞLEMLERİ
  // ---------------------------------------------------------
  // Bu işlemlerde genellikle 'isSubmitting' (büyük yükleme ekranı) kullanılmaz,
  // çünkü bunlar listede hızlıca yapılan işlemlerdir.
  
  Future<String?> toggleTodo(String id) async {
    final result = await _toggleTodo(id);

    return result.fold(
      (failure) => Future.value(failure.message ?? 'Hata oluştu'),
      (_) async {
        await loadTodos(showLoadingIndicator: false); // Sadece listeyi yenile.
        return null;
      },
    );
  }

  Future<String?> deleteTodo(String id) async {
    final result = await _deleteTodo(id);

    return result.fold(
      (failure) => Future.value(failure.message ?? 'Hata oluştu'),
      (_) async {
        await loadTodos(showLoadingIndicator: false);
        return null;
      },
    );
  }

  // YARDIMCI METOD
  // Kod tekrarını önlemek için, isSubmitting'i değiştirip UI'ya haber veren fonksiyon.
  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }
}