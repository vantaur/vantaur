#/bin/bash
NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
MAX=9

COINGITHUB=https://github.com/vantaur/vantaur.git
SENTINELGITHUB=NOSENTINEL
COINSRCDIR=VantaurSRC
# P2Pport and RPCport can be found in chainparams.cpp -> CMainParams()
COINPORT=22813
COINRPCPORT=22812
COINDAEMON=vantaurd
# COINCORE can be found in util.cpp -> GetDefaultDataDir()
COINCORE=.Vantaur
COINCONFIG=Vantaur.conf
key=""

checkForUbuntuVersion() {
   echo "[1/${MAX}] Checking Ubuntu version..."
    if [[ `cat /etc/issue.net`  == *16.04* ]]; then
        echo -e "${GREEN}* You are running `cat /etc/issue.net` . Setup will continue.${NONE}";
    else
        echo -e "${RED}* You are not running Ubuntu 16.04.X. You are running `cat /etc/issue.net` ${NONE}";
        echo && echo "Installation cancelled" && echo;
        exit;
    fi
}

updateAndUpgrade() {
    echo
    echo "[2/${MAX}] Running update and upgrade. Please wait..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq -y > /dev/null 2>&1
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq > /dev/null 2>&1
    echo -e "${GREEN}* Completed${NONE}";
}

setupSwap() {
    echo -e "${BOLD}"
    read -e -p "Add swap space? (If you use a 1G RAM VPS, choose Y.) [Y/n] :" add_swap
    if [[ ("$add_swap" == "y" || "$add_swap" == "Y" || "$add_swap" == "") ]]; then
        swap_size="4G"
    else
        echo -e "${NONE}[3/${MAX}] Swap space not created."
    fi

    if [[ ("$add_swap" == "y" || "$add_swap" == "Y" || "$add_swap" == "") ]]; then
        echo && echo -e "${NONE}[3/${MAX}] Adding swap space...${YELLOW}"
        sudo fallocate -l $swap_size /swapfile
        sleep 2
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        echo -e "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab > /dev/null 2>&1
        sudo sysctl vm.swappiness=10
        sudo sysctl vm.vfs_cache_pressure=50
        echo -e "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf > /dev/null 2>&1
        echo -e "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf > /dev/null 2>&1
        echo -e "${NONE}${GREEN}* Completed${NONE}";
    fi
}

installFail2Ban() {
    echo
    echo -e "[4/${MAX}] Installing fail2ban. Please wait..."
    sudo apt-get -y install fail2ban > /dev/null 2>&1
    sudo systemctl enable fail2ban > /dev/null 2>&1
    sudo systemctl start fail2ban > /dev/null 2>&1
    echo -e "${NONE}${GREEN}* Completed${NONE}";
}

installFirewall() {
    echo
    echo -e "[4/${MAX}] Installing UFW. Please wait..."
    sudo apt-get -y install ufw > /dev/null 2>&1
    sudo ufw default deny incoming > /dev/null 2>&1
    sudo ufw default allow outgoing > /dev/null 2>&1
    sudo ufw allow ssh > /dev/null 2>&1
    sudo ufw limit ssh/tcp > /dev/null 2>&1
    sudo ufw allow $COINPORT/tcp > /dev/null 2>&1
    sudo ufw allow $COINRPCPORT/tcp > /dev/null 2>&1
    sudo ufw logging on > /dev/null 2>&1
    echo "y" | sudo ufw enable > /dev/null 2>&1
    echo -e "${NONE}${GREEN}* Completed${NONE}";
}

installDependencies() {
    echo
    echo -e "[5/${MAX}] Installing dependecies. Please wait..."
    sudo apt-get install git nano rpl wget python-virtualenv -qq -y > /dev/null 2>&1
    sudo apt-get install build-essential libtool automake autoconf -qq -y > /dev/null 2>&1
    sudo apt-get install autotools-dev autoconf pkg-config libssl-dev -qq -y > /dev/null 2>&1
    sudo apt-get install libgmp3-dev libevent-dev bsdmainutils libboost-all-dev -qq -y > /dev/null 2>&1
    sudo apt-get install software-properties-common python-software-properties -qq -y > /dev/null 2>&1
    sudo add-apt-repository ppa:bitcoin/bitcoin -y > /dev/null 2>&1
    sudo apt-get update -qq -y > /dev/null 2>&1
    sudo apt-get install libdb4.8-dev libdb4.8++-dev -qq -y > /dev/null 2>&1
    sudo apt-get install libminiupnpc-dev -qq -y > /dev/null 2>&1
    sudo apt-get install libzmq5 -qq -y > /dev/null 2>&1
    echo -e "${NONE}${GREEN}* Completed${NONE}";
}

