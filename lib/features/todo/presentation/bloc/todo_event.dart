// 1. DOSYA BAĞLANTISI
// ---------------------------------------------------------
// Bu dosya tek başına bir kütüphane değildir, 'todo_bloc.dart' dosyasının bir parçasıdır.
// Bu sayede o dosyadaki private değişkenlere erişebilir ve tek bir kütüphane gibi davranır.
part of 'todo_bloc.dart';

// 2. TEMEL OLAY SINIFI (Abstract Base Class)
// ---------------------------------------------------------
// Tüm olayların atası olan soyut sınıf.
// Abstract (Soyut) olmasının nedeni: Kod içinde doğrudan "TodoEvent" diye bir şey üretmeyiz.
// Her zaman "TodoRefreshRequested" gibi somut alt sınıfları üretiriz.
// Equatable: İki nesnenin (Event'in) birbirinin aynısı olup olmadığını anlamak için kullanılır.
abstract class TodoEvent extends Equatable {
  const TodoEvent(); // Sabit kurucu metod (Performans için).

  // Equatable'ın zorunlu kıldığı metod.
  // İki event kıyaslanırken hangi özelliklerine bakılacağını belirler.
  // Boş liste döndürmek, "Bu sınıfın kıyaslanacak ekstra bir özelliği yok" demektir.
  @override
  List<Object?> get props => [];
}

// 3. LİSTELEME / YENİLEME OLAYI (Refresh Event)
// ---------------------------------------------------------
// Uygulama ilk açıldığında veya listeyi aşağı çekip yenilediğimizde bu sınıfı çağırırız.
class TodoRefreshRequested extends TodoEvent {
  // Constructor: İsteğe bağlı bir "feedbackMessage" (geri bildirim mesajı) alabilir.
  const TodoRefreshRequested({this.feedbackMessage});

  // Neden mesaja ihtiyaç var?
  // Örneğin: Bir silme işlemi yaptıktan sonra listeyi yenilemek istiyoruz.
  // Bu olayı çağırırken "Silme başarılı" mesajını da içine koyup göndeririz.
  // Böylece State güncellendiğinde UI bu mesajı kullanıcıya (SnackBar olarak) gösterebilir.
  final String? feedbackMessage;

  // Kıyaslama listesine bu mesajı ekliyoruz.
  // Eğer mesaj farklıysa, bu farklı bir event olarak algılanır.
  @override
  List<Object?> get props => [feedbackMessage];
}

// 4. DURUM DEĞİŞTİRME OLAYI (Toggle Event)
// ---------------------------------------------------------
// Kullanıcı bir görevi tamamlandı/tamamlanmadı yapmak istediğinde bu sınıfı gönderir.
class TodoToggleRequested extends TodoEvent {
  // Hangi görevi güncelleyeceğimizi bilmek için ID zorunludur.
  const TodoToggleRequested(this.id);

  final String id;

  // Kıyaslama listesi: ID değişirse event değişmiş sayılır.
  @override
  List<Object?> get props => [id];
}

// 5. SİLME OLAYI (Delete Event)
// ---------------------------------------------------------
// Kullanıcı çöp kutusu ikonuna bastığında bu olay tetiklenir.
class TodoDeleteRequested extends TodoEvent {
  // Hangi görevi sileceğimizi bilmek için ID zorunludur.
  const TodoDeleteRequested(this.id);

  final String id;

  // Kıyaslama listesi.
  @override
  List<Object?> get props => [id];
}