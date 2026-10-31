
--[[ 
WALLPAPER CHANGER V. 1.1 (HOTFIX)

This is a simple wallpaper changer made in LUA. Made by Santiago [https://santiagocalebe.neocitites.org]

1. How to use it?
    
    In this hotfix, you don't need to change directory, because the script detects the images folder of your modfolder.
    So now, you only need to use the event in-game.

    https://github.com/SantiagoCalebe/WallpaperChanger/
]]


local ffi = require("ffi")
local currentWallpaperPath = os.getenv("APPDATA") .. "\\Microsoft\\Windows\\Themes\\TranscodedWallpaper"
local backupPath = os.getenv("APPDATA") .. "\\Microsoft\\Windows\\Themes\\TranscodedWallpaper.png"
local savedWallpaperPath = os.getenv("APPDATA") .. "\\Microsoft\\Windows\\Themes\\TranscodedWallpaper.png"

local function getModDirectory()
    local info = debug.getinfo(1, "S") 
    local scriptPath = info.source:sub(2) 
    
    
    local modDir = scriptPath:match("(.*[\\/])") 
    return modDir .. "../images/" 
end

local wallpaperDir = getModDirectory()

local function logMessage(message)
    local userDesktop = os.getenv("USERPROFILE") .. "\\Desktop\\log.txt" 
    local timestamp = os.date("%Y-%m-%d %H:%M:%S") 
    local songname = ""..songName..""

    
    local formattedMessage = string.format("[%s] [%s] - %s\n", timestamp, songname, message)

    local file = io.open(userDesktop, "a") 
    if file then
        file:write(formattedMessage) 
        file:close()
    else
        print("Error opening log file.")
    end
end

function copyCurrentWallpaper()
local result = os.execute('copy "' .. currentWallpaperPath .. '" "' .. backupPath .. '"')
    if result then
        logMessage("Current wallpaper copied to: " .. backupPath)
    else
        logMessage("Failed to copy current wallpaper.")
    end
end

function onStartCountdown()
    copyCurrentWallpaper()
end

local function getAbsolutePath(relativePath)
    local currentDir = io.popen("cd"):read("*l")
    return currentDir .. "\\" .. relativePath:gsub("/", "\\")
end

ffi.cdef[[
    int SystemParametersInfoA(unsigned int uiAction, unsigned int uiParam, const char *pvParam, unsigned int fWinIni);
]]


local SPI_SETDESKWALLPAPER = 0x0014 
local SPI_GETDESKWALLPAPER = 0x0073 
local SPIF_UPDATEINIFILE = 0x01     
local SPIF_SENDCHANGE = 0x02        

function changeWallpaper(imageName)
    local imagePath = getAbsolutePath(wallpaperDir .. imageName) 

    
    local file = io.open(imagePath, "rb")
    if not file then
        logMessage("Returned Null: File not Found - " .. imagePath)
        return false 
    end
    file:close()

    ffi.C.SystemParametersInfoA(SPI_GETDESKWALLPAPER, 256, originalWallpaper, 0)

    local result = ffi.C.SystemParametersInfoA(SPI_SETDESKWALLPAPER, 0, imagePath, SPIF_UPDATEINIFILE + SPIF_SENDCHANGE)

    if result == 0 then
        logMessage("Failed to change wallpaper to: " .. imageName)
        return false
    else
        logMessage("Wallpaper change was successful! - " .. imageName)
        return true
    end
end

function restoreOriginalWallpaper()
    
    local result = ffi.C.SystemParametersInfoA(SPI_SETDESKWALLPAPER, 0, savedWallpaperPath, SPIF_UPDATEINIFILE + SPIF_SENDCHANGE)

    if result == 0 then
        logMessage("Returned Null: Failed to restore user's default wallpaper.")
    else
        logMessage("Default wallpaper restored successfully.")
    end
end

function handleCommand(command, imageName)
    command = command:lower() 

    if command == "on" then
        changeWallpaper(imageName) 
        logMessage("Command 'ON' was received.")

    elseif command == "off" then
        restoreOriginalWallpaper()
        logMessage("Command 'OFF' was received.")

    else
        logMessage("Invalid Command: " .. command)
        logMessage("Valid commands are: 'ON' and 'OFF'")
    end
end

function onEvent(eventName, value1, value2)
    if eventName == 'WallpaperChanger' then
        handleCommand(value1, value2) 
    end 
end 

function onDestroy()
    restoreOriginalWallpaper()
end