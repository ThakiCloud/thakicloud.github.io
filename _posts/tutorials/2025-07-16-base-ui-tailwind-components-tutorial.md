---
title: "Base UI + Tailwind CSS 활용 예제 완전 가이드 - 실전 컴포넌트 구축"
excerpt: "Base UI와 Tailwind CSS를 활용해 실제 프로젝트에서 바로 사용할 수 있는 고품질 React 컴포넌트를 만드는 완전한 실전 가이드"
seo_title: "Base UI Tailwind CSS React 컴포넌트 활용 예제 튜토리얼 - Thaki Cloud"
seo_description: "Base UI와 Tailwind CSS로 Media Player, Dashboard, Form 등 실제 프로젝트에 바로 적용 가능한 React 컴포넌트 구축 방법과 예제 코드 완전 가이드"
date: 2025-07-16
last_modified_at: 2025-07-16
categories:
  - tutorials
tags:
  - base-ui
  - tailwind-css
  - react
  - ui-components
  - frontend
  - headless-ui
  - typescript
  - shadcn
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/base-ui-tailwind-components-tutorial/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 12분

## 서론

**주의**: 요청하신 `borabaloglu/9ui` 리포지토리를 찾을 수 없어, 대신 Base UI와 Tailwind CSS를 활용한 유사한 접근 방식의 실전 튜토리얼을 제공합니다.

Base UI는 MUI에서 개발한 headless React 컴포넌트 라이브러리로, Tailwind CSS와 완벽하게 조합하여 커스터마이징 가능한 고품질 UI 컴포넌트를 만들 수 있습니다. 이 튜토리얼에서는 실제 프로젝트에서 바로 활용할 수 있는 실전 예제들을 단계별로 구축해보겠습니다.

### 왜 Base UI + Tailwind CSS인가?

- **🎨 완전한 디자인 자유도**: Material Design에 제약받지 않는 커스터마이징
- **♿ 접근성 내장**: WAI-ARIA 표준 완벽 지원
- **🚀 성능 최적화**: Tree-shaking으로 필요한 컴포넌트만 번들에 포함
- **🔧 개발자 경험**: TypeScript 완벽 지원 및 친숙한 API
- **💎 프로덕션 검증**: MUI 팀이 실제 프로덕션에서 사용

## 환경 설정

### 1. 프로젝트 초기 설정

```bash
# React 프로젝트 생성
npx create-react-app base-ui-tutorial --template typescript
cd base-ui-tutorial

# 필수 패키지 설치
npm install @base-ui-components/react
npm install -D tailwindcss postcss autoprefixer
npm install clsx

# Tailwind CSS 초기화
npx tailwindcss init -p
```

### 2. Tailwind CSS 설정

```javascript
// tailwind.config.js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        }
      }
    },
  },
  plugins: [],
}
```

```css
/* src/index.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  html {
    font-family: 'Inter', system-ui, sans-serif;
  }
}
```

### 3. 포털 설정

```css
/* src/index.css에 추가 */
.app-root {
  isolation: isolate;
}
```

```jsx
// src/index.tsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);
root.render(
  <React.StrictMode>
    <div className="app-root">
      <App />
    </div>
  </React.StrictMode>
);
```

## 실전 예제 1: 인터랙티브 미디어 플레이어

### 커스텀 슬라이더 컴포넌트

