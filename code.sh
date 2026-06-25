#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BRIGHT_RED='\033[1;31m'
BRIGHT_GREEN='\033[1;32m'
BRIGHT_YELLOW='\033[1;33m'
BRIGHT_BLUE='\033[1;34m'
BRIGHT_MAGENTA='\033[1;35m'
BRIGHT_CYAN='\033[1;36m'
BRIGHT_WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Banner
show_banner() {
    clear
    echo ""
    echo -e "${CYAN}    ████████╗██╗  ██╗███████╗    ██████╗  ██████╗  ██████╗  ███████╗${NC}"
    echo -e "${BLUE}    ╚══██╔══╝██║  ██║██╔════╝    ╚════██╗██╔═████╗██╔═████╗██╔════╝${NC}"
    echo -e "${MAGENTA}       ██║   ███████║█████╗       █████╔╝██║██╔██║██║██╔██║█████╗  ${NC}"
    echo -e "${MAGENTA}       ██║   ██╔══██║██╔══╝      ██╔═══╝ ████╔╝██║████╔╝██║██╔══╝  ${NC}"
    echo -e "${RED}       ╚═╝   ██║  ██║███████╗    ███████╗╚██████╔╝╚██████╔╝███████╗${NC}"
    echo -e "${RED}             ╚═╝  ╚═╝╚════════╝    ╚══════╝ ╚═════╝  ╚═════╝ ╚══════╝${NC}"
    echo ""
    echo -e "${BRIGHT_YELLOW}    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${BRIGHT_YELLOW}    ┃${NC}  ${BRIGHT_CYAN}★${NC}  ${BRIGHT_WHITE}Welcome to iTzTasin69 VsCode VPS MAKER${NC}               ${BRIGHT_YELLOW}┃${NC}"
    echo -e "${BRIGHT_YELLOW}    ┃${NC}  ${DIM}Made with ❤️  by iTzTasin69${NC}                                  ${BRIGHT_YELLOW}┃${NC}"
    echo -e "${BRIGHT_YELLOW}    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
}

# OS definitions
declare -A OS_BASE_IMAGE OS_NAME OS_VERSION OS_ICON OS_COLOR

OS_BASE_IMAGE["1"]="ubuntu:20.04"
OS_NAME["1"]="Ubuntu"
OS_VERSION["1"]="20.04"
OS_ICON["1"]="🟠"
OS_COLOR["1"]="$BRIGHT_YELLOW"

OS_BASE_IMAGE["2"]="ubuntu:22.04"
OS_NAME["2"]="Ubuntu"
OS_VERSION["2"]="22.04"
OS_ICON["2"]="🟠"
OS_COLOR["2"]="$BRIGHT_YELLOW"

OS_BASE_IMAGE["3"]="ubuntu:24.04"
OS_NAME["3"]="Ubuntu"
OS_VERSION["3"]="24.04"
OS_ICON["3"]="🟠"
OS_COLOR["3"]="$BRIGHT_YELLOW"

OS_BASE_IMAGE["4"]="debian:11"
OS_NAME["4"]="Debian"
OS_VERSION["4"]="11"
OS_ICON["4"]="🔴"
OS_COLOR["4"]="$BRIGHT_RED"

OS_BASE_IMAGE["5"]="debian:12"
OS_NAME["5"]="Debian"
OS_VERSION["5"]="12"
OS_ICON["5"]="🔴"
OS_COLOR["5"]="$BRIGHT_RED"

OS_BASE_IMAGE["6"]="debian:13"
OS_NAME["6"]="Debian"
OS_VERSION["6"]="13"
OS_ICON["6"]="🔴"
OS_COLOR["6"]="$BRIGHT_RED"

OS_BASE_IMAGE["7"]="kalilinux/kali-rolling"
OS_NAME["7"]="Kali Linux"
OS_VERSION["7"]="Rolling"
OS_ICON["7"]="🐉"
OS_COLOR["7"]="$BRIGHT_BLUE"

