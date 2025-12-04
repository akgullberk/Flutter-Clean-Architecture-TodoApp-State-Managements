// 1. İMPORTLAR
// ---------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider paketi.
import 'package:taskly/core/routes/app_routes.dart'; // Rota adresleri.
import 'package:taskly/features/todo/domain/entities/todo.dart'; // Todo modeli.
import 'package:taskly/features/todo/presentation/providers/todo_provider.dart'; // State Yöneticisi.
import 'package:taskly/features/todo/presentation/widgets/todo_item_widget.dart'; // Satır widget'ı.

// 2. SINIF TANIMI (STATELESS WIDGET)
// ---------------------------------------------------------
// Artık 'StatefulWidget' değil 'StatelessWidget'.
// Çünkü durumu (State) bu sınıf değil, 'TodoProvider' tutuyor.
class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  // 3. YARDIMCI METODLAR (Logic)
  // ---------------------------------------------------------
  // Stateless widget'ta 'context' global değildir.
  // Bu yüzden metodlara 'BuildContext context' parametresi ekleriz.

  // --- EKLEME SAYFASINA GİT ---
  Future<void> _navigateToAddTodo(BuildContext context) async {
    // Sayfaya git ve sonucu bekle.
    final result = await Navigator.of(context).pushNamed(AppRoutes.todoAdd);

    // Eğer kayıt başarılıysa (result == true) ve ekran hala yerindeyse (mounted):
    if (result == true && context.mounted) {
      // Provider'a "Listeyi Yenile" emri ver.
      // DİKKAT: Fonksiyon çağırırken 'read' kullanılır. (Sadece okur, dinlemez).
      await context.read<TodoProvider>().loadTodos(showLoadingIndicator: false);
    }
  }

  // --- DÜZENLEME SAYFASINA GİT ---
  Future<void> _navigateToEditTodo(BuildContext context, Todo todo) async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.todoEdit,
      arguments: todo,
    );

    if (result == true && context.mounted) {
      await context.read<TodoProvider>().loadTodos(showLoadingIndicator: false);
    }
  }

  // --- TOGGLE (Durum Değiştir) ---
  Future<void> _toggleTodo(BuildContext context, String id) async {
    // Provider'daki toggle fonksiyonunu çağır.
    // Provider bize hata varsa String, yoksa null döner.
    final error = await context.read<TodoProvider>().toggleTodo(id);

    // Eğer hata varsa ve ekran hala açıksa:
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  // --- SİLME İŞLEMİ ---
  Future<void> _deleteTodo(BuildContext context, String id) async {
    final error = await context.read<TodoProvider>().deleteTodo(id);

    if (context.mounted) {
      if (error != null) {
        // Hata Mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        // Başarı Mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todo başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // 4. ARAYÜZ ÇİZİMİ (BUILD)
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // DİKKAT: Verileri okurken 'watch' kullanılır.
    // Bu sayede Provider'da 'notifyListeners()' denildiği an burası tekrar çizilir.
    final todoProvider = context.watch<TodoProvider>();
    
    final todos = todoProvider.todos; // Güncel liste.
    final completedCount = todos.where((todo) => todo.isCompleted).length;
    final totalCount = todos.length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      
      // --- APP BAR ---
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Taskly',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        
        // --- İSTATİSTİK ALANI ---
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Sol Kutu: Toplam
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
                const SizedBox(width: 12),
                
                // Sağ Kutu: Tamamlanan
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

      // --- GÖVDE (BODY) - Provider Durumuna Göre ---
      body: todoProvider.isLoading
          // DURUM 1: Yükleniyor...
          ? const Center(child: CircularProgressIndicator())
          
          : todoProvider.errorMessage != null
              // DURUM 2: Hata Var...
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
                        // Tekrar dene butonuna basınca provider'daki loadTodos çalışır.
                        onPressed: () => context.read<TodoProvider>().loadTodos(),
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              
              : todos.isEmpty
                  // DURUM 3: Liste Boş...
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
                  
                  // DURUM 4: Liste Dolu...
                  : RefreshIndicator(
                      // Listeyi aşağı çekince verileri tazele.
                      onRefresh: () => context
                          .read<TodoProvider>()
                          .loadTodos(showLoadingIndicator: false),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TodoItemWidget(
                              todo: todo,
                              // Fonksiyonlara 'context' gönderiyoruz.
                              onToggle: () => _toggleTodo(context, todo.id),
                              onDelete: () => _deleteTodo(context, todo.id),
                              onUpdate: (updatedTodo) => // Edit için eski metodla uyumluluk
                                  _navigateToEditTodo(context, updatedTodo),
                            ),
                          );
                        },
                      ),
                    ),

      // --- FAB (Buton) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddTodo(context),
        backgroundColor: Colors.blue[600],
        icon: const Icon(Icons.add),
        label: const Text('Yeni Todo'),
      ),
    );
  }
}