```tsx
// src/components/Slider.tsx
import * as React from 'react';
import { Slider as BaseSlider, SliderProps } from '@base-ui-components/react/slider';
import { clsx } from 'clsx';

interface CustomSliderProps extends SliderProps {
  label?: string;
}

const Slider = React.forwardRef<HTMLSpanElement, CustomSliderProps>(
  function Slider(props, ref) {
    const { label, className, ...other } = props;

    return (
      <BaseSlider
        {...other}
        ref={ref}
        className={clsx('relative inline-block w-full h-2 cursor-pointer', className)}
        render={(sliderProps) => (
          <span {...sliderProps}>
            {/* Rail */}
            <span className="absolute w-full h-2 bg-gray-200 dark:bg-gray-700 rounded-full" />
            
            {/* Track */}
            <span 
              className="absolute h-2 bg-blue-500 dark:bg-blue-400 rounded-full"
              style={{ width: `${((sliderProps['aria-valuenow'] as number || 0) / (sliderProps['aria-valuemax'] as number || 100)) * 100}%` }}
            />
            
            {/* Thumb */}
            <span 
              className="absolute w-4 h-4 -mt-1 bg-white border-2 border-blue-500 dark:border-blue-400 rounded-full shadow-md"
              style={{ 
                left: `calc(${((sliderProps['aria-valuenow'] as number || 0) / (sliderProps['aria-valuemax'] as number || 100)) * 100}% - 8px)` 
              }}
            >
              <span className="absolute inset-1 bg-blue-500 dark:bg-blue-400 rounded-full" />
            </span>
          </span>
        )}
      />
    );
  }
);

export default Slider;
```

### 미디어 플레이어 컴포넌트

```tsx
// src/components/MediaPlayer.tsx
import * as React from 'react';
import { Button } from '@base-ui-components/react/button';
import Slider from './Slider';

interface MediaPlayerProps {
  title: string;
  artist: string;
  episode?: string;
  coverImage: string;
  duration: number;
  currentTime: number;
  isPlaying: boolean;
  onPlayPause: () => void;
  onSeek: (time: number) => void;
  onRewind: () => void;
  onForward: () => void;
}

const MediaPlayer: React.FC<MediaPlayerProps> = ({
  title,
  artist,
  episode,
  coverImage,
  duration,
  currentTime,
  isPlaying,
  onPlayPause,
  onSeek,
  onRewind,
  onForward,
}) => {
  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <div className="max-w-md mx-auto bg-white dark:bg-gray-800 rounded-2xl shadow-xl overflow-hidden">
      {/* Header */}
      <div className="p-6 space-y-4">
        <div className="flex items-center space-x-4">
          <img
            src={coverImage}
            alt={`${title} cover`}
            className="w-16 h-16 rounded-lg object-cover"
          />
          <div className="flex-1 min-w-0">
            {episode && (
              <p className="text-sm font-medium text-blue-600 dark:text-blue-400">
                {episode}
              </p>
            )}
            <h2 className="text-lg font-semibold text-gray-900 dark:text-white truncate">
              {title}
            </h2>
            <p className="text-sm text-gray-500 dark:text-gray-400">
              {artist}
            </p>
          </div>
        </div>

        {/* Progress */}
        <div className="space-y-2">
          <Slider
            value={currentTime}
            max={duration}
            onChange={(value) => onSeek(value as number)}
            aria-label="Media progress"
          />
          <div className="flex justify-between text-xs font-medium text-gray-500 dark:text-gray-400">
            <span>{formatTime(currentTime)}</span>
            <span>{formatTime(duration)}</span>
          </div>
        </div>
      </div>

      {/* Controls */}
      <div className="px-6 py-4 bg-gray-50 dark:bg-gray-700 flex items-center justify-center space-x-6">
        {/* Rewind */}
        <Button
          onClick={onRewind}
          className="p-2 text-gray-600 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400 transition-colors"
          aria-label="Rewind 10 seconds"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12.066 11.2a1 1 0 000 1.6l5.334 4A1 1 0 0019 16V8a1 1 0 00-1.6-.8l-5.334 4zM4.066 11.2a1 1 0 000 1.6l5.334 4A1 1 0 0011 16V8a1 1 0 00-1.6-.8l-5.334 4z" />
          </svg>
        </Button>

        {/* Play/Pause */}
        <Button
          onClick={onPlayPause}
          className="p-4 bg-blue-600 hover:bg-blue-700 text-white rounded-full transition-colors shadow-lg"
          aria-label={isPlaying ? "Pause" : "Play"}
        >
          {isPlaying ? (
            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
              <path d="M6 4h4v16H6V4zm8 0h4v16h-4V4z" />
            </svg>
          ) : (
            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
              <path d="M8 5v14l11-7z" />
            </svg>
          )}
        </Button>

        {/* Forward */}
        <Button
          onClick={onForward}
          className="p-2 text-gray-600 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400 transition-colors"
          aria-label="Forward 10 seconds"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11.933 12.8a1 1 0 000-1.6L6.6 7.2A1 1 0 005 8v8a1 1 0 001.6.8l5.333-4zM19.933 12.8a1 1 0 000-1.6l-5.333-4A1 1 0 0013 8v8a1 1 0 001.6.8l5.333-4z" />
          </svg>
        </Button>
      </div>
    </div>
  );
};

export default MediaPlayer;
```

