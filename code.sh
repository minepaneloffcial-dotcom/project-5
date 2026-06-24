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
    echo "vscode-${OS_NAME[$choice]}-${OS_VERSION[$choice]}" | tr '[:upper:]' '[:lower:]' | tr -d ' '
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
    
    cat > /tmp/vscode-dockerfile-$tag << 'DOCKERFILE'
FROM __BASE_IMAGE__
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get install -y curl sudo wget git nano vim htop net-tools lsof unzip neofetch && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN mkdir -p /root/.local/share/code-server /root/.config/neofetch

RUN cat > /entrypoint.sh << 'ENTRYSCRIPT'
#!/bin/bash
if [ -n "$CUSTOM_CPU" ]; then
    mkdir -p /root/.config/neofetch
    cat > /root/.config/neofetch/config.conf << CONF
info "CPU" "${CUSTOM_CPU}"
CONF
fi
if [ -n "$CUSTOM_GPU" ]; then
    mkdir -p /root/.config/neofetch
    if [ -f /root/.config/neofetch/config.conf ]; then
        echo 'info "GPU" "${CUSTOM_GPU}"' >> /root/.config/neofetch/config.conf
    else
        cat > /root/.config/neofetch/config.conf << CONF
info "GPU" "${CUSTOM_GPU}"
CONF
    fi
fi
if [ -n "$CUSTOM_MEM" ]; then
    mkdir -p /root/.config/neofetch
    if [ -f /root/.config/neofetch/config.conf ]; then
        echo 'info "Memory" "${CUSTOM_MEM}"' >> /root/.config/neofetch/config.conf
    else
        cat > /root/.config/neofetch/config.conf << CONF
info "Memory" "${CUSTOM_MEM}"
CONF
    fi
fi
exec code-server --bind-addr 0.0.0.0:8080 --auth password "$@"
ENTRYSCRIPT
RUN chmod +x /entrypoint.sh

RUN echo 'neofetch' >> /root/.bashrc

ENV PASSWORD=changeit
EXPOSE 8080
WORKDIR /root
ENTRYPOINT ["/entrypoint.sh"]
DOCKERFILE
    
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
            echo -e "\n  ${BRIGHT_RED}✘${NC} ${RED}Invalid option!${NC}"
            sleep 1
            return 2
            ;;
    esac
}

# Count containers
count_containers() {
    docker ps -a --filter "name=vscode-" --format "{{.Names}}" 2>/dev/null | wc -l
}

# Count running
count_running() {
    docker ps --filter "name=vscode-" --format "{{.Names}}" 2>/dev/null | wc -l
}

