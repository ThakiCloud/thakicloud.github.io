---
title: "daisyUI와 Tailwind CSS로 빠르게 UI 개발하기"
excerpt: "daisyUI는 Tailwind CSS를 위한 가장 인기 있는 무료 오픈소스 컴포넌트 라이브러리입니다. Vite와 React 환경에서 daisyUI를 설정하고, 다양한 컴포넌트와 테마를 활용하여 생산성을 높이는 방법을 알아봅니다."
seo_title: "daisyUI 튜토리얼: Tailwind CSS 컴포넌트 활용 가이드 - Thaki Cloud"
seo_description: "Vite, React 환경에서 Tailwind CSS와 daisyUI를 함께 사용하는 방법을 단계별로 안내합니다. 설치부터 기본 컴포넌트, 테마 커스터마이징까지 실습 예제를 통해 빠르게 배워보세요."
date: 2025-07-07
last_modified_at: 2025-07-07
categories:
  - tutorials
tags:
  - daisyUI
  - Tailwind CSS
  - React
  - Vite
  - frontend
  - CSS
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/daisyui-tailwind-css-tutorial/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 8분

## 서론

[daisyUI](https://daisyui.com/)는 [Tailwind CSS](https://tailwindcss.com/)를 위한 가장 인기 있는 무료 오픈소스 컴포넌트 라이브러리입니다. Tailwind가 유틸리티 클래스 기반의 CSS 프레임워크라면, daisyUI는 `btn`, `card`, `toggle` 등 미리 디자인된 컴포넌트 클래스를 제공하여 개발자가 UI를 더 빠르고 일관되게 구축할 수 있도록 돕습니다.

이 튜토리얼에서는 Vite를 사용하는 React 프로젝트에 daisyUI를 설치하고, 주요 컴포넌트를 활용하는 방법과 테마를 커스터마이징하는 방법을 단계별로 알아보겠습니다.

### 개발 환경

이 튜토리얼은 다음 환경에서 테스트되었습니다.

- **OS:** macOS
- **Node.js:** v20.11.1
- **npm:** v10.2.4

## 본론

### 1. 프로젝트 생성 및 Tailwind CSS 설치

먼저 Vite를 사용하여 새로운 React 프로젝트를 생성합니다.

```bash
npm create vite@latest my-daisyui-app --template react-ts
cd my-daisyui-app
```

다음으로 Tailwind CSS와 관련 의존성을 설치합니다.

```bash
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

### 2. Tailwind CSS 설정

`tailwind.config.js` 파일을 열어 `content`에 템플릿 파일 경로를 추가합니다.

```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

`./src/index.css` 파일에 Tailwind 지시문을 추가합니다.

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

### 3. daisyUI 설치 및 설정

이제 daisyUI를 프로젝트에 추가합니다.

```bash
npm i -D daisyui@latest
```

`tailwind.config.js` 파일의 `plugins` 배열에 daisyUI를 추가합니다.

```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('daisyui'),
  ],
}
```

### 4. daisyUI 컴포넌트 사용하기

설정이 완료되었습니다. 이제 `src/App.tsx` 파일에서 daisyUI 컴포넌트를 사용해 보겠습니다.

```tsx
import './App.css'

function App() {
  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-4">daisyUI Components</h1>

      {/* Button 컴포넌트 */}
      <div className="mb-4">
        <button className="btn">Default</button>
        <button className="btn btn-primary">Primary</button>
        <button className="btn btn-secondary">Secondary</button>
        <button className="btn btn-accent">Accent</button>
      </div>

      {/* Card 컴포넌트 */}
      <div className="card w-96 bg-base-100 shadow-xl">
        <figure><img src="https://img.daisyui.com/images/stock/photo-1606107557195-0e29a4b5b4aa.jpg" alt="Shoes" /></figure>
        <div className="card-body">
          <h2 className="card-title">Shoes!</h2>
          <p>If a dog chews shoes whose shoes does he choose?</p>
          <div className="card-actions justify-end">
            <button className="btn btn-primary">Buy Now</button>
          </div>
        </div>
      </div>

      {/* Toggle 컴포넌트 */}
      <div className="form-control w-52 my-4">
        <label className="cursor-pointer label">
          <span className="label-text">Remember me</span> 
          <input type="checkbox" className="toggle toggle-primary" defaultChecked />
        </label>
      </div>
    </div>
  )
}

export default App
```

### 5. 로컬 개발 서버 실행 및 결과 확인

이제 개발 서버를 실행하여 결과를 확인합니다.

```bash
npm run dev
```

터미널에 다음과 같은 출력이 나타나며, 브라우저에서 `http://localhost:5173`으로 접속할 수 있습니다.

```
  VITE v5.3.1  ready in 388 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h + enter to show help
```

브라우저에는 우리가 추가한 버튼, 카드, 토글 컴포넌트가 Tailwind CSS와 daisyUI 스타일이 적용된 상태로 렌더링됩니다.

### 6. 테마 커스터마이징

daisyUI는 `light`, `dark`, `cupcake` 등 다양한 내장 테마를 제공하며, 쉽게 전환할 수 있습니다.

`tailwind.config.js` 파일에 `daisyui` 설정을 추가하여 원하는 테마를 지정할 수 있습니다.

```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('daisyui'),
  ],
  daisyui: {
    themes: ["light", "dark", "cupcake"],
  },
}
```

`index.html`의 `<html>` 태그에 `data-theme` 속성을 추가하면 기본 테마를 설정할 수 있습니다.

```html
<!doctype html>
<html lang="en" data-theme="cupcake">
  <head>
    <!-- ... -->
  </head>
  <body>
    <!-- ... -->
  </body>
</html>
```

이렇게 하면 `cupcake` 테마가 기본으로 적용됩니다. 자바스크립트를 사용하여 동적으로 테마를 변경하는 기능도 쉽게 구현할 수 있습니다.

## 결론

daisyUI는 Tailwind CSS의 유틸리티 우선 접근 방식을 유지하면서도, 재사용 가능한 컴포넌트를 통해 개발 속도를 크게 향상시킵니다. 직관적인 클래스명, 다양한 내장 테마, 손쉬운 커스터마이징 기능 덕분에 복잡한 UI도 빠르고 효율적으로 구축할 수 있습니다.

이 튜토리얼을 통해 Vite와 React 환경에서 daisyUI를 시작하는 방법을 익혔습니다. 이제 공식 문서를 참고하여 더 많은 컴포넌트와 기능을 탐색해 보시길 바랍니다. 