### 사용 예제

```tsx
// src/App.tsx
import React, { useState } from 'react';
import MediaPlayer from './components/MediaPlayer';

function App() {
  const [currentTime, setCurrentTime] = useState(145);
  const [isPlaying, setIsPlaying] = useState(false);
  const duration = 320;

  const handlePlayPause = () => setIsPlaying(!isPlaying);
  const handleSeek = (time: number) => setCurrentTime(time);
  const handleRewind = () => setCurrentTime(Math.max(0, currentTime - 10));
  const handleForward = () => setCurrentTime(Math.min(duration, currentTime + 10));

  return (
    <div className="min-h-screen bg-gray-100 dark:bg-gray-900 py-12">
      <MediaPlayer
        title="React 개발 완전 가이드"
        artist="Tech Podcast"
        episode="Ep. 42"
        coverImage="https://via.placeholder.com/80x80/3B82F6/FFFFFF?text=TP"
        duration={duration}
        currentTime={currentTime}
        isPlaying={isPlaying}
        onPlayPause={handlePlayPause}
        onSeek={handleSeek}
        onRewind={handleRewind}
        onForward={handleForward}
      />
    </div>
  );
}

export default App;
```

## 실전 예제 2: 고급 드롭다운 메뉴

### 커스텀 Select 컴포넌트

```tsx
// src/components/Select.tsx
import * as React from 'react';
import { Select as BaseSelect, SelectProps } from '@base-ui-components/react/select';
import { clsx } from 'clsx';

interface Option {
  value: string;
  label: string;
  disabled?: boolean;
}

interface CustomSelectProps extends Omit<SelectProps, 'children'> {
  options: Option[];
  placeholder?: string;
  error?: string;
}

const Select = React.forwardRef<HTMLButtonElement, CustomSelectProps>(
  function Select(props, ref) {
    const { options, placeholder = "선택하세요", error, className, ...other } = props;

    return (
      <BaseSelect {...other} ref={ref}>
        <BaseSelect.Trigger
          className={clsx(
            'relative w-full min-h-[2.5rem] px-3 py-2 text-left',
            'bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600',
            'rounded-lg shadow-sm cursor-pointer',
            'focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500',
            'hover:bg-gray-50 dark:hover:bg-gray-700',
            'transition-colors duration-200',
            error && 'border-red-500 focus:ring-red-500 focus:border-red-500',
            className
          )}
        >
          <BaseSelect.Value 
            placeholder={placeholder}
            className="block truncate text-gray-900 dark:text-white"
          />
          <span className="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
            <svg 
              className="w-5 h-5 text-gray-400" 
              fill="none" 
              stroke="currentColor" 
              viewBox="0 0 24 24"
            >
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
            </svg>
          </span>
        </BaseSelect.Trigger>

        <BaseSelect.Portal>
          <BaseSelect.Positioner className="z-50">
            <BaseSelect.Listbox
              className={clsx(
                'w-full bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700',
                'rounded-lg shadow-lg max-h-60 overflow-auto',
                'py-1 mt-1'
              )}
            >
              {options.map((option) => (
                <BaseSelect.Option
                  key={option.value}
                  value={option.value}
                  disabled={option.disabled}
                  className={clsx(
                    'relative cursor-pointer select-none py-2 px-3',
                    'text-gray-900 dark:text-white',
                    'hover:bg-blue-50 dark:hover:bg-blue-900/20',
                    'data-[highlighted]:bg-blue-100 dark:data-[highlighted]:bg-blue-900/30',
                    'data-[selected]:bg-blue-600 data-[selected]:text-white',
                    'data-[disabled]:opacity-50 data-[disabled]:cursor-not-allowed'
                  )}
                >
                  <span className="block truncate">{option.label}</span>
                  <span className="absolute inset-y-0 right-0 flex items-center pr-3 data-[selected]:block hidden">
                    <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                    </svg>
                  </span>
                </BaseSelect.Option>
              ))}
            </BaseSelect.Listbox>
          </BaseSelect.Positioner>
        </BaseSelect.Portal>
      </BaseSelect>
    );
  }
);

export default Select;
```

