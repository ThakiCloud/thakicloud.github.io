---
title: "الاستدلال المعزز بالاسترداد مع النماذج اللغوية الخفيفة: نموذج جديد للذكاء الاصطناعي الحافظ للخصوصية"
excerpt: "تحليل لأبحاث معهد آلان تورينج حول أنظمة RAG المبنية على نماذج لغوية خفيفة، تشمل هندسة معمارية تدمج الاستدلال والاسترداد للنشر المحلي ونتائج التجارب باستخدام بيانات NHS."
seo_title: "الاستدلال المعزز بالاسترداد مع النماذج اللغوية الخفيفة - ثاكي كلاود"
seo_description: "أحدث أبحاث معهد آلان تورينج حول دمج الاستدلال مع RAG في النماذج اللغوية الخفيفة لأنظمة الذكاء الاصطناعي الحافظة للخصوصية، مع تجارب على بيانات NHS وتحليل الأداء."
date: 2025-08-22
last_modified_at: 2025-08-22
lang: ar
tags:
  - RAG
  - lean-language-models
  - reasoning-systems
  - privacy-ai
  - NHS
  - Qwen2.5
  - DeepSeek-R1
  - test-time-scaling
  - domain-specific
author_profile: true
toc: true
toc_label: "جدول المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/research/retrieval-augmented-reasoning-lean-language-models/"
reading_time: true
published: false
categories:
  - research
---

⏱️ **وقت القراءة المقدر**: 15 دقائق

## مقدمة

بينما يتقدم أداء النماذج اللغوية الكبيرة في الذكاء الاصطناعي بوتيرة مذهلة، يواجه المجال في الوقت ذاته تحديات عملية تتعلق بالخصوصية والأمان وقيود الموارد. تتنامى الحاجة إلى أنظمة ذكاء اصطناعي قابلة للنشر محليًا بأداء عالٍ دون الاعتماد على واجهات برمجية خارجية، لا سيما في القطاعات الحساسة كالرعاية الصحية والمال والحكومة.

تقدم ورقة "الاستدلال المعزز بالاسترداد مع النماذج اللغوية الخفيفة"، التي نشرها باحثون في معهد آلان تورينج مؤخرًا، نهجًا مبتكرًا يلبي هذه المتطلبات العملية. يطور البحث منهجية تجمع بفاعلية بين الاستدلال والتوليد المعزز بالاسترداد ضمن هندسة نموذج لغوي خفيف واحد، متجاوزًا قيود أنظمة RAG الحالية التي تعتمد على نماذج ضخمة وواجهات برمجية خارجية.

يتميز النظام بالتحقق منه باستخدام بيانات حقيقية خاصة بمجال معين، مستمدة من صفحات حالات NHS (هيئة الخدمات الصحية الوطنية) من A إلى Z. يمثل هذا إنجازًا بارزًا يثبت قابلية التطبيق في بيئات الرعاية الصحية الفعلية، متجاوزًا نطاق البحث الأكاديمي البحت.

## خلفية البحث والدوافع

### أهمية التوسع في وقت الاستدلال

أحد الاتجاهات الرئيسية في تحسين أداء النماذج اللغوية الأخيرة هو التوسع في وقت الاستدلال. تُحسّن هذه الاستراتيجية الأداء من خلال توظيف موارد حسابية إضافية خلال الاستدلال بدلًا من زيادة الحوسبة أثناء التدريب المسبق.

تنقسم المنهجيات الرئيسية للتوسع في وقت الاستدلال إلى فئتين: التوليد المتوازي الذي يولد فيه النموذج استجابات مرشحة متعددة ثم يستخلص الإجابة المثلى عبر آليات اختيار كالتصويت الأغلبي أو الاتساق الذاتي، والتوسع التسلسلي الذي يزيد عدد خطوات الاستدلال الوسيطة قبل الوصول إلى الإجابة النهائية.

### تقدم أنظمة RAG وقيودها

أدت أنظمة التوليد المعزز بالاسترداد (RAG) دورًا مهمًا في معالجة الهلوسة في النماذج اللغوية وتحسين دقتها. تبرز فاعلية RAG بشكل خاص في المجالات المعقدة التي تتطلب معرفة متخصصة. غير أن الأنظمة الحالية تُظهر قيودًا واضحة عند التعامل مع المعلومات الحساسة أو السرية، حيث يصعب تطبيقها في سيناريوهات لا يمكن فيها أو لا يجب مشاركة البيانات مع جهات خارجية.

### الحاجة إلى النشر المحلي

أفضت هذه القيود إلى تصاعد الحاجة لنشر النماذج اللغوية على بنية تحتية محلية، بما يشمل البيئات الآمنة أو المعزولة عن الشبكة. وعلى الرغم من نضج النماذج اللغوية مفتوحة المصدر وأطر RAG تدريجيًا، ظل دمج قدرة الاستدلال بفاعلية ضمن قيود النماذج الخفيفة تحديًا بحثيًا قائمًا.

## هندسة النظام وفلسفة التصميم

### المفهوم الأساسي للهندسة الموحدة

يرتكز النظام المقترح في هذا البحث على هندسة موحدة تجمع بفاعلية بين الاستدلال والتوليد المعزز بالاسترداد ضمن نموذج لغوي خفيف واحد. تتمثل فلسفة التصميم الجوهرية في تعظيم التآزر بين مكون الاستدلال ومكون الاسترداد.

