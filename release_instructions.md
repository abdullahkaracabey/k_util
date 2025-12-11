# Pub.dev Yayınlama Kılavuzu

Projenizi pub.dev üzerinde yayınlamak için aşağıdaki adımları takip edin.

## 1. Hazırlık Kontrolü
- [x] `pubspec.yaml` versiyonunu güncelleyin (örn: `1.0.0`).
- [x] `CHANGELOG.md` dosyasına bu versiyon için notları ekleyin.
- [x] `LICENSE` dosyasının mevcut olduğundan emin olun.
- [x] `dart pub publish --dry-run` komutu ile son bir kez hata olup olmadığını kontrol edin.

## 2. Git Durumu
Pub.dev, yayınlamadan önce clean git state (değişikliklerin commitlenmiş olması) ister.

```bash
git add .
git commit -m "Rename to k_scaffold and release version 1.0.0"
```

## 3. Yayınlama
Terminalde proje ana dizinindeyken şu komutu çalıştırın:

```bash
dart pub publish
```

Bu komutu çalıştırdıktan sonra:
1.  Terminalde size bir URL verilecek.
2.  Bu URL'i tarayıcıda açın ve Google hesabınızla giriş yapın.
3.  Yetki verdikten sonra terminale geri dönün, işlem otomatik olarak devam edecektir.
4.  "Successfully uploaded package." mesajını gördüğünüzde işlem tamamlanmıştır.

## 4. Sonrası
Paket yayınlandıktan sonra Git üzerinde de versiyonu etiketlemeniz (tag) önerilir:

```bash
git tag v1.0.0
git push origin v1.0.0
```

---
**Not:** İlk yayınlamadan sonra paketinizin "Verified Publisher" olması için pub.dev panelinden domain doğrulaması yapabilirsiniz ancak zorunlu değildir.