compileWallet() {
    echo
    echo -e "[6/${MAX}] Compiling wallet. Please wait..."
    git clone $COINGITHUB $COINSRCDIR > /dev/null 2>&1
    cd $COINSRCDIR/src > /dev/null 2>&1
    chmod 755 makefile.unix > /dev/null 2>&1
    sudo make -f makefile.unix > /dev/null 2>&1
    echo -e "${NONE}${GREEN}* Completed${NONE}";
}

installWallet() {
    echo
    echo -e "[7/${MAX}] Configuring wallet. Please wait..."
    echo -e "NOTE: This could take 30 minutes- go grab a coffee..."
    cd /root/$COINSRCDIR/src
    strip $COINDAEMON
    echo -e "${NONE}${GREEN}* Completed${NONE}";
}

configureWallet() {
    echo
    echo -e "[8/${MAX}] Configuring wallet. Please wait..."
    sudo mkdir -p /root/$COINCORE
    sudo touch /root/$COINCORE/$COINCONFIG
    sleep 10

    mnip=$(curl --silent ipinfo.io/ip)
    rpcuser=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
    rpcpass=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
    mnkey=$key

    sleep 10

    echo -e "rpcuser=${rpcuser}\nrpcpassword=${rpcpass}\nrpcport=${COINRPCPORT}\nrpcallowip=127.0.0.1\nlisten=1\nserver=1\ndaemon=1\nstaking=0\nmaxconnections=64\nexternalip=${mnip}:${COINPORT}\nmasternodeaddr=${mnip}:${COINPORT}\nmasternode=1\nmasternodeprivkey=${mnkey}\naddnode=207.148.23.182:22813\naddnode=77.81.234.75:22813\naddnode=192.241.150.123:22813\naddnode=173.249.16.205:22813\naddnode=109.248.46.51:22813\naddnode=115.68.47.154:22813\naddnode=207.148.73.10:22813\naddnode=23.95.225.157:22813" > /root/$COINCORE/$COINCONFIG
    echo -e "${NONE}${GREEN}* Completed${NONE}";
}


startWallet() {
    echo
    echo -e "[9/${MAX}] Starting wallet daemon..."
    cd /root/$COINSRCDIR/src
    sudo cp $COINDAEMON /usr/local/bin
    sudo ./$COINDAEMON -daemon > /dev/null 2>&1
    sleep 5
    echo -e "${GREEN}* Completed${NONE}";
}

clear
cd