يستهدف النظام تطبيقات تعالج استفسارات معقدة عبر قواعد معرفة خاصة بمجال محدد. ينبثق التركيز على النماذج اللغوية الخفيفة من دافع عملي: السماح للمنظمات الصغيرة أو الأقسام الحكومية بضبط دقيق للنماذج ونشرها في بيئات محدودة الموارد الحوسبية أو حرجة أمنيًا.

### تكوين المكونات الرئيسية

تتألف هندسة النظام من ثلاثة مكونات رئيسية: مسترد كثيف مسؤول عن استرداد المستندات ذات الصلة بكفاءة، ونموذج Qwen2.5-Instruct المضبوط دقيقًا بوصفه محرك الاستدلال الأساسي، ووحدة لتوليد الاستفسارات الاصطناعية ومسارات الاستدلال المشتقة من نماذج حدودية كـ DeepSeek-R1.

### خط أنابيب معالجة البيانات

يتمحور خط أنابيب معالجة بيانات النظام حول ثلاثة عناصر محورية: ضغط المستندات القائم على الملخصات، وتصميم البيانات الاصطناعية الذي يحاكي أنماط الاستفسار المتنوعة في المجالات الحقيقية، والضبط الدقيق الواعي بالاستدلال.

## بناء مجموعة البيانات والتصميم التجريبي

### استخدام صفحات حالات NHS من A إلى Z

اختار فريق البحث صفحات حالات NHS من A إلى Z لتجاربه. توفر مجموعة البيانات هذه معلومات شاملة عن 989 حالة طبية مميزة، تتضمن كل صفحة أوصافًا تفصيلية للأعراض والأسباب وطرق العلاج والوقاية. اختيرت بيانات NHS لأن مجال الرعاية الصحية يستلزم دقةً عالية وموثوقية، فضلًا عن كونه ميدانًا بالغ الأهمية لخصوصية المرضى.

### منهجية توليد الاستفسارات الاصطناعية

نظرًا لصعوبة استخدام بيانات المرضى الفعلية، طوّر فريق البحث منهجية متطورة لتوليد الاستفسارات الاصطناعية. تمر العملية بالخطوات التالية:

أولًا، **توليد التركيبة السكانية للمرضى**: إنشاء ملفات تعريف افتراضية للمرضى بخصائص ديموغرافية متنوعة تشمل العمر والجنس والتاريخ الطبي.

ثانيًا، **تطوير سيناريوهات الأعراض**: بناءً على محتوى صفحات حالات NHS، تطوير سيناريوهات تعبر بلغة طبيعية عن الأعراض التي قد يعانيها مريض مصاب بتلك الحالة فعلًا. مثال على استفسار الشقيقة:

```
"عانيت من صداع شديد على مدار اليومين الماضيين.
أشعر بإحساس بالضغط والشد حول رأسي، وأعاني من غثيان خفيف.
يتشوش بصري قليلًا حين أقف بسرعة.
لا أصاب عادةً بهذا الصداع الشديد، لذا بدأ قلقي يتصاعد."
```

ثالثًا، **تصنيف مستوى الخطورة**: تُصنَّف كل استفسار إلى أحد مستويات الخطورة الثلاثة:
- **الرعاية الذاتية**: يمكن إدارتها في المنزل أو بالدواء المتاح دون وصفة طبية
- **الرعاية الأولية العاجلة**: تستلزم استشارة طبيب عام أو مركز رعاية عاجلة في أقرب وقت ممكن
- **الطوارئ**: تستدعي العلاج في غرفة الطوارئ

### عملية توليد مسارات الاستدلال

لتعزيز قدرة الاستدلال لدى النموذج، استخدم فريق البحث نماذج حدودية كـ DeepSeek-R1 لتوليد مسارات استدلال عالية الجودة. يتضمن قالب التعليمات المستخدم في هذه العملية العناصر التالية:

```
استخدم السياق المسترد ودرجات التشابه أدناه
(الدرجات الأدنى تشير إلى تشابه أعلى مع استفسار المريض):
{context}

وصف المريض أعراضه على النحو التالي:
"{question}"

فيما يلي ملخص للمعلومات الديموغرافية للمريض:
{demographics}

باستخدام المصادر والسياق المقدمَين، أرسل الحالة ومستوى الخطورة بالصيغة "(الحالة، الخطورة)".
لا تقدم تفسيرًا لإجابتك، قدّم الإجابة النهائية فحسب.
```

### تحليل أمثلة مجموعة البيانات

يؤكد النظر في الأمثلة الفعلية المقدمة في الورقة تعقيد الاستفسارات وتنوعها التي يجب على النظام معالجتها:

**مثال 1 - حالة ألم صدر عالي الخطورة**:
```json
{
  "query": "منذ الليلة الماضية أشعر بضغط وألم شديد في صدري.
           الألم يمتد إلى ذراعي اليسرى، وأتعرق بغزارة ويصعب علي التنفس.
           هذه المرة الأولى التي أعاني فيها من هذه الأعراض.",
  "demographics": {
    "age": 58,
    "sex": "ذكر",
    "medical_history": ["ارتفاع ضغط الدم", "السكري"]
  },
  "expected_condition": "الاحتشاء القلبي",
  "expected_severity": "الطوارئ"
}
```

**مثال 2 - حالة عسر الهضم الخفيف**:
```json
{
  "query": "أشعر منذ أيام بانتفاخ بعد الوجبات وغثيان خفيف.
           شهيتي أقل من المعتاد لكن ذلك لا يتعارض كثيرًا مع حياتي اليومية.",
  "demographics": {
    "age": 32,
    "sex": "أنثى",
    "medical_history": []
  },
  "expected_condition": "عسر الهضم",
  "expected_severity": "الرعاية الذاتية"
}
```

