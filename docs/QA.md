# خطة تأهيل الصورة بعد البناء

## قبل البناء

على Debian 13: `sudo apt update && sudo apt install shellcheck python3-yaml` ثم `bash scripts/validate.sh` و`bash scripts/check-packages.sh`. build.sh يكرر هذه الفحوصات على مضيف البناء قبل lb build.

## بعد البناء

`bash scripts/verify-iso.sh out/DolphinOS-x86_64.iso` ثم تحقق SHA256. عدم وجود ISO أو BIOS/UEFI أو النواة/SquashFS يجعل الخطوة تفشل. اكتمال هذه الفحوصات لا يثبت الإقلاع.

## QEMU اختياري

على مضيف Linux مناسب:

```bash
sudo apt install qemu-system-x86 qemu-utils ovmf
bash scripts/qemu-test.sh out/DolphinOS-x86_64.iso bios 2048
bash scripts/qemu-test.sh out/DolphinOS-x86_64.iso uefi 4096
```

هذه أدوات فتح VM للاختبار اليدوي، لا اختبارات آلية ناجحة. يستخدم TCG لعدم افتراض KVM؛ الأداء على TCG ليس ممثلًا للجهاز الحقيقي. الصوت معطل في أداة QEMU؛ اختبر الصوت في VirtualBox أو جهاز فعلي. ملفات الأقراص منفصلة BIOS/UEFI. بعد التثبيت أخرج DVD من واجهة QEMU واختبر الإقلاع من القرص؛ أو شغّل QEMU مجددًا بالقرص نفسه دون `-cdrom/-boot d`.

## بوابة قبول مستقلة لكل BIOS وUEFI

- [ ] يظهر menu ويقلع LXQt Live.
- [ ] واجهة/مثبت/دخول بالعربية مع الحروف المتصلة، عدم انقلاب النص المختلط، عمل Alt+Shift بعد تسجيل الخروج وبعد التثبيت.
- [ ] يعمل Firefox وصفحة HTTPS، ثم Chromium اختياريًا.
- [ ] الصوت ومخارج pavucontrol، تغيير الشاشة والدقة، تركيب USB وفكه، الشبكة وWi-Fi إن توفر محول.
- [ ] ينجح Calamares على قرص جديد ext4 غير مشفر؛ تجربة ثانية دون إنترنت لتأكيد عدم الحاجة لتنزيل bootloader.
- [ ] حساب مثبت بكلمة مرور، عدم وجود مستخدم Live إلا إن اخترت اسمه، عدم وجود autologin/sudo بدون كلمة مرور.
- [ ] إزالة ISO ثم إقلاع من القرص، حفظ ملف وإعادة تشغيل وبقاؤه.
- [ ] `sudo apt update` و`sudo apt full-upgrade` يعملان، مصادر trixie-security موجودة.
- [ ] تثبيت DEB من APT، Flatpak بسيط، وAppImage amd64 متوافق؛ كل منها يسجل نجاحه أو خطأه فعليًا.
- [ ] ثبات بعد suspend/resume إن دعمه المضيف، وطلب كلمة مرور عند القفل.

## قياس الأداء دون تقدير

انسخ `scripts/measure-performance.sh` إلى النظام الهدف. اختبر 2 GiB ثم 4 GiB في VM لها نفس CPU/القرص والـfirmware. انتظر دقيقتين بعد دخول سطح المكتب، أغلق التطبيقات، ثم:

```bash
bash measure-performance.sh idle-2g.txt
```

كرر ثلاث مرات إقلاعًا باردًا، ثم جرّب Firefox بتبويب واحد وسجّل تقريرًا آخر. القياس يستخدم MemTotal-MemAvailable ويحتفظ بـmpstat عشر عينات وزمن systemd وتسلسل الإقلاع والعمليات. CPU يختلف حسب host/virt وتسارع الرسوم. لا تجمع TCG/VirtualBox/عتاد حقيقي في مقارنة واحدة. وقت firmware قد لا يتوفر؛ زمن systemd ليس زمن ظهور سطح المكتب كله، سجّل هذا الأخير يدويًا كذلك.

القبول المطلوب: نجاح فتح الجلسة والتطبيقات الأساسية على 2 GiB دون OOM أو توقف، وعدم إخفاء خدمات أمان لتجميل الأرقام. لا حد رقمي مختلق لاستهلاك RAM أو CPU.
