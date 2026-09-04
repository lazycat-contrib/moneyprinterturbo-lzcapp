#!/bin/sh
set -eu

/bin/sh /lzcapp/pkg/content/runtime/prepare-config.sh

exec streamlit run ./webui/Main.py \
  --server.address=0.0.0.0 \
  --server.port=8501 \
  --browser.serverAddress="$MPT_BROWSER_SERVER_ADDRESS" \
  --server.enableCORS=true \
  --browser.gatherUsageStats=false \
  --client.toolbarMode=minimal \
  --logger.hideWelcomeMessage=true \
  --server.showEmailPrompt=false
