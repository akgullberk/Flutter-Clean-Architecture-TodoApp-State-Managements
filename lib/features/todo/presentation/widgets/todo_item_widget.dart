// 1. İMPORTLAR
// ---------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatlamak için (Örn: 27 Kas, 14:00).
import 'package:taskly/features/todo/domain/entities/todo.dart'; // Hangi veriyi göstereceğiz?

// 2. WIDGET SINIFI (STATELESS)
// ---------------------------------------------------------
// Bu widget içinde veri değişmez, veri dışarıdan gelir. O yüzden Stateless.
// Rengi, yazısı değişecekse, üst katman yeni bir TodoItemWidget gönderir.
class TodoItemWidget extends StatelessWidget {
  final Todo todo; // Gösterilecek veri.
  
  // Callback'ler (Tetikleyiciler):
  // Bu widget'a tıklandığında ne olacağını ana sayfa (TodoListPage) belirler.
  final VoidCallback onToggle; // Checkbox'a basınca.
  final VoidCallback onDelete; // Sil'e basınca.
  final VoidCallback onEdit; // Düzenle'ye basınca.

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  // 3. SİLME ONAY PENCERESİ
  // ---------------------------------------------------------
  // Kullanıcı yanlışlıkla silmesin diye emin misin diye soruyoruz.
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Todo Sil'),
        content: const Text('Bu todo\'yu silmek istediğinize emin misiniz?'),
        actions: [
          // İptal tuşu
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          // Sil tuşu (Kırmızı renkli)
          TextButton(
            onPressed: () {
              onDelete(); // Üst katmandaki silme fonksiyonunu tetikler.
              Navigator.of(context).pop(); // Pencereyi kapatır.
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  // 4. ARAYÜZ ÇİZİMİ (BUILD)
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Tarih formatlayıcı: "27 Kas 2025, 14:30" formatı.
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'tr_TR');

    return Container(
      // Kart Görünümü (Beyaz kutu + Gölge)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Çok hafif siyah gölge.
            blurRadius: 10, // Gölgenin yayılma oranı.
            offset: const Offset(0, 2), // Gölgenin yönü (hafif aşağı).
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent, // Arka plan rengini Container veriyor.
        child: InkWell(
          // Tıklama efekti (Su dalgası) için InkWell kullanılır.
          borderRadius: BorderRadius.circular(16),
          onTap: onToggle, // Karta tıklayınca da tamamlandı yapılsın.
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- SOL TARAFTAKİ KUTUCUK (CHECKBOX) ---
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  child: Checkbox(
                    value: todo.isCompleted, // Dolu mu boş mu?
                    onChanged: (_) => onToggle(), // Tıklanınca haber ver.
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    activeColor: Colors.blue[600], // Tik rengi.
                  ),
                ),
                const SizedBox(width: 12), // Boşluk.

                // --- ORTA KISIM (BAŞLIK, AÇIKLAMA, TARİH) ---
                Expanded( // Kalan tüm boşluğu kapla.
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık Metni
                      Text(
                        todo.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          // Eğer tamamlandıysa üstünü çiz (LineThrough), değilse normal.
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          // Eğer tamamlandıysa gri yap, değilse siyah.
                          color: todo.isCompleted
                              ? Colors.grey[500]
                              : Colors.grey[900],
                        ),
                      ),
                      
                      // Açıklama Metni (Varsa gösterilir)
                      if (todo.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          todo.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: todo.isCompleted
                                ? Colors.grey[400]
                                : Colors.grey[700],
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 2, // En fazla 2 satır olsun.
                          overflow: TextOverflow.ellipsis, // Sığmazsa "..." koy.
                        ),
                      ],
                      const SizedBox(height: 8),

                      // Tarih Bilgisi
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateFormat.format(todo.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          // Eğer tamamlandıysa, ne zaman tamamlandığını da göster.
                          if (todo.completedAt != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tamamlandı: ${dateFormat.format(todo.completedAt!)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // --- SAĞ TARAFTAKİ MENÜ (ÜÇ NOKTA) ---
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  onSelected: (value) {
                    // Menüden seçilen işleme göre aksiyon al.
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context);
                    }
                  },
                  itemBuilder: (context) => [
                    // Düzenle Seçeneği
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Düzenle'),
                        ],
                      ),
                    ),
                    // Sil Seçeneği
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Sil', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}