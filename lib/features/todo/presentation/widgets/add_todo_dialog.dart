// 1. KÜTÜPHANE
// ---------------------------------------------------------
import 'package:flutter/material.dart'; // Flutter'ın görsel bileşenleri.

// 2. WIDGET SINIFI (STATEFUL)
// ---------------------------------------------------------
// Bu pencerenin içinde kullanıcının yazı yazdığı alanlar (TextField) olduğu için,
// bu yazıların durumunu (State) takip etmemiz gerekir. Bu yüzden StatefulWidget kullanıyoruz.
class AddTodoDialog extends StatefulWidget {
  // Eğer düzenleme (Edit) yapılacaksa, eski başlık ve açıklama buraya gelir.
  final String? initialTitle;
  final String? initialDescription;

  // Callback Fonksiyonu: 
  // "Kullanıcı kaydet tuşuna bastığında ne yapayım?" sorusunun cevabıdır.
  // Bu widget veritabanını bilmez. Sadece bu fonksiyonu tetikler ve verileri içine koyar.
  final Function(String title, String description) onSave;

  const AddTodoDialog({
    super.key,
    this.initialTitle,       // Null gelebilir (Yeni ekleme modu)
    this.initialDescription, // Null gelebilir
    required this.onSave,    // Zorunlu (Ne yapacağını bilmeli)
  });

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

// 3. STATE SINIFI (DURUM YÖNETİMİ)
// ---------------------------------------------------------
class _AddTodoDialogState extends State<AddTodoDialog> {
  // Controller: Text kutularına yazılan yazıyı okumamızı ve yönetmemizi sağlayan araçlar.
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Form Key: Formun geçerliliğini (boş mu dolu mu?) kontrol eden anahtar.
  final _formKey = GlobalKey<FormState>();

  // --- BAŞLANGIÇ AYARLARI (INITSTATE) ---
  @override
  void initState() {
    super.initState();
    // Eğer düzenleme modundaysak (initialTitle boş değilse),
    // Text kutularının içini eski verilerle doldururuz.
    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
    if (widget.initialDescription != null) {
      _descriptionController.text = widget.initialDescription!;
    }
  }

  // --- TEMİZLİK (DISPOSE) ---
  // Bellek Sızıntısını (Memory Leak) önlemek için çok önemlidir.
  // Pencere kapandığında bu controller'ları bellekten sileriz.
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- KAYDETME MANTIĞI ---
  void _save() {
    // Form kurallara uygun mu? (Örn: Başlık dolu mu?)
    if (_formKey.currentState!.validate()) {
      // Eğer uygunsa, verileri kırpıp (trim - baştaki/sondaki boşlukları sil)
      // üst katmandan gelen 'onSave' fonksiyonuna teslim ederiz.
      widget.onSave(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
      );
    }
  }

  // --- ARAYÜZ ÇİZİMİ (BUILD) ---
  @override
  Widget build(BuildContext context) {
    // Başlık doluysa "Düzenleme Modu", boşsa "Ekleme Modu" olduğunu anlarız.
    final isEditing = widget.initialTitle != null;

    return Dialog(
      // Dialog'un köşelerini yuvarlatır.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey, // Form anahtarını buraya bağlıyoruz.
          child: Column(
            mainAxisSize: MainAxisSize.min, // Dialog içeriği kadar yer kaplasın (Tüm ekranı kaplamasın).
            crossAxisAlignment: CrossAxisAlignment.start, // Sola yasla.
            children: [
              // --- PENCERE BAŞLIĞI ---
              Text(
                isEditing ? 'Todo Düzenle' : 'Yeni Todo Ekle', // Dinamik başlık
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24), // Boşluk.

              // --- BAŞLIK GİRİŞ ALANI ---
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Başlık',
                  hintText: 'Todo başlığını girin',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title), // Sol tarafa ikon.
                ),
                // Validasyon Kuralı:
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Başlık boş olamaz'; // Hata mesajı.
                  }
                  return null; // Sorun yok.
                },
                textCapitalization: TextCapitalization.sentences, // Cümle başı büyük harf.
              ),
              const SizedBox(height: 16),

              // --- AÇIKLAMA GİRİŞ ALANI ---
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
                maxLines: 3, // 3 satır yüksekliğinde olsun.
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // --- BUTONLAR ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end, // Sağa yasla.
                children: [
                  // İptal Butonu
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(), // Pencereyi kapatır.
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: 8),
                  
                  // Kaydet Butonu
                  ElevatedButton(
                    onPressed: _save, // _save fonksiyonunu çalıştırır.
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isEditing ? 'Güncelle' : 'Ekle'), // Dinamik buton metni.
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}