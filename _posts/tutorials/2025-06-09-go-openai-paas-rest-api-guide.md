---
title: "Go 언어로 REST API 서비스 구축하기: Docker + OrbStack 맥북 로컬 개발 가이드"
date: 2025-06-09
categories: 
  - tutorials
  - go
  - api
tags: 
  - golang
  - rest-api
  - docker
  - orbstack
  - local-development
  - ai-agents
author_profile: true
toc: true
toc_label: "목차"
---

Go 언어로 확장 가능한 REST API 서비스를 구축하고, 맥북에서 Docker와 OrbStack을 활용하여 컨테이너 환경에서 개발하는 방법을 완전 초보자도 따라할 수 있도록 단계별로 설명합니다. 이 가이드를 통해 AI 에이전트 연동을 위한 기반 서비스를 만들어보세요.

## 사전 준비사항

### 1. 필요한 도구 준비

다음 항목들을 미리 준비해주세요:

- **Go 언어 설치** (1.19 이상)
- **Docker Desktop** 또는 **OrbStack** 설치 (OrbStack 권장)
- **Git** 설치
- **텍스트 에디터** (VS Code 권장)
- **맥북** (Apple Silicon 또는 Intel)

### 2. Go 개발 환경 설정

#### Go 설치 확인

```bash
# Go 버전 확인
go version

# 결과 예시: go version go1.21.0 darwin/amd64
```

