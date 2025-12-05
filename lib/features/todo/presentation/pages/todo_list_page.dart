import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/core/routes/app_routes.dart';
import 'package:taskly/features/todo/domain/entities/todo.dart';
import 'package:taskly/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:taskly/features/todo/presentation/widgets/todo_item_widget.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  Future<void> _navigateToAddTodo(BuildContext context) async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.todoAdd);
    if (result == true && context.mounted) {
      context.read<TodoBloc>().add(const TodoRefreshRequested());
    }
  }

  Future<void> _toggleTodo(BuildContext context, String id) async {
    context.read<TodoBloc>().add(TodoToggleRequested(id));
  }

  Future<void> _deleteTodo(BuildContext context, String id) async {
    context.read<TodoBloc>().add(TodoDeleteRequested(id));
  }

  Future<void> _navigateToEditTodo(
    BuildContext context,
    Todo todo,
  ) async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.todoEdit,
      arguments: todo,
    );
    if (result == true && context.mounted) {
      context.read<TodoBloc>().add(const TodoRefreshRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoBloc, TodoState>(
      listenWhen: (previous, current) =>
          previous.feedbackMessage != current.feedbackMessage ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state.errorMessage != null &&
            state.status != TodoStatus.loading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        switch (state.status) {
          case TodoStatus.loading:
            return _buildScaffold(
              context,
              todos: state.todos,
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          case TodoStatus.failure:
            return _buildScaffold(
              context,
              todos: const [],
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ??
                          'Bir hata oluştu, lütfen tekrar deneyin.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<TodoBloc>()
                          .add(const TodoRefreshRequested()),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            );
          case TodoStatus.success:
            final todos = state.todos;
            final body = todos.isEmpty
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
                : RefreshIndicator(
                    onRefresh: () {
                      context
                          .read<TodoBloc>()
                          .add(const TodoRefreshRequested());
                      return context.read<TodoBloc>().stream.firstWhere(
                            (next) =>
                                next.status == TodoStatus.success ||
                                next.status == TodoStatus.failure,
                          );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TodoItemWidget(
                            todo: todo,
                            onToggle: () => _toggleTodo(context, todo.id),
                            onDelete: () => _deleteTodo(context, todo.id),
                            onEdit: () =>
                                _navigateToEditTodo(context, todo),
                          ),
                        );
                      },
                    ),
                  );

            return _buildScaffold(
              context,
              todos: todos,
              body: body,
            );
        }
      },
    );
  }

  // 5. SAYFA İSKELETİ OLUŞTURUCU (Helper Method)
  // ---------------------------------------------------------
  // Her 3 durumda da (Loading, Error, Data) ortak olan AppBar, FAB ve İstatistikleri
  // tekrar tekrar yazmamak için bu yardımcı metodu kullanıyoruz.
  Widget _buildScaffold(
    BuildContext context, {
    required List<Todo> todos, // İstatistik için gerekli.
    required Widget body, // Değişen orta kısım.
  }) {
    // İstatistik Hesaplamaları:
    // Dart'ın .where() metodu ile listeyi filtreleyip sayısını alıyoruz.
    final completedCount = todos.where((todo) => todo.isCompleted).length;
    final totalCount = todos.length;

    return Scaffold(
      backgroundColor: Colors.grey[100], // Açık gri arka plan.
      
      // --- ÜST ÇUBUK (APP BAR) ---
      appBar: AppBar(
        elevation: 0, // Düz görünüm (gölgesiz).
        title: const Text(
          'Taskly',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        
        // App Bar'ın altındaki istatistik kutucukları.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60), // Yükseklik ayarı.
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Sol Kutu: Toplam Görev Sayısı
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), // Yarı saydam beyaz.
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
                const SizedBox(width: 12), // İki kutu arası boşluk.
                
                // Sağ Kutu: Tamamlanan Görev Sayısı
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

      // --- ORTA KISIM (BODY) ---
      // Burası loading, error veya data durumuna göre değişir.
      body: body,
      
      // --- YUVARLAK EKLEME BUTONU (FAB) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddTodo(context),
        backgroundColor: Colors.blue[600],
        icon: const Icon(Icons.add),
        label: const Text('Yeni Todo'),
      ),
    );
  }
}