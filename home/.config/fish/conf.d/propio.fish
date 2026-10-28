# Lo propio en fish (conf.d no lo toca el setup de ii). Los mismos alias que en zsh.
status is-interactive; or exit

# Hacking etico
alias ips 'ip -br -c addr'
alias myip 'curl -s https://ifconfig.me; echo'
alias vpnip 'vpn-ip; or echo "Sin VPN activa"'
alias ports 'sudo ss -tulpn'
alias listen 'nc -lvnp'
alias nmapq 'nmap -T4 -F'
alias nmapf 'sudo nmap -sC -sV -p- -T4 -oN nmap_full.txt'
alias hist 'history | grep -i'

if command -q eza
    alias ll 'eza -lh --group-directories-first --icons=auto --git --time-style=relative'
    alias lla 'll -a'
    alias tree 'eza --tree --icons=auto --group-directories-first'
end

# Servir la carpeta actual por HTTP: serve [puerto]
function serve
    set -l port (test -n "$argv[1]"; and echo $argv[1]; or echo 8000)
    echo "Sirviendo "(pwd)" en:"
    ip -4 -o addr | awk -v p=$port '$2!="lo"{split($4,a,"/"); print "  http://"a[1]":"p}'
    python3 -m http.server $port
end

# Carpeta de trabajo para una maquina: box nombre [ip]
function box
    if test -z "$argv[1]"
        echo "Uso: box <nombre> [ip]"; return 1
    end
    mkdir -p ~/boxes/$argv[1]/{nmap,loot,exploits}; and cd ~/boxes/$argv[1]
    if test -n "$argv[2]"
        set -gx TARGET $argv[2]; echo "TARGET=$argv[2]"
    end
    echo "Carpeta lista: "(pwd)
end

function atajos
    set_color -o green; echo "Fish"; set_color normal
    echo "  →  / Ctrl+F      aceptar sugerencia gris"
    echo "  Alt+→            aceptar una palabra de la sugerencia"
    echo "  Ctrl+R           buscar en historial"
    echo "  Alt+S            agregar sudo al comando"
    echo "  zsh              volver a zsh (Ctrl+Shift+Alt+Z abre una pestana)"
    set_color -o green; echo "Hacking"; set_color normal
    echo "  ips  myip  vpnip  ports  serve [puerto]  listen <puerto>"
    echo "  nmapq <ip>  nmapf <ip>  box <nombre> [ip]  hist <texto>"
end
