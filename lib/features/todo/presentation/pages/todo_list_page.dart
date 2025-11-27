// 1. İMPORTLAR (Kütüphane ve Dosya Bağlantıları)
// ---------------------------------------------------------
import 'package:flutter/material.dart'; // Flutter'ın görsel bileşenleri (Scaffold, AppBar, vb.).
import 'package:taskly/core/di/injection_container.dart'; // 'sl' (Service Locator) nesnesi buradan gelir.
import 'package:taskly/core/routes/app_routes.dart'; // Sayfa adreslerinin tutulduğu dosya.
import 'package:taskly/features/todo/domain/entities/todo.dart'; // Todo veri modeli.

// DİKKAT: Artık Repository importu YOK. Sadece Use Case'ler var.
import 'package:taskly/features/todo/domain/usecases/add_todo.dart'; 
import 'package:taskly/features/todo/domain/usecases/delete_todo.dart';
import 'package:taskly/features/todo/domain/usecases/get_all_todos.dart';
import 'package:taskly/features/todo/domain/usecases/toggle_todo.dart';
import 'package:taskly/features/todo/domain/usecases/update_todo.dart';
import 'package:taskly/features/todo/presentation/widgets/todo_item_widget.dart'; // Satır görünümü widget'ı.

// 2. SINIF TANIMI (StatefulWidget)
// ---------------------------------------------------------
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key}); // Sabit kurucu metod.

  @override
  // Durum (State) nesnesini oluşturur.
  State<TodoListPage> createState() => _TodoListPageState();
}

// 3. STATE SINIFI VE BAĞIMLILIKLAR
// ---------------------------------------------------------
class _TodoListPageState extends State<TodoListPage> {
  // Dependency Injection (DI) ile Use Case'leri çağırıyoruz.
  // "sl<GetAllTodos>()" demek: "Bana GetAllTodos sınıfının hazır bir örneğini ver."
  // Artık emirleri bu değişkenler üzerinden vereceğiz.
  final GetAllTodos _getAllTodos = sl<GetAllTodos>();
  final AddTodo _addTodoUseCase = sl<AddTodo>();
  final UpdateTodo _updateTodoUseCase = sl<UpdateTodo>(); // Not: Bu örnekte kullanılmamış ama hazırda bekliyor.
  final DeleteTodo _deleteTodoUseCase = sl<DeleteTodo>();
  final ToggleTodo _toggleTodoUseCase = sl<ToggleTodo>();

  // Sayfanın durumunu tutan değişkenler:
  List<Todo> _todos = [];   // Ekranda gösterilecek liste.
  bool _isLoading = true;   // Yükleme çemberi dönsün mü?
  String? _errorMessage;    // Hata var mı?

