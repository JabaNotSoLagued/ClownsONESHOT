--[[

>>> Video Player Event(s) for Psych Engine.
	The good old video player event, updated to work with all versions of Psych Engine.

	This script is quite overkill considering it doesn't actually add any new functionality, 
	Just makes it more accessible for less technical users.

	* Supports all parameters for the built-in startVideo function.
    * Supports camera and layer settings, allowing video to be played behind the HUD.
	* Backward compatible.
	* Includes debugging output to a log file.

    Version Compatibility:
    - Psych Engine 1.0.2+: Full parameter support (canSkip, forMidSong, shouldLoop, playOnLoad)
    - Psych Engine 1.0 - 1.0.1: Limited support (canSkip only)
    - Psych Engine 0.7.3 and below: No optional parameters

	Script by AutisticLulu.

	Usage:
		>>> Video Player:
			Value 1:
				Video filename (without extension), Camera [camGame/camHUD/camOther], Layer [Integer])
				(Example: cutscene1)
				(Example: cutscene1, camOther,

			Value 2:
				Skippable [true/false], Mid-Song [true/false], Loop [true/false], Play On Load [true/false]
				(Example: true, true, false, true)

		If no video filename is specified, the event will not trigger.
		If no parameters are specified, it falls back to the specified defaults in the script.

		>>> Video Player Control:
			Value 1:
				Action to perform: play, pause, resume, setCamera, setLayer
				(Example: play)

			Value 2:
				Additional parameter for the various "set" commands.
				For setCamera: camera name (camGame, camHUD, camOther)
				For setLayer: layer number (0 = bottom)
]]

-- #####################################################################
-- [[ Script Setting Variables ]]
-- Users can modify these variables freely.
-- #####################################################################

local enableDebug = false
local enableFileLogging = true
local debugLogBuffer = ""
local modFolder = nil
local logFilePath = nil

local defaultCanSkip = true
local defaultForMidSong = true
local defaultShouldLoop = false
local defaultPlayOnLoad = true
local defaultCamera = "camOther"
local defaultLayer = nil

-- #####################################################################
-- [[ Debug Functions ]]
-- #####################################################################

-- Enhanced debug logging function, allows debugging to a file with timestamps.
-- Videos often cover up the built-in debugLog output.
-- so this is here to help in cases of weird video behavior.
local function debugLog(message)
    if enableDebug then
        debugPrint(message)

        if enableFileLogging then
            local timestamp = os.date("%Y-%m-%d %H:%M:%S")
            local step = curStep or 0
            local beat = curBeat or 0
            local songTimeMs = getSongPosition() or 0
            local minutes = math.floor(songTimeMs / 60000)
            local seconds = (songTimeMs % 60000) / 1000
            local timeFormatted = string.format("%d:%05.2f", minutes, seconds)
            debugLogBuffer =
                debugLogBuffer ..
                "[" ..
                    timestamp ..
                        "] [Step: " ..
                            step .. " Beat: " .. beat .. " Time: " .. timeFormatted .. "] " .. message .. "\n"
        end
    end
end

local function detectModFolder()
    if modFolder then
        return modFolder
    end

    local currentModDirectory = nil

    -- Check Psych Engine version so we can use the correct property.
    if stringStartsWith(version, "0.6") then
        currentModDirectory = getPropertyFromClass("Paths", "currentModDirectory")
    else
        currentModDirectory = getPropertyFromClass("backend.Mods", "currentModDirectory")
    end

    if currentModDirectory and currentModDirectory ~= "" then
        modFolder = currentModDirectory
        logFilePath = currentModDirectory .. "/data/debug_video_player_event.txt"
        debugLog("Auto-detected mod folder: " .. modFolder)
        return modFolder
    end

    -- Fallback: save to mods root
    debugLog("Could not auto-detect mod folder, using mods root")
    logFilePath = "debug_video_player_event.txt"
    return nil
end

local function saveDebugLog()
    if enableDebug and enableFileLogging and debugLogBuffer ~= "" then
        if not logFilePath then
            debugLog("ERROR: Could not determine log file path")
            return
        end

        local success = saveFile(logFilePath, debugLogBuffer)

        if success then
            debugLog("Debug log saved to: mods/" .. logFilePath)
        else
            debugLog("ERROR: Failed to save debug log to: mods/" .. logFilePath)
            debugLog("This may be a file permissions issue.")
        end
    end
