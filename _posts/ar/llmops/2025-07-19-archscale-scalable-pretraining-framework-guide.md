---
title: "Microsoft ArchScale: دليل شامل لإطار عمل التدريب المسبق للنماذج اللغوية الكبيرة القابل للتوسع"
excerpt: "بناء أبحاث معمارية للشبكات العصبية وخطوط أنابيب تدريب النماذج الكبيرة باستخدام ArchScale. من قوانين التحجيم mu-P++ إلى التدريب على سياق يصل إلى 128 ألف رمز."
seo_title: "دليل التدريب المسبق لـ ArchScale - إطار عمل Microsoft - Thaki Cloud"
seo_description: "دليل شامل للتدريب المسبق على النماذج اللغوية الكبيرة باستخدام Microsoft ArchScale. يغطي تحجيم mu-P++ والتدريب على السياق الطويل والمعالجة الموزعة وتقييم الأداء."
date: 2025-07-19
last_modified_at: 2025-07-19
categories:
  - llmops
tags:
  - ArchScale
  - Microsoft
  - LLM
  - 사전훈련
  - 스케일링
  - μP++
  - 분산훈련
  - 롱컨텍스트
  - PyTorch
  - torchrun
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/llmops/archscale-scalable-pretraining-framework-guide/"
reading_time: true
lang: ar
---

⏱️ **وقت القراءة المقدر**: 25 دقيقة

## مقدمة

**Microsoft ArchScale** هو إطار عمل بسيط وقابل للتوسع للتدريب المسبق، مصمم لأبحاث معمارية الشبكات العصبية. يدعم التدريب الفعّال للنماذج التي يتراوح حجمها من 110 مليون إلى 3.3 مليار معامل، وتتيح قوانين التحجيم **mu-P++** خفض تكلفة ضبط المعاملات الفائقة بشكل كبير.

### الميزات الجوهرية لـ ArchScale

- 🎯 **دعم معماريات متعددة**: Phi4-mini-Flash وSambaY وTransformer++ وMamba وغيرها
- 📊 **تحجيم mu-P++**: نقل المعاملات الفائقة المضبوطة على نماذج صغيرة إلى نماذج كبيرة تلقائياً
- 🚀 **تدريب فعّال**: تقنيات تحسين تشمل Flash Attention وRoPE والنوى المدمجة
- 📏 **سياق طويل**: تدريب بأطوال متغيرة يصل إلى 128 ألف رمز
- 🔍 **تقييم شامل**: معايير RULER وPhonebook والاستدلال وغيرها

## إعداد البيئة والتثبيت

### 1. إعداد Docker

يوصي ArchScale باستخدام Docker لإعداد البيئة:

```bash
# استنساخ مستودع ArchScale
git clone https://github.com/microsoft/ArchScale.git
cd ArchScale

# بناء صورة Docker
docker build -t archscale:latest .

# تشغيل الحاوية مع دعم GPU
docker run --gpus all -it --rm \
    -v $(pwd):/workspace \
    -v /path/to/data:/data \
    archscale:latest bash
```

### 2. التثبيت المباشر

في حال عدم استخدام Docker:

```bash
# تثبيت الاعتماديات
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
pip install lightning datasets transformers wandb

# استنساخ ArchScale وتثبيته
git clone https://github.com/microsoft/ArchScale.git
cd ArchScale
pip install -e .
```

### 3. إعداد البيانات

#### ترميز مجموعة بيانات SlimPajama

```bash
# ترميز البيانات وفق مرجع قاعدة كود Samba
# مثال: معالجة SlimPajama المسبقة
python scripts/prepare_data.py \
    --input_dir /path/to/slimpajama \
    --output_dir /path/to/tokenized_data \
    --tokenizer microsoft/Phi-4-mini-flash-reasoning \
    --context_length 8192
```

## المفهوم الجوهري: قوانين تحجيم mu-P++

### ما هو mu-P++؟

**mu-P++ (Maximal Update Parameterization)** هو أسلوب يُحجّم المعاملات الفائقة المثلى تلقائياً عند تغيُّر حجم النموذج.

```python
# مثال على إعداد BaseHyperparameters
from lit_gpt.config import BaseHyperparameters

# المعاملات الفائقة استناداً إلى d16 (العمق=16)
base_hps = BaseHyperparameters(
    eta0=5e-4,          # معدل التعلم
    b0=8388608,         # حجم الدُفعة (عدد الرموز)
    warmup_tokens0=25_165_824_000,  # عدد رموز الإحماء
    # معاملات أخرى متعلقة بالتحسين
)

# يُحجَّم تلقائياً عند تدريب نماذج d8 أو d24
```

### مزايا قوانين التحجيم

1. **خفض التكلفة**: ضبط المعاملات الفائقة على نماذج صغيرة ثم تطبيقها على نماذج كبيرة
2. **الاتساق**: تدريب مستقر بصرف النظر عن حجم النموذج
3. **الكفاءة**: خفض ملحوظ في عدد التجارب المطلوبة

## دليل التدريب العملي

### 1. التدريب المسبق لنموذج Phi4-mini-Flash

تدريب نموذج Phi4-mini-Flash على 5 تريليون رمز من البيانات عالية الجودة:

```bash
#!/bin/bash
# phi4_pretrain.sh

export LIGHTNING_ARTIFACTS_DIR='/path/to/output_dir'
export MASTER_ADDR='master_node_ip'
export MASTER_PORT='29500'

# التدريب الموزع باستخدام 1000 GPU (128 عقدة x 8 GPU)
torchrun --nnodes=128 --nproc_per_node=8 \
    --rdzv_backend=c10d \
    --rdzv_endpoint=${MASTER_ADDR}:${MASTER_PORT} \
    pretrain.py \
    --train_data_dir /path/to/phi4/data \
    --base_hps.eta0=5e-4 \
    --base_hps.b0=8388608 \
    --base_hps.warmup_tokens0=25_165_824_000 \
    --ctx_len 8192 \
    --max_tokens 5e12 \
    --resume="auto" \
    --train_model phi4miniflash \
    --depth 32 \
    --train_name scaling
```

