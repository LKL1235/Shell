#!/bin/bash

# 检查当前用户是否为 root 用户
if [[ $EUID -ne 0 ]]; then
    echo "请使用 root 用户执行此脚本。"
else
    # 当前用户为 root 用户，执行 apt update 命令
    apt update
    apt install iftop nload net-tools -y
fi