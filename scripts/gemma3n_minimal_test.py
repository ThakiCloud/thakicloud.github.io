#!/usr/bin/env python3
"""
Gemma3n FineVideo 파인튜닝 실제 테스트
"""

def run_minimal_test():
    """최소한의 파인튜닝 테스트"""
    try:
        # 필수 임포트
        from datasets import load_dataset
        from transformers import AutoTokenizer
        import torch
        import json
        
        print("1. 데이터셋 로드...")
        dataset = load_dataset("HuggingFaceFV/finevideo", split="train", streaming=True)
        
        print("2. 샘플 처리...")
        samples = []
        for i, sample in enumerate(dataset):
            if i >= 3:  # 3개 샘플만 테스트
                break
            samples.append(sample)
        
        print(f"처리된 샘플: {len(samples)}개")
        
        print("3. 토크나이저 테스트...")
        tokenizer = AutoTokenizer.from_pretrained("google/gemma-2b")
        
        # 첫 번째 샘플의 메타데이터로 텍스트 생성
        metadata = json.loads(samples[0]['json'])
        title = metadata.get('youtube_title', 'Test Video')
        
        tokens = tokenizer(f"제목: {title}", return_tensors="pt")
        print(f"토큰화 완료: {tokens['input_ids'].shape}")
        
        print("✅ 기본 테스트 완료!")
        
    except Exception as e:
        print(f"❌ 테스트 실패: {e}")

if __name__ == "__main__":
    run_minimal_test()