### 2. تدريب معمارية SambaY (موصى به)

تدريب نموذج SambaY ذي المعمارية الأكثر وضوحاً:

```bash
#!/bin/bash
# sambay_pretrain.sh

torchrun --nnodes=128 --nproc_per_node=8 \
    --rdzv_backend=c10d \
    --rdzv_endpoint=${MASTER_ADDR}:${MASTER_PORT} \
    pretrain.py \
    --train_data_dir /path/to/data \
    --train_model sambayda \
    --depth 24 \
    --vocab_size 200064 \
    --train_name scaling_mup_tie \
    --ctx_len 8192 \
    --max_tokens 1e12
```

### 3. تجارب تحجيم العمليات الحسابية (FLOPs)

تدريب نماذج بأحجام متنوعة تتراوح بين 110 مليون و3.3 مليار معامل:

```bash
#!/bin/bash
# flops_scaling.sh

export MASTER_ADDR='localhost'
export MASTER_PORT='29500'

# تجارب بأعماق متنوعة باستخدام 8 GPU
for depth in 8 12 16 20 24; do
    echo "Training model with depth=${depth}"
    
    torchrun --nnodes=1 --nproc_per_node=8 \
        --rdzv_backend=c10d \
        --rdzv_endpoint=${MASTER_ADDR}:${MASTER_PORT} \
        pretrain.py \
        --train_data_dir /path/to/slim_pajama/data \
        --val_data_dir /path/to/slim_pajama/data \
        --train_model sambay \
        --depth ${depth} \
        --train_name scaling_mup \
        --max_tokens 1e11
done

# توليد منحنى التحجيم
python plot_flops_scaling.py \
    --log_dir /path/to/output_dir \
    --output_file flops_scaling_results.png
```

### 4. تجارب تحجيم البيانات

تحجيم البيانات من 100 مليار إلى 600 مليار رمز باستخدام نموذج بمليار معامل:

```bash
#!/bin/bash
# data_scaling.sh

# تحجيم البيانات باستخدام 64 GPU (8 عقد x 8 GPU)
for tokens in 1e11 2e11 3e11 4e11 5e11 6e11; do
    echo "Training with ${tokens} tokens"
    
    torchrun --nnodes=8 --nproc_per_node=8 \
        --rdzv_backend=c10d \
        --rdzv_endpoint=${MASTER_ADDR}:${MASTER_PORT} \
        pretrain.py \
        --train_data_dir /path/to/slim_pajama/data \
        --val_data_dir /path/to/slim_pajama/data \
        --train_model transformer \
        --depth 16 \
        --max_tokens ${tokens} \
        --train_name scaling_mup_tie
done

# تحليل منحنى تحجيم البيانات
python plot_data_scaling.py \
    --log_dir /path/to/output_dir \
    --output_file data_scaling_results.png
```

## استراتيجية ضبط المعاملات الفائقة

### 1. الضبط الفعّال باستخدام mu-P++

```bash
#!/bin/bash
# hyperparameter_sweep.sh

# ضبط المعاملات الفائقة استناداً إلى نموذج d16 بمليار معامل
# من الناحية العملية، تُجرى التجارب السريعة على نموذج d8
for lr in 4e-4 1e-4 1e-3; do
    for batch_size in 4194304 8388608 16777216; do
        echo "Testing lr=${lr}, batch_size=${batch_size}"
        
        torchrun --nnodes=1 --nproc_per_node=8 \
            --rdzv_backend=c10d \
            --rdzv_endpoint=${MASTER_ADDR}:${MASTER_PORT} \
            pretrain.py \
            --train_data_dir /path/to/slim_pajama/data \
            --val_data_dir /path/to/slim_pajama/data \
            --train_model transformer \
            --depth 8 \
            --base_hps.eta0=${lr} \
            --base_hps.b0=${batch_size} \
            --train_name "hp_sweep_lr${lr}_bs${batch_size}" \
            --max_tokens 1e10
    done
done
```

### 2. تحليل المعاملات الفائقة المثلى

```python
# analyze_hyperparameters.py
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

def analyze_sweep_results(log_dir):
    """تحليل نتائج مسح المعاملات الفائقة"""
    results = []
    
    for log_file in Path(log_dir).glob("*/metrics.csv"):
        # استخراج الخسارة النهائية لكل تجربة
        df = pd.read_csv(log_file)
        final_loss = df['val_loss'].min()
        
        # استخراج المعاملات الفائقة من اسم التجربة
        exp_name = log_file.parent.name
        lr = float(exp_name.split('lr')[1].split('_')[0])
        bs = int(exp_name.split('bs')[1])
        
        results.append({
            'learning_rate': lr,
            'batch_size': bs,
            'final_loss': final_loss
        })
    
    results_df = pd.DataFrame(results)
    
    # إيجاد المعاملات الفائقة المثلى
    best_idx = results_df['final_loss'].idxmin()
    best_config = results_df.iloc[best_idx]
    
    print(f"الإعداد الأمثل:")
    print(f"معدل التعلم: {best_config['learning_rate']}")
    print(f"حجم الدُفعة: {best_config['batch_size']}")
    print(f"الخسارة النهائية: {best_config['final_loss']:.4f}")
    
    return results_df, best_config

if __name__ == "__main__":
    results_df, best_config = analyze_sweep_results("/path/to/sweep_logs")
```