Go가 설치되어 있지 않다면 [공식 사이트](https://golang.org/dl/)에서 다운로드하세요.

### 3. OrbStack 설치 및 설정

#### OrbStack 설치

OrbStack은 macOS에 최적화된 Docker Desktop 대안으로, 더 빠르고 가벼워서 맥북에서 사용하기 좋습니다.

```bash
# Homebrew로 OrbStack 설치
brew install orbstack

# 또는 공식 사이트에서 다운로드
# https://orbstack.dev/
```

#### OrbStack 실행 확인

```bash
# OrbStack 상태 확인
orb status

# Docker 명령어가 정상 작동하는지 확인
docker --version
docker ps
```

#### 개발 디렉토리 생성

```bash
# 프로젝트 디렉토리 생성
mkdir go-rest-api
cd go-rest-api

# Go 모듈 초기화
go mod init go-rest-api
```

## 기본 REST API 서비스 구현

### 1. 필요한 패키지 설치

```bash
# HTTP 서버를 위한 Gin 프레임워크 설치
go get github.com/gin-gonic/gin

# 환경변수 관리를 위한 godotenv
go get github.com/joho/godotenv

# CORS 처리를 위한 패키지
go get github.com/gin-contrib/cors

# UUID 생성을 위한 패키지
go get github.com/google/uuid

# 시간 처리를 위한 패키지
go get github.com/jinzhu/now
```

### 2. 환경 설정 파일 생성

`.env` 파일을 생성하고 기본 설정을 합니다:

```bash
# .env 파일 생성
touch .env
```

`.env` 파일 내용:

```
PORT=8080
APP_ENV=development
DB_CONNECTION_STRING=sqlite:./app.db
LOG_LEVEL=info
```

⚠️ **중요**: `.env` 파일은 절대 Git에 커밋하지 마세요!

### 3. 기본 구조체 및 설정 파일 생성

`config/config.go` 파일을 생성합니다:

```go
package config

import (
    "log"
    "os"

    "github.com/joho/godotenv"
)

type Config struct {
    Port                 string
    AppEnv              string
    DBConnectionString  string
    LogLevel            string
}

func LoadConfig() *Config {
    // .env 파일 로드 (로컬 개발용)
    if err := godotenv.Load(); err != nil {
        log.Println("Warning: .env file not found, using environment variables")
    }

    return &Config{
        Port:               getEnv("PORT", "8080"),
        AppEnv:             getEnv("APP_ENV", "development"),
        DBConnectionString: getEnv("DB_CONNECTION_STRING", "sqlite:./app.db"),
        LogLevel:           getEnv("LOG_LEVEL", "info"),
    }
}

func getEnv(key, defaultValue string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    return defaultValue
}
```

### 4. 비즈니스 로직 서비스 구현

`services/task.go` 파일을 생성합니다:

```go
package services

import (
    "fmt"
    "time"
    
    "github.com/google/uuid"
)

type Task struct {
    ID          string    `json:"id"`
    Title       string    `json:"title"`
    Description string    `json:"description"`
    Status      string    `json:"status"`
    CreatedAt   time.Time `json:"created_at"`
    UpdatedAt   time.Time `json:"updated_at"`
}

type TaskService struct {
    tasks map[string]*Task
}

func NewTaskService() *TaskService {
    return &TaskService{
        tasks: make(map[string]*Task),
    }
}

// 태스크 생성
func (s *TaskService) CreateTask(title, description string) (*Task, error) {
    if title == "" {
        return nil, fmt.Errorf("title is required")
    }

    task := &Task{
        ID:          uuid.New().String(),
        Title:       title,
        Description: description,
        Status:      "pending",
        CreatedAt:   time.Now(),
        UpdatedAt:   time.Now(),
    }

    s.tasks[task.ID] = task
    return task, nil
}

// 모든 태스크 조회
func (s *TaskService) GetAllTasks() []*Task {
    tasks := make([]*Task, 0, len(s.tasks))
    for _, task := range s.tasks {
        tasks = append(tasks, task)
    }
    return tasks
}

// 특정 태스크 조회
func (s *TaskService) GetTaskByID(id string) (*Task, error) {
    task, exists := s.tasks[id]
    if !exists {
        return nil, fmt.Errorf("task not found")
    }
    return task, nil
}

// 태스크 상태 업데이트
func (s *TaskService) UpdateTaskStatus(id, status string) (*Task, error) {
    task, exists := s.tasks[id]
    if !exists {
        return nil, fmt.Errorf("task not found")
    }

    validStatuses := map[string]bool{
        "pending":     true,
        "in_progress": true,
        "completed":   true,
        "cancelled":   true,
    }

    if !validStatuses[status] {
        return nil, fmt.Errorf("invalid status")
    }

    task.Status = status
    task.UpdatedAt = time.Now()
    return task, nil
}

// 태스크 삭제
func (s *TaskService) DeleteTask(id string) error {
    if _, exists := s.tasks[id]; !exists {
        return fmt.Errorf("task not found")
    }
    delete(s.tasks, id)
    return nil
}
```

## REST API 서버 구현

### 1. 요청/응답 모델 정의

`models/models.go` 파일을 생성합니다:

```go
package models

import "go-rest-api/services"

// 태스크 생성 요청
type CreateTaskRequest struct {
    Title       string `json:"title" binding:"required"`
    Description string `json:"description"`
}

// 태스크 상태 업데이트 요청
type UpdateTaskStatusRequest struct {
    Status string `json:"status" binding:"required"`
}

// 성공 응답 (단일 태스크)
type TaskResponse struct {
    Success bool           `json:"success"`
    Data    *services.Task `json:"data"`
}

// 성공 응답 (태스크 리스트)
type TaskListResponse struct {
    Success bool             `json:"success"`
    Data    []*services.Task `json:"data"`
    Count   int              `json:"count"`
}

// 에러 응답
type ErrorResponse struct {
    Success bool   `json:"success"`
    Error   string `json:"error"`
}

// 일반 성공 응답
type SuccessResponse struct {
    Success bool   `json:"success"`
    Message string `json:"message"`
}
```

### 2. API 핸들러 구현

`handlers/handlers.go` 파일을 생성합니다:

```go
package handlers

import (
    "net/http"

    "go-rest-api/models"
    "go-rest-api/services"

    "github.com/gin-gonic/gin"
)

type APIHandler struct {
    taskService *services.TaskService
}

func NewAPIHandler(taskService *services.TaskService) *APIHandler {
    return &APIHandler{
        taskService: taskService,
    }
}

// 헬스 체크
func (h *APIHandler) HealthCheck(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
        "status":  "healthy",
        "message": "Go REST API Server is running",
        "version": "1.0.0",
    })
}

// 태스크 생성
func (h *APIHandler) CreateTask(c *gin.Context) {
    var req models.CreateTaskRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, models.ErrorResponse{
            Success: false,
            Error:   err.Error(),
        })
        return
    }

    task, err := h.taskService.CreateTask(req.Title, req.Description)
    if err != nil {
        c.JSON(http.StatusInternalServerError, models.ErrorResponse{
            Success: false,
            Error:   err.Error(),
        })
        return
    }

    c.JSON(http.StatusCreated, models.TaskResponse{
        Success: true,
        Data:    task,
    })
}

// 모든 태스크 조회
func (h *APIHandler) GetAllTasks(c *gin.Context) {
    tasks := h.taskService.GetAllTasks()

    c.JSON(http.StatusOK, models.TaskListResponse{
        Success: true,
        Data:    tasks,
        Count:   len(tasks),
    })
}

// 특정 태스크 조회
func (h *APIHandler) GetTaskByID(c *gin.Context) {
    id := c.Param("id")
    
    task, err := h.taskService.GetTaskByID(id)
    if err != nil {
        c.JSON(http.StatusNotFound, models.ErrorResponse{
            Success: false,
            Error:   err.Error(),
        })
        return
    }

    c.JSON(http.StatusOK, models.TaskResponse{
        Success: true,
        Data:    task,
    })
}

// 태스크 상태 업데이트
func (h *APIHandler) UpdateTaskStatus(c *gin.Context) {
    id := c.Param("id")
    
    var req models.UpdateTaskStatusRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, models.ErrorResponse{
            Success: false,
            Error:   err.Error(),
        })
        return
    }

    task, err := h.taskService.UpdateTaskStatus(id, req.Status)
    if err != nil {
        c.JSON(http.StatusNotFound, models.ErrorResponse{
            Success: false,
            Error:   err.Error(),
        })
        return
    }

    c.JSON(http.StatusOK, models.TaskResponse{
        Success: true,
        Data:    task,
    })
}

// 태스크 삭제
func (h *APIHandler) DeleteTask(c *gin.Context) {
    id := c.Param("id")
    
    err := h.taskService.DeleteTask(id)
    if err != nil {
        c.JSON(http.StatusNotFound, models.ErrorResponse{
            Success: false,
            Error:   err.Error(),
        })
        return
    }

    c.JSON(http.StatusOK, models.SuccessResponse{
        Success: true,
        Message: "Task deleted successfully",
    })
}
```

### 3. 라우터 설정

`routes/routes.go` 파일을 생성합니다:

```go
package routes

import (
    "go-rest-api/handlers"

    "github.com/gin-contrib/cors"
    "github.com/gin-gonic/gin"
)

func SetupRoutes(handler *handlers.APIHandler) *gin.Engine {
    // Gin 엔진 생성 (개발 모드)
    gin.SetMode(gin.DebugMode)
    r := gin.Default()

    // CORS 설정
    r.Use(cors.New(cors.Config{
        AllowOrigins:     []string{"*"},
        AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
        AllowHeaders:     []string{"*"},
        ExposeHeaders:    []string{"Content-Length"},
        AllowCredentials: true,
    }))

    // API 라우트 그룹
    api := r.Group("/api/v1")
    {
        // 헬스 체크
        api.GET("/health", handler.HealthCheck)
        
        // 태스크 관리 API
        api.POST("/tasks", handler.CreateTask)
        api.GET("/tasks", handler.GetAllTasks)
        api.GET("/tasks/:id", handler.GetTaskByID)
        api.PUT("/tasks/:id/status", handler.UpdateTaskStatus)
        api.DELETE("/tasks/:id", handler.DeleteTask)
    }

    return r
}
```

### 4. 메인 애플리케이션

`main.go` 파일을 생성합니다:

```go
package main

import (
    "log"

    "go-rest-api/config"
    "go-rest-api/handlers"
    "go-rest-api/routes"
    "go-rest-api/services"
)

func main() {
    // 설정 로드
    cfg := config.LoadConfig()

    // 태스크 서비스 초기화
    taskService := services.NewTaskService()

    // 핸들러 초기화
    handler := handlers.NewAPIHandler(taskService)

    // 라우터 설정
    router := routes.SetupRoutes(handler)

    // 서버 시작
    log.Printf("Server starting on port %s", cfg.Port)
    log.Printf("Environment: %s", cfg.AppEnv)
    if err := router.Run(":" + cfg.Port); err != nil {
        log.Fatal("Failed to start server:", err)
    }
}
```

## Docker 컨테이너로 실행하기

### 1. Dockerfile 생성

프로젝트 루트에 `Dockerfile`을 생성합니다:

```dockerfile
# Multi-stage build for Go application
FROM golang:1.21-alpine AS builder

# 작업 디렉토리 설정
WORKDIR /app

# Go 모듈 파일 복사
COPY go.mod go.sum ./

# 의존성 다운로드
RUN go mod download

# 소스코드 복사
COPY . .

# 애플리케이션 빌드
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# 실행 스테이지
FROM alpine:latest

# 필요한 패키지 설치
RUN apk --no-cache add ca-certificates tzdata

# 작업 디렉토리 설정
WORKDIR /root/

# 빌드된 바이너리 복사
COPY --from=builder /app/main .

# 포트 설정
EXPOSE 8080

# 애플리케이션 실행
CMD ["./main"]
```

### 2. Docker Compose 설정

`docker-compose.yml` 파일을 생성합니다:

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - PORT=8080
      - APP_ENV=development
      - LOG_LEVEL=info
    volumes:
      - .:/app
    networks:
      - app-network

  # 향후 AI 에이전트 연동을 위한 준비
  # ai-agent:
  #   image: your-ai-agent-image
  #   ports:
  #     - "8081:8081"
  #   environment:
  #     - API_ENDPOINT=http://app:8080
  #   networks:
  #     - app-network
  #   depends_on:
  #     - app

networks:
  app-network:
    driver: bridge
```

### 3. .dockerignore 파일 생성

```
.env
*.log
.git
.gitignore
README.md
Dockerfile
docker-compose.yml
```

## OrbStack으로 실행하기

### 1. Docker 이미지 빌드

```bash
# 이미지 빌드
docker build -t go-rest-api .

# 빌드 확인
docker images | grep go-rest-api
```

### 2. 단일 컨테이너 실행

```bash
# 컨테이너 실행
docker run -d \
  --name go-rest-api-container \
  -p 8080:8080 \
  -e APP_ENV=development \
  go-rest-api

# 실행 상태 확인
docker ps

# 로그 확인
docker logs go-rest-api-container
```

### 3. Docker Compose로 실행

```bash
# 서비스 시작
docker-compose up -d

# 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs -f

# 서비스 중지
docker-compose down
```

## API 테스트하기

### 1. 헬스 체크 테스트

```bash
curl http://localhost:8080/api/v1/health
```

예상 응답:

```json
{
  "message": "Go REST API Server is running",
  "status": "healthy",
  "version": "1.0.0"
}
```

### 2. 태스크 API 테스트

#### 태스크 생성

```bash
curl -X POST http://localhost:8080/api/v1/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "AI 에이전트 연동 준비",
    "description": "REST API 서버와 AI 에이전트 간 통신 인터페이스 설계"
  }'
