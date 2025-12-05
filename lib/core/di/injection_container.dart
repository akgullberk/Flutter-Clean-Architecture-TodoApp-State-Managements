import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/features/todo/data/datasources/todo_local_data_source.dart';
import 'package:taskly/features/todo/data/models/todo_model.dart';
import 'package:taskly/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:taskly/features/todo/domain/repositories/todo_repository.dart';
import 'package:taskly/features/todo/domain/usecases/add_todo.dart';
import 'package:taskly/features/todo/domain/usecases/delete_todo.dart';
import 'package:taskly/features/todo/domain/usecases/get_all_todos.dart';
import 'package:taskly/features/todo/domain/usecases/toggle_todo.dart';
import 'package:taskly/features/todo/domain/usecases/update_todo.dart';
import 'package:taskly/features/todo/presentation/bloc/todo_bloc.dart';

// Service Locator (GetIt) instance
final sl = GetIt.instance;

/// Uygulama açıldığında bir kez çağrılır.
/// Tüm bağımlılıkların, veritabanının ve adapterlerin kurulduğu yerdir.
Future<void> init({String? hiveSubDir}) async {
  // -----------------------------
  // 1. Hive Başlatma
  // -----------------------------
  // Hive'ı Flutter için başlatır (dizin oluşturur, IO hazırlar).
  if (hiveSubDir != null) {
    Hive.init(hiveSubDir);
  } else {
    await Hive.initFlutter();
  }

  // -----------------------------
  // 2. Hive Adapter Kaydı
  // -----------------------------
  // TodoModel için adapter kayıtlı değilse ekle.
  // Adapter, model class’ını Hive’ın anlayacağı binary formata çevirir.
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TodoModelAdapter());
  }

  // -----------------------------
  // 3. Hive Box Açma
  // -----------------------------
  // 'todos' adında bir box açıyoruz. TodoModel tipinde veri tutar.
  final box = await Hive.openBox<TodoModel>('todos');

  // -----------------------------
  // 4. Box'ı Service Locator'a Kaydetme
  // -----------------------------
  // Box uygulama içinde her yerden erişilsin diye GetIt'e ekliyoruz.
  // lazySingleton => ilk ihtiyaç duyulduğunda oluşturulur.
  sl.registerLazySingleton<Box<TodoModel>>(
    () => box,
  );

  // -----------------------------
  // 5. Data Source Kaydı
  // -----------------------------
  // DataSource, box’a ihtiyaç duyar, bu yüzden sl() ile box verilir.
  // DataSource sadece veri işlerinden sorumludur.
  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(sl()),
  );

  // -----------------------------
  // 6. Repository Kaydı
  // -----------------------------
  // Repository, datasource’u kullanarak domain katmanına veri sağlar.
  // UI → Domain (soyut repository) → DataSource zinciri sağlanır.
  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(localDataSource: sl()),
  );

  // -----------------------------
  // 7. Use Case Kayıtları
  // -----------------------------
  sl
    ..registerLazySingleton(() => GetAllTodos(sl()))
    ..registerLazySingleton(() => AddTodo(sl()))
    ..registerLazySingleton(() => UpdateTodo(sl()))
    ..registerLazySingleton(() => DeleteTodo(sl()))
    ..registerLazySingleton(() => ToggleTodo(sl()));

  // -----------------------------
  // 8. Bloc Kayıtları
  // -----------------------------
  sl.registerFactory(
    () => TodoBloc(
      getAllTodos: sl(),
      toggleTodo: sl(),
      deleteTodo: sl(),
    ),
  );
}