## التدريب على السياق الطويل

### 1. التدريب على سياق 32 ألف رمز باستخدام بيانات ProLong-64K

```bash
#!/bin/bash
# long_context_training.sh

# المعالجة المسبقة لبيانات ProLong-64K (ترميز مسبق)
python scripts/preprocess_prolong.py \
    --input_dir /path/to/prolong_raw \
    --output_dir /path/to/prolong_tokenized \
    --max_length 65536 \
    --shuffle

# التدريب بطول تسلسل 32 ألف رمز
torchrun --nnodes=1 --nproc_per_node=8 \
    --rdzv_backend=c10d \
    --rdzv_endpoint=${MASTER_ADDR}:${MASTER_PORT} \
    pretrain.py \
    --train_data_dir /path/to/prolong_tokenized \
    --val_data_dir /path/to/prolong_tokenized \
    --train_model transformer \
    --depth 16 \
    --ctx_len 32768 \
    --max_tokens 4e10 \
    --train_name scaling_mup_rbase_varlen
```

### 2. التدريب على سياق 128 ألف رمز (الحد الأقصى)

```bash
#!/bin/bash
# ultra_long_context.sh

# التدريب على سياق 128 ألف رمز في وضع توفير الذاكرة
torchrun --nnodes=4 --nproc_per_node=8 \
    --rdzv_backend=c10d \
    --rdzv_endpoint=${MASTER_ADDR}:${MASTER_PORT} \
    pretrain.py \
    --train_data_dir /path/to/prolong_tokenized \
    --train_model transformer \
    --depth 20 \
    --ctx_len 131072 \
    --fsdp_save_mem=true \
    --train_name ultra_long_context \
    --max_tokens 2e10
```

### 3. إعداد التدريب بأطوال متغيرة

```python
# variable_length_config.py
from lit_gpt.config import Config

def setup_variable_length_training():
    """إعداد التدريب بأطوال متغيرة"""
    config = Config(
        # إعداد النموذج الأساسي
        n_layer=16,
        n_head=16,
        n_embd=2048,
        
        # إعدادات الأطوال المتغيرة
        variable_length=True,
        pack_sequences=True,
        eos_token_id=2,  # فصل المستندات باستخدام رمز EOS
        
        # إعدادات RoPE (للسياق الطويل)
        rope_base=10000,  # القيمة الافتراضية
        rope_scaling=None,  # أو {"type": "linear", "factor": 2.0}
        
        # تحسين الذاكرة
        use_gradient_checkpointing=True,
        attention_dropout=0.0,
        residual_dropout=0.1
    )
    
    return config
```

## تدريب معمارية Mamba

### 1. تثبيت Mamba-1

```bash
# تثبيت Mamba بأطوال متغيرة
git clone https://github.com/zigzagcai/varlen_mamba.git --branch feat/add-cu_seqlens
cd varlen_mamba
pip install --no-build-isolation -e .
```

### 2. تدريب نماذج Mamba

```bash
#!/bin/bash
# mamba_training.sh

torchrun --nnodes=2 --nproc_per_node=8 \
    --rdzv_backend=c10d \
    --rdzv_endpoint=${MASTER_ADDR}:${MASTER_PORT} \
    pretrain.py \
    --train_data_dir /path/to/data \
    --train_model mamba \
    --depth 16 \
    --ctx_len 16384 \
    --train_name mamba_varlen \
    --max_tokens 1e11
```

## منظومة التقييم الشاملة

### 1. المعايير القياسية لمعالجة اللغة الطبيعية

```bash
#!/bin/bash
# standard_evaluation.sh

python eval.py \
    --model ArchScale \
    --model_args pretrained=/path/to/checkpoint.pth,config="sambay_d16" \
    --tasks wikitext,lambada_openai,arc_easy,arc_challenge,winogrande,hellaswag,piqa,social_iqa \
    --device cuda \
    --batch_size 16 \
    --trust_remote_code \
    --output_path /path/to/eval_results.json
```

### 2. تقييم السياق الطويل

#### معيار RULER

```bash
#!/bin/bash
# ruler_evaluation.sh

# اختبار الإبرة في كومة القش (Needle-in-a-Haystack)
python eval.py \
    --model ArchScale \
    --model_args pretrained=/path/to/checkpoint.pth,config="sambay_d16",max_length=32768,tokenizer=Orkhan/llama-2-7b-absa \
    --metadata='{"max_seq_lengths":[32768]}' \
    --tasks niah_single_1,niah_single_2,niah_single_3 \
    --device cuda \
    --batch_size 4 \
    --trust_remote_code
```

#### تقييم Phonebook

```bash
#!/bin/bash
# phonebook_evaluation.sh

python eval_phonebook.py \
    --checkpoint_path /path/to/checkpoint.pth \
    --config "sambay_d16" \
    --min_eval_len 1850 \
    --max_eval_len 32000 \
    --output_dir /path/to/phonebook_results \
    --eval_batch_size 4 \
    --num_samples 1000
```

### 3. تقييم الاستدلال

```bash
#!/bin/bash
# reasoning_evaluation.sh

# تقييم الاستدلال الرياضي والعلمي (يتطلب خلفية vLLM)
./eval_reason.sh microsoft/Phi-4-mini-flash-reasoning aime24 /path/to/output_dir

# حل مسائل رياضيات GSM8K
./eval_reason.sh microsoft/Phi-4-mini-flash-reasoning gsm8k /path/to/output_dir

# تقييم مجموعة بيانات MATH
./eval_reason.sh microsoft/Phi-4-mini-flash-reasoning math /path/to/output_dir
```

