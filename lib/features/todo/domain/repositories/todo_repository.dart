// 1. İMPORTLAR
// ---------------------------------------------------------
// Hata türlerini içeren sınıf (Örn: ServerFailure, CacheFailure).
// Domain katmanı, hatanın "Veritabanı çöktü" gibi teknik detayını bilmez, 
// sadece "Bir hata oldu" (Failure) bilgisini bilir.
import 'package:taskly/core/error/failures.dart';

// Uygulamanın saf veri nesnesi (Entity).
import 'package:taskly/features/todo/domain/entities/todo.dart';

// Hata yönetimi için kullanılan 'Either' (Ya o, Ya bu) yapısı.
import 'package:dartz/dartz.dart';


// 2. SOYUT SINIF (ABSTRACT CLASS) - SÖZLEŞME
// ---------------------------------------------------------
// 'abstract' olması, bu sınıfın içinin boş olduğu, sadece fonksiyon isimlerinin
// tanımlandığı anlamına gelir. Gövdesi yoktur.
// Gövdesini (içeriğini) Data katmanındaki 'TodoRepositoryImpl' sınıfı doldurur.
abstract class TodoRepository {
  
  // --- TÜM GÖREVLERİ GETİR ---
  // Future: İşlem zaman alacağı için (asenkron).
  // Either<Failure, List<Todo>>: Sonuç olarak ya sol cepten 'Failure' çıkar,
  // ya da sağ cepten 'List<Todo>' (görev listesi) çıkar.
  Future<Either<Failure, List<Todo>>> getAllTodos();

  // --- GÖREV EKLE ---
  // Yeni bir görev ekler. Başarılı olursa eklenen görevi (ID atanmış halde) geri döner.
  Future<Either<Failure, Todo>> addTodo(Todo todo);

  // --- GÖREV GÜNCELLE ---
  // Var olan bir görevi günceller ve son halini döner.
  Future<Either<Failure, Todo>> updateTodo(Todo todo);

  // --- GÖREV SİL ---
  // void: Silme işleminden sonra geriye bir veri dönmesine gerek yoktur.
  // Ancak başarı/hata durumunu bilmek için yine Either kullanırız.
  // Sağ taraf (başarı) boş (void) olur.
  Future<Either<Failure, void>> deleteTodo(String id);

  // --- DURUM DEĞİŞTİR (TOGGLE) ---
  // Tamamlandı/Tamamlanmadı durumunu değiştirir.
  Future<Either<Failure, Todo>> toggleTodo(String id);
}