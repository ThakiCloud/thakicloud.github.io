---
title: "دليل إعداد Podman Desktop الشامل: إدارة الحاويات أصبحت سهلة"
excerpt: "تعلم كيفية تثبيت وتكوين واستخدام Podman Desktop - أفضل أداة مجانية ومفتوحة المصدر لتطوير الحاويات و Kubernetes. دليل شامل مع أمثلة عملية ونصائح حل المشاكل."
seo_title: "دليل إعداد Podman Desktop 2025 - شرح شامل - Thaki Cloud"
seo_description: "إتقان تثبيت وتكوين Podman Desktop على macOS و Windows و Linux. دليل شامل مع أمثلة إدارة الحاويات وتكامل Kubernetes وأفضل الممارسات."
date: 2025-09-05
lang: ar
permalink: /ar/tutorials/podman-desktop-complete-setup-guide/
canonical_url: "https://thakicloud.github.io/ar/tutorials/podman-desktop-complete-setup-guide/"
categories:
  - tutorials
tags:
  - podman
  - docker
  - حاويات
  - كوبرنيتس
  - أدوات-سطح-المكتب
  - إدارة-الحاويات
  - مفتوح-المصدر
author_profile: true
toc: true
toc_label: "جدول المحتويات"
---

⏱️ **الوقت المقدر للقراءة**: 15 دقيقة

## مقدمة

