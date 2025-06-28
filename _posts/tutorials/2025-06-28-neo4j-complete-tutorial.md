---
title: "Neo4j 완전 정복: macOS에서 그래프 데이터베이스 시작하기"
excerpt: "Neo4j 설치부터 Cypher 쿼리까지, 실제 테스트를 통한 완전한 가이드"
seo_title: "Neo4j 완전 가이드 - macOS 설치와 Cypher 쿼리 튜토리얼 - Thaki Cloud"
seo_description: "Neo4j 그래프 데이터베이스를 macOS에서 설치하고 사용하는 완전한 가이드. Homebrew 설치, Cypher 쿼리, 실전 예제 포함 (150자)"
date: 2025-06-28
categories: 
  - tutorials
  - dev
tags: 
  - Neo4j
  - 그래프데이터베이스
  - Cypher
  - macOS
  - Homebrew
  - NoSQL
author_profile: true
toc: true
toc_label: "Neo4j 튜토리얼"
canonical_url: "https://thakicloud.github.io/tutorials/neo4j-complete-tutorial/"
---

Neo4j는 세계에서 가장 인기 있는 그래프 데이터베이스입니다. 관계형 데이터베이스와 달리 노드(Node)와 관계(Relationship)로 데이터를 저장하여, 복잡한 관계를 직관적으로 표현하고 빠르게 탐색할 수 있습니다.

이 튜토리얼에서는 macOS에서 Neo4j를 설치하고, Cypher 쿼리 언어를 사용하여 실제 그래프 데이터를 다루는 방법을 단계별로 알아보겠습니다.

## 개발환경 정보

테스트 환경:
- **운영체제**: macOS Sequoia 15.0 (Darwin 25.0.0)
- **Neo4j 버전**: 2025.05.0
- **Java 버전**: 1.8.0_421
- **Cypher Shell**: 2025.05.0
- **패키지 관리자**: Homebrew 4.5.8

## Neo4j란 무엇인가?

### 그래프 데이터베이스의 특징

그래프 데이터베이스는 다음과 같은 특징을 가집니다:

- **노드(Nodes)**: 엔티티를 나타내는 객체
- **관계(Relationships)**: 노드 간의 연결
- **속성(Properties)**: 노드와 관계가 가질 수 있는 키-값 쌍
- **레이블(Labels)**: 노드의 타입을 분류하는 태그

### Neo4j의 장점

1. **직관적인 데이터 모델링**: 실제 세계의 관계를 그대로 표현
2. **빠른 관계 탐색**: JOIN 없이 관계를 직접 순회
3. **유연한 스키마**: 동적으로 스키마 변경 가능
4. **강력한 쿼리 언어**: Cypher를 통한 직관적인 쿼리 작성

## Neo4j 설치하기

### Homebrew를 통한 설치

```bash
# Homebrew가 설치되어 있는지 확인
brew --version

# Neo4j 설치
brew install neo4j
```

설치 과정에서 다음 구성요소들이 함께 설치됩니다:
- OpenJDK 21 (Neo4j 실행을 위한 Java 환경)
- Cypher Shell (Neo4j와 상호작용하기 위한 명령줄 도구)

### 설치 확인

```bash
# Neo4j 버전 확인
neo4j version
# 출력: neo4j 2025.05.0

# Cypher Shell 버전 확인
cypher-shell --version
# 출력: Cypher-Shell 2025.05.0
```

## Neo4j 서비스 시작하기

### 서비스 시작

```bash
# Neo4j 서비스 시작
brew services start neo4j

# 서비스 상태 확인
brew services list | grep neo4j
# 출력: neo4j         started         hanhyojung ~/Library/LaunchAgents/homebrew.mxcl.neo4j.plist
```

### 초기 비밀번호 설정

Neo4j를 처음 설치하면 보안을 위해 기본 비밀번호를 변경해야 합니다:

```bash
# system 데이터베이스에 연결하여 비밀번호 변경
echo "ALTER CURRENT USER SET PASSWORD FROM 'neo4j' TO 'password123';" | \
  cypher-shell -u neo4j -p neo4j --database system
```

## Cypher Shell 사용하기

### 기본 연결

```bash
# Neo4j 데이터베이스에 연결
cypher-shell -u neo4j -p password123 --database neo4j
```

### 기본 테스트

다음 간단한 쿼리로 연결을 확인해보겠습니다:

```cypher
// 연결 테스트
RETURN "Hello, Neo4j!" AS message;
```

**실행 결과:**
```
message
"Hello, Neo4j!"
```

## Cypher 쿼리 기초

### 노드 생성

```cypher
// 단일 노드 생성
CREATE (p:Person {name: "Alice", age: 30});

// 여러 노드 생성
CREATE (p1:Person {name: "Bob", age: 25});
CREATE (p2:Person {name: "Charlie", age: 35});
CREATE (c:Company {name: "TechCorp", industry: "Technology"});
```

### 관계 생성

