#!/usr/bin/env bash
# Slider de brilho (estilo notebook) para monitor externo no GNOME via DDC/CI.
# Testado: LG 25UM58G (HDMI) - Fedora 44 - GNOME 50.
set -euo pipefail

UUID="display-brightness-ddcutil@themightydeity.github.com"

echo "==> verificando ddcutil"
if ! command -v ddcutil >/dev/null; then
    if command -v rpm-ostree >/dev/null; then
        echo "Instale com: sudo rpm-ostree install ddcutil  (e reinicie)"; exit 1
    elif command -v dnf >/dev/null; then
        sudo dnf install -y ddcutil
    elif command -v apt >/dev/null; then
        sudo apt install -y ddcutil
    else
        echo "Instale o pacote ddcutil pelo gerenciador da sua distro."; exit 1
    fi
fi

echo "==> módulo i2c-dev"
if ! lsmod | grep -q '^i2c_dev'; then
    sudo modprobe i2c-dev
    echo i2c-dev | sudo tee /etc/modules-load.d/i2c-dev.conf >/dev/null
fi

echo "==> detectando monitores (DDC/CI)"
if ! ddcutil detect --brief 2>/dev/null | grep -q '^Display'; then
    cat <<'EOF'
Nenhum monitor respondeu ao DDC/CI.
 - Ative "DDC/CI" no menu físico do monitor (LG: Configurações > Geral).
 - Se der erro de permissão em /dev/i2c-*: sudo usermod -aG i2c "$USER" e faça login de novo.
EOF
    exit 1
fi
ddcutil detect --brief
ddcutil getvcp 10 || true

echo "==> instalando extensão $UUID (extensions.gnome.org)"
SHELL_MAJOR=$(gnome-shell --version | grep -oE '[0-9]+' | head -1)
INFO=$(curl -fsSL "https://extensions.gnome.org/extension-info/?uuid=${UUID}&shell_version=${SHELL_MAJOR}")
URL=$(python3 -I -c 'import json,sys; print(json.load(sys.stdin)["download_url"])' <<<"$INFO")
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
curl -fsSL -o "$TMP/ext.zip" "https://extensions.gnome.org${URL}"
gnome-extensions install --force "$TMP/ext.zip"

echo "==> marcando como ativa"
python3 -I - "$UUID" <<'EOF'
import ast, subprocess, sys
uuid = sys.argv[1]
raw = subprocess.run(["gsettings", "get", "org.gnome.shell", "enabled-extensions"],
                     capture_output=True, text=True).stdout.strip().replace("@as ", "")
cur = ast.literal_eval(raw) if raw else []
if uuid not in cur:
    cur.append(uuid)
    subprocess.run(["gsettings", "set", "org.gnome.shell", "enabled-extensions", str(cur)], check=True)
EOF
gnome-extensions enable "$UUID" 2>/dev/null || true

cat <<EOF

Pronto! Faça logout/login para o GNOME carregar a extensão.
O slider aparece nas Configurações Rápidas (canto superior direito).
EOF