## 실전 예제 3: 다이얼로그 및 모달

### 커스텀 Dialog 컴포넌트

```tsx
// src/components/Dialog.tsx
import * as React from 'react';
import { Dialog as BaseDialog, DialogProps } from '@base-ui-components/react/dialog';
import { clsx } from 'clsx';

interface CustomDialogProps extends DialogProps {
  title?: string;
  description?: string;
  children?: React.ReactNode;
  size?: 'sm' | 'md' | 'lg' | 'xl';
}

const Dialog: React.FC<CustomDialogProps> = ({
  title,
  description,
  children,
  size = 'md',
  ...props
}) => {
  const sizeClasses = {
    sm: 'max-w-md',
    md: 'max-w-lg',
    lg: 'max-w-2xl',
    xl: 'max-w-4xl'
  };

  return (
    <BaseDialog {...props}>
      <BaseDialog.Portal>
        <BaseDialog.Backdrop className="fixed inset-0 bg-black/50 z-40" />
        <BaseDialog.Popup
          className={clsx(
            'fixed left-1/2 top-1/2 z-50 w-full -translate-x-1/2 -translate-y-1/2',
            'bg-white dark:bg-gray-800 rounded-lg shadow-xl',
            'max-h-[85vh] overflow-auto',
            'p-6 space-y-4',
            sizeClasses[size]
          )}
        >
          {title && (
            <BaseDialog.Title className="text-lg font-semibold text-gray-900 dark:text-white">
              {title}
            </BaseDialog.Title>
          )}
          
          {description && (
            <BaseDialog.Description className="text-sm text-gray-600 dark:text-gray-300">
              {description}
            </BaseDialog.Description>
          )}

          <div className="space-y-4">
            {children}
          </div>

          <BaseDialog.Close className="absolute right-4 top-4 rounded-sm opacity-70 hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-blue-500">
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
            <span className="sr-only">Close</span>
          </BaseDialog.Close>
        </BaseDialog.Popup>
      </BaseDialog.Portal>
    </BaseDialog>
  );
};

export default Dialog;
```

### 사용 예제

```tsx
// src/components/DialogExample.tsx
import React, { useState } from 'react';
import Dialog from './Dialog';
import { Button } from '@base-ui-components/react/button';

const DialogExample: React.FC = () => {
  const [open, setOpen] = useState(false);

  return (
    <div className="p-8">
      <Button
        onClick={() => setOpen(true)}
        className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
      >
        다이얼로그 열기
      </Button>

      <Dialog
        open={open}
        onOpenChange={setOpen}
        title="계정 삭제"
        description="이 작업은 되돌릴 수 없습니다. 계정과 모든 데이터가 영구적으로 삭제됩니다."
        size="md"
      >
        <div className="space-y-4">
          <p className="text-sm text-gray-600 dark:text-gray-300">
            정말로 계정을 삭제하시겠습니까? 모든 프로젝트, 설정 및 데이터가 완전히 제거됩니다.
          </p>
          
          <div className="flex justify-end space-x-3">
            <Button
              onClick={() => setOpen(false)}
              className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50"
            >
              취소
            </Button>
            <Button
              onClick={() => {
                // 삭제 로직
                setOpen(false);
              }}
              className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
            >
              삭제
            </Button>
          </div>
        </div>
      </Dialog>
    </div>
  );
};

export default DialogExample;
```

## 실전 예제 4: 폼 컴포넌트

### 커스텀 Input 컴포넌트

