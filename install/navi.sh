#!/bin/bash
apt install fzf
bash <(curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install)
export PATH=$PATH:/root/.cargo/bin
echo 'export PATH=$PATH:/root/.cargo/bin' >> ~/.bashrc
mkdir -p $(navi info cheats-path)
cd $(navi info cheats-path)
git clone https://github.com/LKL1235/navi-cheats.git