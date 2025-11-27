// 1. İMPORTLAR
// ---------------------------------------------------------
import 'package:dartz/dartz.dart'; // Hata/Başarı yönetimi (Either) için.
import 'package:taskly/core/error/failures.dart'; // Hata sınıfları.
import 'package:taskly/features/todo/domain/entities/todo.dart'; // Todo nesnesi.
import 'package:taskly/features/todo/domain/repositories/todo_repository.dart'; // Depo sözleşmesi.

// 2. USE CASE SINIFI
// ---------------------------------------------------------
// Sınıfın ismi yapılan eylemi net bir şekilde anlatır: "AddTodo" (Todo Ekle).
class AddTodo {
  
  // Bu eylemi gerçekleştirmek için bir Repository'ye ihtiyacımız var.
  // Çünkü veriyi kaydedecek olan o.
  final TodoRepository repository;

  // Constructor (Kurucu):
  // Dışarıdan bir repository bekler (Dependency Injection).
  AddTodo(this.repository);

  // 3. CALL METODU (SIHİRLİ METOD)
  // ---------------------------------------------------------
  // Dart dilinde 'call' ismi özel bir anlam taşır.
  // Bir sınıfın içinde 'call' metodu varsa, o sınıfın örneği (instance)
  // sanki bir fonksiyonmuş gibi kullanılabilir.
  // 
  // Future<Either...>: İşlem asenkron olacak ve sonuç ya Hata ya Todo dönecek.
  Future<Either<Failure, Todo>> call(Todo todo) {
    // Gelen emri olduğu gibi Repository'e iletir.
    // Eğer ekleme yapmadan önce bir kontrol yapmamız gerekseydi (Örn: "Başlık 3 harften kısa olamaz"),
    // o kodları tam olarak BURAYA yazardık.
    return repository.addTodo(todo);
  }
}