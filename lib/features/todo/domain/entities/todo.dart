// 1. KÜTÜPHANE
// ---------------------------------------------------------
// Nesneleri birbirleriyle kıyaslamayı kolaylaştıran popüler paket.
// Normalde Dart'ta iki nesnenin içindeki veriler aynı olsa bile
// hafızadaki yerleri farklı olduğu için "Eşit Değil" sayılırlar.
// Equatable, içindeki verilere bakarak "Eşit" dememizi sağlar.
import 'package:equatable/equatable.dart';

// 2. SINIF TANIMI
// ---------------------------------------------------------
// Todo sınıfı Equatable'dan miras alır.
// Bu sayede == operatörünü otomatik olarak güçlendirmiş oluruz.
class Todo extends Equatable {
  
  // 3. KURUCU METOD (CONSTRUCTOR)
  // ---------------------------------------------------------
  // const: Bu nesne oluşturulduktan sonra asla değişmeyeceği için 'const' ile işaretlenir.
  // Bu, Flutter'ın performansını artırır (gereksiz yere yeniden oluşturulmaz).
  const Todo({
    required this.id,          // Zorunlu alan
    required this.title,       // Zorunlu alan
    required this.description, // Zorunlu alan
    required this.isCompleted, // Zorunlu alan
    required this.createdAt,   // Zorunlu alan
    this.completedAt,          // Opsiyonel (Null olabilir)
  });

  // 4. DEĞİŞKENLER (FIELDS)
  // ---------------------------------------------------------
  // final: Değişkenlere sadece bir kez (constructor'da) değer atanabilir.
  // Sonradan 'todo.title = "Yeni Başlık"' diyemezsiniz. Değişmezlik (Immutability) kuralı.
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt; // ? işareti, bu alanın boş (null) olabileceğini gösterir.

  // 5. KOPYALAMA METODU (COPYWITH)
  // ---------------------------------------------------------
  // Değişkenler 'final' olduğu için, bir alanı değiştirmek istediğimizde
  // nesnenin kendisini değiştiremeyiz.
  // Bunun yerine, eski nesnedeki verileri alıp, sadece istediğimiz alanı değiştirerek
  // YENİ bir nesne oluştururuz.
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Todo(
      // ?? Operatörü Mantığı:
      // "Eğer fonksiyona yeni bir 'id' gönderildiyse onu kullan,
      // gönderilmediyse (null ise) bu nesnenin mevcut id'sini (this.id) kullan."
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // 6. EŞİTLİK KONTROLÜ (PROPS)
  // ---------------------------------------------------------
  // Equatable'ın kalbi burasıdır.
  // İki Todo nesnesini karşılaştırırken (todo1 == todo2) hangi alanlara bakılması gerektiğini söyleriz.
  @override
  List<Object?> get props => [
        id,
        title,
        description,
        isCompleted,
        createdAt,
        completedAt,
      ];
}