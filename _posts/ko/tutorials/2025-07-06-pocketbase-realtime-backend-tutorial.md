---
title: "PocketBase: 단일 파일로 구축하는 실시간 백엔드 완전 가이드"
excerpt: "48.2k 스타의 PocketBase로 SQLite, 실시간 구독, 사용자 관리, Admin UI를 단일 바이너리에서 구현하는 방법을 macOS 환경에서 실습과 함께 마스터해보세요."
seo_title: "PocketBase 실시간 백엔드 Go SQLite MIT 라이센스 완벽 튜토리얼 - Thaki Cloud"
seo_description: "Go 기반 PocketBase로 단일 파일 백엔드 구축, SQLite 실시간 구독, 사용자 인증, 파일 관리, Admin UI를 macOS에서 실습과 함께 상세히 알아봅니다."
date: 2025-07-06
last_modified_at: 2025-07-06
categories:
  - tutorials
tags:
  - pocketbase
  - go
  - sqlite
  - realtime
  - backend
  - mit-license
  - rest-api
  - websocket
  - authentication
  - database
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/pocketbase-realtime-backend-tutorial/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 14분

## 서론

현대 웹 애플리케이션 개발에서 백엔드 구축은 복잡하고 시간이 많이 소요되는 작업입니다. 데이터베이스 설정, 인증 시스템 구현, API 개발, 실시간 기능 추가 등 수많은 컴포넌트를 연결해야 합니다.

