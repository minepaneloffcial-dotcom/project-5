#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo -e "${CYAN}████████╗░█████╗░░██████╗██╗███╗░░██╗${NC}"
    echo -e "${BLUE}░░░██║░░░███████║╚█████╗░██║██╔██╗██║${NC}"
    echo -e "${MAGENTA}░░░██║░░░██╔══██║░╚═══██╗██║██║╚████║${NC}"
    echo -e "${MAGENTA}░░░██║░░░██║░░██║██████╔╝██║██║░╚███║${NC}"
    echo -e "${RED}░░░╚═╝░░░╚═╝░░╚═╝╚═════╝░╚═╝╚═╝░░╚══╝${NC}"
    echo -e "${NC}"
    echo -e "${BOLD}${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║${NC}     ${BOLD}${YELLOW}Welcome to iTzTasin69 VsCode VPS MAKER${NC}              ${BOLD}${GREEN}║${NC}"
    echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Count containers
count_containers() {
    docker ps -a --filter "ancestor=ghcr.io/coder/code-server:latest" --format "{{.Names}}" | wc -l
}

# List containers
list_containers() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                         ${BOLD}Your VsCode Containers${NC}                               ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${DIM}#    Name            Hostname         Status       Port${NC}                   ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════════════╣${NC}"
    
    local containers=$(docker ps -a --filter "ancestor=ghcr.io/coder/code-server:latest" --format "{{.Names}}|{{.Status}}|{{.Ports}}" 2>/dev/null)
    
    if [ -z "$containers" ]; then
        echo -e "${CYAN}║${NC}  ${RED}No containers found!${NC}                                                                  ${CYAN}║${NC}"
    else
        local num=1
        while IFS='|' read -r name status ports; do
            # Get hostname
            local hostname=$(docker inspect -f '{{.Config.Hostname}}' "$name" 2>/dev/null)
            if [ -z "$hostname" ]; then
                hostname="N/A"
            fi
            
            # Extract port
            local port=$(echo "$ports" | grep -oP '0.0.0.0:\K[0-9]+' | head -1)
            if [ -z "$port" ]; then
                port="N/A"
            fi
            
            # Status color
            local status_color="$RED"
            local status_text="STOPPED"
            if echo "$status" | grep -q "Up"; then
                status_color="$GREEN"
                status_text="RUNNING"
            fi
            
            printf "${CYAN}║${NC} ${BOLD}%2d${NC}   ${YELLOW}%-15s${NC}  ${BLUE}%-15s${NC}  ${status_color}%-10s${NC}  ${MAGENTA}%-6s${NC}   ${CYAN}║${NC}\n" "$num" "$name" "$hostname" "$status_text" "$port"
            num=$((num + 1))
        done <<< "$containers"
    fi
    
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Install container
install_container() {
    echo -e "${BOLD}${YELLOW}══════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${GREEN}              🚀 CREATE NEW VSCODE VPS${NC}"
    echo -e "${BOLD}${YELLOW}══════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Name
    read -p "$(echo -e ${CYAN}"Enter container name: "${NC})" container_name
    if [ -z "$container_name" ]; then
        echo -e "${RED}✗ Name cannot be empty!${NC}"
        sleep 2
        return
    fi
    
    # Check if name exists
    if docker ps -a --format "{{.Names}}" | grep -q "^${container_name}$"; then
        echo -e "${RED}✗ Container with name '$container_name' already exists!${NC}"
        sleep 2
        return
    fi
    
    # Hostname
    read -p "$(echo -e ${CYAN}"Enter hostname (e.g., tasin-vps): "${NC})" container_hostname
    if [ -z "$container_hostname" ]; then
        container_hostname="$container_name"
        echo -e "${DIM}  → Using container name as hostname: $container_hostname${NC}"
    fi
    
    # Port
    read -p "$(echo -e ${CYAN}"Enter port (e.g., 8080): "${NC})" container_port
    if [ -z "$container_port" ]; then
        echo -e "${RED}✗ Port cannot be empty!${NC}"
        sleep 2
        return
    fi
    
    # Check if port is in use
    if netstat -tlnp 2>/dev/null | grep -q ":${container_port} "; then
        echo -e "${RED}✗ Port $container_port is already in use!${NC}"
        sleep 2
        return
    fi
    
    # Password
    read -p "$(echo -e ${CYAN}"Enter password: "${NC})" container_password
    if [ -z "$container_password" ]; then
        echo -e "${RED}✗ Password cannot be empty!${NC}"
        sleep 2
        return
    fi
    
    echo ""
    echo -e "${DIM}Creating container...${NC}"
    
    # Run docker with custom hostname
    docker run -d \
        --name "$container_name" \
        --hostname "$container_hostname" \
        -p "${container_port}:8080" \
        -e PASSWORD="$container_password" \
        --restart unless-stopped \
        ghcr.io/coder/code-server:latest > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║${NC}           ${BOLD}${GREEN}✓ CONTAINER CREATED SUCCESSFULLY!${NC}              ${GREEN}║${NC}"
        echo -e "${GREEN}╠═══════════════════════════════════════════════════════════╣${NC}"
        echo -e "${GREEN}║${NC}  ${BOLD}Name:${NC}     ${YELLOW}$container_name${NC}"
        echo -e "${GREEN}║${NC}  ${BOLD}Hostname:${NC} ${BLUE}$container_hostname${NC}"
        echo -e "${GREEN}║${NC}  ${BOLD}Port:${NC}     ${MAGENTA}$container_port${NC}"
        echo -e "${GREEN}║${NC}  ${BOLD}Password:${NC} ${CYAN}$container_password${NC}"
        echo -e "${GREEN}║${NC}  ${BOLD}URL:${NC}      ${WHITE}http://YOUR_IP:$container_port${NC}"
        echo -e "${GREEN}║${NC}  ${BOLD}Terminal:${NC}  ${DIM}root@${container_hostname}${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    else
        echo -e "${RED}✗ Failed to create container! Check Docker logs.${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Uninstall container
uninstall_container() {
    echo -e "${BOLD}${YELLOW}══════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${RED}                🗑️  UNINSTALL VSCODE VPS${NC}"
    echo -e "${BOLD}${YELLOW}══════════════════════════════════════════════════════${NC}"
    echo ""
    
    local containers=$(docker ps -a --filter "ancestor=ghcr.io/coder/code-server:latest" --format "{{.Names}}")
    
    if [ -z "$containers" ]; then
        echo -e "${RED}✗ No containers found to uninstall!${NC}"
        sleep 2
        return
    fi
    
    list_containers
    
    read -p "$(echo -e ${RED}"Enter container name to delete: "${NC})" container_name
    
    if [ -z "$container_name" ]; then
        echo -e "${RED}✗ Name cannot be empty!${NC}"
        sleep 2
        return
    fi
    
    # Check if container exists
    if ! docker ps -a --format "{{.Names}}" | grep -q "^${container_name}$"; then
        echo -e "${RED}✗ Container '$container_name' not found!${NC}"
        sleep 2
        return
    fi
    
    # Confirm
    read -p "$(echo -e ${YELLOW}"Are you sure you want to delete '$container_name'? [y/N]: "${NC})" confirm
    if [[ "$confirm" != [yY] ]]; then
        echo -e "${DIM}Cancelled.${NC}"
        sleep 1
        return
    fi
    
    echo -e "${YELLOW}Stopping and removing $container_name...${NC}"
    
    docker stop "$container_name" > /dev/null 2>&1
    docker rm "$container_name" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Container '$container_name' deleted successfully!${NC}"
    else
        echo -e "${RED}✗ Failed to delete container!${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Main menu
show_menu() {
    local count=$(count_containers)
    
    echo -e "${BOLD}${MAGENTA}┌─────────────────────────────────────────┐${NC}"
    echo -e "${BOLD}${MAGENTA}│${NC}            ${BOLD}${WHITE}MAIN MENU${NC}                   ${BOLD}${MAGENTA}│${NC}"
    echo -e "${BOLD}${MAGENTA}├─────────────────────────────────────────┤${NC}"
    echo -e "${BOLD}${MAGENTA}│${NC}  ${GREEN}[1]${NC} ${BOLD}Install VsCode VPS${NC}               ${BOLD}${MAGENTA}│${NC}"
    echo -e "${BOLD}${MAGENTA}│${NC}  ${RED}[2]${NC} ${BOLD}Uninstall VsCode VPS${NC}             ${BOLD}${MAGENTA}│${NC}"
    echo -e "${BOLD}${MAGENTA}│${NC}  ${CYAN}[3]${NC} ${BOLD}List All Containers${NC}              ${BOLD}${MAGENTA}│${NC}"
    echo -e "${BOLD}${MAGENTA}│${NC}  ${YELLOW}[4]${NC} ${BOLD}Exit${NC}                              ${BOLD}${MAGENTA}│${NC}"
    echo -e "${BOLD}${MAGENTA}├─────────────────────────────────────────┤${NC}"
    echo -e "${BOLD}${MAGENTA}│${NC}  ${DIM}Total Containers: ${BOLD}${YELLOW}${count}${NC}${DIM}${NC}                    ${BOLD}${MAGENTA}│${NC}"
    echo -e "${BOLD}${MAGENTA}└─────────────────────────────────────────┘${NC}"
    echo ""
    read -p "$(echo -e ${BOLD}${WHITE}"Select option [1-4]: "${NC})" choice
    
    case $choice in
        1)
            install_container
            ;;
        2)
            uninstall_container
            ;;
        3)
            list_containers
            read -p "Press Enter to continue..."
            ;;
        4)
            echo -e "${GREEN}Goodbye! 👋${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            sleep 1
            ;;
    esac
}

# Check if docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}✗ Docker is not installed!${NC}"
        echo -e "${YELLOW}Please install Docker first:${NC}"
        echo -e "${CYAN}curl -fsSL https://get.docker.com -o get-docker.sh${NC}"
        echo -e "${CYAN}sh get-docker.sh${NC}"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}✗ Docker is not running!${NC}"
        echo -e "${YELLOW}Start Docker with:${NC}"
        echo -e "${CYAN}systemctl start docker${NC}"
        exit 1
    fi
}

# Pull image
pull_image() {
    echo -e "${DIM}Checking for code-server image...${NC}"
    if ! docker image inspect ghcr.io/coder/code-server:latest &> /dev/null; then
        echo -e "${YELLOW}Pulling code-server image (this may take a moment)...${NC}"
        docker pull ghcr.io/coder/code-server:latest
        if [ $? -ne 0 ]; then
            echo -e "${RED}✗ Failed to pull image!${NC}"
            exit 1
        fi
        echo -e "${GREEN}✓ Image pulled successfully!${NC}"
    else
        echo -e "${GREEN}✓ Image already exists!${NC}"
    fi
    echo ""
}

# Main
main() {
    check_docker
    pull_image
    
    while true; do
        show_banner
        show_menu
    done
}

main
