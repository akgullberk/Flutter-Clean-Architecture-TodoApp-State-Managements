// 1. İMPORTLAR
// ---------------------------------------------------------
import 'package:dartz/dartz.dart'; // Either yapısı için.
import 'package:taskly/core/error/failures.dart'; // Hata sınıfları.
import 'package:taskly/features/todo/domain/repositories/todo_repository.dart'; // Depo sözleşmesi.

// 2. USE CASE SINIFI
// ---------------------------------------------------------
// Sınıfın adı yine eylemi anlatıyor: "DeleteTodo" (Todo Sil).
class DeleteTodo {
  
  // Silme işlemini gerçekleştirecek olan Repository'ye ihtiyacımız var.
  final TodoRepository repository;

  // Constructor (Kurucu):
  // Dependency Injection ile Repository'i içeri alıyoruz.
  DeleteTodo(this.repository);

  // 3. CALL METODU
  // ---------------------------------------------------------
  // Girdi (Input): Silinecek görevin sadece ID'si yeterlidir ('String id').
  // Çıktı (Output): 'Either<Failure, void>' 
  // Burada 'void' olması önemlidir. Başarılı taraf (Right) boştur.
  Future<Either<Failure, void>> call(String id) {
    // Repository'deki silme fonksiyonunu tetikler.
    return repository.deleteTodo(id);
  }
}