```cypher
// 노드 간 관계 생성
MATCH (alice:Person {name: "Alice"}), (bob:Person {name: "Bob"})
CREATE (alice)-[:KNOWS {since: 2020}]->(bob);

// 회사와 직원 관계
MATCH (alice:Person {name: "Alice"}), (company:Company {name: "TechCorp"})
CREATE (alice)-[:WORKS_FOR {position: "Developer", salary: 70000}]->(company);
```

### 데이터 조회

```cypher
// 모든 Person 노드 조회
MATCH (p:Person) RETURN p.name, p.age;

// 관계를 포함한 조회
MATCH (p1:Person)-[r:KNOWS]->(p2:Person) 
RETURN p1.name + " knows " + p2.name AS relationship;
```

**실행 결과:**
```
p.name, p.age
"Alice", 30
"Bob", 25
"Charlie", 35

relationship
"Alice knows Bob"
```

### 고급 쿼리

```cypher
// 경로 탐색: 2단계 관계
MATCH path = (p1:Person)-[:KNOWS*1..2]->(p2:Person)
WHERE p1.name = "Alice"
RETURN p2.name AS connected_person;

// 집계 함수 사용
MATCH (p:Person)-[:WORKS_FOR]->(c:Company)
RETURN c.name AS company, COUNT(p) AS employee_count, AVG(p.age) AS avg_age;

// 조건부 업데이트
MATCH (p:Person {name: "Alice"})
SET p.city = "Seoul", p.updated = timestamp();
```

## 실전 예제: 소셜 네트워크 모델링

### 샘플 데이터 생성

```cypher
// 기존 데이터 정리
MATCH (n) DETACH DELETE n;

// 사용자 생성
CREATE (alice:Person {name: "Alice", age: 30, city: "Seoul"});
CREATE (bob:Person {name: "Bob", age: 25, city: "Busan"});
CREATE (charlie:Person {name: "Charlie", age: 35, city: "Incheon"});
CREATE (diana:Person {name: "Diana", age: 28, city: "Seoul"});

// 회사 생성
CREATE (techcorp:Company {name: "TechCorp", industry: "Technology"});
CREATE (datainc:Company {name: "DataInc", industry: "Analytics"});

// 관계 생성
MATCH (alice:Person {name: "Alice"}), (bob:Person {name: "Bob"})
CREATE (alice)-[:KNOWS {since: 2020}]->(bob);

MATCH (bob:Person {name: "Bob"}), (charlie:Person {name: "Charlie"})
CREATE (bob)-[:KNOWS {since: 2019}]->(charlie);

// 직장 관계
MATCH (alice:Person {name: "Alice"}), (techcorp:Company {name: "TechCorp"})
CREATE (alice)-[:WORKS_FOR {position: "Developer", salary: 70000}]->(techcorp);

MATCH (diana:Person {name: "Diana"}), (techcorp:Company {name: "TechCorp"})
CREATE (diana)-[:WORKS_FOR {position: "Designer", salary: 60000}]->(techcorp);
```

### 복잡한 분석 쿼리

```cypher
// 1. 같은 회사에서 일하는 사람들 찾기
MATCH (p1:Person)-[:WORKS_FOR]->(c:Company)<-[:WORKS_FOR]-(p2:Person)
WHERE p1.name <> p2.name
RETURN c.name AS company, COLLECT(p1.name) AS colleagues;

// 2. 친구의 친구 추천 (2도 관계)
MATCH (alice:Person {name: "Alice"})-[:KNOWS*2]-(recommendation:Person)
WHERE NOT (alice)-[:KNOWS]-(recommendation) AND alice <> recommendation
RETURN DISTINCT recommendation.name AS suggested_friend;

// 3. 도시별 평균 연봉
MATCH (p:Person)-[w:WORKS_FOR]->(c:Company)
RETURN p.city AS city, AVG(w.salary) AS avg_salary, COUNT(p) AS people_count
ORDER BY avg_salary DESC;
```

## 편리한 사용을 위한 Alias 설정

macOS에서 Neo4j를 더 편리하게 사용하기 위해 zsh 별칭을 설정할 수 있습니다.

### Alias 설정 스크립트

다음 스크립트를 실행하여 유용한 별칭들을 추가해보세요:

```bash
#!/bin/bash

# ~/.zshrc에 Neo4j 관련 alias 추가
cat >> ~/.zshrc << 'EOF'

# Neo4j 관련 Aliases
alias neo4j-start='brew services start neo4j'
alias neo4j-stop='brew services stop neo4j'
alias neo4j-restart='brew services restart neo4j'
alias neo4j-status='brew services list | grep neo4j'
alias neo4j-shell='cypher-shell -u neo4j -p password123 --database neo4j'
alias neo4j-system='cypher-shell -u neo4j -p password123 --database system'
alias neo4j-version='neo4j version'

# 빠른 테스트 함수
neo4j-test() {
    echo "Neo4j 연결 테스트 중..."
    echo "RETURN 'Neo4j is working!' AS status;" | \
      cypher-shell -u neo4j -p password123 --database neo4j
}

EOF

# 설정 적용
source ~/.zshrc
```