  // 4. BAŞLANGIÇ AYARLARI (InitState)
  // ---------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _loadTodos(); // Sayfa açılır açılmaz verileri çekmeye başla.
  }

  // 5. VERİLERİ ÇEKME FONKSİYONU
  // ---------------------------------------------------------
  Future<void> _loadTodos() async {
    // Önce ekranı "Yükleniyor" moduna al.
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Varsa eski hata mesajını temizle.
    });

    // Use Case'i çağır.
    // DİKKAT: "_getAllTodos()" şeklinde parantez ile çağırıyoruz.
    // Çünkü Use Case içine "call" metodu yazdık (Callable Class).
    final result = await _getAllTodos();

    // Sonuç kutusunu (Either) aç:
    result.fold(
      (failure) {
        // SOL CEP (Hata):
        setState(() {
          _errorMessage = failure.message ?? 'Bir hata oluştu';
          _isLoading = false; // Yüklemeyi durdur.
        });
      },
      (todos) {
        // SAĞ CEP (Başarı):
        setState(() {
          _todos = todos; // Listeyi güncelle.
          _isLoading = false; // Yüklemeyi durdur.
        });
      },
    );
  }

  // 6. EKLEME SAYFASINA GİTME VE DÖNÜŞÜ DİNLEME
  // ---------------------------------------------------------
  Future<void> _navigateToAddTodo() async {
    // Başka sayfaya git ve orada iş bitene kadar BEKLE (await).
    // Gittiğimiz sayfa kapanırken bize bir sonuç dönebilir (result).
    final result = await Navigator.of(context).pushNamed(AppRoutes.todoAdd);
    
    // Eğer dönen sonuç 'true' ise (yani başarıyla kayıt yapıldıysa),
    // Listeyi yenile (_loadTodos). Böylece yeni eklenen veriyi görürüz.
    if (result == true) {
      _loadTodos();
    }
  }

  // 7. DURUM DEĞİŞTİRME (Toggle)
  // ---------------------------------------------------------
  Future<void> _toggleTodo(String id) async {
    // İlgili Use Case'e "Şu ID'li görevin durumunu değiştir" emrini ver.
    final result = await _toggleTodoUseCase(id);
    
    result.fold(
      (failure) {
        // Hata varsa altta kırmızı uyarı (SnackBar) göster.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message ?? 'Todo güncellenirken hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (_) {
        // Başarılıysa (Sağ taraf boş/veri önemsiz), listeyi yenile.
        // Aslında sadece ilgili satırı güncellemek daha performanslı olurdu
        // ama şimdilik listeyi yenilemek en güvenli yol.
        _loadTodos();
      },
    );
  }

  // 8. SİLME İŞLEMİ
  // ---------------------------------------------------------
  Future<void> _deleteTodo(String id) async {
    // Use Case'e "Sil" emri ver.
    final result = await _deleteTodoUseCase(id);
    
    result.fold(
      (failure) {
        // Hata mesajı göster.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message ?? 'Todo silinirken hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (_) {
        // Başarılıysa:
        _loadTodos(); // Listeyi yenile.
        if (mounted) { // Sayfa hala ekrandaysa (kapanmadıysa).
          // Yeşil "Başarılı" mesajı göster.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Todo başarıyla silindi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }

  // 9. DÜZENLEME SAYFASINA GİTME
  // ---------------------------------------------------------
  Future<void> _navigateToEditTodo(Todo todo) async {
    // Düzenleme sayfasına git, giderken 'todo' verisini de yanında götür (arguments).
    // Ve geri dönmesini bekle (await).
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.todoEdit,
      arguments: todo,
    );
    // Eğer güncelleme yapıldıysa (result == true), listeyi yenile.
    if (result == true) {
      _loadTodos();
    }
  }

  // 10. ARAYÜZ ÇİZİMİ (Build Metodu)
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // İstatistik hesaplamaları (Liste üzerinde filtreleme).
    final completedCount = _todos.where((todo) => todo.isCompleted).length;
    final totalCount = _todos.length;

    return Scaffold(
      backgroundColor: Colors.grey[100], // Hafif gri arka plan.
      
      // --- APP BAR (Üst Çubuk) ---
      appBar: AppBar(
        elevation: 0, // Gölge yok.
        title: const Text(
          'Taskly',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false, // Sola yaslı başlık.
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        
        // App Bar'ın altındaki istatistik alanı.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Sol Kutu: Toplam Sayı
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), // Şeffaf beyaz.
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text('$totalCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const Text('Toplam', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12), // Boşluk.
                // Sağ Kutu: Tamamlanan Sayı
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text('$completedCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const Text('Tamamlanan', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // --- GÖVDE (BODY) - 4 FARKLI DURUM ---
      body: _isLoading
          // DURUM 1: Yükleniyor -> Dönen çember.
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              // DURUM 2: Hata Var -> Hata ikonu, mesajı ve butonu.
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTodos, // Butona basınca tekrar dene.
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : _todos.isEmpty
                  // DURUM 3: Liste Boş -> "Görev Yok" ikonu ve yazısı.
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz todo yok',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Yeni bir todo eklemek için + butonuna bas',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  // DURUM 4: Liste Dolu -> Verileri göster.
                  : RefreshIndicator(
                      onRefresh: _loadTodos, // Listeyi aşağı çekince yenile.
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _todos.length, // Kaç eleman var?
                        itemBuilder: (context, index) {
                          final todo = _todos[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            // Her satır için özel widget'ımızı kullan.
                            child: TodoItemWidget(
                              todo: todo,
                              // Widget üzerindeki butonları fonksiyonlarımıza bağlıyoruz:
                              onToggle: () => _toggleTodo(todo.id),
                              onDelete: () => _deleteTodo(todo.id),
                              onEdit: () => _navigateToEditTodo(todo), // Edit butonu için bağlantı.
                            ),
                          );
                        },
                      ),
                    ),
      
      // --- FAB (Sağ alt buton) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddTodo, // Butona basınca ekleme sayfasına git.
        backgroundColor: Colors.blue[600],
        icon: const Icon(Icons.add),
        label: const Text('Yeni Todo'),
      ),
    );
  }
}