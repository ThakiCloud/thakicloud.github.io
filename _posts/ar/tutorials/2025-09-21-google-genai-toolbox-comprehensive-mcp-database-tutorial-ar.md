---
title: "Google GenAI Toolbox: الدليل الشامل لتكامل قواعد البيانات مع MCP"
excerpt: "إتقان Google GenAI Toolbox لعمليات قواعد البيانات السلسة مع دعم بروتوكول MCP. تعلم الإعداد والتكوين والتكامل مع أطر عمل مختلفة بما في ذلك Genkit وLangChain وOpenAI."
seo_title: "دليل Google GenAI Toolbox MCP لقواعد البيانات - دليل التكامل الشامل"
seo_description: "دليل شامل حول Google GenAI Toolbox لتكامل خادم MCP مع قواعد البيانات. تعلم الإعداد والتكوين وتكامل الإطار مع أمثلة عملية."
date: 2025-09-21
categories:
  - tutorials
tags:
  - GenAI-Toolbox
  - MCP
  - قواعد-البيانات
  - Google
  - تكامل-الذكاء-الاصطناعي
  - Genkit
  - LangChain
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/google-genai-toolbox-comprehensive-mcp-database-tutorial/
canonical_url: "https://thakicloud.github.io/ar/tutorials/google-genai-toolbox-comprehensive-mcp-database-tutorial/"
---

⏱️ **وقت القراءة المتوقع**: 12 دقيقة

يمثل Google GenAI Toolbox نهجاً رائداً لتكامل قواعد البيانات في تطبيقات الذكاء الاصطناعي من خلال بروتوكول السياق النموذجي (MCP). سيرشدك هذا الدليل الشامل خلال إعداد وتكوين واستغلال GenAI Toolbox لعمليات قواعد البيانات السلسة عبر أطر عمل الذكاء الاصطناعي المتعددة.

## ما هو Google GenAI Toolbox؟

