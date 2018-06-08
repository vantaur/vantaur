```
____   ____                 __                          
\   \ /   /_____     ____ _/  |_ _____    __ __ _______ 
 \   Y   / \__  \   /    \\   __\\__  \  |  |  \\_  __ \
  \     /   / __ \_|   |  \|  |   / __ \_|  |  / |  | \/
   \___/   (____  /|___|  /|__|  (____  /|____/  |__|   
                \/      \/            \/   
```
V1.0.0.0

Vantaur is a powerful PoW + PoS hybrid cryptocurrency with a high-reward masternode system.

## Vantaur Specifications

| Specification | Value |
|:-----------|:-----------|
| Block time | `120 seconds` |
| PoS minimum age | `12 hours` |
| MN minimum age| `24 hours` |
| PoS rewards | `25% PoS / 75% MN`|
| Main port | `22813` |
| RPC port | `22812` |

## Social Channels

| Site | Link |
|:-----------|:-----------|
| Bitcointalk | https://bitcointalk.org/index.php?topic=2914598 |
| Discord | https://discord.gg/W3UM8VF |
| Website | http://www.vantaur.tk |



BUILD ON LINUX
-----------
Install the dependencies required to build Vantaur:
```
sudo apt-get install build-essential libssl-dev libboost-all-dev libqrencode-dev pkg-config libminiupnpc-dev qt5-default qttools5-dev-tools libgmp3-dev autoconf automake libtool

sudo add-apt-repository ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install libdb4.8-dev libdb4.8++-dev
```
Execute the following commands in the Terminal to install Vantaur:
1. `git clone https://github.com/vantaur/vantaur`

2. `cd vantaur`

3. To compile the headless daemon (vantaurd), enter the following:
    * `cd src`

    * `make -f makefile.unix`

    * `strip vantaurd`

    * `sudo cp vantaurd /usr/local/bin`

4. To build the graphical wallet (Vantaur-qt), enter the following:
    * `qmake`
    
    * `make`
    
    * `strip Vantaur-qt`
    
    * `sudo cp Vantaur-qt /usr/local/bin`

For more information please visit the website:

http://vantaur.org

