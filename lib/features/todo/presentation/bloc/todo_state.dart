// 1. DOSYA BAĞLANTISI
// ---------------------------------------------------------
// Bu dosya 'todo_bloc.dart' kütüphanesinin bir parçasıdır.
part of 'todo_bloc.dart';

// 2. DURUM ENUM'I (Status Enum)
// ---------------------------------------------------------
// UI'ın o an hangi modda olduğunu belirten basit etiketler.
// loading: Yükleniyor (Spinner dönmeli).
// success: Veri hazır (Liste gösterilmeli).
// failure: Hata var (Hata mesajı gösterilmeli).
enum TodoStatus { loading, success, failure }

// 3. STATE SINIFI (Veri Paketi)
// ---------------------------------------------------------
// Ekrandaki TÜM verileri taşıyan ana sınıf.
// Equatable'dan miras alır, böylece "Veri değişti mi?" kontrolü otomatik yapılır.
// Eğer veri değişmediyse ekran boşuna tekrar çizilmez (Performans).
class TodoState extends Equatable {
  
  // 4. KURUCU METOD (Constructor)
  // ---------------------------------------------------------
  // Başlangıç değerlerini atarız.
  // const: Performans için sabittir.
  const TodoState({
    this.status = TodoStatus.loading, // Varsayılan olarak "Yükleniyor" başla.
    this.todos = const [],            // Varsayılan olarak boş liste.
    this.errorMessage,                // Başlangıçta hata yok (null).
    this.feedbackMessage,             // Başlangıçta mesaj yok (null).
  });

  // 5. DEĞİŞKENLER (Fields)
  // ---------------------------------------------------------
  // Final: Bu değişkenler oluşturulduktan sonra ASLA değiştirilemez (Immutable).
  // Değiştirmek için yeni bir TodoState nesnesi üretmek gerekir (copyWith ile).
  
  final TodoStatus status;      // O anki durum (Yüklüyor/Başarılı/Hata).
  final List<Todo> todos;       // Ekranda gösterilecek asıl Todo listesi.
  final String? errorMessage;   // Hata varsa buraya yazılır (Örn: "İnternet yok").
  final String? feedbackMessage;// Başarı mesajı (Örn: "Todo silindi").

  // 6. KOPYALAMA METODU (copyWith)
  // ---------------------------------------------------------
  // BLoC mimarisinin en kritik metodudur.
  // Mevcut durumun fotokopisini çeker, sadece istediğimiz alanları değiştirir.
  // Neden? Çünkü değişkenlerimiz 'final' olduğu için doğrudan değiştiremeyiz.
  TodoState copyWith({
    TodoStatus? status,
    List<Todo>? todos,
    String? errorMessage,
    String? feedbackMessage,
    // Özel kontrol bayrakları:
    bool clearError = false,    // "Hata mesajını temizle" emri.
    bool clearFeedback = false, // "Geri bildirim mesajını temizle" emri.
  }) {
    return TodoState(
      // ?? Operatörü (Null Coalescing):
      // "Yeni gelen 'status' null değilse onu kullan, yoksa eskisiyle (this.status) devam et."
      status: status ?? this.status,
      todos: todos ?? this.todos,
      
      // Hata Mesajı Mantığı:
      // Eğer 'clearError' true ise -> null yap (Temizle).
      // Değilse -> Yeni mesaj varsa onu kullan, yoksa eskisini koru.
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
      
      // Geri Bildirim Mesajı Mantığı:
      // Aynı mantık; temizle denildiyse sil, yoksa güncelle veya koru.
      feedbackMessage:
          clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
    );
  }

  // 7. EŞİTLİK KONTROLÜ (Props)
  // ---------------------------------------------------------
  // Equatable kütüphanesine, iki State'in ne zaman "farklı" sayılacağını söyleriz.
  // Flutter, buradaki listedeki değerlerden biri bile değişse ekranı günceller.
  @override
  List<Object?> get props => [
        status,
        todos,
        errorMessage,
        feedbackMessage,
      ];
}