```

#### 모든 태스크 조회

```bash
curl http://localhost:8080/api/v1/tasks
```

#### 특정 태스크 조회

```bash
curl http://localhost:8080/api/v1/tasks/{task_id}
```

#### 태스크 상태 업데이트

```bash
curl -X PUT http://localhost:8080/api/v1/tasks/{task_id}/status \
  -H "Content-Type: application/json" \
  -d '{"status": "in_progress"}'
```

#### 태스크 삭제

```bash
curl -X DELETE http://localhost:8080/api/v1/tasks/{task_id}
```

### 3. 웹 인터페이스 생성 (선택사항)

`static/index.html` 파일을 생성합니다:

```html
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Go REST API 태스크 관리</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 1000px; margin: 0 auto; padding: 20px; }
        .container { margin-bottom: 30px; padding: 20px; border: 1px solid #ddd; border-radius: 8px; }
        input, textarea, select { width: 100%; padding: 10px; margin: 5px 0; border: 1px solid #ddd; border-radius: 4px; }
        button { background: #007cba; color: white; padding: 10px 20px; border: none; cursor: pointer; border-radius: 4px; margin: 5px; }
        button:hover { background: #005a87; }
        .task-item { background: #f9f9f9; margin: 10px 0; padding: 15px; border-radius: 5px; }
        .status { padding: 4px 8px; border-radius: 4px; color: white; font-size: 12px; }
        .status.pending { background: #ffa500; }
        .status.in_progress { background: #007cba; }
        .status.completed { background: #28a745; }
        .status.cancelled { background: #dc3545; }
    </style>
</head>
<body>
    <h1>Go REST API 태스크 관리 시스템</h1>
    <p><em>AI 에이전트 연동을 위한 기반 서비스</em></p>
    
    <!-- 태스크 생성 -->
    <div class="container">
        <h2>새 태스크 생성</h2>
        <input type="text" id="taskTitle" placeholder="태스크 제목 (필수)">
        <textarea id="taskDescription" placeholder="태스크 설명 (선택사항)" rows="3"></textarea>
        <button onclick="createTask()">태스크 생성</button>
    </div>

    <!-- 태스크 목록 -->
    <div class="container">
        <h2>태스크 목록</h2>
        <button onclick="loadTasks()">새로고침</button>
        <div id="taskList"></div>
    </div>

    <script>
        const API_BASE = 'http://localhost:8080/api/v1';

        async function createTask() {
            const title = document.getElementById('taskTitle').value;
            const description = document.getElementById('taskDescription').value;
            
            if (!title.trim()) {
                alert('태스크 제목을 입력해주세요.');
                return;
            }

            try {
                const response = await fetch(`${API_BASE}/tasks`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ title, description })
                });

                const result = await response.json();
                if (result.success) {
                    document.getElementById('taskTitle').value = '';
                    document.getElementById('taskDescription').value = '';
                    loadTasks();
                    alert('태스크가 생성되었습니다.');
                } else {
                    alert('오류: ' + result.error);
                }
            } catch (error) {
                console.error('Error:', error);
                alert('네트워크 오류가 발생했습니다.');
            }
        }

        async function loadTasks() {
            try {
                const response = await fetch(`${API_BASE}/tasks`);
                const result = await response.json();
                
                if (result.success) {
                    displayTasks(result.data);
                } else {
                    alert('태스크 로드 실패: ' + result.error);
                }
            } catch (error) {
                console.error('Error:', error);
                alert('네트워크 오류가 발생했습니다.');
            }
        }

        async function updateTaskStatus(taskId, newStatus) {
            try {
                const response = await fetch(`${API_BASE}/tasks/${taskId}/status`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ status: newStatus })
                });

                const result = await response.json();
                if (result.success) {
                    loadTasks();
                } else {
                    alert('상태 업데이트 실패: ' + result.error);
                }
            } catch (error) {
                console.error('Error:', error);
            }
        }

        async function deleteTask(taskId) {
            if (!confirm('정말 이 태스크를 삭제하시겠습니까?')) return;

            try {
                const response = await fetch(`${API_BASE}/tasks/${taskId}`, {
                    method: 'DELETE'
                });

                const result = await response.json();
                if (result.success) {
                    loadTasks();
                    alert('태스크가 삭제되었습니다.');
                } else {
                    alert('삭제 실패: ' + result.error);
                }
            } catch (error) {
                console.error('Error:', error);
            }
        }

        function displayTasks(tasks) {
            const taskList = document.getElementById('taskList');
            
            if (tasks.length === 0) {
                taskList.innerHTML = '<p>등록된 태스크가 없습니다.</p>';
                return;
            }

            taskList.innerHTML = tasks.map(task => `
                <div class="task-item">
                    <h3>${task.title}</h3>
                    <p>${task.description || '설명 없음'}</p>
                    <p><strong>상태:</strong> <span class="status ${task.status}">${getStatusText(task.status)}</span></p>
                    <p><strong>생성일:</strong> ${new Date(task.created_at).toLocaleString()}</p>
                    <p><strong>수정일:</strong> ${new Date(task.updated_at).toLocaleString()}</p>
                    
                    <select onchange="updateTaskStatus('${task.id}', this.value)">
                        <option value="">상태 변경</option>
                        <option value="pending" ${task.status === 'pending' ? 'disabled' : ''}>대기중</option>
                        <option value="in_progress" ${task.status === 'in_progress' ? 'disabled' : ''}>진행중</option>
                        <option value="completed" ${task.status === 'completed' ? 'disabled' : ''}>완료</option>
                        <option value="cancelled" ${task.status === 'cancelled' ? 'disabled' : ''}>취소</option>
                    </select>
                    
                    <button onclick="deleteTask('${task.id}')" style="background: #dc3545;">삭제</button>
                </div>
            `).join('');
        }

        function getStatusText(status) {
            const statusMap = {
                pending: '대기중',
                in_progress: '진행중',
                completed: '완료',
                cancelled: '취소'
            };
            return statusMap[status] || status;
        }

        // 페이지 로드 시 태스크 목록 불러오기
        document.addEventListener('DOMContentLoaded', loadTasks);
    </script>
</body>
</html>
```

라우터에 정적 파일 서빙을 추가하세요:

```go
// routes/routes.go에 추가
r.Static("/static", "./static")
r.StaticFile("/", "./static/index.html")
```

## 개발 환경 최적화

### 1. 라이브 리로드 설정

개발 중 코드 변경 시 자동으로 재시작되도록 설정:

```bash
# Air 설치 (Go 라이브 리로드 도구)
go install github.com/cosmtrek/air@latest

# .air.toml 설정 파일 생성
air init
```

### 2. 디버깅 설정

VS Code에서 디버깅할 수 있도록 `.vscode/launch.json` 설정:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch Package",
            "type": "go",
            "request": "launch",
            "mode": "auto",
            "program": "${workspaceFolder}",
            "env": {
                "APP_ENV": "development"
            }
        }
    ]
}
```

### 3. Git 설정

`.gitignore` 파일 생성:

```
# 환경 설정
.env
.env.local
.env.*.local

# 빌드 결과물
/main
/go-rest-api

# 로그 파일
*.log

# 운영체제 파일
.DS_Store
Thumbs.db

# IDE 설정
.vscode/
.idea/

# Docker 볼륨 데이터
/data/

# 테스트 결과
coverage.out
```

## 다음 단계: AI 에이전트 연동 준비

이 기본 REST API 서비스는 향후 AI 에이전트와 연동하기 위한 기반이 됩니다. 다음 단계에서는:

### 1. AI 에이전트 연동 인터페이스 설계

```go
// 향후 추가될 AI 에이전트 서비스 인터페이스
type AIAgentService interface {
    ProcessTask(task *Task) (*AgentResponse, error)
    GetAgentStatus() (*AgentStatus, error)
    RegisterWebhook(endpoint string) error
}
```

### 2. 웹훅 시스템 구현

AI 에이전트가 태스크 완료 시 알림을 보낼 수 있도록 웹훅 엔드포인트 추가 예정.

### 3. 큐 시스템 도입

Redis나 RabbitMQ를 활용한 태스크 큐 시스템으로 확장 가능.

### 4. 데이터베이스 연동

PostgreSQL이나 MongoDB 연동으로 태스크 영속성 확보.

### 5. 모니터링 및 로깅

Prometheus + Grafana를 활용한 모니터링 시스템 구축.

## 문제 해결 가이드

### 자주 발생하는 오류들

#### 1. "Port already in use" 오류

**원인**: 포트 8080이 이미 사용 중  
**해결**: 다른 포트 사용 또는 기존 프로세스 종료

```bash
# 포트 사용 중인 프로세스 확인
lsof -i :8080

# 프로세스 종료
kill -9 <PID>
```

#### 2. "Docker daemon not running" 오류

**원인**: OrbStack이나 Docker Desktop이 실행되지 않음  
**해결**: OrbStack 실행 확인

```bash
orb status
```

#### 3. "Module not found" 오류

**원인**: Go 모듈 의존성 문제  
**해결**: 모듈 재설치

```bash
go mod tidy
go mod download
```

## 결론

이 가이드를 통해 다음을 구축했습니다:

### 완성된 기능들

1. **Go REST API 서버**: 태스크 관리 시스템
2. **Docker 컨테이너화**: OrbStack을 활용한 로컬 개발 환경
3. **완전한 CRUD API**: 태스크 생성, 조회, 수정, 삭제
4. **웹 인터페이스**: 브라우저에서 테스트 가능한 UI
5. **확장 가능한 구조**: AI 에이전트 연동을 위한 기반 구조

### 개발 환경의 장점

- **빠른 개발**: OrbStack의 뛰어난 macOS 최적화
- **격리된 환경**: Docker 컨테이너로 일관된 개발 환경
- **쉬운 확장**: Docker Compose로 마이크로서비스 확장 가능
- **AI 에이전트 준비**: 향후 AI 에이전트 연동을 위한 인터페이스 준비 완료

이제 이 기반 서비스 위에 AI 에이전트를 연동하여 더욱 강력한 자동화 시스템을 구축할 수 있습니다!

---

**참고 링크:**

- [Go 공식 문서](https://golang.org/doc/)
- [Gin 웹 프레임워크](https://gin-gonic.com/)
- [OrbStack 공식 사이트](https://orbstack.dev/)
- [Docker Compose 문서](https://docs.docker.com/compose/)