[Google GenAI Toolbox](https://github.com/googleapis/genai-toolbox) هو خادم MCP مفتوح المصدر مصمم خصيصاً لعمليات قواعد البيانات. يوفر واجهة موحدة لوكلاء الذكاء الاصطناعي للتفاعل مع أنظمة قواعد البيانات المختلفة، ويقدم أدوات للاستعلام وفحص المخطط ومعالجة البيانات من خلال بروتوكول موحد.

### الميزات الرئيسية

- **دعم قواعد البيانات المتعددة**: PostgreSQL، MySQL، SQLite وغيرها
- **امتثال بروتوكول MCP**: تكامل سلس مع تطبيقات الذكاء الاصطناعي
- **مستقل عن الإطار**: يعمل مع Genkit وLangChain وOpenAI والتطبيقات المخصصة
- **الأمان أولاً**: مراقبة المصادقة والأذونات المدمجة
- **جاهز للإنتاج**: بنية قابلة للتوسع مع دعم Docker

## التثبيت والإعداد

### المتطلبات المسبقة

قبل البدء، تأكد من تثبيت ما يلي:

```bash
# فحص إصدار Go (مطلوب 1.21+)
go version

# فحص Docker (اختياري لكن مُوصى به)
docker --version

# التحقق من الوصول إلى قاعدة البيانات (مثال PostgreSQL)
psql --version
```

### تثبيت GenAI Toolbox

#### الطريقة الأولى: التثبيت المباشر

```bash
# استنساخ المستودع
git clone https://github.com/googleapis/genai-toolbox.git
cd genai-toolbox

# بناء صندوق الأدوات
go build -o toolbox ./cmd/toolbox

# جعله قابلاً للتنفيذ
chmod +x toolbox

# نقل إلى مسار النظام (اختياري)
sudo mv toolbox /usr/local/bin/
```

#### الطريقة الثانية: تثبيت Docker

```bash
# سحب صورة Docker الرسمية
docker pull googleapis/genai-toolbox:latest

# إنشاء شبكة Docker للتواصل مع قاعدة البيانات
docker network create genai-network
```

## التكوين

### ملف التكوين الأساسي

إنشاء ملف `tools.yaml` لتعريف مصادر قاعدة البيانات والأدوات المتاحة:

```yaml
# tools.yaml
sources:
  # تكوين قاعدة بيانات PostgreSQL
  my-postgres-db:
    kind: postgres
    host: localhost
    port: 5432
    database: ecommerce_db
    user: toolbox_user
    password: secure_password
    
  # تكوين قاعدة بيانات MySQL  
  my-mysql-db:
    kind: mysql
    host: localhost
    port: 3306
    database: analytics_db
    user: mysql_user
    password: mysql_password

tools:
  # البحث في المنتجات بالاسم
  search-products:
    kind: postgres-sql
    source: my-postgres-db
    description: "البحث عن المنتجات بناءً على الاسم أو الوصف"
    parameters:
      - name: search_term
        type: string
        description: "اسم المنتج أو الوصف للبحث عنه"
    statement: |
      SELECT product_id, name, description, price, stock_quantity 
      FROM products 
      WHERE name ILIKE '%' || $1 || '%' 
         OR description ILIKE '%' || $1 || '%'
      LIMIT 20;

  # الحصول على تحليلات العملاء
  customer-analytics:
    kind: mysql-sql
    source: my-mysql-db
    description: "استرداد بيانات تحليلات العملاء"
    parameters:
      - name: customer_id
        type: integer
        description: "معرف العميل الفريد"
      - name: date_range
        type: string
        description: "نطاق التاريخ بصيغة YYYY-MM-DD (اختياري)"
        required: false
    statement: |
      SELECT 
        customer_id,
        total_orders,
        total_spent,
        avg_order_value,
        last_order_date
      FROM customer_summary 
      WHERE customer_id = ?
      {% raw %}{{#if date_range}}{% endraw %}
        AND last_order_date >= ?
      {% raw %}{{/if}}{% endraw %};

  # فحص المخطط الديناميكي
  inspect-table:
    kind: postgres-sql
    source: my-postgres-db
    description: "الحصول على معلومات مخطط الجدول التفصيلية"
    parameters:
      - name: table_name
        type: string
        description: "اسم الجدول للفحص"
    statement: |
      SELECT 
        column_name,
        data_type,
        is_nullable,
        column_default,
        character_maximum_length
      FROM information_schema.columns 
      WHERE table_name = $1 
        AND table_schema = 'public'
      ORDER BY ordinal_position;

toolsets:
  ecommerce_tools:
    - search-products
    - inspect-table
  analytics_tools:
    - customer-analytics
    - inspect-table
  admin_tools:
    - search-products
    - customer-analytics
    - inspect-table
```

### تكوين الأمان المتقدم

تنفيذ تدابير أمنية محسنة لبيئات الإنتاج:

```yaml
# secure-tools.yaml
sources:
  secure-postgres:
    kind: postgres
    host: localhost
    port: 5432
    database: production_db
    user: ${POSTGRES_USER}
    password: ${POSTGRES_PASSWORD}
    ssl_mode: require
    connection_timeout: 30
    max_connections: 10
    
security:
  authentication:
    enabled: true
    method: "api_key"
    api_key: ${TOOLBOX_API_KEY}
  
  rate_limiting:
    enabled: true
    requests_per_minute: 100
    
  audit_logging:
    enabled: true
    log_level: "info"
    log_file: "/var/log/genai-toolbox.log"
```

## أمثلة تكامل الإطار

### تكامل Genkit

يوفر GenAI Toolbox دعم Genkit الأصلي من خلال حزمة `tbgenkit`:

```go
package main

import (
    "context"
    "log"
    
    "github.com/firebase/genkit/go/ai"
    "github.com/firebase/genkit/go/genkit"
    "github.com/googleapis/mcp-toolbox-sdk-go/core"
    "github.com/googleapis/mcp-toolbox-sdk-go/tbgenkit"
)

func main() {
    ctx := context.Background()
    
    // تهيئة Genkit
    g, err := genkit.Init(ctx)
    if err != nil {
        log.Fatalf("فشل في تهيئة Genkit: %v", err)
    }
    
    // الاتصال بخادم GenAI Toolbox
    client, err := core.NewToolboxClient("http://localhost:5000")
    if err != nil {
        log.Fatalf("فشل في الاتصال بصندوق الأدوات: %v", err)
    }
    
    // تحميل الأدوات المتاحة
    tools, err := client.LoadToolset(ctx, "ecommerce_tools")
    if err != nil {
        log.Fatalf("فشل في تحميل الأدوات: %v", err)
    }
    
    // تحويل الأدوات لـ Genkit
    var genkitTools []*ai.Tool
    for _, tool := range tools {
        genkitTool, err := tbgenkit.ToGenkitTool(tool, g)
        if err != nil {
            log.Printf("فشل في تحويل الأداة %s: %v", tool.Name(), err)
            continue
        }
        genkitTools = append(genkitTools, genkitTool)
    }
    
    // إنشاء تدفق Genkit مع أدوات قاعدة البيانات
    searchFlow := genkit.DefineFlow(
        "product-search-flow",
        func(ctx context.Context, query string) (string, error) {
            // استخدام أداة search-products
            result, err := client.ExecuteTool(ctx, "search-products", map[string]interface{}{
                "search_term": query,
            })
            if err != nil {
                return "", err
            }
            
            return formatSearchResults(result), nil
        },
    )
    
    log.Println("تم تسجيل تدفق Genkit مع أدوات قاعدة البيانات")
}

func formatSearchResults(result interface{}) string {
    // تنسيق نتائج قاعدة البيانات للعرض
    return "نتائج البحث المنسقة..."
}
```

### تكامل LangChain

التكامل مع LangChain Go لتطبيقات ذكاء اصطناعي شاملة:

```go
package main

import (
    "context"
    "encoding/json"
    "log"
    
    "github.com/tmc/langchaingo/llms"
    "github.com/tmc/langchaingo/llms/openai"
    "github.com/googleapis/mcp-toolbox-sdk-go/core"
)

func setupLangChainWithToolbox() error {
    ctx := context.Background()
    
    // تهيئة عميل صندوق الأدوات
    client, err := core.NewToolboxClient("http://localhost:5000")
    if err != nil {
        return err
    }
    
    // تحميل الأدوات
    tool, err := client.LoadTool("search-products", ctx)
    if err != nil {
        return err
    }
    
    // الحصول على مخطط الأداة
    inputSchema, err := tool.InputSchema()
    if err != nil {
        return err
    }
    
    var paramsSchema map[string]any
    if err := json.Unmarshal(inputSchema, &paramsSchema); err != nil {
        return err
    }
    
    // إنشاء أداة LangChain
    langChainTool := llms.Tool{
        Type: "function",
        Function: &llms.FunctionDefinition{
            Name:        tool.Name(),
            Description: tool.Description(),
            Parameters:  paramsSchema,
        },
    }
    
    // تهيئة عميل OpenAI مع الأدوات
    llm, err := openai.New(
        openai.WithModel("gpt-4"),
        openai.WithToken("your-openai-api-key"),
    )
    if err != nil {
        return err
    }
    
    // استخدام الأداة في إكمال المحادثة
    response, err := llm.GenerateContent(ctx, []llms.MessageContent{
        llms.TextParts(llms.ChatMessageTypeHuman, "ابحث عن المنتجات التي تحتوي على 'لابتوب'"),
    }, llms.WithTools([]llms.Tool{langChainTool}))
    
    if err != nil {
        return err
    }
    
    log.Printf("استجابة LangChain: %s", response.Choices[0].Content)
    return nil
}
```

### تكامل OpenAI المباشر

للتكامل المباشر مع OpenAI API:

```go
package main

import (
    "context"
    "encoding/json"
    "log"
    
    "github.com/googleapis/mcp-toolbox-sdk-go/core"
    openai "github.com/openai/openai-go"
)

func integrateWithOpenAI() error {
    ctx := context.Background()
    
    // إعداد عميل صندوق الأدوات
    client, err := core.NewToolboxClient("http://localhost:5000")
    if err != nil {
        return err
    }
    
    // تحميل أداة التحليلات
    tool, err := client.LoadTool("customer-analytics", ctx)
    if err != nil {
        return err
    }
    
    // تحضير تعريف أداة OpenAI
    inputSchema, err := tool.InputSchema()
    if err != nil {
        return err
    }
    
    var paramsSchema openai.FunctionParameters
    if err := json.Unmarshal(inputSchema, &paramsSchema); err != nil {
        return err
    }
    
    openAITool := openai.ChatCompletionToolParam{
        Function: openai.FunctionDefinitionParam{
            Name:        tool.Name(),
            Description: openai.String(tool.Description()),
            Parameters:  paramsSchema,
        },
    }
    
    // تهيئة عميل OpenAI
    openaiClient := openai.NewClient()
    
    // إنشاء إكمال محادثة مع الأدوات
    completion, err := openaiClient.Chat.Completions.New(ctx, openai.ChatCompletionNewParams{
        Messages: openai.F([]openai.ChatCompletionMessageParamUnion{
            openai.UserMessage("احصل على تحليلات العميل رقم 12345"),
        }),
        Model: openai.F(openai.ChatModelGPT4),
        Tools: openai.F([]openai.ChatCompletionToolParam{openAITool}),
    })
    
    if err != nil {
        return err
    }
    
    log.Printf("استجابة OpenAI: %+v", completion)
    return nil
}
```

## عمليات قاعدة البيانات المتقدمة

### أمثلة الاستعلامات المعقدة

إنشاء عمليات قاعدة بيانات متطورة للسيناريوهات الحقيقية:

```yaml
tools:
  # تحليلات مبيعات التجارة الإلكترونية
  sales-analytics:
    kind: postgres-sql
    source: my-postgres-db
    description: "إنتاج تقرير تحليلات مبيعات شامل"
    parameters:
      - name: start_date
        type: string
        description: "تاريخ البداية بصيغة YYYY-MM-DD"
      - name: end_date
        type: string
        description: "تاريخ النهاية بصيغة YYYY-MM-DD"
      - name: category
        type: string
        description: "مرشح فئة المنتج (اختياري)"
        required: false
    statement: |
      WITH daily_sales AS (
        SELECT 
          DATE(o.created_at) as sale_date,
          p.category,
          SUM(oi.quantity * oi.unit_price) as daily_revenue,
          COUNT(DISTINCT o.order_id) as order_count,
          COUNT(oi.product_id) as items_sold
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        JOIN products p ON oi.product_id = p.product_id
        WHERE o.created_at BETWEEN $1 AND $2
        {% raw %}{{#if category}}{% endraw %}
          AND p.category = $3
        {% raw %}{{/if}}{% endraw %}
        GROUP BY DATE(o.created_at), p.category
      )
      SELECT 
        sale_date,
        category,
        daily_revenue,
        order_count,
        items_sold,
        ROUND(daily_revenue / NULLIF(order_count, 0), 2) as avg_order_value
      FROM daily_sales
      ORDER BY sale_date DESC, daily_revenue DESC;

  # تقسيم العملاء
  customer-segmentation:
    kind: postgres-sql
    source: my-postgres-db
    description: "تقسيم العملاء بناءً على سلوك الشراء"
    parameters:
      - name: months_lookback
        type: integer
        description: "عدد الشهور للتحليل (افتراضي: 6)"
        required: false
    statement: |
      WITH customer_metrics AS (
        SELECT 
          c.customer_id,
          c.email,
          COUNT(o.order_id) as total_orders,
          SUM(o.total_amount) as total_spent,
          AVG(o.total_amount) as avg_order_value,
          MAX(o.created_at) as last_order_date,
          EXTRACT(DAYS FROM NOW() - MAX(o.created_at)) as days_since_last_order
        FROM customers c
        LEFT JOIN orders o ON c.customer_id = o.customer_id
        WHERE o.created_at >= NOW() - INTERVAL '{% raw %}{{months_lookback | default: 6}}{% endraw %} months'
        GROUP BY c.customer_id, c.email
      )
      SELECT 
        customer_id,
        email,
        total_orders,
        ROUND(total_spent, 2) as total_spent,
        ROUND(avg_order_value, 2) as avg_order_value,
        last_order_date,
        days_since_last_order,
        CASE 
          WHEN total_orders >= 10 AND total_spent >= 1000 THEN 'VIP'
          WHEN total_orders >= 5 AND total_spent >= 500 THEN 'منتظم'
          WHEN total_orders >= 2 THEN 'أحياناً'
          ELSE 'جديد'
        END as customer_segment,
        CASE 
          WHEN days_since_last_order <= 30 THEN 'نشط'
          WHEN days_since_last_order <= 90 THEN 'معرض للخطر'
          ELSE 'مفقود'
        END as activity_status
      FROM customer_metrics
      ORDER BY total_spent DESC;
```

### ربط قواعد البيانات المتعددة

للعمليات المعقدة عبر قواعد بيانات متعددة:

```yaml
tools:
  # تحليلات عبر قواعد البيانات
  unified-analytics:
    kind: custom
    description: "دمج البيانات من مصادر قواعد بيانات متعددة"
    parameters:
      - name: metric_type
        type: string
        description: "نوع المقياس لحسابه"
        enum: ["revenue", "customers", "products"]
    implementation: |
      async function unifiedAnalytics(params) {
        const pgClient = await getPostgresClient();
        const mysqlClient = await getMySQLClient();
        
        let result = {};
        
        switch(params.metric_type) {
          case 'revenue':
            const revenueData = await pgClient.query(`
              SELECT SUM(total_amount) as total_revenue 
              FROM orders 
              WHERE created_at >= NOW() - INTERVAL '30 days'
            `);
            
            const conversionData = await mysqlClient.query(`
              SELECT conversion_rate 
              FROM marketing_metrics 
              WHERE date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
            `);
            
            result = {
              total_revenue: revenueData.rows[0].total_revenue,
              avg_conversion_rate: conversionData[0].conversion_rate,
              revenue_per_visitor: revenueData.rows[0].total_revenue * conversionData[0].conversion_rate
            };
            break;
            
          // حالات إضافية...
        }
        
        return result;
      }
```

## النشر للإنتاج

### نشر Docker

إنشاء إعداد Docker جاهز للإنتاج:

```dockerfile
# Dockerfile
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o toolbox ./cmd/toolbox

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/

COPY --from=builder /app/toolbox .
COPY tools.yaml .

EXPOSE 5000
CMD ["./toolbox", "--tools-file", "tools.yaml", "--port", "5000"]
```

### إعداد Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  genai-toolbox:
    build: .
    ports:
      - "5000:5000"
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - TOOLBOX_API_KEY=${TOOLBOX_API_KEY}
    volumes:
      - ./tools.yaml:/root/tools.yaml
      - ./logs:/var/log
    depends_on:
      - postgres
      - redis
    networks:
      - genai-network

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=toolbox_db
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - genai-network

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    networks:
      - genai-network

volumes:
  postgres_data:
  redis_data:

networks:
  genai-network:
    driver: bridge
```

### نشر Kubernetes

للنشر على نطاق المؤسسة:

```yaml
# k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: genai-toolbox
  labels:
    app: genai-toolbox
spec:
  replicas: 3
  selector:
    matchLabels:
      app: genai-toolbox
  template:
    metadata:
      labels:
        app: genai-toolbox
    spec:
      containers:
      - name: toolbox
        image: your-registry/genai-toolbox:latest
        ports:
        - containerPort: 5000
        env:
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 5000
          initialDelaySeconds: 5
          periodSeconds: 5

---
apiVersion: v1
kind: Service
metadata:
  name: genai-toolbox-service
spec:
  selector:
    app: genai-toolbox
  ports:
  - protocol: TCP
    port: 80
    targetPort: 5000
  type: ClusterIP
```

## تحسين الأداء

### تجميع الاتصالات

تحسين اتصالات قاعدة البيانات للسيناريوهات عالية الإنتاجية:

```yaml
sources:
  optimized-postgres:
    kind: postgres
    host: localhost
    port: 5432
    database: production_db
    user: ${POSTGRES_USER}
    password: ${POSTGRES_PASSWORD}
    
    # إعدادات تجمع الاتصال
    max_open_connections: 25
    max_idle_connections: 5
    connection_max_lifetime: "5m"
    connection_max_idle_time: "30s"
    
    # تحسين الاستعلام
    default_query_timeout: "30s"
    slow_query_log: true
    slow_query_threshold: "1s"
```

### استراتيجية التخزين المؤقت

تنفيذ التخزين المؤقت الذكي للبيانات المُستخدمة بكثرة:

```yaml
caching:
  enabled: true
  provider: "redis"
  redis:
    host: "localhost:6379"
    password: ${REDIS_PASSWORD}
    db: 0
    
  policies:
    - pattern: "search-*"
      ttl: "5m"
      cache_null_results: false
      
    - pattern: "analytics-*"
      ttl: "15m"
      cache_on_query_params: ["customer_id"]
      
    - pattern: "schema-*"
      ttl: "1h"
      cache_globally: true
```

## المراقبة والملاحظة

### جمع المقاييس

```yaml
monitoring:
  metrics:
    enabled: true
    port: 9090
    path: "/metrics"
    
  logging:
    level: "info"
    format: "json"
    output: "/var/log/genai-toolbox.log"
    
  tracing:
    enabled: true
    jaeger_endpoint: "http://localhost:14268/api/traces"
    
  health_checks:
    enabled: true
    database_ping: true
    cache_connectivity: true
```

### لوحة معلومات Grafana

إنشاء لوحات معلومات مراقبة شاملة:

```json
{
  "dashboard": {
    "title": "مراقبة GenAI Toolbox",
    "panels": [
      {
        "title": "معدل الطلبات",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(toolbox_requests_total[5m])",
            "legendFormat": "طلبات/ثانية"
          }
        ]
      },
      {
        "title": "تجمع اتصال قاعدة البيانات",
        "type": "graph",
        "targets": [
          {
            "expr": "toolbox_db_connections_active",
            "legendFormat": "الاتصالات النشطة"
          },
          {
            "expr": "toolbox_db_connections_idle",
            "legendFormat": "الاتصالات الخاملة"
          }
        ]
      },
      {
        "title": "أداء الاستعلام",
        "type": "heatmap",
        "targets": [
          {
            "expr": "toolbox_query_duration_seconds",
            "legendFormat": "مدة الاستعلام"
          }
        ]
      }
    ]
  }
}
```

## أفضل الممارسات والأمان

### تقوية الأمان

1. **متغيرات البيئة**: لا تقوم بترميز أوراق الاعتماد بشكل ثابت
2. **عزل الشبكة**: استخدم الشبكات الخاصة للتواصل مع قاعدة البيانات
3. **تشفير TLS**: قم بتمكين SSL/TLS لجميع اتصالات قاعدة البيانات
4. **التحقق من الإدخال**: نفذ التحقق الصارم من المعاملات
5. **تعقيم الاستعلام**: استخدم الاستعلامات المعاملة حصرياً

### أفضل ممارسات الأداء

1. **تحسين الاستعلام**: استخدم EXPLAIN ANALYZE لضبط الاستعلام
2. **استراتيجية الفهرس**: تأكد من الفهرسة المناسبة للاستعلامات المتكررة
3. **حدود الاتصال**: قم بتعيين أحجام تجمع اتصال مناسبة
4. **تكوين المهلة الزمنية**: نفذ مهلات زمنية معقولة للاستعلام
5. **مراقبة الموارد**: راقب استخدام المعالج والذاكرة والإدخال/الإخراج

### استكشاف الأخطاء وإصلاحها الشائعة

#### مشاكل الاتصال

```bash
# اختبار اتصال قاعدة البيانات
docker exec -it genai-toolbox ./toolbox test-connection --source my-postgres-db

