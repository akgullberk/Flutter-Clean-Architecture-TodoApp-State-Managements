// Dart'ın asenkron işlem kütüphanesini ekler (Future, Stream vb. için).
import 'dart:async';

// Riverpod paketini ekler. Durum yönetimi bu paket üzerinden yapılır.
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Bağımlılık enjeksiyonu (Dependency Injection) konteynerini ekler.
// 'sl' (Service Locator) nesnesine buradan erişilir.
import 'package:taskly/core/di/injection_container.dart';

// Domain katmanındaki varlık (Entity) ve kullanım senaryolarını (Use Cases) ekler.
import 'package:taskly/features/todo/domain/entities/todo.dart';
import 'package:taskly/features/todo/domain/usecases/add_todo.dart';
import 'package:taskly/features/todo/domain/usecases/delete_todo.dart';
import 'package:taskly/features/todo/domain/usecases/get_all_todos.dart';
import 'package:taskly/features/todo/domain/usecases/toggle_todo.dart';
import 'package:taskly/features/todo/domain/usecases/update_todo.dart';

/// Todo listesi için Riverpod tabanlı durum yöneticisi.
/// AsyncNotifier: Asenkron verileri (Loading, Error, Data durumlarını) otomatik yöneten
/// güçlü bir Riverpod sınıfıdır. Liste türünde Todo (List<Todo>) tutar.
class TodoListNotifier extends AsyncNotifier<List<Todo>> {
  
  // Dependency Injection (sl) kullanarak UseCase sınıflarını çağırıyoruz.
  // Bu yöntemle "TodoListNotifier", verinin nereden geldiğini bilmez (Database mi, API mi),
  // sadece işi yapan UseCase'i tanır.
  GetAllTodos get _getAllTodos => sl<GetAllTodos>();
  AddTodo get _addTodo => sl<AddTodo>();
  UpdateTodo get _updateTodo => sl<UpdateTodo>();
  DeleteTodo get _deleteTodo => sl<DeleteTodo>();
  ToggleTodo get _toggleTodo => sl<ToggleTodo>();

  // AsyncNotifier başlatıldığında çalışan ilk metod (init gibi düşünebilirsin).
  // Bu metodun dönüş değeri, provider'ın "başlangıç durumu" olur.
  @override
  FutureOr<List<Todo>> build() async {
    // Başlangıçta veritabanındaki todoları çekip listeler.
    return _fetchTodos();
  }

  // Yardımcı (Private) metod: Verileri çekme işini yapar.
  Future<List<Todo>> _fetchTodos() async {
    // UseCase'i çağırır (Veritabanına git, veriyi al).
    final result = await _getAllTodos();
    
    // result.fold: Dartz veya Fpdart paketinden gelen fonksiyonel bir yapıdır.
    // Clean Architecture'da hataları (Left) ve başarıyı (Right) ayırmak için kullanılır.
    return result.fold(
      (failure) {
        // Hata varsa (Left), bir Exception fırlatır. Riverpod bunu yakalayıp
        // UI'da "AsyncError" durumuna çevirir.
        throw Exception(failure.message ?? 'Todolar yüklenirken bir hata oluştu');
      },
      (todos) => todos, // Başarı varsa (Right), listeyi döndürür.
    );
  }

  /// Listeyi manuel olarak yenilemek için kullanılan metod.
  Future<void> refresh() async {
    // Önce durumu "Yükleniyor" (Loading) moduna alır. UI'da dönen çark (spinner) gösterilmesini sağlar.
    state = const AsyncLoading();
    // AsyncValue.guard: _fetchTodos fonksiyonunu çalıştırır.
    // Hata çıkarsa otomatik olarak AsyncError, başarılı olursa AsyncData durumuna geçer.
    state = await AsyncValue.guard(_fetchTodos);
  }

  /// Yeni todo ekleme işlemi.
  Future<void> add(Todo todo) async {
    // 1. Domain katmanındaki "Ekleme" senaryosunu çalıştır.
    final result = await _addTodo(todo);

    // 2. Sonucu kontrol et (Hata mı, Başarı mı?)
    await result.fold<Future<void>>(
      (failure) async {
        // Hata durumunda: State'i hata durumuna güncelle.
        // StackTrace.current: Hatanın nerede olduğunu loglamak için kullanılır.
        state = AsyncError(
          Exception(failure.message ?? 'Todo eklenirken bir hata oluştu'),
          StackTrace.current,
        );
      },
      (_) async {
        // Başarı durumunda (_ -> return değerini önemsemiyoruz):
        // Listeyi sıfırdan tekrar çek (refresh).
        // NOT: Alternatif olarak listeye manuel ekleme de yapılabilirdi ama
        // veritabanı ile senkronize olmak için refresh() daha güvenlidir.
        await refresh();
      },
    );
  }

  /// Var olan bir todo'yu güncelleme işlemi.
  Future<void> updateTodo(Todo todo) async {
    // UseCase çağrısı
    final result = await _updateTodo(todo);

    // Sonuç kontrolü
    await result.fold<Future<void>>(
      (failure) async {
        state = AsyncError(
          Exception(failure.message ?? 'Todo güncellenirken bir hata oluştu'),
          StackTrace.current,
        );
      },
      (_) async {
        // Başarılıysa listeyi yenile.
        await refresh();
      },
    );
  }

  /// Todo silme işlemi.
  Future<void> delete(String id) async {
    // UseCase çağrısı (ID parametresi ile)
    final result = await _deleteTodo(id);

    await result.fold<Future<void>>(
      (failure) async {
        state = AsyncError(
          Exception(failure.message ?? 'Todo silinirken bir hata oluştu'),
          StackTrace.current,
        );
      },
      (_) async {
        // Başarılıysa listeyi yenile.
        await refresh();
      },
    );
  }

  /// Tamamlama durumunu (check/uncheck) değiştirme işlemi.
  Future<void> toggle(String id) async {
    // UseCase çağrısı
    final result = await _toggleTodo(id);

    await result.fold<Future<void>>(
      (failure) async {
        state = AsyncError(
          Exception(failure.message ?? 'Todo güncellenirken bir hata oluştu'),
          StackTrace.current,
        );
      },
      (_) async {
        // Başarılıysa listeyi yenile.
        await refresh();
      },
    );
  }
}

/// Todo listesi için global provider tanımı.
/// UI (Widget'lar) bu provider'ı dinleyerek (watch) ekranı çizer.
final todoListProvider =
    AsyncNotifierProvider<TodoListNotifier, List<Todo>>(
  TodoListNotifier.new, // Sınıfın kurucu metodunu referans verir.
);