[PocketBase](https://github.com/pocketbase/pocketbase)는 이러한 복잡성을 혁신적으로 해결하는 오픈소스 솔루션입니다. 48.2k GitHub 스타를 받으며 검증된 이 Go 기반 백엔드는 단일 바이너리 파일로 완전한 백엔드 시스템을 제공합니다.

본 튜토리얼에서는 PocketBase의 핵심 기능부터 고급 활용법까지 macOS 환경에서 실습과 함께 완전히 마스터하는 방법을 알아보겠습니다.

## PocketBase란?

### 핵심 특징

**🗃️ 통합 백엔드 솔루션**
- SQLite 임베디드 데이터베이스
- 실시간 구독 (WebSocket)
- REST-ish API 자동 생성
- Admin 대시보드 UI 내장

**👥 사용자 관리 시스템**
- 내장 사용자 인증 및 권한 관리
- 이메일 인증, 소셜 로그인 지원
- 역할 기반 접근 제어 (RBAC)
- 세션 관리 및 토큰 인증

**📁 파일 관리**
- 파일 업로드/다운로드 API
- 이미지 리사이징 및 썸네일 생성
- S3 호환 스토리지 지원
- 파일 접근 권한 제어

**🔧 개발자 친화적**
- Go 프레임워크로 확장 가능
- JavaScript 플러그인 지원
- 마이그레이션 시스템
- 풍부한 SDK (JavaScript, Dart)

### 기술 스택

**언어**: Go 71.4%, Svelte 16.9%
**라이센스**: MIT (상업적 사용 가능)
**데이터베이스**: SQLite (임베디드)
**지원 플랫폼**: 크로스 플랫폼
**최소 요구사항**: Go 1.23+

### MIT 라이센스 장점

**✅ 완전 자유 사용**
- 상업적 프로젝트에 무제한 사용
- 소스코드 수정 및 재배포 자유
- 사적/공적 사용 모두 허용
- 라이센스 비용 없음

**📋 간단한 의무사항**
- 저작권 고지만 포함하면 됨
- 복잡한 컴플라이언스 요구사항 없음

## 시스템 요구사항 및 설치

### macOS 환경 준비

```bash
# Go 설치 확인 (1.23+ 필요)
go version

# Go가 없다면 Homebrew로 설치
brew install go

# 작업 디렉토리 생성
mkdir ~/pocketbase-tutorial
cd ~/pocketbase-tutorial
```

### 설치 방법

#### 방법 1: 사전 빌드된 바이너리 사용 (권장)

```bash
#!/bin/bash
# 파일명: install_pocketbase.sh

echo "🚀 PocketBase 설치 스크립트"

# 최신 릴리즈 정보 가져오기
LATEST_RELEASE=$(curl -s https://api.github.com/repos/pocketbase/pocketbase/releases/latest)
VERSION=$(echo $LATEST_RELEASE | grep -o '"tag_name": "[^"]*' | grep -o '[^"]*$')

echo "📦 최신 버전: $VERSION"

# macOS용 바이너리 다운로드
if [[ $(uname -m) == "arm64" ]]; then
    ARCH="darwin_arm64"
else
    ARCH="darwin_amd64"
fi

DOWNLOAD_URL="https://github.com/pocketbase/pocketbase/releases/download/$VERSION/pocketbase_${VERSION:1}_${ARCH}.zip"

echo "📥 다운로드 중: $DOWNLOAD_URL"
curl -LO "$DOWNLOAD_URL"

# 압축 해제
unzip "pocketbase_${VERSION:1}_${ARCH}.zip"
rm "pocketbase_${VERSION:1}_${ARCH}.zip"

# 실행 권한 부여
chmod +x pocketbase

# 버전 확인
./pocketbase --version

echo "✅ PocketBase 설치 완료!"
echo "💡 실행 방법: ./pocketbase serve"
```

#### 방법 2: Go 소스코드 빌드

```bash
# PocketBase 예제 클론
git clone https://github.com/pocketbase/pocketbase.git
cd pocketbase/examples/base

# 의존성 설치
go mod tidy

# 빌드
CGO_ENABLED=0 go build -o pocketbase

# 실행 권한 부여
chmod +x pocketbase

# 버전 확인
./pocketbase --version
```

#### 방법 3: Docker 사용

```bash
# Docker로 실행
docker run --name pocketbase \
  -p 8080:8080 \
  -v $(pwd)/pb_data:/pb_data \
  spectrocloud/pocketbase:latest

# 또는 docker-compose.yml 생성
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  pocketbase:
    image: spectrocloud/pocketbase:latest
    container_name: pocketbase
    restart: unless-stopped
    ports:
      - "8080:8080"
    volumes:
      - ./pb_data:/pb_data
    environment:
      - POCKETBASE_ADMIN_EMAIL=admin@example.com
      - POCKETBASE_ADMIN_PASSWORD=adminpassword
EOF

# Docker Compose로 실행
docker-compose up -d
```

### 첫 실행 및 설정

```bash
# PocketBase 서버 시작
./pocketbase serve

# 또는 특정 포트로 실행
./pocketbase serve --http=0.0.0.0:8090

# 백그라운드 실행
./pocketbase serve &

# 로그 출력 확인
tail -f pb_data/logs/pocketbase.log
```

## 기본 사용법

### Admin 대시보드 설정

```bash
# 서버 시작 후 브라우저에서 접속
# http://localhost:8080/_/

# 첫 접속 시 관리자 계정 생성이 필요합니다.
```

**관리자 계정 생성**:
1. 브라우저에서 `http://localhost:8080/_/` 접속
2. 이메일과 패스워드 입력하여 계정 생성
3. 로그인하여 Admin 대시보드 접근

### 컬렉션(테이블) 생성

```bash
# CLI로 컬렉션 생성 (옵션)
./pocketbase collections create \
  --name="posts" \
  --type="base" \
  --schema='[
    {"name": "title", "type": "text", "required": true},
    {"name": "content", "type": "text"},
    {"name": "author", "type": "relation", "options": {"collectionId": "_pb_users_auth_"}},
    {"name": "published", "type": "bool", "default": false},
    {"name": "tags", "type": "json"}
  ]'
```

**Admin UI에서 컬렉션 생성**:
1. `Collections` 탭 클릭
2. `New collection` 버튼 클릭
3. 컬렉션 이름 입력: `posts`
4. 필드 추가:
   - `title`: Text (required)
   - `content`: Editor
   - `author`: Relation → users
   - `published`: Bool (default: false)
   - `created_at`: Date (auto)

## REST API 활용

### 기본 CRUD 작업

```javascript
#!/usr/bin/env node
// 파일명: api_examples.js

const BASE_URL = 'http://localhost:8080/api';

// 1. 사용자 생성 (회원가입)
async function createUser() {
    const response = await fetch(`${BASE_URL}/collections/users/records`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            username: 'johndoe',
            email: 'john@example.com',
            password: 'securepassword123',
            passwordConfirm: 'securepassword123'
        })
    });
    
    const user = await response.json();
    console.log('✅ 사용자 생성:', user);
    return user;
}

// 2. 로그인 (인증)
async function loginUser() {
    const response = await fetch(`${BASE_URL}/collections/users/auth-with-password`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            identity: 'john@example.com',
            password: 'securepassword123'
        })
    });
    
    const auth = await response.json();
    console.log('🔐 로그인 성공:', auth);
    return auth.token;
}

// 3. 게시글 생성
async function createPost(token) {
    const response = await fetch(`${BASE_URL}/collections/posts/records`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
            title: 'PocketBase로 백엔드 구축하기',
            content: '단일 파일로 완전한 백엔드를 구축할 수 있습니다.',
            published: true,
            tags: ['tutorial', 'backend', 'go']
        })
    });
    
    const post = await response.json();
    console.log('📝 게시글 생성:', post);
    return post;
}

// 4. 게시글 목록 조회
async function getPosts() {
    const response = await fetch(
        `${BASE_URL}/collections/posts/records?sort=-created&expand=author`
    );
    
    const posts = await response.json();
    console.log('📚 게시글 목록:', posts);
    return posts;
}

// 5. 게시글 업데이트
async function updatePost(postId, token) {
    const response = await fetch(`${BASE_URL}/collections/posts/records/${postId}`, {
        method: 'PATCH',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
            content: '업데이트된 내용입니다.',
            published: true
        })
    });
    
    const updatedPost = await response.json();
    console.log('✏️ 게시글 업데이트:', updatedPost);
    return updatedPost;
}

// 6. 파일 업로드
async function uploadFile(token) {
    const formData = new FormData();
    formData.append('title', '이미지 포스트');
    formData.append('content', '파일이 첨부된 게시글입니다.');
    
    // 실제 환경에서는 File 객체 사용
    // formData.append('image', fileInput.files[0]);
    
    const response = await fetch(`${BASE_URL}/collections/posts/records`, {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${token}`
        },
        body: formData
    });
    
    const postWithFile = await response.json();
    console.log('📎 파일 업로드:', postWithFile);
    return postWithFile;
}