### 사용 가능한 명령어들

설정 후 다음 명령어들을 사용할 수 있습니다:

- `neo4j-start`: Neo4j 서비스 시작
- `neo4j-stop`: Neo4j 서비스 중지
- `neo4j-status`: 서비스 상태 확인
- `neo4j-shell`: Cypher Shell 바로 접속
- `neo4j-test`: 연결 테스트

## 성능 최적화 팁

### 인덱스 생성

```cypher
// 자주 검색하는 속성에 인덱스 생성
CREATE INDEX person_name_index FOR (p:Person) ON (p.name);
CREATE INDEX company_name_index FOR (c:Company) ON (c.name);

// 인덱스 확인
SHOW INDEXES;
```

### 쿼리 최적화

```cypher
// 비효율적인 쿼리 (전체 스캔)
MATCH (p:Person) WHERE p.name = "Alice" RETURN p;

// 효율적인 쿼리 (레이블과 속성 동시 사용)
MATCH (p:Person {name: "Alice"}) RETURN p;

// EXPLAIN으로 실행 계획 확인
EXPLAIN MATCH (p:Person {name: "Alice"}) RETURN p;
```

### 대용량 데이터 처리

```cypher
// 배치 처리를 위한 PERIODIC COMMIT 사용
:auto USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///large_dataset.csv' AS row
CREATE (p:Person {name: row.name, age: toInteger(row.age)});
```

## 웹 인터페이스 사용하기

Neo4j는 웹 브라우저에서 사용할 수 있는 Neo4j Browser를 제공합니다:

1. 웹 브라우저에서 `http://localhost:7474` 접속
2. 사용자명: `neo4j`, 비밀번호: `password123`으로 로그인
3. 그래픽 인터페이스로 그래프 시각화 및 쿼리 실행 가능

## 백업과 복원

### 데이터 백업

```bash
# Neo4j 서비스 중지
neo4j-stop

# 데이터 백업
cp -r /opt/homebrew/var/neo4j/data ~/neo4j_backup_$(date +%Y%m%d)

# 서비스 재시작
neo4j-start
```

### 데이터 내보내기

```cypher
// CSV로 데이터 내보내기
MATCH (p:Person)
RETURN p.name, p.age, p.city
// 결과를 CSV로 저장 가능
```

## 트러블슈팅

### 일반적인 문제들

1. **포트 충돌**: 기본 포트 7474가 사용 중인 경우
   ```bash
   # 포트 사용 확인
   lsof -i :7474
   
   # 설정 파일에서 포트 변경
   # /opt/homebrew/etc/neo4j/neo4j.conf
   ```

2. **메모리 부족**: 대용량 데이터 처리 시
   ```bash
   # JVM 힙 크기 조정
   export NEO4J_HEAP_SIZE=2G
   ```

3. **권한 문제**: 데이터 디렉터리 접근 권한
   ```bash
   # 권한 확인 및 수정
   chmod -R 755 /opt/homebrew/var/neo4j
   ```

## 실제 테스트 결과 요약

이 튜토리얼에서 실행한 테스트들의 결과를 요약하면:

- ✅ **설치 성공**: Homebrew를 통한 Neo4j 2025.05.0 설치 완료
- ✅ **서비스 실행**: 백그라운드 서비스로 정상 실행
- ✅ **연결 테스트**: Cypher Shell을 통한 데이터베이스 연결 성공
- ✅ **CRUD 작업**: 노드 생성, 관계 설정, 데이터 조회 모두 정상 동작
- ✅ **Alias 설정**: zsh 별칭을 통한 편의 기능 구현 완료

## 다음 단계

Neo4j 기초를 익혔다면 다음 주제들을 학습해보세요:

1. **고급 Cypher 쿼리**: 집계, 경로 분석, 그래프 알고리즘
2. **Neo4j 드라이버**: Python, Java, JavaScript 등 언어별 연동
3. **그래프 알고리즘**: PageRank, Community Detection, Shortest Path
4. **Neo4j 클러스터링**: 고가용성과 확장성 구현
5. **그래프 시각화**: D3.js, Vis.js 등을 활용한 시각화

## 결론

Neo4j는 복잡한 관계를 다루는 현대 애플리케이션에서 매우 유용한 도구입니다. 소셜 네트워크, 추천 시스템, 지식 그래프, 사기 탐지 등 다양한 영역에서 활용할 수 있습니다.

이 튜토리얼을 통해 Neo4j의 기본기를 익혔다면, 이제 실제 프로젝트에서 그래프 데이터베이스의 강력함을 경험해보시기 바랍니다. 관계형 데이터베이스로는 어려웠던 복잡한 관계 분석이 Neo4j를 통해 얼마나 직관적이고 효율적으로 처리될 수 있는지 확인할 수 있을 것입니다. 