### 4. تحليل نتائج التقييم

```python
# evaluation_analysis.py
import json
import pandas as pd
import matplotlib.pyplot as plt

def analyze_evaluation_results(results_dir):
    """تحليل شامل لنتائج التقييم"""
    
    # تحميل نتائج المعايير القياسية
    with open(f"{results_dir}/standard_eval.json", 'r') as f:
        standard_results = json.load(f)
    
    # تحميل نتائج السياق الطويل
    with open(f"{results_dir}/phonebook_results.json", 'r') as f:
        phonebook_results = json.load(f)
    
    # تحميل نتائج الاستدلال
    with open(f"{results_dir}/reasoning_results.json", 'r') as f:
        reasoning_results = json.load(f)
    
    # تنظيم النتائج
    summary = {
        "Standard NLP": {
            "HellaSwag": standard_results.get("hellaswag", {}).get("acc_norm", 0),
            "PIQA": standard_results.get("piqa", {}).get("acc_norm", 0),
            "WinoGrande": standard_results.get("winogrande", {}).get("acc", 0),
            "ARC-E": standard_results.get("arc_easy", {}).get("acc_norm", 0),
            "ARC-C": standard_results.get("arc_challenge", {}).get("acc_norm", 0)
        },
        "Long Context": {
            "Phonebook (16K)": phonebook_results.get("16384", {}).get("accuracy", 0),
            "Phonebook (32K)": phonebook_results.get("32768", {}).get("accuracy", 0),
        },
        "Reasoning": {
            "GSM8K": reasoning_results.get("gsm8k", {}).get("accuracy", 0),
            "AIME": reasoning_results.get("aime24", {}).get("accuracy", 0),
            "MATH": reasoning_results.get("math", {}).get("accuracy", 0)
        }
    }
    
    # تصور النتائج
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    for idx, (category, scores) in enumerate(summary.items()):
        tasks = list(scores.keys())
        values = list(scores.values())
        
        axes[idx].bar(tasks, values)
        axes[idx].set_title(f"{category} Performance")
        axes[idx].set_ylabel("Accuracy")
        axes[idx].tick_params(axis='x', rotation=45)
    
    plt.tight_layout()
    plt.savefig(f"{results_dir}/evaluation_summary.png", dpi=300, bbox_inches='tight')
    
    return summary

# مثال على التشغيل
if __name__ == "__main__":
    summary = analyze_evaluation_results("/path/to/eval_results")
    print("ملخص نتائج التقييم:")
    for category, scores in summary.items():
        print(f"\n{category}:")
        for task, score in scores.items():
            print(f"  {task}: {score:.3f}")
```

## المراقبة والتسجيل

### 1. التكامل مع Weights and Biases

```python
# wandb_integration.py
import wandb
from datetime import datetime

def setup_wandb_logging(config):
    """إعداد تسجيل W&B"""
    
    # تهيئة المشروع
    wandb.init(
        project="archscale-pretraining",
        name=f"experiment_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
        config={
            "model_architecture": config.train_model,
            "depth": config.depth,
            "context_length": config.ctx_len,
            "max_tokens": config.max_tokens,
            "learning_rate": config.base_hps.eta0,
            "batch_size": config.base_hps.b0,
            "scaling_method": "muP++" if "mup" in config.train_name else "standard"
        },
        tags=[config.train_model, f"depth_{config.depth}", config.train_name]
    )
    
    return wandb

def log_training_metrics(step, metrics):
    """تسجيل مقاييس التدريب"""
    wandb.log({
        "step": step,
        "train/loss": metrics["train_loss"],
        "train/perplexity": metrics["train_ppl"],
        "val/loss": metrics["val_loss"],
        "val/perplexity": metrics["val_ppl"],
        "lr": metrics["learning_rate"],
        "gpu_memory": metrics["gpu_memory_gb"],
        "tokens_per_second": metrics["tokens_per_sec"]
    })

def log_evaluation_results(eval_results):
    """تسجيل نتائج التقييم"""
    for task, result in eval_results.items():
        wandb.log({
            f"eval/{task}": result["accuracy"],
            f"eval/{task}_samples": result["num_samples"]
        })
```

### 2. مراقبة النظام