```tsx
// src/components/Input.tsx
import * as React from 'react';
import { Input as BaseInput, InputProps } from '@base-ui-components/react/input';
import { clsx } from 'clsx';

interface CustomInputProps extends InputProps {
  label?: string;
  error?: string;
  hint?: string;
  startIcon?: React.ReactNode;
  endIcon?: React.ReactNode;
}

const Input = React.forwardRef<HTMLInputElement, CustomInputProps>(
  function Input(props, ref) {
    const { label, error, hint, startIcon, endIcon, className, ...other } = props;

    return (
      <div className="space-y-1">
        {label && (
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
            {label}
          </label>
        )}
        
        <div className="relative">
          {startIcon && (
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <span className="text-gray-500 dark:text-gray-400">
                {startIcon}
              </span>
            </div>
          )}
          
          <BaseInput
            {...other}
            ref={ref}
            className={clsx(
              'block w-full px-3 py-2 border border-gray-300 dark:border-gray-600',
              'rounded-lg bg-white dark:bg-gray-800',
              'text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400',
              'focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500',
              'transition-colors duration-200',
              startIcon && 'pl-10',
              endIcon && 'pr-10',
              error && 'border-red-500 focus:ring-red-500 focus:border-red-500',
              className
            )}
          />
          
          {endIcon && (
            <div className="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
              <span className="text-gray-500 dark:text-gray-400">
                {endIcon}
              </span>
            </div>
          )}
        </div>
        
        {(error || hint) && (
          <p className={clsx(
            'text-sm',
            error ? 'text-red-600 dark:text-red-400' : 'text-gray-500 dark:text-gray-400'
          )}>
            {error || hint}
          </p>
        )}
      </div>
    );
  }
);

export default Input;
```

### 폼 예제

```tsx
// src/components/ContactForm.tsx
import React, { useState } from 'react';
import Input from './Input';
import Select from './Select';
import { Button } from '@base-ui-components/react/button';

interface FormData {
  name: string;
  email: string;
  subject: string;
  message: string;
}

const ContactForm: React.FC = () => {
  const [formData, setFormData] = useState<FormData>({
    name: '',
    email: '',
    subject: '',
    message: ''
  });

  const [errors, setErrors] = useState<Partial<FormData>>({});

  const subjectOptions = [
    { value: 'general', label: '일반 문의' },
    { value: 'support', label: '기술 지원' },
    { value: 'billing', label: '결제 문의' },
    { value: 'feature', label: '기능 요청' }
  ];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    // 유효성 검사
    const newErrors: Partial<FormData> = {};
    if (!formData.name) newErrors.name = '이름을 입력해주세요.';
    if (!formData.email) newErrors.email = '이메일을 입력해주세요.';
    if (!formData.subject) newErrors.subject = '문의 유형을 선택해주세요.';
    if (!formData.message) newErrors.message = '메시지를 입력해주세요.';

    setErrors(newErrors);

    if (Object.keys(newErrors).length === 0) {
      console.log('Form submitted:', formData);
      // 폼 제출 로직
    }
  };

  const handleInputChange = (field: keyof FormData) => (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    setFormData(prev => ({ ...prev, [field]: e.target.value }));
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: undefined }));
    }
  };

  return (
    <form onSubmit={handleSubmit} className="max-w-md mx-auto space-y-6 p-6 bg-white dark:bg-gray-800 rounded-lg shadow-lg">
      <h2 className="text-2xl font-bold text-gray-900 dark:text-white text-center">
        문의하기
      </h2>

      <Input
        label="이름"
        value={formData.name}
        onChange={handleInputChange('name')}
        error={errors.name}
        placeholder="이름을 입력하세요"
        startIcon={
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
          </svg>
        }
      />

      <Input
        type="email"
        label="이메일"
        value={formData.email}
        onChange={handleInputChange('email')}
        error={errors.email}
        placeholder="email@example.com"
        startIcon={
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" />
          </svg>
        }
      />

      <div className="space-y-1">
        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
          문의 유형
        </label>
        <Select
          options={subjectOptions}
          value={formData.subject}
          onChange={(value) => {
            setFormData(prev => ({ ...prev, subject: value as string }));
            if (errors.subject) {
              setErrors(prev => ({ ...prev, subject: undefined }));
            }
          }}
          placeholder="문의 유형을 선택하세요"
          error={errors.subject}
        />
        {errors.subject && (
          <p className="text-sm text-red-600 dark:text-red-400">{errors.subject}</p>
        )}
      </div>

      <div className="space-y-1">
        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
          메시지
        </label>
        <textarea
          value={formData.message}
          onChange={handleInputChange('message')}
          placeholder="자세한 내용을 입력해주세요..."
          rows={4}
          className={clsx(
            'block w-full px-3 py-2 border border-gray-300 dark:border-gray-600',
            'rounded-lg bg-white dark:bg-gray-800',
            'text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400',
            'focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500',
            'transition-colors duration-200 resize-vertical',
            errors.message && 'border-red-500 focus:ring-red-500 focus:border-red-500'
          )}
        />
        {errors.message && (
          <p className="text-sm text-red-600 dark:text-red-400">{errors.message}</p>
        )}
      </div>

      <Button
        type="submit"
        className="w-full py-2 px-4 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-lg transition-colors duration-200"
      >
        메시지 보내기
      </Button>
    </form>
  );
};

export default ContactForm;
```

