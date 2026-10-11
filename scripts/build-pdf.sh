#!/usr/bin/env bash
# index.html 을 @media print 규칙으로 렌더해 resume.pdf 를 만든다.
# 사용: scripts/build-pdf.sh   (경력 내용을 고친 뒤 다시 실행해 PDF 를 갱신)
set -euo pipefail
cd "$(dirname "$0")/.."

CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
[ -x "$CHROME" ] || { echo "Chrome 을 찾지 못했습니다: $CHROME (CHROME 환경변수로 지정)"; exit 1; }

PORT=8765
python3 -m http.server "$PORT" --bind 127.0.0.1 >/dev/null 2>&1 &
SERVER=$!
trap 'kill $SERVER 2>/dev/null' EXIT
sleep 0.5

# 절대경로(/style.css)가 풀리도록 로컬 서버를 통해 연다.
# virtual-time-budget: CDN 웹폰트(Pretendard) 로딩과 근속개월 계산 스크립트가 끝날 시간을 준다.
"$CHROME" --headless=new --disable-gpu --no-pdf-header-footer \
  --virtual-time-budget=8000 \
  --print-to-pdf="$PWD/resume.pdf" \
  "http://127.0.0.1:$PORT/index.html" 2>/dev/null

echo "생성: resume.pdf ($(du -h resume.pdf | cut -f1))"
