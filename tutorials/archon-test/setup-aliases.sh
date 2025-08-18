#!/bin/bash

# Archon 관련 유용한 alias 설정
# ~/.zshrc에 추가하여 사용

echo "# Archon OS 관련 alias" >> ~/.zshrc
echo "alias archon-start='cd ~/work/thakicloud/thakicloud.github.io/tutorials/archon-test/Archon && docker-compose up -d'" >> ~/.zshrc
echo "alias archon-stop='cd ~/work/thakicloud/thakicloud.github.io/tutorials/archon-test/Archon && docker-compose down'" >> ~/.zshrc
echo "alias archon-restart='cd ~/work/thakicloud/thakicloud.github.io/tutorials/archon-test/Archon && docker-compose restart'" >> ~/.zshrc
echo "alias archon-logs='cd ~/work/thakicloud/thakicloud.github.io/tutorials/archon-test/Archon && docker-compose logs -f'" >> ~/.zshrc
echo "alias archon-status='cd ~/work/thakicloud/thakicloud.github.io/tutorials/archon-test/Archon && docker ps | grep -E \"(Archon|archon)\"'" >> ~/.zshrc
echo "alias archon-test='cd ~/work/thakicloud/thakicloud.github.io/tutorials/archon-test && ./test-archon-setup.sh'" >> ~/.zshrc
echo "alias archon-ui='open http://localhost:3737'" >> ~/.zshrc
echo "alias archon-build='cd ~/work/thakicloud/thakicloud.github.io/tutorials/archon-test/Archon && docker-compose up --build -d'" >> ~/.zshrc

echo "✅ Archon alias가 ~/.zshrc에 추가되었습니다."
echo "다음 명령어로 reload 하세요: source ~/.zshrc"
echo ""
echo "🎯 사용 가능한 alias:"
echo "  archon-start    - Archon 시작"
echo "  archon-stop     - Archon 종료"
echo "  archon-restart  - Archon 재시작"
echo "  archon-logs     - 로그 확인"
echo "  archon-status   - 상태 확인"
echo "  archon-test     - 테스트 실행"
echo "  archon-ui       - 웹 UI 열기"
echo "  archon-build    - 재빌드 후 시작"