يُحدث [Podman Desktop](https://github.com/podman-desktop/podman-desktop) ثورة في طريقة عمل المطورين مع الحاويات و Kubernetes. كأفضل أداة مجانية ومفتوحة المصدر لتطوير الحاويات، فإنها توفر واجهة رسومية بديهية تجعل إدارة الحاويات في متناول المطورين من جميع المستويات.

في هذا الدليل الشامل، سنغطي كل ما تحتاج لمعرفته حول Podman Desktop - من التثبيت إلى إدارة الحاويات المتقدمة وتكامل Kubernetes.

## ما هو Podman Desktop؟

Podman Desktop هو واجهة رسومية تمكن مطوري التطبيقات من العمل بسلاسة مع الحاويات و Kubernetes. على عكس أدوات سطر الأوامر التقليدية، فإنه يوفر:

- **إدارة مرئية للحاويات**: بناء وتشغيل وإدارة وتصحيح الحاويات من خلال واجهة مستخدم بديهية
- **دعم محركات متعددة**: يعمل مع محركات الحاويات Podman و Docker و crc و Lima
- **تكامل Kubernetes**: اتصال ونشر إلى بيئات Kubernetes المحلية أو البعيدة
- **تكامل علبة النظام**: وصول سريع دون فقدان التركيز من المهام الأخرى
- **ميزات المؤسسة**: دعم البروكسي وإدارة سجلات OCI
- **نظام التوسعات**: قدرات قابلة للتوسيع من خلال التوسعات

## الميزات والفوائد الرئيسية

### 🎯 القدرات الأساسية

1. **لوحة تحكم الحاويات والبودات**
   - إدارة مرئية لدورة حياة الحاوية
   - إنشاء ونشر البودات
   - تحويل الحاوية إلى Kubernetes
   - تنسيق متعدد المحركات

2. **دعم محركات الحاويات المتعددة**
   - Podman (المحرك الأساسي)
   - توافق Docker
   - crc (CodeReady Containers)
   - Lima (Linux Machines)

3. **التحديثات التلقائية**
   - إبقاء Podman محدثًا تلقائيًا
   - إدارة إصدارات سلسة
   - إشعارات التحديث في الخلفية

4. **ميزات على مستوى المؤسسة**
   - دعم بروكسي الشركة
   - تكامل السجل الخاص
   - الامتثال لسياسات الأمان
   - أدوات التعاون الجماعي

## دليل التثبيت

### المتطلبات الأساسية

قبل تثبيت Podman Desktop، تأكد من أن نظامك يلبي هذه المتطلبات:

- **macOS**: 10.15 (Catalina) أو أحدث
- **Windows**: Windows 10/11 (64-bit)
- **Linux**: معظم التوزيعات الحديثة
- **ذاكرة الوصول العشوائي**: 4GB كحد أدنى، 8GB+ موصى به
- **مساحة القرص**: على الأقل 2GB مساحة فارغة

### التثبيت على macOS

#### الطريقة 1: التحميل من الموقع الرسمي

1. **زيارة صفحة التحميلات**
   ```bash
   open https://podman-desktop.io/downloads
   ```

2. **تحميل حزمة macOS**
   - اختر ملف `.dmg` لنظام macOS
   - اختر بين إصدارات Intel أو Apple Silicon

3. **تثبيت التطبيق**
   ```bash
   # تثبيت ملف DMG
   hdiutil mount ~/Downloads/podman-desktop-*.dmg
   
   # نسخ إلى التطبيقات
   cp -R "/Volumes/Podman Desktop/Podman Desktop.app" /Applications/
   
   # إلغاء تثبيت DMG
   hdiutil unmount "/Volumes/Podman Desktop"
   ```

#### الطريقة 2: استخدام Homebrew

```bash
# التثبيت باستخدام Homebrew Cask
brew install --cask podman-desktop

# التحقق من التثبيت
brew list --cask | grep podman-desktop
```

#### الطريقة 3: استخدام MacPorts

```bash
# التثبيت باستخدام MacPorts
sudo port install podman-desktop

# تحديث تعريفات المنافذ
sudo port selfupdate
```

### التثبيت على Windows

#### الطريقة 1: التحميل المباشر

1. تحميل مثبت Windows من [podman-desktop.io](https://podman-desktop.io/downloads)
2. تشغيل مثبت `.exe` كمدير
3. اتباع معالج التثبيت

#### الطريقة 2: استخدام Chocolatey

```powershell
# تثبيت Chocolatey (إذا لم يكن مثبتًا بالفعل)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# تثبيت Podman Desktop
choco install podman-desktop
```

#### الطريقة 3: استخدام winget

```powershell
# التثبيت باستخدام Windows Package Manager
winget install podman-desktop
```

### التثبيت على Linux

#### الطريقة 1: Flatpak (موصى به)

```bash
# تثبيت Flatpak (إذا لم يكن متاحًا)
sudo apt update && sudo apt install flatpak  # Ubuntu/Debian
sudo dnf install flatpak                      # Fedora
sudo pacman -S flatpak                        # Arch Linux

# إضافة مستودع Flathub
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# تثبيت Podman Desktop
flatpak install flathub io.podman_desktop.PodmanDesktop

# تشغيل التطبيق
flatpak run io.podman_desktop.PodmanDesktop
```

#### الطريقة 2: AppImage

```bash
# تحميل AppImage
curl -LO https://github.com/podman-desktop/podman-desktop/releases/latest/download/podman-desktop-*.AppImage

# جعله قابل للتنفيذ
chmod +x podman-desktop-*.AppImage

# تشغيل التطبيق
./podman-desktop-*.AppImage
```

#### الطريقة 3: مديرو الحزم

```bash
# Fedora/RHEL/CentOS
sudo dnf install podman-desktop

# Ubuntu/Debian (استخدام حزمة .deb)
wget https://github.com/podman-desktop/podman-desktop/releases/latest/download/podman-desktop_*_amd64.deb
sudo dpkg -i podman-desktop_*_amd64.deb
sudo apt-get install -f  # إصلاح التبعيات إذا لزم الأمر

# Arch Linux (AUR)
yay -S podman-desktop
```

## الإعداد الأولي والتكوين

### إعداد التشغيل الأول

1. **تشغيل Podman Desktop**
   ```bash
   # macOS
   open "/Applications/Podman Desktop.app"
   
   # Linux (إذا تم تثبيته عبر مدير الحزم)
   podman-desktop
   
   # Windows
   # استخدم قائمة ابدأ أو اختصار سطح المكتب
   ```

2. **إكمال معالج الترحيب**
   - قبول شروط الخدمة
   - اختيار تفضيلات التثبيت
   - تكوين إعدادات محرك الحاوية

### تكوين محرك الحاوية

#### إعداد محرك Podman

```bash
# macOS: تثبيت Podman عبر Homebrew
brew install podman

# تهيئة آلة Podman (macOS/Windows)
podman machine init
podman machine start

# التحقق من تثبيت Podman
podman version
podman info
```

#### توافق Docker

```bash
# تمكين توافق Docker API
podman system service --time=0 unix:///tmp/podman.sock

# تعيين اسم مستعار لمقبس Docker (اختياري)
export DOCKER_HOST=unix:///tmp/podman.sock
```

### تكوين علبة النظام

1. **تمكين علبة النظام**
   - انتقل إلى الإعدادات → عام
   - تمكين "إظهار في علبة النظام"
   - تكوين سلوك البدء

2. **تخصيص خيارات العلبة**
   - تعيين تفضيلات محرك الحاوية
   - تكوين إعدادات الإشعارات
   - تمكين/تعطيل البدء التلقائي

## عمليات الحاوية الأساسية

### إنشاء أول حاوية

#### الطريقة 1: استخدام واجهة المستخدم الرسومية

1. **التنقل إلى الصور**
   - انقر على "Images" في الشريط الجانبي
   - انقر على "Pull an image"
   - أدخل اسم الصورة (مثل: `nginx:latest`)

2. **تشغيل الحاوية**
   - انقر على زر "Run" بجانب الصورة
   - تكوين إعدادات الحاوية:
     - اسم الحاوية: `my-nginx`
     - تعيين المنفذ: `8080:80`
     - متغيرات البيئة (إذا لزم الأمر)

3. **التحقق من حالة الحاوية**
   - تحقق من علامة التبويب "Containers"
   - تأكد من أن الحاوية قيد التشغيل
   - الوصول إلى التطبيق على `http://localhost:8080`

#### الطريقة 2: استخدام تكامل الطرفية

```bash
# سحب صورة
podman pull nginx:latest

# تشغيل حاوية مع تعيين المنفذ
podman run -d --name my-nginx -p 8080:80 nginx:latest

# سرد الحاويات قيد التشغيل
podman ps

# فحص سجلات الحاوية
podman logs my-nginx

# إيقاف الحاوية
podman stop my-nginx

# إزالة الحاوية
podman rm my-nginx
```

### بناء صور مخصصة

#### إنشاء تطبيق ويب بسيط

1. **إنشاء دليل المشروع**
   ```bash
   mkdir ~/podman-demo
   cd ~/podman-demo
   ```

2. **إنشاء ملفات التطبيق**
   ```bash
   # إنشاء ملف HTML بسيط
   cat > index.html << 'EOF'
   <!DOCTYPE html>
   <html>
   <head>
       <title>عرض توضيحي Podman Desktop</title>
       <style>
           body { font-family: Arial, sans-serif; margin: 40px; direction: rtl; }
           .container { max-width: 800px; margin: 0 auto; }
           .header { color: #2196F3; text-align: center; }
       </style>
   </head>
   <body>
       <div class="container">
           <h1 class="header">مرحبًا بك في Podman Desktop!</h1>
           <p>هذا تطبيق عرض توضيحي يعمل في حاوية.</p>
           <p>تم إنشاؤه بـ ❤️ باستخدام Podman Desktop</p>
       </div>
   </body>
   </html>
   EOF
   
   # إنشاء Dockerfile
   cat > Dockerfile << 'EOF'
   FROM nginx:alpine
   COPY index.html /usr/share/nginx/html/
   EXPOSE 80
   CMD ["nginx", "-g", "daemon off;"]
   EOF
   ```

3. **البناء باستخدام Podman Desktop**
   - افتح Podman Desktop
   - انتقل إلى "Images" → "Build"
   - اختر دليل المشروع
   - تعيين اسم الصورة: `podman-demo:latest`
   - انقر على "Build"

4. **البديل: البناء عبر الطرفية**
   ```bash
   # بناء الصورة
   podman build -t podman-demo:latest .
   
   # تشغيل الحاوية
   podman run -d --name demo-app -p 8080:80 podman-demo:latest
   
   # اختبار التطبيق
   curl http://localhost:8080
   ```

### عمليات إدارة الحاوية

#### المراقبة وتصحيح الأخطاء

```bash
# إحصائيات الحاوية في الوقت الفعلي
podman stats

# استخدام موارد الحاوية
podman top my-container

# تنفيذ أوامر في الحاوية قيد التشغيل
podman exec -it my-container /bin/bash

# نسخ الملفات من/إلى الحاوية
podman cp local-file.txt my-container:/app/
podman cp my-container:/app/output.txt ./
```

#### إدارة دورة حياة الحاوية

```bash
# بدء حاوية متوقفة
podman start my-container

# إعادة تشغيل حاوية
podman restart my-container

# إيقاف/استئناف الحاوية مؤقتًا
podman pause my-container
podman unpause my-container

# قتل حاوية (إيقاف قسري)
podman kill my-container

# إزالة الحاويات والصور
podman rm $(podman ps -aq)  # إزالة جميع الحاويات المتوقفة
podman rmi $(podman images -q)  # إزالة جميع الصور
```

## العمل مع البودات

### فهم البودات في Podman

البودات في Podman مشابهة لبودات Kubernetes - فهي تجمع الحاويات ذات الصلة التي تشارك:
- مساحة اسم الشبكة
- أحجام التخزين
- إدارة دورة الحياة

### إنشاء وإدارة البودات

#### الطريقة 1: استخدام واجهة Podman Desktop الرسومية

1. **إنشاء بود جديد**
   - انتقل إلى قسم "Pods"
   - انقر على "Create Pod"
   - تكوين إعدادات البود:
     - الاسم: `web-app-pod`
     - تعيين المنافذ: `8080:80`
     - الأحجام المشتركة (إذا لزم الأمر)

2. **إضافة حاويات إلى البود**
   - اختر البود المُنشأ
   - انقر على "Add Container"
   - اختر الصورة وتكوين الإعدادات

#### الطريقة 2: استخدام أوامر الطرفية

```bash
# إنشاء بود مع تعيين المنفذ
podman pod create --name web-app-pod -p 8080:80

# إضافة حاويات إلى البود
podman run -dt --pod web-app-pod --name nginx-container nginx:latest
podman run -dt --pod web-app-pod --name redis-container redis:alpine

# سرد البودات وحاوياتها
podman pod ls
podman ps --pod

# إدارة دورة حياة البود
podman pod start web-app-pod
podman pod stop web-app-pod
podman pod rm web-app-pod
```

### مثال تطبيق متعدد الحاويات

```bash
# إنشاء بود WordPress + MySQL
podman pod create --name wordpress-pod -p 8080:80

# حاوية قاعدة بيانات MySQL
podman run -d --pod wordpress-pod \
  --name mysql-db \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wpuser \
  -e MYSQL_PASSWORD=wppass \
  mysql:5.7

# حاوية تطبيق WordPress
podman run -d --pod wordpress-pod \
  --name wordpress-app \
  -e WORDPRESS_DB_HOST=localhost \
  -e WORDPRESS_DB_USER=wpuser \
  -e WORDPRESS_DB_PASSWORD=wppass \
  -e WORDPRESS_DB_NAME=wordpress \
  wordpress:latest

# التحقق من التطبيق
echo "WordPress متاح على: http://localhost:8080"
```

## تكامل Kubernetes

### إعداد سياق Kubernetes

#### Kubernetes المحلي مع Kind

```bash
# تثبيت Kind (إذا لم يكن مثبتًا بالفعل)
brew install kind  # macOS
# أو التحميل من: https://kind.sigs.k8s.io/docs/user/quick-start/

# إنشاء مجموعة Kind
kind create cluster --name podman-demo

# التحقق من المجموعة
kubectl cluster-info --context kind-podman-demo
```

#### الاتصال بـ Kubernetes البعيد

1. **إضافة سياق Kubernetes في Podman Desktop**
   - انتقل إلى الإعدادات → Kubernetes
   - انقر على "Add Context"
   - استورد ملف kubeconfig أو أدخل تفاصيل المجموعة

2. **تكوين سياق kubectl**
   ```bash
   # سرد السياقات المتاحة
   kubectl config get-contexts
   
   # التبديل إلى السياق المطلوب
   kubectl config use-context your-cluster-context
   
   # التحقق من الاتصال
   kubectl get nodes
   ```

### نشر البودات إلى Kubernetes

#### الطريقة 1: استخدام Podman Desktop

1. **إنتاج YAML لـ Kubernetes**
   - اختر البود في Podman Desktop
   - انقر على "Deploy to Kubernetes"
   - اختر السياق المستهدف
   - راجع YAML المُولد
   - انقر على "Deploy"

2. **مراقبة النشر**
   - تحقق من قسم "Kubernetes"
   - عرض البودات والخدمات والنشر
   - مراقبة السجلات والأحداث

#### الطريقة 2: نشر Kubernetes يدوي

```bash
# إنتاج YAML لـ Kubernetes من البود
podman generate kube web-app-pod > web-app-pod.yaml

# مراجعة وتحرير ملف YAML
cat web-app-pod.yaml

# النشر إلى Kubernetes
kubectl apply -f web-app-pod.yaml

# فحص حالة النشر
kubectl get pods
kubectl get services

# إعادة توجيه المنفذ للوصول المحلي
kubectl port-forward pod/web-app-pod 8080:80
```

### مثال: نشر تطبيق كامل

```yaml
# احفظ كـ: k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: podman-demo-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: podman-demo
  template:
    metadata:
      labels:
        app: podman-demo
    spec:
      containers:
      - name: web-app
        image: podman-demo:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: podman-demo-service
spec:
  selector:
    app: podman-demo
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

```bash
# نشر التطبيق
kubectl apply -f k8s-deployment.yaml

# فحص النشر
kubectl get deployments
kubectl get services
kubectl get pods

# الحصول على URL الخدمة (لمقدمي الخدمات السحابية)
kubectl get service podman-demo-service
```

## الميزات المتقدمة

### إدارة السجل

#### تكوين السجلات الخاصة

1. **إضافة سجل في واجهة المستخدم الرسومية**
   - انتقل إلى الإعدادات → السجلات
   - انقر على "Add Registry"
   - أدخل تفاصيل السجل:
     - URL: `your-registry.com`
     - اسم المستخدم وكلمة المرور
     - إعدادات الشهادة (إذا لزم الأمر)

2. **تكوين سطر الأوامر**
   ```bash
   # إضافة مصادقة السجل
   podman login your-registry.com
   
   # تكوين السجل في containers.conf
   cat >> ~/.config/containers/registries.conf << 'EOF'
   [[registry]]
   location = "your-registry.com"
   insecure = false
   blocked = false
   EOF
   ```

#### العمل مع الصور الخاصة

```bash
# وضع علامة على الصورة للسجل الخاص
podman tag local-image:latest your-registry.com/namespace/image:v1.0

# الدفع إلى السجل الخاص
podman push your-registry.com/namespace/image:v1.0

# السحب من السجل الخاص
podman pull your-registry.com/namespace/image:v1.0
```

### إدارة الأحجام

#### إنشاء وإدارة الأحجام

```bash
# إنشاء أحجام مسماة
podman volume create app-data
podman volume create app-logs

# سرد الأحجام
podman volume ls

# فحص تفاصيل الحجم
podman volume inspect app-data

# استخدام الأحجام في الحاويات
podman run -d \
  --name data-container \
  -v app-data:/app/data \
  -v app-logs:/var/log \
  nginx:latest

# نسخ احتياطي لبيانات الحجم
podman run --rm \
  -v app-data:/source \
  -v $(pwd):/backup \
  alpine tar czf /backup/app-data-backup.tar.gz -C /source .

# استعادة بيانات الحجم
podman run --rm \
  -v app-data:/target \
  -v $(pwd):/backup \
  alpine tar xzf /backup/app-data-backup.tar.gz -C /target
```

### تكوين الشبكة

#### الشبكات المخصصة

```bash
# إنشاء شبكة مخصصة
podman network create --driver bridge app-network

# سرد الشبكات
podman network ls

# تشغيل الحاويات على الشبكة المخصصة
podman run -d --network app-network --name web nginx:latest
podman run -d --network app-network --name db mysql:5.7

# فحص الشبكة
podman network inspect app-network

# ربط الحاوية قيد التشغيل بالشبكة
podman network connect app-network existing-container
```

### التوسعات والمكونات الإضافية

#### تثبيت التوسعات

1. **استخدام واجهة Podman Desktop الرسومية**
   - انتقل إلى الإعدادات → التوسعات
   - تصفح التوسعات المتاحة
   - انقر على "Install" على التوسعات المطلوبة

2. **التوسعات الشائعة**
   - **Kind Extension**: مجموعات Kubernetes المحلية
   - **Compose Extension**: دعم Docker Compose
   - **Lima Extension**: أجهزة Linux الافتراضية على macOS
   - **Red Hat OpenShift**: Kubernetes للمؤسسات

3. **إدارة التوسعات**
   ```bash
   # سرد التوسعات المثبتة
   podman-desktop --list-extensions
   
   # تمكين/تعطيل التوسعات عبر واجهة المستخدم الرسومية
   # الإعدادات → التوسعات → مفاتيح التبديل
   ```

## نصوص الاختبار والتحقق

### التحقق من الإعداد التلقائي

إنشاء نص شامل لاختبار تثبيت Podman Desktop:

```bash
#!/bin/bash
# احفظ كـ: test-podman-desktop.sh

set -e

echo "🧪 مجموعة اختبار تثبيت Podman Desktop"
echo "=================================="

# رموز الألوان للإخراج
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # بدون لون

# دالة الاختبار
test_command() {
    local cmd="$1"
    local desc="$2"
    
    echo -e "\n${BLUE}اختبار: $desc${NC}"
    echo "الأمر: $cmd"
    
    if eval "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ نجح${NC}"
        return 0
    else
        echo -e "${RED}❌ فشل${NC}"
        return 1
    fi
}

# عداد نتائج الاختبار
TOTAL_TESTS=0
PASSED_TESTS=0

run_test() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if test_command "$1" "$2"; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
    fi
}

echo -e "\n${BLUE}1. اختبارات التثبيت الأساسية${NC}"
echo "------------------------"

run_test "which podman" "تم تثبيت ملف Podman التنفيذي"
run_test "podman --version" "فحص إصدار Podman"
run_test "podman info" "معلومات نظام Podman"

echo -e "\n${BLUE}2. اختبارات محرك الحاوية${NC}"
echo "----------------------"

run_test "podman machine list" "حالة آلة Podman"
run_test "podman images" "سرد صور الحاوية"
run_test "podman ps -a" "سرد الحاويات"

echo -e "\n${BLUE}3. عمليات الحاوية الأساسية${NC}"
echo "------------------------"

# سحب صورة اختبار صغيرة
echo "سحب صورة hello-world..."
if podman pull hello-world:latest >/dev/null 2>&1; then
    run_test "podman images | grep hello-world" "نجح سحب الصورة"
    
    # تشغيل حاوية اختبار
    echo "تشغيل حاوية اختبار..."
    if podman run --rm hello-world >/dev/null 2>&1; then
        run_test "echo 'نجح تشغيل الحاوية'" "تنفيذ الحاوية"
    else
        run_test "false" "تنفيذ الحاوية"
    fi
    
    # التنظيف
    podman rmi hello-world:latest >/dev/null 2>&1
else
    run_test "false" "سحب الصورة"
    run_test "false" "تنفيذ الحاوية"
fi

echo -e "\n${BLUE}4. اختبارات عمليات البود${NC}"
echo "---------------------"

# اختبار إنشاء البود
POD_NAME="test-pod-$$"
if podman pod create --name "$POD_NAME" >/dev/null 2>&1; then
    run_test "podman pod list | grep $POD_NAME" "إنشاء البود"
    
    # التنظيف
    podman pod rm -f "$POD_NAME" >/dev/null 2>&1
else
    run_test "false" "إنشاء البود"
fi

echo -e "\n${BLUE}5. اختبارات الشبكة${NC}"
echo "----------------"

run_test "podman network ls" "سرد الشبكة"

# اختبار الشبكة المخصصة
NETWORK_NAME="test-network-$$"
if podman network create "$NETWORK_NAME" >/dev/null 2>&1; then
    run_test "podman network ls | grep $NETWORK_NAME" "إنشاء شبكة مخصصة"
    
    # التنظيف
    podman network rm "$NETWORK_NAME" >/dev/null 2>&1
else
    run_test "false" "إنشاء شبكة مخصصة"
fi

echo -e "\n${BLUE}6. اختبارات الأحجام${NC}"
echo "-----------------"

run_test "podman volume ls" "سرد الأحجام"

# اختبار إنشاء الحجم
VOLUME_NAME="test-volume-$$"
if podman volume create "$VOLUME_NAME" >/dev/null 2>&1; then
    run_test "podman volume ls | grep $VOLUME_NAME" "إنشاء الحجم"
    
    # التنظيف
    podman volume rm "$VOLUME_NAME" >/dev/null 2>&1
else
    run_test "false" "إنشاء الحجم"
fi

echo -e "\n${BLUE}7. اختبارات تكامل Kubernetes${NC}"
echo "----------------------------"

run_test "which kubectl" "تم تثبيت kubectl"
if command -v kubectl >/dev/null 2>&1; then
    run_test "kubectl version --client" "فحص إصدار kubectl"
    run_test "podman generate kube --help" "إنتاج YAML لـ Kubernetes"
fi

echo -e "\n${BLUE}ملخص الاختبار${NC}"
echo "============="
echo -e "إجمالي الاختبارات: $TOTAL_TESTS"
echo -e "نجح: ${GREEN}$PASSED_TESTS${NC}"
echo -e "فشل: ${RED}$((TOTAL_TESTS - PASSED_TESTS))${NC}"

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo -e "\n${GREEN}🎉 نجحت جميع الاختبارات! تثبيت Podman Desktop يعمل بشكل صحيح.${NC}"
    exit 0
else
    echo -e "\n${RED}⚠️  فشلت بعض الاختبارات. يرجى فحص التثبيت.${NC}"
    exit 1
fi
```

اجعل النص قابلاً للتنفيذ وشغله:

```bash
chmod +x test-podman-desktop.sh
./test-podman-desktop.sh
```

### نص مقياس الأداء

```bash
#!/bin/bash
# احفظ كـ: benchmark-podman.sh

echo "🚀 مقياس أداء Podman"
echo "=================="

# دالة قياس الوقت
measure_time() {
    local cmd="$1"
    local desc="$2"
    
    echo -e "\n📊 قياس: $desc"
    echo "الأمر: $cmd"
    
    start_time=$(date +%s.%N)
    eval "$cmd" >/dev/null 2>&1
    end_time=$(date +%s.%N)
    
    duration=$(echo "$end_time - $start_time" | bc)
    echo "⏱️  الوقت: ${duration}ث"
}

# مقياس سحب الصورة
measure_time "podman pull alpine:latest" "سحب صورة Alpine"

# مقياس دورة حياة الحاوية
measure_time "podman run --rm alpine:latest echo 'Hello World'" "تشغيل الحاوية (بسيط)"

# مقياس البناء
cat > /tmp/Dockerfile << 'EOF'
FROM alpine:latest
RUN apk add --no-cache curl
EOF

measure_time "podman build -t benchmark-test /tmp -f /tmp/Dockerfile" "بناء الصورة"

# التنظيف
podman rmi benchmark-test alpine:latest >/dev/null 2>&1
rm /tmp/Dockerfile

echo -e "\n✅ اكتمل المقياس!"
```

## استكشاف الأخطاء وإصلاحها

### مشاكل التثبيت

#### macOS: خطأ "لا يمكن فتح التطبيق"

```bash
# إزالة خاصية الحجر الصحي
sudo xattr -rd com.apple.quarantine "/Applications/Podman Desktop.app"

# البديل: التمكين في تفضيلات النظام
echo "انتقل إلى تفضيلات النظام → الأمان والخصوصية → عام"
echo "انقر على 'افتح على أي حال' بجانب Podman Desktop"
```

#### Windows: فشل التثبيت

```powershell
# تشغيل كمدير
# فحص توافق إصدار Windows
Get-ComputerInfo | Select WindowsProductName, WindowsVersion

# تعطيل مكافح الفيروسات مؤقتًا أثناء التثبيت
# إضافة Podman Desktop إلى استثناءات مكافح الفيروسات
```

#### Linux: رفض الإذن

```bash
# إضافة المستخدم إلى مجموعة docker (إذا كنت تستخدم توافق Docker)
sudo usermod -aG docker $USER

# إصلاح أذونات مقبس Podman
sudo chmod 666 /run/user/$(id -u)/podman/podman.sock

# إعادة تشغيل الجلسة
newgrp docker
```

### مشاكل وقت التشغيل

#### الحاوية لا تبدأ

```bash
# فحص حالة الحاوية والسجلات
podman ps -a
podman logs container-name

# فحص موارد النظام
podman system df
df -h

# إعادة تشغيل آلة Podman (macOS/Windows)
podman machine stop
podman machine start
```

#### مشاكل اتصال الشبكة

```bash
# إعادة تعيين تكوين الشبكة
podman system reset --force

# فحص إعدادات جدار الحماية
sudo ufw status  # Ubuntu
sudo firewall-cmd --list-all  # CentOS/RHEL

# اختبار اتصال الشبكة
podman run --rm alpine:latest ping -c 3 google.com
```

#### مشاكل الأداء

```bash
# فحص استخدام الموارد
podman stats
podman system df

# تنظيف الموارد غير المستخدمة
podman system prune -af
podman volume prune -f

# إعادة تشغيل Docker Desktop (إذا كنت تستخدم Docker)
# macOS: killall Docker && open /Applications/Docker.app
```

### مشاكل تكامل Kubernetes

#### السياق غير متاح

```bash
# فحص تكوين kubectl
kubectl config view
kubectl config get-contexts

# التحقق من اتصال المجموعة
kubectl cluster-info
kubectl get nodes

# إعادة استيراد kubeconfig
cp ~/.kube/config ~/.kube/config.backup
# إعادة تحميل التكوين من مقدم المجموعة
```

#### فشل نشر البود

```bash
# فحص أحداث Kubernetes
kubectl get events --sort-by='.lastTimestamp'

# التحقق من YAML للبود
kubectl apply --dry-run=client -f pod.yaml

# فحص حصص الموارد
kubectl describe quota
kubectl top nodes
```

## أفضل الممارسات والنصائح

### أفضل ممارسات الأمان

1. **أمان الصور**
   ```bash
   # استخدم الصور الرسمية عندما يكون ذلك ممكنًا
   podman pull nginx:alpine  # فضل متغيرات alpine
   
   # فحص الصور للثغرات الأمنية
   podman scan your-image:latest
   
   # استخدم علامات محددة، تجنب 'latest'
   podman pull nginx:1.21-alpine
   ```

2. **أمان الحاوية**
   ```bash
   # تشغيل الحاويات بمستخدم غير جذر
   podman run --user 1000:1000 nginx:alpine
   
   # استخدم نظم ملفات للقراءة فقط
   podman run --read-only nginx:alpine
   
   # حدد الموارد
   podman run --memory=512m --cpus=1 nginx:alpine
   ```

3. **أمان الشبكة**
   ```bash
   # استخدم الشبكات المخصصة بدلاً من الافتراضية
   podman network create secure-network
   podman run --network secure-network nginx:alpine
   
   # تجنب شبكات المضيف ما لم تكن ضرورية
   # podman run --network=host  # تجنب هذا
   ```

### تحسين الأداء

1. **إدارة الموارد**
   ```bash
   # تعيين حدود موارد مناسبة
   podman run -m 512m --cpus="1.5" nginx:alpine
   
   # استخدم تركيبات الأحجام للبيانات المستمرة
   podman run -v data-volume:/app/data nginx:alpine
   
   # تمكين تخزين الحاوية مؤقتًا
   # استخدم بناءات متعددة المراحل لتقليل حجم الصورة
   ```

2. **تحسين الصورة**
   ```dockerfile
   # استخدم بناءات متعددة المراحل
   FROM node:alpine AS builder
   WORKDIR /app
   COPY package*.json ./
   RUN npm ci --only=production
   
   FROM node:alpine
   WORKDIR /app
   COPY --from=builder /app/node_modules ./node_modules
   COPY . .
   CMD ["npm", "start"]
   ```

3. **تحسين التخزين**
   ```bash
   # تنظيف منتظم
   podman system prune -af
   podman volume prune -f
   
   # استخدم .dockerignore/.containerignore
   echo "node_modules" > .containerignore
   echo "*.log" >> .containerignore
   ```

### سير عمل التطوير

1. **تكامل التحكم في الإصدار**
   ```bash
   # تضمين تكوينات الحاوية في git
   git add Dockerfile docker-compose.yml
   git add .containerignore
   
   # استخدم CI/CD القائم على الحاوية
   # تضمين أوامر podman في GitHub Actions
   ```

2. **إدارة البيئة**
   ```bash
   # استخدم تكوينات خاصة بالبيئة
   podman run --env-file .env.development app:latest
   podman run --env-file .env.production app:latest
   
   # استخدم إدارة الأسرار
   echo "password123" | podman secret create db-password -
   podman run --secret db-password app:latest
   ```

3. **التعاون الجماعي**
   ```bash
   # مشاركة حاويات التطوير
   podman save app:latest | gzip > app-latest.tar.gz
   
   # استخدم صور أساسية موحدة
   # إنشاء صور أساسية خاصة بالمؤسسة
   ```

## الخلاصة

يمثل Podman Desktop مستقبل أدوات تطوير الحاويات، حيث يوفر توازنًا مثاليًا بين الوظائف القوية والتصميم الصديق للمستخدم. مع مجموعة ميزاته الشاملة ودعم متعدد المنصات وتكامل Kubernetes السلس، فهو أداة أساسية للمطورين الحديثين.

### النقاط الرئيسية

- **تثبيت سهل**: طرق تثبيت متعددة لجميع المنصات
- **واجهة بديهية**: إدارة مرئية للحاويات دون التضحية بالقوة
- **دعم محركات متعددة**: يعمل مع Podman و Docker ومحركات الحاويات الأخرى
- **جاهز لـ Kubernetes**: انتقال سلس من التطوير المحلي إلى الإنتاج
- **ميزات المؤسسة**: الأمان والشبكات وإدارة السجل
- **قابل للتوسيع**: نظام بيئي غني من التوسعات والمكونات الإضافية

### الخطوات التالية

1. **استكشاف الميزات المتقدمة**: تعمق أكثر في تكامل Kubernetes والتوسعات
2. **انضم إلى المجتمع**: ساهم في المشروع أو شارك في المناقشات
3. **نشر الإنتاج**: خطط لانتقالك من Docker إلى Podman في الإنتاج
4. **الأتمتة**: دمج سير عمل Podman Desktop في خطوط أنابيب CI/CD

### مصادر إضافية

- **الوثائق الرسمية**: [podman-desktop.io/docs](https://podman-desktop.io/docs)
- **مستودع GitHub**: [github.com/podman-desktop/podman-desktop](https://github.com/podman-desktop/podman-desktop)
- **مناقشات المجتمع**: [GitHub Discussions](https://github.com/podman-desktop/podman-desktop/discussions)
- **وثائق Podman**: [docs.podman.io](https://docs.podman.io)
- **وثائق Kubernetes**: [kubernetes.io/docs](https://kubernetes.io/docs)

ابدأ رحلة تطوير الحاويات مع Podman Desktop اليوم واختبر الفرق الذي يمكن أن يحدثه التصميم المدروس والوظائف القوية في سير عمل التطوير الخاص بك!

---

*حاويات سعيدة! 🐳*
