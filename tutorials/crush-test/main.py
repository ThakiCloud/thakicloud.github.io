def fibonacci(n):
    """피보나치 수열을 계산하는 함수"""
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

def main():
    """메인 함수"""
    n = 10
    print(f"피보나치({n}) = {fibonacci(n)}")

if __name__ == "__main__":
    main()
