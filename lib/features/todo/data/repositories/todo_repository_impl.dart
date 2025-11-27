// 1. İMPORTLAR VE KÜTÜPHANELER
// ---------------------------------------------------------
import 'package:dartz/dartz.dart'; // Fonksiyonel programlama kütüphanesi. 'Either' yapısı buradan gelir.
import 'package:taskly/core/error/failures.dart'; // Hata türlerimiz (Failure sınıfları).
import 'package:taskly/features/todo/data/datasources/todo_local_data_source.dart'; // Veriyi nereden çekeceğiz? (Hive).
import 'package:taskly/features/todo/data/models/todo_model.dart'; // Veritabanı formatı (Model).
import 'package:taskly/features/todo/domain/entities/todo.dart'; // Uygulama formatı (Entity).
import 'package:taskly/features/todo/domain/repositories/todo_repository.dart'; // Uyulması gereken sözleşme (Interface).

// 2. SINIF TANIMI
// ---------------------------------------------------------
// Bu sınıf, Domain katmanındaki 'TodoRepository' sözleşmesini (abstract class) uygular (implements).
// Yani Domain katmanı "Bana veri getir" der, ama verinin nereden geldiğini bilmez. Bu sınıf o işi yapar.
class TodoRepositoryImpl implements TodoRepository {
  
  // Veriye erişim aracımız (DataSource). 
  // Bugün Hive, yarın SQLite veya API olabilir. Repository sadece bu aracı kullanır.
  final TodoLocalDataSource localDataSource;

  // Constructor: Dışarıdan bir veri kaynağı verilmesini bekler (Dependency Injection).
  TodoRepositoryImpl({required this.localDataSource});

  // --- TÜM GÖREVLERİ GETİR ---
  @override
  // Dönüş tipi: Future<Either<Failure, List<Todo>>>
  // Anlamı: "Gelecekte sana bir paket vereceğim. Bu paketin SOL cebinde Hata (Failure), 
  // SAĞ cebinde ise Başarılı Sonuç (List<Todo>) olabilir."
  Future<Either<Failure, List<Todo>>> getAllTodos() async {
    try {
      // 1. Veri kaynağından "Model" listesini çekiyoruz.
      final todoModels = await localDataSource.getAllTodos();
      
      // 2. DÖNÜŞÜM (MAPPING): Model -> Entity
      // Domain katmanı 'TodoModel' tanımaz, sadece 'Todo' tanır.
      // Bu yüzden listeyi gezip (map) her modeli entity'e çeviriyoruz.
      final todos = todoModels.map((model) => model.toEntity()).toList();
      
      // 3. Başarılı sonuç (Right) döndürülür.
      return Right(todos);
    } on CacheFailure catch (failure) {
      // DataSource'dan özel bir hata (CacheFailure) gelirse, bunu SOL cebe koyup yollarız.
      return Left(failure);
    } catch (e) {
      // Beklenmeyen başka bir hata olursa, genel bir hata mesajıyla yakalarız.
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  // --- GÖREV EKLE ---
  @override
  Future<Either<Failure, Todo>> addTodo(Todo todo) async {
    try {
      // 1. DÖNÜŞÜM: Entity -> Model
      // Kaydetmek istediğimiz veri 'Todo' (Entity) formatında gelir.
      // Veritabanı sadece 'TodoModel' kabul eder. Önce çevirmemiz lazım.
      final todoModel = TodoModel.fromEntity(todo);
      
      // 2. Veri kaynağına ekleme işlemini yap.
      final addedTodo = await localDataSource.addTodo(todoModel);
      
      // 3. Eklenen veriyi tekrar Entity'e çevirip başarılı (Right) olarak döndür.
      return Right(addedTodo.toEntity());
    } on CacheFailure catch (failure) {
      return Left(failure); // Hata varsa Sol.
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  // --- GÖREV GÜNCELLE ---
  @override
  Future<Either<Failure, Todo>> updateTodo(Todo todo) async {
    try {
      // Ekleme mantığıyla aynıdır. Önce Entity'i Model'e çevir, kaydet, sonucu geri çevir.
      final todoModel = TodoModel.fromEntity(todo);
      final updatedTodo = await localDataSource.updateTodo(todoModel);
      return Right(updatedTodo.toEntity());
    } on CacheFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  // --- GÖREV SİL ---
  @override
  Future<Either<Failure, void>> deleteTodo(String id) async {
    try {
      // Sadece ID ile silme işlemi yapılır.
      await localDataSource.deleteTodo(id);
      
      // Geriye bir veri dönmesi gerekmiyor (void), işlem başarılıysa 'Right(null)' döneriz.
      return const Right(null);
    } on CacheFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  // --- DURUM DEĞİŞTİR (TOGGLE) ---
  @override
  Future<Either<Failure, Todo>> toggleTodo(String id) async {
    try {
      // DataSource'daki toggle metodunu çağırır.
      final updatedTodo = await localDataSource.toggleTodo(id);
      
      // Gelen güncel Model'i Entity'e çevirip sunar.
      return Right(updatedTodo.toEntity());
    } on CacheFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }
}