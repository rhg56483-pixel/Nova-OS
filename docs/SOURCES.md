# المراجع التي استُخدمت في المراجعة

- GitHub: التشغيل اليدوي يحتاج workflow_dispatch والملف على الفرع الافتراضي:
  https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow
- GitHub Releases: كل ملف أصل أقل من 2 GiB؛ تقسيم الملف لا يقلل حصة Artifacts:
  https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases
- Debian 13 live-build، الخيارات المعتمدة:
  https://manpages.debian.org/trixie/live-build/lb_config.1.en.html
- إعدادات Calamares الرسمية 13.0.13-1؛ حزمة Debian الفعلية استُخرجت للمقارنة:
  https://sources.debian.org/src/calamares-settings-debian/13.0.13-1/
- LXQt core في Debian trixie ومكوناته:
  https://packages.debian.org/trixie/lxqt-core
- فهارس الحزم المستخدمة في فحص الأسماء ومحاكاة حل الاعتماديات:
  https://deb.debian.org/debian/dists/trixie/main/binary-amd64/Packages.xz
  https://deb.debian.org/debian/dists/trixie/contrib/binary-amd64/Packages.xz
  https://deb.debian.org/debian/dists/trixie/non-free-firmware/binary-amd64/Packages.xz
- مصادر LXQt appearance لتأكيد مفاتيح اللوحة اللونية:
  https://github.com/lxqt/lxqt-config/blob/2.1.0/lxqt-config-appearance/styleconfig.cpp
- إعدادات partition في Calamares المتوافق مع الحزمة:
  https://github.com/calamares/calamares/blob/v3.3.14/src/modules/partition/partition.conf
- تعليمات Brave الرسمية:
  https://brave.com/linux/

أسماء الحزم والإعدادات فُحصت بتاريخ المراجعة. runtime hooks يستعمل إعدادات Debian المثبتة فعليًا ويوقف البناء إذا تغير تسلسل المثبت المطلوب. إصدار Docker وأدوات GitHub غير مثبتين بواسطة digest، ولذلك البناء ليس reproducible على مستوى البايتات.
