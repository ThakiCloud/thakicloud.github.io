---
title: "LiYing: 오픈소스 AI 어시스턴트 플랫폼 완전 구축 가이드"
excerpt: "다국어 지원 AI 어시스턴트 플랫폼 LiYing의 설치부터 커스터마이징까지! 음성 인식, 자연어 처리, 작업 자동화를 통합한 지능형 어시스턴트 구축 방법"
seo_title: "LiYing AI 어시스턴트 플랫폼 완전 설정 가이드 - Thaki Cloud"
seo_description: "오픈소스 LiYing AI 어시스턴트 플랫폼 구축 방법. 음성 인식, NLP, 작업 자동화, 플러그인 시스템을 활용한 맞춤형 AI 어시스턴트 개발 가이드"
date: 2025-08-05
last_modified_at: 2025-08-05
categories:
  - tutorials
tags:
  - liying
  - ai-assistant
  - natural-language-processing
  - voice-recognition
  - automation
  - python
  - machine-learning
  - chatbot
  - open-source
  - nlp
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/liying-ai-assistant-platform-setup-guide/"
reading_time: true
published: false
---

⏱️ **예상 읽기 시간**: 19분

## 서론

현대의 디지털 워크플로우에서 **AI 어시스턴트**는 필수적인 도구가 되었습니다. 하지만 기존의 상용 솔루션들은 데이터 프라이버시 문제, 높은 비용, 제한적인 커스터마이징 등의 한계가 있었습니다. 특히 **기업 내부 정보**나 **민감한 데이터**를 다루는 환경에서는 외부 AI 서비스 사용이 제약되는 경우가 많습니다.

