-- Datos comunes de la capa custom: rutas y estado guardado por los scripts.
local M = {}

M.home    = os.getenv("HOME")
M.dir     = M.home .. "/.config/hypr"
M.scripts = M.dir .. "/scripts"
M.estado  = M.home .. "/.local/state/hypr-cachyos"   -- lo escribe modo.sh

function M.existe(ruta)
    local f = io.open(ruta)
    if f then f:close() end
    return f ~= nil
end

function M.leer(ruta)
    local f = io.open(ruta)
    if not f then return nil end
    local s = f:read("l")
    f:close()
    if s then s = s:gsub("%s+$", "") end
    if s == "" then return nil end
    return s
end

function M.script(nombre)
    return M.scripts .. "/" .. nombre
end

-- equilibrado | rendimiento | ahorro  (scripts/modo.sh)
M.modo = M.leer(M.estado .. "/modo") or "equilibrado"

return M
