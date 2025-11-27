// 1. İMPORTLAR
// ---------------------------------------------------------
import 'package:dartz/dartz.dart'; // Başarı/Hata kutusu (Either).
import 'package:taskly/core/error/failures.dart'; // Hata sınıfları.
import 'package:taskly/features/todo/domain/entities/todo.dart'; // Todo nesnesi.
import 'package:taskly/features/todo/domain/repositories/todo_repository.dart'; // Depo sözleşmesi.

// 2. USE CASE SINIFI
// ---------------------------------------------------------
// İsim: "UpdateTodo" (Todo Güncelle / Düzenle).
class UpdateTodo {
  
  // Güncelleme işini yapacak olan Repository.
  final TodoRepository repository;

  // Constructor (Kurucu):
  UpdateTodo(this.repository);

  // 3. CALL METODU
  // ---------------------------------------------------------
  // Girdi (Input): 'Todo todo'
  // Burası çok önemlidir. Güncelleme işlemi için sadece ID yetmez.
  // Yeni başlığı, yeni açıklaması olan, ama ID'si ESKİ olan 
  // güncellenmiş nesnenin tamamını isteriz.
  //
  // Çıktı (Output): 'Either<Failure, Todo>'
  // Başarılı olursa güncellenmiş nesneyi geri döneriz.
  Future<Either<Failure, Todo>> call(Todo todo) {
    // Repository'e "Al bu nesneyi, kendi ID'sini bul ve üzerine yaz" deriz.
    return repository.updateTodo(todo);
  }
}