تُظهر هذه الأمثلة أن النظام يجب أن يتجاوز المطابقة البسيطة للكلمات المفتاحية ليفهم السياقات الطبية المعقدة.

## عملية التدريب واستراتيجية الضبط الدقيق

### خط أنابيب التدريب التدريجي

تتضمن عملية تدريب النظام خط أنابيب تدريجي متعدد المراحل. في المرحلة الأولى يجري تكيّف النموذج مع مجال NHS. في المرحلة الثانية يتعلم النموذج توظيف المستندات المسترجعة بفاعلية. وفي المرحلة الثالثة يُعزَّز بمسارات استدلال عالية الجودة مولَّدة بواسطة DeepSeek-R1.

### نهج التعلم متعدد المهام

اعتمد فريق البحث نهج التعلم متعدد المهام الذي يتيح لنموذج واحد أداء عدة مهام ذات صلة في آنٍ واحد:

1. **تصنيف الحالة**: تحديد أنسب حالة من بين 989 حالة NHS بناءً على وصف المريض
2. **تقييم الخطورة**: تحديد مستوى الرعاية المناسب (الرعاية الذاتية، الرعاية الأولية العاجلة، الطوارئ)
3. **التعامل مع حالات عدم اليقين**: القدرة على الحكم بـ"غير حاسم" حين لا يمكن تشخيص واضح من المعلومات المتاحة وحدها

## منهجية التقييم والنتائج التجريبية

### إطار التقييم الشامل

بنى فريق البحث إطار تقييم شامل لتقييم أداء النظام من زوايا متعددة، يغطي بُعدَي الدقة والاتساق.

### المقارنة مع النماذج الأساسية

قورنت في التجارب نماذج أساسية متعددة:

**نماذج بلا استدلال**:
- Qwen2.5-32B-Instruct الأساسي
- GPT-4o (بلا استرداد)
- نماذج خفيفة للأغراض العامة

**نماذج استدلال للأغراض العامة**:
- DeepSeek-R1
- o3-mini
- s1.1-32B

**النظام المقترح**:
- t0-1.1-k5-32B (النموذج المطور في هذا البحث)

### مؤشرات الأداء الرئيسية

أظهرت النتائج التجريبية تحسينات أداء ملموسة على مؤشرات رئيسية متعددة.

**دقة تحديد الحالة**: حقق نموذج t0-1.1-k5-32B المضبوط دقيقًا لمجال NHS دقةً أعلى بنحو 23% مقارنةً بـ Qwen2.5-32B-Instruct الأساسي.

**دقة تصنيف الخطورة**: سجّل النظام المقترح أداءً أعلى بنحو 35% مقارنةً بنماذج الأغراض العامة، مما يدل على أن أثر التدريب الخاص بمجال الرعاية الصحية يبلغ ذروته في صنع القرار السريري.

**اتساق الاستجابة**: في التقييمات المتكررة لسيناريوهات الأعراض ذاتها، أبدى النظام المقترح اتساقًا يتجاوز 95%.

## إمكانيات التطبيق العملي

### سيناريوهات التطبيق في البيئات الصحية

يُظهر النظام المقترح إمكانات تطبيق فوري في عدة بيئات رعاية صحية حقيقية. أولًا، بوصفه **نظام دعم للرعاية الأولية** يمكن لأطباء الأسرة استخدامه أداةً مساعدة خلال التقييم الأولي للمريض. ثانيًا، بوصفه **أداة لدعم التشخيص الذاتي للمريض** تساعد عامة الناس على تحديد مستوى الخدمة الطبية المناسبة عند ظهور الأعراض. ثالثًا، بوصفه **منصة تعليمية طبية** لكليات الطب وتدريب المهنيين الصحيين.

### القابلية للتوسع إلى مجالات أخرى

المنهجية المُتبَعة في هذا النظام، التي جرى التحقق منها ببيانات NHS الطبية، قابلة للتوسع إلى مجالات متخصصة أخرى: الاستشارة القانونية، والمشورة المالية، وأنظمة الدعم التقني.

### مزايا الخصوصية والأمان

يُعدّ إمكان النشر المحلي الكامل أبرز مزايا هذا النظام. يتيح هذا الالتزامَ بلوائح حماية البيانات الصارمة كـ **GDPR** و**HIPAA**، إذ لا تُرسَل أي معلومات صحية أو شخصية حساسة إلى خوادم خارجية. كما يمكنه العمل في **بيئات معزولة عن الشبكة**، مما يتيح استخدامه الآمن في الجهات الحكومية والمنظمات الدفاعية.

## القيود واتجاهات البحث المستقبلية

### القيود الرئيسية للنظام الحالي

تشمل القيود التي يُقرّ بها فريق البحث بصراحة: **التحيز اللغوي والثقافي الأحادي** نتيجة التدريب على بيانات NHS الإنجليزية، **صعوبة التحديث الفوري** في ظل التطور المستمر للمعرفة الطبية، و**القيود في معالجة المعلومات متعددة الوسائط** مع اقتصار النظام على الأوصاف النصية.

### اتجاهات التحسين على المدى القريب

تشمل اتجاهات التحسين المطروحة: **التوسع متعدد اللغات**، و**تحسين التعامل مع الحالات النادرة** عبر التعلم بأمثلة قليلة أو التعلم الميتا، و**تحسين واجهة المستخدم** لضمان سهولة الاستخدام من قِبَل العاملين الصحيين والمستخدمين العامين.

