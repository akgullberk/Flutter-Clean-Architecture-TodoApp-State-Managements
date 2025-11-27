// 1. KÜTÜPHANELER
// ---------------------------------------------------------
import 'package:hive/hive.dart'; // Hafif ve hızlı NoSQL veritabanı olan Hive paketi.
import 'package:taskly/core/error/failures.dart'; // Hata durumlarında fırlatacağımız özel hata sınıfı (Örn: CacheFailure).
import 'package:taskly/features/todo/data/models/todo_model.dart'; // Veritabanına kaydedilecek olan veri modeli.

// 2. SOYUT SINIF (INTERFACE)
// ---------------------------------------------------------
// Bu soyut sınıf, uygulamanın veri katmanıyla nasıl konuşacağını belirleyen bir "sözleşme"dir.
// Repository katmanı, verilerin Hive'dan mı yoksa başka bir yerden mi geldiğini bilmez, sadece bu fonksiyonları çağırır.
abstract class TodoLocalDataSource {
  // Tüm yapılacakları listeler.
  Future<List<TodoModel>> getAllTodos();
  
  // Yeni bir görev ekler.
  Future<TodoModel> addTodo(TodoModel todo);
  
  // Var olan bir görevi günceller (Örn: Başlık değişikliği).
  Future<TodoModel> updateTodo(TodoModel todo);
  
  // Bir görevi ID'sine göre siler.
  Future<void> deleteTodo(String id);
  
  // Görevin tamamlandı/tamamlanmadı durumunu değiştirir.
  Future<TodoModel> toggleTodo(String id);
}

// 3. UYGULAMA SINIFI (IMPLEMENTATION)
// ---------------------------------------------------------
// Yukarıdaki sözleşmeyi (interface) Hive kullanarak gerçekleştiren asıl sınıf.
class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  
  // Hive "Box", SQL'deki tabloya benzer. Verilerin saklandığı kutudur.
  final Box<TodoModel> box;

  // Constructor (Kurucu): Bu sınıf oluşturulurken içine hazır bir Hive kutusu (box) verilir.
  // Bu sayede test yazarken gerçek veritabanı yerine sahte bir kutu verebiliriz (Dependency Injection).
  TodoLocalDataSourceImpl(this.box);

  // --- TÜM GÖREVLERİ GETİR ---
  @override
  Future<List<TodoModel>> getAllTodos() async {
    try {
      // box.values: Kutudaki tüm verileri alır.
      // toList(): Bunları bir listeye çevirir.
      return box.values.toList()
        // sort: Listeyi sıralar.
        // (b, a) kıyaslaması yaparak 'createdAt' (oluşturulma tarihi) en yeni olanı en başa koyar.
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); 
    } catch (e) {
      // Eğer okurken bir hata olursa, bunu yakalar ve kendi özel hata türümüze (CacheFailure) çeviririz.
      throw CacheFailure('Failed to get todos: ${e.toString()}');
    }
  }

  // --- GÖREV EKLE ---
  @override
  Future<TodoModel> addTodo(TodoModel todo) async {
    try {
      // box.put(key, value): Veriyi kaydeder.
      // Anahtar (key) olarak 'todo.id' kullanıyoruz. Bu sayede o ID ile veriye ulaşabiliriz.
      await box.put(todo.id, todo);
      return todo; // Başarılı olursa eklenen veriyi geri döndürür.
    } catch (e) {
      throw CacheFailure('Failed to add todo: ${e.toString()}');
    }
  }

  // --- GÖREV GÜNCELLE ---
  @override
  Future<TodoModel> updateTodo(TodoModel todo) async {
    try {
      // Hive'da 'put' komutu, eğer o ID (key) zaten varsa üzerine yazar (günceller).
      // Eğer yoksa yeni oluşturur. Burada güncelleme amacıyla kullanıyoruz.
      await box.put(todo.id, todo);
      return todo;
    } catch (e) {
      throw CacheFailure('Failed to update todo: ${e.toString()}');
    }
  }

  // --- GÖREV SİL ---
  @override
  Future<void> deleteTodo(String id) async {
    try {
      // Verilen ID'ye (key) sahip veriyi kutudan tamamen siler.
      await box.delete(id);
    } catch (e) {
      throw CacheFailure('Failed to delete todo: ${e.toString()}');
    }
  }

  // --- DURUM DEĞİŞTİR (TOGGLE) ---
  @override
  Future<TodoModel> toggleTodo(String id) async {
    try {
      // 1. Önce güncellenecek veriyi ID ile buluruz.
      final todo = box.get(id);
      
      // Eğer veri bulunamazsa (null ise) hata fırlatırız.
      if (todo == null) {
        throw CacheFailure('Todo not found');
      }

      // 2. Verinin kopyasını oluşturup (copyWith) sadece değişen alanları güncelleriz.
      // isCompleted: Mevcut durumun tam tersi yapılır (!todo.isCompleted).
      // completedAt: Eğer tamamlanıyorsa şu anki zaman, tamamlanma geri alınıyorsa 'null' atanır.
      final updatedTodo = todo.copyWith(
        isCompleted: !todo.isCompleted,
        completedAt: !todo.isCompleted ? DateTime.now() : null,
      );

      // 3. Güncellenmiş yeni halini tekrar kutuya kaydederiz.
      await box.put(id, updatedTodo);
      return updatedTodo;
    } catch (e) {
      throw CacheFailure('Failed to toggle todo: ${e.toString()}');
    }
  }
}

