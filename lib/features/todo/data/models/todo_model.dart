// 1. KÜTÜPHANELER VE BAĞLANTILAR
// ---------------------------------------------------------
import 'package:hive/hive.dart'; // Hive veritabanı özelliklerini kullanmak için gerekli.
import 'package:taskly/features/todo/domain/entities/todo.dart'; // Domain katmanındaki saf 'Todo' sınıfı.

// Bu satır çok kritiktir. 'todo_model.g.dart' dosyası biz kodu yazarken yoktur.
// Terminalde "build_runner" komutunu çalıştırdığımızda otomatik oluşturulur.
// Hive'ın verileri okuyup yazması için gereken "TypeAdapter" kodları o dosyanın içindedir.
part 'todo_model.g.dart'; 


// 2. HIVE TANIMLAMALARI (ANNOTATIONS)
// ---------------------------------------------------------

// @HiveType: Bu sınıfın Hive tarafından saklanabilir bir nesne olduğunu belirtir.
// typeId: 0 -> Bu ID çok önemlidir. Veritabanındaki her farklı modelin (User, Todo, Settings vb.)
// benzersiz bir numarası olmalıdır.
@HiveType(typeId: 0)
class TodoModel extends HiveObject {
  // HiveObject'ten miras almak (extends), bu nesneye .save() veya .delete() gibi
  // doğrudan veritabanı yetenekleri kazandırır.

  // @HiveField(0): Veritabanındaki sütun numarası gibi düşünebilirsiniz.
  // Bu numaraları ASLA değiştirmemelisiniz. Değiştirirseniz eski veriler bozulur.
  @HiveField(0)
  final String id; // Görevin benzersiz kimliği.

  @HiveField(1)
  final String title; // Başlık.

  @HiveField(2)
  final String description; // Açıklama.

  @HiveField(3)
  final bool isCompleted; // Tamamlandı mı?

  @HiveField(4)
  final DateTime createdAt; // Oluşturulma tarihi.

  @HiveField(5)
  final DateTime? completedAt; // Tamamlanma tarihi (Boş olabilir, o yüzden ? var).


  // 3. KURUCU METOD (CONSTRUCTOR)
  // ---------------------------------------------------------
  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt, // Zorunlu değil (required yok), null gelebilir.
  });


  // 4. DÖNÜŞTÜRME METODLARI (MAPPING)
  // ---------------------------------------------------------
  // Clean Architecture'da katmanlar arası veri taşırken dönüşüm yapılır.
  
  // Entity -> Model Dönüşümü
  // Uygulama içinde kullanılan saf 'Todo' nesnesini, veritabanına kaydedilecek 'TodoModel'e çevirir.
  // Genellikle "Kaydetme" veya "Güncelleme" işlemi yapılırken kullanılır.
  factory TodoModel.fromEntity(Todo todo) {
    return TodoModel(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      isCompleted: todo.isCompleted,
      createdAt: todo.createdAt,
      completedAt: todo.completedAt,
    );
  }

  // Model -> Entity Dönüşümü
  // Veritabanından gelen ham 'TodoModel' verisini, uygulamanın kullanacağı 'Todo' nesnesine çevirir.
  // Verileri "Listeleme" yaparken kullanılır.
  Todo toEntity() {
    return Todo(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted,
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }


  // 5. KOPYALAMA METODU (COPYWITH)
  // ---------------------------------------------------------
  // Nesnenin kendisini değiştirmeden, sadece belirli alanlarını değiştirip
  // yeni bir kopyasını oluşturmak için kullanılır.
  // Örn: Sadece isCompleted alanını 'true' yapıp diğer her şeyi aynı tutmak.
  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TodoModel(
      // ?? operatörü: "Eğer yeni bir değer geldiyse onu kullan, gelmediyse (null ise) eskisi kalsın."
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}