[LiYing](https://github.com/aoguai/LiYing)은 이런 문제를 해결하는 **오픈소스 AI 어시스턴트 플랫폼**입니다. **Python 기반**으로 구축되어 있으며, **모듈식 아키텍처**를 통해 필요한 기능만 선택적으로 구성할 수 있습니다. **온프레미스 배포**를 지원하여 데이터 보안을 보장하면서도, **플러그인 시스템**을 통해 무한히 확장 가능한 AI 어시스턴트를 구축할 수 있습니다.

이번 가이드에서는 LiYing의 설치부터 고급 커스터마이징까지, 실무에서 활용할 수 있는 완전한 AI 어시스턴트 구축 방법을 다루겠습니다.

## LiYing 핵심 기능

### 🧠 지능형 대화 시스템

LiYing은 **고급 자연어 처리(NLP)**를 통해 자연스러운 대화가 가능합니다.

#### 대화 엔진 아키텍처
```python
# core/conversation/engine.py
class ConversationEngine:
    def __init__(self, config):
        self.config = config
        self.nlp_processor = NLPProcessor(config.nlp)
        self.intent_classifier = IntentClassifier(config.intents)
        self.entity_extractor = EntityExtractor(config.entities)
        self.response_generator = ResponseGenerator(config.responses)
        self.context_manager = ContextManager()
    
    async def process_message(self, user_input, session_id):
        """사용자 메시지 처리"""
        
        # 1. 텍스트 전처리
        cleaned_input = self.nlp_processor.preprocess(user_input)
        
        # 2. 의도 분류
        intent = await self.intent_classifier.classify(cleaned_input)
        
        # 3. 개체명 추출
        entities = await self.entity_extractor.extract(cleaned_input)
        
        # 4. 컨텍스트 업데이트
        context = self.context_manager.update_context(
            session_id, intent, entities
        )
        
        # 5. 응답 생성
        response = await self.response_generator.generate(
            intent, entities, context
        )
        
        return {
            'intent': intent,
            'entities': entities,
            'response': response,
            'context': context,
            'confidence': intent.confidence
        }
```

#### 다국어 지원 시스템
```python
# core/i18n/language_manager.py
class LanguageManager:
    def __init__(self):
        self.supported_languages = {
            'ko': '한국어',
            'en': 'English',
            'zh': '中文',
            'ja': '日本語',
            'es': 'Español',
            'fr': 'Français',
            'de': 'Deutsch'
        }
        self.language_models = {}
        self.load_language_models()
    
    def detect_language(self, text):
        """언어 자동 감지"""
        from langdetect import detect, detect_langs
        
        try:
            detected = detect(text)
            confidence_scores = detect_langs(text)
            
            return {
                'language': detected,
                'confidence': max([lang.prob for lang in confidence_scores]),
                'alternatives': [
                    {'lang': lang.lang, 'prob': lang.prob} 
                    for lang in confidence_scores[:3]
                ]
            }
        except:
            return {'language': 'en', 'confidence': 0.5, 'alternatives': []}
    
    def translate_response(self, text, target_language):
        """응답 번역"""
        if target_language not in self.supported_languages:
            return text
        
        # 번역 서비스 연동 (Google Translate, DeepL, 등)
        translated = self.translation_service.translate(
            text, target_language
        )
        
        return translated
```

### 🎤 음성 인식 및 합성

**실시간 음성 처리**로 핸즈프리 상호작용이 가능합니다.

#### 음성 인식 엔진
```python
# modules/speech/recognition.py
import speech_recognition as sr
import pyaudio
import wave
import asyncio

class SpeechRecognitionEngine:
    def __init__(self, config):
        self.config = config
        self.recognizer = sr.Recognizer()
        self.microphone = sr.Microphone()
        self.setup_microphone()
    
    def setup_microphone(self):
        """마이크 설정 최적화"""
        with self.microphone as source:
            # 주변 소음 수준 조정
            self.recognizer.adjust_for_ambient_noise(source, duration=1)
            
        # 인식 파라미터 조정
        self.recognizer.energy_threshold = 300
        self.recognizer.dynamic_energy_threshold = True
        self.recognizer.pause_threshold = 0.8
        self.recognizer.phrase_threshold = 0.3
        self.recognizer.non_speaking_duration = 0.8
    
    async def listen_continuously(self, callback):
        """연속 음성 인식"""
        def audio_callback(recognizer, audio):
            try:
                # 백그라운드에서 음성 인식 처리
                asyncio.create_task(self.process_audio(audio, callback))
            except Exception as e:
                print(f"음성 인식 오류: {e}")
        
        # 백그라운드 리스닝 시작
        stop_listening = self.recognizer.listen_in_background(
            self.microphone, audio_callback, phrase_time_limit=5
        )
        
        return stop_listening
    
    async def process_audio(self, audio, callback):
        """음성 데이터 처리"""
        try:
            # 여러 STT 엔진 병렬 처리
            recognition_results = await asyncio.gather(
                self.recognize_with_google(audio),
                self.recognize_with_whisper(audio),
                self.recognize_with_wav2vec2(audio),
                return_exceptions=True
            )
            
            # 최고 신뢰도 결과 선택
            best_result = self.select_best_recognition(recognition_results)
            
            if best_result and best_result['confidence'] > 0.7:
                await callback(best_result)
                
        except Exception as e:
            print(f"음성 처리 오류: {e}")
    
    async def recognize_with_whisper(self, audio):
        """OpenAI Whisper 음성 인식"""
        import whisper
        
        # 음성 데이터를 임시 파일로 저장
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp_file:
            tmp_file.write(audio.get_wav_data())
            tmp_file_path = tmp_file.name
        
        try:
            # Whisper 모델 로드 (캐시됨)
            model = whisper.load_model("base")
            
            # 음성 인식 실행
            result = model.transcribe(tmp_file_path, language='ko')
            
            return {
                'text': result['text'].strip(),
                'confidence': 0.9,  # Whisper는 신뢰도 점수를 제공하지 않음
                'engine': 'whisper'
            }
        finally:
            os.unlink(tmp_file_path)
```

#### 음성 합성 시스템
```python
# modules/speech/synthesis.py
import pyttsx3
import asyncio
from gtts import gTTS
import pygame

class TextToSpeechEngine:
    def __init__(self, config):
        self.config = config
        self.tts_engine = pyttsx3.init()
        self.setup_voice()
        pygame.mixer.init()
    
    def setup_voice(self):
        """음성 설정"""
        voices = self.tts_engine.getProperty('voices')
        
        # 한국어 음성 찾기
        korean_voice = None
        for voice in voices:
            if 'korean' in voice.name.lower() or 'ko' in voice.id.lower():
                korean_voice = voice
                break
        
        if korean_voice:
            self.tts_engine.setProperty('voice', korean_voice.id)
        
        # 음성 속도 및 볼륨 설정
        self.tts_engine.setProperty('rate', self.config.speech_rate or 200)
        self.tts_engine.setProperty('volume', self.config.speech_volume or 0.9)
    
    async def speak(self, text, language='ko'):
        """텍스트 음성 변환 및 재생"""
        if self.config.use_online_tts:
            await self.speak_with_gtts(text, language)
        else:
            await self.speak_with_pyttsx3(text)
    
    async def speak_with_gtts(self, text, language='ko'):
        """Google TTS 사용"""
        try:
            tts = gTTS(text=text, lang=language, slow=False)
            
            with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as tmp_file:
                tts.save(tmp_file.name)
                
                # 오디오 재생
                pygame.mixer.music.load(tmp_file.name)
                pygame.mixer.music.play()
                
                # 재생 완료까지 대기
                while pygame.mixer.music.get_busy():
                    await asyncio.sleep(0.1)
                
                os.unlink(tmp_file.name)
                
        except Exception as e:
            print(f"TTS 오류: {e}")
            # 폴백으로 로컬 TTS 사용
            await self.speak_with_pyttsx3(text)
    
    async def speak_with_pyttsx3(self, text):
        """로컬 TTS 엔진 사용"""
        def speak_sync():
            self.tts_engine.say(text)
            self.tts_engine.runAndWait()
        
        # 비동기로 음성 출력
        await asyncio.get_event_loop().run_in_executor(None, speak_sync)
```

### 🔧 플러그인 시스템

**확장 가능한 아키텍처**로 무한한 기능 추가가 가능합니다.

#### 플러그인 매니저
```python
# core/plugins/manager.py
import importlib
import inspect
from typing import Dict, List, Any

class PluginManager:
    def __init__(self, config):
        self.config = config
        self.plugins: Dict[str, Any] = {}
        self.plugin_hooks: Dict[str, List[callable]] = {}
        self.load_plugins()
    
    def load_plugins(self):
        """플러그인 자동 로드"""
        plugin_dir = self.config.plugin_directory
        
        for plugin_file in os.listdir(plugin_dir):
            if plugin_file.endswith('.py') and not plugin_file.startswith('_'):
                plugin_name = plugin_file[:-3]
                self.load_plugin(plugin_name)
    
    def load_plugin(self, plugin_name):
        """개별 플러그인 로드"""
        try:
            # 플러그인 모듈 동적 import
            plugin_module = importlib.import_module(f'plugins.{plugin_name}')
            
            # 플러그인 클래스 찾기
            for name, obj in inspect.getmembers(plugin_module):
                if (inspect.isclass(obj) and 
                    hasattr(obj, 'plugin_info') and
                    obj != BasePlugin):
                    
                    # 플러그인 인스턴스 생성
                    plugin_instance = obj(self.config)
                    self.plugins[plugin_name] = plugin_instance
                    
                    # 훅 등록
                    self.register_plugin_hooks(plugin_instance)
                    
                    print(f"✅ 플러그인 로드됨: {plugin_name}")
                    break
                    
        except Exception as e:
            print(f"❌ 플러그인 로드 실패 ({plugin_name}): {e}")
    
    def register_plugin_hooks(self, plugin):
        """플러그인 훅 등록"""
        plugin_info = plugin.plugin_info
        
        for hook_name in plugin_info.get('hooks', []):
            if hook_name not in self.plugin_hooks:
                self.plugin_hooks[hook_name] = []
            
            hook_method = getattr(plugin, f'on_{hook_name}', None)
            if hook_method:
                self.plugin_hooks[hook_name].append(hook_method)
    
    async def execute_hook(self, hook_name, *args, **kwargs):
        """훅 실행"""
        results = []
        
        if hook_name in self.plugin_hooks:
            for hook_method in self.plugin_hooks[hook_name]:
                try:
                    result = await hook_method(*args, **kwargs)
                    results.append(result)
                except Exception as e:
                    print(f"훅 실행 오류 ({hook_name}): {e}")
        
        return results

# 기본 플러그인 클래스
class BasePlugin:
    plugin_info = {
        'name': 'Base Plugin',
        'version': '1.0.0',
        'description': 'Base plugin class',
        'hooks': []
    }
    
    def __init__(self, config):
        self.config = config
    
    async def initialize(self):
        """플러그인 초기화"""
        pass
    
    async def cleanup(self):
        """플러그인 정리"""
        pass
```

## 설치 및 환경 구성

### 1. 시스템 요구사항

#### 하드웨어 권장 사양
```bash
# 최소 사양
CPU: 2코어 이상
RAM: 4GB 이상
Storage: 10GB 이상

# 권장 사양 (음성 처리 포함)
CPU: 4코어 이상 (또는 GPU 지원)
RAM: 8GB 이상
Storage: 20GB 이상 (모델 캐시 포함)
GPU: NVIDIA GPU (CUDA 지원) - 선택사항
```

#### 소프트웨어 요구사항
```bash
# Python 버전
Python 3.8+ (3.9+ 권장)

# 운영체제
Ubuntu 20.04+ / macOS 10.15+ / Windows 10+

# 시스템 의존성 확인
python --version
pip --version
git --version
```

### 2. 기본 설치

#### 저장소 클론 및 의존성 설치
```bash
# 프로젝트 클론
git clone https://github.com/aoguai/LiYing.git
cd LiYing

# Python 가상환경 생성
python -m venv liying-env

# 가상환경 활성화
# macOS/Linux:
source liying-env/bin/activate
# Windows:
# liying-env\Scripts\activate

# 의존성 설치
pip install --upgrade pip
pip install -r requirements.txt

# 개발 도구 설치 (선택사항)
pip install -r requirements-dev.txt
```

#### 시스템 의존성 설치 (Ubuntu/Debian)
```bash
# 음성 처리 관련 라이브러리
sudo apt update
sudo apt install -y \
    portaudio19-dev \
    python3-pyaudio \
    espeak espeak-data \
    libespeak1 libespeak-dev \
    festival festvox-kallpc16k \
    alsa-utils pulseaudio

# FFmpeg (음성/비디오 처리)
sudo apt install -y ffmpeg

# 기타 유틸리티
sudo apt install -y \
    build-essential \
    python3-dev \
    libffi-dev \
    libssl-dev
```

#### macOS 의존성 설치
```bash
# Homebrew 사용
brew install portaudio
brew install espeak
brew install ffmpeg

# PyAudio 설치 (macOS 특별 처리)
pip install --global-option='build_ext' \
    --global-option='-I/opt/homebrew/include' \
    --global-option='-L/opt/homebrew/lib' \
    pyaudio
```

### 3. 설정 파일 구성

#### 기본 설정 파일 생성
```yaml
# config/config.yaml
app:
  name: "LiYing Assistant"
  version: "1.0.0"
  debug: true
  log_level: "INFO"

# 다국어 설정
i18n:
  default_language: "ko"
  supported_languages:
    - "ko"
    - "en"
    - "zh"
    - "ja"
  auto_detect: true

# 음성 인식 설정
speech:
  recognition:
    engine: "whisper"  # google, whisper, wav2vec2
    language: "ko"
    timeout: 5
    phrase_time_limit: 5
    energy_threshold: 300
  
  synthesis:
    engine: "gtts"  # gtts, pyttsx3, espeak
    language: "ko"
    rate: 200
    volume: 0.9
    use_online_tts: true

# NLP 설정
nlp:
  model_name: "klue/bert-base"  # 한국어 모델
  max_sequence_length: 512
  batch_size: 32
  cache_dir: "models/cache"

# 대화 설정
conversation:
  max_context_length: 10
  confidence_threshold: 0.7
  response_timeout: 30
  enable_context_memory: true

# 플러그인 설정
plugins:
  directory: "plugins"
  auto_load: true
  enabled_plugins:
    - "weather"
    - "calendar"
    - "timer"
    - "calculator"
    - "web_search"

# 데이터베이스 설정
database:
  type: "sqlite"  # sqlite, postgresql, mysql
  path: "data/liying.db"
  # host: "localhost"
  # port: 5432
  # username: "liying"
  # password: "password"
  # database: "liying"

# 보안 설정
security:
  enable_auth: false
  secret_key: "your-secret-key-here"
  session_timeout: 3600
  rate_limit: 100  # 분당 요청 수

# API 설정
api:
  host: "0.0.0.0"
  port: 8000
  enable_cors: true
  enable_docs: true

# 로깅 설정
logging:
  level: "INFO"
  file: "logs/liying.log"
  max_size: "10MB"
  backup_count: 5
  format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
```

#### 환경별 설정 파일
```bash
# 개발 환경
cp config/config.yaml config/config.dev.yaml

# 프로덕션 환경
cp config/config.yaml config/config.prod.yaml

# 환경변수로 설정 파일 지정
export LIYING_CONFIG=config/config.dev.yaml
```

### 4. 데이터베이스 초기화

#### SQLite 데이터베이스 설정 (기본)
```python
# scripts/init_database.py
import sqlite3
import os

def create_database():
    """데이터베이스 및 기본 테이블 생성"""
    
    # 데이터 디렉토리 생성
    os.makedirs('data', exist_ok=True)
    
    # 데이터베이스 연결
    conn = sqlite3.connect('data/liying.db')
    cursor = conn.cursor()
    
    # 사용자 테이블
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username VARCHAR(50) UNIQUE NOT NULL,
            email VARCHAR(100),
            preferences TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            last_active TIMESTAMP
        )
    ''')
    
    # 대화 세션 테이블
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS conversations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id VARCHAR(100) NOT NULL,
            user_id INTEGER,
            message_type VARCHAR(20) NOT NULL,
            content TEXT NOT NULL,
            intent VARCHAR(50),
            entities TEXT,
            confidence REAL,
            timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    ''')
    
    # 플러그인 설정 테이블
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS plugin_settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            plugin_name VARCHAR(50) NOT NULL,
            user_id INTEGER,
            settings TEXT,
            enabled BOOLEAN DEFAULT 1,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    ''')
    
    # 시스템 로그 테이블
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS system_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            level VARCHAR(20),
            module VARCHAR(50),
            message TEXT,
            metadata TEXT,
            timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # 인덱스 생성
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_conversations_session ON conversations(session_id)')
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_conversations_timestamp ON conversations(timestamp)')
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)')
    
    conn.commit()
    conn.close()
    
    print("✅ 데이터베이스 초기화 완료")

if __name__ == "__main__":
    create_database()
```

```bash
# 데이터베이스 초기화 실행
python scripts/init_database.py
```

## 기본 사용법

### 1. AI 어시스턴트 시작

#### 명령행 인터페이스
```python
# main.py
import asyncio
from core.assistant import LiYingAssistant
from core.config import load_config

async def main():
    """LiYing 어시스턴트 시작"""
    
    # 설정 로드
    config = load_config()
    
    # 어시스턴트 초기화
    assistant = LiYingAssistant(config)
    await assistant.initialize()
    
    print("🤖 LiYing AI 어시스턴트가 시작되었습니다!")
    print("음성으로 말하거나 텍스트를 입력하세요. 'quit'으로 종료합니다.")
    
    # 음성 인식 시작
    if config.speech.recognition.enabled:
        stop_listening = await assistant.start_voice_recognition()
        print("🎤 음성 인식이 활성화되었습니다.")
    
    try:
        # 메인 루프
        while True:
            user_input = input("\n사용자: ")
            
            if user_input.lower() in ['quit', 'exit', '종료']:
                break
            
            if user_input.strip():
                response = await assistant.process_message(user_input)
                print(f"LiYing: {response['text']}")
                
                # 음성 응답
                if config.speech.synthesis.enabled:
                    await assistant.speak(response['text'])
    
    except KeyboardInterrupt:
        print("\n어시스턴트를 종료합니다...")
    
    finally:
        # 정리
        if config.speech.recognition.enabled:
            stop_listening(wait_for_stop=False)
        await assistant.cleanup()

if __name__ == "__main__":
    asyncio.run(main())
```

#### 웹 인터페이스
```python
# web_app.py
from fastapi import FastAPI, WebSocket, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse
import asyncio
import json

app = FastAPI(title="LiYing AI Assistant")

# 정적 파일 서빙
app.mount("/static", StaticFiles(directory="web/static"), name="static")

# 어시스턴트 인스턴스
assistant = None

@app.on_event("startup")
async def startup_event():
    global assistant
    config = load_config()
    assistant = LiYingAssistant(config)
    await assistant.initialize()

@app.get("/", response_class=HTMLResponse)
async def get_home():
    """메인 페이지"""
    with open("web/templates/index.html", "r", encoding="utf-8") as f:
        return HTMLResponse(content=f.read())

@app.post("/api/chat")
async def chat_endpoint(message: dict):
    """채팅 API"""
    user_message = message.get("message", "")
    session_id = message.get("session_id", "default")
    
    if not user_message:
        raise HTTPException(status_code=400, detail="메시지가 비어있습니다")
    
    try:
        response = await assistant.process_message(user_message, session_id)
        return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """실시간 채팅 WebSocket"""
    await websocket.accept()
    session_id = f"ws_{id(websocket)}"
    
    try:
        while True:
            # 클라이언트 메시지 수신
            data = await websocket.receive_text()
            message_data = json.loads(data)
            
            if message_data["type"] == "message":
                user_message = message_data["content"]
                
                # 메시지 처리
                response = await assistant.process_message(user_message, session_id)
                
                # 응답 전송
                await websocket.send_text(json.dumps({
                    "type": "response",
                    "content": response["text"],
                    "intent": response["intent"],
                    "confidence": response["confidence"]
                }))
            
            elif message_data["type"] == "voice_data":
                # 음성 데이터 처리
                audio_data = message_data["audio"]
                text = await assistant.speech_to_text(audio_data)
                
                if text:
                    response = await assistant.process_message(text, session_id)
                    await websocket.send_text(json.dumps({
                        "type": "voice_response",
                        "transcription": text,
                        "response": response["text"]
                    }))
    
    except Exception as e:
        print(f"WebSocket 오류: {e}")
    finally:
        # 연결 정리
        await assistant.cleanup_session(session_id)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
```

### 2. 플러그인 개발

#### 날씨 정보 플러그인
```python
# plugins/weather.py
import aiohttp
import json
from core.plugins.manager import BasePlugin

class WeatherPlugin(BasePlugin):
    plugin_info = {
        'name': 'Weather Plugin',
        'version': '1.0.0',
        'description': '날씨 정보를 제공하는 플러그인',
        'hooks': ['message_processed'],
        'intents': ['weather_query'],
        'entities': ['location', 'date']
    }
    
    def __init__(self, config):
        super().__init__(config)
        self.api_key = config.plugins.weather.api_key
        self.api_url = "https://api.openweathermap.org/data/2.5"
    
    async def on_message_processed(self, intent, entities, context):
        """메시지 처리 후 훅"""
        if intent.name == 'weather_query':
            return await self.get_weather_info(entities)
        return None
    
    async def get_weather_info(self, entities):
        """날씨 정보 조회"""
        location = self.extract_location(entities)
        if not location:
            return {
                'text': '어떤 지역의 날씨를 알고 싶으신가요?',
                'needs_clarification': True
            }
        
        try:
            # OpenWeatherMap API 호출
            async with aiohttp.ClientSession() as session:
                url = f"{self.api_url}/weather"
                params = {
                    'q': location,
                    'appid': self.api_key,
                    'units': 'metric',
                    'lang': 'kr'
                }
                
                async with session.get(url, params=params) as response:
                    if response.status == 200:
                        data = await response.json()
                        return self.format_weather_response(data)
                    else:
                        return {
                            'text': f'{location}의 날씨 정보를 찾을 수 없습니다.',
                            'error': True
                        }
        
        except Exception as e:
            return {
                'text': '날씨 정보를 가져오는 중 오류가 발생했습니다.',
                'error': str(e)
            }
    
    def format_weather_response(self, weather_data):
        """날씨 응답 포맷팅"""
        city = weather_data['name']
        country = weather_data['sys']['country']
        temp = weather_data['main']['temp']
        feels_like = weather_data['main']['feels_like']
        humidity = weather_data['main']['humidity']
        description = weather_data['weather'][0]['description']
        
        response_text = f"""
        {city}, {country}의 현재 날씨입니다:
        
        🌡️ 기온: {temp}°C (체감온도: {feels_like}°C)
        💧 습도: {humidity}%
        ☁️ 날씨: {description}
        """
        
        return {
            'text': response_text.strip(),
            'weather_data': weather_data,
            'success': True
        }
    
    def extract_location(self, entities):
        """엔티티에서 위치 정보 추출"""
        for entity in entities:
            if entity['type'] == 'location':
                return entity['value']
        return None
```

#### 일정 관리 플러그인
```python
# plugins/calendar.py
import datetime
import sqlite3
from core.plugins.manager import BasePlugin

class CalendarPlugin(BasePlugin):
    plugin_info = {
        'name': 'Calendar Plugin',
        'version': '1.0.0',
        'description': '일정 관리 플러그인',
        'hooks': ['message_processed'],
        'intents': ['schedule_create', 'schedule_query', 'schedule_delete'],
        'entities': ['datetime', 'event_title', 'duration']
    }
    
    def __init__(self, config):
        super().__init__(config)
        self.db_path = config.database.path
        self.setup_database()
    
    def setup_database(self):
        """일정 테이블 생성"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS events (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title VARCHAR(200) NOT NULL,
                description TEXT,
                start_time TIMESTAMP NOT NULL,
                end_time TIMESTAMP,
                user_id INTEGER,
                reminder_minutes INTEGER DEFAULT 15,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        conn.commit()
        conn.close()
    
    async def on_message_processed(self, intent, entities, context):
        """메시지 처리 후 훅"""
        if intent.name == 'schedule_create':
            return await self.create_event(entities, context)
        elif intent.name == 'schedule_query':
            return await self.query_events(entities, context)
        elif intent.name == 'schedule_delete':
            return await self.delete_event(entities, context)
        return None
    
    async def create_event(self, entities, context):
        """일정 생성"""
        title = self.extract_entity_value(entities, 'event_title')
        datetime_str = self.extract_entity_value(entities, 'datetime')
        duration = self.extract_entity_value(entities, 'duration') or 60
        
        if not title:
            return {
                'text': '일정의 제목을 알려주세요.',
                'needs_clarification': True
            }
        
        if not datetime_str:
            return {
                'text': '언제 일정을 만드시겠습니까?',
                'needs_clarification': True
            }
        
        try:
            # 날짜/시간 파싱
            start_time = self.parse_datetime(datetime_str)
            end_time = start_time + datetime.timedelta(minutes=int(duration))
            
            # 데이터베이스에 저장
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT INTO events (title, start_time, end_time, user_id)
                VALUES (?, ?, ?, ?)
            ''', (title, start_time, end_time, context.get('user_id', 1)))
            
            event_id = cursor.lastrowid
            conn.commit()
            conn.close()
            
            return {
                'text': f'일정 "{title}"을(를) {start_time.strftime("%Y년 %m월 %d일 %H시 %M분")}에 등록했습니다.',
                'event_id': event_id,
                'success': True
            }
        
        except Exception as e:
            return {
                'text': '일정 생성 중 오류가 발생했습니다.',
                'error': str(e)
            }
    
    async def query_events(self, entities, context):
        """일정 조회"""
        date_filter = self.extract_entity_value(entities, 'datetime')
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        if date_filter:
            # 특정 날짜의 일정
            target_date = self.parse_datetime(date_filter).date()
            cursor.execute('''
                SELECT title, start_time, end_time
                FROM events
                WHERE DATE(start_time) = ?
                ORDER BY start_time
            ''', (target_date,))
        else:
            # 오늘의 일정
            today = datetime.date.today()
            cursor.execute('''
                SELECT title, start_time, end_time
                FROM events
                WHERE DATE(start_time) = ?
                ORDER BY start_time
            ''', (today,))
        
        events = cursor.fetchall()
        conn.close()
        
        if not events:
            return {
                'text': '등록된 일정이 없습니다.',
                'events': []
            }
        
        # 응답 포맷팅
        response_lines = ['오늘의 일정입니다:']
        for title, start_time, end_time in events:
            start_dt = datetime.datetime.fromisoformat(start_time)
            end_dt = datetime.datetime.fromisoformat(end_time) if end_time else None
            
            time_str = start_dt.strftime('%H:%M')
            if end_dt:
                time_str += f' - {end_dt.strftime("%H:%M")}'
            
            response_lines.append(f'• {time_str}: {title}')
        
        return {
            'text': '\n'.join(response_lines),
            'events': events,
            'success': True
        }
    
    def parse_datetime(self, datetime_str):
        """날짜/시간 문자열 파싱"""
        # 간단한 파싱 예제 (실제로는 더 정교한 파싱 필요)
        now = datetime.datetime.now()
        
        if '오늘' in datetime_str:
            base_date = now.date()
        elif '내일' in datetime_str:
            base_date = now.date() + datetime.timedelta(days=1)
        elif '모레' in datetime_str:
            base_date = now.date() + datetime.timedelta(days=2)
        else:
            base_date = now.date()
        
        # 시간 추출 (예: "오후 3시", "15시", "3시 30분")
        import re
        time_match = re.search(r'(\d{1,2})시?\s*(\d{1,2}분?)?', datetime_str)
        
        if time_match:
            hour = int(time_match.group(1))
            minute = int(time_match.group(2).replace('분', '')) if time_match.group(2) else 0
            
            # 오후 처리
            if '오후' in datetime_str and hour < 12:
                hour += 12
        else:
            hour, minute = now.hour, now.minute
        
        return datetime.datetime.combine(base_date, datetime.time(hour, minute))
    
    def extract_entity_value(self, entities, entity_type):
        """특정 타입의 엔티티 값 추출"""
        for entity in entities:
            if entity['type'] == entity_type:
                return entity['value']
        return None
```

## 고급 커스터마이징

### 1. 커스텀 NLP 모델 훈련

#### 의도 분류 모델 훈련
```python
# training/intent_classifier.py
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from transformers import AutoTokenizer, AutoModelForSequenceClassification
from transformers import TrainingArguments, Trainer
import torch

class IntentClassifierTrainer:
    def __init__(self, model_name='klue/bert-base'):
        self.model_name = model_name
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = None
        self.label_to_id = {}
        self.id_to_label = {}
    
    def prepare_data(self, data_path):
        """훈련 데이터 준비"""
        # CSV 파일에서 데이터 로드
        df = pd.read_csv(data_path)
        
        # 라벨 인코딩
        unique_labels = df['intent'].unique()
        self.label_to_id = {label: idx for idx, label in enumerate(unique_labels)}
        self.id_to_label = {idx: label for label, idx in self.label_to_id.items()}
        
        # 데이터 분할
        train_texts, val_texts, train_labels, val_labels = train_test_split(
            df['text'].tolist(),
            df['intent'].tolist(),
            test_size=0.2,
            random_state=42,
            stratify=df['intent']
        )
        
        # 토큰화
        train_encodings = self.tokenizer(
            train_texts, truncation=True, padding=True, max_length=128
        )
        val_encodings = self.tokenizer(
            val_texts, truncation=True, padding=True, max_length=128
        )
        
        # 라벨 ID 변환
        train_label_ids = [self.label_to_id[label] for label in train_labels]
        val_label_ids = [self.label_to_id[label] for label in val_labels]
        
        return (train_encodings, train_label_ids), (val_encodings, val_label_ids)
    
    def create_model(self, num_labels):
        """모델 생성"""
        self.model = AutoModelForSequenceClassification.from_pretrained(
            self.model_name, 
            num_labels=num_labels
        )
    
    def train(self, train_data, val_data, output_dir='models/intent_classifier'):
        """모델 훈련"""
        train_encodings, train_labels = train_data
        val_encodings, val_labels = val_data
        
        # 데이터셋 클래스
        class IntentDataset(torch.utils.data.Dataset):
            def __init__(self, encodings, labels):
                self.encodings = encodings
                self.labels = labels
            
            def __getitem__(self, idx):
                item = {key: torch.tensor(val[idx]) for key, val in self.encodings.items()}
                item['labels'] = torch.tensor(self.labels[idx])
                return item
            
            def __len__(self):
                return len(self.labels)
        
        # 데이터셋 생성
        train_dataset = IntentDataset(train_encodings, train_labels)
        val_dataset = IntentDataset(val_encodings, val_labels)
        
        # 훈련 설정
        training_args = TrainingArguments(
            output_dir=output_dir,
            num_train_epochs=3,
            per_device_train_batch_size=16,
            per_device_eval_batch_size=64,
            warmup_steps=500,
            weight_decay=0.01,
            logging_dir=f'{output_dir}/logs',
            evaluation_strategy='epoch',
            save_strategy='epoch',
            load_best_model_at_end=True,
            metric_for_best_model='eval_loss',
            greater_is_better=False
        )
        
        # 트레이너 생성
        trainer = Trainer(
            model=self.model,
            args=training_args,
            train_dataset=train_dataset,
            eval_dataset=val_dataset,
            tokenizer=self.tokenizer
        )
        
        # 훈련 실행
        trainer.train()
        
        # 모델 저장
        trainer.save_model()
        self.tokenizer.save_pretrained(output_dir)
        
        # 라벨 매핑 저장
        import json
        with open(f'{output_dir}/label_mapping.json', 'w', encoding='utf-8') as f:
            json.dump({
                'label_to_id': self.label_to_id,
                'id_to_label': self.id_to_label
            }, f, ensure_ascii=False, indent=2)
    
    def evaluate(self, test_data):
        """모델 평가"""
        from sklearn.metrics import classification_report, confusion_matrix
        
        test_encodings, test_labels = test_data
        predictions = []
        
        # 배치 단위로 예측
        for i in range(0, len(test_labels), 32):
            batch_texts = test_encodings[i:i+32]
            batch_encodings = self.tokenizer(
                batch_texts, truncation=True, padding=True, 
                max_length=128, return_tensors='pt'
            )
            
            with torch.no_grad():
                outputs = self.model(**batch_encodings)
                batch_predictions = torch.argmax(outputs.logits, dim=-1)
                predictions.extend(batch_predictions.tolist())
        
        # 평가 메트릭 계산
        report = classification_report(
            test_labels, predictions,
            target_names=list(self.label_to_id.keys()),
            output_dict=True
        )
        
        return report

# 사용 예제
def train_intent_model():
    """의도 분류 모델 훈련 예제"""
    
    # 훈련 데이터 예제 (CSV 형식)
    training_data = """
text,intent
안녕하세요,greeting
안녕히 가세요,farewell
오늘 날씨 어때?,weather_query
서울 날씨 알려줘,weather_query
내일 비 올까?,weather_query
일정 추가해줘,schedule_create
오후 3시 회의 등록,schedule_create
오늘 일정 뭐야?,schedule_query
내일 일정 알려줘,schedule_query
타이머 5분 설정,timer_set
알람 8시에 맞춰줘,alarm_set
계산해줘 123 곱하기 456,calculation
몇 시야?,time_query
지금 몇 시?,time_query
"""
    
    # 임시 데이터 파일 생성
    with open('training_data.csv', 'w', encoding='utf-8') as f:
        f.write(training_data.strip())
    
    # 트레이너 초기화
    trainer = IntentClassifierTrainer()
    
    # 데이터 준비
    train_data, val_data = trainer.prepare_data('training_data.csv')
    
    # 모델 생성
    num_labels = len(trainer.label_to_id)
    trainer.create_model(num_labels)
    
    # 훈련 실행
    trainer.train(train_data, val_data)
    
    print("✅ 의도 분류 모델 훈련 완료")

if __name__ == "__main__":
    train_intent_model()
```

### 2. 실시간 대화 개선

#### 컨텍스트 메모리 시스템
```python
# core/memory/context_manager.py
import json
import datetime
from typing import Dict, List, Any

class ContextManager:
    def __init__(self, max_context_length=10):
        self.max_context_length = max_context_length
        self.user_contexts: Dict[str, List[Dict]] = {}
        self.global_context: Dict[str, Any] = {}
    
    def update_context(self, session_id: str, intent: Dict, entities: List[Dict], response: str):
        """컨텍스트 업데이트"""
        
        if session_id not in self.user_contexts:
            self.user_contexts[session_id] = []
        
        context_item = {
            'timestamp': datetime.datetime.now().isoformat(),
            'intent': intent,
            'entities': entities,
            'response': response,
            'turn_id': len(self.user_contexts[session_id]) + 1
        }
        
        # 컨텍스트 추가
        self.user_contexts[session_id].append(context_item)
        
        # 최대 길이 유지
        if len(self.user_contexts[session_id]) > self.max_context_length:
            self.user_contexts[session_id] = self.user_contexts[session_id][-self.max_context_length:]
        
        # 글로벌 컨텍스트 업데이트
        self.update_global_context(intent, entities)
        
        return self.get_context(session_id)
    
    def get_context(self, session_id: str) -> Dict:
        """현재 컨텍스트 조회"""
        user_context = self.user_contexts.get(session_id, [])
        
        # 최근 대화에서 중요한 정보 추출
        recent_entities = self.extract_recent_entities(user_context)
        conversation_topic = self.infer_conversation_topic(user_context)
        user_preferences = self.extract_user_preferences(user_context)
        
        return {
            'session_id': session_id,
            'conversation_history': user_context,
            'recent_entities': recent_entities,
            'conversation_topic': conversation_topic,
            'user_preferences': user_preferences,
            'global_context': self.global_context,
            'context_length': len(user_context)
        }
    
    def extract_recent_entities(self, context_history: List[Dict]) -> Dict:
        """최근 언급된 엔티티 추출"""
        entity_tracker = {}
        
        # 최근 3턴의 대화에서 엔티티 추출
        recent_turns = context_history[-3:] if len(context_history) >= 3 else context_history
        
        for turn in recent_turns:
            for entity in turn.get('entities', []):
                entity_type = entity['type']
                entity_value = entity['value']
                
                if entity_type not in entity_tracker:
                    entity_tracker[entity_type] = []
                
                # 중복 제거 및 최신 값 우선
                if entity_value not in [e['value'] for e in entity_tracker[entity_type]]:
                    entity_tracker[entity_type].append({
                        'value': entity_value,
                        'confidence': entity.get('confidence', 1.0),
                        'turn_id': turn['turn_id']
                    })
        
        return entity_tracker
    
    def infer_conversation_topic(self, context_history: List[Dict]) -> str:
        """대화 주제 추론"""
        if not context_history:
            return 'general'
        
        # 최근 의도들을 분석하여 주제 추론
        recent_intents = [turn['intent']['name'] for turn in context_history[-5:]]
        
        topic_mapping = {
            'weather': ['weather_query', 'weather_forecast'],
            'schedule': ['schedule_create', 'schedule_query', 'schedule_delete'],
            'timer': ['timer_set', 'timer_cancel', 'alarm_set'],
            'calculation': ['calculation', 'math_operation'],
            'general': ['greeting', 'farewell', 'thanks', 'help']
        }
        
        topic_scores = {}
        for topic, intents in topic_mapping.items():
            score = sum(1 for intent in recent_intents if intent in intents)
            topic_scores[topic] = score
        
        # 가장 점수가 높은 주제 반환
        return max(topic_scores, key=topic_scores.get) if topic_scores else 'general'
    
    def extract_user_preferences(self, context_history: List[Dict]) -> Dict:
        """사용자 선호도 추출"""
        preferences = {
            'preferred_language': 'ko',
            'time_format': '24h',
            'location': None,
            'reminder_preferences': {},
            'communication_style': 'formal'
        }
        
        # 컨텍스트에서 선호도 패턴 분석
        for turn in context_history:
            entities = turn.get('entities', [])
            
            # 위치 선호도
            for entity in entities:
                if entity['type'] == 'location':
                    preferences['location'] = entity['value']
            
            # 언어 패턴 분석 (비격식체 사용 여부)
            response_text = turn.get('response', '')
            if any(pattern in response_text for pattern in ['ㅋㅋ', '~', '♪']):
                preferences['communication_style'] = 'casual'
        
        return preferences
    
    def should_clarify(self, intent: Dict, entities: List[Dict], context: Dict) -> bool:
        """추가 명확화가 필요한지 판단"""
        
        # 의도 신뢰도가 낮은 경우
        if intent.get('confidence', 0) < 0.7:
            return True
        
        # 필수 엔티티가 누락된 경우
        required_entities = self.get_required_entities(intent['name'])
        present_entities = [e['type'] for e in entities]
        
        missing_entities = set(required_entities) - set(present_entities)
        if missing_entities:
            return True
        
        # 모호한 참조가 있는 경우
        if self.has_ambiguous_references(entities, context):
            return True
        
        return False
    
    def get_required_entities(self, intent_name: str) -> List[str]:
        """의도별 필수 엔티티 정의"""
        requirements = {
            'weather_query': ['location'],
            'schedule_create': ['datetime', 'event_title'],
            'timer_set': ['duration'],
            'alarm_set': ['datetime'],
            'calculation': ['expression']
        }
        
        return requirements.get(intent_name, [])
    
    def has_ambiguous_references(self, entities: List[Dict], context: Dict) -> bool:
        """모호한 참조 존재 여부 확인"""
        # 예: "그것", "저기", "아까 말한" 등의 지시어 처리
        ambiguous_patterns = ['그것', '저것', '여기', '저기', '아까', '방금']
        
        for entity in entities:
            if any(pattern in entity['value'] for pattern in ambiguous_patterns):
                return True
        
        return False
```

### 3. 성능 모니터링 및 최적화

#### 성능 모니터링 시스템
```python
# core/monitoring/performance_monitor.py
import time
import psutil
import asyncio
from collections import defaultdict, deque
import logging

class PerformanceMonitor:
    def __init__(self, config):
        self.config = config
        self.metrics = defaultdict(deque)
        self.logger = logging.getLogger(__name__)
        self.alert_thresholds = {
            'response_time': 5.0,  # 초
            'memory_usage': 80.0,   # %
            'cpu_usage': 80.0,      # %
            'error_rate': 5.0       # %
        }
    
    async def start_monitoring(self):
        """모니터링 시작"""
        asyncio.create_task(self.collect_system_metrics())
        asyncio.create_task(self.analyze_performance())
    
    async def collect_system_metrics(self):
        """시스템 메트릭 수집"""
        while True:
            try:
                # CPU 사용률
                cpu_percent = psutil.cpu_percent(interval=1)
                self.record_metric('cpu_usage', cpu_percent)
                
                # 메모리 사용률
                memory = psutil.virtual_memory()
                self.record_metric('memory_usage', memory.percent)
                
                # 디스크 사용률
                disk = psutil.disk_usage('/')
                self.record_metric('disk_usage', disk.percent)
                
                # 네트워크 I/O
                network = psutil.net_io_counters()
                self.record_metric('network_bytes_sent', network.bytes_sent)
                self.record_metric('network_bytes_recv', network.bytes_recv)
                
                await asyncio.sleep(10)  # 10초마다 수집
                
            except Exception as e:
                self.logger.error(f"시스템 메트릭 수집 오류: {e}")
                await asyncio.sleep(10)
    
    def record_metric(self, metric_name: str, value: float):
        """메트릭 기록"""
        timestamp = time.time()
        
        # 최대 1000개 데이터 포인트 유지
        if len(self.metrics[metric_name]) >= 1000:
            self.metrics[metric_name].popleft()
        
        self.metrics[metric_name].append({
            'timestamp': timestamp,
            'value': value
        })
        
        # 임계값 초과 시 알림
        if value > self.alert_thresholds.get(metric_name, float('inf')):
            self.send_alert(metric_name, value)
    
    def measure_execution_time(self, func_name: str):
        """실행 시간 측정 데코레이터"""
        def decorator(func):
            async def wrapper(*args, **kwargs):
                start_time = time.time()
                try:
                    result = await func(*args, **kwargs)
                    execution_time = time.time() - start_time
                    self.record_metric(f'{func_name}_execution_time', execution_time)
                    return result
                except Exception as e:
                    execution_time = time.time() - start_time
                    self.record_metric(f'{func_name}_execution_time', execution_time)
                    self.record_metric(f'{func_name}_error', 1)
                    raise
            return wrapper
        return decorator
    
    async def analyze_performance(self):
        """성능 분석 및 최적화 제안"""
        while True:
            try:
                await asyncio.sleep(60)  # 1분마다 분석
                
                analysis = self.generate_performance_report()
                
                if analysis['issues']:
                    self.logger.warning(f"성능 이슈 감지: {analysis['issues']}")
                    
                    # 자동 최적화 시도
                    await self.auto_optimize(analysis)
                
            except Exception as e:
                self.logger.error(f"성능 분석 오류: {e}")
    
    def generate_performance_report(self) -> Dict:
        """성능 리포트 생성"""
        current_time = time.time()
        last_hour = current_time - 3600  # 지난 1시간
        
        report = {
            'timestamp': current_time,
            'metrics': {},
            'issues': [],
            'recommendations': []
        }
        
        for metric_name, data_points in self.metrics.items():
            recent_data = [
                dp for dp in data_points 
                if dp['timestamp'] >= last_hour
            ]
            
            if recent_data:
                values = [dp['value'] for dp in recent_data]
                report['metrics'][metric_name] = {
                    'avg': sum(values) / len(values),
                    'max': max(values),
                    'min': min(values),
                    'count': len(values)
                }
                
                # 이슈 감지
                avg_value = report['metrics'][metric_name]['avg']
                threshold = self.alert_thresholds.get(metric_name)
                
                if threshold and avg_value > threshold:
                    report['issues'].append(f'{metric_name} 평균값 임계값 초과: {avg_value:.2f}')
        
        # 최적화 권장사항 생성
        report['recommendations'] = self.generate_recommendations(report['metrics'])
        
        return report
    
    def generate_recommendations(self, metrics: Dict) -> List[str]:
        """최적화 권장사항 생성"""
        recommendations = []
        
        # CPU 사용률 최적화
        if 'cpu_usage' in metrics and metrics['cpu_usage']['avg'] > 70:
            recommendations.append('CPU 사용률이 높습니다. 비동기 처리를 늘리거나 워커 프로세스를 추가하세요.')
        
        # 메모리 사용률 최적화
        if 'memory_usage' in metrics and metrics['memory_usage']['avg'] > 75:
            recommendations.append('메모리 사용률이 높습니다. 캐시 크기를 줄이거나 가비지 컬렉션을 최적화하세요.')
        
        # 응답 시간 최적화
        if 'response_time' in metrics and metrics['response_time']['avg'] > 3:
            recommendations.append('응답 시간이 느립니다. 데이터베이스 쿼리나 외부 API 호출을 최적화하세요.')
        
        return recommendations
    
    async def auto_optimize(self, analysis: Dict):
        """자동 최적화 수행"""
        metrics = analysis['metrics']
        
        # 메모리 정리
        if 'memory_usage' in metrics and metrics['memory_usage']['avg'] > 80:
            import gc
            gc.collect()
            self.logger.info("자동 가비지 컬렉션 수행됨")
        
        # 캐시 정리
        if hasattr(self, 'cache_manager'):
            await self.cache_manager.cleanup_old_entries()
            self.logger.info("캐시 정리 수행됨")
    
    def send_alert(self, metric_name: str, value: float):
        """알림 발송"""
        message = f"⚠️ {metric_name} 임계값 초과: {value:.2f}"
        
        # 로그 기록
        self.logger.warning(message)
        
        # 이메일/슬랙 알림 (설정된 경우)
        if self.config.alerts.email_enabled:
            asyncio.create_task(self.send_email_alert(message))
        
        if self.config.alerts.slack_enabled:
            asyncio.create_task(self.send_slack_alert(message))
    
    def get_metrics_dashboard_data(self) -> Dict:
        """대시보드용 메트릭 데이터"""
        dashboard_data = {}
        
        for metric_name, data_points in self.metrics.items():
            if data_points:
                latest_data = list(data_points)[-100:]  # 최근 100개
                dashboard_data[metric_name] = {
                    'timestamps': [dp['timestamp'] for dp in latest_data],
                    'values': [dp['value'] for dp in latest_data],
                    'current': latest_data[-1]['value'] if latest_data else 0
                }
        
        return dashboard_data
```

## 결론

LiYing은 **프라이버시와 커스터마이징을 모두 만족**하는 차세대 AI 어시스턴트 플랫폼입니다. 오픈소스의 투명성과 온프레미스 배포의 보안성을 결합하여, 기업과 개인 모두에게 **완전히 제어 가능한 AI 솔루션**을 제공합니다.

### 🎯 핵심 가치

1. **데이터 주권**: 모든 데이터가 내부에서 처리되어 완전한 프라이버시 보장
2. **무한 확장성**: 플러그인 시스템으로 어떤 기능이든 추가 가능
3. **다국어 지원**: 글로벌 환경에서도 자연스러운 의사소통
4. **실시간 학습**: 사용할수록 더 정확해지는 적응형 AI

### 🚀 활용 분야

- **기업 환경**: 내부 업무 자동화, 직원 지원, 데이터 분석
- **개발팀**: 코드 리뷰, 문서화, 프로젝트 관리 지원
- **교육 기관**: 맞춤형 학습 지원, 질의응답 시스템
- **의료 기관**: 환자 상담, 의료 정보 검색 (규정 준수)

### 💡 혁신 포인트

1. **모듈식 아키텍처**: 필요한 기능만 선택적 구성
2. **실시간 컨텍스트**: 대화 흐름을 기억하는 지능형 메모리
3. **멀티모달 지원**: 텍스트, 음성, 이미지 통합 처리
4. **성능 최적화**: 실시간 모니터링과 자동 튜닝

### 🔮 미래 발전 방향

- **엣지 컴퓨팅**: 더욱 빠른 로컬 처리를 위한 경량화
- **연합 학습**: 개인정보 보호하면서 집단 지능 향상
- **AR/VR 통합**: 몰입형 환경에서의 AI 어시스턴트
- **IoT 연동**: 스마트 홈/오피스와의 완전한 통합

LiYing을 통해 **진정한 의미의 개인화된 AI 어시스턴트**를 구축하고, **데이터 주권을 지키면서도 최첨단 AI 기술**의 혜택을 누려보시기 바랍니다. 오픈소스 AI의 무한한 가능성을 경험하시길 바랍니다! 🤖🚀✨

---

> **참고 자료**
> - [LiYing GitHub Repository](https://github.com/aoguai/LiYing)
> - [Python 비동기 프로그래밍 가이드](https://docs.python.org/3/library/asyncio.html)
> - [Transformers 라이브러리 문서](https://huggingface.co/docs/transformers)
> - [FastAPI 공식 문서](https://fastapi.tiangolo.com)