```python
# system_monitor.py
import psutil
import GPUtil
import torch
import time
from threading import Thread

class SystemMonitor:
    def __init__(self, log_interval=60):
        self.log_interval = log_interval
        self.monitoring = False
        
    def start_monitoring(self):
        """بدء مراقبة النظام"""
        self.monitoring = True
        monitor_thread = Thread(target=self._monitor_loop)
        monitor_thread.daemon = True
        monitor_thread.start()
        
    def stop_monitoring(self):
        """إيقاف مراقبة النظام"""
        self.monitoring = False
        
    def _monitor_loop(self):
        """حلقة المراقبة"""
        while self.monitoring:
            metrics = self._collect_metrics()
            self._log_metrics(metrics)
            time.sleep(self.log_interval)
    
    def _collect_metrics(self):
        """جمع مقاييس النظام"""
        # استخدام المعالج والذاكرة
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        
        # مقاييس GPU
        gpus = GPUtil.getGPUs()
        gpu_metrics = []
        for gpu in gpus:
            gpu_metrics.append({
                "id": gpu.id,
                "utilization": gpu.load * 100,
                "memory_used": gpu.memoryUsed,
                "memory_total": gpu.memoryTotal,
                "temperature": gpu.temperature
            })
        
        # ذاكرة PyTorch (CUDA)
        torch_memory = {}
        if torch.cuda.is_available():
            for i in range(torch.cuda.device_count()):
                torch_memory[f"cuda_{i}"] = {
                    "allocated": torch.cuda.memory_allocated(i) / 1024**3,  # GB
                    "reserved": torch.cuda.memory_reserved(i) / 1024**3,    # GB
                    "max_allocated": torch.cuda.max_memory_allocated(i) / 1024**3
                }
        
        return {
            "timestamp": time.time(),
            "cpu_percent": cpu_percent,
            "memory_percent": memory.percent,
            "memory_available_gb": memory.available / 1024**3,
            "gpu_metrics": gpu_metrics,
            "torch_memory": torch_memory
        }
    
    def _log_metrics(self, metrics):
        """تسجيل المقاييس"""
        print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] System Metrics:")
        print(f"  CPU: {metrics['cpu_percent']:.1f}%")
        print(f"  Memory: {metrics['memory_percent']:.1f}%")
        
        for gpu in metrics['gpu_metrics']:
            print(f"  GPU {gpu['id']}: {gpu['utilization']:.1f}% | "
                  f"{gpu['memory_used']:.1f}GB/{gpu['memory_total']:.1f}GB | "
                  f"{gpu['temperature']}°C")
        
        # التسجيل أيضاً في W&B
        if wandb.run is not None:
            wandb.log({
                "system/cpu_percent": metrics['cpu_percent'],
                "system/memory_percent": metrics['memory_percent'],
                **{f"system/gpu_{gpu['id']}_util": gpu['utilization'] 
                   for gpu in metrics['gpu_metrics']},
                **{f"system/gpu_{gpu['id']}_memory": gpu['memory_used'] 
                   for gpu in metrics['gpu_metrics']}
            })
```

## استراتيجية النشر في الإنتاج

### 1. تحويل النموذج وتحسينه

```python
# model_optimization.py
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer
from lit_gpt.model import GPT
from lit_gpt.config import Config

def convert_archscale_to_hf(checkpoint_path, config_name, output_dir):
    """تحويل نموذج ArchScale إلى صيغة HuggingFace"""
    
    # تحميل نموذج ArchScale
    config = Config.from_name(config_name)
    model = GPT(config)
    
    checkpoint = torch.load(checkpoint_path, map_location="cpu")
    model.load_state_dict(checkpoint["model"])
    
    # التحويل إلى صيغة HuggingFace
    # (التنفيذ الفعلي يختلف حسب المعمارية)
    hf_model = convert_to_hf_format(model, config)
    
    # الحفظ
    hf_model.save_pretrained(output_dir)
    
    return hf_model

def quantize_model(model_path, output_path, quantization_type="int8"):
    """تكميم النموذج"""
    import torch.quantization as quant
    
    model = AutoModelForCausalLM.from_pretrained(model_path)
    
    if quantization_type == "int8":
        model = quant.quantize_dynamic(
            model, {torch.nn.Linear}, dtype=torch.qint8
        )
    elif quantization_type == "int4":
        # استخدام BitsAndBytes
        from transformers import BitsAndBytesConfig
        
        quantization_config = BitsAndBytesConfig(
            load_in_4bit=True,
            bnb_4bit_quant_type="nf4",
            bnb_4bit_compute_dtype=torch.float16
        )
        
        model = AutoModelForCausalLM.from_pretrained(
            model_path,
            quantization_config=quantization_config,
            device_map="auto"
        )
    
    model.save_pretrained(output_path)
    return model
```

### 2. تحسين التقديم

```python
# serving_optimization.py
import vllm
from vllm import LLM, SamplingParams
import ray

class ArchScaleInferenceServer:
    def __init__(self, model_path, gpu_memory_utilization=0.9):
        """خادم تقديم نموذج ArchScale"""
        
        # تهيئة محرك vLLM
        self.llm = LLM(
            model=model_path,
            gpu_memory_utilization=gpu_memory_utilization,
            max_model_len=32768,  # دعم السياق الطويل
            enable_prefix_caching=True,  # تسريع بالتخزين المؤقت للبادئة
            enforce_eager=False,  # تحسين رسم CUDA البياني
        )
        
        # معاملات أخذ العينات الافتراضية
        self.default_sampling_params = SamplingParams(
            temperature=0.7,
            top_p=0.9,
            max_tokens=1024,
            repetition_penalty=1.1
        )
    
    def generate(self, prompts, sampling_params=None):
        """توليد دُفعي"""
        if sampling_params is None:
            sampling_params = self.default_sampling_params
            
        outputs = self.llm.generate(prompts, sampling_params)
        
        results = []
        for output in outputs:
            results.append({
                "prompt": output.prompt,
                "generated_text": output.outputs[0].text,
                "finish_reason": output.outputs[0].finish_reason,
                "tokens": len(output.outputs[0].token_ids)
            })
        
        return results
    
    async def generate_stream(self, prompt, sampling_params=None):
        """توليد تدفقي"""
        if sampling_params is None:
            sampling_params = self.default_sampling_params
            
        # تنفيذ التدفق في vLLM
        for output in self.llm.generate_stream([prompt], sampling_params):
            yield output.outputs[0].text

# النشر القابل للتوسع باستخدام Ray Serve
@ray.serve.deployment(num_replicas=2)
class ArchScaleService:
    def __init__(self, model_path):
        self.inference_server = ArchScaleInferenceServer(model_path)
    
    async def __call__(self, request):
        prompts = request["prompts"]
        sampling_params = SamplingParams(**request.get("sampling_params", {}))
        
        results = self.inference_server.generate(prompts, sampling_params)
        return {"results": results}
```

### 3. قياس أداء النظام