## 실전 예제 5: 데이터 테이블

### 커스텀 Table 컴포넌트

```tsx
// src/components/Table.tsx
import * as React from 'react';
import { clsx } from 'clsx';

interface Column<T> {
  key: keyof T;
  header: string;
  cell?: (value: T[keyof T], row: T) => React.ReactNode;
  sortable?: boolean;
  width?: string;
}

interface TableProps<T> {
  data: T[];
  columns: Column<T>[];
  loading?: boolean;
  emptyMessage?: string;
  onSort?: (key: keyof T, direction: 'asc' | 'desc') => void;
  sortKey?: keyof T;
  sortDirection?: 'asc' | 'desc';
}

function Table<T extends Record<string, any>>({
  data,
  columns,
  loading = false,
  emptyMessage = "데이터가 없습니다.",
  onSort,
  sortKey,
  sortDirection
}: TableProps<T>) {
  const handleSort = (column: Column<T>) => {
    if (!column.sortable || !onSort) return;
    
    const newDirection = 
      sortKey === column.key && sortDirection === 'asc' ? 'desc' : 'asc';
    onSort(column.key, newDirection);
  };

  if (loading) {
    return (
      <div className="w-full bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden">
        <div className="p-8 text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-2 text-gray-500 dark:text-gray-400">로딩 중...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="w-full bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead className="bg-gray-50 dark:bg-gray-700">
            <tr>
              {columns.map((column) => (
                <th
                  key={String(column.key)}
                  onClick={() => handleSort(column)}
                  className={clsx(
                    'px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider',
                    column.sortable && 'cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-600',
                    column.width && { width: column.width }
                  )}
                >
                  <div className="flex items-center space-x-1">
                    <span>{column.header}</span>
                    {column.sortable && (
                      <span className="text-gray-400">
                        {sortKey === column.key ? (
                          sortDirection === 'asc' ? '↑' : '↓'
                        ) : (
                          '↕'
                        )}
                      </span>
                    )}
                  </div>
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
            {data.length === 0 ? (
              <tr>
                <td
                  colSpan={columns.length}
                  className="px-6 py-8 text-center text-gray-500 dark:text-gray-400"
                >
                  {emptyMessage}
                </td>
              </tr>
            ) : (
              data.map((row, index) => (
                <tr
                  key={index}
                  className="hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
                >
                  {columns.map((column) => (
                    <td
                      key={String(column.key)}
                      className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white"
                    >
                      {column.cell
                        ? column.cell(row[column.key], row)
                        : String(row[column.key])}
                    </td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default Table;
```

### 테이블 사용 예제

