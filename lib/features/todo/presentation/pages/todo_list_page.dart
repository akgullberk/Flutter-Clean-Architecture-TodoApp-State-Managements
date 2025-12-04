// 1. İMPORTLAR (Kütüphane ve Dosya Bağlantıları)
// ---------------------------------------------------------
import 'package:flutter/material.dart'; // Flutter'ın görsel bileşenleri (Scaffold, AppBar, vb.).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskly/core/routes/app_routes.dart'; // Sayfa adreslerinin tutulduğu dosya.
import 'package:taskly/features/todo/domain/entities/todo.dart'; // Todo veri modeli.
import 'package:taskly/features/todo/presentation/widgets/todo_item_widget.dart'; // Satır görünümü widget'ı.
import 'package:taskly/features/todo/presentation/providers/todo_providers.dart';

// 2. SINIF TANIMI (Riverpod ConsumerWidget)
// ---------------------------------------------------------
class TodoListPage extends ConsumerWidget {
  const TodoListPage({super.key}); // Sabit kurucu metod.

  // 6. EKLEME SAYFASINA GİTME VE DÖNÜŞÜ DİNLEME
  // ---------------------------------------------------------
  Future<void> _navigateToAddTodo(BuildContext context, WidgetRef ref) async {
    // Başka sayfaya git ve orada iş bitene kadar BEKLE (await).
    // Gittiğimiz sayfa kapanırken bize bir sonuç dönebilir (result).
    final result = await Navigator.of(context).pushNamed(AppRoutes.todoAdd);
    
    // Eğer dönen sonuç 'true' ise (yani başarıyla kayıt yapıldıysa),
    // Listeyi yenile (_loadTodos). Böylece yeni eklenen veriyi görürüz.
    if (result == true) {
      await ref.read(todoListProvider.notifier).refresh();
    }
  }

  // 7. DURUM DEĞİŞTİRME (Toggle)
  // ---------------------------------------------------------
  Future<void> _toggleTodo(BuildContext context, WidgetRef ref, String id) async {
    // İlgili Use Case'e "Şu ID'li görevin durumunu değiştir" emrini ver.
    await ref.read(todoListProvider.notifier).toggle(id);
  }

  // 8. SİLME İŞLEMİ
  // ---------------------------------------------------------
  Future<void> _deleteTodo(BuildContext context, WidgetRef ref, String id) async {
    await ref.read(todoListProvider.notifier).delete(id);
    // Yeşil "Başarılı" mesajı göster.
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todo başarıyla silindi'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // 9. DÜZENLEME SAYFASINA GİTME
  // ---------------------------------------------------------
  Future<void> _navigateToEditTodo(
    BuildContext context,
    WidgetRef ref,
    Todo todo,
  ) async {
    // Düzenleme sayfasına git, giderken 'todo' verisini de yanında götür (arguments).
    // Ve geri dönmesini bekle (await).
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.todoEdit,
      arguments: todo,
    );
    // Eğer güncelleme yapıldıysa (result == true), listeyi yenile.
    if (result == true) {
      await ref.read(todoListProvider.notifier).refresh();
    }
  }

  // 10. ARAYÜZ ÇİZİMİ (Build Metodu)
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosState = ref.watch(todoListProvider);

    return todosState.when(
      loading: () => _buildScaffold(
        context,
        ref,
        todos: const [],
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => _buildScaffold(
        context,
        ref,
        todos: const [],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                error.toString(),
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(todoListProvider.notifier).refresh(),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
      data: (todos) {
        final body = todos.isEmpty
            // DURUM: Liste Boş -> "Görev Yok" ikonu ve yazısı.
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz todo yok',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yeni bir todo eklemek için + butonuna bas',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            // DURUM: Liste Dolu -> Verileri göster.
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(todoListProvider.notifier).refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: todos.length, // Kaç eleman var?
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      // Her satır için özel widget'ımızı kullan.
                      child: TodoItemWidget(
                        todo: todo,
                        // Widget üzerindeki butonları fonksiyonlarımıza bağlıyoruz:
                        onToggle: () =>
                            _toggleTodo(context, ref, todo.id),
                        onDelete: () =>
                            _deleteTodo(context, ref, todo.id),
                        onEdit: () =>
                            _navigateToEditTodo(context, ref, todo),
                      ),
                    );
                  },
                ),
              );

        return _buildScaffold(context, ref, todos: todos, body: body);
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    WidgetRef ref, {
    required List<Todo> todos,
    required Widget body,
  }) {
    // İstatistik hesaplamaları (Liste üzerinde filtreleme).
    final completedCount = todos.where((todo) => todo.isCompleted).length;
    final totalCount = todos.length;

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

      // --- GÖVDE (BODY) ---
      body: body,
      
      // --- FAB (Sağ alt buton) ---
      floatingActionButton: FloatingActionButton.extended(
        // Butona basınca ekleme sayfasına git.
        onPressed: () => _navigateToAddTodo(context, ref),
        backgroundColor: Colors.blue[600],
        icon: const Icon(Icons.add),
        label: const Text('Yeni Todo'),
      ),
    );
  }
}