// 전체 플로우 실행
async function runExample() {
    try {
        console.log('🚀 PocketBase API 예제 시작\n');
        
        // 사용자 생성 및 로그인
        await createUser();
        const token = await loginUser();
        
        // 게시글 CRUD
        const post = await createPost(token);
        await getPosts();
        await updatePost(post.id, token);
        
        console.log('\n✅ 모든 API 테스트 완료!');
    } catch (error) {
        console.error('❌ 오류 발생:', error);
    }
}

// Node.js 환경에서 실행
if (typeof require !== 'undefined' && require.main === module) {
    // fetch polyfill for Node.js
    global.fetch = require('node-fetch');
    global.FormData = require('form-data');
    runExample();
}
```

### 고급 쿼리 기능

```bash
#!/bin/bash
# 파일명: advanced_queries.sh

echo "🔍 PocketBase 고급 쿼리 예제"

BASE_URL="http://localhost:8080/api"

echo "📊 1. 필터링 쿼리"
# 제목에 'PocketBase'가 포함된 게시글
curl -G "$BASE_URL/collections/posts/records" \
  --data-urlencode "filter=title~'PocketBase'"

echo -e "\n📊 2. 정렬 및 페이징"
# 최신 순으로 10개, 2페이지
curl -G "$BASE_URL/collections/posts/records" \
  --data-urlencode "sort=-created" \
  --data-urlencode "page=2" \
  --data-urlencode "perPage=10"

echo -e "\n📊 3. 관계 확장"
# 작성자 정보와 함께 조회
curl -G "$BASE_URL/collections/posts/records" \
  --data-urlencode "expand=author"

echo -e "\n📊 4. 복합 필터"
# 게시됨 상태이고 특정 태그 포함
curl -G "$BASE_URL/collections/posts/records" \
  --data-urlencode "filter=published=true && tags?~'tutorial'"

