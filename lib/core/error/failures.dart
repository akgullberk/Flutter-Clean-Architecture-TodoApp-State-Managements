// 1. KÜTÜPHANE
// ---------------------------------------------------------
import 'package:equatable/equatable.dart'; // Nesne karşılaştırması için.

// 2. ANA HATA SINIFI (ABSTRACT)
// ---------------------------------------------------------
// 'abstract' olması, bu sınıftan doğrudan nesne üretilemeyeceği anlamına gelir.
// Yani kodun içinde "new Failure()" diyemezsiniz.
// Mutlaka bunun alt türlerini (ServerFailure, CacheFailure) kullanmalısınız.
abstract class Failure extends Equatable {
  
  // Kurucu Metod:
  // Opsiyonel bir mesaj alabilir ([this.message]).
  // const: Bu nesneler oluşturulduktan sonra değiştirilemez.
  const Failure([this.message]);

  // Hata mesajını tutan değişken.
  // Örneğin: "İnternet bağlantısı yok" veya "Disk dolu".
  final String? message;

  // Equatable'ın Karşılaştırma Mantığı:
  // İki hata nesnesinin eşit olup olmadığına 'message' alanına bakarak karar ver.
  // Eğer bunu yapmasaydık, aynı mesajı taşıyan iki hata "Farklı" sayılırdı.
  // Test yazarken: expect(result, ServerFailure('Hata')) diyebilmek için gereklidir.
  @override
  List<Object?> get props => [message];
}

// 3. ALT HATA SINIFLARI (SUBCLASSES)
// ---------------------------------------------------------
// Bu sınıflar, hatanın "Kaynağını" belirtir.

// SERVER FAILURE: Sunucu / API kaynaklı hatalar.
// Örn: 404 Not Found, 500 Internal Server Error.
class ServerFailure extends Failure {
  // super.message: Gelen mesajı alıp yukarıdaki (abstract Failure) sınıfına paslar.
  const ServerFailure([super.message]);
}

// CACHE FAILURE: Yerel Veritabanı (Hive/SQLite) kaynaklı hatalar.
// Örn: Veri okunamadı, yazma izni yok, disk dolu.
class CacheFailure extends Failure {
  const CacheFailure([super.message]);
}

// NETWORK FAILURE: Ağ bağlantısı kaynaklı hatalar.
// Örn: İnternet kesik, Wi-Fi kapalı.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);
}