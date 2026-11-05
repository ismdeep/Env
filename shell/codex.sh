#!/usr/bin/env bash

set -e

endpoint=''
key=''
model=''

# 解析命令行参数
while [[ $# -gt 0 ]]; do
  case $1 in
    --endpoint)
      endpoint="${2:?}"
      shift 2
      ;;
    --key)
      key="${2:?}"
      shift 2
      ;;
    --model)
      model="${2:?}"
      shift 2
      ;;
    -*)
      log_error "未知选项: $1"
      echo "使用 --help 查看帮助信息"
      exit 1
      ;;
    *)
      log_error "未知参数: $1"
      echo "使用 --help 查看帮助信息"
      exit 1
      ;;
  esac
done

CODEX_API_KEY="${key:?}" \
  codex \
    --model "${model}" \
    -c 'model_provider="custom"' \
    -c 'model_providers.custom.name="Custom API"' \
    -c "model_providers.custom.base_url=${endpoint:?}" \
    -c 'model_providers.custom.env_key="CODEX_API_KEY"' \
    -c 'model_providers.custom.wire_api="responses"' \
    --no-daemon --ask-for-approval never --sandbox workspace-write