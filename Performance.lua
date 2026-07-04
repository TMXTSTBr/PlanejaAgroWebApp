--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    PERFORMANCE HUB v2.0                      ║
    ║              Developed for Roblox (Luau) Executors           ║
    ║                  High Performance FPS Booster                ║
    ╚══════════════════════════════════════════════════════════════╝
    
    Módulos:
    [1] Serviços & Referências
    [2] Configurações & Estado
    [3] Cache do Sistema
    [4] Utilitários
    [5] Sistema FPS
    [6] Otimizações
    [7] Monitoramento
    [8] Interface (UI)
    [9] Auto Optimization
    [10] Inicialização
]]

-- ════════════════════════════════════════════════════════════════
-- [1] SERVIÇOS & REFERÊNCIAS
-- ════════════════════════════════════════════════════════════════

local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local Lighting         = game:GetService("Lighting")
local Workspace        = game:GetService("Workspace")
local Stats            = game:GetService("Stats")
local CollectionService= game:GetService("CollectionService")
local GuiService       = game:GetService("GuiService")

local LocalPlayer      = Players.LocalPlayer
local PlayerGui        = LocalPlayer:WaitForChild("PlayerGui")
local Camera           = Workspace.CurrentCamera
local Terrain          = Workspace.Terrain

-- ════════════════════════════════════════════════════════════════
-- [2] CONFIGURAÇÕES & ESTADO GLOBAL
-- ════════════════════════════════════════════════════════════════

local VERSION          = "2.0.0"
local SCRIPT_START     = os.clock()
local UPDATE_INTERVAL  = 0.5   -- Intervalo de atualização das stats (segundos)
local SCAN_INTERVAL    = 3.0   -- Intervalo de scan do Workspace (segundos)
local AUTO_OPT_INTERVAL= 5.0   -- Intervalo do sistema automático

-- Estado das configurações (persistente durante a sessão)
local State = {
    -- FPS
    FpsCap          = 60,
    UnlimitedFps    = false,
    
    -- Render Distance
    RenderDistance  = 500,
    
    -- Features ativas
    Features        = {},
    
    -- Modo atual
    CurrentMode     = "None",
    
    -- Estatísticas em tempo real
    Stats = {
        FPS          = 0,
        RAM          = 0,
        Ping         = 0,
        CPU          = 0,
        Objects      = 0,
        Parts        = 0,
        MeshParts    = 0,
        Decals       = 0,
        Textures     = 0,
        Particles    = 0,
        Lights       = 0,
        RenderTime   = 0,
    },
    
    -- Contadores
    OptimizationsApplied = 0,
    Uptime               = 0,
    
    -- UI State
    UIVisible        = true,
    UIMinimized      = false,
    CurrentCategory  = "Performance",
}

-- Temas de cor
local Theme = {
    Background      = Color3.fromRGB(12,  12,  16 ),
    BackgroundAlt   = Color3.fromRGB(18,  18,  25 ),
    Panel           = Color3.fromRGB(22,  22,  32 ),
    PanelAlt        = Color3.fromRGB(28,  28,  40 ),
    Border          = Color3.fromRGB(50,  50,  80 ),
    Accent          = Color3.fromRGB(130, 60,  255),
    AccentDark      = Color3.fromRGB(90,  30,  200),
    AccentBlue      = Color3.fromRGB(0,   150, 255),
    AccentNeon      = Color3.fromRGB(180, 80,  255),
    Text            = Color3.fromRGB(240, 240, 255),
    TextDim         = Color3.fromRGB(160, 160, 200),
    TextMuted       = Color3.fromRGB(100, 100, 140),
    Success         = Color3.fromRGB(50,  220, 120),
    Warning         = Color3.fromRGB(255, 180, 50 ),
    Danger          = Color3.fromRGB(255, 70,  70 ),
    Glow            = Color3.fromRGB(150, 80,  255),
    White           = Color3.fromRGB(255, 255, 255),
    Black           = Color3.fromRGB(0,   0,   0  ),
}

-- ════════════════════════════════════════════════════════════════
-- [3] CACHE DO SISTEMA
-- ════════════════════════════════════════════════════════════════

local Cache = {
    -- Cache de objetos do Workspace
    Parts           = {},
    MeshParts       = {},
    Decals          = {},
    Textures        = {},
    Particles       = {},
    Lights          = {},
    Trails          = {},
    Beams           = {},
    Smokes          = {},
    Fires           = {},
    Explosions      = {},
    Sparkles        = {},
    Highlights      = {},
    Accessories     = {},
    Animations      = {},
    
    -- Cache de conexões (para desconectar depois)
    Connections     = {},
    
    -- Timestamp da última atualização
    LastScan        = 0,
    LastStatsUpdate = 0,
    
    -- Cache de objetos UI
    UI              = {},
    
    -- Cache de configurações originais
    OriginalLighting = {},
    OriginalSky     = nil,
    OriginalAtmosphere = nil,
    OriginalTerrain = {},
}

-- Salva configurações originais do Lighting
local function CacheLightingOriginals()
    Cache.OriginalLighting = {
        GlobalShadows     = Lighting.GlobalShadows,
        FogEnd            = Lighting.FogEnd,
        FogStart          = Lighting.FogStart,
        FogColor          = Lighting.FogColor,
        Brightness        = Lighting.Brightness,
        ClockTime         = Lighting.ClockTime,
        Ambient           = Lighting.Ambient,
        OutdoorAmbient    = Lighting.OutdoorAmbient,
        ShadowSoftness    = Lighting.ShadowSoftness,
        EnvironmentDiffuseScale  = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    }
    -- Sky
    local sky = Lighting:FindFirstChildWhichIsA("Sky")
    if sky then
        Cache.OriginalSky = sky
    end
    -- Atmosphere
    local atm = Lighting:FindFirstChildWhichIsA("Atmosphere")
    if atm then
        Cache.OriginalAtmosphere = {
            Density   = atm.Density,
            Offset    = atm.Offset,
            Color     = atm.Color,
            Decay     = atm.Decay,
            Glare     = atm.Glare,
            Haze      = atm.Haze,
        }
    end
    -- Terrain
    Cache.OriginalTerrain = {
        WaterWaveSize   = Terrain.WaterWaveSize,
        WaterWaveSpeed  = Terrain.WaterWaveSpeed,
        WaterReflectance= Terrain.WaterReflectance,
        WaterTransparency = Terrain.WaterTransparency,
        Decoration      = Terrain.Decoration,
    }
end

-- ════════════════════════════════════════════════════════════════
-- [4] UTILITÁRIOS
-- ════════════════════════════════════════════════════════════════

-- Cria uma Tween segura
local function SafeTween(obj, info, props)
    if not obj or not obj.Parent then return end
    local ok, tween = pcall(function()
        return TweenService:Create(obj, info, props)
    end)
    if ok and tween then
        tween:Play()
        return tween
    end
end