echo -e "\n📊 5. 날짜 범위 검색"
# 최근 7일 내 생성된 게시글
curl -G "$BASE_URL/collections/posts/records" \
  --data-urlencode "filter=created>=@now(-7d)"

echo -e "\n📊 6. 사용자별 게시글 개수"
# 집계 쿼리 (Admin API 필요)
curl -H "Authorization: Bearer $ADMIN_TOKEN" \
  "$BASE_URL/collections/posts/records?groupBy=author&aggregate=count"
```

## 실시간 구독 구현

### JavaScript 실시간 클라이언트

```html
<!DOCTYPE html>
<!-- 파일명: realtime_example.html -->
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PocketBase 실시간 예제</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .container { max-width: 800px; margin: 0 auto; }
        .post { border: 1px solid #ddd; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .form-group { margin: 10px 0; }
        input, textarea { width: 100%; padding: 8px; margin: 5px 0; }
        button { background: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 3px; cursor: pointer; }
        .status { padding: 10px; border-radius: 3px; margin: 10px 0; }
        .success { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📡 PocketBase 실시간 게시판</h1>
        
        <!-- 로그인 폼 -->
        <div id="loginForm">
            <h2>🔐 로그인</h2>
            <div class="form-group">
                <input type="email" id="email" placeholder="이메일" value="john@example.com">
            </div>
            <div class="form-group">
                <input type="password" id="password" placeholder="패스워드" value="securepassword123">
            </div>
            <button onclick="login()">로그인</button>
        </div>

        <!-- 게시글 작성 폼 -->
        <div id="postForm" style="display: none;">
            <h2>✏️ 새 게시글</h2>
            <div class="form-group">
                <input type="text" id="title" placeholder="제목">
            </div>
            <div class="form-group">
                <textarea id="content" placeholder="내용" rows="4"></textarea>
            </div>
            <button onclick="createPost()">게시글 작성</button>
            <button onclick="logout()" style="background: #dc3545; margin-left: 10px;">로그아웃</button>
        </div>

        <!-- 상태 메시지 -->
        <div id="status"></div>

        <!-- 실시간 게시글 목록 -->
        <div id="posts">
            <h2>📚 실시간 게시글</h2>
            <div id="postsList"></div>
        </div>
    </div>

    <!-- PocketBase JavaScript SDK -->
    <script src="https://unpkg.com/pocketbase@latest/dist/pocketbase.umd.js"></script>
    
    <script>
        // PocketBase 클라이언트 초기화
        const pb = new PocketBase('http://localhost:8080');
        let currentUser = null;

        // 상태 메시지 표시
        function showStatus(message, type = 'success') {
            const statusDiv = document.getElementById('status');
            statusDiv.innerHTML = `<div class="${type}">${message}</div>`;
            setTimeout(() => statusDiv.innerHTML = '', 5000);
        }

        // 로그인
        async function login() {
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;

            try {
                const authData = await pb.collection('users').authWithPassword(email, password);
                currentUser = authData.record;
                
                document.getElementById('loginForm').style.display = 'none';
                document.getElementById('postForm').style.display = 'block';
                
                showStatus(`환영합니다, ${currentUser.username || currentUser.email}!`);
                
                // 실시간 구독 시작
                subscribeToRealtime();
                
                // 기존 게시글 로드
                loadPosts();
                
            } catch (error) {
                showStatus(`로그인 실패: ${error.message}`, 'error');
            }
        }

        // 로그아웃
        function logout() {
            pb.authStore.clear();
            currentUser = null;
            
            document.getElementById('loginForm').style.display = 'block';
            document.getElementById('postForm').style.display = 'none';
            document.getElementById('postsList').innerHTML = '';
            
            // 실시간 구독 해제
            pb.realtime.unsubscribe();
            
            showStatus('로그아웃되었습니다.');
        }

        // 게시글 작성
        async function createPost() {
            const title = document.getElementById('title').value;
            const content = document.getElementById('content').value;

            if (!title || !content) {
                showStatus('제목과 내용을 모두 입력해주세요.', 'error');
                return;
            }

            try {
                const data = {
                    title: title,
                    content: content,
                    author: currentUser.id,
                    published: true
                };

                await pb.collection('posts').create(data);
                
                // 폼 초기화
                document.getElementById('title').value = '';
                document.getElementById('content').value = '';
                
                showStatus('게시글이 작성되었습니다!');
                
            } catch (error) {
                showStatus(`게시글 작성 실패: ${error.message}`, 'error');
            }
        }

        // 기존 게시글 로드
        async function loadPosts() {
            try {
                const posts = await pb.collection('posts').getList(1, 50, {
                    sort: '-created',
                    expand: 'author'
                });
                
                displayPosts(posts.items);
                
            } catch (error) {
                showStatus(`게시글 로드 실패: ${error.message}`, 'error');
            }
        }

        // 게시글 표시
        function displayPosts(posts) {
            const postsContainer = document.getElementById('postsList');
            
            postsContainer.innerHTML = posts.map(post => `
                <div class="post" id="post-${post.id}">
                    <h3>${post.title}</h3>
                    <p>${post.content}</p>
                    <small>
                        작성자: ${post.expand?.author?.username || post.expand?.author?.email || 'Unknown'} | 
                        작성일: ${new Date(post.created).toLocaleString('ko-KR')}
                    </small>
                </div>
            `).join('');
        }

        // 실시간 구독
        function subscribeToRealtime() {
            // 게시글 컬렉션 실시간 구독
            pb.collection('posts').subscribe('*', function (e) {
                console.log('실시간 이벤트:', e);
                
                if (e.action === 'create') {
                    showStatus(`새 게시글: "${e.record.title}"이 작성되었습니다!`);
                    addPostToTop(e.record);
                } else if (e.action === 'update') {
                    showStatus(`게시글 "${e.record.title}"이 수정되었습니다.`);
                    updatePostInList(e.record);
                } else if (e.action === 'delete') {
                    showStatus(`게시글이 삭제되었습니다.`);
                    removePostFromList(e.record.id);
                }
            });
            
            showStatus('실시간 구독이 활성화되었습니다.', 'success');
        }

        // 새 게시글을 목록 맨 위에 추가
        async function addPostToTop(post) {
            // 작성자 정보 로드
            try {
                const fullPost = await pb.collection('posts').getOne(post.id, {
                    expand: 'author'
                });
                
                const postsContainer = document.getElementById('postsList');
                const newPostHtml = `
                    <div class="post" id="post-${fullPost.id}" style="border-color: #28a745;">
                        <h3>${fullPost.title}</h3>
                        <p>${fullPost.content}</p>
                        <small>
                            작성자: ${fullPost.expand?.author?.username || fullPost.expand?.author?.email || 'Unknown'} | 
                            작성일: ${new Date(fullPost.created).toLocaleString('ko-KR')}
                        </small>
                    </div>
                `;
                
                postsContainer.insertAdjacentHTML('afterbegin', newPostHtml);
                
                // 강조 효과 제거
                setTimeout(() => {
                    const postElement = document.getElementById(`post-${fullPost.id}`);
                    if (postElement) {
                        postElement.style.borderColor = '#ddd';
                    }
                }, 3000);
                
            } catch (error) {
                console.error('게시글 정보 로드 실패:', error);
            }
        }

        // 게시글 업데이트
        function updatePostInList(post) {
            const postElement = document.getElementById(`post-${post.id}`);
            if (postElement) {
                postElement.style.borderColor = '#ffc107';
                postElement.querySelector('h3').textContent = post.title;
                postElement.querySelector('p').textContent = post.content;
                
                setTimeout(() => {
                    postElement.style.borderColor = '#ddd';
                }, 3000);
            }
        }

        // 게시글 삭제
        function removePostFromList(postId) {
            const postElement = document.getElementById(`post-${postId}`);
            if (postElement) {
                postElement.style.opacity = '0.5';
                setTimeout(() => postElement.remove(), 1000);
            }
        }

        // 페이지 로드 시 인증 상태 확인
        window.addEventListener('load', function() {
            if (pb.authStore.isValid) {
                currentUser = pb.authStore.model;
                document.getElementById('loginForm').style.display = 'none';
                document.getElementById('postForm').style.display = 'block';
                subscribeToRealtime();
                loadPosts();
                showStatus(`다시 오신 것을 환영합니다, ${currentUser.username || currentUser.email}!`);
            }
        });

        // 페이지 종료 시 구독 해제
        window.addEventListener('beforeunload', function() {
            pb.realtime.unsubscribe();
        });
    </script>
</body>
</html>
```

## Go 프레임워크로 확장

### 커스텀 PocketBase 애플리케이션

```go
// 파일명: main.go
package main

import (
    "log"
    "net/http"
    "encoding/json"
    "github.com/pocketbase/pocketbase"
    "github.com/pocketbase/pocketbase/core"
    "github.com/pocketbase/pocketbase/models"
    "github.com/pocketbase/pocketbase/apis"
    "github.com/pocketbase/pocketbase/tools/types"
)

// 커스텀 API 응답 구조체
type APIResponse struct {
    Success bool        `json:"success"`
    Message string      `json:"message"`
    Data    interface{} `json:"data,omitempty"`
}

func main() {
    app := pocketbase.New()

    // 커스텀 라우트 추가
    app.OnServe().BindFunc(func(se *core.ServeEvent) error {
        // API 통계 엔드포인트
        se.Router.GET("/api/stats", func(re *core.RequestEvent) error {
            return getStats(app, re)
        })

        // 게시글 검색 엔드포인트
        se.Router.GET("/api/search/posts", func(re *core.RequestEvent) error {
            return searchPosts(app, re)
        })

        // 사용자 프로필 업데이트 훅
        se.Router.POST("/api/profile/update", func(re *core.RequestEvent) error {
            return updateProfile(app, re)
        })

        return se.Next()
    })

    // 레코드 생성 후 훅 (게시글 알림)
    app.OnRecordAfterCreateSuccess("posts").BindFunc(func(rce *core.RecordEvent) error {
        return sendPostNotification(app, rce.Record)
    })

    // 사용자 등록 후 훅 (환영 이메일)
    app.OnRecordAfterCreateSuccess("users").BindFunc(func(rce *core.RecordEvent) error {
        return sendWelcomeEmail(app, rce.Record)
    })

    // 레코드 삭제 전 검증
    app.OnRecordBeforeDeleteRequest("posts").BindFunc(func(rde *core.RecordEvent) error {
        return validatePostDeletion(app, rde)
    })

    if err := app.Start(); err != nil {
        log.Fatal(err)
    }
}

// API 통계 정보 제공
func getStats(app *pocketbase.PocketBase, re *core.RequestEvent) error {
    stats := map[string]interface{}{}

    // 총 사용자 수
    userCount, err := app.Dao().DB().
        Select("count(*)").
        From("users").
        Build().
        Execute()
    
    if err == nil {
        stats["total_users"] = userCount
    }

    // 총 게시글 수
    postCount, err := app.Dao().DB().
        Select("count(*)").
        From("posts").
        Build().
        Execute()
    
    if err == nil {
        stats["total_posts"] = postCount
    }

    // 오늘 생성된 게시글 수
    todayPosts, err := app.Dao().DB().
        Select("count(*)").
        From("posts").
        Where("DATE(created) = DATE('now')").
        Build().
        Execute()
    
    if err == nil {
        stats["today_posts"] = todayPosts
    }

    response := APIResponse{
        Success: true,
        Message: "통계 정보를 성공적으로 조회했습니다.",
        Data:    stats,
    }

    return re.JSON(http.StatusOK, response)
}

// 게시글 검색 기능
func searchPosts(app *pocketbase.PocketBase, re *core.RequestEvent) error {
    query := re.Request.URL.Query().Get("q")
    if query == "" {
        return re.JSON(http.StatusBadRequest, APIResponse{
            Success: false,
            Message: "검색어를 입력해주세요.",
        })
    }

    // 제목 또는 내용에서 검색
    records, err := app.Dao().FindRecordsByFilter(
        "posts",
        "title ~ {:query} || content ~ {:query}",
        "-created",
        100,
        0,
        map[string]any{"query": query},
    )

    if err != nil {
        return re.JSON(http.StatusInternalServerError, APIResponse{
            Success: false,
            Message: "검색 중 오류가 발생했습니다.",
        })
    }

    response := APIResponse{
        Success: true,
        Message: "검색이 완료되었습니다.",
        Data:    records,
    }

    return re.JSON(http.StatusOK, response)
}

// 사용자 프로필 업데이트
func updateProfile(app *pocketbase.PocketBase, re *core.RequestEvent) error {
    // 인증 확인
    authRecord, _ := re.Auth.(*models.Record)
    if authRecord == nil {
        return apis.NewForbiddenError("인증이 필요합니다.", nil)
    }

    data := struct {
        Username string `json:"username"`
        Name     string `json:"name"`
        Avatar   string `json:"avatar"`
    }{}

    if err := json.NewDecoder(re.Request.Body).Decode(&data); err != nil {
        return re.JSON(http.StatusBadRequest, APIResponse{
            Success: false,
            Message: "잘못된 요청 데이터입니다.",
        })
    }

    // 프로필 업데이트
    authRecord.Set("username", data.Username)
    authRecord.Set("name", data.Name)
    if data.Avatar != "" {
        authRecord.Set("avatar", data.Avatar)
    }

    if err := app.Dao().SaveRecord(authRecord); err != nil {
        return re.JSON(http.StatusInternalServerError, APIResponse{
            Success: false,
            Message: "프로필 업데이트에 실패했습니다.",
        })
    }

    response := APIResponse{
        Success: true,
        Message: "프로필이 성공적으로 업데이트되었습니다.",
        Data:    authRecord,
    }

    return re.JSON(http.StatusOK, response)
}

// 게시글 생성 알림 발송
func sendPostNotification(app *pocketbase.PocketBase, record *models.Record) error {
    // 실제 환경에서는 이메일, 푸시 알림 등을 발송
    log.Printf("📬 새 게시글 알림: %s", record.GetString("title"))
    
    // 여기에 실제 알림 로직 구현
    // - 이메일 발송
    // - 푸시 알림
    // - Slack, Discord 메시지 등
    
    return nil
}

// 환영 이메일 발송
func sendWelcomeEmail(app *pocketbase.PocketBase, record *models.Record) error {
    email := record.GetString("email")
    username := record.GetString("username")
    
    log.Printf("📧 환영 이메일 발송: %s (%s)", username, email)
    
    // 실제 이메일 발송 로직
    message := &types.Message{
        From: "noreply@example.com",
        To:   []string{email},
        Subject: "PocketBase 가입을 환영합니다!",
        HTML: `
            <h1>환영합니다!</h1>
            <p>안녕하세요 ` + username + `님,</p>
            <p>PocketBase 커뮤니티에 가입해주셔서 감사합니다.</p>
            <p>이제 다양한 기능을 사용하실 수 있습니다.</p>
        `,
    }
    
    return app.NewMailClient().Send(message)
}

// 게시글 삭제 권한 검증
func validatePostDeletion(app *pocketbase.PocketBase, rde *core.RecordEvent) error {
    // 작성자만 삭제 가능하도록 검증
    authRecord, _ := rde.RequestEvent.Auth.(*models.Record)
    if authRecord == nil {
        return apis.NewForbiddenError("인증이 필요합니다.", nil)
    }

    postAuthor := rde.Record.GetString("author")
    if postAuthor != authRecord.Id {
        return apis.NewForbiddenError("자신의 게시글만 삭제할 수 있습니다.", nil)
    }

    return rde.Next()
}
```

### 빌드 및 실행

```bash
#!/bin/bash
# 파일명: build_custom_pocketbase.sh

echo "🔨 커스텀 PocketBase 빌드"

# Go 모듈 초기화
go mod init custom-pocketbase

# PocketBase 의존성 추가
go mod tidy

# 빌드
echo "📦 바이너리 빌드 중..."
CGO_ENABLED=0 go build -o custom-pocketbase main.go

# 실행 권한 부여
chmod +x custom-pocketbase

echo "✅ 빌드 완료!"
echo "💡 실행 방법: ./custom-pocketbase serve"

# 실행
./custom-pocketbase serve --http=0.0.0.0:8080