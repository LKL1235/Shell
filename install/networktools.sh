#!/bin/bash


# 当前用户为 root 用户，执行 apt update 命令
apt update
apt install iftop nload net-tools -y
