# Nova OS 1.0 — توزيعة Linux حقيقية (Debian + KDE Plasma)

نظام تشغيل قابل للإقلاع والتثبيت، مبني بـ `live-build` فوق **Debian 13 (trixie)**، معمارية **x86_64**، إقلاع **BIOS + UEFI** (ISO هجين)، مع مثبّت رسومي **Calamares**.
الناتج: `out/NovaOS-x86_64.iso`

## المحتويات
| المتطلب | التنفيذ |
|---|---|
| سطح مكتب عصري | KDE Plasma 6: شريط مهام سفلي عائم، قائمة بداية (Kickoff) بأيقونة Nova، حواف نوافذ مستديرة (Breeze)، Blur + حركات |
| التطبيقات | Dolphin، System Settings، Firefox ESR، Discover (+Flatpak/Flathub)، Konsole، System Monitor (مدير المهام) |
| اللغات | English + العربية كاملة (locales + task-arabic-kde-desktop + خطوط). التغيير: الإعدادات ← اللغة والمنطقة. تبديل لوحة المفاتيح: Alt+Shift (us/ara) |
| الدخول والقفل | SDDM (شاشة دخول) + قفل Plasma (يقفل بعد 10 دقائق وعند الاستئناف) + إنشاء المستخدم أثناء التثبيت وفي الإعدادات ← المستخدمون |
| الشبكة/الصوت/الإدخال | NetworkManager، PipeWire، libinput |
| المثبّت | Calamares: اختيار اللغة، لوحة المفاتيح، القرص، المستخدم، BIOS/UEFI تلقائيًا |
| VirtualBox | `virtualbox-guest-utils` + `virtualbox-guest-x11` مثبتة داخل الصورة وتُشغَّل تلقائيًا (دقة الشاشة، الحافظة، السحب والإفلات) |
| الهوية | شعار وخلفية SVG أصلية (`branding/`) — لا شيء من Microsoft |

## البناء
المتطلبات: ~15 GB مساحة فارغة، اتصال إنترنت، وقت 20–60 دقيقة.

**الخيار 1 — Debian 12/13 (جهاز أو VM):**
```bash
sudo ./build.sh
```
**الخيار 2 — أي Linux/WSL2 مع Docker:**
```bash
./docker-build.sh
```
**الخيار 3 — بدون Linux:** ارفع المشروع إلى GitHub ← Actions ← *Build Nova OS ISO* ← Run workflow، ثم نزّل الـ artifact.

> لا تبنِ داخل مجلد NTFS أو مجلد مشترك VirtualBox؛ استخدم نظام ملفات Linux (المسار الافتراضي `/tmp/nova-build`).
> مع Docker على ويندوز (WSL2) قد تحتاج رفع حد القرص.

## التجربة في VirtualBox
```bash
./scripts/create-vbox-vm.sh out/NovaOS-x86_64.iso efi      # أو bios
```
ويندوز: `.\scripts\create-vbox-vm.ps1 -Iso C:\...\NovaOS-x86_64.iso`
(أو يدويًا: Linux/Debian 64-bit، RAM ≥ 4GB، Video 128MB VMSVGA، قرص ≥ 25GB، فعّل EFI إن أردت اختبار UEFI.)

1. أقلع من الـ ISO ← يدخل جلسة Live تلقائيًا (المستخدم `novalive`، كلمة المرور `live` لفتح القفل).
2. اضغط أيقونة **Install Nova OS** على سطح المكتب.
3. اتبع المعالج ← أعد التشغيل ← أخرج الـ ISO.

## هيكل المشروع
- `build.sh`, `docker-build.sh`, `.github/workflows/build-iso.yml` — البناء
- `config/package-lists/` — الحزم
- `config/hooks/normal/` — سكربتات داخل الـ chroot (الهوية، الخدمات، اللغات، Flathub)
- `config/includes.chroot_after_packages/` — ملفات النظام: إعدادات Plasma/SDDM/Calamares، الحزمة look-and-feel `org.novaos.desktop` (تخطيط شريط المهام)
- `branding/` — الشعار والخلفية (SVG)
- `scripts/` — إنشاء VM في VirtualBox

## تخصيص
- أضف حزمًا في `config/package-lists/nova.list.chroot`.
- غيّر التخطيط في `.../org.novaos.desktop/contents/layouts/org.kde.plasma.desktop-layout.js`.
- Secure Boot غير مفعّل (غير موقّع بمفتاح Nova)؛ عطّله في VirtualBox/الجهاز أو أضف `shim-signed` و`grub-efi-amd64-signed`.