# فحص سجلات أخطاء الاتصال
docker logs genai-toolbox | grep -i "connection"

# التحقق من اتصال الشبكة
docker exec -it genai-toolbox ping postgres-host
```

#### مشاكل الأداء

```bash
# تمكين سجل الاستعلام
docker exec -it genai-toolbox ./toolbox --log-level debug

# مراقبة الاتصالات النشطة
docker exec -it postgres psql -U user -d database -c "SELECT count(*) FROM pg_stat_activity;"

# فحص الاستعلامات البطيئة
docker exec -it postgres psql -U user -d database -c "SELECT query, mean_time FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"
```

## الخلاصة

يوفر Google GenAI Toolbox حلاً قوياً وقابلاً للتوسع لدمج عمليات قاعدة البيانات في تطبيقات الذكاء الاصطناعي من خلال بروتوكول MCP. تصميمه المستقل عن الإطار، وميزات الأمان الشاملة، والبنية الجاهزة للإنتاج تجعله خياراً ممتازاً لنشر الذكاء الاصطناعي في المؤسسات.

النقاط الرئيسية من هذا البرنامج التعليمي:

1. **إعداد سهل**: تكوين بسيط من خلال ملفات YAML
2. **مرونة الإطار**: يعمل مع Genkit وLangChain وOpenAI والتطبيقات المخصصة
3. **جاهز للإنتاج**: قدرات أمان ومراقبة وتوسع مدمجة
4. **محسن للأداء**: تجميع الاتصالات والتخزين المؤقت وتحسين الاستعلام
5. **أدوات شاملة**: مجموعة غنية من عمليات قاعدة البيانات وأدوات التحليلات

سواء كنت تبني روبوت محادثة بسيط مع استعلامات قاعدة البيانات أو نظام وكلاء متعدد معقد يتطلب عمليات بيانات متطورة، فإن GenAI Toolbox يوفر الأساس لتكامل قاعدة البيانات الموثوق والآمن وعالي الأداء.

لحالات الاستخدام الأكثر تقدماً والتحديثات الأحدث، قم بزيارة [المستودع الرسمي](https://github.com/googleapis/genai-toolbox) وانضم إلى المجتمع المتنامي من المطورين الذين يستفيدون من MCP لعمليات قاعدة البيانات المدعومة بالذكاء الاصطناعي.
