// 1. KÜTÜPHANE İMPORTLARI
// ---------------------------------------------------------
import 'package:bloc/bloc.dart'; // BLoC yapısının temel kütüphanesi.
import 'package:equatable/equatable.dart'; // Nesneleri kıyaslamak için (State değişti mi anlamak için).
// Domain katmanından gelen bağımlılıklar (Entity ve UseCase'ler).
import 'package:taskly/features/todo/domain/entities/todo.dart';
import 'package:taskly/features/todo/domain/usecases/delete_todo.dart';
import 'package:taskly/features/todo/domain/usecases/get_all_todos.dart';
import 'package:taskly/features/todo/domain/usecases/toggle_todo.dart';

// 2. PARÇALI DOSYA TANIMLARI
// ---------------------------------------------------------
// Bu dosya tek başına çalışmaz; 'event' ve 'state' dosyalarıyla bir bütündür.
// part keyword'ü, bu dosyaların birbirinin private üyelerine erişmesini sağlar.
part 'todo_event.dart';
part 'todo_state.dart';

// 3. BLOC SINIFI TANIMI
// ---------------------------------------------------------
// TodoBloc: İş mantığının merkezi.
// <TodoEvent, TodoState>: Bu kutuya "TodoEvent" girer, dışarıya "TodoState" çıkar.
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  
  // 4. CONSTRUCTOR (KURUCU METOD) VE BAĞIMLILIK ENJEKSİYONU
  // ---------------------------------------------------------
  // Bloc çalışmak için UseCase'lere ihtiyaç duyar (Database'e erişen sınıflar).
  // Bunları "required" olarak istiyoruz.
  TodoBloc({
    required GetAllTodos getAllTodos,
    required ToggleTodo toggleTodo,
    required DeleteTodo deleteTodo,
  })  : _getAllTodos = getAllTodos, // Gelenleri private değişkenlere atıyoruz.
        _toggleTodo = toggleTodo,
        _deleteTodo = deleteTodo,
        // super: Başlangıç durumunu (Initial State) belirliyoruz.
        super(const TodoState()) {
    
    // 5. OLAY (EVENT) KAYITLARI (Event Handlers)
    // ---------------------------------------------------------
    // "Eğer kapıdan şu Olay girerse, şu Fonksiyonu çalıştır" dediğimiz yer.
    
    // Kullanıcı listeyi yenilemek isterse '_onRefreshRequested' çalışsın.
    on<TodoRefreshRequested>(_onRefreshRequested);
    
    // Kullanıcı bir görevi işaretlerse (check/uncheck) '_onToggleRequested' çalışsın.
    on<TodoToggleRequested>(_onToggleRequested);
    
    // Kullanıcı silme butonuna basarsa '_onDeleteRequested' çalışsın.
    on<TodoDeleteRequested>(_onDeleteRequested);
  }

  // Private değişkenler (Sadece bu sınıf içinde kullanılır).
  final GetAllTodos _getAllTodos;
  final ToggleTodo _toggleTodo;
  final DeleteTodo _deleteTodo;

  // 6. LİSTELEME MANTIĞI (Refresh)
  // ---------------------------------------------------------
  Future<void> _onRefreshRequested(
    TodoRefreshRequested event, // Gelen olay verisi.
    Emitter<TodoState> emit,    // State gönderme aracı (Hoparlör gibi düşün).
  ) async {
    // ADIM 1: Yükleniyor durumunu bildir.
    // UI'da dönen çark (Spinner) görünmesi için status: loading yapıyoruz.
    // copyWith: Mevcut durumu kopyala, sadece değişenleri güncelle (Immutability).
    emit(
      state.copyWith(
        status: TodoStatus.loading,
        clearError: true, // Önceki hataları temizle.
        clearFeedback: true,
      ),
    );

    // ADIM 2: Veritabanına git (UseCase çağrısı).
    final result = await _getAllTodos();

    // ADIM 3: Sonucu işle (Fold: Hata mı, Başarı mı?).
    result.fold(
      // SOL (Left): Hata durumu.
      (failure) => emit(
        state.copyWith(
          status: TodoStatus.failure, // Durumu "Hata" yap.
          errorMessage: failure.message ?? 'Todo listesi yüklenemedi.',
        ),
      ),
      // SAĞ (Right): Başarı durumu.
      (todos) => emit(
        state.copyWith(
          status: TodoStatus.success, // Durumu "Başarılı" yap.
          todos: todos, // Gelen listeyi state'e koy.
          clearError: true,
        ),
      ),
    );
  }

  // 7. DURUM DEĞİŞTİRME MANTIĞI (Toggle)
  // ---------------------------------------------------------
  Future<void> _onToggleRequested(
    TodoToggleRequested event,
    Emitter<TodoState> emit,
  ) async {
    // ADIM 1: Yükleniyor...
    emit(
      state.copyWith(
        status: TodoStatus.loading,
        clearError: true,
        clearFeedback: true,
      ),
    );

    // ADIM 2: ID ile güncelleme isteği gönder.
    final result = await _toggleTodo(event.id);

    // ADIM 3: Sonucu işle.
    result.fold(
      // Hata varsa bildir.
      (failure) => emit(
        state.copyWith(
          status: TodoStatus.failure,
          errorMessage: failure.message ?? 'Todo güncellenemedi.',
        ),
      ),
      // Başarılıysa (_ -> dönüş değeri önemsiz):
      (_) {
        // BURASI KRİTİK:
        // Bloc içinde başka bir Event tetikliyoruz!
        // Güncelleme başarılı olduğu için "Listeyi Yenile" olayını (Refresh) çağırıyoruz.
        // Böylece liste veritabanından güncel haliyle tekrar çekiliyor.
        add(const TodoRefreshRequested());
      },
    );
  }

  // 8. SİLME MANTIĞI (Delete)
  // ---------------------------------------------------------
  Future<void> _onDeleteRequested(
    TodoDeleteRequested event,
    Emitter<TodoState> emit,
  ) async {
    // ADIM 1: Yükleniyor...
    emit(
      state.copyWith(
        status: TodoStatus.loading,
        clearError: true,
        clearFeedback: true,
      ),
    );

    // ADIM 2: Silme isteği gönder.
    final result = await _deleteTodo(event.id);

    // ADIM 3: Sonucu işle.
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TodoStatus.failure,
          errorMessage: failure.message ?? 'Todo silinemedi.',
        ),
      ),
      (_) {
        // Başarılıysa yine "Listeyi Yenile" olayını tetikliyoruz.
        // Farklı olarak: UI'da SnackBar göstermek için bir "feedbackMessage" gönderiyoruz.
        add(
          const TodoRefreshRequested(
            feedbackMessage: 'Todo başarıyla silindi',
          ),
        );
      },
    );
  }
}