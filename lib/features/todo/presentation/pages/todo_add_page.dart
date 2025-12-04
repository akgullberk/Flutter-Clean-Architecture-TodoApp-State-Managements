// 1. İMPORTLAR
// ---------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // State Management paketi.
import 'package:taskly/features/todo/domain/entities/todo.dart'; // Veri modeli.
import 'package:taskly/features/todo/presentation/providers/todo_provider.dart'; // Provider sınıfı.

// 2. WIDGET SINIFI (STATEFUL)
// ---------------------------------------------------------
// Form verilerini (TextEditingController) tutmak için StatefulWidget kullanmaya devam ediyoruz.
// Ancak iş mantığını (Business Logic) Provider'a devredeceğiz.
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
    // Sayfa kapanınca kontrolcüleri bellekten sil.
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- KAYDETME MANTIĞI ---
  Future<void> _save() async {
    // 1. Form geçerli mi? (Başlık dolu mu?)
    if (!_formKey.currentState!.validate()) return;

    // 2. YENİ NESNE OLUŞTURMA
    // Kullanıcının girdiği verilerle geçici bir Todo nesnesi oluşturuyoruz.
    final newTodo = Todo(
      // ID Üretimi: Benzersiz olması için şu anki zamanın milisaniye değerini kullanıyoruz.
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      isCompleted: false, // Yeni görev varsayılan olarak tamamlanmamıştır.
      createdAt: DateTime.now(), // Oluşturulma tarihi.
    );

    // 3. PROVIDER İLE KAYDETME
    // DİKKAT: Fonksiyon çağırırken 'read' kullanıyoruz (Dinlemeye gerek yok).
    // Provider bize işlemin sonucunu (Hata varsa String, yoksa null) dönecek.
    final error = await context.read<TodoProvider>().addTodo(newTodo);

    // İşlem bitene kadar sayfa kapandıysa (örn: kullanıcı geri tuşuna bastıysa) dur.
    if (!mounted) return;

    // 4. SONUCU KONTROL ET
    if (error != null) {
      // HATA VARSA: Kırmızı uyarı göster ve fonksiyondan çık.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    // BAŞARI DURUMU:
    // Yeşil uyarı göster.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todo başarıyla eklendi'),
        backgroundColor: Colors.green,
      ),
    );

    // Sayfayı kapat ve geriye 'true' değeri döndür.
    // (Bunu dinleyen bir önceki sayfa listeyi yenileyecek).
    Navigator.of(context).pop(true);
  }

  // --- EKRAN ÇİZİMİ (BUILD) ---
  @override
  Widget build(BuildContext context) {
    // DİKKAT: Yükleniyor durumunu dinlemek için 'watch' kullanıyoruz.
    // Provider'daki 'isSubmitting' değeri değişirse burası yeniden çizilir
    // ve butonun üzerindeki loading animasyonu görünür/kaybolur.
    final isSaving = context.watch<TodoProvider>().isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Todo Ekle'),
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
                width: double.infinity,
                child: ElevatedButton.icon(
                  // Yükleniyorsa tıklamayı engelle (null), değilse _save çalışsın.
                  onPressed: isSaving ? null : _save,
                  
                  // İkon: Yükleniyorsa dönen çember, değilse tik işareti.
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  
                  // Yazı: Duruma göre değişir.
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