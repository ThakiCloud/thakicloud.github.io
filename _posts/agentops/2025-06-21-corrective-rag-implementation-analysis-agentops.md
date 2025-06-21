---
title: "Corrective RAG 완전 분석: 자체 평가 메커니즘으로 RAG 시스템 혁신하기"
excerpt: "Corrective RAG의 핵심 구현 원리와 자체 평가 메커니즘을 AgentOps 관점에서 상세 분석하고, 실전 구현 방법을 제시합니다."
date: 2025-06-21
categories: 
  - agentops
tags: 
  - Corrective-RAG
  - Self-Assessment
  - RAG-Enhancement
  - Document-Evaluation
  - AgentOps
  - LLM
  - Retrieval-Systems
author_profile: true
toc: true
toc_label: "Corrective RAG 분석"
---

## 개요

[Corrective RAG (CRAG)](https://github.com/HuskyInSalt/CRAG)는 기존 RAG 시스템의 한계를 극복하기 위해 **자체 평가 메커니즘**을 도입한 혁신적인 접근법입니다. 검색된 문서의 품질을 동적으로 평가하고, 필요에 따라 웹 검색이나 지식 정제를 수행하여 더 정확한 응답을 생성합니다.

### Corrective RAG의 핵심 원리

**기존 RAG의 문제점:**
- 검색된 문서의 관련성을 검증하지 않음
- 부정확한 정보가 포함된 경우 잘못된 답변 생성
- 정적인 코퍼스에만 의존하여 최신 정보 부족

**CRAG의 해결책:**
- **검색 평가기(Retrieval Evaluator)**: 문서 품질 자동 평가
- **적응적 지식 검색**: 상황에 따른 다양한 검색 전략
- **분해-재구성 알고리즘**: 핵심 정보 추출 및 노이즈 제거

## 시스템 아키텍처 분석

### 1. 전체 워크플로우

```python
# CRAG 시스템의 전체 워크플로우
class CorrectiveRAGSystem:
    def __init__(self):
        self.retrieval_evaluator = RetrievalEvaluator()
        self.knowledge_refiner = KnowledgeRefiner()
        self.web_searcher = WebSearcher()
        self.response_generator = ResponseGenerator()
    
    def process_query(self, query: str) -> str:
        """CRAG 메인 프로세스"""
        
        # 1. 초기 문서 검색
        retrieved_docs = self.initial_retrieval(query)
        
        # 2. 검색 품질 평가
        evaluation_result = self.retrieval_evaluator.evaluate(
            query, retrieved_docs
        )
        
        # 3. 평가 결과에 따른 액션 결정
        if evaluation_result.confidence >= 0.8:
            # CORRECT: 문서 정제 후 사용
            refined_knowledge = self.knowledge_refiner.refine(
                retrieved_docs, query
            )
            knowledge_source = refined_knowledge
            
        elif evaluation_result.confidence <= 0.3:
            # INCORRECT: 웹 검색으로 대체
            web_results = self.web_searcher.search(query)
            knowledge_source = web_results
            
        else:
            # AMBIGUOUS: 정제된 문서 + 웹 검색 결합
            refined_docs = self.knowledge_refiner.refine(
                retrieved_docs, query
            )
            web_results = self.web_searcher.search(query)
            knowledge_source = self.combine_sources(
                refined_docs, web_results
            )
        
        # 4. 최종 응답 생성
        response = self.response_generator.generate(
            query, knowledge_source
        )
        
        return response
```

### 2. 검색 평가기 (Retrieval Evaluator)

검색 평가기는 CRAG의 핵심 컴포넌트로, 검색된 문서의 품질을 평가합니다.

```python
# 검색 평가기 구현
class RetrievalEvaluator:
    def __init__(self, model_path: str):
        self.model = AutoModelForSequenceClassification.from_pretrained(
            model_path
        )
        self.tokenizer = AutoTokenizer.from_pretrained(model_path)
        
    def evaluate(self, query: str, documents: List[str]) -> EvaluationResult:
        """문서 관련성 평가"""
        
        scores = []
        
        for doc in documents:
            # 쿼리-문서 쌍을 입력으로 구성
            input_text = f"Query: {query}\nDocument: {doc}"
            
            # 토큰화 및 모델 추론
            inputs = self.tokenizer(
                input_text,
                return_tensors="pt",
                max_length=512,
                truncation=True,
                padding=True
            )
            
            with torch.no_grad():
                outputs = self.model(**inputs)
                
            # 관련성 점수 계산 (0-1 범위)
            relevance_score = torch.softmax(outputs.logits, dim=-1)[0][1].item()
            scores.append(relevance_score)
        
        # 전체 검색 품질 평가
        avg_score = sum(scores) / len(scores)
        confidence = self._calculate_confidence(scores)
        
        return EvaluationResult(
            average_score=avg_score,
            confidence=confidence,
            individual_scores=scores,
            action=self._determine_action(confidence)
        )
    
    def _calculate_confidence(self, scores: List[float]) -> float:
        """신뢰도 계산"""
        if not scores:
            return 0.0
        
        # 평균 점수와 분산을 고려한 신뢰도
        avg_score = sum(scores) / len(scores)
        variance = sum((s - avg_score) ** 2 for s in scores) / len(scores)
        
        # 높은 평균 점수와 낮은 분산이 높은 신뢰도를 의미
        confidence = avg_score * (1 - variance)
        
        return max(0.0, min(1.0, confidence))
    
    def _determine_action(self, confidence: float) -> str:
        """신뢰도 기반 액션 결정"""
        if confidence >= 0.8:
            return "CORRECT"
        elif confidence <= 0.3:
            return "INCORRECT"
        else:
            return "AMBIGUOUS"
```

### 3. 지식 정제기 (Knowledge Refiner)

검색된 문서에서 핵심 정보만 추출하여 노이즈를 제거합니다.

```python
# 지식 정제기 구현
class KnowledgeRefiner:
    def __init__(self, llm_model: str = "gpt-3.5-turbo"):
        self.llm = ChatOpenAI(model=llm_model, temperature=0)
        
    def refine(self, documents: List[str], query: str) -> List[str]:
        """문서 분해-재구성을 통한 지식 정제"""
        
        refined_knowledge = []
        
        for doc in documents:
            # 1. 문서를 의미 단위로 분해
            segments = self._decompose_document(doc)
            
            # 2. 각 세그먼트의 관련성 평가
            relevant_segments = self._filter_relevant_segments(
                segments, query
            )
            
            # 3. 관련 세그먼트 재구성
            if relevant_segments:
                refined_doc = self._recompose_segments(relevant_segments)
                refined_knowledge.append(refined_doc)
        
        return refined_knowledge
    
    def _decompose_document(self, document: str) -> List[str]:
        """문서를 의미 단위로 분해"""
        
        decomposition_prompt = f"""
        다음 문서를 의미적으로 완결된 세그먼트들로 분해하세요.
        각 세그먼트는 하나의 완전한 아이디어나 사실을 포함해야 합니다.
        
        문서: {document}
        
        세그먼트들을 [SEGMENT] 태그로 구분하여 출력하세요.
        """
        
        response = self.llm.invoke(decomposition_prompt)
        
        # 응답에서 세그먼트 추출
        segments = []
        lines = response.content.split('\n')
        current_segment = ""
        
        for line in lines:
            if line.startswith('[SEGMENT]'):
                if current_segment.strip():
                    segments.append(current_segment.strip())
                current_segment = ""
            else:
                current_segment += line + '\n'
        
        if current_segment.strip():
            segments.append(current_segment.strip())
        
        return segments
    
    def _filter_relevant_segments(
        self, 
        segments: List[str], 
        query: str
    ) -> List[str]:
        """쿼리와 관련된 세그먼트만 필터링"""
        
        relevant_segments = []
        
        for segment in segments:
            relevance_prompt = f"""
            다음 세그먼트가 주어진 쿼리와 관련이 있는지 평가하세요.
            
            쿼리: {query}
            세그먼트: {segment}
            
            관련성이 있으면 "YES", 없으면 "NO"로만 답하세요.
            """
            
            response = self.llm.invoke(relevance_prompt)
            
            if "YES" in response.content.upper():
                relevant_segments.append(segment)
        
        return relevant_segments
    
    def _recompose_segments(self, segments: List[str]) -> str:
        """관련 세그먼트들을 논리적으로 재구성"""
        
        recomposition_prompt = f"""
        다음 세그먼트들을 논리적으로 연결하여 
        일관성 있는 문서로 재구성하세요.
        
        세그먼트들:
        {chr(10).join(f"{i+1}. {seg}" for i, seg in enumerate(segments))}
        
        재구성된 문서:
        """
        
        response = self.llm.invoke(recomposition_prompt)
        return response.content
```

### 4. 웹 검색기 (Web Searcher)

로컬 코퍼스에서 충분한 정보를 얻지 못할 때 웹 검색을 수행합니다.

```python
# 웹 검색기 구현
class WebSearcher:
    def __init__(self, search_api_key: str, search_engine_id: str):
        self.api_key = search_api_key
        self.engine_id = search_engine_id
        self.llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0)
        
    def search(self, query: str) -> List[str]:
        """쿼리 재작성 후 웹 검색 수행"""
        
        # 1. 쿼리 재작성
        rewritten_queries = self._rewrite_query(query)
        
        # 2. 각 재작성된 쿼리로 검색
        all_results = []
        
        for rewritten_query in rewritten_queries:
            search_results = self._perform_search(rewritten_query)
            all_results.extend(search_results)
        
        # 3. 결과 중복 제거 및 정제
        unique_results = self._deduplicate_results(all_results)
        refined_results = self._refine_search_results(unique_results, query)
        
        return refined_results
    
    def _rewrite_query(self, original_query: str) -> List[str]:
        """검색 효율성을 위한 쿼리 재작성"""
        
        rewrite_prompt = f"""
        다음 질문에 대해 웹 검색에 최적화된 검색 쿼리들을 생성하세요.
        원래 질문의 의도를 유지하면서 다양한 관점에서 접근하세요.
        
        원래 질문: {original_query}
        
        3-5개의 검색 쿼리를 생성하고, 각각을 새 줄에 작성하세요.
        """
        
        response = self.llm.invoke(rewrite_prompt)
        
        # 응답에서 쿼리들 추출
        queries = [
            line.strip() 
            for line in response.content.split('\n') 
            if line.strip() and not line.startswith('#')
        ]
        
        return queries[:5]  # 최대 5개로 제한
    
    def _perform_search(self, query: str) -> List[Dict]:
        """실제 웹 검색 수행"""
        
        search_url = "https://www.googleapis.com/customsearch/v1"
        
        params = {
            'key': self.api_key,
            'cx': self.engine_id,
            'q': query,
            'num': 5  # 상위 5개 결과만
        }
        
        try:
            response = requests.get(search_url, params=params)
            response.raise_for_status()
            
            search_data = response.json()
            
            results = []
            for item in search_data.get('items', []):
                results.append({
                    'title': item.get('title', ''),
                    'snippet': item.get('snippet', ''),
                    'link': item.get('link', ''),
                    'content': self._extract_content(item.get('link', ''))
                })
            
            return results
            
        except Exception as e:
            print(f"웹 검색 오류: {e}")
            return []
    
    def _extract_content(self, url: str) -> str:
        """웹페이지에서 텍스트 콘텐츠 추출"""
        
        try:
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.content, 'html.parser')
            
            # 불필요한 태그 제거
            for tag in soup(['script', 'style', 'nav', 'footer', 'header']):
                tag.decompose()
            
            # 텍스트 추출
            text = soup.get_text()
            
            # 정제
            lines = [line.strip() for line in text.splitlines()]
            content = '\n'.join(line for line in lines if line)
            
            # 길이 제한
            return content[:2000]
            
        except Exception as e:
            print(f"콘텐츠 추출 오류 ({url}): {e}")
            return ""
    
    def _deduplicate_results(self, results: List[Dict]) -> List[Dict]:
        """중복 결과 제거"""
        
        seen_urls = set()
        unique_results = []
        
        for result in results:
            url = result.get('link', '')
            if url not in seen_urls and result.get('content'):
                seen_urls.add(url)
                unique_results.append(result)
        
        return unique_results
    
    def _refine_search_results(
        self, 
        results: List[Dict], 
        original_query: str
    ) -> List[str]:
        """검색 결과를 원래 쿼리와 관련된 내용으로 정제"""
        
        refined_contents = []
        
        for result in results:
            content = result.get('content', '')
            if not content:
                continue
            
            refine_prompt = f"""
            다음 웹 콘텐츠에서 주어진 질문과 관련된 정보만 추출하세요.
            관련 없는 정보는 제거하고, 핵심 내용만 정리하세요.
            
            질문: {original_query}
            
            웹 콘텐츠:
            {content}
            
            관련 정보:
            """
            
            response = self.llm.invoke(refine_prompt)
            
            refined_content = response.content.strip()
            if refined_content and len(refined_content) > 50:
                refined_contents.append(refined_content)
        
        return refined_contents
```

## AgentOps 관점에서의 구현

### 1. 모니터링 및 로깅

```python
import agentops
from typing import Dict, Any

class CRAGWithAgentOps:
    def __init__(self):
        # AgentOps 초기화
        agentops.init(api_key=os.getenv('AGENTOPS_API_KEY'))
        
        self.retrieval_evaluator = RetrievalEvaluator()
        self.knowledge_refiner = KnowledgeRefiner()
        self.web_searcher = WebSearcher()
        self.response_generator = ResponseGenerator()
    
    @agentops.record_function('crag_full_pipeline')
    def process_query(self, query: str) -> str:
        """AgentOps 모니터링이 포함된 CRAG 파이프라인"""
        
        # 메트릭 수집을 위한 컨텍스트
        metrics = {
            'query_length': len(query),
            'start_time': time.time()
        }
        
        try:
            # 1. 초기 검색
            retrieved_docs = self._initial_retrieval_with_monitoring(query)
            metrics['retrieved_docs_count'] = len(retrieved_docs)
            
            # 2. 검색 품질 평가
            evaluation_result = self._evaluate_with_monitoring(
                query, retrieved_docs
            )
            metrics['evaluation_confidence'] = evaluation_result.confidence
            metrics['evaluation_action'] = evaluation_result.action
            
            # 3. 액션 실행
            knowledge_source = self._execute_action_with_monitoring(
                evaluation_result, query, retrieved_docs
            )
            metrics['final_knowledge_source_length'] = len(str(knowledge_source))
            
            # 4. 응답 생성
            response = self._generate_response_with_monitoring(
                query, knowledge_source
            )
            
            # 성공 메트릭 기록
            metrics['success'] = True
            metrics['response_length'] = len(response)
            metrics['total_time'] = time.time() - metrics['start_time']
            
            agentops.record_action({
                'action_type': 'crag_success',
                'metrics': metrics
            })
            
            return response
            
        except Exception as e:
            # 에러 메트릭 기록
            metrics['success'] = False
            metrics['error'] = str(e)
            metrics['total_time'] = time.time() - metrics['start_time']
            
            agentops.record_action({
                'action_type': 'crag_error',
                'metrics': metrics
            })
            
            raise
    
    @agentops.record_function('retrieval_evaluation')
    def _evaluate_with_monitoring(
        self, 
        query: str, 
        documents: List[str]
    ) -> EvaluationResult:
        """모니터링이 포함된 검색 평가"""
        
        start_time = time.time()
        
        result = self.retrieval_evaluator.evaluate(query, documents)
        
        # 평가 메트릭 기록
        agentops.record_action({
            'action_type': 'retrieval_evaluation',
            'metrics': {
                'evaluation_time': time.time() - start_time,
                'confidence_score': result.confidence,
                'average_relevance': result.average_score,
                'action_decided': result.action,
                'documents_evaluated': len(documents)
            }
        })
        
        return result
    
    @agentops.record_function('knowledge_refinement')
    def _refine_knowledge_with_monitoring(
        self, 
        documents: List[str], 
        query: str
    ) -> List[str]:
        """모니터링이 포함된 지식 정제"""
        
        start_time = time.time()
        original_length = sum(len(doc) for doc in documents)
        
        refined_docs = self.knowledge_refiner.refine(documents, query)
        
        refined_length = sum(len(doc) for doc in refined_docs)
        compression_ratio = refined_length / original_length if original_length > 0 else 0
        
        # 정제 메트릭 기록
        agentops.record_action({
            'action_type': 'knowledge_refinement',
            'metrics': {
                'refinement_time': time.time() - start_time,
                'original_docs_count': len(documents),
                'refined_docs_count': len(refined_docs),
                'original_total_length': original_length,
                'refined_total_length': refined_length,
                'compression_ratio': compression_ratio
            }
        })
        
        return refined_docs
    
    @agentops.record_function('web_search')
    def _web_search_with_monitoring(self, query: str) -> List[str]:
        """모니터링이 포함된 웹 검색"""
        
        start_time = time.time()
        
        search_results = self.web_searcher.search(query)
        
        # 웹 검색 메트릭 기록
        agentops.record_action({
            'action_type': 'web_search',
            'metrics': {
                'search_time': time.time() - start_time,
                'results_count': len(search_results),
                'total_content_length': sum(len(result) for result in search_results)
            }
        })
        
        return search_results
```

### 2. 성능 최적화 및 A/B 테스팅

```python
class CRAGOptimizer:
    def __init__(self):
        self.performance_tracker = PerformanceTracker()
        self.ab_tester = ABTester()
    
    @agentops.record_function('crag_ab_test')
    def run_ab_test(self, queries: List[str], test_configs: Dict) -> Dict:
        """CRAG 시스템의 A/B 테스트 실행"""
        
        results = {}
        
        for config_name, config in test_configs.items():
            print(f"테스트 구성 실행: {config_name}")
            
            config_results = []
            
            for query in queries:
                # 구성별 CRAG 시스템 생성
                crag_system = self._create_crag_with_config(config)
                
                start_time = time.time()
                
                try:
                    response = crag_system.process_query(query)
                    
                    # 성능 메트릭 수집
                    metrics = {
                        'query': query,
                        'response': response,
                        'response_time': time.time() - start_time,
                        'success': True,
                        'config': config_name
                    }
                    
                    # 응답 품질 평가
                    quality_score = self._evaluate_response_quality(
                        query, response
                    )
                    metrics['quality_score'] = quality_score
                    
                    config_results.append(metrics)
                    
                except Exception as e:
                    config_results.append({
                        'query': query,
                        'error': str(e),
                        'response_time': time.time() - start_time,
                        'success': False,
                        'config': config_name
                    })
            
            results[config_name] = config_results
        
        # A/B 테스트 결과 분석
        analysis = self._analyze_ab_results(results)
        
        # AgentOps에 결과 기록
        agentops.record_action({
            'action_type': 'ab_test_completed',
            'metrics': {
                'test_configs': list(test_configs.keys()),
                'total_queries': len(queries),
                'analysis': analysis
            }
        })
        
        return analysis
    
    def _create_crag_with_config(self, config: Dict) -> CRAGWithAgentOps:
        """구성에 따른 CRAG 시스템 생성"""
        
        crag = CRAGWithAgentOps()
        
        # 신뢰도 임계값 설정
        if 'confidence_thresholds' in config:
            crag.retrieval_evaluator.set_thresholds(
                config['confidence_thresholds']
            )
        
        # 지식 정제 방식 설정
        if 'refinement_strategy' in config:
            crag.knowledge_refiner.set_strategy(
                config['refinement_strategy']
            )
        
        # 웹 검색 설정
        if 'web_search_config' in config:
            crag.web_searcher.configure(
                config['web_search_config']
            )
        
        return crag
    
    def _evaluate_response_quality(
        self, 
        query: str, 
        response: str
    ) -> float:
        """응답 품질 평가"""
        
        # 여러 메트릭을 조합한 품질 점수
        relevance_score = self._calculate_relevance(query, response)
        accuracy_score = self._calculate_accuracy(response)
        completeness_score = self._calculate_completeness(query, response)
        
        # 가중 평균
        quality_score = (
            0.4 * relevance_score +
            0.3 * accuracy_score +
            0.3 * completeness_score
        )
        
        return quality_score
    
    def _analyze_ab_results(self, results: Dict) -> Dict:
        """A/B 테스트 결과 분석"""
        
        analysis = {}
        
        for config_name, config_results in results.items():
            successful_results = [
                r for r in config_results if r.get('success', False)
            ]
            
            if successful_results:
                avg_response_time = sum(
                    r['response_time'] for r in successful_results
                ) / len(successful_results)
                
                avg_quality_score = sum(
                    r.get('quality_score', 0) for r in successful_results
                ) / len(successful_results)
                
                success_rate = len(successful_results) / len(config_results)
                
                analysis[config_name] = {
                    'avg_response_time': avg_response_time,
                    'avg_quality_score': avg_quality_score,
                    'success_rate': success_rate,
                    'total_queries': len(config_results)
                }
            else:
                analysis[config_name] = {
                    'avg_response_time': float('inf'),
                    'avg_quality_score': 0.0,
                    'success_rate': 0.0,
                    'total_queries': len(config_results)
                }
        
        return analysis
```

## 실전 구현 가이드

### 1. 환경 설정

```bash
# 필요한 라이브러리 설치
pip install torch transformers
pip install langchain openai
pip install beautifulsoup4 requests
pip install agentops
pip install scikit-learn numpy

# 환경 변수 설정
export OPENAI_API_KEY="your-openai-key"
export AGENTOPS_API_KEY="your-agentops-key"
export GOOGLE_SEARCH_API_KEY="your-google-search-key"
export GOOGLE_SEARCH_ENGINE_ID="your-search-engine-id"
```

### 2. 검색 평가기 학습

```python
# 검색 평가기 학습 데이터 준비
class RetrievalEvaluatorTrainer:
    def __init__(self):
        self.model_name = "microsoft/deberta-v3-base"
        
    def prepare_training_data(self, dataset_path: str):
        """학습 데이터 준비"""
        
        # 데이터 형식: query, document, relevance_label (0 or 1)
        training_data = []
        
        with open(dataset_path, 'r', encoding='utf-8') as f:
            for line in f:
                data = json.loads(line)
                
                input_text = f"Query: {data['query']}\nDocument: {data['document']}"
                label = data['relevance_label']
                
                training_data.append({
                    'input_text': input_text,
                    'label': label
                })
        
        return training_data
    
    def train_evaluator(self, training_data: List[Dict]):
        """검색 평가기 모델 학습"""
        
        # 토크나이저와 모델 로드
        tokenizer = AutoTokenizer.from_pretrained(self.model_name)
        model = AutoModelForSequenceClassification.from_pretrained(
            self.model_name,
            num_labels=2
        )
        
        # 데이터셋 준비
        train_dataset = EvaluatorDataset(training_data, tokenizer)
        
        # 학습 설정
        training_args = TrainingArguments(
            output_dir="./retrieval_evaluator",
            num_train_epochs=3,
            per_device_train_batch_size=16,
            per_device_eval_batch_size=16,
            warmup_steps=500,
            weight_decay=0.01,
            logging_dir="./logs",
            evaluation_strategy="epoch",
            save_strategy="epoch",
            load_best_model_at_end=True,
        )
        
        # 트레이너 생성 및 학습
        trainer = Trainer(
            model=model,
            args=training_args,
            train_dataset=train_dataset,
            eval_dataset=train_dataset,  # 실제로는 별도의 검증 데이터 사용
            tokenizer=tokenizer,
        )
        
        trainer.train()
        
        # 모델 저장
        trainer.save_model("./retrieval_evaluator_final")
        
        return trainer

class EvaluatorDataset(torch.utils.data.Dataset):
    def __init__(self, data: List[Dict], tokenizer):
        self.data = data
        self.tokenizer = tokenizer
    
    def __len__(self):
        return len(self.data)
    
    def __getitem__(self, idx):
        item = self.data[idx]
        
        encoding = self.tokenizer(
            item['input_text'],
            truncation=True,
            padding='max_length',
            max_length=512,
            return_tensors='pt'
        )
        
        return {
            'input_ids': encoding['input_ids'].flatten(),
            'attention_mask': encoding['attention_mask'].flatten(),
            'labels': torch.tensor(item['label'], dtype=torch.long)
        }
```

### 3. 전체 시스템 통합

```python
# 완전한 CRAG 시스템 구현
def main():
    """CRAG 시스템 메인 실행 함수"""
    
    # AgentOps 초기화
    agentops.init(api_key=os.getenv('AGENTOPS_API_KEY'))
    
    # CRAG 시스템 초기화
    crag_system = CRAGWithAgentOps()
    
    # 샘플 쿼리들
    test_queries = [
        "인공지능의 최신 발전 동향은 무엇인가요?",
        "기후 변화가 북극 생태계에 미치는 영향은?",
        "양자 컴퓨팅의 실용화 전망은 어떻게 되나요?"
    ]
    
    # 각 쿼리 처리
    for query in test_queries:
        print(f"\n쿼리: {query}")
        print("-" * 50)
        
        try:
            start_time = time.time()
            response = crag_system.process_query(query)
            end_time = time.time()
            
            print(f"응답: {response}")
            print(f"처리 시간: {end_time - start_time:.2f}초")
            
        except Exception as e:
            print(f"오류 발생: {e}")
    
    # AgentOps 세션 종료
    agentops.end_session('Success')

if __name__ == "__main__":
    main()
```

## 성능 벤치마크 및 평가

### 1. 평가 메트릭

```python
class CRAGEvaluator:
    def __init__(self):
        self.metrics = {
            'accuracy': self._calculate_accuracy,
            'relevance': self._calculate_relevance,
            'completeness': self._calculate_completeness,
            'response_time': self._calculate_response_time,
            'cost_efficiency': self._calculate_cost_efficiency
        }
    
    def evaluate_system(
        self, 
        crag_system: CRAGWithAgentOps,
        test_dataset: List[Dict]
    ) -> Dict:
        """CRAG 시스템 종합 평가"""
        
        results = []
        
        for test_case in test_dataset:
            query = test_case['query']
            expected_answer = test_case['expected_answer']
            
            start_time = time.time()
            
            try:
                actual_answer = crag_system.process_query(query)
                response_time = time.time() - start_time
                
                # 각 메트릭 계산
                case_metrics = {}
                for metric_name, metric_func in self.metrics.items():
                    if metric_name == 'response_time':
                        case_metrics[metric_name] = response_time
                    else:
                        case_metrics[metric_name] = metric_func(
                            query, expected_answer, actual_answer
                        )
                
                case_metrics['success'] = True
                results.append(case_metrics)
                
            except Exception as e:
                results.append({
                    'success': False,
                    'error': str(e),
                    'response_time': time.time() - start_time
                })
        
        # 전체 성능 요약
        summary = self._summarize_results(results)
        
        return {
            'individual_results': results,
            'summary': summary
        }
    
    def _calculate_accuracy(
        self, 
        query: str, 
        expected: str, 
        actual: str
    ) -> float:
        """정확도 계산 (BLEU 스코어 기반)"""
        
        from nltk.translate.bleu_score import sentence_bleu
        
        expected_tokens = expected.lower().split()
        actual_tokens = actual.lower().split()
        
        bleu_score = sentence_bleu([expected_tokens], actual_tokens)
        
        return bleu_score
    
    def _calculate_relevance(
        self, 
        query: str, 
        expected: str, 
        actual: str
    ) -> float:
        """관련성 계산 (의미적 유사도 기반)"""
        
        from sentence_transformers import SentenceTransformer
        
        model = SentenceTransformer('all-MiniLM-L6-v2')
        
        query_embedding = model.encode([query])
        actual_embedding = model.encode([actual])
        
        # 코사인 유사도 계산
        similarity = cosine_similarity(query_embedding, actual_embedding)[0][0]
        
        return similarity
    
    def _summarize_results(self, results: List[Dict]) -> Dict:
        """결과 요약"""
        
        successful_results = [r for r in results if r.get('success', False)]
        
        if not successful_results:
            return {'error': 'No successful results'}
        
        summary = {}
        
        for metric in self.metrics.keys():
            values = [r.get(metric, 0) for r in successful_results]
            summary[metric] = {
                'mean': sum(values) / len(values),
                'min': min(values),
                'max': max(values),
                'std': (sum((v - sum(values)/len(values))**2 for v in values) / len(values))**0.5
            }
        
        summary['success_rate'] = len(successful_results) / len(results)
        
        return summary
```

### 2. 비교 실험

```python
def compare_rag_systems():
    """기존 RAG vs CRAG 성능 비교"""
    
    # 테스트 데이터 로드
    test_dataset = load_test_dataset("./test_data.json")
    
    # 시스템들 초기화
    basic_rag = BasicRAGSystem()
    corrective_rag = CRAGWithAgentOps()
    
    evaluator = CRAGEvaluator()
    
    # 각 시스템 평가
    print("기본 RAG 시스템 평가 중...")
    basic_results = evaluator.evaluate_system(basic_rag, test_dataset)
    
    print("Corrective RAG 시스템 평가 중...")
    crag_results = evaluator.evaluate_system(corrective_rag, test_dataset)
    
    # 결과 비교
    comparison = {
        'basic_rag': basic_results['summary'],
        'corrective_rag': crag_results['summary'],
        'improvement': {}
    }
    
    # 개선율 계산
    for metric in ['accuracy', 'relevance', 'completeness']:
        basic_score = basic_results['summary'][metric]['mean']
        crag_score = crag_results['summary'][metric]['mean']
        
        improvement = ((crag_score - basic_score) / basic_score) * 100
        comparison['improvement'][metric] = f"{improvement:.2f}%"
    
    # 결과 출력
    print("\n=== 성능 비교 결과 ===")
    print(f"정확도 개선: {comparison['improvement']['accuracy']}")
    print(f"관련성 개선: {comparison['improvement']['relevance']}")
    print(f"완성도 개선: {comparison['improvement']['completeness']}")
    
    return comparison
```

## 실무 적용 사례

### 1. 고객 지원 시스템

```python
class CustomerSupportCRAG:
    def __init__(self):
        self.crag_system = CRAGWithAgentOps()
        self.knowledge_base = CustomerKnowledgeBase()
        
    @agentops.record_function('customer_support_query')
    def handle_customer_query(self, query: str, customer_context: Dict) -> str:
        """고객 문의 처리"""
        
        # 고객 컨텍스트를 포함한 쿼리 확장
        enriched_query = self._enrich_query_with_context(
            query, customer_context
        )
        
        # CRAG로 답변 생성
        response = self.crag_system.process_query(enriched_query)
        
        # 고객 맞춤화
        personalized_response = self._personalize_response(
            response, customer_context
        )
        
        # 만족도 예측
        satisfaction_score = self._predict_satisfaction(
            query, personalized_response
        )
        
        # 메트릭 기록
        agentops.record_action({
            'action_type': 'customer_support_completed',
            'metrics': {
                'customer_id': customer_context.get('customer_id'),
                'query_category': self._classify_query(query),
                'predicted_satisfaction': satisfaction_score,
                'response_length': len(personalized_response)
            }
        })
        
        return personalized_response
```

### 2. 연구 보조 시스템

```python
class ResearchAssistantCRAG:
    def __init__(self):
        self.crag_system = CRAGWithAgentOps()
        self.paper_database = PaperDatabase()
        
    @agentops.record_function('research_query')
    def research_query(self, question: str, domain: str) -> Dict:
        """연구 질문 처리"""
        
        # 도메인별 특화 검색
        domain_specific_docs = self.paper_database.search_by_domain(
            question, domain
        )
        
        # CRAG로 종합 분석
        analysis = self.crag_system.process_query(question)
        
        # 관련 논문 추천
        related_papers = self._recommend_papers(question, domain)
        
        # 연구 방향 제안
        research_directions = self._suggest_research_directions(
            question, analysis
        )
        
        return {
            'analysis': analysis,
            'related_papers': related_papers,
            'research_directions': research_directions,
            'confidence_score': self._calculate_confidence(analysis)
        }
```

## 결론

Corrective RAG는 **자체 평가 메커니즘**을 통해 기존 RAG 시스템의 한계를 극복하는 혁신적인 접근법입니다. 

### 핵심 장점

1. **적응적 지식 검색**: 상황에 따른 최적 검색 전략 선택
2. **품질 보장**: 검색된 문서의 관련성 자동 평가
3. **노이즈 제거**: 분해-재구성을 통한 핵심 정보 추출
4. **확장성**: 웹 검색을 통한 지식 베이스 확장

### AgentOps 통합 효과

- **실시간 모니터링**: 각 단계별 성능 추적
- **A/B 테스팅**: 다양한 구성의 효과 비교
- **성능 최적화**: 데이터 기반 시스템 개선
- **운영 안정성**: 오류 추적 및 복구

### 실무 적용 가이드

1. **단계적 도입**: 기존 RAG에서 점진적 업그레이드
2. **도메인 특화**: 업무 영역에 맞는 평가기 학습
3. **지속적 개선**: AgentOps 데이터 기반 최적화
4. **비용 관리**: 웹 검색과 로컬 검색의 균형

Corrective RAG와 AgentOps의 결합은 더 정확하고 신뢰할 수 있는 AI 시스템 구축을 가능하게 하며, 실제 비즈니스 환경에서 검증된 성과를 제공합니다. 