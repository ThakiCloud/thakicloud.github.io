#!/bin/bash

# Screego 관련 zsh aliases 설정
# ~/.zshrc에 추가할 내용

echo "# Screego 서버 관리 aliases" >> ~/.zshrc
echo "alias screego-start='cd ~/screego && docker-compose up -d'" >> ~/.zshrc
echo "alias screego-stop='cd ~/screego && docker-compose down'" >> ~/.zshrc
echo "alias screego-logs='cd ~/screego && docker-compose logs -f'" >> ~/.zshrc
echo "alias screego-restart='cd ~/screego && docker-compose restart'" >> ~/.zshrc
echo "alias screego-status='cd ~/screego && docker-compose ps'" >> ~/.zshrc
echo "alias screego-update='cd ~/screego && docker-compose pull && docker-compose up -d'" >> ~/.zshrc

echo "Screego aliases가 ~/.zshrc에 추가되었습니다."
echo "변경사항을 적용하려면 'source ~/.zshrc' 또는 새 터미널을 실행하세요."
