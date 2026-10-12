# التطبيقات والملفات

| الوظيفة | التنفيذ |
|---|---|
| التصفح الافتراضي | Firefox ESR + ترجمة عربية |
| Chromium | اختياري: `sudo apt update && sudo apt install chromium chromium-l10n` |
| Brave | التعليمات الرسمية: https://brave.com/linux/؛ إضافة المفتاح ومستودع signed-by ثم تثبيت brave-browser |
| تطبيقات DEB | من الطرفية: `sudo apt install ./file.deb`، أو Synaptic للحزم المسجلة في المستودعات |
| Flatpak | `flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo` ثم `flatpak install flathub APP-ID` |
| AppImage | ملف amd64 متوافق، `chmod +x file.AppImage` ثم `./file.AppImage`؛ libfuse2t64 ضمن الصورة |
| الملفات وUSB | PCManFM-Qt + udisks2/gvfs |
| الصوت والفيديو | MPV + PipeWire، التحكم pavucontrol-qt |
| التحديثات | Synaptic من قائمة تحديث النظام، أو `sudo apt update && sudo apt full-upgrade` |
| إعدادات الحساب | إنشاء الحساب في Calamares، وإدارة كلمات المرور بـ `passwd` والمستخدمين بـ `sudo adduser USER`؛ لا صفحة إدارة حسابات شكلية |

أداة التطبيقات الاختيارية نافذة Zenity أصلية وليست متجر HTML. تُشغّل العمليات الفعلية في طرفية واضحة. Synaptic لا يملك واجهة متجر Flatpak. لا يُثبت Brave تلقائيًا؛ اتبع المصدر الرسمي المتغير بدل تثبيت عنوان مفتاح غير مفحوص.

Flatpak يستخدم مساحة وقد تشغّل تطبيقاته عمليات إضافية. AppImage ليس ضمانًا أن كل ملف يعمل على كل توزيعة. لا تُنفّذ ملفات غير موثوقة.
