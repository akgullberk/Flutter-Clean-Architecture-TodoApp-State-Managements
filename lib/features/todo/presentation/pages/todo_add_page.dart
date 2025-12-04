// 1. İMPORTLAR
// ---------------------------------------------------------
import 'package:flutter/material.dart'; // UI bileşenleri (Form, TextField, Button vb.)
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod kütüphanesi.
import 'package:taskly/features/todo/domain/entities/todo.dart'; // Veri modeli (Todo sınıfı).
import 'package:taskly/features/todo/presentation/providers/todo_providers.dart'; // Provider'a erişim.

// 2. SINIF TANIMI: ConsumerStatefulWidget
// ---------------------------------------------------------
// Hem yerel durumu (TextController'lar) yönetmek hem de Riverpod (ref) kullanmak için
// "ConsumerStatefulWidget" kullanıyoruz.
class TodoAddPage extends ConsumerStatefulWidget {
  const TodoAddPage({super.key});

  @override
  // ConsumerStatefulWidget, "ConsumerState" tipinde bir state oluşturur.
  ConsumerState<TodoAddPage> createState() => _TodoAddPageState();
}

// 3. STATE SINIFI
// ---------------------------------------------------------
// "State" yerine "ConsumerState" kullanıyoruz. Bu sayede sınıfın her yerinde
// "ref" nesnesine doğrudan erişebiliriz.
class _TodoAddPageState extends ConsumerState<TodoAddPage> {
  
  // Formun geçerliliğini (boş mu dolu mu) kontrol etmek için bir anahtar.
  final _formKey = GlobalKey<FormState>();
  
  // Kullanıcının girdiği metinleri tutan ve yöneten kontrolcüler.
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Butona basıldığında yükleniyor animasyonu göstermek için yerel bir değişken.
  bool _isSaving = false;

  // 4. TEMİZLİK (DISPOSE)
  // ---------------------------------------------------------
  // Sayfa kapandığında bellek sızıntısını önlemek için controller'ları yok ediyoruz.
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 5. KAYDETME FONKSİYONU
  // ---------------------------------------------------------
  Future<void> _save() async {
    // Adım 1: Form validasyonu.
    // TextFormField içindeki 'validator' fonksiyonlarını çalıştırır.
    // Eğer bir hata varsa (örn: başlık boşsa) fonksiyonu durdurur.
    if (!_formKey.currentState!.validate()) return;

    // Adım 2: Yükleniyor durumunu başlat.
    // Buton dönemeye başlasın ve kullanıcı tekrar basamasın.
    setState(() {
      _isSaving = true;
    });

    // Adım 3: Todo Objesini Oluştur.
    // Controller'lardan metinleri alıp bir Todo nesnesi paketliyoruz.
    final newTodo = Todo(
      // Benzersiz bir ID oluştur (Basitçe şimdiki zamanın milisaniyesi).
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      title: _titleController.text.trim(), // Başlıktaki gereksiz boşlukları sil.
      description: _descriptionController.text.trim(),
      isCompleted: false, // Yeni görev tamamlanmamış olarak başlar.
      createdAt: DateTime.now(),
    );

    try {
      // Adım 4: Riverpod ile Ekleme İşlemi.
      // ref.read: Sadece bir kere işlem yapacağımız için 'read' kullanıyoruz.
      // .notifier: Veriyi değil, ekleme fonksiyonunu barındıran sınıfı çağırıyoruz.
      // .add(newTodo): Notifier içindeki add metodunu tetikliyoruz.
      await ref.read(todoListProvider.notifier).add(newTodo);
      
      // context.mounted Kontrolü:
      // Asenkron işlem (await) bitene kadar kullanıcı sayfayı kapatmış olabilir.
      // Eğer sayfa kapandıysa aşağıdaki kodları çalıştırma.
      if (!mounted) return;
      
      // Başarılı mesajı göster.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todo başarıyla eklendi'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Adım 5: Sayfayı Kapat ve Geri Dön.
      // pop(true): Geriye 'true' değeri döndürürüz.
      // Bir önceki sayfa (Listeleme sayfası) bu 'true' değerini yakalayıp listeyi yeniler.
      Navigator.of(context).pop(true);
      
    } catch (_) {
      // Hata Durumu:
      if (!mounted) return;
      
      // Yükleniyor animasyonunu durdur.
      setState(() {
        _isSaving = false;
      });
      
      // Hata mesajı göster.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todo eklenirken hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 6. ARAYÜZ (BUILD)
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Todo Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form( // Form widget'ı validasyon için gereklidir.
          key: _formKey, // Yukarıda tanımladığımız anahtarı buraya veriyoruz.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // --- BAŞLIK ALANI ---
              TextFormField(
                controller: _titleController, // Controller'ı bağlıyoruz.
                decoration: InputDecoration(
                  labelText: 'Başlık',
                  hintText: 'Todo başlığını girin',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                // Validasyon Mantığı:
                validator: (value) {
                  // Eğer boşsa hata mesajı döndür.
                  if (value == null || value.trim().isEmpty) {
                    return 'Başlık boş olamaz';
                  }
                  return null; // Hata yok.
                },
                textCapitalization: TextCapitalization.sentences, // Cümle başı büyük harf.
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
                maxLines: 3, // Biraz daha yüksek bir kutu.
                textCapitalization: TextCapitalization.sentences,
                // Burada validator yok, çünkü opsiyonel.
              ),
              
              const SizedBox(height: 24),
              
              // --- KAYDET BUTONU ---
              SizedBox(
                width: double.infinity, // Ekran genişliğine yayıl.
                child: ElevatedButton.icon(
                  // Eğer kaydediliyorsa (_isSaving true ise) onPressed null olur.
                  // Bu da butonu devre dışı bırakır (tıklanamaz yapar).
                  onPressed: _isSaving ? null : _save,
                  
                  // İkon Mantığı:
                  // Kaydediliyorsa dönen çark, değilse tik işareti göster.
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  
                  // Yazı Mantığı:
                  label: Text(_isSaving ? 'Kaydediliyor...' : 'Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}