```python
# performance_benchmark.py
import time
import asyncio
import aiohttp
import statistics
from concurrent.futures import ThreadPoolExecutor

class PerformanceBenchmark:
    def __init__(self, server_url="http://localhost:8000"):
        self.server_url = server_url
        
    async def single_request_latency(self, prompt, num_requests=100):
        """قياس زمن استجابة الطلب الفردي"""
        latencies = []
        
        async with aiohttp.ClientSession() as session:
            for _ in range(num_requests):
                start_time = time.time()
                
                async with session.post(
                    f"{self.server_url}/generate",
                    json={"prompts": [prompt]}
                ) as response:
                    await response.json()
                
                latency = time.time() - start_time
                latencies.append(latency)
        
        return {
            "mean_latency": statistics.mean(latencies),
            "median_latency": statistics.median(latencies),
            "p95_latency": sorted(latencies)[int(0.95 * len(latencies))],
            "p99_latency": sorted(latencies)[int(0.99 * len(latencies))]
        }
    
    async def throughput_test(self, prompt, concurrent_requests=50, duration_seconds=60):
        """قياس الإنتاجية"""
        completed_requests = 0
        start_time = time.time()
        
        async def worker():
            nonlocal completed_requests
            async with aiohttp.ClientSession() as session:
                while time.time() - start_time < duration_seconds:
                    try:
                        async with session.post(
                            f"{self.server_url}/generate",
                            json={"prompts": [prompt]}
                        ) as response:
                            await response.json()
                            completed_requests += 1
                    except Exception as e:
                        print(f"Request failed: {e}")
        
        # تنفيذ الطلبات المتزامنة
        tasks = [worker() for _ in range(concurrent_requests)]
        await asyncio.gather(*tasks)
        
        actual_duration = time.time() - start_time
        throughput = completed_requests / actual_duration
        
        return {
            "total_requests": completed_requests,
            "duration_seconds": actual_duration,
            "requests_per_second": throughput
        }
    
    def token_generation_speed(self, prompts, output_lengths):
        """قياس سرعة توليد الرموز"""
        total_tokens = 0
        total_time = 0
        
        for prompt, expected_length in zip(prompts, output_lengths):
            start_time = time.time()
            
            # الطلب الفعلي (متزامن)
            import requests
            response = requests.post(
                f"{self.server_url}/generate",
                json={
                    "prompts": [prompt],
                    "sampling_params": {"max_tokens": expected_length}
                }
            )
            
            generation_time = time.time() - start_time
            actual_tokens = len(response.json()["results"][0]["generated_text"].split())
            
            total_tokens += actual_tokens
            total_time += generation_time
        
        return {
            "total_tokens": total_tokens,
            "total_time": total_time,
            "tokens_per_second": total_tokens / total_time
        }

# مثال على تشغيل المعيار
async def run_benchmark():
    benchmark = PerformanceBenchmark()
    
    test_prompt = "Explain the concept of machine learning in simple terms:"
    
    # اختبار زمن الاستجابة
    latency_results = await benchmark.single_request_latency(test_prompt)
    print("Latency Results:", latency_results)
    
    # اختبار الإنتاجية
    throughput_results = await benchmark.throughput_test(test_prompt)
    print("Throughput Results:", throughput_results)
    
    # اختبار سرعة توليد الرموز
    speed_results = benchmark.token_generation_speed([test_prompt], [100])
    print("Generation Speed:", speed_results)

if __name__ == "__main__":
    asyncio.run(run_benchmark())
```

## دليل التشغيل الإنتاجي

### 1. إدارة نقاط التفتيش

```python
# checkpoint_manager.py
import torch
import shutil
from pathlib import Path
import json
from datetime import datetime

class CheckpointManager:
    def __init__(self, base_dir, max_checkpoints=5):
        self.base_dir = Path(base_dir)
        self.max_checkpoints = max_checkpoints
        self.metadata_file = self.base_dir / "checkpoint_metadata.json"
        
    def save_checkpoint(self, model, optimizer, scheduler, step, metrics):
        """حفظ نقطة التفتيش"""
        checkpoint_dir = self.base_dir / f"checkpoint_{step}"
        checkpoint_dir.mkdir(parents=True, exist_ok=True)
        
        # حفظ حالة النموذج
        torch.save({
            "model": model.state_dict(),
            "optimizer": optimizer.state_dict(),
            "scheduler": scheduler.state_dict(),
            "step": step,
            "metrics": metrics
        }, checkpoint_dir / "model.pth")
        
        # حفظ البيانات الوصفية
        metadata = {
            "step": step,
            "timestamp": datetime.now().isoformat(),
            "metrics": metrics,
            "path": str(checkpoint_dir)
        }
        
        self._update_metadata(metadata)
        self._cleanup_old_checkpoints()
        
        return checkpoint_dir
    
    def load_latest_checkpoint(self):
        """تحميل أحدث نقطة تفتيش"""
        if not self.metadata_file.exists():
            return None
            
        with open(self.metadata_file, 'r') as f:
            all_metadata = json.load(f)
        
        if not all_metadata:
            return None
            
        # إيجاد أحدث نقطة تفتيش
        latest = max(all_metadata, key=lambda x: x["step"])
        checkpoint_path = Path(latest["path"]) / "model.pth"
        
        if checkpoint_path.exists():
            return torch.load(checkpoint_path), latest
        
        return None
    
    def _update_metadata(self, new_metadata):
        """تحديث البيانات الوصفية"""
        all_metadata = []
        
        if self.metadata_file.exists():
            with open(self.metadata_file, 'r') as f:
                all_metadata = json.load(f)
        
        all_metadata.append(new_metadata)
        
        with open(self.metadata_file, 'w') as f:
            json.dump(all_metadata, f, indent=2)
    
    def _cleanup_old_checkpoints(self):
        """حذف نقاط التفتيش القديمة"""
        with open(self.metadata_file, 'r') as f:
            all_metadata = json.load(f)
        
        if len(all_metadata) <= self.max_checkpoints:
            return
        
        # حذف نقاط التفتيش الأقدم
        sorted_metadata = sorted(all_metadata, key=lambda x: x["step"])
        to_remove = sorted_metadata[:-self.max_checkpoints]
        
        for metadata in to_remove:
            checkpoint_path = Path(metadata["path"])
            if checkpoint_path.exists():
                shutil.rmtree(checkpoint_path)
        
        # تحديث البيانات الوصفية
        remaining_metadata = sorted_metadata[-self.max_checkpoints:]
        with open(self.metadata_file, 'w') as f:
            json.dump(remaining_metadata, f, indent=2)
```

