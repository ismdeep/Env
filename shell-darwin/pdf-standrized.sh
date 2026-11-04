#!/usr/bin/env bash

set -e

if [ $# -eq 0 ]; then
    echo "用法: $0 <input.pdf> [output.pdf]"
    echo "修正 PDF 文件以兼容 macOS 预览程序"
    exit 1
fi

gs_script='/opt/homebrew/bin/gs'

input_file="$1"
output_file="${2:-${input_file%.*}_fixed.pdf}"

if [ ! -f "$input_file" ]; then
    echo "错误: 文件 '$input_file' 不存在"
    exit 1
fi

if [ ! -x "${gs_script}" ]; then
    echo "错误: Ghostscript 未安装，请运行: brew install ghostscript"
    exit 1
fi

echo "正在修正 PDF 文件: $input_file -> $output_file"
"${gs_script}" -o "$output_file" -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -dCompatibilityLevel=1.4 "$input_file"
echo "修正完成: $output_file"