-- TweenInfo pré-configurados
local TI = {
    Fast     = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Medium   = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Slow     = TweenInfo.new(0.4,  Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Elastic  = TweenInfo.new(0.4,  Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
    Bounce   = TweenInfo.new(0.5,  Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    Spring   = TweenInfo.new(0.35, Enum.EasingStyle.Back,   Enum.EasingDirection.Out),
}

-- Executa função com proteção de erro
local function SafeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        -- Silencia erros para não poluir o console
    end
    return ok
end

-- Verifica se propriedade existe no objeto
local function HasProperty(obj, prop)
    local ok = pcall(function() return obj[prop] end)
    return ok
end

-- Arredonda número
local function Round(n, decimals)
    local factor = 10 ^ (decimals or 0)
    return math.floor(n * factor + 0.5) / factor
end

-- Formata bytes para string legível
local function FormatBytes(bytes)
    if bytes < 1024 then
        return string.format("%.0f B", bytes)
    elseif bytes < 1024 * 1024 then
        return string.format("%.1f KB", bytes / 1024)
    else
        return string.format("%.1f MB", bytes / (1024 * 1024))
    end
end

-- Cria conexão gerenciada (auto-registrada no Cache)
local function Connect(signal, fn)
    local conn = signal:Connect(fn)
    table.insert(Cache.Connections, conn)
    return conn
end

-- Desconecta todas as conexões gerenciadas
local function DisconnectAll()
    for _, conn in ipairs(Cache.Connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    Cache.Connections = {}
end

-- Conta objetos por tipo no Workspace (cached)
local function ScanWorkspace()
    -- Limpa cache anterior
    Cache.Parts      = {}
    Cache.MeshParts  = {}
    Cache.Decals     = {}
    Cache.Textures   = {}
    Cache.Particles  = {}
    Cache.Lights     = {}
    Cache.Trails     = {}
    Cache.Beams      = {}
    Cache.Smokes     = {}
    Cache.Fires      = {}
    Cache.Explosions = {}
    Cache.Sparkles   = {}
    Cache.Highlights = {}

    -- Uma única passagem pelo Workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local className = obj.ClassName
        if className == "Part" or className == "UnionOperation" or className == "SpecialMesh" then
            table.insert(Cache.Parts, obj)
        elseif className == "MeshPart" then
            table.insert(Cache.MeshParts, obj)
            table.insert(Cache.Parts, obj)
        elseif className == "Decal" then
            table.insert(Cache.Decals, obj)
        elseif className == "Texture" then
            table.insert(Cache.Textures, obj)
        elseif className == "ParticleEmitter" then
            table.insert(Cache.Particles, obj)
        elseif className == "PointLight" or className == "SpotLight" or className == "SurfaceLight" then
            table.insert(Cache.Lights, obj)
        elseif className == "Trail" then
            table.insert(Cache.Trails, obj)
        elseif className == "Beam" then
            table.insert(Cache.Beams, obj)
        elseif className == "Smoke" then
            table.insert(Cache.Smokes, obj)
        elseif className == "Fire" then
            table.insert(Cache.Fires, obj)
        elseif className == "Explosion" then
            table.insert(Cache.Explosions, obj)
        elseif className == "SelectionBox" or className == "Highlight" then
            table.insert(Cache.Highlights, obj)
        elseif className == "Sparkles" then
            table.insert(Cache.Sparkles, obj)
        end
    end

    Cache.LastScan = os.clock()
end

-- ════════════════════════════════════════════════════════════════
-- [5] SISTEMA FPS
-- ════════════════════════════════════════════════════════════════

-- Aplica FPS Cap usando métodos disponíveis
local function UpdateFPS(value)
    State.FpsCap = value
    
    -- Método 1: setfpscap (disponível em alguns executores)
    if setfpscap then
        SafeCall(setfpscap, value)
        return
    end
    
    -- Método 2: setframerate
    if setframerate then
        SafeCall(setframerate, value)
        return
    end
    
    -- Método 3: via UserSettings
    SafeCall(function()
        if game.UserSettings and game.UserSettings.GameSettings then
            local gs = game.UserSettings.GameSettings
            if gs:FindFirstChild("FramerateCap") then
                gs.FramerateCap = value
            end
        end
    end)
end

-- Modo Unlimited FPS
local function SetUnlimitedFPS(enabled)
    State.UnlimitedFps = enabled
    if enabled then
        UpdateFPS(9999)
    else
        UpdateFPS(State.FpsCap)
    end
end

-- ════════════════════════════════════════════════════════════════
-- [6] SISTEMA DE OTIMIZAÇÃO - FUNÇÕES INDIVIDUAIS
-- ════════════════════════════════════════════════════════════════

-- Desabilita/habilita objetos por lista do cache
local function ToggleCachedObjects(list, disable, propName, propValue, propValueOn)
    for _, obj in ipairs(list) do
        if obj and obj.Parent then
            SafeCall(function()
                if disable then
                    obj[propName] = propValue
                else
                    obj[propName] = propValueOn
                end
            end)
        end
    end
end

-- ── Sombras ──────────────────────────────────────────────────────
local function OptimizeShadows(disable)
    SafeCall(function()
        Lighting.GlobalShadows  = not disable
        Lighting.ShadowSoftness = disable and 0 or (Cache.OriginalLighting.ShadowSoftness or 0.5)
    end)
    State.Features["DisableShadows"] = disable
    State.OptimizationsApplied = State.OptimizationsApplied + (disable and 1 or 0)
end

-- ── Partículas ────────────────────────────────────────────────────
local function OptimizeParticles(disable)
    for _, p in ipairs(Cache.Particles) do
        if p and p.Parent then
            SafeCall(function()
                p.Enabled = not disable
                if disable then p.Rate = 0 end
            end)
        end
    end
    State.Features["DisableParticles"] = disable
end

-- ── Trails ────────────────────────────────────────────────────────
local function OptimizeTrails(disable)
    ToggleCachedObjects(Cache.Trails, disable, "Enabled", false, true)
    State.Features["DisableTrails"] = disable
end

-- ── Smoke ─────────────────────────────────────────────────────────
local function OptimizeSmoke(disable)
    ToggleCachedObjects(Cache.Smokes, disable, "Enabled", false, true)
    State.Features["DisableSmoke"] = disable
end

-- ── Fire ──────────────────────────────────────────────────────────
local function OptimizeFire(disable)
    ToggleCachedObjects(Cache.Fires, disable, "Enabled", false, true)
    State.Features["DisableFire"] = disable
end

-- ── Sparkles ──────────────────────────────────────────────────────
local function OptimizeSparkles(disable)
    ToggleCachedObjects(Cache.Sparkles, disable, "Enabled", false, true)
    State.Features["DisableSparkles"] = disable
end

-- ── Beams ─────────────────────────────────────────────────────────
local function OptimizeBeams(disable)
    ToggleCachedObjects(Cache.Beams, disable, "Enabled", false, true)
    State.Features["DisableBeams"] = disable
end

-- ── Decals ────────────────────────────────────────────────────────
local function OptimizeDecals(disable)
    ToggleCachedObjects(Cache.Decals, disable, "Transparency", 1, 0)
    State.Features["DisableDecals"] = disable
end

-- ── Textures ──────────────────────────────────────────────────────
local function OptimizeTextures(disable)
    ToggleCachedObjects(Cache.Textures, disable, "Transparency", 1, 0)
    State.Features["DisableTextures"] = disable
end

-- ── Lights ────────────────────────────────────────────────────────
local function OptimizeLights(disable)
    ToggleCachedObjects(Cache.Lights, disable, "Enabled", false, true)
    State.Features["DisableLights"] = disable
end

-- ── PointLights ───────────────────────────────────────────────────
local function OptimizePointLights(disable)
    for _, l in ipairs(Cache.Lights) do
        if l and l.ClassName == "PointLight" and l.Parent then
            SafeCall(function() l.Enabled = not disable end)
        end
    end
    State.Features["DisablePointLights"] = disable
end

-- ── SpotLights ────────────────────────────────────────────────────
local function OptimizeSpotLights(disable)
    for _, l in ipairs(Cache.Lights) do
        if l and l.ClassName == "SpotLight" and l.Parent then
            SafeCall(function() l.Enabled = not disable end)
        end
    end
    State.Features["DisableSpotLights"] = disable
end

-- ── SurfaceLights ─────────────────────────────────────────────────
local function OptimizeSurfaceLights(disable)
    for _, l in ipairs(Cache.Lights) do
        if l and l.ClassName == "SurfaceLight" and l.Parent then
            SafeCall(function() l.Enabled = not disable end)
        end
    end
    State.Features["DisableSurfaceLights"] = disable
end

-- ── Highlights ────────────────────────────────────────────────────
local function OptimizeHighlights(disable)
    ToggleCachedObjects(Cache.Highlights, disable, "Enabled", false, true)
    State.Features["DisableHighlights"] = disable
end

-- ── SurfaceAppearance ─────────────────────────────────────────────
local function OptimizeSurfaceAppearance(disable)
    SafeCall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.ClassName == "SurfaceAppearance" then
                obj.Parent = disable and nil or obj.Parent
            end
        end
    end)
    State.Features["DisableSurfaceAppearance"] = disable
end

-- ── Grass ─────────────────────────────────────────────────────────
local function OptimizeGrass(disable)
    SafeCall(function()
        Terrain.Decoration = not disable
    end)
    State.Features["DisableGrass"] = disable
end

-- ── Water Effects ─────────────────────────────────────────────────
local function OptimizeWater(disable)
    SafeCall(function()
        if disable then
            Terrain.WaterWaveSize      = 0
            Terrain.WaterWaveSpeed     = 0
            Terrain.WaterReflectance   = 0
            Terrain.WaterTransparency  = 0
        else
            Terrain.WaterWaveSize      = Cache.OriginalTerrain.WaterWaveSize or 1
            Terrain.WaterWaveSpeed     = Cache.OriginalTerrain.WaterWaveSpeed or 10
            Terrain.WaterReflectance   = Cache.OriginalTerrain.WaterReflectance or 0.5
            Terrain.WaterTransparency  = Cache.OriginalTerrain.WaterTransparency or 0.3
        end
    end)
    State.Features["DisableWater"] = disable
end

-- ── Clouds ────────────────────────────────────────────────────────
local function OptimizeClouds(disable)
    SafeCall(function()
        local clouds = Terrain:FindFirstChildWhichIsA("Clouds")
        if clouds then
            clouds.Enabled = not disable
        end
    end)
    State.Features["DisableClouds"] = disable
end

-- ── Atmosphere ────────────────────────────────────────────────────
local function OptimizeAtmosphere(disable)
    SafeCall(function()
        local atm = Lighting:FindFirstChildWhichIsA("Atmosphere")
        if atm then
            if disable then
                atm.Density = 0
                atm.Haze    = 0
                atm.Glare   = 0
            else
                if Cache.OriginalAtmosphere then
                    atm.Density = Cache.OriginalAtmosphere.Density
                    atm.Haze    = Cache.OriginalAtmosphere.Haze
                    atm.Glare   = Cache.OriginalAtmosphere.Glare
                end
            end
        end
    end)
    State.Features["DisableAtmosphere"] = disable
end

-- ── Fog ───────────────────────────────────────────────────────────
local function OptimizeFog(disable)
    SafeCall(function()
        if disable then
            Lighting.FogEnd   = 100000
            Lighting.FogStart = 99999
        else
            Lighting.FogEnd   = Cache.OriginalLighting.FogEnd   or 100000
            Lighting.FogStart = Cache.OriginalLighting.FogStart or 0
        end
    end)
    State.Features["DisableFog"] = disable
end

-- ── Sun Rays ──────────────────────────────────────────────────────
local function OptimizeSunRays(disable)
    SafeCall(function()
        local sunRays = Lighting:FindFirstChildWhichIsA("SunRaysEffect")
        if sunRays then
            sunRays.Intensity = disable and 0 or 0.25
        end
    end)
    State.Features["DisableSunRays"] = disable
end

-- ── Bloom ─────────────────────────────────────────────────────────
local function OptimizeBloom(disable)
    SafeCall(function()
        local bloom = Lighting:FindFirstChildWhichIsA("BloomEffect")
        if bloom then
            bloom.Intensity = disable and 0 or 1
            bloom.Size      = disable and 0 or 24
        end
    end)
    State.Features["DisableBloom"] = disable
end

-- ── Blur ──────────────────────────────────────────────────────────
local function OptimizeBlur(disable)
    SafeCall(function()
        local blur = Lighting:FindFirstChildWhichIsA("BlurEffect")
        if blur then
            blur.Size = disable and 0 or 24
        end
    end)
    State.Features["DisableBlur"] = disable
end

-- ── Color Correction ──────────────────────────────────────────────
local function OptimizeColorCorrection(disable)
    SafeCall(function()
        local cc = Lighting:FindFirstChildWhichIsA("ColorCorrectionEffect")
        if cc then
            cc.Enabled = not disable
        end
    end)
    State.Features["DisableColorCorrection"] = disable
end

-- ── Depth of Field ────────────────────────────────────────────────
local function OptimizeDepthOfField(disable)
    SafeCall(function()
        local dof = Lighting:FindFirstChildWhichIsA("DepthOfFieldEffect")
        if dof then
            dof.Enabled = not disable
        end
    end)
    State.Features["DisableDepthOfField"] = disable
end

-- ── Sky ───────────────────────────────────────────────────────────
local function OptimizeSky(disable)
    SafeCall(function()
        local sky = Lighting:FindFirstChildWhichIsA("Sky")
        if sky then
            sky.Parent = disable and game:GetService("ReplicatedStorage") or Lighting
        end
    end)
    State.Features["DisableSky"] = disable
end

-- ── Lighting Geral ────────────────────────────────────────────────
local function OptimizeLighting(mode)
    SafeCall(function()
        if mode == "low" then
            Lighting.GlobalShadows           = false
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale= 0
            Lighting.ShadowSoftness          = 0
        elseif mode == "medium" then
            Lighting.GlobalShadows           = true
            Lighting.EnvironmentDiffuseScale = 0.5
            Lighting.EnvironmentSpecularScale= 0.5
            Lighting.ShadowSoftness          = 0.2
        elseif mode == "restore" then
            Lighting.GlobalShadows           = Cache.OriginalLighting.GlobalShadows
            Lighting.EnvironmentDiffuseScale = Cache.OriginalLighting.EnvironmentDiffuseScale  or 1
            Lighting.EnvironmentSpecularScale= Cache.OriginalLighting.EnvironmentSpecularScale or 1
            Lighting.ShadowSoftness          = Cache.OriginalLighting.ShadowSoftness or 0.5
        end
    end)
end

-- ── Renderização ──────────────────────────────────────────────────
local function OptimizeRendering(level)
    SafeCall(function()
        if level == "low" then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        elseif level == "medium" then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level05
        elseif level == "high" then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level10
        elseif level == "auto" then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end)
end

-- ── View Distance (MaxDistance) ───────────────────────────────────
local function SetRenderDistance(value)
    State.RenderDistance = value
    SafeCall(function()
        -- Workspace StreamingEnabled
        if value <= 200 then
            Workspace.StreamingMinRadius = math.min(value, 64)
            Workspace.StreamingTargetRadius = value
        end
    end)
    -- Limita distância de câmera
    SafeCall(function()
        Camera.MaxAxisFieldOfView = value > 1000 and 120 or 90
    end)
    State.Features["RenderDistance"] = value
end

-- ── Physics ────────────────────────────────────────────────────────
local function OptimizePhysics(disable)
    SafeCall(function()
        if disable then
            Workspace.PhysicsSimulationRate = Enum.PhysicsSimulationRate.Fixed60Hz
        else
            Workspace.PhysicsSimulationRate = Enum.PhysicsSimulationRate.Fixed240Hz
        end
    end)
    State.Features["OptimizePhysics"] = disable
end

-- ── Personagens ───────────────────────────────────────────────────
local function OptimizeCharacters(disable)
    SafeCall(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                -- Desabilita efeitos em personagens de outros jogadores
                for _, desc in ipairs(char:GetDescendants()) do
                    if desc:IsA("ParticleEmitter") or desc:IsA("Trail") or
                       desc:IsA("Smoke") or desc:IsA("Fire") or desc:IsA("Sparkles") then
                        SafeCall(function()
                            desc.Enabled = not disable
                        end)
                    end
                end
            end
        end
    end)
    State.Features["OptimizeCharacters"] = disable
end

-- ── Memory / Garbage Collection ────────────────────────────────────
local function OptimizeMemory()
    -- Coleta de lixo Lua
    SafeCall(function()
        collectgarbage("collect")
        collectgarbage("step", 100)
    end)
    State.OptimizationsApplied = State.OptimizationsApplied + 1
end

-- ── GUI Optimization ──────────────────────────────────────────────
local function OptimizeGUI(disable)
    SafeCall(function()
        -- Desabilita blur de GUI para ganho de performance
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "PerformanceHubUI" then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("BlurEffect") or desc:IsA("DepthOfFieldEffect") then
                        desc.Enabled = not disable
                    end
                end
            end
        end
    end)
    State.Features["OptimizeGUI"] = disable
end

-- ── Audio ──────────────────────────────────────────────────────────
local function OptimizeAudio(disable)
    SafeCall(function()
        local SoundService = game:GetService("SoundService")
        if disable then
            SoundService.AmbientReverb = Enum.ReverbType.NoReverb
            SoundService.DistanceFactor = 10
        end
    end)
    State.Features["OptimizeAudio"] = disable
end

-- ── Network / Streaming ───────────────────────────────────────────
local function OptimizeNetwork(enable)
    SafeCall(function()
        -- Streaming inteligente (se disponível)
        if Workspace.StreamingEnabled then
            if enable then
                Workspace.StreamingMinRadius    = 64
                Workspace.StreamingTargetRadius = 512
            end
        end
    end)
    State.Features["OptimizeNetwork"] = enable
end

-- ── Materiais Neon ────────────────────────────────────────────────
local function OptimizeNeonMaterials(disable)
    SafeCall(function()
        for _, p in ipairs(Cache.Parts) do
            if p and p.Parent and p:IsA("BasePart") then
                if p.Material == Enum.Material.Neon then
                    p.Material = disable and Enum.Material.SmoothPlastic or Enum.Material.Neon
                end
            end
        end
    end)
    State.Features["DisableNeonMaterials"] = disable
end

-- ── Glass Transparency ────────────────────────────────────────────
local function OptimizeGlass(disable)
    SafeCall(function()
        for _, p in ipairs(Cache.Parts) do
            if p and p.Parent and p:IsA("BasePart") then
                if p.Material == Enum.Material.Glass then
                    if disable then
                        p.Material    = Enum.Material.SmoothPlastic
                        p.Transparency = math.max(p.Transparency, 0)
                    end
                end
            end
        end
    end)
    State.Features["DisableGlass"] = disable
end

-- ════════════════════════════════════════════════════════════════
-- [7] PRESETS DE OTIMIZAÇÃO
-- ════════════════════════════════════════════════════════════════

-- Tabela de presets
local Presets = {
    ["Light"] = {
        description = "Otimizações leves. Melhora leve no FPS.",
        apply = function()
            OptimizeShadows(false)
            OptimizeBloom(true)
            OptimizeSunRays(true)
            OptimizeFog(true)
            OptimizeRendering("auto")
        end
    },
    ["Medium"] = {
        description = "Otimizações médias. Bom equilíbrio.",
        apply = function()
            OptimizeShadows(true)
            OptimizeBloom(true)
            OptimizeSunRays(true)
            OptimizeFog(true)
            OptimizeAtmosphere(true)
            OptimizeParticles(false)
            OptimizeRendering("medium")
            UpdateFPS(60)
        end
    },
    ["High"] = {
        description = "Otimizações altas. Ganho notável de FPS.",
        apply = function()
            OptimizeShadows(true)
            OptimizeBloom(true)
            OptimizeSunRays(true)
            OptimizeFog(true)
            OptimizeAtmosphere(true)
            OptimizeClouds(true)
            OptimizeParticles(true)
            OptimizeTrails(true)
            OptimizeSmoke(true)
            OptimizeFire(true)
            OptimizeDecals(true)
            OptimizeLighting("low")
            OptimizeRendering("low")
            OptimizeWater(true)
            UpdateFPS(60)
        end
    },
    ["Extreme"] = {
        description = "Otimizações extremas. Máximo FPS.",
        apply = function()
            OptimizeShadows(true)
            OptimizeBloom(true)
            OptimizeSunRays(true)
            OptimizeFog(true)
            OptimizeAtmosphere(true)
            OptimizeClouds(true)
            OptimizeParticles(true)
            OptimizeTrails(true)
            OptimizeSmoke(true)
            OptimizeFire(true)
            OptimizeSparkles(true)
            OptimizeBeams(true)
            OptimizeDecals(true)
            OptimizeTextures(true)
            OptimizeLights(true)
            OptimizeLighting("low")
            OptimizeRendering("low")
            OptimizeWater(true)
            OptimizeGrass(true)
            OptimizeSky(true)
            OptimizeNeonMaterials(true)
            OptimizeGlass(true)
            OptimizePhysics(true)
            OptimizeGUI(true)
            SetRenderDistance(200)
            UpdateFPS(9999)
        end
    },
    ["Gamer"] = {
        description = "Modo Gamer. Alta performance com visual aceitável.",
        apply = function()
            OptimizeShadows(true)
            OptimizeBloom(true)
            OptimizeSunRays(true)
            OptimizeFog(true)
            OptimizeAtmosphere(false)
            OptimizeClouds(true)
            OptimizeParticles(true)
            OptimizeTrails(true)
            OptimizeLighting("medium")
            OptimizeRendering("medium")
            OptimizeWater(true)
            OptimizeGrass(false)
            UpdateFPS(144)
        end
    },
    ["Ultra Performance"] = {
        description = "Ultra Performance. Absolutamente tudo otimizado.",
        apply = function()
            -- Aplica tudo do Extreme
            Presets["Extreme"].apply()
            -- Mais agressivo
            OptimizeAudio(true)
            OptimizeGUI(true)
            OptimizeCharacters(true)
            OptimizeNetwork(true)
            OptimizePhysics(true)
            OptimizeMemory()
            OptimizeDepthOfField(true)
            OptimizeColorCorrection(true)
            OptimizeBlur(true)
            OptimizeHighlights(true)
            OptimizeNeonMaterials(true)
            OptimizeGlass(true)
            SetRenderDistance(100)
            UpdateFPS(9999)
        end
    },
    ["Intelligent"] = {
        description = "Modo Inteligente. Detecta e aplica melhor configuração.",
        apply = function()
            local fps = State.Stats.FPS
            if fps < 20 then
                Presets["Ultra Performance"].apply()
            elseif fps < 35 then
                Presets["Extreme"].apply()
            elseif fps < 50 then
                Presets["High"].apply()
            elseif fps < 55 then
                Presets["Medium"].apply()
            else
                Presets["Light"].apply()
            end
        end
    },
    ["Automatic"] = {
        description = "Modo Automático. Ajusta continuamente.",
        apply = function()
            -- Será gerenciado pelo loop de Auto Optimization
            State.Features["AutoMode"] = true
        end
    },
}

-- Aplicar preset por nome
local function ApplyPreset(name)
    local preset = Presets[name]
    if preset then
        State.CurrentMode = name
        ScanWorkspace() -- Atualiza cache antes de aplicar
        SafeCall(preset.apply)
        State.OptimizationsApplied = State.OptimizationsApplied + 1
        return true
    end
    return false
end

-- Restaurar padrões
local function RestoreDefaults()
    SafeCall(function()
        -- Lighting
        Lighting.GlobalShadows           = Cache.OriginalLighting.GlobalShadows
        Lighting.FogEnd                  = Cache.OriginalLighting.FogEnd
        Lighting.FogStart                = Cache.OriginalLighting.FogStart
        Lighting.Brightness              = Cache.OriginalLighting.Brightness
        Lighting.ShadowSoftness          = Cache.OriginalLighting.ShadowSoftness or 0.5
        Lighting.EnvironmentDiffuseScale = Cache.OriginalLighting.EnvironmentDiffuseScale  or 1
        Lighting.EnvironmentSpecularScale= Cache.OriginalLighting.EnvironmentSpecularScale or 1

        -- Terrain
        Terrain.WaterWaveSize    = Cache.OriginalTerrain.WaterWaveSize or 1
        Terrain.WaterWaveSpeed   = Cache.OriginalTerrain.WaterWaveSpeed or 10
        Terrain.WaterReflectance = Cache.OriginalTerrain.WaterReflectance or 0.5
        Terrain.Decoration       = Cache.OriginalTerrain.Decoration ~= false

        -- Partículas
        OptimizeParticles(false)
        OptimizeTrails(false)
        OptimizeSmoke(false)
        OptimizeFire(false)
        OptimizeSparkles(false)
        OptimizeBeams(false)
        OptimizeLights(false)

        -- Sky
        if Cache.OriginalSky then
            Cache.OriginalSky.Parent = Lighting
        end
        
        -- Rendering
        OptimizeRendering("auto")
        
        State.CurrentMode = "None"
        State.Features = {}
        State.OptimizationsApplied = 0
    end)
end

-- ════════════════════════════════════════════════════════════════
-- [8] SISTEMA DE MONITORAMENTO (Stats)
-- ════════════════════════════════════════════════════════════════

-- FPS counter via RenderStepped
local fpsTable   = {}
local fpsSize    = 30
local fpsCurrent = 0
local lastFpsTime= os.clock()

Connect(RunService.RenderStepped, function(dt)
    -- FPS
    local now = os.clock()
    local elapsed = now - lastFpsTime
    lastFpsTime = now

    if elapsed > 0 then
        local fps = 1 / elapsed
        table.insert(fpsTable, fps)
        if #fpsTable > fpsSize then
            table.remove(fpsTable, 1)
        end
        -- Média dos últimos frames
        local sum = 0
        for _, v in ipairs(fpsTable) do sum = sum + v end
        fpsCurrent = Round(sum / #fpsTable, 0)
    end
    State.Stats.FPS = fpsCurrent
end)

-- Atualiza estatísticas gerais (não usa RenderStepped para evitar overhead)
local function UpdateStats()
    -- RAM
    SafeCall(function()
        State.Stats.RAM = math.floor(Stats:GetTotalMemoryUsageMb())
    end)
    
    -- Ping
    SafeCall(function()
        State.Stats.Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    
    -- CPU (aproximado via Heartbeat)
    SafeCall(function()
        local hbStats = Stats:FindFirstChild("Heartbeat")
        if hbStats then
            State.Stats.CPU = Round(hbStats:GetValue() * 100, 1)
        end
    end)
    
    -- Contagens de objetos (do cache)
    State.Stats.Objects    = #Workspace:GetChildren()
    State.Stats.Parts      = #Cache.Parts
    State.Stats.MeshParts  = #Cache.MeshParts
    State.Stats.Decals     = #Cache.Decals
    State.Stats.Textures   = #Cache.Textures
    State.Stats.Particles  = #Cache.Particles
    State.Stats.Lights     = #Cache.Lights
    
    -- Render Time
    SafeCall(function()
        State.Stats.RenderTime = Round(Stats["Render"]["Total/Frame"]:GetValue(), 2)
    end)
    
    -- Uptime
    State.Uptime = Round(os.clock() - SCRIPT_START, 0)
end

-- ════════════════════════════════════════════════════════════════
-- [9] AUTO OPTIMIZATION SYSTEM
-- ════════════════════════════════════════════════════════════════

local AutoOptEnabled   = false
local lastAutoOpt      = 0

local function RunAutoOptimization()
    local now = os.clock()
    if now - lastAutoOpt < AUTO_OPT_INTERVAL then return end
    lastAutoOpt = now

    local fps  = State.Stats.FPS
    local ram  = State.Stats.RAM
    local ping = State.Stats.Ping

    -- FPS crítico
    if fps > 0 and fps < 20 then
        ApplyPreset("Ultra Performance")
        OptimizeMemory()
        return
    end

    -- FPS baixo
    if fps > 0 and fps < 35 then
        OptimizeParticles(true)
        OptimizeShadows(true)
        OptimizeBloom(true)
        OptimizeLighting("low")
        return
    end

    -- RAM alta (> 800MB)
    if ram > 800 then
        OptimizeMemory()
        OptimizeTextures(true)
        OptimizeDecals(true)
        return
    end

    -- Ping alto (> 300ms)
    if ping > 300 then
        OptimizeNetwork(true)
        return
    end
end

-- Detecção inteligente de novos efeitos
local function WatchWorkspaceForNewEffects()
    Connect(Workspace.DescendantAdded, function(obj)
        if not obj or not obj.Parent then return end
        local className = obj.ClassName
        
        -- Adiciona ao cache automaticamente
        if className == "ParticleEmitter" then
            table.insert(Cache.Particles, obj)
            if State.Features["DisableParticles"] then
                SafeCall(function()
                    obj.Enabled = false
                    obj.Rate = 0
                end)
            end
        elseif className == "Trail" then
            table.insert(Cache.Trails, obj)
            if State.Features["DisableTrails"] then
                SafeCall(function() obj.Enabled = false end)
            end
        elseif className == "Smoke" then
            table.insert(Cache.Smokes, obj)
            if State.Features["DisableSmoke"] then
                SafeCall(function() obj.Enabled = false end)
            end
        elseif className == "Fire" then
            table.insert(Cache.Fires, obj)
            if State.Features["DisableFire"] then
                SafeCall(function() obj.Enabled = false end)
            end
        elseif className == "Sparkles" then
            table.insert(Cache.Sparkles, obj)
            if State.Features["DisableSparkles"] then
                SafeCall(function() obj.Enabled = false end)
            end
        elseif className == "Beam" then
            table.insert(Cache.Beams, obj)
            if State.Features["DisableBeams"] then
                SafeCall(function() obj.Enabled = false end)
            end
        elseif className == "PointLight" or className == "SpotLight" or className == "SurfaceLight" then
            table.insert(Cache.Lights, obj)
            if State.Features["DisableLights"] then
                SafeCall(function() obj.Enabled = false end)
            end
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- [10] INTERFACE (UI) - PERFORMANCE HUB
-- ════════════════════════════════════════════════════════════════

-- Remove UI anterior se existir
if PlayerGui:FindFirstChild("PerformanceHubUI") then
    PlayerGui:FindFirstChild("PerformanceHubUI"):Destroy()
end

-- ── Criação Base da UI ────────────────────────────────────────────
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name              = "PerformanceHubUI"
    ScreenGui.ResetOnSpawn      = false
    ScreenGui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder      = 999
    ScreenGui.IgnoreGuiInset    = true
    ScreenGui.Parent            = PlayerGui

    -- ── Blur de fundo ──────────────────────────────────────────────
    local BlurBG = Instance.new("BlurEffect")
    BlurBG.Name  = "PerfHubBlur"
    BlurBG.Size  = 0
    BlurBG.Parent= Lighting

    -- ── Overlay escuro ─────────────────────────────────────────────
    local Overlay = Instance.new("Frame")
    Overlay.Name              = "Overlay"
    Overlay.Size              = UDim2.fromScale(1, 1)
    Overlay.BackgroundColor3  = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 1
    Overlay.ZIndex            = 0
    Overlay.Parent            = ScreenGui

    -- ── Container Principal ────────────────────────────────────────
    local MainFrame = Instance.new("Frame")
    MainFrame.Name              = "MainFrame"
    MainFrame.Size              = UDim2.new(0, 700, 0, 480)
    MainFrame.Position          = UDim2.new(0.5, -350, 0.5, -240)
    MainFrame.BackgroundColor3  = Theme.Background
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.ClipsDescendants  = false
    MainFrame.ZIndex            = 10
    MainFrame.Parent            = ScreenGui

    -- Cantos arredondados
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent       = MainFrame

    -- Borda principal
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color     = Theme.Accent
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0.4
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent   = MainFrame

    -- Sombra externa
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name              = "Shadow"
    Shadow.Size              = UDim2.new(1, 60, 1, 60)
    Shadow.Position          = UDim2.new(0, -30, 0, -30)
    Shadow.BackgroundTransparency = 1
    Shadow.Image             = "rbxassetid://6015897843"
    Shadow.ImageColor3       = Theme.AccentDark
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType         = Enum.ScaleType.Slice
    Shadow.SliceCenter       = Rect.new(49, 49, 450, 450)
    Shadow.ZIndex            = 9
    Shadow.Parent            = MainFrame

    -- Gradiente de fundo
    local BGGradient = Instance.new("UIGradient")
    BGGradient.Color    = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Theme.Background),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 12, 22)),
        ColorSequenceKeypoint.new(1,   Theme.BackgroundAlt),
    })
    BGGradient.Rotation = 135
    BGGradient.Parent   = MainFrame

    -- ── TopBar ─────────────────────────────────────────────────────
    local TopBar = Instance.new("Frame")
    TopBar.Name              = "TopBar"
    TopBar.Size              = UDim2.new(1, 0, 0, 48)
    TopBar.BackgroundColor3  = Theme.Panel
    TopBar.BackgroundTransparency = 0.1
    TopBar.ZIndex            = 11
    TopBar.Parent            = MainFrame

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent       = TopBar

    -- Corrige canto inferior do topbar
    local TopFix = Instance.new("Frame")
    TopFix.Size             = UDim2.new(1, 0, 0, 12)
    TopFix.Position         = UDim2.new(0, 0, 1, -12)
    TopFix.BackgroundColor3 = Theme.Panel
    TopFix.BackgroundTransparency = 0.1
    TopFix.BorderSizePixel  = 0
    TopFix.ZIndex           = 11
    TopFix.Parent           = TopBar

    -- Gradiente no TopBar
    local TopGradient = Instance.new("UIGradient")
    TopGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(30, 20, 50)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 14, 35)),
        ColorSequenceKeypoint.new(1,   Theme.Panel),
    })
    TopGradient.Rotation = 90
    TopGradient.Parent   = TopBar

    -- Linha decorativa no TopBar
    local TopAccentLine = Instance.new("Frame")
    TopAccentLine.Size             = UDim2.new(0.6, 0, 0, 2)
    TopAccentLine.Position         = UDim2.new(0.2, 0, 1, -2)
    TopAccentLine.BackgroundColor3 = Theme.Accent
    TopAccentLine.BorderSizePixel  = 0
    TopAccentLine.ZIndex           = 12
    TopAccentLine.Parent           = TopBar

    local LineGrad = Instance.new("UIGradient")
    LineGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.3, Theme.Accent),
        ColorSequenceKeypoint.new(0.7, Theme.AccentBlue),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,0,0)),
    })
    LineGrad.Parent = TopAccentLine

    -- Ícone / Logo
    local LogoLabel = Instance.new("TextLabel")
    LogoLabel.Size              = UDim2.new(0, 36, 0, 36)
    LogoLabel.Position          = UDim2.new(0, 10, 0.5, -18)
    LogoLabel.BackgroundColor3  = Theme.Accent
    LogoLabel.Text              = "⚡"
    LogoLabel.TextColor3        = Theme.White
    LogoLabel.TextScaled        = true
    LogoLabel.Font              = Enum.Font.GothamBold
    LogoLabel.ZIndex            = 12
    LogoLabel.Parent            = TopBar

    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0, 8)
    LogoCorner.Parent       = LogoLabel

    local LogoGrad = Instance.new("UIGradient")
    LogoGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.AccentBlue),
    })
    LogoGrad.Rotation = 45
    LogoGrad.Parent   = LogoLabel

    -- Título
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size              = UDim2.new(0, 180, 0, 24)
    TitleLabel.Position          = UDim2.new(0, 54, 0, 8)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text              = "Performance Hub"
    TitleLabel.TextColor3        = Theme.Text
    TitleLabel.TextSize          = 16
    TitleLabel.Font              = Enum.Font.GothamBold
    TitleLabel.TextXAlignment    = Enum.TextXAlignment.Left
    TitleLabel.ZIndex            = 12
    TitleLabel.Parent            = TopBar

    -- Subtítulo / Versão
    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size              = UDim2.new(0, 180, 0, 16)
    SubLabel.Position          = UDim2.new(0, 54, 0, 28)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text              = "v" .. VERSION .. " • FPS Booster"
    SubLabel.TextColor3        = Theme.AccentBlue
    SubLabel.TextSize          = 11
    SubLabel.Font              = Enum.Font.Gotham
    SubLabel.TextXAlignment    = Enum.TextXAlignment.Left
    SubLabel.ZIndex            = 12
    SubLabel.Parent            = TopBar

    -- ── Botões de controle (Fechar / Minimizar / Restaurar) ────────
    local function CreateControlBtn(icon, xOffset, color)
        local btn = Instance.new("TextButton")
        btn.Size              = UDim2.new(0, 28, 0, 28)
        btn.Position          = UDim2.new(1, xOffset, 0.5, -14)
        btn.BackgroundColor3  = Theme.PanelAlt
        btn.Text              = icon
        btn.TextColor3        = color
        btn.TextSize          = 14
        btn.Font              = Enum.Font.GothamBold
        btn.ZIndex            = 12
        btn.Parent            = TopBar
        
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = btn

        local s = Instance.new("UIStroke")
        s.Color     = color
        s.Thickness = 1
        s.Transparency = 0.6
        s.Parent = btn
        
        -- Hover
        btn.MouseEnter:Connect(function()
            SafeTween(btn, TI.Fast, {BackgroundColor3 = color, TextColor3 = Theme.White})
        end)
        btn.MouseLeave:Connect(function()
            SafeTween(btn, TI.Fast, {BackgroundColor3 = Theme.PanelAlt, TextColor3 = color})
        end)
        
        return btn
    end

    local CloseBtn    = CreateControlBtn("✕", -10, Theme.Danger)
    local MinimizeBtn = CreateControlBtn("─", -46, Theme.Warning)
    local RestoreBtn  = CreateControlBtn("□", -82, Theme.Success)

    -- FPS rápido no TopBar
    local TopFPS = Instance.new("TextLabel")
    TopFPS.Name              = "TopFPS"
    TopFPS.Size              = UDim2.new(0, 80, 0, 28)
    TopFPS.Position          = UDim2.new(1, -170, 0.5, -14)
    TopFPS.BackgroundColor3  = Theme.Panel
    TopFPS.BackgroundTransparency = 0.3
    TopFPS.Text              = "⚡ 0 FPS"
    TopFPS.TextColor3        = Theme.Success
    TopFPS.TextSize          = 12
    TopFPS.Font              = Enum.Font.GothamBold
    TopFPS.ZIndex            = 12
    TopFPS.Parent            = TopBar

    local TopFPSCorner = Instance.new("UICorner")
    TopFPSCorner.CornerRadius = UDim.new(0, 6)
    TopFPSCorner.Parent      = TopFPS

    -- ── Sidebar ────────────────────────────────────────────────────
    local Sidebar = Instance.new("Frame")
    Sidebar.Name              = "Sidebar"
    Sidebar.Size              = UDim2.new(0, 140, 1, -48)
    Sidebar.Position          = UDim2.new(0, 0, 0, 48)
    Sidebar.BackgroundColor3  = Theme.Panel
    Sidebar.BackgroundTransparency = 0.2
    Sidebar.ZIndex            = 11
    Sidebar.Parent            = MainFrame

    local SideGrad = Instance.new("UIGradient")
    SideGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 14, 32)),
        ColorSequenceKeypoint.new(1, Theme.Panel),
    })
    SideGrad.Rotation = 90
    SideGrad.Parent   = Sidebar

    -- Lista de categorias
    local SideScroll = Instance.new("ScrollingFrame")
    SideScroll.Size              = UDim2.new(1, 0, 1, -10)
    SideScroll.Position          = UDim2.new(0, 0, 0, 10)
    SideScroll.BackgroundTransparency = 1
    SideScroll.ScrollBarThickness = 0
    SideScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    SideScroll.CanvasSize         = UDim2.new(0, 0, 0, 0)
    SideScroll.ZIndex             = 11
    SideScroll.Parent             = Sidebar

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Padding    = UDim.new(0, 3)
    SideLayout.SortOrder  = Enum.SortOrder.LayoutOrder
    SideLayout.Parent     = SideScroll

    -- ── Área de Conteúdo ───────────────────────────────────────────
    local ContentArea = Instance.new("Frame")
    ContentArea.Name              = "ContentArea"
    ContentArea.Size              = UDim2.new(1, -140, 1, -48)
    ContentArea.Position          = UDim2.new(0, 140, 0, 48)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ClipsDescendants  = true
    ContentArea.ZIndex            = 11
    ContentArea.Parent            = MainFrame

    -- ── Categorias ─────────────────────────────────────────────────
    local Categories = {
        {name = "Performance", icon = "⚡"},
        {name = "Graphics",    icon = "🎨"},
        {name = "Rendering",   icon = "🖥"},
        {name = "Lighting",    icon = "💡"},
        {name = "Memory",      icon = "💾"},
        {name = "Network",     icon = "📡"},
        {name = "Advanced",    icon = "⚙"},
        {name = "Settings",    icon = "🔧"},
        {name = "Stats",       icon = "📊"},
    }

    -- Painéis por categoria
    local Panels = {}

    -- Cria painel vazio para cada categoria
    for _, cat in ipairs(Categories) do
        local panel = Instance.new("ScrollingFrame")
        panel.Name              = cat.name .. "Panel"
        panel.Size              = UDim2.new(1, 0, 1, 0)
        panel.BackgroundTransparency = 1
        panel.ScrollBarThickness = 3
        panel.ScrollBarImageColor3 = Theme.Accent
        panel.CanvasSize        = UDim2.new(0, 0, 0, 0)
        panel.ScrollingDirection = Enum.ScrollingDirection.Y
        panel.Visible           = false
        panel.ZIndex            = 12
        panel.Parent            = ContentArea
        
        local Layout = Instance.new("UIListLayout")
        Layout.Padding   = UDim.new(0, 6)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent    = panel
        
        local Padding = Instance.new("UIPadding")
        Padding.PaddingTop    = UDim.new(0, 8)
        Padding.PaddingLeft   = UDim.new(0, 10)
        Padding.PaddingRight  = UDim.new(0, 10)
        Padding.PaddingBottom = UDim.new(0, 8)
        Padding.Parent = panel
        
        -- Auto-ajusta canvas
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            panel.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 16)
        end)
        
        Panels[cat.name] = panel
    end

    -- ── Funções de UI Helpers ─────────────────────────────────────
    
    -- Cria seção/header
    local function CreateSection(parent, title)
        local section = Instance.new("Frame")
        section.Size              = UDim2.new(1, 0, 0, 28)
        section.BackgroundTransparency = 1
        section.ZIndex            = 12
        section.Parent            = parent

        local line1 = Instance.new("Frame")
        line1.Size             = UDim2.new(0.15, 0, 0, 1)
        line1.Position         = UDim2.new(0, 0, 0.5, 0)
        line1.BackgroundColor3 = Theme.Border
        line1.BorderSizePixel  = 0
        line1.ZIndex           = 12
        line1.Parent           = section

        local lbl = Instance.new("TextLabel")
        lbl.Size              = UDim2.new(0.7, 0, 1, 0)
        lbl.Position          = UDim2.new(0.15, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text              = title
        lbl.TextColor3        = Theme.Accent
        lbl.TextSize          = 11
        lbl.Font              = Enum.Font.GothamBold
        lbl.ZIndex            = 12
        lbl.Parent            = section

        local LblGrad = Instance.new("UIGradient")
        LblGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.AccentBlue),
        })
        LblGrad.Parent = lbl

        local line2 = Instance.new("Frame")
        line2.Size             = UDim2.new(0.15, 0, 0, 1)
        line2.Position         = UDim2.new(0.85, 0, 0.5, 0)
        line2.BackgroundColor3 = Theme.Border
        line2.BorderSizePixel  = 0
        line2.ZIndex           = 12
        line2.Parent           = section

        return section
    end

    -- Cria Toggle (Switch)
    local function CreateToggle(parent, label, defaultState, callback)
        local row = Instance.new("Frame")
        row.Size              = UDim2.new(1, 0, 0, 38)
        row.BackgroundColor3  = Theme.PanelAlt
        row.BackgroundTransparency = 0.3
        row.ZIndex            = 12
        row.Parent            = parent

        local rowCorner = Instance.new("UICorner")
        rowCorner.CornerRadius = UDim.new(0, 8)
        rowCorner.Parent = row

        local rowStroke = Instance.new("UIStroke")
        rowStroke.Color     = Theme.Border
        rowStroke.Thickness = 1
        rowStroke.Transparency = 0.7
        rowStroke.Parent    = row

        local lbl = Instance.new("TextLabel")
        lbl.Size              = UDim2.new(1, -56, 1, 0)
        lbl.Position          = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text              = label
        lbl.TextColor3        = Theme.Text
        lbl.TextSize          = 12
        lbl.Font              = Enum.Font.Gotham
        lbl.TextXAlignment    = Enum.TextXAlignment.Left
        lbl.ZIndex            = 12
        lbl.Parent            = row

        -- Switch background
        local switchBG = Instance.new("Frame")
        switchBG.Size              = UDim2.new(0, 40, 0, 20)
        switchBG.Position          = UDim2.new(1, -52, 0.5, -10)
        switchBG.BackgroundColor3  = defaultState and Theme.Accent or Theme.Border
        switchBG.ZIndex            = 13
        switchBG.Parent            = row

        local switchCorner = Instance.new("UICorner")
        switchCorner.CornerRadius = UDim.new(1, 0)
        switchCorner.Parent = switchBG

        -- Knob
        local knob = Instance.new("Frame")
        knob.Size              = UDim2.new(0, 16, 0, 16)
        knob.Position          = defaultState
            and UDim2.new(1, -18, 0.5, -8)
            or  UDim2.new(0, 2, 0.5, -8)
        knob.BackgroundColor3  = Theme.White
        knob.ZIndex            = 14
        knob.Parent            = switchBG

        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = knob

        -- Glow do knob
        local knobGlow = Instance.new("UIStroke")
        knobGlow.Color = defaultState and Theme.Accent or Color3.fromRGB(100,100,100)
        knobGlow.Thickness = 2
        knobGlow.Transparency = 0.5
        knobGlow.Parent = knob

        local state = defaultState
        local btn = Instance.new("TextButton")
        btn.Size              = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text              = ""
        btn.ZIndex            = 15
        btn.Parent            = row

        btn.MouseEnter:Connect(function()
            SafeTween(row, TI.Fast, {BackgroundTransparency = 0.1, BackgroundColor3 = Color3.fromRGB(30, 25, 45)})
        end)
        btn.MouseLeave:Connect(function()
            SafeTween(row, TI.Fast, {BackgroundTransparency = 0.3, BackgroundColor3 = Theme.PanelAlt})
        end)

        btn.MouseButton1Click:Connect(function()
            state = not state
            -- Ripple effect
            local ripple = Instance.new("Frame")
            ripple.Size              = UDim2.new(0, 0, 0, 0)
            ripple.Position          = UDim2.new(0.5, 0, 0.5, 0)
            ripple.BackgroundColor3  = Theme.Accent
            ripple.BackgroundTransparency = 0.7
            ripple.ZIndex            = 16
            ripple.Parent            = row
            local rc = Instance.new("UICorner")
            rc.CornerRadius = UDim.new(1, 0)
            rc.Parent = ripple
            SafeTween(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(2, 0, 2, 0),
                Position = UDim2.new(-0.5, 0, -0.5, 0),
                BackgroundTransparency = 1,
            })
            task.delay(0.4, function()
                if ripple and ripple.Parent then ripple:Destroy() end
            end)

            if state then
                SafeTween(switchBG, TI.Medium, {BackgroundColor3 = Theme.Accent})
                SafeTween(knob, TI.Medium, {Position = UDim2.new(1, -18, 0.5, -8)})
                SafeTween(knobGlow, TI.Medium, {Color = Theme.Accent})
            else
                SafeTween(switchBG, TI.Medium, {BackgroundColor3 = Theme.Border})
                SafeTween(knob, TI.Medium, {Position = UDim2.new(0, 2, 0.5, -8)})
                SafeTween(knobGlow, TI.Medium, {Color = Color3.fromRGB(100,100,100)})
            end

            if callback then
                SafeCall(callback, state)
            end
        end)

        return row, function() return state end
    end

    -- Cria Botão de preset
    local function CreatePresetButton(parent, label, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size              = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3  = color or Theme.Accent
        btn.BackgroundTransparency = 0.3
        btn.Text              = label
        btn.TextColor3        = Theme.White
        btn.TextSize          = 13
        btn.Font              = Enum.Font.GothamBold
        btn.ZIndex            = 12
        btn.Parent            = parent

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = btn

        local s = Instance.new("UIStroke")
        s.Color       = color or Theme.Accent
        s.Thickness   = 1
        s.Transparency = 0.4
        s.Parent      = btn

        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200,200,200)),
        })
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(0.5, 0.7),
            NumberSequenceKeypoint.new(1, 0.9),
        })
        g.Rotation = 90
        g.Parent   = btn

        btn.MouseEnter:Connect(function()
            SafeTween(btn, TI.Fast, {BackgroundTransparency = 0.1})
        end)
        btn.MouseLeave:Connect(function()
            SafeTween(btn, TI.Fast, {BackgroundTransparency = 0.3})
        end)

        btn.MouseButton1Click:Connect(function()
            -- Ripple
            local ripple = Instance.new("Frame")
            ripple.Size              = UDim2.new(0, 10, 0, 10)
            ripple.Position          = UDim2.new(0.5, -5, 0.5, -5)
            ripple.BackgroundColor3  = Theme.White
            ripple.BackgroundTransparency = 0.5
            ripple.ZIndex            = 16
            ripple.Parent            = btn
            local rc = Instance.new("UICorner")
            rc.CornerRadius = UDim.new(1, 0)
            rc.Parent = ripple
            SafeTween(ripple, TweenInfo.new(0.5), {
                Size     = UDim2.new(2, 0, 4, 0),
                Position = UDim2.new(-0.5, 0, -1.5, 0),
                BackgroundTransparency = 1,
            })
            task.delay(0.5, function()
                if ripple and ripple.Parent then ripple:Destroy() end
            end)

            if callback then SafeCall(callback) end
        end)

        return btn
    end

    -- Cria Slider
    local function CreateSlider(parent, label, min, max, default, values, callback)
        local container = Instance.new("Frame")
        container.Size              = UDim2.new(1, 0, 0, 58)
        container.BackgroundColor3  = Theme.PanelAlt
        container.BackgroundTransparency = 0.3
        container.ZIndex            = 12
        container.Parent            = parent

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = container

        local s = Instance.new("UIStroke")
        s.Color     = Theme.Border
        s.Thickness = 1
        s.Transparency = 0.7
        s.Parent    = container

        local lbl = Instance.new("TextLabel")
        lbl.Size              = UDim2.new(0.7, 0, 0, 20)
        lbl.Position          = UDim2.new(0, 12, 0, 4)
        lbl.BackgroundTransparency = 1
        lbl.Text              = label
        lbl.TextColor3        = Theme.Text
        lbl.TextSize          = 12
        lbl.Font              = Enum.Font.Gotham
        lbl.TextXAlignment    = Enum.TextXAlignment.Left
        lbl.ZIndex            = 12
        lbl.Parent            = container

        local valLabel = Instance.new("TextLabel")
        valLabel.Size              = UDim2.new(0.3, -12, 0, 20)
        valLabel.Position          = UDim2.new(0.7, 0, 0, 4)
        valLabel.BackgroundTransparency = 1
        valLabel.Text              = tostring(default)
        valLabel.TextColor3        = Theme.Accent
        valLabel.TextSize          = 12
        valLabel.Font              = Enum.Font.GothamBold
        valLabel.TextXAlignment    = Enum.TextXAlignment.Right
        valLabel.ZIndex            = 12
        valLabel.Parent            = container

        -- Track
        local track = Instance.new("Frame")
        track.Size              = UDim2.new(1, -24, 0, 4)
        track.Position          = UDim2.new(0, 12, 0, 34)
        track.BackgroundColor3  = Theme.Border
        track.ZIndex            = 12
        track.Parent            = container

        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(1, 0)
        trackCorner.Parent = track

        -- Fill
        local fill = Instance.new("Frame")
        fill.Size              = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3  = Theme.Accent
        fill.ZIndex            = 13
        fill.Parent            = track

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill

        local fillGrad = Instance.new("UIGradient")
        fillGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.AccentBlue),
        })
        fillGrad.Parent = fill

        -- Thumb
        local thumb = Instance.new("Frame")
        thumb.Size              = UDim2.new(0, 14, 0, 14)
        thumb.Position          = UDim2.new(0, -7, 0.5, -7)
        thumb.BackgroundColor3  = Theme.White
        thumb.ZIndex            = 14
        thumb.Parent            = track

        local thumbCorner = Instance.new("UICorner")
        thumbCorner.CornerRadius = UDim.new(1, 0)
        thumbCorner.Parent = thumb

        local thumbGlow = Instance.new("UIStroke")
        thumbGlow.Color     = Theme.Accent
        thumbGlow.Thickness = 2
        thumbGlow.Transparency = 0.3
        thumbGlow.Parent    = thumb

        -- Lógica do slider
        local currentValue = default
        local dragging = false

        -- Usa lista de valores predefinidos ou range
        local function GetClosestValue(pct)
            if values and #values > 0 then
                local idx = math.max(1, math.min(#values, math.floor(pct * (#values - 1) + 1.5)))
                return values[idx]
            else
                return math.floor(min + (max - min) * pct)
            end
        end

        local function GetPctFromValue(val)
            if values and #values > 0 then
                for i, v in ipairs(values) do
                    if v == val then
                        return (i - 1) / (#values - 1)
                    end
                end
                return 0
            else
                return (val - min) / (max - min)
            end
        end

        local function UpdateSlider(pct)
            pct = math.clamp(pct, 0, 1)
            local val = GetClosestValue(pct)
            local visualPct = GetPctFromValue(val)
            currentValue = val
            valLabel.Text = tostring(val)
            fill.Size     = UDim2.new(visualPct, 0, 1, 0)
            thumb.Position = UDim2.new(visualPct, -7, 0.5, -7)
            if callback then SafeCall(callback, val) end
        end

        -- Inicializa
        UpdateSlider(GetPctFromValue(default))

        local inputConn
        thumb.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or
               inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                SafeTween(thumb, TI.Fast, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(fill.Size.X.Scale, -9, 0.5, -9)})
            end
        end)

        thumb.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or
               inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                SafeTween(thumb, TI.Fast, {Size = UDim2.new(0, 14, 0, 14)})
            end
        end)

        if inputConn then inputConn:Disconnect() end
        inputConn = Connect(UserInputService.InputChanged, function(inp)
            if not dragging then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement or
               inp.UserInputType == Enum.UserInputType.Touch then
                local trackPos  = track.AbsolutePosition
                local trackSize = track.AbsoluteSize
                local mouseX    = inp.Position.X
                local pct       = (mouseX - trackPos.X) / trackSize.X
                UpdateSlider(pct)
            end
        end)

        track.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                local trackPos  = track.AbsolutePosition
                local trackSize = track.AbsoluteSize
                local mouseX    = inp.Position.X
                local pct       = (mouseX - trackPos.X) / trackSize.X
                UpdateSlider(pct)
            end
        end)

        return container
    end

    -- Cria label de stat
    local function CreateStatRow(parent, label, valueName)
        local row = Instance.new("Frame")
        row.Size              = UDim2.new(1, 0, 0, 34)
        row.BackgroundColor3  = Theme.PanelAlt
        row.BackgroundTransparency = 0.4
        row.ZIndex            = 12
        row.Parent            = parent

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = row

        local lbl = Instance.new("TextLabel")
        lbl.Size              = UDim2.new(0.6, 0, 1, 0)
        lbl.Position          = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text              = label
        lbl.TextColor3        = Theme.TextDim
        lbl.TextSize          = 12
        lbl.Font              = Enum.Font.Gotham
        lbl.TextXAlignment    = Enum.TextXAlignment.Left
        lbl.ZIndex            = 12
        lbl.Parent            = row

        local val = Instance.new("TextLabel")
        val.Name              = valueName
        val.Size              = UDim2.new(0.4, -12, 1, 0)
        val.Position          = UDim2.new(0.6, 0, 0, 0)
        val.BackgroundTransparency = 1
        val.Text              = "..."
        val.TextColor3        = Theme.Accent
        val.TextSize          = 12
        val.Font              = Enum.Font.GothamBold
        val.TextXAlignment    = Enum.TextXAlignment.Right
        val.ZIndex            = 12
        val.Parent            = row

        return row, val
    end

    -- ── PAINEL: PERFORMANCE ───────────────────────────────────────
    local perfPanel = Panels["Performance"]
    
    CreateSection(perfPanel, "⚡  MODOS DE OTIMIZAÇÃO")
    
    local modeColors = {
        ["Light"]          = Theme.AccentBlue,
        ["Medium"]         = Theme.Accent,
        ["High"]           = Theme.Warning,
        ["Extreme"]        = Theme.Danger,
        ["Gamer"]          = Color3.fromRGB(0, 200, 100),
        ["Ultra Performance"] = Color3.fromRGB(255, 50, 100),
        ["Intelligent"]    = Color3.fromRGB(180, 100, 255),
        ["Automatic"]      = Color3.fromRGB(100, 180, 255),
    }

    for modeName, _ in pairs(Presets) do
        local col = modeColors[modeName] or Theme.Accent
        CreatePresetButton(perfPanel, "▶  " .. modeName, col, function()
            ApplyPreset(modeName)
        end)
    end

    CreateSection(perfPanel, "⚙  CONTROLES")

    CreatePresetButton(perfPanel, "✓  Enable All Optimizations", Theme.Success, function()
        ScanWorkspace()
        ApplyPreset("Ultra Performance")
    end)

    CreatePresetButton(perfPanel, "✕  Disable All / Restore", Theme.Danger, function()
        RestoreDefaults()
        ScanWorkspace()
    end)

    CreatePresetButton(perfPanel, "↺  Reset to Defaults", Theme.AccentBlue, function()
        RestoreDefaults()
    end)

    CreatePresetButton(perfPanel, "🔍  Auto Detect Best Settings", Color3.fromRGB(150, 220, 255), function()
        ApplyPreset("Intelligent")
    end)

    CreatePresetButton(perfPanel, "🔧  Benchmark (Scan Workspace)", Theme.Warning, function()
        ScanWorkspace()
        UpdateStats()
    end)

    -- ── PAINEL: GRAPHICS ──────────────────────────────────────────
    local graphPanel = Panels["Graphics"]

    CreateSection(graphPanel, "🎨  EFEITOS VISUAIS")

    local graphicsToggles = {
        {"Disable Shadows",           function(v) OptimizeShadows(v) end},
        {"Disable Particles",         function(v) OptimizeParticles(v) end},
        {"Disable Trails",            function(v) OptimizeTrails(v) end},
        {"Disable Smoke",             function(v) OptimizeSmoke(v) end},
        {"Disable Fire",              function(v) OptimizeFire(v) end},
        {"Disable Sparkles",          function(v) OptimizeSparkles(v) end},
        {"Disable Beams",             function(v) OptimizeBeams(v) end},
        {"Disable Decals",            function(v) OptimizeDecals(v) end},
        {"Disable Textures",          function(v) OptimizeTextures(v) end},
        {"Disable Highlights",        function(v) OptimizeHighlights(v) end},
        {"Disable Surface Appearance",function(v) OptimizeSurfaceAppearance(v) end},
        {"Disable Neon Materials",    function(v) OptimizeNeonMaterials(v) end},
        {"Disable Glass",             function(v) OptimizeGlass(v) end},
    }

    for _, t in ipairs(graphicsToggles) do
        CreateToggle(graphPanel, t[1], false, t[2])
    end

    -- ── PAINEL: RENDERING ─────────────────────────────────────────
    local renderPanel = Panels["Rendering"]

    CreateSection(renderPanel, "🖥  QUALIDADE")

    CreateSlider(renderPanel, "Graphics Quality", 1, 10, 5,
        {1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
        function(val)
            SafeCall(function()
                local levels = {
                    Enum.QualityLevel.Level01, Enum.QualityLevel.Level02,
                    Enum.QualityLevel.Level03, Enum.QualityLevel.Level04,
                    Enum.QualityLevel.Level05, Enum.QualityLevel.Level06,
                    Enum.QualityLevel.Level07, Enum.QualityLevel.Level08,
                    Enum.QualityLevel.Level09, Enum.QualityLevel.Level10,
                }
                settings().Rendering.QualityLevel = levels[val] or Enum.QualityLevel.Level05
            end)
        end)

    CreateSection(renderPanel, "📏  RENDER DISTANCE")

    CreateSlider(renderPanel, "View Distance", 50, 2000,
        500,
        {50, 100, 200, 300, 500, 800, 1000, 2000},
        function(val)
            SetRenderDistance(val)
        end)

    CreateSection(renderPanel, "⚡  FPS")

    CreateToggle(renderPanel, "Unlimited FPS", false, function(v)
        SetUnlimitedFPS(v)
    end)

    CreateSlider(renderPanel, "FPS Cap", 30, 9999,
        60,
        {30, 60, 90, 120, 144, 165, 240, 360, 500, 1000, 9999},
        function(val)
            State.FpsCap = val
            if not State.UnlimitedFps then
                UpdateFPS(val)
            end
        end)

    CreateSection(renderPanel, "🖥  OTIMIZAÇÕES")

    local renderToggles = {
        {"Disable Bloom",         function(v) OptimizeBloom(v) end},
        {"Disable Blur",          function(v) OptimizeBlur(v) end},
        {"Disable Depth of Field",function(v) OptimizeDepthOfField(v) end},
        {"Disable Color Correction",function(v) OptimizeColorCorrection(v) end},
        {"Disable Sun Rays",      function(v) OptimizeSunRays(v) end},
        {"Optimize Physics",      function(v) OptimizePhysics(v) end},
        {"Optimize GUI",          function(v) OptimizeGUI(v) end},
        {"Optimize Audio",        function(v) OptimizeAudio(v) end},
        {"Optimize Characters",   function(v) OptimizeCharacters(v) end},
        {"Optimize Network",      function(v) OptimizeNetwork(v) end},
    }

    for _, t in ipairs(renderToggles) do
        CreateToggle(renderPanel, t[1], false, t[2])
    end

    -- ── PAINEL: LIGHTING ──────────────────────────────────────────
    local lightPanel = Panels["Lighting"]

    CreateSection(lightPanel, "💡  ILUMINAÇÃO")

    local lightToggles = {
        {"Disable All Lights",    function(v) OptimizeLights(v) end},
        {"Disable Point Lights",  function(v) OptimizePointLights(v) end},
        {"Disable Spot Lights",   function(v) OptimizeSpotLights(v) end},
        {"Disable Surface Lights",function(v) OptimizeSurfaceLights(v) end},
        {"Disable Atmosphere",    function(v) OptimizeAtmosphere(v) end},
        {"Disable Fog",           function(v) OptimizeFog(v) end},
        {"Disable Clouds",        function(v) OptimizeClouds(v) end},
        {"Disable Sky",           function(v) OptimizeSky(v) end},
        {"Disable Grass",         function(v) OptimizeGrass(v) end},
        {"Disable Water Effects", function(v) OptimizeWater(v) end},
    }

    for _, t in ipairs(lightToggles) do
        CreateToggle(lightPanel, t[1], false, t[2])
    end

    CreateSection(lightPanel, "⚙  QUALIDADE DE LUZ")

    CreatePresetButton(lightPanel, "Low Lighting Quality", Theme.Warning, function()
        OptimizeLighting("low")
    end)

    CreatePresetButton(lightPanel, "Medium Lighting Quality", Theme.AccentBlue, function()
        OptimizeLighting("medium")
    end)

    CreatePresetButton(lightPanel, "Restore Lighting", Theme.Success, function()
        OptimizeLighting("restore")
    end)

    -- ── PAINEL: MEMORY ────────────────────────────────────────────
    local memPanel = Panels["Memory"]

    CreateSection(memPanel, "💾  MEMÓRIA")

    CreatePresetButton(memPanel, "🧹  Force Garbage Collection", Theme.AccentBlue, function()
        OptimizeMemory()
    end)

    CreatePresetButton(memPanel, "🗑  Clear Unused Cache", Theme.Warning, function()
        -- Limpa referências inválidas
        for key, list in pairs(Cache) do
            if type(list) == "table" then
                local cleaned = {}
                for _, obj in ipairs(list) do
                    if type(obj) == "userdata" and obj.Parent then
                        table.insert(cleaned, obj)
                    end
                end
                Cache[key] = cleaned
            end
        end
        OptimizeMemory()
    end)

    CreateSection(memPanel, "📊  USO DE MEMÓRIA")

    local _, ramStatVal    = CreateStatRow(memPanel, "RAM Usage (MB)",       "MemRAM")
    local _, objStatVal    = CreateStatRow(memPanel, "Total Objects",        "MemObj")
    local _, partStatVal   = CreateStatRow(memPanel, "Parts",                "MemParts")
    local _, meshStatVal   = CreateStatRow(memPanel, "MeshParts",            "MemMesh")
    local _, particleVal   = CreateStatRow(memPanel, "Particle Emitters",    "MemParticles")
    local _, lightVal      = CreateStatRow(memPanel, "Lights",               "MemLights")

    -- Registra referências para update
    Cache.UI.MemRAM       = ramStatVal
    Cache.UI.MemObj       = objStatVal
    Cache.UI.MemParts     = partStatVal
    Cache.UI.MemMesh      = meshStatVal
    Cache.UI.MemParticles = particleVal
    Cache.UI.MemLights    = lightVal

    -- ── PAINEL: NETWORK ────────────────────────────────────────────
    local netPanel = Panels["Network"]

    CreateSection(netPanel, "📡  REDE")

    CreateToggle(netPanel, "Optimize Streaming", false, function(v)
        OptimizeNetwork(v)
    end)

    CreateToggle(netPanel, "Optimize Audio Quality", false, function(v)
        OptimizeAudio(v)
    end)

    local _, pingVal = CreateStatRow(netPanel, "Ping (ms)",    "NetPing")
    Cache.UI.NetPing = pingVal

    -- ── PAINEL: ADVANCED ──────────────────────────────────────────
    local advPanel = Panels["Advanced"]

    CreateSection(advPanel, "⚙  AVANÇADO")

    CreateToggle(advPanel, "Auto Optimization", false, function(v)
        AutoOptEnabled = v
        State.Features["AutoMode"] = v
    end)

    CreateToggle(advPanel, "Monitor New Effects", true, function(v)
        -- A conexão já foi criada em WatchWorkspaceForNewEffects
        State.Features["MonitorEffects"] = v
    end)

    CreatePresetButton(advPanel, "🔄  Rescan Workspace", Theme.AccentBlue, function()
        ScanWorkspace()
    end)

    CreatePresetButton(advPanel, "⚡  Aggressive Optimization", Theme.Danger, function()
        ScanWorkspace()
        ApplyPreset("Ultra Performance")
        OptimizeMemory()
    end)

    CreateSection(advPanel, "ℹ  EXECUTOR INFO")

    local function CreateInfoRow(parent, label, value)
        local row = Instance.new("Frame")
        row.Size              = UDim2.new(1, 0, 0, 30)
        row.BackgroundTransparency = 1
        row.ZIndex            = 12
        row.Parent            = parent

        local lbl = Instance.new("TextLabel")
        lbl.Size              = UDim2.new(0.5, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text              = label
        lbl.TextColor3        = Theme.TextMuted
        lbl.TextSize          = 11
        lbl.Font              = Enum.Font.Gotham
        lbl.TextXAlignment    = Enum.TextXAlignment.Left
        lbl.ZIndex            = 12
        lbl.Parent            = row

        local val = Instance.new("TextLabel")
        val.Size              = UDim2.new(0.5, 0, 1, 0)
        val.Position          = UDim2.new(0.5, 0, 0, 0)
        val.BackgroundTransparency = 1
        val.Text              = value
        val.TextColor3        = Theme.Text
        val.TextSize          = 11
        val.Font              = Enum.Font.GothamBold
        val.TextXAlignment    = Enum.TextXAlignment.Right
        val.ZIndex            = 12
        val.Parent            = row

        return row
    end

    CreateInfoRow(advPanel, "Script Version",  "v" .. VERSION)
    CreateInfoRow(advPanel, "setfpscap",       setfpscap   and "✓ Available" or "✕ Unavailable")
    CreateInfoRow(advPanel, "setframerate",    setframerate and "✓ Available" or "✕ Unavailable")
    CreateInfoRow(advPanel, "Streaming",       Workspace.StreamingEnabled and "✓ Enabled" or "✕ Disabled")

    -- ── PAINEL: SETTINGS ──────────────────────────────────────────
    local setPanel = Panels["Settings"]

    CreateSection(setPanel, "🔧  CONFIGURAÇÕES")

    CreatePresetButton(setPanel, "Enable All Features", Theme.Success, function()
        ScanWorkspace()
        ApplyPreset("Ultra Performance")
    end)

    CreatePresetButton(setPanel, "Disable All Features", Theme.Danger, function()
        RestoreDefaults()
    end)

    CreatePresetButton(setPanel, "Reset All Settings", Theme.Warning, function()
        RestoreDefaults()
        UpdateFPS(60)
        SetRenderDistance(500)
    end)

    CreateSection(setPanel, "ℹ  INFORMAÇÕES")

    local _, uptimeVal     = CreateStatRow(setPanel, "Uptime (s)",            "SetUptime")
    local _, optCountVal   = CreateStatRow(setPanel, "Otimizações Aplicadas", "SetOptCount")
    local _, modeVal       = CreateStatRow(setPanel, "Modo Atual",            "SetMode")

    Cache.UI.SetUptime   = uptimeVal
    Cache.UI.SetOptCount = optCountVal
    Cache.UI.SetMode     = modeVal

    -- ── PAINEL: STATS ─────────────────────────────────────────────
    local statsPanel = Panels["Stats"]

    CreateSection(statsPanel, "📊  ESTATÍSTICAS EM TEMPO REAL")

    local _, fpsVal     = CreateStatRow(statsPanel, "FPS",               "StatFPS")
    local _, ramVal2    = CreateStatRow(statsPanel, "RAM (MB)",           "StatRAM")
    local _, pingVal2   = CreateStatRow(statsPanel, "Ping (ms)",          "StatPing")
    local _, cpuVal     = CreateStatRow(statsPanel, "CPU (approx %)",     "StatCPU")
    local _, rtVal      = CreateStatRow(statsPanel, "Render Time (ms)",   "StatRT")
    local _, objVal     = CreateStatRow(statsPanel, "Workspace Objects",  "StatObj")
    local _, partsVal   = CreateStatRow(statsPanel, "Parts",              "StatParts")
    local _, meshVal    = CreateStatRow(statsPanel, "MeshParts",          "StatMesh")
    local _, decalVal   = CreateStatRow(statsPanel, "Decals",             "StatDecals")
    local _, texVal     = CreateStatRow(statsPanel, "Textures",           "StatTex")
    local _, partEmVal  = CreateStatRow(statsPanel, "Particle Emitters",  "StatParticles")
    local _, lightVal2  = CreateStatRow(statsPanel, "Lights",             "StatLights")

    Cache.UI.StatFPS       = fpsVal
    Cache.UI.StatRAM       = ramVal2
    Cache.UI.StatPing      = pingVal2
    Cache.UI.StatCPU       = cpuVal
    Cache.UI.StatRT        = rtVal
    Cache.UI.StatObj       = objVal
    Cache.UI.StatParts     = partsVal
    Cache.UI.StatMesh      = meshVal
    Cache.UI.StatDecals    = decalVal
    Cache.UI.StatTex       = texVal
    Cache.UI.StatParticles = partEmVal
    Cache.UI.StatLights    = lightVal2

    -- ── Botões de Sidebar ─────────────────────────────────────────
    local activeBtn = nil

    local function SetCategory(name)
        State.CurrentCategory = name
        for _, cat in ipairs(Categories) do
            if Panels[cat.name] then
                Panels[cat.name].Visible = (cat.name == name)
            end
        end
    end

    for _, cat in ipairs(Categories) do
        local btn = Instance.new("TextButton")
        btn.Size              = UDim2.new(1, -10, 0, 36)
        btn.Position          = UDim2.new(0, 5, 0, 0)
        btn.BackgroundTransparency = 1
        btn.Text              = cat.icon .. "  " .. cat.name
        btn.TextColor3        = Theme.TextDim
        btn.TextSize          = 12
        btn.Font              = Enum.Font.Gotham
        btn.TextXAlignment    = Enum.TextXAlignment.Left
        btn.ZIndex            = 12
        btn.Parent            = SideScroll

        local btnPad = Instance.new("UIPadding")
        btnPad.PaddingLeft = UDim.new(0, 10)
        btnPad.Parent = btn

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        -- Indicador lateral
        local indicator = Instance.new("Frame")
        indicator.Size              = UDim2.new(0, 3, 0.6, 0)
        indicator.Position          = UDim2.new(0, 0, 0.2, 0)
        indicator.BackgroundColor3  = Theme.Accent
        indicator.BackgroundTransparency = 1
        indicator.ZIndex            = 13
        indicator.Parent            = btn

        local indCorner = Instance.new("UICorner")
        indCorner.CornerRadius = UDim.new(1, 0)
        indCorner.Parent = indicator

        btn.MouseEnter:Connect(function()
            if State.CurrentCategory ~= cat.name then
                SafeTween(btn, TI.Fast, {BackgroundTransparency = 0.7, TextColor3 = Theme.Text})
            end
        end)

        btn.MouseLeave:Connect(function()
            if State.CurrentCategory ~= cat.name then
                SafeTween(btn, TI.Fast, {BackgroundTransparency = 1, TextColor3 = Theme.TextDim})
            end
        end)

        btn.MouseButton1Click:Connect(function()
            -- Desativa botão anterior
            if activeBtn then
                SafeTween(activeBtn.btn, TI.Fast, {
                    BackgroundTransparency = 1,
                    TextColor3 = Theme.TextDim
                })
                SafeTween(activeBtn.ind, TI.Fast, {BackgroundTransparency = 1})
            end

            -- Ativa este botão
            SafeTween(btn, TI.Fast, {
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.8,
                TextColor3 = Theme.White
            })
            SafeTween(indicator, TI.Fast, {BackgroundTransparency = 0})

            activeBtn = {btn = btn, ind = indicator}
            SetCategory(cat.name)
        end)

        -- Ativa a primeira categoria automaticamente
        if cat.name == "Performance" then
            SafeTween(btn, TI.Fast, {
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.8,
                TextColor3 = Theme.White
            })
            indicator.BackgroundTransparency = 0
            activeBtn = {btn = btn, ind = indicator}
        end
    end

    SetCategory("Performance")

    -- ── Dragging ──────────────────────────────────────────────────
    local isDragging   = false
    local dragStartPos = Vector2.new(0, 0)
    local frameStartPos= Vector2.new(0, 0)

    TopBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then
            isDragging    = true
            dragStartPos  = Vector2.new(inp.Position.X, inp.Position.Y)
            frameStartPos = Vector2.new(
                MainFrame.Position.X.Offset,
                MainFrame.Position.Y.Offset
            )
        end
    end)

    TopBar.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    Connect(UserInputService.InputChanged, function(inp)
        if not isDragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement or
           inp.UserInputType == Enum.UserInputType.Touch then
            local delta = Vector2.new(inp.Position.X, inp.Position.Y) - dragStartPos
            local newX  = frameStartPos.X + delta.X
            local newY  = frameStartPos.Y + delta.Y
            -- Clamp dentro da tela
            local vpSize = Camera.ViewportSize
            newX = math.clamp(newX, 0, vpSize.X - MainFrame.AbsoluteSize.X)
            newY = math.clamp(newY, 0, vpSize.Y - MainFrame.AbsoluteSize.Y)
            MainFrame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    -- ── Minimizar / Fechar / Restaurar ────────────────────────────
    local originalSize = MainFrame.Size
    local originalPos  = MainFrame.Position
    local isMinimized  = false

    MinimizeBtn.MouseButton1Click:Connect(function()
        if isMinimized then
            isMinimized = false
            ContentArea.Visible = true
            Sidebar.Visible     = true
            SafeTween(MainFrame, TI.Spring, {Size = originalSize})
            SafeTween(BlurBG, TI.Medium, {Size = 8})
        else
            isMinimized = true
            ContentArea.Visible = false
            Sidebar.Visible     = false
            SafeTween(MainFrame, TI.Spring, {Size = UDim2.new(0, 700, 0, 48)})
            SafeTween(BlurBG, TI.Medium, {Size = 0})
        end
        State.UIMinimized = isMinimized
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        SafeTween(MainFrame, TI.Medium, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(
                MainFrame.Position.X.Scale,
                MainFrame.Position.X.Offset + MainFrame.AbsoluteSize.X / 2,
                MainFrame.Position.Y.Scale,
                MainFrame.Position.Y.Offset + MainFrame.AbsoluteSize.Y / 2
            ),
            BackgroundTransparency = 1
        })
        SafeTween(BlurBG, TI.Medium, {Size = 0})
        task.delay(0.3, function()
            ScreenGui:Destroy()
            BlurBG:Destroy()
        end)
        State.UIVisible = false
    end)

    RestoreBtn.MouseButton1Click:Connect(function()
        isMinimized = false
        ContentArea.Visible = true
        Sidebar.Visible     = true
        MainFrame.Size     = originalSize
        MainFrame.Position = UDim2.new(0.5, -350, 0.5, -240)
        State.UIMinimized  = false
        SafeTween(BlurBG, TI.Medium, {Size = 8})
    end)

    -- ── Animação de abertura ──────────────────────────────────────
    MainFrame.Size               = UDim2.new(0, 0, 0, 0)
    MainFrame.Position           = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundTransparency = 1

    SafeTween(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size     = originalSize,
        Position = UDim2.new(0.5, -350, 0.5, -240),
        BackgroundTransparency = 0.05,
    })

    SafeTween(BlurBG, TweenInfo.new(0.5), {Size = 8})

    -- ── Função de atualização do UI (Stats) ───────────────────────
    local function RefreshUIStats()
        -- TopBar FPS
        if TopFPS and TopFPS.Parent then
            local fps = State.Stats.FPS
            TopFPS.Text = string.format("⚡ %d FPS", fps)
            if fps >= 55 then
                TopFPS.TextColor3 = Theme.Success
            elseif fps >= 30 then
                TopFPS.TextColor3 = Theme.Warning
            else
                TopFPS.TextColor3 = Theme.Danger
            end
        end

        -- Stats panel
        local function SafeSetText(obj, text)
            if obj and obj.Parent then
                obj.Text = text
            end
        end

        SafeSetText(Cache.UI.StatFPS,       string.format("%d", State.Stats.FPS))
        SafeSetText(Cache.UI.StatRAM,       string.format("%d MB", State.Stats.RAM))
        SafeSetText(Cache.UI.StatPing,      string.format("%d ms", State.Stats.Ping))
        SafeSetText(Cache.UI.StatCPU,       string.format("%.1f%%", State.Stats.CPU))
        SafeSetText(Cache.UI.StatRT,        string.format("%.2f ms", State.Stats.RenderTime))
        SafeSetText(Cache.UI.StatObj,       string.format("%d", State.Stats.Objects))
        SafeSetText(Cache.UI.StatParts,     string.format("%d", State.Stats.Parts))
        SafeSetText(Cache.UI.StatMesh,      string.format("%d", State.Stats.MeshParts))
        SafeSetText(Cache.UI.StatDecals,    string.format("%d", State.Stats.Decals))
        SafeSetText(Cache.UI.StatTex,       string.format("%d", State.Stats.Textures))
        SafeSetText(Cache.UI.StatParticles, string.format("%d", State.Stats.Particles))
        SafeSetText(Cache.UI.StatLights,    string.format("%d", State.Stats.Lights))

        -- Memory panel
        SafeSetText(Cache.UI.MemRAM,       string.format("%d MB", State.Stats.RAM))
        SafeSetText(Cache.UI.MemObj,       string.format("%d", State.Stats.Objects))
        SafeSetText(Cache.UI.MemParts,     string.format("%d", State.Stats.Parts))
        SafeSetText(Cache.UI.MemMesh,      string.format("%d", State.Stats.MeshParts))
        SafeSetText(Cache.UI.MemParticles, string.format("%d", State.Stats.Particles))
        SafeSetText(Cache.UI.MemLights,    string.format("%d", State.Stats.Lights))

        -- Network panel
        SafeSetText(Cache.UI.NetPing, string.format("%d ms", State.Stats.Ping))

        -- Settings panel
        SafeSetText(Cache.UI.SetUptime,   string.format("%ds", State.Uptime))
        SafeSetText(Cache.UI.SetOptCount, string.format("%d", State.OptimizationsApplied))
        SafeSetText(Cache.UI.SetMode,     State.CurrentMode)
    end

    return RefreshUIStats
