import 'package:flutter/material.dart';
import 'package:taskly/core/di/injection_container.dart';
import 'package:taskly/core/routes/app_routes.dart';
import 'package:taskly/features/todo/domain/entities/todo.dart';
import 'package:taskly/features/todo/domain/usecases/add_todo.dart';
import 'package:taskly/features/todo/domain/usecases/delete_todo.dart';
import 'package:taskly/features/todo/domain/usecases/get_all_todos.dart';
import 'package:taskly/features/todo/domain/usecases/toggle_todo.dart';
import 'package:taskly/features/todo/domain/usecases/update_todo.dart';
import 'package:taskly/features/todo/presentation/widgets/todo_item_widget.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final GetAllTodos _getAllTodos = sl<GetAllTodos>();
  final AddTodo _addTodoUseCase = sl<AddTodo>();
  final UpdateTodo _updateTodoUseCase = sl<UpdateTodo>();
  final DeleteTodo _deleteTodoUseCase = sl<DeleteTodo>();
  final ToggleTodo _toggleTodoUseCase = sl<ToggleTodo>();
  List<Todo> _todos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _getAllTodos();
    result.fold(
      (failure) {
        setState(() {
          _errorMessage = failure.message ?? 'Bir hata oluştu';
          _isLoading = false;
        });
      },
      (todos) {
        setState(() {
          _todos = todos;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _navigateToAddTodo() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.todoAdd);
    if (result == true) {
      _loadTodos();
    }
  }

  Future<void> _toggleTodo(String id) async {
    final result = await _toggleTodoUseCase(id);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message ?? 'Todo güncellenirken hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (_) {
        _loadTodos();
      },
    );
  }

  Future<void> _deleteTodo(String id) async {
    final result = await _deleteTodoUseCase(id);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message ?? 'Todo silinirken hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (_) {
        _loadTodos();
        if (mounted) {
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

  Future<void> _navigateToEditTodo(Todo todo) async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.todoEdit,
      arguments: todo,
    );
    if (result == true) {
      _loadTodos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _todos.where((todo) => todo.isCompleted).length;
    final totalCount = _todos.length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Taskly',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTodos,
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : _todos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 80,
                            color: Colors.grey[400],
                          ),
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
                      onRefresh: _loadTodos,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _todos.length,
                        itemBuilder: (context, index) {
                          final todo = _todos[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TodoItemWidget(
                              todo: todo,
                              onToggle: () => _toggleTodo(todo.id),
                              onDelete: () => _deleteTodo(todo.id),
                              onEdit: () => _navigateToEditTodo(todo),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddTodo,
        backgroundColor: Colors.blue[600],
        icon: const Icon(Icons.add),
        label: const Text('Yeni Todo'),
      ),
    );
  }
}

