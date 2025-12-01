// 1. İMPORTLAR
// ---------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:taskly/features/todo/domain/entities/todo.dart'; // Düzenlenecek veri modeli.
import 'package:provider/provider.dart';
import 'package:taskly/features/todo/presentation/providers/todo_provider.dart';

// 2. WIDGET SINIFI (STATEFUL)
// ---------------------------------------------------------
// Bu sayfa açılırken düzenlenecek olan 'Todo' nesnesini parametre olarak almak ZORUNDADIR.
class TodoEditPage extends StatefulWidget {
  final Todo todo;

  const TodoEditPage({
    super.key,
    required this.todo, // Hangi görevi düzenleyeceğimizi bilmeliyiz.
  });

  @override
  State<TodoEditPage> createState() => _TodoEditPageState();
}

// 3. STATE SINIFI
// ---------------------------------------------------------
class _TodoEditPageState extends State<TodoEditPage> {
  // Form doğrulama anahtarı.
  final _formKey = GlobalKey<FormState>();

  // Metin kutularını yönetecek kontrolcüler.
  // 'late': "Bunu birazdan (initState içinde) başlatacağım, merak etme" demektir.
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  // --- BAŞLANGIÇ (INITSTATE) ---
  @override
  void initState() {
    super.initState();
    // Sayfa açılır açılmaz, metin kutularının içini
    // dışarıdan gelen eski verilerle dolduruyoruz.
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(
      text: widget.todo.description,
    );
  }

  // --- TEMİZLİK (DISPOSE) ---
  @override
  void dispose() {
    // Sayfa kapanınca hafızayı temizle.
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- KAYDETME MANTIĞI ---
  Future<void> _save() async {
    // 1. Form geçerli mi? (Başlık boş mu?)
    if (!_formKey.currentState!.validate()) return;

    // 3. GÜNCEL NESNEYİ OLUŞTURMA
    // Burası çok önemli! 'widget.todo' (Eski veri) üzerinden 'copyWith' yapıyoruz.
    // ID değişmiyor! Tarih değişmiyor! Sadece Başlık ve Açıklama değişiyor.
    final updatedTodo = widget.todo.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    // 4. Provider üzerinden güncelleme isteği gönder.
    final error = await context.read<TodoProvider>().updateTodo(updatedTodo);

    if (!mounted) return;

    if (error != null) {
      // Kırmızı uyarı göster.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    // BAŞARI DURUMU:
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todo başarıyla güncellendi'),
        backgroundColor: Colors.green,
      ),
    );
    // Sayfayı kapat ve geriye 'true' değeri döndür.
    // (Ana sayfa bu 'true' değerini görünce listeyi yenileyeceğini anlar).
    Navigator.of(context).pop(true);
  }

  // --- EKRAN ÇİZİMİ (BUILD) ---
  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<TodoProvider>().isSubmitting;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Düzenle'), // Sayfa Başlığı.
      ),
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
                width: double.infinity, // Ekran genişliğince uzasın.
                child: ElevatedButton.icon(
                  // Eğer kaydediliyorsa butona tıklanamasın (null), değilse _save çalışsın.
                  onPressed: isSaving ? null : _save,

                  // Buton ikonu: Yükleniyorsa dönen çember, değilse tik işareti.
                  icon:
                      isSaving
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.check),

                  // Buton yazısı.
                  label: Text(isSaving ? 'Kaydediliyor...' : 'Güncelle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
