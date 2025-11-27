// 1. İMPORTLAR
// ---------------------------------------------------------
import 'package:dartz/dartz.dart'; // Hata/Başarı yapısı (Either).
import 'package:taskly/core/error/failures.dart'; // Hata sınıfları.
import 'package:taskly/features/todo/domain/entities/todo.dart'; // Todo nesnesi.
import 'package:taskly/features/todo/domain/repositories/todo_repository.dart'; // Depo sözleşmesi.

// 2. USE CASE SINIFI
// ---------------------------------------------------------
// İsim: "ToggleTodo" (Durum Değiştir).
// Yazılımda "Toggle", elektrik anahtarı gibi bir şeyi "Açık <-> Kapalı" 
// arasında değiştirme işlemine denir.
class ToggleTodo {
  
  // İşlemi yapacak Repository.
  final TodoRepository repository;

  // Constructor (Kurucu):
  ToggleTodo(this.repository);

  // 3. CALL METODU
  // ---------------------------------------------------------
  // Girdi (Input): Sadece 'String id' alır. Hangi görevin durumunu değiştireceğiz?
  //
  // Çıktı (Output): 'Either<Failure, Todo>'
  // Burası önemli: Geriye "void" değil, güncellenmiş "Todo" nesnesini döndürüyoruz.
  Future<Either<Failure, Todo>> call(String id) {
    return repository.toggleTodo(id);
  }
}