### التحديات البحثية على المدى المتوسط والبعيد

تشمل التحديات الأبعد مدى: **دمج الذكاء الاصطناعي متعدد الوسائط** بما يتجاوز النص، و**دمج التعلم الفيدرالي** الذي يتيح لكل مؤسسة صحية تحسين الأداء الكلي دون مشاركة بياناتها خارجيًا، و**قدرة التعلم والتكيف الفوري** بناءً على تغذية راجعة الاستخدام.

## الخلاصة والإسهامات

### الإسهامات الجوهرية للبحث

يُقدم هذا البحث إسهامات مهمة في مجال الذكاء الاصطناعي. أولًا، تحقيق **دمج الاستدلال والاسترداد في نماذج خفيفة** بوصفه ابتكارًا تقنيًا. ثانيًا، إثبات قيمة عملية تتجاوز البحث الأكاديمي من خلال **التحقق في مجال حقيقي** ببيانات NHS. ثالثًا، ضمان إمكانية إعادة إنتاج البحث ونشره عبر **الإصدار مفتوح المصدر**.

### الأثر على الصناعة

في ظل تصاعد اتجاه **الذكاء الاصطناعي المحوري للخصوصية**، يُقدم هذا البحث حلًا تقنيًا يضمن أمان البيانات مع الحفاظ على الأداء العالي. يُتوقع أن يُسهم في تخفيض عوائق اعتماد الذكاء الاصطناعي في القطاعات ذات الخصوصية العالية كالرعاية الصحية والمال والقانون.

يُثبت هذا البحث أيضًا إمكانية **الذكاء الاصطناعي الاقتصادي في الموارد** الذي يوفر خدمات عالية الجودة دون الاعتماد على بنية تحتية سحابية ضخمة، مما يُفتح الباب أمام الشركات الصغيرة والمتوسطة والمنظمات محدودة الموارد للاستفادة من تقنيات الذكاء الاصطناعي المتقدمة.

## مخطط تدفق عملية التعلم

يمكن تلخيص عملية تطوير النظام الكلية المقدمة في البحث في المخطط التالي:

{% raw %}
<!--
  animated-architecture-diagram — self-contained D3 embed template.
  HuggingFace research-article style: declarative NODES/EDGES/SEQ model,
  data(solid)/event(dashed) edges, hover-trace + tooltip, flow-dot animation
  along edge paths, replay button, scroll-into-view autoplay, reduced-motion +
  light/dark aware. The renderer injects window.__ARCH_SPEC__ at the marker.
  Format (D3 machinery + CSS) is owned by this committed template; the model
  only authors the JSON spec (content). See references/spec-schema.md.
