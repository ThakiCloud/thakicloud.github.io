#!/usr/bin/env python3
"""
Simba RAG 시스템 간단 데모 스크립트
실제 외부 패키지 없이 RAG 개념을 시연하는 데모입니다.
"""

import json
import re
import math
from collections import Counter
from typing import List, Dict, Any, Tuple
import os

class SimpleRAGDemo:
    """간단한 RAG 시스템 데모"""
    
    def __init__(self):
        self.knowledge_base = []
        self.index = {}
        
    def add_document(self, doc_id: str, content: str, metadata: Dict = None):
        """문서 추가"""
        chunks = self._split_text(content)
        
        for i, chunk in enumerate(chunks):
            chunk_id = f"{doc_id}_chunk_{i}"
            doc_chunk = {
                'id': chunk_id,
                'content': chunk,
                'metadata': metadata or {},
                'doc_id': doc_id,
                'chunk_index': i
            }
            
            self.knowledge_base.append(doc_chunk)
            self._add_to_index(chunk_id, chunk)
    
    def _split_text(self, text: str, chunk_size: int = 200) -> List[str]:
        """텍스트를 청크로 분할"""
        sentences = re.split(r'[.!?]+', text)
        chunks = []
        current_chunk = ""
        
        for sentence in sentences:
            sentence = sentence.strip()
            if not sentence:
                continue
                
            if len(current_chunk) + len(sentence) < chunk_size:
                current_chunk += sentence + ". "
            else:
                if current_chunk:
                    chunks.append(current_chunk.strip())
                current_chunk = sentence + ". "
        
        if current_chunk:
            chunks.append(current_chunk.strip())
        
        return chunks
    
    def _add_to_index(self, chunk_id: str, content: str):
        """인덱스에 추가"""
        words = self._tokenize(content)
        
        for word in words:
            if word not in self.index:
                self.index[word] = []
            self.index[word].append(chunk_id)
    
    def _tokenize(self, text: str) -> List[str]:
        """텍스트 토큰화"""
        # 한글과 영어 단어 추출
        words = re.findall(r'[가-힣]+|[a-zA-Z]+', text.lower())
        return words
    
    def search(self, query: str, top_k: int = 3) -> List[Dict]:
        """검색 수행"""
        query_words = self._tokenize(query)
        
        # 문서별 점수 계산
        doc_scores = {}
        
        for word in query_words:
            if word in self.index:
                for chunk_id in self.index[word]:
                    if chunk_id not in doc_scores:
                        doc_scores[chunk_id] = 0
                    doc_scores[chunk_id] += 1
        
        # 점수 순으로 정렬
        sorted_docs = sorted(doc_scores.items(), key=lambda x: x[1], reverse=True)
        
        # 상위 k개 문서 반환
        results = []
        for chunk_id, score in sorted_docs[:top_k]:
            for doc in self.knowledge_base:
                if doc['id'] == chunk_id:
                    results.append({
                        'content': doc['content'],
                        'metadata': doc['metadata'],
                        'score': score,
                        'chunk_id': chunk_id
                    })
                    break
        
        return results
    
    def generate_answer(self, query: str, context_docs: List[Dict]) -> str:
        """답변 생성 (간단한 규칙 기반)"""
        if not context_docs:
            return "관련 정보를 찾을 수 없습니다."
        
        # 컨텍스트 결합
        context = " ".join([doc['content'] for doc in context_docs])
        
        # 간단한 답변 생성 로직
        query_words = self._tokenize(query)
        
        # 질문 유형 판단
        if any(word in query_words for word in ['무엇', '뭐', 'what']):
            answer_type = "정의"
        elif any(word in query_words for word in ['어떻게', 'how']):
            answer_type = "방법"
        elif any(word in query_words for word in ['왜', 'why']):
            answer_type = "이유"
        else:
            answer_type = "일반"
        
        # 답변 생성
        answer = f"제공된 문서에 따르면, {context[:200]}..."
        
        return answer
    
    def query(self, question: str, top_k: int = 3) -> Dict:
        """전체 RAG 파이프라인 실행"""
        # 검색
        search_results = self.search(question, top_k)
        
        # 답변 생성
        answer = self.generate_answer(question, search_results)
        
        return {
            'question': question,
            'answer': answer,
            'sources': search_results
        }

