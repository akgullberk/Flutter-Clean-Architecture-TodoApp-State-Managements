// 1. İMPORTLAR
// ---------------------------------------------------------
import 'package:dartz/dartz.dart'; // Hata/Başarı kutusu (Either).
import 'package:taskly/core/error/failures.dart'; // Hata sınıfları.
import 'package:taskly/features/todo/domain/entities/todo.dart'; // Veri nesnesi.
import 'package:taskly/features/todo/domain/repositories/todo_repository.dart'; // Depo sözleşmesi.

// 2. USE CASE SINIFI
// ---------------------------------------------------------
// İsimlendirme yine çok net: "GetAllTodos" (Tüm Todoları Getir).
class GetAllTodos {
  
  // Veriyi getirecek olan Repository.
  final TodoRepository repository;

  // Constructor (Kurucu):
  // Repository'i dependency injection ile alıyoruz.
  GetAllTodos(this.repository);

  // 3. CALL METODU
  // ---------------------------------------------------------
  // Girdi (Input): Parantez içi boş '()'. Çünkü tüm listeyi isterken
  // özel bir parametreye ihtiyacımız yok.
  //
  // Çıktı (Output): 'Either<Failure, List<Todo>>'
  // Sağ cepte (Başarı) bu sefer tek bir Todo değil, 'List<Todo>' (Todolar Listesi) var.
  Future<Either<Failure, List<Todo>>> call() {
    // Repository'deki listeleme fonksiyonunu çağırır ve sonucu olduğu gibi geri döner.
    return repository.getAllTodos();
  }
}