-->
<div class="d3-arch" data-arch-root id="soningleanlanguagemodels-1"></div>
<style>
  /* ---- Theme tokens (standalone; light default + dark override) ---- */
  .d3-arch {
    --page-bg: #ffffff;
    --surface-bg: #f7f8fa;
    --text-color: #1a1d21;
    --muted-color: #6b7280;
    --border-color: #d5d9e0;
    --primary-color: hsl(217 91% 55%); /* brand accent — swap for #1B4F72 etc. */
    position: relative;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Noto Sans KR", system-ui, sans-serif;
    color: var(--text-color);
  }
  @media (prefers-color-scheme: dark) {
    .d3-arch {
      --page-bg: #0f1115;
      --surface-bg: #171a21;
      --text-color: #e6e8eb;
      --muted-color: #9aa3af;
      --border-color: #2a2f3a;
      --primary-color: hsl(217 91% 62%);
    }
  }
  .d3-arch[data-theme="light"] { --page-bg:#fff; --surface-bg:#f7f8fa; --text-color:#1a1d21; --muted-color:#6b7280; --border-color:#d5d9e0; --primary-color:hsl(217 91% 55%); }
  .d3-arch[data-theme="dark"]  { --page-bg:#0f1115; --surface-bg:#171a21; --text-color:#e6e8eb; --muted-color:#9aa3af; --border-color:#2a2f3a; --primary-color:hsl(217 91% 62%); }

  .d3-arch .diagram-scroll { overflow-x: auto; }
  .d3-arch svg { display: block; width: 100%; max-width: 100%; height: auto; font-family: inherit; }

  /* Group boxes */
  .d3-arch .group rect { fill: none; stroke: var(--border-color); stroke-dasharray: 3 3; rx: 12px; }
  .d3-arch .group text { font-size: 10px; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase; fill: var(--muted-color); }

  /* Nodes */
  .d3-arch .node rect { fill: var(--surface-bg); stroke: var(--border-color); stroke-width: 1; transition: stroke 0.15s ease, opacity 0.15s ease; }
  .d3-arch .node .node-title { font-size: 12px; font-weight: 600; fill: var(--text-color); }
  .d3-arch .node .node-sub { font-size: 9.5px; fill: var(--muted-color); }
  .d3-arch .node { cursor: default; transition: opacity 0.15s ease; }

  /* Edges */
  .d3-arch .edge { transition: opacity 0.15s ease; }
  .d3-arch .edge path.main { fill: none; stroke-width: 1.5; }
  .d3-arch .edge.data path.main { stroke: var(--primary-color); }
  .d3-arch .edge.event path.main { stroke: var(--muted-color); stroke-dasharray: 5 4; }
  .d3-arch .edge text { font-size: 9.5px; fill: var(--muted-color); paint-order: stroke; stroke: var(--page-bg); stroke-width: 3px; stroke-linejoin: round; }

  /* Hover highlighting */
  .d3-arch.hovering .edge:not(.hl) { opacity: 0.12; }
  .d3-arch.hovering .node:not(.hl):not(.nb) { opacity: 0.25; }
  .d3-arch .node.hl rect { stroke: var(--primary-color); stroke-width: 1.5; }

  /* Flow animation */
  .d3-arch .flow-dot.data { fill: var(--primary-color); stroke: var(--page-bg); stroke-width: 1.5; }
  .d3-arch .flow-dot.event { fill: var(--page-bg); stroke: var(--muted-color); stroke-width: 1.5; }
  .d3-arch .node.anim-hl rect { stroke: var(--primary-color); stroke-width: 1.5; }
  .d3-arch .replay-btn { font: inherit; font-size: 11px; font-weight: 600; padding: 4px 10px; border: 1px solid var(--border-color); border-radius: 8px; background: var(--surface-bg); color: var(--text-color); cursor: pointer; transition: border-color 0.15s ease, opacity 0.15s ease; }
  .d3-arch .replay-btn:hover:not(:disabled) { border-color: var(--primary-color); }
  .d3-arch .replay-btn:disabled { opacity: 0.45; cursor: default; }
  .d3-arch .replay-btn:focus-visible { outline: 2px solid var(--primary-color); outline-offset: 1px; }

  /* Legend */
  .d3-arch .legend { display: flex; flex-direction: column; align-items: flex-start; gap: 6px; margin-top: 10px; }
  .d3-arch .legend-title { font-size: 12px; font-weight: 700; color: var(--text-color); }
  .d3-arch .legend .items { display: flex; flex-wrap: wrap; gap: 8px 18px; align-items: center; }
  .d3-arch .legend .item { display: inline-flex; align-items: center; gap: 7px; white-space: nowrap; font-size: 12px; color: var(--text-color); }
  .d3-arch .legend .swatch { width: 22px; height: 0; }
  .d3-arch .legend .swatch.data-line { border-top: 2.5px solid var(--primary-color); }
  .d3-arch .legend .swatch.event-line { border-top: 2.5px dashed var(--muted-color); }
  .d3-arch .legend .hint { font-size: 11px; font-style: italic; color: var(--muted-color); }
</style>
<script>
  (() => {
    const SPEC = ({"title": "", "ariaLabel": "", "width": 719, "height": 1114, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 249, "y": 24, "w": 212, "h": 62, "title": ["صفحات حالات NHS من A إلى Z", "(989 حالة)"]}, {"id": "B", "x": 294, "y": 304, "w": 142, "h": 62, "title": ["معالجة المستندات", "وتقسيمها"]}, {"id": "C", "x": 304, "y": 444, "w": 121, "h": 62, "title": ["توليد التضمين", "المتجهي"]}, {"id": "D", "x": 305, "y": 584, "w": 120, "h": 62, "title": ["بناء فهرس", "الاسترداد"]}, {"id": "E", "x": 53, "y": 24, "w": 135, "h": 62, "title": ["توليد التركيبة", "السكانية للمرضى"]}, {"id": "F", "x": 56, "y": 164, "w": 149, "h": 62, "title": ["توليد الاستفسارات", "الاصطناعية"]}, {"id": "G", "x": 45, "y": 304, "w": 170, "h": 62, "title": ["توليد مسار الاستدلال", "بواسطة DeepSeek-R1"]}, {"id": "H", "x": 52, "y": 444, "w": 156, "h": 62, "title": ["بناء مجموعة بيانات", "الضبط الدقيق"]}, {"id": "I", "x": 24, "y": 584, "w": 212, "h": 62, "title": ["الضبط الدقيق لتكيّف", "Qwen2.5-Instruct مع المجال"]}, {"id": "J", "x": 181, "y": 724, "w": 120, "h": 46, "title": "دمج نظام RAG"}, {"id": "K", "x": 159, "y": 848, "w": 163, "h": 94, "title": ["تقييم الأداء", "- دقة تحديد الحالة", "- دقة تصنيف الخطورة", "- اتساق الاستجابة"]}, {"id": "L", "x": 177, "y": 1020, "w": 128, "h": 62, "title": ["النظام النهائي", "القابل للنشر"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [359, 86, 365, 304]}, {"src": "B", "dst": "C", "kind": "data", "line": [365, 366, 365, 444]}, {"src": "C", "dst": "D", "kind": "data", "line": [365, 506, 365, 584]}, {"src": "E", "dst": "F", "kind": "data", "line": [120, 86, 126, 164]}, {"src": "A", "dst": "F", "kind": "data", "line": [306, 86, 181, 164]}, {"src": "F", "dst": "G", "kind": "data", "line": [130, 226, 130, 304]}, {"src": "G", "dst": "H", "kind": "data", "line": [130, 366, 130, 444]}, {"src": "H", "dst": "I", "kind": "data", "line": [130, 506, 130, 584]}, {"src": "D", "dst": "J", "kind": "data", "curve": [[365, 646], [365, 685], [365, 685], [287, 724]]}, {"src": "I", "dst": "J", "kind": "data", "curve": [[130, 646], [130, 685], [130, 685], [200, 724]]}, {"src": "J", "dst": "K", "kind": "data", "line": [241, 770, 241, 848]}, {"src": "K", "dst": "L", "kind": "data", "line": [241, 942, 241, 1020]}]});
    const ensureD3 = (cb) => {
      if (window.d3 && typeof window.d3.select === 'function') return cb();
      let s = document.getElementById('d3-cdn-script');
      if (!s) {
        s = document.createElement('script');
        s.id = 'd3-cdn-script';
        s.src = 'https://cdn.jsdelivr.net/npm/d3@7/dist/d3.min.js';
        document.head.appendChild(s);
      }
      const onReady = () => { if (window.d3 && typeof window.d3.select === 'function') cb(); };
      s.addEventListener('load', onReady, { once: true });
      if (window.d3) onReady();
    };

    const bootstrap = () => {
      const container = document.getElementById('soningleanlanguagemodels-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'soningleanlanguagemodels-1';
        const NODES = SPEC.nodes || [];
        const EDGES = SPEC.edges || [];
        const GROUPS = SPEC.groups || [];
        const HOP = SPEC.hop || 800;
        const legendCfg = SPEC.legend || {};
        const dataLabel = legendCfg.data || 'Data path';
        const eventLabel = legendCfg.event || 'Event side-channel';

        const byId = Object.fromEntries(NODES.map((n) => [n.id, n]));
        const cx = (n) => n.x + n.w / 2;
        const asTitle = (t) => Array.isArray(t) ? t : [t];

        // Canvas: explicit, else auto from node/group extents + padding
        let W = SPEC.width, H = SPEC.height;
        if (!W || !H) {
          const xs = [], ys = [];
          NODES.forEach((n) => { xs.push(n.x + n.w); ys.push(n.y + n.h); });
          GROUPS.forEach((g) => { xs.push(g.x + g.w); ys.push(g.y + g.h); });
          W = W || Math.max(760, Math.ceil(Math.max(...xs, 0) + 24));
          H = H || Math.ceil(Math.max(...ys, 0) + 20);
        }

        // Tooltip
        container.style.position = container.style.position || 'relative';
        const tip = document.createElement('div');
        Object.assign(tip.style, {
          position: 'absolute', top: '0px', left: '0px',
          transform: 'translate(-9999px, -9999px)', pointerEvents: 'none',
          padding: '8px 10px', borderRadius: '8px', fontSize: '12px', lineHeight: '1.4',
          border: '1px solid var(--border-color)', background: 'var(--surface-bg)',
          color: 'var(--text-color)', boxShadow: '0 4px 24px rgba(0,0,0,.18)',
          opacity: '0', transition: 'opacity .12s ease', maxWidth: '260px', zIndex: '3'
        });
        const tipInner = document.createElement('div');
        tip.appendChild(tipInner);

        const scroll = document.createElement('div');
        scroll.className = 'diagram-scroll';
        container.appendChild(scroll);

        const svg = d3.select(scroll).append('svg')
          .attr('viewBox', `0 0 ${W} ${H}`)
          .attr('preserveAspectRatio', 'xMidYMid meet')
          .attr('role', 'img')
          .attr('aria-label', SPEC.ariaLabel || SPEC.title || 'Architecture diagram');
        svg.style('max-width', W + 'px').style('min-width', Math.min(W, 760) + 'px').style('margin', '0 auto');

        const defs = svg.append('defs');
        const mkMarker = (id, color) => {
          defs.append('marker')
            .attr('id', id).attr('viewBox', '0 0 10 10')
            .attr('refX', 9).attr('refY', 5)
            .attr('markerWidth', 6.5).attr('markerHeight', 6.5)
            .attr('orient', 'auto-start-reverse')
            .append('path').attr('d', 'M 0 0 L 10 5 L 0 10 z').style('fill', color);
        };
        mkMarker(`${uid}-arrow-data`, 'var(--primary-color)');
        mkMarker(`${uid}-arrow-event`, 'var(--muted-color)');

        // Groups
        const groups = svg.append('g');
        GROUPS.forEach((gr) => {
          const g = groups.append('g').attr('class', 'group');
          g.append('rect').attr('x', gr.x).attr('y', gr.y).attr('width', gr.w).attr('height', gr.h).attr('rx', 12);
          if (gr.label) g.append('text').attr('x', gr.lx != null ? gr.lx : gr.x + 12).attr('y', gr.ly != null ? gr.ly : gr.y + 18).text(gr.label);
        });

        // Edges (under nodes)
        const edgeLayer = svg.append('g');
        const curvePath = (p) => `M ${p[0][0]} ${p[0][1]} C ${p[1][0]} ${p[1][1]}, ${p[2][0]} ${p[2][1]}, ${p[3][0]} ${p[3][1]}`;
        EDGES.forEach((e, i) => {
          const kind = e.kind === 'event' ? 'event' : 'data';
          const g = edgeLayer.append('g').attr('class', `edge ${kind}`).attr('data-src', e.src).attr('data-dst', e.dst);
          const marker = `url(#${uid}-arrow-${kind})`;
          if (e.line) {
            const [x1, y1, x2, y2] = e.line;
            e.pathEl = g.append('path').attr('class', 'main').attr('d', `M ${x1} ${y1} L ${x2} ${y2}`).attr('marker-end', marker).node();
            if (e.label) g.append('text').attr('x', e.lx != null ? e.lx : (x1 + x2) / 2).attr('y', e.ly != null ? e.ly : (y1 + y2) / 2 - 6).attr('text-anchor', e.anchor || 'middle').text(e.label);
          } else if (e.curve) {
            e.pathEl = g.append('path').attr('class', 'main').attr('d', curvePath(e.curve)).attr('marker-end', marker).node();
            if (e.label && e.off) {
              const p = e.curve;
              const lp = p[3][0] < p[0][0] ? [p[3], p[2], p[1], p[0]] : p;
              const lpId = `${uid}-lbl-${i}`;
              g.append('path').attr('id', lpId).attr('d', curvePath(lp)).attr('fill', 'none').attr('stroke', 'none');
              g.append('text').attr('dy', -5).append('textPath').attr('href', `#${lpId}`).attr('startOffset', e.off).attr('text-anchor', 'middle').text(e.label);
            } else if (e.label) {
              g.append('text').attr('x', e.lx).attr('y', e.ly).attr('text-anchor', e.anchor || 'start').text(e.label);
            }
          }
        });

        // Nodes (over edges)
        const nodeLayer = svg.append('g');
        NODES.forEach((n) => {
          const g = nodeLayer.append('g').attr('class', 'node').attr('data-id', n.id);
          g.append('rect').attr('x', n.x).attr('y', n.y).attr('width', n.w).attr('height', n.h).attr('rx', 9);
          const title = asTitle(n.title);
          const lines = title.length;
          const baseY = n.y + n.h / 2 - (lines - 1) * 7 - (n.sub ? 5 : -4);
          title.forEach((t, li) => {
            g.append('text').attr('class', 'node-title').attr('x', cx(n)).attr('y', baseY + li * 14).attr('text-anchor', 'middle').text(t);
          });
          if (n.sub) g.append('text').attr('class', 'node-sub').attr('x', cx(n)).attr('y', baseY + (lines - 1) * 14 + 15).attr('text-anchor', 'middle').text(n.sub);
        });

        // Hover highlighting
        const edgeSel = svg.selectAll('.edge');
        const nodeSel = svg.selectAll('.node');
        nodeSel
          .on('mouseenter', function () {
            const id = this.getAttribute('data-id');
            const n = byId[id];
            container.classList.add('hovering');
            const nb = new Set([id]);
            edgeSel.classed('hl', function () {
              const hit = this.getAttribute('data-src') === id || this.getAttribute('data-dst') === id;
              if (hit) { nb.add(this.getAttribute('data-src')); nb.add(this.getAttribute('data-dst')); }
              return hit;
            });
            nodeSel.classed('hl', function () { return this.getAttribute('data-id') === id; })
                   .classed('nb', function () { return nb.has(this.getAttribute('data-id')); });
            if (n && n.desc) { tipInner.innerHTML = `<strong>${asTitle(n.title).join('')}</strong><br>${n.desc}`; tip.style.opacity = '1'; }
          })
          .on('mousemove', function (event) {
            const [mx, my] = d3.pointer(event, container);
            const flip = mx > container.clientWidth - 280;
            tip.style.transform = `translate(${flip ? mx - 270 : mx + 14}px, ${my + 14}px)`;
          })
          .on('mouseleave', function () {
            container.classList.remove('hovering');
            edgeSel.classed('hl', false);
            nodeSel.classed('hl', false).classed('nb', false);
            tip.style.opacity = '0';
            tip.style.transform = 'translate(-9999px, -9999px)';
          });

        // Flow animation sequence: explicit SEQ, else auto forward-cascade of data edges
        const resolveEdge = (s) => {
          if (typeof s.e === 'number') return s.e;
          if (s.from && s.to) return EDGES.findIndex((e) => e.src === s.from && e.dst === s.to);
          return -1;
        };
        let SEQ = (SPEC.seq || []).map((s) => ({ e: resolveEdge(s), t0: s.t0 })).filter((s) => s.e >= 0);
        if (!SEQ.length) {
          let t = 0;
          EDGES.forEach((e, i) => { if ((e.kind || 'data') === 'data') { SEQ.push({ e: i, t0: t }); t += HOP; } });
        }
        const TOTAL = SPEC.total || (Math.max(0, ...SEQ.map((s) => s.t0)) + HOP + 800);

        let playing = false, replayBtn = null;
        const pulseNode = (id) => {
          const sel = nodeSel.filter(function () { return this.getAttribute('data-id') === id; });
          sel.classed('anim-hl', true);
          setTimeout(() => sel.classed('anim-hl', false), 550);
        };
        const play = () => {
          if (playing) return;
          playing = true;
          if (replayBtn) replayBtn.disabled = true;
          const layer = svg.append('g');
          const steps = SEQ.map((s) => {
            const edge = EDGES[s.e];
            return { ...s, edge, len: edge.pathEl.getTotalLength(), dot: null, arrived: false };
          });
          const start = performance.now();
          const frame = (now) => {
            const t = now - start;
            steps.forEach((s) => {
              if (t < s.t0) return;
              const f = Math.min(1, (t - s.t0) / HOP);
              if (f >= 1) { if (s.dot) { s.dot.remove(); s.dot = null; } if (!s.arrived) { s.arrived = true; pulseNode(s.edge.dst); } return; }
              if (!s.dot) s.dot = layer.append('circle').attr('class', `flow-dot ${s.edge.kind || 'data'}`).attr('r', (s.edge.kind === 'event') ? 4 : 5);
              const p = s.edge.pathEl.getPointAtLength(d3.easeCubicInOut(f) * s.len);
              s.dot.attr('cx', p.x).attr('cy', p.y);
            });
            if (t < TOTAL) requestAnimationFrame(frame);
            else { layer.remove(); playing = false; if (replayBtn) replayBtn.disabled = false; }
          };
          requestAnimationFrame(frame);
        };

        // Legend
        const legend = document.createElement('div');
        legend.className = 'legend';
        legend.innerHTML = `
          <div class="legend-title">${SPEC.legendTitle || 'Legend'}</div>
          <div class="items">
            <span class="item"><span class="swatch data-line"></span><span>${dataLabel}</span></span>
            <span class="item"><span class="swatch event-line"></span><span>${eventLabel}</span></span>
            <button class="replay-btn" type="button" aria-label="Replay the flow animation">&#9654; Replay</button>
            <span class="hint">${SPEC.hint || 'Hover a component to trace its connections.'}</span>
          </div>`;
        container.appendChild(legend);
        container.appendChild(tip);
        replayBtn = legend.querySelector('.replay-btn');
        replayBtn.addEventListener('click', play);

        const prefersReduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        if (!prefersReduced && window.IntersectionObserver) {
          const io = new IntersectionObserver((entries) => {
            entries.forEach((en) => { if (en.isIntersecting) { io.disconnect(); play(); } });
          }, { threshold: 0.5 });
          io.observe(container);
        }
      } catch (err) {
        const pre = document.createElement('pre');
        pre.style.color = '#c0392b';
        pre.style.fontSize = '12px';
        pre.textContent = 'Failed to render architecture diagram: ' + (err && err.message ? err.message : err);
        container.appendChild(pre);
      }
    };

    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', () => ensureD3(bootstrap), { once: true });
    else ensureD3(bootstrap);
  })();
</script>
{% endraw %}

## قوالب التعليمات التفصيلية وأمثلة مجموعة البيانات

### قالب توليد الاستفسارات الاصطناعية

قالب التعليمات المحدد الذي استخدمه فريق البحث لتوليد الاستفسارات الاصطناعية:

```
أنشئ استفسارًا بناءً على التفاصيل التالية:

نوع الاستفسار: {query_type}
مستوى الخطورة: {severity_level}
الجنس: {sex}
محتوى صفحة الحالات: {conditions_content}

استخدم لغةً طبيعية كما يصف المريض أعراضه.
تجنب المصطلحات الطبية؛ استخدم تعابير يستخدمها غير المتخصصين.

صيغة الإخراج (JSON):
{
  "query": "اكتب وصفًا تفصيليًا للأعراض هنا.",
  "demographics": {
    "age": العمر,
    "sex": "الجنس",
    "medical_history": ["الحالات الموجودة"]
  }
}
```

### تعليمات توليد مسار الاستدلال

التعليمات المستخدمة لتوليد مسارات الاستدلال باستخدام نموذج DeepSeek-R1:

```
استخدم السياق المسترد ودرجات التشابه التالية
(الدرجات الأدنى تشير إلى تشابه أعلى مع استفسار المريض):
{context}

وصف المريض أعراضه على النحو التالي:
"{question}"

فيما يلي ملخص للمعلومات الديموغرافية للمريض:
{demographics}

باستخدام المصادر والسياق المقدمَين، أرسل الحالة ومستوى الخطورة بالصيغة
"(الحالة، الخطورة)".
لا تقدم تفسيرًا لإجابتك، قدّم الإجابة النهائية فحسب.

يجب أن تكون الحالة إحدى {sources}، أو
"غير حاسم" إن قررت أن الحالة ليست في القائمة.
يجب أن يكون مستوى الخطورة أحد ["الرعاية الذاتية"، "الرعاية الأولية العاجلة"، "الطوارئ"].
```

### تعليمات التقييم

قالب التعليمات القائم على الأداة المستخدم لتقييم النظام:

**تعليمات النظام:**
```
أنت مساعد طبي بالذكاء الاصطناعي.
ستستقبل وصف مريض لأعراضه، والسياق المسترد ذو الصلة، ودرجة تشابه كل سياق.

يجب أن تقترح الحالة الأكثر احتمالًا ومستوى الخطورة.
يجب اختيار الخطورة من الخيارات التالية:

* الطوارئ: تستدعي العلاج في غرفة الطوارئ
* الرعاية الأولية العاجلة: تستلزم استشارة طبيب عام أو مركز رعاية عاجلة في أقرب وقت
* الرعاية الذاتية: يمكن إدارتها في المنزل أو بالدواء المتاح دون وصفة طبية

استخدم الأداة المقدمة لإرسال الحالة ومستوى الخطورة.
استخدم "غير حاسم" إن قررت أن الحالة ليست في القائمة.
```

**قالب تعليمات المستخدم:**
```
استخدم السياق المسترد ودرجات التشابه التالية:
{context}

وصف المريض أعراضه على النحو التالي:
"{question}"

المعلومات الديموغرافية للمريض:
{demographics}

باستخدام المصادر والسياق المقدمَين،
أرسل الحالة ومستوى الخطورة عبر أداة "submit_condition_recommendation".

يجب أن تكون الحالة إحدى {sources} أو "غير حاسم".
يجب أن تكون الخطورة إحدى ["الرعاية الذاتية"، "الرعاية الأولية العاجلة"، "الطوارئ"].
```

### آلية ضمان جودة البيانات

نفّذ فريق البحث عمليات التحقق التالية لضمان جودة البيانات الاصطناعية:

1. **مراجعة الخبراء الطبيين**: التحقق من الاحتمالية الطبية لسيناريوهات الأعراض المولَّدة
2. **ضمان التنوع**: التأكد من التوزيع المتوازن للعمر والجنس والتاريخ الطبي
3. **التحقق من الواقعية**: التأكد من استخدام تعابير طبيعية يستخدمها المريض الفعلي
4. **اتساق الخطورة**: التأكد من الاتساق في أحكام الخطورة للحالة ذاتها

شكّلت هذه العملية المنهجية لبناء مجموعة البيانات والتحقق منها العامل الرئيسي في تحسين موثوقية النظام وعمليته بشكل ملحوظ.