def setup_demo_knowledge_base():
    """데모용 지식베이스 설정"""
    rag = SimpleRAGDemo()
    
    # 샘플 문서들 추가
    documents = [
        {
            'id': 'ai_basics',
            'content': '''
            인공지능(AI)은 컴퓨터 시스템이 인간의 지능을 모방하는 기술입니다.
            머신러닝은 데이터로부터 패턴을 학습하는 AI의 한 분야입니다.
            딥러닝은 신경망을 사용하는 머신러닝의 한 방법입니다.
            자연어처리는 컴퓨터가 인간의 언어를 이해하고 생성하는 기술입니다.
            컴퓨터 비전은 컴퓨터가 이미지와 비디오를 분석하는 기술입니다.
            ''',
            'metadata': {'topic': 'AI 기초', 'author': 'Demo'}
        },
        {
            'id': 'rag_systems',
            'content': '''
            RAG(Retrieval-Augmented Generation)는 정보 검색과 생성을 결합한 AI 기술입니다.
            RAG 시스템은 문서 저장소, 검색 엔진, 생성 모델, 벡터 데이터베이스로 구성됩니다.
            RAG의 장점은 최신 정보 활용, 환각 감소, 도메인 특화 지식 제공입니다.
            RAG 시스템 구축 과정은 문서 수집, 청크 분할, 임베딩, 벡터 저장, 검색 파이프라인 구축입니다.
            ''',
            'metadata': {'topic': 'RAG 시스템', 'author': 'Demo'}
        },
        {
            'id': 'vector_db',
            'content': '''
            벡터 데이터베이스는 고차원 벡터 데이터를 저장하고 검색하는 시스템입니다.
            벡터 데이터베이스의 특징은 유사도 기반 검색, 고차원 데이터 지원, 빠른 검색 성능입니다.
            인기 있는 벡터 데이터베이스로는 ChromaDB, Pinecone, Weaviate, Milvus가 있습니다.
            벡터 데이터베이스는 의미 검색, 추천 시스템, 이미지 검색에 활용됩니다.
            ''',
            'metadata': {'topic': '벡터 데이터베이스', 'author': 'Demo'}
        }
    ]
    
    # 문서들을 지식베이스에 추가
    for doc in documents:
        rag.add_document(doc['id'], doc['content'], doc['metadata'])
    
    return rag

def run_demo():
    """데모 실행"""
    print("🤖 Simba RAG 시스템 간단 데모")
    print("=" * 50)
    
    # 지식베이스 설정
    print("📚 지식베이스 설정 중...")
    rag = setup_demo_knowledge_base()
    print(f"✅ 지식베이스 설정 완료 ({len(rag.knowledge_base)} 문서 청크)")
    
    # 샘플 질문들
    sample_questions = [
        "인공지능이란 무엇인가요?",
        "RAG 시스템의 장점은 무엇인가요?",
        "벡터 데이터베이스의 특징을 설명해주세요.",
        "머신러닝에 대해 설명해주세요.",
        "딥러닝은 무엇인가요?"
    ]
    
    print("\n🔍 질문 답변 데모:")
    print("-" * 50)
    
    for i, question in enumerate(sample_questions, 1):
        print(f"\n{i}. 질문: {question}")
        
        result = rag.query(question, top_k=2)
        
        print(f"   답변: {result['answer']}")
        print(f"   참조 문서 수: {len(result['sources'])}")
        
        if result['sources']:
            print("   참조 내용:")
            for j, source in enumerate(result['sources']):
                print(f"     {j+1}. {source['content'][:50]}... (점수: {source['score']})")
    
    print("\n" + "=" * 50)
    print("💡 이것은 실제 Simba RAG 시스템의 간단한 데모입니다.")
    print("실제 시스템에서는 OpenAI 임베딩과 ChromaDB를 사용합니다.")
    print("=" * 50)

def interactive_demo():
    """대화형 데모"""
    print("\n🗣️ 대화형 데모 모드")
    print("질문을 입력하세요 (종료하려면 'quit' 입력):")
    print("-" * 50)
    
    rag = setup_demo_knowledge_base()
    
    while True:
        try:
            question = input("\n질문: ").strip()
            
            if question.lower() in ['quit', 'exit', 'q', '종료']:
                print("👋 데모를 종료합니다.")
                break
            
            if not question:
                continue
            
            result = rag.query(question, top_k=3)
            
            print(f"답변: {result['answer']}")
            
            if result['sources']:
                print("참조 문서:")
                for i, source in enumerate(result['sources'], 1):
                    print(f"  {i}. {source['content'][:100]}...")
        
        except KeyboardInterrupt:
            print("\n👋 데모를 종료합니다.")
            break

if __name__ == "__main__":
    print("🚀 Simba RAG 데모 시작")
    print("=" * 50)
    
    try:
        # 기본 데모 실행
        run_demo()
        
        # 대화형 모드 제안
        response = input("\n대화형 모드를 시작하시겠습니까? (y/n): ").strip().lower()
        if response in ['y', 'yes', '예']:
            interactive_demo()
        
    except KeyboardInterrupt:
        print("\n\n👋 데모를 종료합니다.")
    except Exception as e:
        print(f"\n❌ 오류 발생: {str(e)}") 