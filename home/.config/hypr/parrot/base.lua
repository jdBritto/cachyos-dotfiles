-- Datos comunes: rutas, tema elegido, modo de rendimiento y programas.
local M = {}

M.home    = os.getenv("HOME")
M.dir     = M.home .. "/.config/hypr"
M.gen     = M.dir .. "/generado"   -- archivos que crean los scripts
M.scripts = M.dir .. "/scripts"

local function leer(ruta)
    local f = io.open(ruta)
    if not f then return nil end
    local s = f:read("l")
    f:close()
    if s then s = s:gsub("%s+$", "") end
    if s == "" then return nil end
    return s
end
M.leer = leer

-- Un tema es un archivo clave=valor en temas/<id>.tema
function M.cargar_tema(id)
    local f = io.open(M.dir .. "/temas/" .. id .. ".tema")
    if not f then return nil end
    local t = {}
    for linea in f:lines() do
        local k, v = linea:match('^%s*([%w_]+)%s*=%s*"?([^"]*)"?%s*$')
        if k then t[k] = v end
    end
    f:close()
    return t
end

M.tema_id = leer(M.gen .. "/tema") or "parrot"
M.tema    = M.cargar_tema(M.tema_id) or M.cargar_tema("parrot")

-- equilibrado | rendimiento | ahorro  (scripts/modo.sh)
M.modo = leer(M.gen .. "/modo") or "equilibrado"
-- dwindle (mosaico) | master (principal) | scrolling (columnas, como Niri)
M.distribucion = leer(M.gen .. "/distribucion") or "dwindle"

-- "2ecc71" -> "rgba(2ecc71ff)"
function M.color(hex, alfa)
    return "rgba(" .. hex .. (alfa or "ff") .. ")"
end

function M.script(nombre)
    return M.scripts .. "/" .. nombre
end

M.programas = {
    terminal  = M.script("terminal.sh"),   -- Ghostty con el tema (o Kitty)
    navegador = M.script("navegador.sh"),
    archivos  = "nautilus --new-window",
    tareas    = M.script("terminal.sh") .. " --title Tareas -e btop",
}

return M
