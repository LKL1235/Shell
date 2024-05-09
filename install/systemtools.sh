#!/bin/bash


# 当前用户为 root 用户，执行 apt update 命令
add-apt-repository ppa:zhangsongcui3371/fastfetch
apt update
apt install fastfetch -y
