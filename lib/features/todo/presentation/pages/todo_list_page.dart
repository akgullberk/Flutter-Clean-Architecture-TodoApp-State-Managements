// 1. İMPORTLAR (Kütüphane ve Dosya Bağlantıları)
// ---------------------------------------------------------
import 'package:flutter/material.dart'; // Flutter'ın görsel bileşenleri (Scaffold, AppBar, vb.).
import 'package:provider/provider.dart';
import 'package:taskly/core/routes/app_routes.dart'; // Sayfa adreslerinin tutulduğu dosya.
import 'package:taskly/features/todo/domain/entities/todo.dart'; // Todo veri modeli.
import 'package:taskly/features/todo/presentation/providers/todo_provider.dart';
import 'package:taskly/features/todo/presentation/widgets/todo_item_widget.dart'; // Satır görünümü widget'ı.

// 2. SINIF TANIMI
// ---------------------------------------------------------
class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key}); // Sabit kurucu metod.

  Future<void> _navigateToAddTodo(BuildContext context) async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.todoAdd);
    if (result == true && context.mounted) {
      await context.read<TodoProvider>().loadTodos(showLoadingIndicator: false);
    }
  }

  Future<void> _navigateToEditTodo(BuildContext context, Todo todo) async {
    final result = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.todoEdit, arguments: todo);
    if (result == true && context.mounted) {
      await context.read<TodoProvider>().loadTodos(showLoadingIndicator: false);
    }
  }

  Future<void> _toggleTodo(BuildContext context, String id) async {
    final error = await context.read<TodoProvider>().toggleTodo(id);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteTodo(BuildContext context, String id) async {
    final error = await context.read<TodoProvider>().deleteTodo(id);
    if (context.mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todo başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // 3. ARAYÜZ ÇİZİMİ (Build Metodu)
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final todoProvider = context.watch<TodoProvider>();
    final todos = todoProvider.todos;
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
                        Text(
                          '$totalCount',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Toplam',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
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
                        Text(
                          '$completedCount',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Tamamlanan',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
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
      body:
          todoProvider.isLoading
              // DURUM 1: Yükleniyor -> Dönen çember.
              ? const Center(child: CircularProgressIndicator())
              : todoProvider.errorMessage != null
              // DURUM 2: Hata Var -> Hata ikonu, mesajı ve butonu.
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      todoProvider.errorMessage!,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          () =>
                              todoProvider
                                  .loadTodos(), // Butona basınca tekrar dene.
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              )
              : todos.isEmpty
              // DURUM 3: Liste Boş -> "Görev Yok" ikonu ve yazısı.
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
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              // DURUM 4: Liste Dolu -> Verileri göster.
              : RefreshIndicator(
                onRefresh:
                    () => todoProvider.loadTodos(
                      showLoadingIndicator: false,
                    ), // Listeyi aşağı çekince yenile.
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
                        onToggle: () => _toggleTodo(context, todo.id),
                        onDelete: () => _deleteTodo(context, todo.id),
                        onEdit:
                            () => _navigateToEditTodo(
                              context,
                              todo,
                            ), // Edit butonu için bağlantı.
                      ),
                    );
                  },
                ),
              ),

      // --- FAB (Sağ alt buton) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => _navigateToAddTodo(
              context,
            ), // Butona basınca ekleme sayfasına git.
        backgroundColor: Colors.blue[600],
        icon: const Icon(Icons.add),
        label: const Text('Yeni Todo'),
      ),
    );
  }
}
