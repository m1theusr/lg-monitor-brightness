# Brilho do monitor externo no GNOME (LG 25UM58G)

Adiciona um slider de brilho nas Configurações Rápidas do GNOME, igual ao de notebook, para um monitor externo.
O brilho é controlado por **DDC/CI**, um protocolo que deixa o computador mudar as configurações do monitor pelo cabo de vídeo.

- **Monitor:** LG 25UM58G (25" ultrawide), via HDMI (`/dev/i2c-1`).
- **Sistema:** Fedora 44 com GNOME 50.
- **Backend:** [`ddcutil`](https://www.ddcutil.com/).
- **Extensão:** [Brightness control using ddcutil](https://extensions.gnome.org/extension/2645/brightness-control-using-ddcutil/) ([código](https://github.com/daitj/gnome-display-brightness-ddcutil)).

## Instalação

```bash
./install.sh
```

O script faz o seguinte:

1. Confere ou instala o `ddcutil`.
2. Carrega o módulo `i2c-dev` e o configura para carregar no boot.
3. Verifica se o monitor responde ao DDC/CI.
4. Baixa a versão da extensão compatível com o seu GNOME, a partir do extensions.gnome.org, e a ativa.

Depois, faça logout e login.

## Comandos úteis

```bash
ddcutil detect            # lista os monitores
ddcutil getvcp 10         # mostra o brilho atual (código VCP 0x10)
ddcutil setvcp 10 70      # muda o brilho para 70%
ddcutil setvcp 12 50      # muda o contraste
```

## Problemas comuns

- **"No displays found":** ative a opção **DDC/CI** no menu físico do monitor.
- **Erro de permissão em `/dev/i2c-*`:** rode `sudo usermod -aG i2c $USER` e faça login de novo.
- **O slider demora para aparecer:** isso é normal, a detecção pelo DDC leva alguns segundos no login.