end

-- #####################################################################
-- [[ Event Helper Functions ]]
-- #####################################################################

-- Compares two version strings numerically (e.g., "1.0.2" vs "1.0.1").
-- Returns: 1 if curVer > minVer, -1 if curVer < minVer, 0 if equal.
-- This is to determine which parameters to pass to startVideo based on version.
local function checkCompatibility(curVer, minVer)
    local curVerParts = {}
    local minVerParts = {}

    for num in string.gmatch(curVer, "%d+") do
        table.insert(curVerParts, tonumber(num))
    end

    for num in string.gmatch(minVer, "%d+") do
        table.insert(minVerParts, tonumber(num))
    end

    for i = 1, math.max(#curVerParts, #minVerParts) do
        local curPart = curVerParts[i] or 0
        local minPart = minVerParts[i] or 0

        if curPart > minPart then
            return 1
        elseif curPart < minPart then
            return -1
        end
    end

    return 0
end

local function psychVersion(minVersion)
    return checkCompatibility(version, minVersion) >= 0
end

local function playLoadedVideo()
    if psychVersion("1.0.2") then
        local video = getProperty("videoCutscene")
        if video ~= nil then
            callMethod("videoCutscene.play")
            return true
        else
            debugLog("No video loaded to play!")
            return false
        end
    else
        debugLog("Play command requires Psych Engine 1.0.2 or higher")
        return false
    end
end

local function pauseLoadedVideo()
    if psychVersion("1.0.2") then
        local video = getProperty("videoCutscene")
        if video ~= nil then
            callMethod("videoCutscene.pause")
            return true
        else
            debugLog("No video loaded to pause!")
            return false
        end
    else
        debugLog("Pause command requires Psych Engine 1.0.2 or higher")
        return false
    end
end

local function resumeLoadedVideo()
    if psychVersion("1.0.2") then
        local video = getProperty("videoCutscene")
        if video ~= nil then
            callMethod("videoCutscene.resume")
            return true
        else
            debugLog("No video loaded to resume!")
            return false
        end
    else
        debugLog("Resume command requires Psych Engine 1.0.2 or higher")
        return false
    end
end

local function setVideoCamera(camera)
    if psychVersion("1.0.2") then
        local video = getProperty("videoCutscene")
        if video ~= nil then
            setObjectCamera("videoCutscene", camera)
            debugLog("Video camera set to: " .. camera)
            return true
        else
            debugLog("No video loaded to set camera!")
            return false
        end
    else
        debugLog("Set Camera command requires Psych Engine 1.0.2 or higher")
        return false
    end
end

local function setVideoLayer(layer)
    if psychVersion("1.0.2") then
        local video = getProperty("videoCutscene")
        if video ~= nil then
            setObjectOrder("videoCutscene", layer)
            debugLog("Video layer set to: " .. layer)
            return true
        else
            debugLog("No video loaded to set layer!")
            return false
        end
    else
        debugLog("Set Layer command requires Psych Engine 1.0.2 or higher")
        return false
    end
end

-- Parses the video setup from the input string
local function parseVideoConfig(value)
    if not value or value == "" then
        return nil, defaultCamera, defaultLayer
    end

    debugLog('Parsing value1: "' .. value .. '"')

    local params = {}
    for param in string.gmatch(value, "([^,]+)") do
        local trimmed = param:match("^%s*(.-)%s*$")
        table.insert(params, trimmed)
        debugLog('  Found param: "' .. trimmed .. '"')
    end

    local videoName = params[1]
    local camera = defaultCamera
    local layer = defaultLayer

    if params[2] ~= nil and params[2] ~= "" then camera = params[2] end
    if params[3] ~= nil and params[3] ~= "" then layer = tonumber(params[3]) end

    debugLog(
        "  Parsed: videoName=" ..
            tostring(videoName) .. ", camera=" .. tostring(camera) .. ", layer=" .. tostring(layer)
    )
    return videoName, camera, layer
end


-- Parses the video parameters from the input string
local function parsePlaybackSettings(value)
    if not value or value == "" then
        return defaultCanSkip, defaultForMidSong, defaultShouldLoop, defaultPlayOnLoad
    end

    local normalized = value:gsub(" ", ""):lower()
    debugLog('Parsing value2: "' .. value .. '" normalized to: "' .. normalized .. '"')

    if normalized == "true" then
        return true, defaultForMidSong, defaultShouldLoop, defaultPlayOnLoad
    elseif normalized == "false" then
        return false, defaultForMidSong, defaultShouldLoop, defaultPlayOnLoad
    end

    local params = {}
    for param in string.gmatch(normalized, "(%a+)") do
        table.insert(params, param == "true")
        debugLog('  Found param: "' .. param .. '" = ' .. tostring(param == "true"))
    end

    local canSkip = defaultCanSkip
    local forMidSong = defaultForMidSong
    local shouldLoop = defaultShouldLoop
    local playOnLoad = defaultPlayOnLoad

    if params[1] ~= nil then canSkip = params[1] end
    if params[2] ~= nil then forMidSong = params[2] end 
    if params[3] ~= nil then shouldLoop = params[3] end
    if params[4] ~= nil then playOnLoad = params[4] end

    debugLog(
        "  Parsed: canSkip=" ..
            tostring(canSkip) ..
                ", forMidSong=" ..
                    tostring(forMidSong) ..
                        ", shouldLoop=" .. tostring(shouldLoop) .. ", playOnLoad=" .. tostring(playOnLoad)
    )
    return canSkip, forMidSong, shouldLoop, playOnLoad
end

-- #####################################################################
-- [[ Bind our local functions to Psych Engine events ]]
-- #####################################################################

function onCreate()
    detectModFolder()
end

function onEvent(name, value1, value2)
    if name == "Video Player" or name == "Video_Player" then
        debugLog("Video Player Event Triggered:")
        debugLog("Psych Engine Version: " .. version)

        local videoName, camera, layer = parseVideoConfig(value1)
        local canSkip, forMidSong, shouldLoop, playOnLoad = parsePlaybackSettings(value2)

        debugLog("Video: " .. (videoName or "NONE"))
        if camera ~= defaultCamera then
            debugLog("Camera: " .. camera)
        end
        if layer ~= defaultLayer then
            debugLog("Layer: " .. tostring(layer))
        end
        debugLog("Can Skip: " .. tostring(canSkip) .. " | Mid-Song: " .. tostring(forMidSong))
        debugLog("Loop: " .. tostring(shouldLoop) .. " | Play On Load: " .. tostring(playOnLoad))

        if psychVersion("1.0.2") then
            startVideo(videoName, canSkip, forMidSong, shouldLoop, playOnLoad)
        elseif psychVersion("1.0") then
            startVideo(videoName, canSkip)
        else
            startVideo(videoName)
            setProperty('inCutscene', false)
        end

        setVideoCamera(camera)

        if layer ~= nil then
            setVideoLayer(layer)
        end

        saveDebugLog()

    elseif name == "Video Player Control" or name == "Video_Player_Control" then
        local command = (value1 or ""):gsub(" ", ""):lower()

        debugLog("Video Player Control Event Triggered:")
        debugLog("  Command: " .. command)
        if value2 and value2 ~= "" then
            debugLog("  Parameter: " .. value2)
        end

        if command == "play" then
            playLoadedVideo()
        elseif command == "pause" then
            pauseLoadedVideo()
        elseif command == "resume" then
            resumeLoadedVideo()
        elseif command == "setcamera" then
            local camera = value2 and value2:match("^%s*(.-)%s*$") or "camOther"
            setVideoCamera(camera)
        elseif command == "setlayer" then
            local layer = tonumber(value2) or 0
            setVideoLayer(layer)
        else
            debugLog("Unknown Video Player Control command: " .. command)
        end

        saveDebugLog()
    end
end

function onPause()
    if psychVersion("1.0.2") then
        pauseLoadedVideo()
    end
end

function onResume()
    if psychVersion("1.0.2") then
        resumeLoadedVideo()
    end
end

function onDestroy()
    saveDebugLog()
end