### 2. إدارة التجارب الآلية

```python
# experiment_manager.py
import yaml
import subprocess
import time
from pathlib import Path
import wandb

class ExperimentManager:
    def __init__(self, config_file):
        with open(config_file, 'r') as f:
            self.config = yaml.safe_load(f)
        
        self.experiments = self.config["experiments"]
        self.base_command = self.config["base_command"]
        
    def run_experiment_suite(self):
        """تشغيل مجموعة التجارب"""
        results = {}
        
        for exp_name, exp_config in self.experiments.items():
            print(f"Starting experiment: {exp_name}")
            
            # تشغيل التجربة
            result = self._run_single_experiment(exp_name, exp_config)
            results[exp_name] = result
            
            # تسجيل النتيجة
            self._log_experiment_result(exp_name, result)
        
        # ملخص جميع النتائج
        self._generate_summary_report(results)
        
        return results
    
    def _run_single_experiment(self, exp_name, exp_config):
        """تشغيل تجربة واحدة"""
        
        # بناء الأمر
        command = self._build_command(exp_config)
        
        # قياس وقت التنفيذ
        start_time = time.time()
        
        try:
            # تشغيل التجربة
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=exp_config.get("timeout", 3600*24)  # 24 ساعة افتراضياً
            )
            
            duration = time.time() - start_time
            
            if result.returncode == 0:
                # تجربة ناجحة
                metrics = self._extract_metrics(result.stdout)
                return {
                    "status": "success",
                    "duration": duration,
                    "metrics": metrics,
                    "stdout": result.stdout[-1000:],  # آخر 1000 حرف فقط
                    "stderr": result.stderr
                }
            else:
                # تجربة فاشلة
                return {
                    "status": "failed",
                    "duration": duration,
                    "error": result.stderr,
                    "returncode": result.returncode
                }
                
        except subprocess.TimeoutExpired:
            return {
                "status": "timeout",
                "duration": time.time() - start_time,
                "error": "Experiment timed out"
            }
        except Exception as e:
            return {
                "status": "error",
                "duration": time.time() - start_time,
                "error": str(e)
            }
    
    def _build_command(self, exp_config):
        """بناء أمر التجربة"""
        command_parts = [self.base_command]
        
        for key, value in exp_config.items():
            if key in ["timeout", "description"]:
                continue
                
            if isinstance(value, bool):
                if value:
                    command_parts.append(f"--{key}")
            else:
                command_parts.append(f"--{key} {value}")
        
        return " ".join(command_parts)
    
    def _extract_metrics(self, stdout):
        """استخراج المقاييس من المخرجات"""
        metrics = {}
        
        for line in stdout.split('\n'):
            if 'final_loss:' in line:
                try:
                    metrics['final_loss'] = float(line.split('final_loss:')[1].strip())
                except:
                    pass
            elif 'best_val_loss:' in line:
                try:
                    metrics['best_val_loss'] = float(line.split('best_val_loss:')[1].strip())
                except:
                    pass
        
        return metrics

# مثال على إعداد التجارب (experiments.yaml)
experiments_yaml = """
base_command: "torchrun --nnodes=1 --nproc_per_node=8 pretrain.py"

experiments:
  small_lr_sweep_1:
    train_data_dir: "/path/to/data"
    train_model: "transformer"
    depth: 8
    base_hps.eta0: 1e-4
    max_tokens: 1e10
    train_name: "lr_sweep_1e4"
    timeout: 7200
    description: "Learning rate 1e-4 test"
    
  small_lr_sweep_2:
    train_data_dir: "/path/to/data"
    train_model: "transformer"
    depth: 8
    base_hps.eta0: 5e-4
    max_tokens: 1e10
    train_name: "lr_sweep_5e4"
    timeout: 7200
    description: "Learning rate 5e-4 test"
    
  small_lr_sweep_3:
    train_data_dir: "/path/to/data"
    train_model: "transformer"
    depth: 8
    base_hps.eta0: 1e-3
    max_tokens: 1e10
    train_name: "lr_sweep_1e3"
    timeout: 7200
    description: "Learning rate 1e-3 test"
"""
```

## دليل استكشاف الأخطاء وإصلاحها

### 1. الأخطاء الشائعة وحلولها