get_image_tag() {
    local choice=$1
    # Added -v2 to force rebuild with the fixed neofetch injection method
    echo "vscode-${OS_NAME[$choice]}-${OS_VERSION[$choice]}-v2" | tr '[:upper:]' '[:lower:]' | tr -d ' '
}

# Build OS image
build_os_image() {
    local choice=$1
    local tag=$(get_image_tag "$choice")
    local base_image="${OS_BASE_IMAGE[$choice]}"
    local os_name="${OS_NAME[$choice]}"
    local os_ver="${OS_VERSION[$choice]}"
    local icon="${OS_ICON[$choice]}"
    
    if docker image inspect "code-server:$tag" &> /dev/null; then
        echo -e "  ${BRIGHT_GREEN}✔${NC} ${DIM}Image cached: ${BRIGHT_CYAN}code-server:$tag${NC}"
        return 0
    fi
    
    echo ""
    echo -e "  ${icon} ${BRIGHT_YELLOW}Building ${os_name} ${os_ver} image...${NC}"
    echo -e "  ${DIM}┌─────────────────────────────────────────────────────────────┐${NC}"
    
    cat > /tmp/vscode-dockerfile-$tag << 'DOCKERFILE_END'
FROM __BASE_IMAGE__
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get install -y curl sudo wget git nano vim htop net-tools lsof unzip neofetch && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN mkdir -p /root/.local/share/code-server

# Safely inject real-looking functions into .bashrc
RUN echo 'if [ -n "$CUSTOM_CPU" ]; then get_cpu() { printf "%s" "$CUSTOM_CPU"; }; fi' >> /root/.bashrc
RUN echo 'if [ -n "$CUSTOM_GPU" ]; then get_gpu() { printf "%s" "$CUSTOM_GPU"; }; fi' >> /root/.bashrc
RUN echo 'if [ -n "$CUSTOM_HOST" ]; then get_host() { printf "%s" "$CUSTOM_HOST"; }; fi' >> /root/.bashrc
RUN echo 'if [ -n "$CUSTOM_MEM" ]; then get_memory() { printf "%s" "$CUSTOM_MEM"; }; fi' >> /root/.bashrc
RUN echo 'neofetch' >> /root/.bashrc

ENV PASSWORD=changeit
EXPOSE 8080
WORKDIR /root
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "password"]
DOCKERFILE_END
    
    sed -i "s|__BASE_IMAGE__|${base_image}|g" /tmp/vscode-dockerfile-$tag
    
    (
        docker build -t "code-server:$tag" -f /tmp/vscode-dockerfile-$tag /tmp/ > /tmp/docker-build-log-$tag 2>&1
        echo $? > /tmp/docker-build-status-$tag
    ) &
    local build_pid=$!
    
    local dots="⠁⠂⠄⡀⢀⠠⠐⠈"
    local i=0
    tput civis
    while kill -0 $build_pid 2>/dev/null; do
        i=$(( (i+1) % ${#dots} ))
        printf "\r  ${BRIGHT_CYAN}${dots:$i:1}${NC} ${DIM}Downloading & installing packages...${NC}        "
        sleep 0.15
    done
    tput cnorm
    printf "\r  ${BRIGHT_GREEN}✔${NC} ${DIM}Build process completed${NC}                     \n"
    
    echo -e "  ${DIM}└─────────────────────────────────────────────────────────────┘${NC}"
    
    rm -f /tmp/vscode-dockerfile-$tag /tmp/docker-build-log-$tag /tmp/docker-build-status-$tag
    
    if docker image inspect "code-server:$tag" &> /dev/null; then
        echo -e "  ${BRIGHT_GREEN}✔${NC} ${BRIGHT_WHITE}Image ready: ${BRIGHT_CYAN}code-server:$tag${NC}"
        return 0
    else
        echo ""
        echo -e "  ${BRIGHT_RED}╭──────────────────────────────────────────────────────╮${NC}"
        echo -e "  ${BRIGHT_RED}│${NC}   ${BRIGHT_WHITE}✘ ERROR${NC}                                               ${BRIGHT_RED}│${NC}"
        echo -e "  ${BRIGHT_RED}│${NC}   Failed to build ${os_name} ${os_ver} image!${NC}                 ${BRIGHT_RED}│${NC}"
        echo -e "  ${BRIGHT_RED}╰──────────────────────────────────────────────────────╯${NC}"
        echo ""
        return 1
    fi
}

# Show OS menu
show_os_menu() {
    echo -e "  ${BRIGHT_CYAN}┌───────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${BRIGHT_CYAN}│${NC}  ${BRIGHT_WHITE}◈${NC}  ${BRIGHT_YELLOW}SELECT OPERATING SYSTEM${NC}                              ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}├───────────────────────────────────────────────────────────┤${NC}"
    echo -e "  ${BRIGHT_CYAN}│${NC}                                                              ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}│${NC}   ${BRIGHT_WHITE}━━━━━━━━━━ ${BRIGHT_YELLOW}UBUNTU${NC} ${BRIGHT_WHITE}━━━━━━━━━━${NC}                              ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}│${NC}   ${YELLOW}[1]${NC} 🟠  ${BRIGHT_WHITE}Ubuntu${NC}    ${DIM}20.04 LTS (Focal Fossa)${NC}              ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}│${NC}   ${YELLOW}[2]${NC} 🟠  ${BRIGHT_WHITE}Ubuntu${NC}    ${DIM}22.04 LTS (Jammy Jellyfish)${NC}        ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}│${NC}   ${YELLOW}[3]${NC} 🟠  ${BRIGHT_WHITE}Ubuntu${NC}    ${DIM}24.04 LTS (Noble Numbat)${NC}           ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}│${NC}                                                              ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}│${NC}   ${BRIGHT_WHITE}━━━━━━━━━━ ${BRIGHT_RED}DEBIAN${NC} ${BRIGHT_WHITE}━━━━━━━━━━${NC}                              ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}│${NC}   ${YELLOW}[4]${NC} 🔴  ${BRIGHT_WHITE}Debian${NC}    ${DIM}11 (Bullseye)${NC}                        ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}│${NC}   ${YELLOW}[5]${NC} 🔴  ${BRIGHT_WHITE}Debian${NC}    ${DIM}12 (Bookworm)${NC}                        ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}│${NC}   ${YELLOW}[6]${NC} 🔴  ${BRIGHT_WHITE}Debian${NC}    ${DIM}13 (Trixie)${NC}                          ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}│${NC}                                                              ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}│${NC}   ${BRIGHT_WHITE}━━━━━━━━━━ ${BRIGHT_BLUE}KALI LINUX${NC} ${BRIGHT_WHITE}━━━━━━━━━━${NC}                        ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}│${NC}   ${YELLOW}[7]${NC} 🐉  ${BRIGHT_WHITE}Kali Linux${NC} ${DIM}Rolling${NC}                               ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}│${NC}                                                              ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}├───────────────────────────────────────────────────────────┤${NC}"
    echo -e "  ${BRIGHT_CYAN}│${NC}   ${DIM}[0] ← Back to main menu${NC}                                  ${BRIGHT_CYAN}│${NC}"
    echo -e "  ${BRIGHT_CYAN}└───────────────────────────────────────────────────────────┘${NC}"
    echo ""
    printf "  ${BRIGHT_WHITE}┃${NC} ${BRIGHT_CYAN}Select OS${NC} ${DIM}[0-7]${NC}${BRIGHT_WHITE}:${NC} "
    read os_choice
    
    case $os_choice in
        0) return 1 ;;
        1|2|3|4|5|6|7) return 0 ;;
        *)
            echo -e "\n  ${BRIGHT_RED}