end

-- ════════════════════════════════════════════════════════════════
-- [10] INICIALIZAÇÃO E LOOP PRINCIPAL
-- ════════════════════════════════════════════════════════════════

-- Cria a UI e obtém a função de refresh
CacheLightingOriginals()
ScanWorkspace()
local RefreshUIStats = CreateUI()
WatchWorkspaceForNewEffects()

-- Configuração inicial de FPS
UpdateFPS(60)

-- ── Loop Principal ─────────────────────────────────────────────
local lastStatUpdate  = 0
local lastScanUpdate  = 0
local lastAutoUpdate  = 0

Connect(RunService.Heartbeat, function()
    local now = os.clock()

    -- Atualiza estatísticas
    if now - lastStatUpdate >= UPDATE_INTERVAL then
        lastStatUpdate = now
        SafeCall(UpdateStats)
        SafeCall(RefreshUIStats)
    end

    -- Re-scan do Workspace (menos frequente)
    if now - lastScanUpdate >= SCAN_INTERVAL then
        lastScanUpdate = now
        SafeCall(ScanWorkspace)
    end

    -- Auto Optimization
    if AutoOptEnabled and (now - lastAutoUpdate >= AUTO_OPT_INTERVAL) then
        lastAutoUpdate = now
        SafeCall(RunAutoOptimization)
    end

    -- Modo Automático contínuo
    if State.Features["AutoMode"] and Presets["Automatic"] then
        SafeCall(function()
            local fps = State.Stats.FPS
            if fps > 0 and fps < 25 and not State._autoApplied then
                State._autoApplied = true
                ApplyPreset("Intelligent")
            elseif fps >= 60 then
                State._autoApplied = false
            end
        end)
    end
end)

-- ── Cleanup ao sair ────────────────────────────────────────────
LocalPlayer.AncestryChanged:Connect(function()
    DisconnectAll()
end)

-- ── Mensagem de inicialização ──────────────────────────────────
print(string.format(
    "[Performance Hub v%s] Iniciado com sucesso! FPS: %d | RAM: %dMB | Objetos: %d",
    VERSION,
    State.Stats.FPS,
    State.Stats.RAM,
    #Workspace:GetChildren()
))