```python
# troubleshooting.py

class ArchScaleTroubleshooter:
    @staticmethod
    def diagnose_oom_error():
        """تشخيص أخطاء نفاد الذاكرة وحلها"""
        print("تشخيص خطأ نفاد الذاكرة (OOM):")
        print("1. التحقق من ذاكرة GPU:")
        print("   nvidia-smi")
        print("\n2. تقليل حجم الدُفعة:")
        print("   --base_hps.b0=4194304  # نصف القيمة الافتراضية")
        print("\n3. تفعيل نقاط تفتيش التدرج:")
        print("   --gradient_checkpointing=true")
        print("\n4. وضع توفير ذاكرة FSDP:")
        print("   --fsdp_save_mem=true")
        print("\n5. تقليل طول السياق:")
        print("   --ctx_len=4096  # نصف القيمة الافتراضية 8192")
    
    @staticmethod
    def diagnose_slow_training():
        """تشخيص بطء التدريب"""
        print("تشخيص بطء التدريب:")
        print("1. فحص اختناق تحميل البيانات:")
        print("   --num_workers=8  # زيادة عدد عمال محمّل البيانات")
        print("\n2. تفعيل الدقة المختلطة:")
        print("   --precision=bf16")
        print("\n3. استخدام وضع الترجمة:")
        print("   --compile=true")
        print("\n4. التحقق من Flash Attention:")
        print("   pip install flash-attn")
        print("\n5. ترميز مجموعة البيانات مسبقاً:")
        print("   استخدام بيانات مرمّزة مسبقاً")
    
    @staticmethod
    def diagnose_distributed_issues():
        """تشخيص مشكلات التدريب الموزع"""
        print("تشخيص مشكلات التدريب الموزع:")
        print("1. التحقق من اتصال الشبكة:")
        print("   ping $MASTER_ADDR")
        print("\n2. التحقق من توفر المنفذ:")
        print("   netstat -an | grep $MASTER_PORT")
        print("\n3. ضبط متغيرات بيئة NCCL:")
        print("   export NCCL_DEBUG=INFO")
        print("   export NCCL_IB_DISABLE=1  # عند وجود مشكلات InfiniBand")
        print("\n4. التحقق من إعدادات جدار الحماية:")
        print("   فتح نطاق المنافذ 29500-29510")
        print("\n5. مزامنة الوقت بين العقد:")
        print("   ntpdate -s time.nist.gov")
```

### 2. قائمة مراجعة تحسين الأداء

```bash
#!/bin/bash
# performance_optimization_checklist.sh

echo "قائمة مراجعة تحسين أداء ArchScale"

echo "1. التحقق من إعداد الأجهزة:"
echo "   - ذاكرة GPU: يُنصح بـ 24 جيجابايت فأكثر"
echo "   - ربط GPU: NVLink أو PCIe 4.0+"
echo "   - التخزين: يُنصح بـ NVMe SSD"
echo "   - الشبكة: 10 جيجابت/ث فأكثر (للتدريب الموزع)"

echo -e "\n2. تحسين البرنامج:"
echo "   - استخدام PyTorch 2.0+"
echo "   - يُنصح بـ CUDA 12.1+"
echo "   - تثبيت Flash Attention 2.0"
echo "   - النظر في تثبيت xFormers"

echo -e "\n3. تحسين إعداد التدريب:"
echo "   - استخدام الدقة المختلطة (bf16)"
echo "   - ضبط تراكم التدرج"
echo "   - ضبط num_workers في DataLoader"
echo "   - ضبط عامل الجلب المسبق"

echo -e "\n4. تحسين الذاكرة:"
echo "   - استخدام FSDP (التشتت الكامل للبيانات الموازية)"
echo "   - تفعيل نقاط تفتيش التدرج"
echo "   - النظر في تشتيت النموذج"
echo "   - تفريغ إلى وحدة المعالجة المركزية (عند الحاجة)"

echo -e "\n5. خط أنابيب البيانات:"
echo "   - استخدام بيانات مرمّزة مسبقاً"
echo "   - تفعيل التخزين المؤقت للبيانات"
echo "   - تحميل البيانات بالتوازي"
echo "   - استخدام صيغة بيانات مضغوطة"
```

## الخلاصة

**Microsoft ArchScale** هو إطار عمل متين ومرن للتدريب المسبق على النماذج اللغوية الكبيرة. من خلال المحتوى الوارد في هذا الدليل، يمكن تحقيق النتائج الآتية:

### النتائج الجوهرية

1. **بحث موفّر للتكلفة**: خفض تكاليف ضبط المعاملات الفائقة بنسبة 90% باستخدام تحجيم mu-P++
2. **معمارية قابلة للتوسع**: خط أنابيب تدريب متسق من 110 مليون إلى مليارات المعاملات
3. **دعم السياق الطويل**: تدريب فعّال يصل إلى 128 ألف رمز
4. **تقييم شامل**: تقييم متعدد الأبعاد للأداء عبر معايير RULER وPhonebook والاستدلال

### نقاط التطبيق العملي

- **الشركات الناشئة**: بحث فعّال في النماذج بموارد محدودة
- **المؤسسات البحثية**: تجارب معمارية متنوعة وبحث في قوانين التحجيم
- **الشركات**: تدريب مسبق فعّال على النماذج المخصصة للمجال
- **المطورون**: بناء أنظمة إنتاجية باستخدام أحدث تقنيات النماذج اللغوية الكبيرة

### الخطوات التالية

1. **تجارب صغيرة النطاق**: البدء بـ 8 وحدات GPU والتحقق من تحجيم mu-P++
2. **استكشاف المعماريات**: مقارنة SambaY وMamba وغيرها من المعماريات
3. **تحسين الإنتاج**: تحسين التقديم عبر vLLM والتكميم
4. **المساهمة في المجتمع**: المساهمة بالتحسينات في [ArchScale GitHub](https://github.com/microsoft/ArchScale)

يمنحك ArchScale الأدوات اللازمة لتطوير نموذجك اللغوي من الجيل التالي بكفاءة.

---

**المراجع**:
- [Microsoft ArchScale GitHub](https://github.com/microsoft/ArchScale)
- [ورقة mu-P++](https://arxiv.org/abs/2507.06607)
- [ورقة Flash Attention](https://arxiv.org/abs/2205.14135)
- [معيار RULER](https://arxiv.org/abs/2404.06654)