```tsx
// src/components/UserTable.tsx
import React, { useState, useMemo } from 'react';
import Table from './Table';

interface User {
  id: number;
  name: string;
  email: string;
  role: string;
  status: 'active' | 'inactive';
  lastLogin: string;
}

const UserTable: React.FC = () => {
  const [sortKey, setSortKey] = useState<keyof User>('name');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('asc');

  const users: User[] = [
    {
      id: 1,
      name: '김철수',
      email: 'kim@example.com',
      role: 'Admin',
      status: 'active',
      lastLogin: '2024-01-15'
    },
    {
      id: 2,
      name: '이영희',
      email: 'lee@example.com',
      role: 'User',
      status: 'active',
      lastLogin: '2024-01-14'
    },
    {
      id: 3,
      name: '박민수',
      email: 'park@example.com',
      role: 'User',
      status: 'inactive',
      lastLogin: '2024-01-10'
    }
  ];

  const sortedUsers = useMemo(() => {
    return [...users].sort((a, b) => {
      const aValue = a[sortKey];
      const bValue = b[sortKey];
      
      if (aValue < bValue) return sortDirection === 'asc' ? -1 : 1;
      if (aValue > bValue) return sortDirection === 'asc' ? 1 : -1;
      return 0;
    });
  }, [users, sortKey, sortDirection]);

  const columns = [
    {
      key: 'name' as keyof User,
      header: '이름',
      sortable: true,
    },
    {
      key: 'email' as keyof User,
      header: '이메일',
      sortable: true,
    },
    {
      key: 'role' as keyof User,
      header: '역할',
      cell: (value: string) => (
        <span className={clsx(
          'px-2 py-1 text-xs font-medium rounded-full',
          value === 'Admin' 
            ? 'bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-300'
            : 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300'
        )}>
          {value}
        </span>
      ),
    },
    {
      key: 'status' as keyof User,
      header: '상태',
      cell: (value: string) => (
        <span className={clsx(
          'px-2 py-1 text-xs font-medium rounded-full',
          value === 'active'
            ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300'
            : 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300'
        )}>
          {value === 'active' ? '활성' : '비활성'}
        </span>
      ),
    },
    {
      key: 'lastLogin' as keyof User,
      header: '마지막 로그인',
      sortable: true,
    },
  ];

  return (
    <div className="p-6">
      <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-6">
        사용자 관리
      </h2>
      
      <Table
        data={sortedUsers}
        columns={columns}
        onSort={(key, direction) => {
          setSortKey(key);
          setSortDirection(direction);
        }}
        sortKey={sortKey}
        sortDirection={sortDirection}
      />
    </div>
  );
};

export default UserTable;
```

## 성능 최적화 팁

### 1. 메모이제이션 활용

```tsx
// 컴포넌트 메모이제이션
const OptimizedComponent = React.memo(MyComponent);

// 복잡한 계산 메모이제이션
const expensiveValue = useMemo(() => {
  return heavyCalculation(data);
}, [data]);

// 콜백 메모이제이션
const handleClick = useCallback((id: string) => {
  // 클릭 핸들러 로직
}, [dependency]);
```

### 2. Bundle 최적화

```tsx
// 동적 임포트로 코드 스플리팅
const LazyComponent = React.lazy(() => import('./LazyComponent'));

// 사용
<Suspense fallback={<div>Loading...</div>}>
  <LazyComponent />
</Suspense>
```

### 3. 가상화

```tsx
// 대용량 리스트를 위한 가상화
import { FixedSizeList as List } from 'react-window';

const VirtualizedList = ({ items }) => (
  <List
    height={600}
    itemCount={items.length}
    itemSize={50}
  >
    {({ index, style }) => (
      <div style={style}>
        {items[index]}
      </div>
    )}
  </List>
);
```

## 접근성 (A11y) 개선 사항

### 1. 키보드 네비게이션

```tsx
const AccessibleButton = () => {
  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' || e.key === ' ') {
      // 버튼 액션 실행
    }
  };

  return (
    <button
      onKeyDown={handleKeyDown}
      aria-label="접근 가능한 버튼"
      role="button"
      tabIndex={0}
    >
      클릭하세요
    </button>
  );
};
```

### 2. ARIA 라벨링