# List containers
list_containers() {
    local containers=$(docker ps -a --filter "name=vscode-" --format "{{.Names}}|{{.Status}}|{{.Ports}}|{{.Image}}" 2>/dev/null)
    
    echo -e "  ${BRIGHT_CYAN}╔════════════════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${BRIGHT_CYAN}║${NC}  ${BRIGHT_WHITE}◆${NC}  ${BRIGHT_YELLOW}YOUR VSCODE CONTAINERS${NC}                                                                                      ${BRIGHT_CYAN}║${NC}"
    echo -e "  ${BRIGHT_CYAN}╠════════════════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${BRIGHT_CYAN}║${NC}  ${DIM}  #    Name                Hostname           OS                 Status         Port${NC}       ${BRIGHT_CYAN}║${NC}"
    echo -e "  ${BRIGHT_CYAN}╠════════════════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    
    if [ -z "$containers" ]; then
        echo -e "  ${BRIGHT_CYAN}║${NC}                                                                                                                  ${BRIGHT_CYAN}║${NC}"
        echo -e "  ${BRIGHT_CYAN}║${NC}     ${DIM}No containers found. Create one from the main menu!${NC}                                                              ${BRIGHT_CYAN}║${NC}"
        echo -e "  ${BRIGHT_CYAN}║${NC}                                                                                                                  ${BRIGHT_CYAN}║${NC}"
    else
        local num=1
        while IFS='|' read -r name status ports image; do
            local hostname=$(docker inspect -f '{{.Config.Hostname}}' "$name" 2>/dev/null)
            [ -z "$hostname" ] && hostname="N/A"
            
            local os_info=$(echo "$image" | sed 's/code-server://g')
            
            local port=$(echo "$ports" | grep -oP '0.0.0.0:\K[0-9]+' | head -1)
            [ -z "$port" ] && port="N/A"
            
            local status_icon="●"
            local status_color="$BRIGHT_RED"
            local status_text="STOPPED "
            if echo "$status" | grep -q "Up"; then
                status_color="$BRIGHT_GREEN"
                status_text="RUNNING"
            fi
            
            printf "  ${BRIGHT_CYAN}║${NC}  ${BRIGHT_WHITE}%2d${NC}   ${BRIGHT_YELLOW}%-18s${NC} ${BRIGHT_BLUE}%-18s${NC} ${DIM}%-19s${NC} ${status_color}%s %s${NC}   ${BRIGHT_MAGENTA}%-5s${NC}  ${BRIGHT_CYAN}║${NC}\n" \
                "$num" "$name" "$hostname" "$os_info" "$status_icon" "$status_text" "$port"
            num=$((num + 1))
        done <<< "$containers"
    fi
    
    echo -e "  ${BRIGHT_CYAN}╚════════════════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Install container
install_container() {
    echo -e "  ${BRIGHT_YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${BRIGHT_YELLOW}║${NC}  ${BRIGHT_GREEN}🚀${NC}  ${BRIGHT_WHITE}CREATE NEW VSCODE VPS${NC}                             ${BRIGHT_YELLOW}║${NC}"
    echo -e "  ${BRIGHT_YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    while true; do
        show_os_menu
        local os_result=$?
        if [ $os_result -eq 1 ]; then
            return
        elif [ $os_result -eq 0 ]; then
            break
        fi
    done
    
    local os_choice_selected=$os_choice
    local os_name="${OS_NAME[$os_choice_selected]}"
    local os_ver="${OS_VERSION[$os_choice_selected]}"
    local os_icon="${OS_ICON[$os_choice_selected]}"
    local image_tag=$(get_image_tag "$os_choice_selected")
    
    echo ""
    echo -e "  ${DIM}─────────────────────────────────────────────────────────${NC}"
    echo -e "  ${BRIGHT_CYAN}┃${NC}  ${BRIGHT_WHITE}CONFIGURATION${NC}"
    echo -e "  ${DIM}─────────────────────────────────────────────────────────${NC}"
    echo ""
    
    # Name
    while true; do
        printf "  ${BRIGHT_CYAN}┃${NC} ${BRIGHT_WHITE}Container Name${NC}    ${DIM}[auto: vscode-]${NC}${BRIGHT_WHITE}:${NC} "
        read container_name
        if [ -z "$container_name" ]; then
            echo -e "  ${BRIGHT_RED}┃${NC}  ${RED}Name cannot be empty!${NC}"
            continue
        fi
        container_name="${container_name#vscode-}"
        container_name="vscode-${container_name}"
        if docker ps -a --format "{{.Names}}" | grep -q "^${container_name}$"; then
            echo -e "  ${BRIGHT_RED}┃${NC}  ${RED}Container '$container_name' already exists!${NC}"
            continue
        fi
        break
    done
    
    # Hostname
    printf "  ${BRIGHT_CYAN}┃${NC} ${BRIGHT_WHITE}Hostname${NC}          ${DIM}[default: ${container_name#vscode-}]${NC}${BRIGHT_WHITE}:${NC} "
    read container_hostname
    [ -z "$container_hostname" ] && container_hostname="${container_name#vscode-}"
    
    echo ""
    echo -e "  ${DIM}─────────────────────────────────────────────────────────${NC}"
    echo -e "  ${BRIGHT_CYAN}┃${NC}  ${BRIGHT_WHITE}NEOFETCH CUSTOM INFO${NC}  ${DIM}(what neofetch shows)${NC}"
    echo -e "  ${DIM}─────────────────────────────────────────────────────────${NC}"
    echo ""
    
    # CPU Model
    printf "  ${BRIGHT_CYAN}┃${NC} ${BRIGHT_WHITE}CPU Model${NC}        ${DIM}[e.g., AMD Ryzen 9 7950X]${NC}${BRIGHT_WHITE}:${NC} "
    read custom_cpu
    [ -z "$custom_cpu" ] && custom_cpu=""
    
    # GPU Model
    printf "  ${BRIGHT_CYAN}┃${NC} ${BRIGHT_WHITE}GPU Model${NC}        ${DIM}[e.g., NVIDIA RTX 4090]${NC}${BRIGHT_WHITE}:${NC} "
    read custom_gpu
    [ -z "$custom_gpu" ] && custom_gpu=""
    
    # Memory
    printf "  ${BRIGHT_CYAN}┃${NC} ${BRIGHT_WHITE}Memory${NC}            ${DIM}[e.g., 16384MiB / 32768MiB]${NC}${BRIGHT_WHITE}:${NC} "
    read custom_mem
    [ -z "$custom_mem" ] && custom_mem=""
    
    echo ""
    echo -e "  ${DIM}─────────────────────────────────────────────────────────${NC}"
    echo -e "  ${BRIGHT_CYAN}┃${NC}  ${BRIGHT_WHITE}NETWORK${NC}"
    echo -e "  ${DIM}─────────────────────────────────────────────────────────${NC}"
    echo ""
    
    # Port
    while true; do
        printf "  ${BRIGHT_CYAN}┃${NC} ${BRIGHT_WHITE}Port${NC}              ${DIM}[e.g., 8080]${NC}${BRIGHT_WHITE}:${NC} "
        read container_port
        if [ -z "$container_port" ]; then
            echo -e "  ${BRIGHT_RED}┃${NC}  ${RED}Port cannot be empty!${NC}"
            continue
        fi
        if ss -tlnp 2>/dev/null | grep -q ":${container_port} "; then
            echo -e "  ${BRIGHT_RED}┃${NC}  ${RED}Port $container_port is already in use!${NC}"
            continue
        fi
        break
    done
    
    # Password
    while true; do
        printf "  ${BRIGHT_CYAN}┃${NC} ${BRIGHT_WHITE}Password${NC}          ${DIM}[login password]${NC}${BRIGHT_WHITE}:${NC} "
        read container_password
        if [ -z "$container_password" ]; then
            echo -e "  ${BRIGHT_RED}┃${NC}  ${RED}Password cannot be empty!${NC}"
            continue
        fi
        break
    done
    
    echo ""
    echo -e "  ${DIM}─────────────────────────────────────────────────────────${NC}"
    echo -e "  ${BRIGHT_CYAN}┃${NC}  ${BRIGHT_WHITE}BUILDING${NC}"
    echo -e "  ${DIM}─────────────────────────────────────────────────────────${NC}"
    
    if ! build_os_image "$os_choice_selected"; then
        printf "  ${DIM}Press Enter to continue...${NC} "
        read
        return
    fi
    
    echo ""
    echo -e "  ${DIM}─────────────────────────────────────────────────────────${NC}"
    echo -e "  ${BRIGHT_CYAN}┃${NC}  ${BRIGHT_WHITE}DEPLOYING${NC}"
    echo -e "  ${DIM}─────────────────────────────────────────────────────────${NC}"
    
    # Build docker run command with optional env vars
    local docker_envs="-e PASSWORD=\"$container_password\""
    
    if [ -n "$custom_cpu" ]; then
        docker_envs="$docker_envs -e CUSTOM_CPU=\"$custom_cpu\""
    fi
    if [ -n "$custom_gpu" ]; then
        docker_envs="$docker_envs -e CUSTOM_GPU=\"$custom_gpu\""
    fi
    if [ -n "$custom_mem" ]; then
        docker_envs="$docker_envs -e CUSTOM_MEM=\"$custom_mem\""
    fi
    
    (
        eval docker run -d \
            --name "$container_name" \
            --hostname "$container_hostname" \
            -p "${container_port}:8080" \
            $docker_envs \
            --restart unless-stopped \
            "code-server:$image_tag" > /dev/null 2>&1
        echo $? > /tmp/docker-run-status
    ) &
    local run_pid=$!
    
    local frames="⣾⣽⣻⢿⡿⣟⣯⣷"
    local i=0
    tput civis
    while kill -0 $run_pid 2>/dev/null; do
        i=$(( (i+1) % ${#frames} ))
        printf "\r  ${BRIGHT_MAGENTA}${frames:$i:1}${NC} ${DIM}Starting container...${NC}                    "
        sleep 0.1
    done
    tput cnorm
    printf "\r  ${BRIGHT_GREEN}✔${NC} ${DIM}Container started${NC}                              \n"
    
    local run_status=$(cat /tmp/docker-run-status 2>/dev/null)
    rm -f /tmp/docker-run-status
    
    if [ "$run_status" = "0" ]; then
        echo ""
        echo -e "  ${BRIGHT_GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "  ${BRIGHT_GREEN}║${NC}           ${BRIGHT_WHITE}✔ CONTAINER CREATED SUCCESSFULLY${NC}               ${BRIGHT_GREEN}║${NC}"
        echo -e "  ${BRIGHT_GREEN}╠══════════════════════════════════════════════════════════╣${NC}"
        echo -e "  ${BRIGHT_GREEN}║${NC}                                                              ${BRIGHT_GREEN}║${NC}"
        echo -e "  ${BRIGHT_GREEN}║${NC}   ${BRIGHT_WHITE}Name${NC}     ${DIM}┃${NC}  ${BRIGHT_YELLOW}${container_name}${NC}"
        echo -e "  ${BRIGHT_GREEN}║${NC}   ${BRIGHT_WHITE}OS${NC}       ${DIM}┃${NC}  ${os_icon} ${os_name} ${os_ver}${NC}"
        echo -e "  ${BRIGHT_GREEN}║${NC}   ${BRIGHT_WHITE}Hostname${NC}  ${DIM}┃${NC}  ${BRIGHT_BLUE}${container_hostname}${NC}"
        
        if [ -n "$custom_cpu" ]; then
            echo -e "  ${BRIGHT_GREEN}║${NC}   ${BRIGHT_WHITE}CPU${NC}      ${DIM}┃${NC}  ${BRIGHT_CYAN}${custom_cpu}${NC}"
        fi
        if [ -n "$custom_gpu" ]; then
            echo -e "  ${BRIGHT_GREEN}║${NC}   ${BRIGHT_WHITE}GPU${NC}      ${DIM}┃${NC}  ${BRIGHT_MAGENTA}${custom_gpu}${NC}"
        fi
        if [ -n "$custom_mem" ]; then
            echo -e "  ${BRIGHT_GREEN}║${NC}   ${BRIGHT_WHITE}Memory${NC}   ${DIM}┃${NC}  ${BRIGHT_YELLOW}${custom_mem}${NC}"
        fi
        
        echo -e "  ${BRIGHT_GREEN}║${NC}   ${BRIGHT_WHITE}Port${NC}     ${DIM}┃${NC}  ${BRIGHT_MAGENTA}${container_port}${NC}"
        echo -e "  ${BRIGHT_GREEN}║${NC}   ${BRIGHT_WHITE}Password${NC}  ${DIM}┃${NC}  ${BRIGHT_CYAN}${container_password}${NC}"
        echo -e "  ${BRIGHT_GREEN}║${NC}   ${BRIGHT_WHITE}URL${NC}      ${DIM}┃${NC}  ${BRIGHT_WHITE}http://YOUR_IP:${container_port}${NC}"
        echo -e "  ${BRIGHT_GREEN}║${NC}   ${BRIGHT_WHITE}Terminal${NC}  ${DIM}┃${NC}  ${BRIGHT_GREEN}root@${container_hostname}${NC}"
        echo -e "  ${BRIGHT_GREEN}║${NC}                                                              ${BRIGHT_GREEN}║${NC}"
        echo -e "  ${BRIGHT_GREEN}║${NC}   ${DIM}Image: code-server:${image_tag}${NC}"
        echo -e "  ${BRIGHT_GREEN}║${NC}   ${DIM}Neofetch: auto-runs on terminal open${NC}"
        echo -e "  ${BRIGHT_GREEN}║${NC}                                                              ${BRIGHT_GREEN}║${NC}"
        echo -e "  ${BRIGHT_GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    else
        echo ""
        echo -e "  ${BRIGHT_RED}╭──────────────────────────────────────────────────────╮${NC}"
        echo -e "  ${BRIGHT_RED}│${NC}   ${BRIGHT_WHITE}✘ ERROR${NC}                                               ${BRIGHT_RED}│${NC}"
        echo -e "  ${BRIGHT_RED}│${NC}   Failed to create container!${NC}                             ${BRIGHT_RED}│${NC}"
        echo -e "  ${BRIGHT_RED}│${NC}   ${DIM}Run: docker logs $container_name${NC}                       ${BRIGHT_RED}│${NC}"
        echo -e "  ${BRIGHT_RED}╰──────────────────────────────────────────────────────╯${NC}"
        echo ""
    fi
    
    printf "  ${DIM}Press Enter to continue...${NC} "
    read
}

# Uninstall container
uninstall_container() {
    echo -e "  ${BRIGHT_RED}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${BRIGHT_RED}║${NC}  ${BRIGHT_WHITE}🗑️  UNINSTALL VSCODE VPS${NC}                              ${BRIGHT_RED}║${NC}"
    echo -e "  ${BRIGHT_RED}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local containers=$(docker ps -a --filter "name=vscode-" --format "{{.Names}}")
    
    if [ -z "$containers" ]; then
        echo -e "  ${BRIGHT_RED}╭──────────────────────────────────────────────────────╮${NC}"
        echo -e "  ${BRIGHT_RED}│${NC}   ${BRIGHT_WHITE}✘ ERROR${NC}                                               ${BRIGHT_RED}│${NC}"
        echo -e "  ${BRIGHT_RED}│${NC}   No containers found to uninstall!${NC}                      ${BRIGHT_RED}│${NC}"
        echo -e "  ${BRIGHT_RED}╰──────────────────────────────────────────────────────╯${NC}"
        echo ""
        sleep 2
        return
    fi
    
    list_containers
    
    printf "  ${BRIGHT_RED}┃${NC} ${BRIGHT_WHITE}Container name to delete${NC}${BRIGHT_WHITE}:${NC} "
    read container_name
    
    if [ -z "$container_name" ]; then
        echo -e "  ${BRIGHT_RED}╭──────────────────────────────────────────────────────╮${NC}"
        echo -e "  ${BRIGHT_RED}│${NC}   ${BRIGHT_WHITE}✘ ERROR${NC}                                               ${BRIGHT_RED}│${NC}"
        echo -e "  ${BRIGHT_RED}│${NC}   Name cannot be empty!${NC}                                  ${BRIGHT_RED}│${NC}"
        echo -e "  ${BRIGHT_RED}╰──────────────────────────────────────────────────────╯${NC}"
        echo ""
        sleep 2
        return
    fi
    
    [[ ! "$container_name" =~ ^vscode- ]] && container_name="vscode-${container_name}"
    
    if ! docker ps -a --format "{{.Names}}" | grep -q "^${container_name}$"; then
        echo -e "  ${BRIGHT_RED}╭──────────────────────────────────────────────────────╮${NC}"
        echo -e "  ${BRIGHT_RED}│${NC}   ${BRIGHT_WHITE}✘ ERROR${NC}                                               ${BRIGHT_RED}│${NC}"
        echo -e "  ${BRIGHT_RED}│${NC}   Container '${BRIGHT_WHITE}${container_name}${BRIGHT_RED}' not found!${NC}                   ${BRIGHT_RED}│${NC}"
        echo -e "  ${BRIGHT_RED}╰──────────────────────────────────────────────────────╯${NC}"
        echo ""
        sleep 2
        return
    fi
    
    echo ""
    printf "  ${BRIGHT_YELLOW}┃${NC} ${BRIGHT_WHITE}Confirm delete '${BRIGHT_RED}${container_name}${BRIGHT_WHITE}'?${NC} ${DIM}[y/N]${NC}${BRIGHT_WHITE}:${NC} "
    read confirm
    if [[ "$confirm" != [yY] ]]; then
        echo -e "  ${DIM}Cancelled.${NC}"
        sleep 1
        return
    fi
    
    echo ""
    
    (
        docker stop "$container_name" > /dev/null 2>&1
        docker rm "$container_name" > /dev/null 2>&1
        echo $? > /tmp/docker-rm-status
    ) &
    local rm_pid=$!
    
    local frames="⣾⣽⣻⢿⡿⣟⣯⣷"
    local i=0
    tput civis
    while kill -0 $rm_pid 2>/dev/null; do
        i=$(( (i+1) % ${#frames} ))
        printf "\r  ${BRIGHT_RED}${frames:$i:1}${NC} ${DIM}Removing container...${NC}                    "
        sleep 0.1
    done
    tput cnorm
    
    local rm_status=$(cat /tmp/docker-rm-status 2>/dev
