<p align="center">
  <a href="../../README.md"><img alt="English" src="https://img.shields.io/badge/English-3A3A3C?style=for-the-badge"></a>
  <a href="./ar.md"><img alt="Arabic" src="https://img.shields.io/badge/%D8%A7%D9%84%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9-0A84FF?style=for-the-badge"></a>
  <a href="./es.md"><img alt="Spanish" src="https://img.shields.io/badge/Espa%C3%B1ol-3A3A3C?style=for-the-badge"></a>
  <a href="./fr.md"><img alt="French" src="https://img.shields.io/badge/Fran%C3%A7ais-3A3A3C?style=for-the-badge"></a>
  <a href="./de.md"><img alt="German" src="https://img.shields.io/badge/Deutsch-3A3A3C?style=for-the-badge"></a>
  <a href="./pt.md"><img alt="Portuguese" src="https://img.shields.io/badge/Portugu%C3%AAs-3A3A3C?style=for-the-badge"></a>
  <a href="./tr.md"><img alt="Turkish" src="https://img.shields.io/badge/T%C3%BCrk%C3%A7e-3A3A3C?style=for-the-badge"></a>
  <a href="./zh.md"><img alt="Chinese" src="https://img.shields.io/badge/%E4%B8%AD%E6%96%87-3A3A3C?style=for-the-badge"></a>
  <a href="./ja.md"><img alt="Japanese" src="https://img.shields.io/badge/%E6%97%A5%E6%9C%AC%E8%AA%9E-3A3A3C?style=for-the-badge"></a>
  <a href="./ko.md"><img alt="Korean" src="https://img.shields.io/badge/%ED%95%9C%EA%B5%AD%EC%96%B4-3A3A3C?style=for-the-badge"></a>
</p>

# Banish

**التطبيق، وكل ما تركه خلفه.**

سحب التطبيق إلى سلة المهملات يزيل الأيقونة فقط. التفضيلات والكاش والحاويات والسجلات ووكلاء التشغيل تبقى في المكتبة. تظل تشغل مساحة، وتعود عند إعادة التثبيت.

Banish يجد هذه الملفات، ويعرضها قبل أي نقل، ثم يرسل ما تختاره أنت فقط إلى السلة. تستطيع إرجاع كل عنصر. لا يوجد حذف نهائي.

<p>
  <img src="../images/library.png" alt="قائمة التطبيقات في Banish مع الحجم والإصدار" width="920">
</p>

## ماذا ترى

القائمة تعرض التطبيقات المثبتة مع الإصدار والحجم. النقطة الخضراء تعني أن التطبيق يعمل. البحث يقبل الاسم أو معرّف الحزمة، مثل `com.google.Chrome`.

عند الاختيار تظهر ثلاثة أرقام: حجم التطبيق، وحجم الملفات المرتبطة، وحجم ما هو محدد فعلاً وسينتقل إلى السلة.

**الملفات المرتبطة** تُطابق بمعرّف الحزمة وتبدأ محددة. **تطابق الاسم** ملفات تشترك في الاسم فقط، فتبقى غير محددة حتى تراجع المسار.

<p>
  <img src="../images/detail.png" alt="تفاصيل Chrome في Banish" width="920">
</p>

## لا شيء يتحرك قبل التأكيد

**Move to Trash** يفتح ورقة تأكيد بالعدد والحجم. زر النقل ليس الزر الافتراضي، لذلك مفتاح الإدخال لا يؤكد بالخطأ.

تطبيقات مجلد `/Applications` ملك لـ macOS، والنقل العادي يُرفض. الورقة تقول إن كلمة السر قد تُطلب. بعد موافقتك، يسأل macOS مرة واحدة وينقل Banish ما حددته إلى السلة.

<p>
  <img src="../images/confirm.png" alt="ورقة التأكيد قبل النقل إلى السلة" width="920">
</p>

إلغاء نافذة كلمة السر يوقف النقل. ما لم يُنقل يبقى مكانه، وما وصل إلى السلة يمكن إرجاعه.

## أين يبحث

Banish لا يفحص القرص كله. ينظر في مجلدات المكتبة المعروفة بعمق محدود: التفضيلات، وApplication Support، والكاش، والسجلات، والحاويات، وبيانات الويب عندما يطابق المعرّف، ووكلاء التشغيل، والحالة المحفوظة.

المطابقة القوية تعتمد على معرّف الحزمة. `com.foo.app` لا يسحب `com.foo.application` ولا `com.foo.app2`. `Google/Chrome` يمكن أن يتبع Chrome، بينما `Google/Earth` لا يتبعه لمجرد اشتراك كلمة.

## ما لا يلمسه

مواقع النظام مثل `/System` و`/usr` و`/bin` و`/private`. مستنداتك وسطح المكتب والتنزيلات والصور والموسيقى. البريد والرسائل والصور وسفاري وسلسلة المفاتيح والتقويم والملاحظات. مجلد `~/.ssh`، والسلة نفسها كمصدر للحذف. الاختصارات الرمزية. ونسخة Banish العاملة، فالتطبيق لا ينقل نفسه.

تطبيقات آبل الأساسية مثل Finder وSafari وMail تبقى مقفلة. تطبيقات آبل الاختيارية مثل Keynote وPages وNumbers يمكن نقلها مع تنبيه. تطبيقات النظام مخفية في البداية، وتظهر من قائمة العرض أو من الإعدادات.

## الصلاحيات

**كلمة سر المسؤول** تُطلب فقط عندما يرفض macOS نقل تطبيق من مجلد التطبيقات. النافذة نافذة النظام، وتظهر باسم Banish.

**الوصول الكامل إلى القرص** اختياري، ويفيد لقراءة الحاويات والكاش. من دونه تبقى القائمة تعمل، وتظهر لافتة إذا تعذرت قراءة مجلد.

إعدادات النظام ← الخصوصية والأمن ← الوصول الكامل إلى القرص

## اللغة داخل التطبيق

النافذة تتبع لغة الماك، ومن اليمين إلى اليسار مع العربية. من الإعدادات يمكن تثبيت العربية أو الإنجليزية.

<p>
  <img src="../images/settings.png" alt="إعدادات Banish" width="540">
</p>

## البناء

macOS 14 أو أحدث، وSwift 6. بلا مكتبات خارجية.

```bash
./Scripts/build-app.sh
open build/Banish.app
```

أو `make app` ثم `make run`. الاختبارات عبر `make test`. التطبيق الموقّع يكون في `build/Banish.app`.
