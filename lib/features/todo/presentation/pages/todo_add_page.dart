// 1. İMPORTLAR
// ---------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:taskly/features/todo/domain/entities/todo.dart'; // Oluşturacağımız veri modeli.
import 'package:provider/provider.dart';
import 'package:taskly/features/todo/presentation/providers/todo_provider.dart';

// 2. WIDGET SINIFI (STATEFUL)
// ---------------------------------------------------------
// Bu sayfa dışarıdan bir parametre almaz. Çünkü sıfırdan veri oluşturacak.
class TodoAddPage extends StatefulWidget {
  const TodoAddPage({super.key});

  @override
  State<TodoAddPage> createState() => _TodoAddPageState();
}

// 3. STATE SINIFI
// ---------------------------------------------------------
class _TodoAddPageState extends State<TodoAddPage> {
  // Form doğrulama anahtarı.
  final _formKey = GlobalKey<FormState>();

  // Metin kutularını yönetecek kontrolcüler.
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // --- TEMİZLİK (DISPOSE) ---
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- KAYDETME MANTIĞI ---
  Future<void> _save() async {
    // 1. Form geçerli mi? (Başlık dolu mu?)
    if (!_formKey.currentState!.validate()) return;

    // 3. YENİ NESNE OLUŞTURMA
    // Burası 'EditPage'den farklıdır. EditPage var olanı kopyalıyordu.
    // Burada sıfırdan bir Todo oluşturuyoruz.
    final newTodo = Todo(
      // ID Üretimi: Basit bir yöntem olarak o anki zamanın milisaniye değerini ID yapıyoruz.
      // (Gerçek projelerde 'uuid' paketi kullanılır ama bu da çalışır).
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      isCompleted: false, // Yeni görev henüz tamamlanmamıştır.
      createdAt: DateTime.now(), // Oluşturulma tarihi şu an.
    );

    // 4. Provider üzerinden domain katmanına isteği gönder.
    final error = await context.read<TodoProvider>().addTodo(newTodo);

    if (!mounted) return;

    if (error != null) {
      // Kırmızı hata mesajı göster.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    // BAŞARI DURUMU (SAĞ CEP):
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todo başarıyla eklendi'),
        backgroundColor: Colors.green,
      ),
    );
    // Sayfayı kapat ve geriye 'true' değeri döndür.
    // (Ana sayfa bu 'true'yu görünce listeyi yenileyecek).
    Navigator.of(context).pop(true);
  }

  // --- EKRAN ÇİZİMİ (BUILD) ---
  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<TodoProvider>().isSubmitting;
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Todo Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- BAŞLIK ALANI ---
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Başlık',
                  hintText: 'Todo başlığını girin',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Başlık boş olamaz';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // --- AÇIKLAMA ALANI ---
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Açıklama (Opsiyonel)',
                  hintText: 'Todo açıklamasını girin',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // --- KAYDET BUTONU ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  // Yükleniyorsa tıklamayı engelle (null).
                  onPressed: isSaving ? null : _save,
                  icon:
                      isSaving
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.check),
                  label: Text(isSaving ? 'Kaydediliyor...' : 'Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
