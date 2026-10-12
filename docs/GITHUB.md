# رفع المشروع وحل Get started

GitHub لا يقرأ ملفات Workflow من ZIP مرفوع أو من `nova-os/.github/` تحت جذر المستودع. يجب أن يكون `build.sh` في الجذر و`.github/workflows/build-iso.yml` في الجذر كذلك.

فعّل عرض العناصر المخفية في Explorer. افتح Git Bash أو PowerShell داخل مجلد المشروع، ثم:

```bash
git init -b main
git add .
git status --short
```

تأكد من ظهور `.github/workflows/build-iso.yml` بين الملفات المضافة. إذا كان مستودعك جديدًا فارغًا:

```bash
git commit -m "Develop Nova OS into Dolphin OS 1.0"
git remote add origin https://github.com/YOUR-USER/YOUR-REPO.git
git push -u origin main
```

استبدل الرابط برابط مستودعك. إن كان المستودع موجودًا ويحوي commits، انسخه أولًا باستخدام `git clone`، ثم انسخ محتويات المشروع داخله مع `.github`، واعمل commit وpush. **لا تستخدم force push**.

تحقق في Code أن ملف Workflow موجود في الفرع الافتراضي (Settings → Branches أو General). افحص Settings → Actions → General وأن السياسة تسمح بـ checkout/upload-artifact. افتح Actions وحدد Build Dolphin OS ISO ثم Run workflow.

للتنزيل بعد نجاح التشغيل: صفحة تشغيل Workflow → Artifacts → DolphinOS-x86_64-رقم. افك ZIP، ثم على Windows من PowerShell داخل المجلد:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\join-iso.ps1
```

هذا يسمح بتشغيل الملف المحلي في العملية الحالية ولا يغير سياسة الجهاز دائمًا. يجب أن تحصل على ISO وتنجح مطابقة SHA256. تحت Linux `bash join-iso.sh`.

إذا فشل الرفع بسبب حصة التخزين، احذف Artifacts قديمة لا تحتاجها من واجهة GitHub أو شغل البناء مع خيار draft_release؛ ثم افتح Releases وحمّل الأجزاء من المسودة بصلاحياتك. إذا لم تسمح سياسة المؤسسة بالـ Releases، استخدم البناء المحلي.

نجاح فحص YAML محليًا لا يثبت أن GitHub اكتشف الملف في مستودعك؛ هذا يحتاج رفعًا فعليًا بالمسار الصحيح. لا يوجد ربط بمستودع من داخل هذه المهمة.