```tsx
const AccessibleForm = () => (
  <form aria-labelledby="form-title">
    <h2 id="form-title">연락처 정보</h2>
    
    <input
      aria-describedby="email-hint"
      aria-required="true"
      aria-invalid={hasError}
    />
    <div id="email-hint">유효한 이메일 주소를 입력하세요</div>
  </form>
);
```

## 테스팅 전략

### 1. 단위 테스트

```tsx
// src/components/__tests__/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from '@base-ui-components/react/button';

describe('Button Component', () => {
  test('renders button with text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button', { name: 'Click me' })).toBeInTheDocument();
  });

  test('calls onClick when clicked', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    
    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

### 2. 접근성 테스트

```tsx
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

test('should not have accessibility violations', async () => {
  const { container } = render(<MyComponent />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

## 배포 및 프로덕션 고려사항

### 1. 빌드 최적화

```json
// package.json
{
  "scripts": {
    "build": "react-scripts build",
    "analyze": "npm run build && npx bundle-analyzer build/static/js/*.js"
  }
}
```

### 2. 환경별 설정

```tsx
// src/config/index.ts
export const config = {
  isDevelopment: process.env.NODE_ENV === 'development',
  apiUrl: process.env.REACT_APP_API_URL || 'http://localhost:3001',
  enableAnalytics: process.env.REACT_APP_ENABLE_ANALYTICS === 'true'
};
```

### 3. 에러 바운더리

```tsx
// src/components/ErrorBoundary.tsx
import React from 'react';

interface Props {
  children: React.ReactNode;
  fallback?: React.ComponentType<{ error: Error }>;
}

interface State {
  hasError: boolean;
  error?: Error;
}

class ErrorBoundary extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      const FallbackComponent = this.props.fallback || DefaultErrorFallback;
      return <FallbackComponent error={this.state.error!} />;
    }

    return this.props.children;
  }
}

const DefaultErrorFallback: React.FC<{ error: Error }> = ({ error }) => (
  <div className="p-8 text-center">
    <h2 className="text-xl font-bold text-red-600 mb-4">
      문제가 발생했습니다
    </h2>
    <p className="text-gray-600 mb-4">
      {error.message}
    </p>
    <button
      onClick={() => window.location.reload()}
      className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
    >
      페이지 새로고침
    </button>
  </div>
);

export default ErrorBoundary;
```

## 결론

Base UI와 Tailwind CSS의 조합은 현대적이고 접근 가능한 웹 애플리케이션을 구축하는 강력한 방법입니다. 이 튜토리얼에서 다룬 실전 예제들을 통해 다음과 같은 이점을 얻을 수 있습니다.

### 주요 장점

✅ **완전한 디자인 제어**: Material Design에 얽매이지 않는 자유로운 커스터마이징  
✅ **최고 수준의 접근성**: WAI-ARIA 표준을 준수하는 내장 접근성 기능  
✅ **뛰어난 성능**: Tree-shaking과 최적화된 번들 크기  
✅ **개발자 경험**: TypeScript 완벽 지원과 직관적인 API  
✅ **프로덕션 준비**: 대규모 애플리케이션에서 검증된 안정성  

### 다음 단계

이 가이드의 예제들을 바탕으로 다음과 같은 확장을 고려해보세요:

- 🎨 **고급 애니메이션**: Framer Motion 통합
- 📱 **반응형 디자인**: 모바일 최적화 패턴
- 🌐 **국제화**: i18next 통합
- 📊 **데이터 시각화**: Chart.js 또는 D3.js 연동
- 🔒 **보안**: CSP 및 XSS 방어 구현

### 추가 리소스

- 📚 [Base UI 공식 문서](https://base-ui.com/)
- 🎨 [Tailwind CSS 가이드](https://tailwindcss.com/docs)
- ♿ [접근성 체크리스트](https://www.a11yproject.com/checklist/)
- 🧪 [React Testing Library](https://testing-library.com/docs/react-testing-library/intro/)

이제 여러분만의 독창적이고 접근 가능한 UI 컴포넌트를 만들어보세요! 