#!/usr/bin/env -S python3 -I
"""Cambia ajustes de end4-pC desde fuera de su ventana de ajustes.

end4-pC guarda sus ajustes en ~/.config/illogical-impulse/config.json y, al abrir su
pagina de Hyprland, reescribe ~/.config/hypr/hyprland/shellOverrides/main.lua con
ellos. Por eso cada cambio se hace en los dos sitios: si solo se tocara Hyprland,
end4-pC lo desharia la siguiente vez.

  ajustes-end4.py inicial [--forzar]   valores de este equipo (una sola vez)
  ajustes-end4.py poner CLAVE VALOR    p. ej.  poner general.layout scrolling
  ajustes-end4.py ver CLAVE            p. ej.  ver general.layout
  ajustes-end4.py reaplicar            vuelve a escribir los tiempos de inactividad
                                       de end4-pC en hypridle.conf (tras reinstalar)
"""
import json
import os
import re
import subprocess
import sys
import tempfile
import time

HOME = os.path.expanduser("~")
CONFIG = f"{HOME}/.config/illogical-impulse/config.json"
SHELL = f"{HOME}/.config/quickshell/end4-pC/scripts/hyprland"
OVERRIDES = f"{HOME}/.config/hypr/hyprland/shellOverrides/main.lua"
HYPRIDLE = f"{HOME}/.config/hypr/hypridle.conf"
MARCA = f"{HOME}/.local/state/hypr-cachyos/ajustes-iniciales"

# Clave en config.json (dentro de "hyprland") -> opcion de Hyprland
HYPR = {
    "general.layout": "general:layout",
    "input.kbLayout": "input:kb_layout",
    "input.repeatDelay": "input:repeat_delay",
    "input.repeatRate": "input:repeat_rate",
    "input.touchpad.naturalScroll": "input:touchpad:natural_scroll",
    "input.touchpad.clickfingerBehavior": "input:touchpad:clickfinger_behavior",
    "input.touchpad.disableWhileTyping": "input:touchpad:disable_while_typing",
    "input.touchpad.scrollFactor": "input:touchpad:scroll_factor",
}


def teclado_sistema():
    """Distribucion de teclado de CachyOS (localectl set-x11-keymap)."""
    try:
        with open("/etc/X11/xorg.conf.d/00-keyboard.conf") as f:
            m = re.search(r'Option\s+"XkbLayout"\s+"([^"]+)"', f.read())
            return m.group(1) if m else "us"
    except OSError:
        return "us"


def inicial():
    """Valores para un portatil con CachyOS (los de end4-pC son de escritorio)."""
    return {
        "input.kbLayout": teclado_sistema(),
        "input.repeatDelay": 300,
        "input.touchpad.naturalScroll": True,
        "input.touchpad.clickfingerBehavior": True,
        "input.touchpad.scrollFactor": 0.8,
        # Bloquear a los 5 min, apagar pantalla a los 6, suspender a los 30
        # (scripts/suspender.sh no suspende si esta enchufado)
        "idle.lock": 300,
        "idle.screenOff": 360,
        "idle.suspend": 1800,
    }


def leer():
    with open(CONFIG) as f:
        return json.load(f)


def escribir(datos):
    carpeta = os.path.dirname(CONFIG)
    with tempfile.NamedTemporaryFile("w", dir=carpeta, delete=False) as f:
        json.dump(datos, f, indent=4, ensure_ascii=False)
        f.write("\n")
    os.chmod(f.name, os.stat(CONFIG).st_mode)
    os.replace(f.name, CONFIG)


def obtener(datos, clave):
    d = datos["hyprland"]
    for parte in clave.split("."):
        d = d[parte]
    return d


def fijar(datos, clave, valor):
    d = datos.setdefault("hyprland", {})
    *ruta, ultima = clave.split(".")
    for parte in ruta:
        d = d.setdefault(parte, {})
    d[ultima] = valor


def convertir(texto):
    """'true' -> True, '300' -> 300, '0.8' -> 0.8, lo demas texto."""
    if texto in ("true", "false"):
        return texto == "true"
    for tipo in (int, float):
        try:
            return tipo(texto)
        except ValueError:
            pass
    return texto


def aplicar(datos, claves):
    """Escribe en Hyprland (overrides de end4-pC y hypridle.conf) lo de config.json."""
    orden = ["python3", "-I", f"{SHELL}/hyprconfigurator.py", "--file", OVERRIDES]
    hay = False
    for clave in claves:
        if clave in HYPR:
            v = obtener(datos, clave)
            if isinstance(v, bool):
                v = int(v)
            orden += ["--set", HYPR[clave], str(v)]
            hay = True
    if hay:
        subprocess.run(orden, check=True, stdout=subprocess.DEVNULL)
    if any(c.startswith("idle.") for c in claves):
        i = datos["hyprland"]["idle"]
        subprocess.run(["python3", "-I", f"{SHELL}/hypridleconfigurator.py", "--file", HYPRIDLE,
                        "--lock", str(i["lock"]), "--screen-off", str(i["screenOff"]),
                        "--suspend", str(i["suspend"])], check=True, stdout=subprocess.DEVNULL)
        subprocess.run("pgrep -x hypridle >/dev/null && "
                       "{ pkill -x hypridle; sleep 0.3; setsid -f hypridle >/dev/null 2>&1; }",
                       shell=True)
    if os.environ.get("HYPRLAND_INSTANCE_SIGNATURE"):
        subprocess.run(["hyprctl", "reload"], stdout=subprocess.DEVNULL)


def esperar_config(segundos=60):
    """En la primera sesion end4-pC crea config.json al arrancar: se espera."""
    for _ in range(segundos):
        if os.path.exists(CONFIG):
            time.sleep(2)   # que termine de escribirlo
            return True
        time.sleep(1)
    return False


def main(args):
    if not args or args[0] in ("-h", "--help"):
        print(__doc__.strip())
        return 0
    orden = args[0]
    if orden == "inicial":
        if os.path.exists(MARCA) and "--forzar" not in args:
            return 0
        if not esperar_config():
            print("No existe config.json de end4-pC (arranca la interfaz primero).", file=sys.stderr)
            return 1
        datos = leer()
        valores = inicial()
        for clave, valor in valores.items():
            fijar(datos, clave, valor)
        escribir(datos)
        aplicar(datos, valores)
        os.makedirs(os.path.dirname(MARCA), exist_ok=True)
        open(MARCA, "w").close()
        return 0
    if orden == "poner" and len(args) == 3:
        datos = leer()
        fijar(datos, args[1], convertir(args[2]))
        escribir(datos)
        aplicar(datos, [args[1]])
        return 0
    if orden == "reaplicar":
        if os.path.exists(CONFIG) and os.path.exists(MARCA):
            aplicar(leer(), ["idle.lock"])
        return 0
    if orden == "ver" and len(args) == 2:
        v = obtener(leer(), args[1])
        print(json.dumps(v) if isinstance(v, bool) else v)
        return 0
    print(__doc__.strip(), file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