echo
echo -e "${RED}           MM${NONE}                                                          ${WHITE}MMM           ${NONE}"
echo -e "${RED}          MMM${NONE}                                                         ${WHITE}MMMM           ${NONE}"
echo -e "${RED}         MMMMM${NONE}                                                       ${WHITE}MMMMMM          ${NONE}"
echo -e "${RED}        MMMMMMM${NONE}                                                     ${WHITE}MMMMMMMM         ${NONE}"
echo -e "${RED}       MMMMMMMMM${NONE}                                                    ${WHITE}MMMMMMMMM        ${NONE}"
echo -e "${RED}      MMMMMMMMMMM${NONE}                                                  ${WHITE}MMMMMMMMMMM       ${NONE}"
echo -e "${RED}     MMMMMMMMMMMM${NONE}                                                 ${WHITE}MMMMMMMMMMMMM      ${NONE}"
echo -e "${RED}     MMMMMMMMMMMMM${NONE}                                               ${WHITE}MMMMMMMMMMMMMMM     ${NONE}"
echo -e "${RED}    MMMMMMMMMMMMMMM${NONE}                                             ${WHITE}MMMMMMMMMMMMMMMMM    ${NONE}"
echo -e "${RED}   MMMMMMMMMMMMMMMMM${NONE}                                           ${WHITE}MMMMMMMMMMMMMMMMMM    ${NONE}"
echo -e "${RED}  MMMMMMMMMMMMMMMMMMM${NONE}                                         ${WHITE}MMMMMMMMMMMMMMMMMMMM   ${NONE}"
echo -e "${RED}  MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM${NONE}     ${WHITE}MMMMMMMMMMMMMMMMMMMMM  ${NONE}"
echo -e "${RED}  MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM${NONE}    ${WHITE}MMMMMMMMMMMMMMMMMMMMM   ${NONE}"
echo -e "${RED}   MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM${NONE}    ${WHITE}MMMMMMMMMMMMMMMMMMMMM    ${NONE}"
echo -e "${RED}     MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM${NONE}    ${WHITE}MMMMMMMMMMMMMMMMMMMMM     ${NONE}"
echo -e "${RED}     MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM${NONE}    ${WHITE}MMMMMMMMMMMMMMMMMMMMM      ${NONE}"
echo -e "${RED}      MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM${NONE}    ${WHITE}MMMMMMMMMMMMMMMMMMMMM       ${NONE}"
echo -e "${RED}       MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM${NONE}   ${WHITE}MMMMMMMMMMMMMMMMMMMMM        ${NONE}"
echo -e "${RED}        MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM${NONE}    ${WHITE}MMMMMMMMMMMMMMMMMMMMM        ${NONE}"
echo -e "${RED}        MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM${NONE}    ${WHITE}MMMMMMMMMMMMMMMMMMMMM         ${NONE}"
echo -e "${RED}         MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM${NONE}    ${WHITE}MMMMMMMMMMMMMMMMMMMMM          ${NONE}"
echo -e "${RED}          MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM${NONE}    ${WHITE}MMMMMMMMMMMMMMMMMMMMM           ${NONE}"
echo -e "${RED}           MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM${NONE}    ${WHITE}MMMMMMMMMMMMMMMMMMMMM            ${NONE}"
echo -e "${WHITE}                                                   MMMMMMMMMMMMMMMMMMMMM             ${NONE}"
echo -e "${WHITE}                                                  MMMMMMMMMMMMMMMMMMMMM              ${NONE}"
echo -e "${WHITE}             MMMMMMMMMMMMMMMMMMMMM                MMMMMMMMMMMMMMMMMMMMM              ${NONE}"
echo -e "${WHITE}              MMMMMMMMMMMMMMMMMMMMM              MMMMMMMMMMMMMMMMMMMMM               ${NONE}"
echo -e "${WHITE}               MMMMMMMMMMMMMMMMMMMMM            MMMMMMMMMMMMMMMMMMMMM                ${NONE}"
echo -e "${WHITE}                MMMMMMMMMMMMMMMMMMMMM          MMMMMMMMMMMMMMMMMMMMM                 ${NONE}"
echo -e "${WHITE}                 MMMMMMMMMMMMMMMMMMMMM        MMMMMMMMMMMMMMMMMMMMM                  ${NONE}"
echo -e "${WHITE}                  MMMMMMMMMMMMMMMMMMMM       MMMMMMMMMMMMMMMMMMMMM                   ${NONE}"
echo -e "${WHITE}                  MMMMMMMMMMMMMMMMMMMMM     MMMMMMMMMMMMMMMMMMMMM                    ${NONE}"
echo -e "${WHITE}                   MMMMMMMMMMMMMMMMMMMMM    MMMMMMMMMMMMMMMMMMMM                     ${NONE}"
echo -e "${WHITE}                    MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM                     ${NONE}"
echo -e "${WHITE}                     MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM                      ${NONE}"
echo -e "${WHITE}                      MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM                       ${NONE}"
echo -e "${WHITE}                       MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM                        ${NONE}"
echo -e "${WHITE}                        MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM                         ${NONE}"
echo -e "${WHITE}                        MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM                          ${NONE}"
echo -e "${WHITE}                         MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM                           ${NONE}"
echo -e "${WHITE}                          MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM                           ${NONE}"
echo -e "${WHITE}                           MMMMMMMMMMMMMMMMMMMMMMMMMMMMMM                            ${NONE}"
echo -e "${WHITE}                            MMMMMMMMMMMMMMMMMMMMMMMMMMMM                             ${NONE}"
echo -e "${WHITE}                             MMMMMMMMMMMMMMMMMMMMMMMMMM                              ${NONE}"
echo -e "${WHITE}                              MMMMMMMMMMMMMMMMMMMMMMMM                               ${NONE}"
echo -e "${WHITE}                              MMMMMMMMMMMMMMMMMMMMMMM                                ${NONE}"
echo -e "${WHITE}                               MMMMMMMMMMMMMMMMMMMMM                                 ${NONE}"


echo -e "${BOLD}"
read -p "This script will setup your Vantaur Coin Masternode. Do you wish to continue? (y/n)?" response
echo -e "${NONE}"

if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    read -e -p "Masternode Private Key (e.g. 7edfjLCUzGczZi3JQw8GHp434R9kNY33eFyMGeKRymkB56G4324h) : " key
    if [[ "$key" == "" ]]; then
        echo "WARNING: No private key entered, exiting!!!"
        echo && exit
    fi
    checkForUbuntuVersion
    updateAndUpgrade
    setupSwap
#    installFail2Ban
    installFirewall
    installDependencies
    compileWallet
    installWallet
    configureWallet
    startWallet
    echo
    echo -e "${BOLD}The VPS side of your masternode has been installed. Use the following line in your cold wallet masternode.conf and replace the tx and index${NONE}".
    echo
    echo -e "${CYAN}masternode1 ${mnip}:${COINPORT} ${mnkey} tx index${NONE}"
    echo
    echo -e "${BOLD}Thank you for your support of Vantaur Coin.${NONE}"
    echo
else
    echo && echo "Installation cancelled" && echo
fi
