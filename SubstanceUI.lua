--------------------------------------------------------------------------------
-- Substance 2.0 — standalone executor UI library (no external dependencies).
--------------------------------------------------------------------------------

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer

local ACCENT = Color3.fromRGB(244, 99, 111)
local ACCENT_DARK = Color3.fromRGB(174, 62, 72)
local BG = Color3.fromRGB(8, 8, 10)
local HEADER = Color3.fromRGB(4, 4, 5)
local PANEL = Color3.fromRGB(12, 12, 15)
local CARD = Color3.fromRGB(16, 16, 20)
local FIELD = Color3.fromRGB(5, 5, 7)
local OUTLINE = Color3.fromRGB(34, 33, 39)
local TEXT = Color3.fromRGB(228, 226, 234)
local MUTED = Color3.fromRGB(118, 114, 130)
local DIM = Color3.fromRGB(70, 68, 80)
local DARK = Color3.fromRGB(18, 16, 20)
local BADGE = Color3.fromRGB(236, 236, 240)
local FONT = Enum.Font.RobotoMono

local BOLD_FONT
pcall(function()
	BOLD_FONT = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Bold)
end)

local env = (type(getgenv) == "function" and getgenv()) or _G
local Toggles, Options = {}, {}
env.Toggles, env.Options = Toggles, Options

local Library = {
	-- Capability marker: NewUAPB's loadLibraries() refuses stale/incompatible
	-- builds that lack the module-card API (e.g. an old SubstanceUI or a
	-- Linoria-style lib sitting in the workspace under this filename).
	API_VERSION = 2,
	FontColor = TEXT,
	MainColor = PANEL,
	BackgroundColor = BG,
	AccentColor = ACCENT,
	AccentColorDark = ACCENT_DARK,
	OutlineColor = OUTLINE,
	Font = FONT,
	Black = Color3.new(0, 0, 0),
	-- Weak-keyed so destroyed instances (popup rows, rebuilt keybind labels,
	-- transient notification frames) drop out instead of being pinned forever.
	Registry = setmetatable({}, { __mode = "k" }),
	RegistryMap = setmetatable({}, { __mode = "k" }),
	Signals = {},
	KeyPickers = {},
	ThemeRegistry = setmetatable({}, { __mode = "k" }),
	TitleLabels = setmetatable({}, { __mode = "k" }),
	Controls = {},
	Unloaded = false,
}

--------------------------------------------------------------------------------
-- Theme
--------------------------------------------------------------------------------

---Font families offered in the Theme module; value = Roblox FontFamily json name.
Library.Fonts = { "RobotoMono", "Code", "Gotham", "GothamMedium", "SourceSans", "Ubuntu", "Arimo" }

local FONT_FAMILIES = {
	RobotoMono = "RobotoMono",
	Code = "Inconsolata",
	Gotham = "GothamSSm",
	GothamMedium = "GothamSSm",
	SourceSans = "SourceSansPro",
	Ubuntu = "Ubuntu",
	Arimo = "Arimo",
}

Library.Theme = {
	Accent = ACCENT,
	AccentDark = ACCENT_DARK,
	Background = BG,
	Header = HEADER,
	Panel = PANEL,
	Card = CARD,
	Field = FIELD,
	Outline = OUTLINE,
	Text = TEXT,
	Muted = MUTED,
	Dim = DIM,
	Dark = DARK,
	Badge = BADGE,
	Sheen = Color3.fromRGB(255, 255, 255),
	Font = FONT,
	TextScale = 1,
	WindowTransparency = 0,
	PanelTransparency = 0,
	CardTransparency = 0,
	FieldTransparency = 0,
	BackgroundImage = "",
	BackgroundImageTransparency = 0.6,
	BackgroundImageBlur = 0,
	BackgroundDim = 0.4,
	ScreenBlur = false,
	BlurSize = 24,
	Animations = true,
	HoverGlow = ACCENT,
	HoverGlowEnabled = true,
}

Library.Presets = {
	Dark = {
		Accent = ACCENT,
		AccentDark = ACCENT_DARK,
		Background = BG,
		Header = HEADER,
		Panel = PANEL,
		Card = CARD,
		Field = FIELD,
		Outline = OUTLINE,
		Text = TEXT,
		Muted = MUTED,
		Dim = DIM,
		Dark = DARK,
		Badge = BADGE,
		Sheen = Color3.fromRGB(255, 255, 255),
		WindowTransparency = 0,
		PanelTransparency = 0,
		CardTransparency = 0,
		FieldTransparency = 0,
		ScreenBlur = false,
	},
	Glass = {
		Accent = ACCENT,
		AccentDark = ACCENT_DARK,
		Background = BG,
		Header = HEADER,
		Panel = PANEL,
		Card = CARD,
		Field = FIELD,
		Outline = OUTLINE,
		Text = TEXT,
		Muted = MUTED,
		Dim = DIM,
		Dark = DARK,
		Badge = BADGE,
		Sheen = Color3.fromRGB(255, 255, 255),
		WindowTransparency = 0.4,
		PanelTransparency = 0.45,
		CardTransparency = 0.35,
		FieldTransparency = 0.2,
		ScreenBlur = true,
	},
	Midnight = {
		Accent = Color3.fromRGB(120, 150, 255),
		AccentDark = Color3.fromRGB(84, 105, 179),
		Background = Color3.fromRGB(6, 8, 16),
		Header = Color3.fromRGB(4, 5, 10),
		Panel = Color3.fromRGB(10, 12, 22),
		Card = Color3.fromRGB(14, 17, 30),
		Field = Color3.fromRGB(5, 6, 12),
		Outline = Color3.fromRGB(32, 38, 60),
		Text = Color3.fromRGB(226, 230, 245),
		Muted = Color3.fromRGB(110, 118, 148),
		Dim = Color3.fromRGB(66, 72, 95),
		Dark = Color3.fromRGB(14, 16, 26),
		Badge = Color3.fromRGB(232, 235, 245),
		Sheen = Color3.fromRGB(200, 215, 255),
		WindowTransparency = 0,
		PanelTransparency = 0,
		CardTransparency = 0,
		FieldTransparency = 0,
		ScreenBlur = false,
	},
	Crimson = {
		Accent = Color3.fromRGB(230, 50, 70),
		AccentDark = Color3.fromRGB(161, 35, 49),
		Background = Color3.fromRGB(12, 6, 8),
		Header = Color3.fromRGB(7, 3, 5),
		Panel = Color3.fromRGB(18, 9, 12),
		Card = Color3.fromRGB(24, 12, 16),
		Field = Color3.fromRGB(8, 4, 6),
		Outline = Color3.fromRGB(58, 26, 32),
		Text = Color3.fromRGB(238, 226, 229),
		Muted = Color3.fromRGB(150, 108, 118),
		Dim = Color3.fromRGB(96, 60, 68),
		Dark = Color3.fromRGB(24, 10, 14),
		Badge = Color3.fromRGB(245, 232, 235),
		Sheen = Color3.fromRGB(255, 200, 208),
		WindowTransparency = 0,
		PanelTransparency = 0,
		CardTransparency = 0,
		FieldTransparency = 0,
		ScreenBlur = false,
	},
	Emerald = {
		Accent = Color3.fromRGB(80, 200, 140),
		AccentDark = Color3.fromRGB(56, 140, 98),
		Background = Color3.fromRGB(6, 12, 9),
		Header = Color3.fromRGB(4, 8, 6),
		Panel = Color3.fromRGB(10, 18, 14),
		Card = Color3.fromRGB(14, 24, 18),
		Field = Color3.fromRGB(5, 10, 7),
		Outline = Color3.fromRGB(30, 56, 42),
		Text = Color3.fromRGB(226, 240, 232),
		Muted = Color3.fromRGB(108, 142, 122),
		Dim = Color3.fromRGB(64, 92, 76),
		Dark = Color3.fromRGB(14, 24, 18),
		Badge = Color3.fromRGB(232, 245, 238),
		Sheen = Color3.fromRGB(190, 255, 220),
		WindowTransparency = 0,
		PanelTransparency = 0,
		CardTransparency = 0,
		FieldTransparency = 0,
		ScreenBlur = false,
	},
	Amethyst = {
		Accent = Color3.fromRGB(170, 110, 255),
		AccentDark = Color3.fromRGB(119, 77, 179),
		Background = Color3.fromRGB(10, 6, 14),
		Header = Color3.fromRGB(6, 4, 9),
		Panel = Color3.fromRGB(16, 10, 22),
		Card = Color3.fromRGB(22, 14, 30),
		Field = Color3.fromRGB(8, 5, 11),
		Outline = Color3.fromRGB(48, 30, 66),
		Text = Color3.fromRGB(232, 224, 245),
		Muted = Color3.fromRGB(128, 112, 155),
		Dim = Color3.fromRGB(82, 66, 108),
		Dark = Color3.fromRGB(20, 12, 28),
		Badge = Color3.fromRGB(240, 232, 250),
		Sheen = Color3.fromRGB(225, 200, 255),
		WindowTransparency = 0,
		PanelTransparency = 0,
		CardTransparency = 0,
		FieldTransparency = 0,
		ScreenBlur = false,
	},
}

---Map a Color3 to its theme role name.
local COLOR_ROLES = {
	{ ACCENT, "Accent" },
	{ ACCENT_DARK, "AccentDark" },
	{ BG, "Background" },
	{ HEADER, "Header" },
	{ PANEL, "Panel" },
	{ CARD, "Card" },
	{ FIELD, "Field" },
	{ OUTLINE, "Outline" },
	{ TEXT, "Text" },
	{ MUTED, "Muted" },
	{ DIM, "Dim" },
	{ DARK, "Dark" },
	{ BADGE, "Badge" },
}

local function roleFor(value)
	for _, pair in next, COLOR_ROLES do
		if value == pair[1] then
			return pair[2]
		end
	end
	return nil
end

---Register an instance property as theme-driven. ThemeRegistry is weak-keyed by
---object so entries for destroyed instances are collected automatically.
local function tprop(object, property, role, base)
	local list = Library.ThemeRegistry[object]
	if not list then
		list = {}
		Library.ThemeRegistry[object] = list
	end
	table.insert(list, { property, role, base })
end

---Read a theme color (live).
local function th(role)
	return Library.Theme[role]
end

---Tween with the animations toggle respected.
local function tween(object, seconds, props, style)
	if Library.Theme.Animations == false then
		for key, value in next, props do
			object[key] = value
		end
		return nil
	end
	local t = TweenService:Create(
		object,
		TweenInfo.new(seconds or 0.18, style or Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		props
	)
	t:Play()
	return t
end

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function assignProps(object, props)
	for key, value in next, props or {} do
		object[key] = value
		if typeof(value) == "Color3" then
			local role = roleFor(value)
			if role then
				object[key] = Library.Theme[role]
				tprop(object, key, role)
			end
		elseif key == "Font" and value == FONT then
			object.Font = Library.Theme.Font
			tprop(object, "Font", "Font")
		elseif key == "TextSize" and type(value) == "number" then
			object.TextSize = math.max(1, math.floor(value * Library.Theme.TextScale + 0.5))
			tprop(object, "TextSize", "TextScale", value)
		end
	end
end

local TRANSPARENCY_ROLES = {
	Window = "WindowTransparency",
	Header = "PanelTransparency",
	Panel = "PanelTransparency",
	Card = "CardTransparency",
	Field = "FieldTransparency",
}

local function create(class, props, transparencyRole)
	local object = type(class) == "string" and Instance.new(class) or class
	assignProps(object, props)
	if transparencyRole then
		object.BackgroundTransparency = Library.Theme[TRANSPARENCY_ROLES[transparencyRole]] or 0
		tprop(object, "BackgroundTransparency", transparencyRole)
	end
	return object
end

local function stroke(parent, color, thickness)
	return create("UIStroke", { Color = color or OUTLINE, Thickness = thickness or 1, Parent = parent })
end

local CORNER_RADIUS = 1 -- global cap; raise for rounder corners

local function corner(parent, radius)
	return create("UICorner", { CornerRadius = UDim.new(0, math.min(radius or CORNER_RADIUS, CORNER_RADIUS)), Parent = parent })
end

local function padding(parent, left, right, top, bottom)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or left or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or top or 0),
		Parent = parent,
	})
end

local function list(parent, gap)
	return create("UIListLayout", {
		Padding = UDim.new(0, gap or 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = parent,
	})
end

local function mklabel(parent, props)
	local object = create("TextLabel", {
		BackgroundTransparency = 1,
		Font = FONT,
		TextColor3 = TEXT,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = parent,
	})
	assignProps(object, props)
	return object
end

local function bold(object)
	local family = FONT_FAMILIES[tostring(Library.Theme.Font.Name)] or "RobotoMono"
	local ok = pcall(function()
		object.FontFace = Font.new(
			"rbxasset://fonts/families/" .. family .. ".json",
			Enum.FontWeight.Bold
		)
	end)
	if not ok then
		object.Font = Library.Theme.Font
	end
	Library.TitleLabels[object] = true
end

local function track(signal)
	table.insert(Library.Signals, signal)
	return signal
end

---4 L-shaped corner brackets on a frame; returns the 8 frames.
local function addBrackets(parent, color, len, thick)
	local L = len or 12
	local T = thick or 2
	local frames = {}
	local function piece(w, h, anchorX, x, anchorY, y)
		local f = create("Frame", {
			AnchorPoint = Vector2.new(anchorX, anchorY),
			BackgroundColor3 = color or ACCENT,
			BorderSizePixel = 0,
			Position = UDim2.new(anchorX, x, anchorY, y),
			Size = UDim2.fromOffset(w, h),
			Parent = parent,
		})
		table.insert(frames, f)
	end
	piece(L, T, 0, 0, 0, 0); piece(T, L, 0, 0, 0, 0)
	piece(L, T, 1, 0, 0, 0); piece(T, L, 1, 0, 0, 0)
	piece(L, T, 0, 0, 1, 0); piece(T, L, 0, 0, 1, 0)
	piece(L, T, 1, 0, 1, 0); piece(T, L, 1, 0, 1, 0)
	return frames
end

---Substance-style checkbox: accent fill + checkmark when on.
---@return table { Box = TextButton, Set = fn(on, instant) }
local function makeCheckbox(parent, props)
	props = props or {}
	local box = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = FIELD,
		BorderSizePixel = 0,
		Text = "",
		Parent = parent,
	}, "Field")
	for key, value in next, props do
		box[key] = value
	end
	corner(box, 2)
	stroke(box)
	local markScale = create("UIScale", { Scale = 0 })
	local mark = mklabel(box, {
		Size = UDim2.fromScale(1, 1),
		Text = "✓",
		TextColor3 = DARK,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	markScale.Parent = mark
	local state = false
	local api = { Box = box }
	function api.Set(on, instant)
		state = on == true
		if instant or Library.Theme.Animations == false then
			box.BackgroundColor3 = state and th("Accent") or th("Field")
			markScale.Scale = state and 1 or 0
		else
			tween(box, 0.16, { BackgroundColor3 = state and th("Accent") or th("Field") })
			tween(markScale, 0.22, { Scale = state and 1 or 0 }, Enum.EasingStyle.Back)
		end
	end
	function api.Get()
		return state
	end
	return api
end

---Baseline transparency cache so re-fades restore the right target; wiped by ApplyTheme.
local fadeBase = setmetatable({}, { __mode = "k" })

local FADE_PROPS = {
	"BackgroundTransparency",
	"TextTransparency",
	"TextStrokeTransparency",
	"ImageTransparency",
	"Transparency",
}

local function collectFade(object, out)
	for _, prop in next, FADE_PROPS do
		local ok, value = pcall(function()
			return object[prop]
		end)
		if ok and type(value) == "number" then
			local store = fadeBase[object]
			if not store then
				store = {}
				fadeBase[object] = store
			end
			if store[prop] == nil then
				store[prop] = value
			end
			table.insert(out, { object = object, prop = prop, base = store[prop] })
		end
	end
end

---Fade an element's whole subtree back to its baseline transparency.
local function fadeIn(root, seconds, delaySeconds)
	if Library.Theme.Animations == false then
		return
	end
	local targets = {}
	collectFade(root, targets)
	for _, descendant in next, root:GetDescendants() do
		collectFade(descendant, targets)
	end
	for _, target in next, targets do
		if target.base < 1 then
			pcall(function()
				target.object[target.prop] = 1
			end)
		end
	end
	local function run()
		for _, target in next, targets do
			if target.base < 1 then
				tween(target.object, seconds, { [target.prop] = target.base })
			end
		end
	end
	if delaySeconds and delaySeconds > 0 then
		task.delay(delaySeconds, run)
	else
		run()
	end
end

---Cards that host their controls through a UIListLayout get an inner content
---frame so the sheen overlay (a GuiObject) is never counted by that layout.
local cardContent = setmetatable({}, { __mode = "k" })

---Light sweep across a card. Implemented as a clipped overlay band rather than a
---UIGradient: gradients multiply the background color, so they cannot brighten
---a dark card — the old gradient sweep rendered completely invisible.
local function attachSheen(card)
	local overlay = nil
	track(card.MouseEnter:Connect(function()
		if Library.Theme.Animations == false then
			return
		end
		if not overlay or not overlay.Parent then
			overlay = create("Frame", {
				Name = "SheenOverlay",
				Active = false,
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				ZIndex = 50,
				Parent = card,
			})
			corner(overlay, 2)
		end
		-- Offset size (not scale) so the card's AutomaticSize never feeds back.
		overlay.Size = UDim2.fromOffset(card.AbsoluteSize.X, card.AbsoluteSize.Y)

		local band = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = th("Sheen") or Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(-0.35, 0.5),
			Rotation = 65,
			Size = UDim2.new(0.35, 0, 3, 0),
			ZIndex = 50,
			Parent = overlay,
		})
		create("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.35, 0.82),
				NumberSequenceKeypoint.new(0.5, 0.62),
				NumberSequenceKeypoint.new(0.65, 0.82),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Parent = band,
		})
		local anim = tween(band, 0.55, { Position = UDim2.fromScale(1.35, 0.5) }, Enum.EasingStyle.Quad)
		if anim then
			anim.Completed:Connect(function()
				band:Destroy()
			end)
		else
			band:Destroy()
		end
	end))
end

---Weak-keyed map of hover-glow images -> state { card, alpha, hovered, t }.
---Fallback entries (UIStroke) map to `true`.
Library._hoverGlows = setmetatable({}, { __mode = "k" })

local resolveAsset, resolveIcon -- defined in the theme section; used by AddTab + hover glow

local glowAsset = nil
local glowAssetTried = false
local glowLoopConn = nil

local function getGlowAsset()
	if not glowAssetTried then
		glowAssetTried = true
		glowAsset = resolveIcon("hoverglow")
	end
	return glowAsset
end

---One render connection drives every glow. Hover fades the halo in while the
---ring eases outward from the center to the card edge (the ripple); leaving
---fades it back out. The image is a child of the card, so hiding, scrolling,
---or destroying the card takes the glow with it.
local function ensureGlowLoop()
	if glowLoopConn then
		if glowLoopConn.Connected ~= false then
			return
		end
		glowLoopConn = nil -- disconnected on unload; reconnect below
	end
	glowLoopConn = track(RunService.RenderStepped:Connect(function(dt)
		for glow, st in next, Library._hoverGlows do
			if type(st) == "table" then
				pcall(function()
					local card = st.card
					if card.Parent == nil then
						glow:Destroy()
						Library._hoverGlows[glow] = nil
						return
					end
					local target = (st.hovered and Library.Theme.HoverGlowEnabled ~= false) and 1 or 0
					st.alpha = st.alpha + (target - st.alpha) * math.min(dt * 8, 1)
					if st.alpha <= 0.02 then
						glow.Visible = false
						st.t = 0
						return
					end
					st.t = st.t + dt
					-- Ripple: ring eases from ~center out to the card edge, then
					-- settles into a subtle breathe.
					local w = math.min(st.t / 0.55, 1)
					local ease = 1 - (1 - w) * (1 - w) * (1 - w)
					local scale = 0.55 + ease * 0.7 + math.sin(st.t * 2) * 0.015
					glow.Visible = true
					glow.Size = UDim2.fromScale(scale, scale)
					glow.ImageTransparency = 1 - st.alpha * 0.85
				end)
			end
		end
	end))
end

---Soft radial halo that ripples out to the card edges on hover. Returns true
---when the halo was attached so callers can skip the legacy sheen; falls back
---to a thin border stroke (and false) when image assets are unavailable.
local function attachHoverGlow(card)
	local asset = getGlowAsset()

	if not asset then
		-- Fallback: thin border stroke when image assets are unavailable.
		local glow = create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = th("HoverGlow") or ACCENT,
			Thickness = 1.5,
			Transparency = 1,
			Parent = card,
		})
		tprop(glow, "Color", "HoverGlow")
		Library._hoverGlows[glow] = true
		track(card.MouseEnter:Connect(function()
			if Library.Theme.HoverGlowEnabled == false then
				return
			end
			tween(glow, 0.22, { Transparency = 0.35 })
		end))
		track(card.MouseLeave:Connect(function()
			tween(glow, 0.3, { Transparency = 1 })
		end))
		return false
	end

	-- Clip so the halo can't bleed outside the card (also inherits hiding).
	pcall(function()
		card.ClipsDescendants = true
	end)

	local glow = create("ImageLabel", {
		Active = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = asset,
		ImageColor3 = th("HoverGlow") or ACCENT,
		ImageTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 1,
		Parent = card,
	})
	tprop(glow, "ImageColor3", "HoverGlow")

	local st = { card = card, alpha = 0, hovered = false, t = 0 }
	Library._hoverGlows[glow] = st

	track(card.MouseEnter:Connect(function()
		st.hovered = true
		st.t = 0 -- replay the wave from the center every hover
	end))
	track(card.MouseLeave:Connect(function()
		st.hovered = false
	end))
	ensureGlowLoop()
	return true
end

---Format a KeyCode-ish name for badges: RightShift -> "RIGHT SHIFT", MouseButton1 -> "MB1".
local function formatKey(name)
	if not name or name == "None" or name == "N/A" or name == "" then
		return "None"
	end
	if name == "MouseButton1" then
		return "MB1"
	end
	if name == "MouseButton2" then
		return "MB2"
	end
	if name == "MouseButton3" then
		return "MB3"
	end
	local pretty = tostring(name):gsub("(%u)", " %1"):gsub("^%s", "")
	return pretty:upper()
end

local function badgeWidth(name)
	return math.max(34, #formatKey(name) * 7 + 16)
end

local function to255(v)
	return math.floor(v * 255 + 0.5)
end

local function fs()
	return {
		isfolder = env.isfolder or _G.isfolder,
		makefolder = env.makefolder or _G.makefolder,
		isfile = env.isfile or _G.isfile,
		readfile = env.readfile or _G.readfile,
		writefile = env.writefile or _G.writefile,
		listfiles = env.listfiles or _G.listfiles,
		delfile = env.delfile or _G.delfile,
	}
end

--------------------------------------------------------------------------------
-- Control base
--------------------------------------------------------------------------------

local function installControlMethods(control)
	function control:OnChanged(callback)
		table.insert(self.Changed, callback)
		return self
	end
	function control:SetValue(value)
		self.Value = value
		if self.Display then
			self:Display()
		end
		if self.Callback then
			pcall(self.Callback, value)
		end
		for _, callback in next, self.Changed do
			pcall(callback, value)
		end
		return self
	end
	function control:SetValues(values)
		self.Values = values or {}
		if self.Value ~= nil then
			if self.Multi then
				for value in next, self.Value do
					if not table.find(self.Values, value) then
						self.Value[value] = nil
					end
				end
			elseif not table.find(self.Values, self.Value) then
				self.Value = nil
			end
		end
		if self.Display then
			self:Display()
		end
		return self
	end
	return control
end

local function newControl(id, info, kind)
	local control = installControlMethods({
		Value = info.Default,
		Values = info.Values or {},
		Callback = info.Callback,
		Type = kind,
		Changed = {},
	})
	if kind == "toggle" and id then
		Toggles[id] = control
	elseif id then
		Options[id] = control
	end
	table.insert(Library.Controls, control)
	return control
end

--------------------------------------------------------------------------------
-- Popups (dropdown lists, color pickers) rendered above everything
--------------------------------------------------------------------------------

local Popups, PopupOverlay

---Connections belonging to the currently-open popup; disconnected on close so
---every dropdown/color-picker open doesn't leak into Library.Signals forever.
local popupSignals = {}

local function trackPopup(signal)
	table.insert(popupSignals, signal)
	return signal
end

local function ensurePopups()
	if Popups then
		return
	end
	Popups = create("Frame", {
		Name = "Popups",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = Library.ScreenGui,
	})
	PopupOverlay = create("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		Visible = false,
		ZIndex = 99,
		Parent = Popups,
	})
	track(PopupOverlay.MouseButton1Click:Connect(function()
		Library:ClosePopup()
	end))
end

function Library:ClosePopup()
	for _, signal in next, popupSignals do
		pcall(function()
			signal:Disconnect()
		end)
	end
	table.clear(popupSignals)

	if self.ActivePopup then
		self.ActivePopup:Destroy()
		self.ActivePopup = nil
	end
	if PopupOverlay then
		PopupOverlay.Visible = false
	end
end

local function openPopupFrame(anchor, width, height)
	Library:ClosePopup()
	ensurePopups()
	PopupOverlay.Visible = true
	local frame = create("Frame", {
		BackgroundColor3 = CARD,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(anchor.AbsolutePosition.X, anchor.AbsolutePosition.Y + anchor.AbsoluteSize.Y + 4),
		Size = UDim2.fromOffset(width or anchor.AbsoluteSize.X, height or 100),
		ZIndex = 100,
		Parent = Popups,
	}, "Card")
	corner(frame, 2)
	stroke(frame)
	Library.ActivePopup = frame
	return frame
end

local function popupLabel(parent, props)
	props = props or {}
	props.ZIndex = props.ZIndex or 101
	return mklabel(parent, props)
end

--------------------------------------------------------------------------------
-- Keybind list frame
--------------------------------------------------------------------------------

local function rebuildKeybindList()
	local frame = Library.KeybindListFrame
	if not frame then
		return
	end
	local listFrame = frame:FindFirstChild("Entries")
	if not listFrame then
		return
	end
	for _, child in next, listFrame:GetChildren() do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	local shown = 0
	for _, picker in next, Library.KeyPickers do
		local bound = picker.Value and picker.Value ~= "None" and picker.Value ~= "N/A"
		local isFeature = picker.LinkedToggle ~= nil or picker.ShowInList == true
		local on = picker.LinkedToggle and picker.LinkedToggle.Value == true
		if bound and isFeature and (not Library.KeybindListActiveOnly or on) then
			shown = shown + 1
			mklabel(listFrame, {
				LayoutOrder = shown,
				Size = UDim2.new(1, 0, 0, 16),
				Text = "  [" .. formatKey(picker.Value) .. "]  " .. (picker.Text or ""),
				TextColor3 = on and th("Accent") or th("Muted"),
				TextSize = 11,
			})
		end
	end
end

---Re-render the keybind list (bound by feature toggles and the UI filter).
Library.RefreshKeybinds = rebuildKeybindList

--------------------------------------------------------------------------------
-- Container (settings grid)
--------------------------------------------------------------------------------

local Container = {}
Container.__index = Container

---Rough text height estimate for column balancing (title 13px ≈ 20 chars, desc 11px ≈ 24 chars).
local function textLines(text, perLine)
	return math.max(1, math.ceil(#tostring(text) / perLine))
end

---Create an auto-height setting card in the currently shortest grid column.
---Children are stacked by a UIListLayout: title, description, then the control area.
---@param areaHeight number height of the control strip at the bottom (0 for none)
---@param title string?
---@param description string?
---@return Frame card, Frame area
function Container:_card(areaHeight, title, description)
	local heights = self.Heights
	local shortest = 1
	for index = 2, #self.Columns do
		if heights[index] < heights[shortest] then
			shortest = index
		end
	end
	local card = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = CARD,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = self.Columns[shortest],
	}, "Card")
	corner(card, 2)

	-- Inner layout host: keeps the UIListLayout off `card` so overlay children
	-- (the sheen sweep) don't get counted as rows.
	local content = create("Frame", {
		Name = "Content",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = card,
	})
	padding(content, 10, 10, 10, 10)
	list(content, 3)
	cardContent[card] = content

	local order = 0
	local titleLabel
	if title and #tostring(title) > 0 then
		order = order + 1
		titleLabel = mklabel(content, {
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = order,
			Size = UDim2.new(1, 0, 0, 0),
			Text = title,
			TextSize = 13,
			TextWrapped = true,
		})
		bold(titleLabel)
	end
	if description and #tostring(description) > 0 then
		order = order + 1
		mklabel(content, {
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = order,
			Size = UDim2.new(1, 0, 0, 0),
			Text = description,
			TextColor3 = MUTED,
			TextSize = 11,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
	end
	local area
	if areaHeight > 0 then
		order = order + 1
		area = create("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = order,
			Size = UDim2.new(1, 0, 0, areaHeight),
			Parent = content,
		})
	end

	local estimate = 20
		+ (title and #tostring(title) > 0 and textLines(title, 20) * 16 or 0)
		+ (description and #tostring(description) > 0 and textLines(description, 24) * 14 or 0)
		+ (order > 1 and (order - 1) * 3 or 0)
		+ areaHeight
	heights[shortest] = heights[shortest] + estimate + 8
	self._controlCount = (self._controlCount or 0) + 1
	if self._placeholder then
		self._placeholder.Visible = false
	end
	if not attachHoverGlow(card) then
		attachSheen(card)
	end
	if titleLabel then
		track(card.MouseEnter:Connect(function()
			tween(titleLabel, 0.18, { TextColor3 = th("Accent") })
		end))
		track(card.MouseLeave:Connect(function()
			tween(titleLabel, 0.18, { TextColor3 = th("Text") })
		end))
	end
	if self.OnCard then
		self.OnCard(card)
	end
	return card, area
end

function Container:AddDivider()
	return self
end

function Container:AddLabel(text)
	text = tostring(text)
	local long = #text > 28
	local card = self:_card(0)
	local host = cardContent[card] or card
	local object = newControl(nil, { Default = text }, "label")
	object.Label = mklabel(host, {
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 0),
		Text = text,
		TextColor3 = long and MUTED or TEXT,
		TextSize = long and 11 or 13,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
	})
	if not long then
		bold(object.Label)
	end
	local area
	object.Card = card
	function object:SetText(value)
		self.Value = value
		if self.Label then
			self.Label.Text = value
		end
	end
	function object:AddKeyPicker(keyId, info)
		if not area then
			area = create("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 22),
				Parent = host,
			})
		end
		local picker = self.Parent:_makeKeyPicker(keyId, info or {}, nil)
		picker.Auto = true
		picker:Display()
		picker.Badge.Parent = area
		picker.Badge.Position = UDim2.new(1, 0, 0, 2)
		return picker
	end
	object.Parent = self
	return object
end

function Container:AddButton(info, callback)
	if type(info) ~= "table" then
		info = { Text = info, Func = callback }
	end
	local card, area = self:_card(32, nil, info.Tooltip)
	local btn = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = FIELD,
		BorderSizePixel = 0,
		Font = FONT,
		Position = UDim2.new(0, 0, 0, 2),
		Size = UDim2.new(1, 0, 0, 28),
		Text = info.Text or "",
		TextColor3 = TEXT,
		TextSize = 12,
		Parent = area,
	}, "Field")
	corner(btn, 2)
	stroke(btn)
	local brackets
	track(btn.MouseEnter:Connect(function()
		if brackets then
			for _, f in next, brackets do
				f:Destroy()
			end
		end
		brackets = addBrackets(btn, ACCENT, 6, 1)
	end))
	track(btn.MouseLeave:Connect(function()
		if brackets then
			for _, f in next, brackets do
				f:Destroy()
			end
			brackets = nil
		end
	end))
	local confirming = false
	track(btn.MouseButton1Click:Connect(function()
		if info.DoubleClick then
			if confirming then
				confirming = false
				btn.Text = info.Text or ""
				if info.Func then
					task.spawn(info.Func)
				end
			else
				confirming = true
				btn.Text = "CONFIRM?"
				task.delay(0.6, function()
					if confirming then
						confirming = false
						btn.Text = info.Text or ""
					end
				end)
			end
		elseif info.Func then
			task.spawn(info.Func)
		end
	end))
	local chain = { Parent = self }
	function chain:AddButton(nextInfo, nextCallback)
		return self.Parent:AddButton(nextInfo, nextCallback)
	end
	return chain
end

function Container:AddToggle(id, info)
	info = info or {}
	local card, area = self:_card(26, info.Text or id, info.Tooltip or info.Description)
	local control = newControl(id, info, "toggle")
	control.Card = card
	-- full-area hit zone beneath the checkbox
	local hit = create("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		Parent = area,
	})
	local checkbox = makeCheckbox(area, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 5),
		Size = UDim2.fromOffset(16, 16),
	})
	function control:Display()
		checkbox.Set(self.Value == true)
	end
	track(checkbox.Box.MouseButton1Click:Connect(function()
		control:SetValue(not control.Value)
	end))
	track(hit.MouseButton1Click:Connect(function()
		control:SetValue(not control.Value)
	end))
	function control:AddKeyPicker(keyId, keyInfo)
		if self.AutoPicker then
			removePicker(self.AutoPicker)
			self.AutoPicker = nil
		end
		local picker = self.Parent:_makeKeyPicker(keyId, keyInfo or {}, self)
		picker.Auto = true
		picker:Display()
		picker.Badge.Parent = area
		picker.Badge.Position = UDim2.new(1, -24, 0, 4)
		return picker
	end
	function control:AddColorPicker(colorId, colorInfo)
		return self.Parent:AddColorPicker(colorId, colorInfo)
	end
	control.Parent = self
	control:Display()
	-- "[ + ]" slot: let users bind a key to any toggle from the UI itself.
	if id and (not info or info.NoKeybind ~= true) then
		self:_autoKeybind(control, id, info.Text or id, area, UDim2.new(1, -24, 0, 4))
	end
	return control
end

function Container:AddSlider(id, info)
	info = info or {}
	local card, area = self:_card(48, info.Text or id, info.Tooltip or info.Description)
	local control = newControl(id, info, "slider")
	control.Value = tonumber(info.Default) or tonumber(info.Min) or 0
	local min, max = tonumber(info.Min) or 0, tonumber(info.Max) or 100
	local factor = 10 ^ (info.Rounding or 0)
	local function clampValue(v)
		v = tonumber(v) or min
		v = math.floor(v * factor + 0.5) / factor
		return math.clamp(v, min, max)
	end
	local trackBar = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = FIELD,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 4),
		Size = UDim2.new(1, 0, 0, 5),
		Text = "",
		Parent = area,
	}, "Field")
	corner(trackBar, 2)
	local fill = create("Frame", {
		BackgroundColor3 = ACCENT,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		Parent = trackBar,
	})
	corner(fill, 2)
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = BADGE,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(6, 12),
		Parent = trackBar,
	})
	corner(knob, 1)
	local field = create("TextBox", {
		BackgroundColor3 = FIELD,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = FONT,
		Position = UDim2.new(0, 0, 0, 18),
		Size = UDim2.new(1, 0, 0, 24),
		TextColor3 = TEXT,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = area,
	}, "Field")
	corner(field, 2)
	stroke(field)
	padding(field, 8)
	function control:Display()
		local alpha = max > min and math.clamp((self.Value - min) / (max - min), 0, 1) or 0
		if self._dragging or Library.Theme.Animations == false then
			fill.Size = UDim2.new(alpha, 0, 1, 0)
			knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		else
			tween(fill, 0.06, { Size = UDim2.new(alpha, 0, 1, 0) })
			tween(knob, 0.06, { Position = UDim2.new(alpha, 0, 0.5, 0) })
		end
		field.Text = "~$ " .. tostring(self.Value) .. (info.Suffix or "")
	end
	local baseSetValue = control.SetValue
	function control:SetValue(value)
		return baseSetValue(self, clampValue(value))
	end
	local function setFromInput(input)
		local alpha =
			math.clamp((input.Position.X - trackBar.AbsolutePosition.X) / math.max(trackBar.AbsoluteSize.X, 1), 0, 1)
		control:SetValue(min + (max - min) * alpha)
	end
	track(trackBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			control._dragging = true
			setFromInput(input)
		end
	end))
	track(trackBar.InputChanged:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
		then
			setFromInput(input)
		end
	end))
	track(UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			control._dragging = false
		end
	end))
	track(field.FocusLost:Connect(function()
		local number = tonumber(tostring(field.Text):gsub("[^%d%.%-]", ""))
		if number then
			control:SetValue(number)
		else
			control:Display()
		end
	end))
	control:Display()
	return control
end

function Container:AddInput(id, info)
	info = info or {}
	local card, area = self:_card(30, info.Text or id, info.Tooltip or info.Description)
	local control = newControl(id, { Default = tostring(info.Default or ""), Callback = info.Callback }, "input")
	local wrap = create("Frame", {
		BackgroundColor3 = FIELD,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 2),
		Size = UDim2.new(1, 0, 0, 26),
		Parent = area,
	}, "Field")
	corner(wrap, 2)
	stroke(wrap)
	mklabel(wrap, {
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(0, 24, 1, 0),
		Text = "~$",
		TextColor3 = MUTED,
		TextSize = 11,
	})
	local box = create("TextBox", {
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		Font = FONT,
		PlaceholderColor3 = DIM,
		PlaceholderText = info.Placeholder or "",
		Position = UDim2.fromOffset(32, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Text = tostring(info.Default or ""),
		TextColor3 = TEXT,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = wrap,
	})
	function control:Display()
		box.Text = tostring(self.Value or "")
	end
	if info.Numeric then
		track(box:GetPropertyChangedSignal("Text"):Connect(function()
			local filtered = box.Text:gsub("[^%-%d%.]", "")
			if filtered ~= box.Text then
				box.Text = filtered
			end
		end))
	end
	track(box.FocusLost:Connect(function()
		control:SetValue(box.Text)
	end))
	control:Display()
	return control
end

function Container:AddDropdown(id, info)
	info = info or {}
	local card, area = self:_card(30, info.Text or id, info.Tooltip or info.Description)
	local control = newControl(id, info, "dropdown")
	control.Multi = info.Multi == true
	if type(control.Value) == "number" then
		control.Value = control.Values[control.Value]
	end
	if info.Multi and type(control.Value) ~= "table" then
		control.Value = control.Value ~= nil and { [control.Value] = true } or {}
	end
	local field = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = FIELD,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 2),
		Size = UDim2.new(1, 0, 0, 26),
		Text = "",
		Parent = area,
	}, "Field")
	corner(field, 2)
	stroke(field)
	padding(field, 8)
	local fieldText = mklabel(field, {
		Size = UDim2.new(1, -22, 1, 0),
		Text = "",
		TextSize = 11,
	})
	mklabel(field, {
		Position = UDim2.new(1, -18, 0, 0),
		Size = UDim2.new(0, 14, 1, 0),
		Text = "v",
		TextColor3 = MUTED,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
	})
	local function isSelected(value)
		if info.Multi then
			return control.Value ~= nil and control.Value[value] == true
		end
		return control.Value == value
	end
	function control:Display()
		if info.Multi then
			local chosen = {}
			for value in next, self.Value or {} do
				table.insert(chosen, value)
			end
			table.sort(chosen)
			fieldText.Text = #chosen > 0 and ("{ " .. table.concat(chosen, ", ") .. " }") or "{ None }"
		else
			fieldText.Text = self.Value ~= nil and ("{ " .. tostring(self.Value) .. " }") or "{ None }"
		end
	end
	track(field.MouseButton1Click:Connect(function()
		local rows = math.min(#control.Values, 8)
		if rows == 0 then
			return
		end
		local popup = openPopupFrame(field, field.AbsoluteSize.X, rows * 24)
		local scroll = create("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.fromOffset(0, #control.Values * 24),
			ScrollBarThickness = 2,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 101,
			Parent = popup,
		})
		list(scroll, 0)
		for index, value in next, control.Values do
			local row = create("TextButton", {
				AutoButtonColor = false,
				BackgroundColor3 = CARD,
				BorderSizePixel = 0,
				LayoutOrder = index,
				Size = UDim2.new(1, 0, 0, 24),
				Text = "",
				ZIndex = 101,
				Parent = scroll,
			})
			local bar = create("Frame", {
				BackgroundColor3 = ACCENT,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(2, 24),
				Visible = isSelected(value),
				ZIndex = 102,
				Parent = row,
			})
			local rowLabel = popupLabel(row, {
				Position = UDim2.fromOffset(10, 0),
				Size = UDim2.new(1, -14, 1, 0),
				Text = tostring(value),
				TextColor3 = isSelected(value) and th("Text") or th("Muted"),
				TextSize = 11,
				ZIndex = 102,
			})
			trackPopup(row.MouseButton1Click:Connect(function()
				if info.Multi then
					local set = control.Value or {}
					set[value] = not set[value] and true or nil
					control:SetValue(set)
					local on = isSelected(value)
					bar.Visible = on
					rowLabel.TextColor3 = on and th("Text") or th("Muted")
				else
					if isSelected(value) and info.AllowNull then
						control:SetValue(nil)
					else
						control:SetValue(value)
					end
					Library:ClosePopup()
				end
			end))
		end
	end))
	control:Display()
	return control
end

--------------------------------------------------------------------------------
-- KeyPicker
--------------------------------------------------------------------------------

local function makeBadge()
	local badge = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		AutoButtonColor = false,
		BackgroundColor3 = BADGE,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(60, 18),
		Text = "",
	})
	corner(badge, 2)
	local badgeText = mklabel(badge, {
		Size = UDim2.fromScale(1, 1),
		Text = "",
		TextColor3 = DARK,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	return badge, badgeText
end

---Fully unregister a keypicker (its badge may be destroyed).
local function removePicker(picker)
	picker.Display = nil
	if picker.Badge then
		picker.Badge:Destroy()
		picker.Badge = nil
	end
	for index, p in next, Library.KeyPickers do
		if p == picker then
			table.remove(Library.KeyPickers, index)
			break
		end
	end
	for index, c in next, Library.Controls do
		if c == picker then
			table.remove(Library.Controls, index)
			break
		end
	end
end

function Container:_makeKeyPicker(id, info, linkedToggle)
	info = info or {}
	local default = info.Default
	if default == "N/A" or default == nil or default == "" then
		default = "None"
	end
	local control = newControl(id, { Default = default, Callback = info.Callback }, "keypicker")
	control.Mode = info.Mode or "Toggle"
	control.Text = info.Text
	control.LinkedToggle = linkedToggle
	if linkedToggle and linkedToggle.OnChanged then
		linkedToggle:OnChanged(rebuildKeybindList)
	end
	control.SyncToggle = info.SyncToggleState == true
	control.Auto = info.Auto == true
	control.ShowInList = info.ShowInList == true
	control.Held = false
	table.insert(Library.KeyPickers, control)

	local badge, badgeText = makeBadge()
	control.Badge = badge
	control.BadgeText = badgeText
	function control:Display()
		local empty = self.Value == nil or self.Value == "None" or self.Value == "N/A"
		if self.Auto and empty then
			badgeText.Text = "+"
			badgeText.TextColor3 = th("Muted")
			badge.BackgroundTransparency = 0
			badge.BackgroundColor3 = th("Field")
			badge.Size = UDim2.fromOffset(22, 18)
			if not badge:FindFirstChildOfClass("UIStroke") then
				stroke(badge, DIM, 1)
			end
			badge:FindFirstChildOfClass("UIStroke").Color = th("Outline")
		else
			local badgeBg = th("Badge")
			local luminance = 0.299 * badgeBg.R + 0.587 * badgeBg.G + 0.114 * badgeBg.B
			badgeText.Text = formatKey(self.Value)
			badgeText.TextColor3 = luminance > 0.5 and th("Dark") or th("Text")
			badge.BackgroundTransparency = 0
			badge.BackgroundColor3 = badgeBg
			badge.Size = UDim2.fromOffset(badgeWidth(self.Value), 18)
			local s = badge:FindFirstChildOfClass("UIStroke")
			if s then
				s:Destroy()
			end
		end
		rebuildKeybindList()
	end
	track(badge.MouseButton1Click:Connect(function()
		badgeText.Text = "..."
		control.Capturing = true
	end))
	track(badge.MouseEnter:Connect(function()
		local s = badge:FindFirstChildOfClass("UIStroke") or stroke(badge, DIM, 1)
		s.Color = th("Accent")
	end))
	track(badge.MouseLeave:Connect(function()
		if not control.Capturing then
			control:Display()
		end
	end))
	function control:GetState()
		if self.Mode == "Hold" then
			return self.Held == true
		end
		if self.LinkedToggle then
			return self.LinkedToggle.Value == true
		end
		return self.Held == true
	end
	control:Display()
	return control
end

---Attach a "[ + ]" ghost badge that lets the user bind a key to a feature themselves.
---Creates a real keypicker under id "<id>Key" so the bind persists in configs.
---@param control table the toggle/module it drives
---@param id string base option id
---@param name string display name
---@param parent Instance badge parent
---@param position UDim2
function Container:_autoKeybind(control, id, name, parent, position)
	local keyId = id .. "Key"
	local picker = self:_makeKeyPicker(keyId, {
		Default = "None",
		Text = name,
		Mode = "Toggle",
		SyncToggleState = true,
		Auto = true,
	}, control)
	picker.Badge.Parent = parent
	picker.Badge.Position = position
	control.AutoPicker = picker
	return picker
end

function Container:AddKeyPicker(id, info)
	info = info or {}
	local picker = self:_makeKeyPicker(id, info, nil)
	if info.Text then
		picker.Auto = true
		picker:Display()
		local _, area = self:_card(24, info.Text, info.Tooltip or info.Description)
		picker.Badge.Parent = area
		picker.Badge.Position = UDim2.new(1, 0, 0, 3)
	else
		picker.Badge:Destroy()
		picker.Badge = nil
	end
	return picker
end

-- Global key handling for pickers.
local function pickerMatches(picker, keyName)
	return picker.Value ~= nil and picker.Value ~= "None" and picker.Value ~= "N/A" and picker.Value == keyName
end

local function inputKeyName(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		return input.KeyCode.Name
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		return "MouseButton1"
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		return "MouseButton2"
	end
	return nil
end

track(UIS.InputBegan:Connect(function(input, processed)
	for _, picker in next, Library.KeyPickers do
		if picker.Capturing then
			picker.Capturing = false
			if input.KeyCode == Enum.KeyCode.Escape then
				picker:SetValue("None")
			else
				local name = inputKeyName(input)
				if name then
					picker:SetValue(name)
				end
			end
			return
		end
	end
	if processed then
		return
	end
	local keyName = inputKeyName(input)
	if not keyName then
		return
	end
	for _, picker in next, Library.KeyPickers do
		if pickerMatches(picker, keyName) then
			picker.Held = true
			if picker.Mode == "Hold" then
				if picker.SyncToggle and picker.LinkedToggle then
					picker.LinkedToggle:SetValue(true)
				end
			elseif picker.SyncToggle and picker.LinkedToggle then
				picker.LinkedToggle:SetValue(not picker.LinkedToggle.Value)
			elseif picker.Callback then
				pcall(picker.Callback, true)
			end
		end
	end
end))

track(UIS.InputEnded:Connect(function(input)
	local keyName = inputKeyName(input)
	if not keyName then
		return
	end
	for _, picker in next, Library.KeyPickers do
		if pickerMatches(picker, keyName) then
			picker.Held = false
			if picker.Mode == "Hold" and picker.SyncToggle and picker.LinkedToggle then
				picker.LinkedToggle:SetValue(false)
			end
		end
	end
end))

--------------------------------------------------------------------------------
-- ColorPicker
--------------------------------------------------------------------------------

function Container:AddColorPicker(id, info)
	info = info or {}
	local _, area = self:_card(26, info.Text or id, info.Tooltip or info.Description)
	local control = newControl(id, info, "color")
	control.Value = info.Default or ACCENT
	local swatch = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		AutoButtonColor = false,
		BackgroundColor3 = control.Value,
		BorderSizePixel = 0,
		Position = UDim2.new(1, 0, 0, 4),
		Size = UDim2.fromOffset(28, 18),
		Text = "",
		Parent = area,
	})
	corner(swatch, 2)
	stroke(swatch)
	function control:Display()
		swatch.BackgroundColor3 = self.Value
	end
	track(swatch.MouseButton1Click:Connect(function()
		local popup = openPopupFrame(swatch, 190, 136)
		local comps = { "R", "G", "B" }
		local current = { to255(control.Value.R), to255(control.Value.G), to255(control.Value.B) }
		local preview, hexBox
		local function apply()
			control:SetValue(Color3.fromRGB(current[1], current[2], current[3]))
			if preview then
				preview.BackgroundColor3 = control.Value
			end
			if hexBox then
				hexBox.Text = string.format("#%02X%02X%02X", current[1], current[2], current[3])
			end
		end
		for i = 1, 3 do
			popupLabel(popup, {
				Position = UDim2.fromOffset(10, 8 + (i - 1) * 28),
				Size = UDim2.fromOffset(14, 16),
				Text = comps[i],
				TextSize = 11,
			})
			local bar = create("TextButton", {
				AutoButtonColor = false,
				BackgroundColor3 = FIELD,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(28, 12 + (i - 1) * 28),
				Size = UDim2.new(1, -80, 0, 8),
				Text = "",
				ZIndex = 101,
				Parent = popup,
			})
			corner(bar, 2)
			local fillBar = create("Frame", {
				BackgroundColor3 = ACCENT,
				BorderSizePixel = 0,
				Size = UDim2.new(current[i] / 255, 0, 1, 0),
				ZIndex = 102,
				Parent = bar,
			})
			corner(fillBar, 2)
			local valueLabel = popupLabel(popup, {
				Position = UDim2.new(1, -44, 0, 8 + (i - 1) * 28),
				Size = UDim2.fromOffset(34, 16),
				Text = tostring(current[i]),
				TextColor3 = MUTED,
				TextSize = 10,
			})
			local function setFrom(input)
				local alpha =
					math.clamp((input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
				current[i] = math.floor(alpha * 255 + 0.5)
				fillBar.Size = UDim2.new(alpha, 0, 1, 0)
				valueLabel.Text = tostring(current[i])
				apply()
			end
			trackPopup(bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					setFrom(input)
				end
			end))
			trackPopup(bar.InputChanged:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseMovement
					and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
				then
					setFrom(input)
				end
			end))
		end
		hexBox = create("TextBox", {
			BackgroundColor3 = FIELD,
			BorderSizePixel = 0,
			ClearTextOnFocus = false,
			Font = FONT,
			Position = UDim2.fromOffset(10, 100),
			Size = UDim2.new(1, -64, 0, 22),
			Text = string.format("#%02X%02X%02X", current[1], current[2], current[3]),
			TextColor3 = TEXT,
			TextSize = 11,
			ZIndex = 101,
			Parent = popup,
		})
		corner(hexBox, 2)
		stroke(hexBox)
		preview = create("Frame", {
			BackgroundColor3 = control.Value,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -46, 0, 100),
			Size = UDim2.fromOffset(36, 22),
			ZIndex = 101,
			Parent = popup,
		})
		corner(preview, 2)
		stroke(preview)
		trackPopup(hexBox.FocusLost:Connect(function()
			local hex = tostring(hexBox.Text):gsub("#", "")
			if #hex == 6 then
				local r = tonumber(hex:sub(1, 2), 16)
				local g = tonumber(hex:sub(3, 4), 16)
				local b = tonumber(hex:sub(5, 6), 16)
				if r and g and b then
					current = { r, g, b }
					apply()
				end
			end
		end))
	end))
	control:Display()
	return control
end

--------------------------------------------------------------------------------
-- DependencyBox
--------------------------------------------------------------------------------

function Container:AddDependencyBox()
	local box = setmetatable({
		Columns = self.Columns,
		Heights = self.Heights,
		Parent = self,
		_cards = {},
	}, Container)
	function box.OnCard(card)
		table.insert(box._cards, card)
	end
	function box:SetupDependencies(dependencies)
		local function update()
			local visible = true
			for _, dependency in next, dependencies do
				if dependency[1].Value ~= dependency[2] then
					visible = false
				end
			end
			for _, card in next, self._cards do
				card.Visible = visible
			end
		end
		for _, dependency in next, dependencies do
			dependency[1]:OnChanged(update)
		end
		update()
	end
	return box
end

--------------------------------------------------------------------------------
-- Library public API
--------------------------------------------------------------------------------

function Library:Create(class, props)
	return create(class, props)
end

function Library:CreateLabel(props)
	return mklabel(nil, props)
end

function Library:AddToRegistry(object, properties)
	local data = { Instance = object, Properties = properties }
	-- Weak-keyed: dead instances are collected rather than pinned forever.
	self.Registry[object] = data
	self.RegistryMap[object] = data
end

function Library:MakeDraggable(frame, cutoff)
	local dragging, dragStart, startPosition
	track(frame.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		if input.Position.Y - frame.AbsolutePosition.Y > (cutoff or 46) then
			return
		end
		dragging, dragStart, startPosition = true, input.Position, frame.Position
	end))
	track(UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = startPosition + UDim2.fromOffset(delta.X, delta.Y)
		end
	end))
	track(UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end))
end

function Library:Notify(message, duration)
	if not self.ScreenGui then
		return
	end
	local holder = self.ScreenGui:FindFirstChild("Notifications")
	if not holder then
		holder = create("Frame", {
			Name = "Notifications",
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -12, 1, -12),
			Size = UDim2.fromOffset(280, 400),
			Parent = self.ScreenGui,
		})
		local layout = list(holder, 6)
		layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	end
	local note = create("Frame", {
		BackgroundColor3 = CARD,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 40),
		Parent = holder,
	}, "Card")
	corner(note, 2)
	stroke(note)
	create("Frame", {
		BackgroundColor3 = ACCENT,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(2, 40),
		Parent = note,
	})
	local textLabel = mklabel(note, {
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -20, 1, 0),
		Text = tostring(message),
		TextSize = 11,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Center,
	})
	note.BackgroundTransparency = 1
	textLabel.TextTransparency = 1
	TweenService:Create(note, TweenInfo.new(0.25), { BackgroundTransparency = 0 }):Play()
	TweenService:Create(textLabel, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
	task.delay(duration or 4, function()
		if note and note.Parent then
			note:Destroy()
		end
	end)
end

function Library:SetWatermark(text)
	if not self.ScreenGui then
		return
	end
	local pill = self.ScreenGui:FindFirstChild("Watermark")
	if not pill then
		pill = create("Frame", {
			Name = "Watermark",
			BackgroundColor3 = CARD,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(10, 10),
			Size = UDim2.fromOffset(10, 22),
			Visible = false,
			Parent = self.ScreenGui,
		}, "Card")
		corner(pill, 2)
		stroke(pill)
		mklabel(pill, {
			Name = "Text",
			Position = UDim2.fromOffset(10, 0),
			Size = UDim2.new(1, -20, 1, 0),
			TextSize = 11,
		})
	end
	pill.Text.Text = tostring(text)
	pill.Size = UDim2.fromOffset(#tostring(text) * 7 + 24, 22)
	pill.Visible = true
end

function Library:SetWatermarkVisibility(visible)
	local pill = self.ScreenGui and self.ScreenGui:FindFirstChild("Watermark")
	if pill then
		pill.Visible = visible == true
	end
end

function Library:OnUnload(callback)
	self.UnloadCallback = callback
end

function Library:Toggle()
	self.Visible = not self.Visible
	self:ClosePopup()
	local outer = self.Window and self.Window.Outer
	if outer then
		local finalSize = self._windowSize or outer.Size
		self._windowSize = finalSize
		if self.Visible then
			outer.Visible = true
			outer.Size = UDim2.new(
				finalSize.X.Scale, math.floor(finalSize.X.Offset * 0.94),
				finalSize.Y.Scale, math.floor(finalSize.Y.Offset * 0.94)
			)
			tween(outer, 0.28, { Size = finalSize }, Enum.EasingStyle.Exponential)
		else
			local t = tween(outer, 0.2, {
				Size = UDim2.new(
					finalSize.X.Scale, math.floor(finalSize.X.Offset * 0.94),
					finalSize.Y.Scale, math.floor(finalSize.Y.Offset * 0.94)
				),
			})
			if t then
				t.Completed:Connect(function()
					if not self.Visible then
						outer.Visible = false
					end
					outer.Size = finalSize
				end)
			else
				outer.Visible = false
				outer.Size = finalSize
			end
		end
	end
	self:_syncBlur()
end

function Library:Unload()
	if self.Unloaded then
		return
	end
	self.Unloaded = true
	for _, signal in next, self.Signals do
		pcall(function()
			signal:Disconnect()
		end)
	end
	if self._blur then
		pcall(function()
			self._blur:Destroy()
		end)
		self._blur = nil
	end
	if self.ScreenGui then
		pcall(function()
			self.ScreenGui:Destroy()
		end)
	end
	if self.UnloadCallback then
		self.UnloadCallback()
	end
end

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------

function Library:CreateWindow(config)
	config = config or {}
	local gui = create("ScreenGui", {
		Name = "SubstanceUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		Parent = (type(gethui) == "function" and gethui()) or CoreGui,
	})
	self.ScreenGui = gui
	ensurePopups()

	local keybindFrame = create("Frame", {
		Name = "Keybinds",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = CARD,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = UDim2.fromOffset(10, 40),
		Size = UDim2.fromOffset(200, 22),
		Visible = false,
		Parent = gui,
	}, "Card")
	corner(keybindFrame, 2)
	stroke(keybindFrame)
	local kbHeader = create("Frame", {
		BackgroundColor3 = ACCENT,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 22),
		Parent = keybindFrame,
	})
	local kbTitle = mklabel(kbHeader, {
		Size = UDim2.fromScale(1, 1),
		Text = "Keybinds",
		TextColor3 = DARK,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	bold(kbTitle)
	local kbEntries = create("Frame", {
		Name = "Entries",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 22),
		Size = UDim2.new(1, 0, 0, 0),
		Parent = keybindFrame,
	})
	list(kbEntries, 2)
	padding(kbEntries, 0, 0, 4, 6)
	self.KeybindFrame = keybindFrame
	self.KeybindListFrame = keybindFrame
	self:MakeDraggable(keybindFrame, 99999)

	local outer = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = BG,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = config.Size or UDim2.fromOffset(980, 560),
		Parent = gui,
	}, "Window")
	corner(outer, 2)
	stroke(outer)
	self:MakeDraggable(outer, 46)

	-- Custom background layer: image + fake-blur copies + dim overlay.
	local bgFrame = create("Frame", {
		Name = "BackgroundLayer",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Size = UDim2.fromScale(1, 1),
		ZIndex = -10,
		Parent = outer,
	})
	corner(bgFrame, 2)
	local bgImage = create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "",
		ImageTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		ScaleType = Enum.ScaleType.Crop,
		Size = UDim2.fromScale(1.04, 1.04),
		ZIndex = -10,
		Parent = bgFrame,
	})
	local bgCopies = {}
	for i = 1, 8 do
		bgCopies[i] = create("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "",
			ImageTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Crop,
			Size = UDim2.fromScale(1.04, 1.04),
			Visible = false,
			ZIndex = -9,
			Parent = bgFrame,
		})
	end
	local bgDim = create("Frame", {
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = -8,
		Parent = bgFrame,
	})
	self._bg = { frame = bgFrame, image = bgImage, copies = bgCopies, dim = bgDim }

	local header = create("Frame", {
		BackgroundColor3 = HEADER,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 46),
		Parent = outer,
	}, "Panel")
	local title = mklabel(header, {
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(0.5, -20, 1, 0),
		Text = config.Title or "SUBSTANCE 2.0",
		TextColor3 = ACCENT,
		TextSize = 13,
	})
	bold(title)
	local meta = create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -14, 0, 0),
		Size = UDim2.new(0, 0, 1, 0),
		Parent = header,
	})
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Parent = meta,
	})
	mklabel(meta, {
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 1,
		Size = UDim2.fromOffset(0, 46),
		Text = tostring(config.User or (localPlayer and localPlayer.Name) or "user"),
		TextColor3 = TEXT,
		TextSize = 11,
	})
	mklabel(meta, {
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 2,
		Size = UDim2.fromOffset(0, 46),
		Text = "[" .. tostring(config.Rank or "DEV") .. "]",
		TextColor3 = ACCENT,
		TextSize = 11,
	})
	mklabel(meta, {
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 3,
		Size = UDim2.fromOffset(0, 46),
		Text = "UID: " .. tostring(config.UID or 0),
		TextColor3 = MUTED,
		TextSize = 11,
	})
	create("Frame", {
		BackgroundColor3 = OUTLINE,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
		Parent = header,
	})

	local nav = create("Frame", {
		BackgroundColor3 = PANEL,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(10, 54),
		Size = UDim2.new(0, 170, 1, -64),
		Parent = outer,
	}, "Panel")
	corner(nav, 2)

	-- sliding accent indicator; created before the item list so items render above it
	local navIndicator = create("Frame", {
		BackgroundColor3 = ACCENT,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(6, 8),
		Size = UDim2.new(1, -12, 0, 36),
		Visible = false,
		Parent = nav,
	})
	corner(navIndicator, 2)
	local navStripes = {}
	for i = 0, 2 do
		table.insert(navStripes, create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = DARK,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -20 + i * 7, 1, -8),
			Rotation = 45,
			Size = UDim2.fromOffset(10, 2),
			Parent = navIndicator,
		}))
	end

	local navList = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(6, 8),
		Size = UDim2.new(1, -12, 1, -16),
		Parent = nav,
	})
	list(navList, 2)

	local moduleColumn = create("ScrollingFrame", {
		BackgroundColor3 = PANEL,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		Position = UDim2.fromOffset(190, 54),
		ScrollBarThickness = 2,
		Size = UDim2.new(0, 212, 1, -64),
		Parent = outer,
	}, "Panel")
	corner(moduleColumn, 2)
	padding(moduleColumn, 8, 8, 8, 8)
	local moduleLayout = list(moduleColumn, 6)
	track(moduleLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		moduleColumn.CanvasSize = UDim2.fromOffset(0, moduleLayout.AbsoluteContentSize.Y + 16)
	end))

	local rightPane = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(412, 54),
		Size = UDim2.new(1, -422, 1, -64),
		Parent = outer,
	})

	local searchField = create("TextBox", {
		BackgroundColor3 = FIELD,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = FONT,
		PlaceholderColor3 = DIM,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 30),
		Text = "",
		TextColor3 = TEXT,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = rightPane,
	}, "Field")
	corner(searchField, 2)
	stroke(searchField)
	padding(searchField, 10, 44)
	local searchCount = mklabel(rightPane, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 0),
		Size = UDim2.fromOffset(40, 30),
		ZIndex = 2,
		Text = "-/-",
		TextColor3 = MUTED,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Right,
	})

	local settingsPane = create("ScrollingFrame", {
		BackgroundColor3 = PANEL,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		Position = UDim2.fromOffset(0, 38),
		ScrollBarThickness = 2,
		Size = UDim2.new(1, 0, 1, -38),
		Parent = rightPane,
	}, "Panel")
	corner(settingsPane, 2)

	local settingsHint = mklabel(settingsPane, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(220, 18),
		Text = "Select a module",
		TextColor3 = MUTED,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Center,
	})

	local window = { Tabs = {}, Outer = outer, Modules = {}, ActiveTab = nil, SettingsHint = settingsHint }

	local function updateSearchPlaceholder()
		local user = tostring(config.User or (localPlayer and localPlayer.Name) or "user"):lower():gsub("%s", "-")
		local path = ""
		local selected = window.SelectedModule
		if selected then
			path = selected.Tab.Name:lower():gsub("%s", "-") .. "/" .. selected.Name:lower():gsub("%s", "-")
		elseif window.ActiveTab then
			path = window.ActiveTab.Name:lower():gsub("%s", "-")
		end
		searchField.PlaceholderText = user .. " & substance ~&: cd " .. path
	end

	local function applyModuleFilter()
		local query = searchField.Text:lower()
		local shown = 0
		local activeCount = 0
		for _, module in next, window.Modules do
			local visible
			if query == "" then
				visible = window.ActiveTab ~= nil and module.Tab == window.ActiveTab
			else
				visible = (module.Name .. " " .. (module.Description or "")):lower():find(query, 1, true) ~= nil
			end
			module.Card.Visible = visible
			if visible then
				shown = shown + 1
			end
			if window.ActiveTab and module.Tab == window.ActiveTab then
				activeCount = activeCount + 1
			end
		end
		if window.EmptyLabel then
			window.EmptyLabel.Visible = query == "" and activeCount == 0
		end
		searchCount.Text = query == "" and "-/-" or (shown .. "/" .. #window.Modules)
	end
	window.ApplyModuleFilter = applyModuleFilter

	local function selectModule(module)
		local changed = window.SelectedModule ~= module
		window.SelectedModule = module
		for _, other in next, window.Modules do
			other:SetSelected(other == module)
		end
		for _, child in next, settingsPane:GetChildren() do
			if child.Name == "Grid" then
				child.Visible = false
			end
		end
		if module then
			module.Grid.Visible = true
			if changed and Library.Theme.Animations ~= false then
				for index, column in ipairs(module.Columns) do
					local base = column.Position
					column.Position =
						UDim2.new(base.X.Scale, base.X.Offset - 18, base.Y.Scale, base.Y.Offset)
					tween(column, 0.4, { Position = base }, Enum.EasingStyle.Exponential)
					fadeIn(column, 0.4, (index - 1) * 0.09)
				end
			end
		end
		if window.SettingsHint then
			window.SettingsHint.Visible = module == nil
		end
		updateSearchPlaceholder()
	end
	window.SelectModule = selectModule

	track(searchField:GetPropertyChangedSignal("Text"):Connect(applyModuleFilter))

	function window:AddTab(name, opts)
		opts = opts or {}
		local tab = { Name = name, Modules = {} }

		local item = create("TextButton", {
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 36),
			Text = "",
			Parent = navList,
		})
		corner(item, 2)
		local iconImage
		if opts.Icon then
			local asset = resolveIcon(opts.Icon)
			if asset then
				iconImage = create("ImageLabel", {
					BackgroundTransparency = 1,
					Image = asset,
					ImageColor3 = MUTED,
					Position = UDim2.fromOffset(11, 11),
					Size = UDim2.fromOffset(14, 14),
					Parent = item,
				})
				tab.IconImage = iconImage
			end
		end
		if not iconImage then
			local glyph = create("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(15, 15),
				Size = UDim2.fromOffset(6, 6),
				Parent = item,
			})
			tab.GlyphStroke = stroke(glyph, ACCENT, 1)
		end
		local nameLabel = mklabel(item, {
			Position = UDim2.fromOffset(34, 0),
			Size = UDim2.new(1, -40, 1, 0),
			Text = name,
			TextColor3 = MUTED,
			TextSize = 12,
		})

		function tab:Show()
			local switching = window.ActiveTab ~= tab
			for _, other in next, window.Tabs do
				tween(other.NameLabel, 0.2, { TextColor3 = th("Muted") })
				if other.GlyphStroke then
					tween(other.GlyphStroke, 0.2, { Color = th("Accent") })
				end
				if other.IconImage then
					tween(other.IconImage, 0.2, { ImageColor3 = th("Muted") })
				end
			end
			tween(nameLabel, 0.2, { TextColor3 = th("Dark") })
			if tab.GlyphStroke then
				tween(tab.GlyphStroke, 0.2, { Color = th("Dark") })
			end
			if iconImage then
				tween(iconImage, 0.2, { ImageColor3 = th("Dark") })
			end
			local index = table.find(window.Tabs, tab) or 1
			navIndicator.Visible = true
			tween(navIndicator, 0.26, { Position = UDim2.fromOffset(6, 8 + (index - 1) * 38) }, Enum.EasingStyle.Exponential)
			for _, s in next, navStripes do
				s.BackgroundColor3 = th("Dark")
			end
			window.ActiveTab = tab
			applyModuleFilter()
			updateSearchPlaceholder()
			-- settings pane keeps the previously selected module; only a click changes it
			if switching and Library.Theme.Animations ~= false then
				local pad = moduleColumn:FindFirstChildOfClass("UIPadding")
				if pad then
					pad.PaddingTop = UDim.new(0, 24)
					tween(pad, 0.45, { PaddingTop = UDim.new(0, 8) }, Enum.EasingStyle.Exponential)
				end
				local shown = 0
				for _, module in next, tab.Modules do
					if module.Card.Visible then
						fadeIn(module.Card, 0.4, shown * 0.05)
						shown = shown + 1
					end
				end
			end
		end
		track(item.MouseEnter:Connect(function()
			if window.ActiveTab ~= tab then
				tween(nameLabel, 0.15, { TextColor3 = th("Text") })
				if iconImage then
					tween(iconImage, 0.15, { ImageColor3 = th("Text") })
				end
			end
		end))
		track(item.MouseLeave:Connect(function()
			if window.ActiveTab ~= tab then
				tween(nameLabel, 0.15, { TextColor3 = th("Muted") })
				if iconImage then
					tween(iconImage, 0.15, { ImageColor3 = th("Muted") })
				end
			end
		end))
		track(item.MouseButton1Click:Connect(function()
			tab:Show()
		end))
		tab.Item = item
		tab.NameLabel = nameLabel

		function tab:AddModule(id, info)
			info = info or {}
			return window:_buildModule(tab, id, info)
		end

		table.insert(window.Tabs, tab)
		if #window.Tabs == 1 then
			tab:Show()
		end
		return tab
	end

	local emptyCard = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 60),
		Visible = false,
		Parent = moduleColumn,
	})
	mklabel(emptyCard, {
		Size = UDim2.fromScale(1, 1),
		Text = "Nothing here yet.",
		TextColor3 = MUTED,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	window.EmptyLabel = emptyCard

	function window:_buildModule(tab, id, info)
		local toggleable = id ~= nil and info.Toggle ~= false
		local module =
			setmetatable({ Tab = tab, Name = info.Name or id or "Module", Description = info.Description }, Container)

		-- per-module settings grid
		local paneWidth = settingsPane.AbsoluteSize.X > 0 and settingsPane.AbsoluteSize.X or 548
		local colW = math.floor((paneWidth - 32) / 3)
		local grid = create("Frame", {
			Name = "Grid",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Visible = false,
			Parent = settingsPane,
		})
		local columns = {}
		for i = 1, 3 do
			local column = create("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset((i - 1) * (colW + 8) + 8, 8),
				Size = UDim2.new(0, colW, 0, 0),
				Parent = grid,
			})
			local columnLayout = list(column, 8)
			track(columnLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				local maxH = 0
				for _, c in next, columns do
					local lay = c:FindFirstChildOfClass("UIListLayout")
					if lay and lay.AbsoluteContentSize.Y > maxH then
						maxH = lay.AbsoluteContentSize.Y
					end
				end
				settingsPane.CanvasSize = UDim2.fromOffset(0, maxH + 24)
			end))
			columns[i] = column
		end
		module.Columns = columns
		module.Heights = { 0, 0, 0 }
		module.Grid = grid
		module._controlCount = 0

		local placeholder = create("Frame", {
			BackgroundColor3 = CARD,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 44),
			Visible = false,
			Parent = columns[1],
		}, "Card")
		corner(placeholder, 2)
		mklabel(placeholder, {
			Size = UDim2.fromScale(1, 1),
			Text = "No settings for this module.",
			TextColor3 = MUTED,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Center,
		})
		module._placeholder = placeholder
		track(grid:GetPropertyChangedSignal("Visible"):Connect(function()
			if grid.Visible then
				placeholder.Visible = module._controlCount == 0
			end
		end))

		-- module card in the shared module column
		local card = create("TextButton", {
			AutoButtonColor = false,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = CARD,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Size = UDim2.new(1, 0, 0, 0),
			Text = "",
			Visible = false,
			Parent = moduleColumn,
		}, "Card")
		corner(card, 2)
		local brackets = addBrackets(card, DIM, 12, 2)

		local titleLabel = mklabel(card, {
			Position = UDim2.fromOffset(10, 10),
			Size = UDim2.new(1, -20, 0, 15),
			Text = module.Name,
			TextColor3 = MUTED,
			TextSize = 13,
		})
		bold(titleLabel)
		local hasDesc = info.Description ~= nil and #tostring(info.Description) > 0
		local descLabel = mklabel(card, {
			AutomaticSize = Enum.AutomaticSize.Y,
			Position = UDim2.fromOffset(10, 28),
			Size = UDim2.new(1, -20, 0, 0),
			Text = info.Description or "",
			TextColor3 = MUTED,
			TextSize = 10,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			Visible = hasDesc,
		})
		local bottomRow = create("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 28),
			Size = UDim2.new(1, -20, 0, 32),
			Parent = card,
		})
		local function layoutBottom()
			local y = 28 + (hasDesc and (math.max(descLabel.TextBounds.Y, 12) + 8) or 0)
			bottomRow.Position = UDim2.new(0, 10, 0, y)
		end
		track(descLabel:GetPropertyChangedSignal("TextBounds"):Connect(layoutBottom))
		layoutBottom()

		if toggleable then
			installControlMethods(module)
			module.Value = info.Default == true
			module.Callback = info.Callback
			module.Type = "toggle"
			module.Changed = {}
			Toggles[id] = module

			local checkbox = makeCheckbox(bottomRow, {
				Position = UDim2.fromOffset(0, 3),
				Size = UDim2.fromOffset(16, 16),
			})
			mklabel(bottomRow, {
				Position = UDim2.fromOffset(22, 0),
				Size = UDim2.new(0, 60, 0, 22),
				Text = "Enabled",
				TextColor3 = MUTED,
				TextSize = 10,
			})
			function module:Display()
				checkbox.Set(self.Value == true)
			end
			track(checkbox.Box.MouseButton1Click:Connect(function()
				module:SetValue(not module.Value)
				selectModule(module)
			end))
			module:Display()
		end

		local gear = create("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = FIELD,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -22, 0, 0),
			Size = UDim2.fromOffset(22, 22),
			Text = "",
			Parent = bottomRow,
		})
		corner(gear, 2)
		local gearBrackets = addBrackets(gear, DIM, 5, 1)
		local gearIcon = create("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://6031280882",
			ImageColor3 = TEXT,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(14, 14),
			Parent = gear,
		})
		track(gear.MouseButton1Click:Connect(function()
			selectModule(module)
		end))

		local badgeSlot = create("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -28, 0, 2),
			Size = UDim2.fromOffset(80, 18),
			Parent = bottomRow,
		})

		local hovered = false
		local selected = false
		local function refreshTitle()
			tween(
				titleLabel,
				0.28,
				{ TextColor3 = hovered and th("Accent") or (selected and th("Text") or th("Muted")) }
			)
		end
		function module:SetSelected(on)
			selected = on == true
			local bracketColor = selected and th("Accent") or th("Dim")
			for _, f in next, brackets do
				tween(f, 0.28, { BackgroundColor3 = bracketColor })
			end
			for _, f in next, gearBrackets do
				tween(f, 0.28, { BackgroundColor3 = bracketColor })
			end
			refreshTitle()
			tween(gearIcon, 0.28, { ImageColor3 = selected and th("Accent") or th("Text") })
		end

		function module:AddKeyPicker(keyId, keyInfo)
			keyInfo = keyInfo or {}
			if self.AutoPicker then
				removePicker(self.AutoPicker)
				self.AutoPicker = nil
			end
			local picker = self:_makeKeyPicker(keyId, keyInfo, toggleable and self or nil)
			picker.Auto = true -- badge always visible: "+" affordance when unbound
			picker:Display()
			picker.Badge.Parent = badgeSlot
			picker.Badge.Position = UDim2.new(1, 0, 0, 0)
			return picker
		end

		if toggleable then
			module:_autoKeybind(module, id, module.Name, badgeSlot, UDim2.new(1, 0, 0, 0))
		end

		track(card.MouseButton1Click:Connect(function()
			selectModule(module)
		end))
		if not attachHoverGlow(card) then
			attachSheen(card)
		end
		track(card.MouseEnter:Connect(function()
			hovered = true
			refreshTitle()
		end))
		track(card.MouseLeave:Connect(function()
			hovered = false
			refreshTitle()
		end))

		module.Card = card
		table.insert(tab.Modules, module)
		table.insert(window.Modules, module)
		applyModuleFilter()
		return module
	end

	applyModuleFilter()
	updateSearchPlaceholder()

	self.Window = window
	self.Visible = true
	self._windowSize = outer.Size
	outer.Size = UDim2.new(
		outer.Size.X.Scale, math.floor(outer.Size.X.Offset * 0.94),
		outer.Size.Y.Scale, math.floor(outer.Size.Y.Offset * 0.94)
	)
	tween(outer, 0.28, { Size = self._windowSize }, Enum.EasingStyle.Exponential)
	return window
end

--------------------------------------------------------------------------------
-- Config module (save/load UI configs)
--------------------------------------------------------------------------------

local function serializeControls(ignore)
	local data = {}
	for id, control in next, Toggles do
		if not ignore[id] and not tostring(id):match("^UI_") then
			data[id] = { type = "toggle", value = control.Value == true }
		end
	end
	for id, control in next, Options do
		if not ignore[id] and not tostring(id):match("^UI_") then
			local kind = control.Type
			if kind == "slider" or kind == "input" or kind == "dropdown" or kind == "keypicker" then
				data[id] = { type = kind, value = control.Value }
			elseif kind == "color" then
				local v = control.Value
				data[id] = {
					type = kind,
					value = v and { r = to255(v.R), g = to255(v.G), b = to255(v.B) } or nil,
				}
			end
		end
	end
	return data
end

local function deserializeControls(data, ignore)
	for id, entry in next, data or {} do
		-- UI_-prefixed controls are excluded from serialization; skip them here
		-- too so stale configs saved before the exclusion can't resurrect them
		-- (e.g. an old "UI_Animations": false would silently kill all tweens).
		if not ignore[id] and not tostring(id):match("^UI_") then
			local control = Toggles[id] or Options[id]
			if control and type(entry) == "table" then
				local value = entry.value
				if entry.type == "color" and type(value) == "table" then
					value = Color3.fromRGB(value.r or 0, value.g or 0, value.b or 0)
				end
				pcall(function()
					control:SetValue(value)
				end)
			end
		end
	end
end

function Library:AddConfigModule(tab, opts)
	opts = opts or {}
	local folder = opts.Folder or "UAPB/Configs"
	self._themeFolder = self._themeFolder or folder
	local settingsDir = folder .. "/settings"
	local ignore = {}
	for _, id in next, opts.Ignore or {} do
		ignore[id] = true
	end

	local module = tab:AddModule(nil, {
		Name = "Configs",
		Description = "Save and load UI configuration files.",
	})

	local functions = fs()
	local available = functions.isfolder
		and functions.makefolder
		and functions.isfile
		and functions.readfile
		and functions.writefile
		and functions.listfiles

	if not available then
		module:AddLabel("Filesystem unavailable.")
		module:AddButton({
			Text = "Save",
			Func = function()
				Library:Notify("Filesystem unavailable.")
			end,
		})
		return module
	end

	if not functions.isfolder(settingsDir) then
		pcall(function()
			functions.makefolder(folder)
			functions.makefolder(settingsDir)
		end)
	end

	local function configFiles()
		local names = {}
		local ok, files = pcall(function()
			return functions.listfiles(settingsDir)
		end)
		for _, path in next, (ok and files) or {} do
			local name = tostring(path):match("([^/\\]+)%.json$")
			if name then
				table.insert(names, name)
			end
		end
		table.sort(names)
		return names
	end

	module:AddInput("ConfigName", { Text = "Config Name", Placeholder = "default" })
	local listControl = module:AddDropdown("ConfigList", {
		Text = "Configs",
		Values = configFiles(),
		AllowNull = true,
	})
	local autoloadLabel = module:AddLabel("Autoload: none")

	local function refresh()
		listControl:SetValues(configFiles())
	end
	local function selected()
		local name = (Options.ConfigList and Options.ConfigList.Value)
			or (Options.ConfigName and Options.ConfigName.Value)
		return (name and #tostring(name) > 0) and name or nil
	end
	local function path(name)
		return settingsDir .. "/" .. name .. ".json"
	end

	module:AddButton({
		Text = "Save",
		Func = function()
			local name = (Options.ConfigName and #tostring(Options.ConfigName.Value) > 0 and Options.ConfigName.Value)
				or selected()
			if not name then
				return Library:Notify("Enter a config name first.")
			end
			local ok, encoded = pcall(function()
				return HttpService:JSONEncode(serializeControls(ignore))
			end)
			if ok then
				functions.writefile(path(name), encoded)
				refresh()
				Library:Notify("Saved config '" .. name .. "'.")
			end
		end,
	})
	module:AddButton({
		Text = "Load",
		Func = function()
			local name = selected()
			if not name or not functions.isfile(path(name)) then
				return Library:Notify("Select a config first.")
			end
			local ok, decoded = pcall(function()
				return HttpService:JSONDecode(functions.readfile(path(name)))
			end)
			if ok and type(decoded) == "table" then
				deserializeControls(decoded, ignore)
				Library:Notify("Loaded config '" .. name .. "'.")
			end
		end,
	})
	module:AddButton({
		Text = "Delete (Double Click)",
		DoubleClick = true,
		Func = function()
			local name = selected()
			if name and functions.delfile and functions.isfile(path(name)) then
				functions.delfile(path(name))
				refresh()
			end
		end,
	})
	module:AddButton({ Text = "Refresh", Func = refresh })
	module:AddButton({
		Text = "Set Autoload",
		Func = function()
			local name = selected()
			if not name then
				return Library:Notify("Select a config first.")
			end
			functions.writefile(settingsDir .. "/autoload.txt", name)
			autoloadLabel:SetText("Autoload: " .. name)
		end,
	})

	self._config = { folder = folder, ignore = ignore, autoloadLabel = autoloadLabel }
	refresh()
	return module
end

function Library:LoadAutoloadConfig()
	local cfg = self._config
	if not cfg then
		return
	end
	local functions = fs()
	if not (functions.isfile and functions.readfile) then
		return
	end
	local autoloadPath = cfg.folder .. "/settings/autoload.txt"
	if not functions.isfile(autoloadPath) then
		return
	end
	local name = tostring(functions.readfile(autoloadPath)):gsub("%s+", "")
	local path = cfg.folder .. "/settings/" .. name .. ".json"
	if #name == 0 or not functions.isfile(path) then
		return
	end
	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(functions.readfile(path))
	end)
	if ok and type(decoded) == "table" then
		deserializeControls(decoded, cfg.ignore or {})
		if cfg.autoloadLabel then
			cfg.autoloadLabel:SetText("Autoload: " .. name)
		end
	end
end

--------------------------------------------------------------------------------
-- Theme application, background image, screen blur
--------------------------------------------------------------------------------

---Sync the Lighting blur with theme + visibility.
function Library:_syncBlur()
	if self._blur then
		self._blur.Enabled = self.Theme.ScreenBlur == true and self.Visible ~= false
		self._blur.Size = self.Theme.BlurSize or 24
	end
end

---Enable/disable blur of the game behind the UI.
function Library:SetBlur(enabled, size)
	if enabled ~= nil then
		self.Theme.ScreenBlur = enabled == true
	end
	if size then
		self.Theme.BlurSize = size
	end
	if self.Theme.ScreenBlur or self._blur then
		if not self._blur then
			local lighting = game:GetService("Lighting")
			self._blur = lighting:FindFirstChild("SubstanceUIBlur")
				or Instance.new("BlurEffect")
			self._blur.Name = "SubstanceUIBlur"
			self._blur.Parent = lighting
		end
		self:_syncBlur()
	end
end

---Resolve a user-supplied image reference to an asset id.
resolveAsset = function(input)
	input = tostring(input or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if #input == 0 then
		return ""
	end
	if input:find("rbxasset") or input:find("://") then
		return input
	end
	if input:match("^%d+$") then
		return "rbxassetid://" .. input
	end
	local f = fs()
	local getcustomasset = env.getcustomasset or _G.getcustomasset
	if f.isfile and getcustomasset then
		local exists = false
		pcall(function()
			exists = f.isfile(input)
		end)
		if exists then
			local ok, asset = pcall(getcustomasset, input)
			if ok and type(asset) == "string" then
				return asset
			end
		end
	end
	return input
end

--------------------------------------------------------------------------------
-- Tab icons (embedded PNGs, written to UAPB/icons/ on first use)
--------------------------------------------------------------------------------

local ICON_DIR = "UAPB/icons"

local ICON_DATA = {
	combat = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAaUlEQVR42u2XMQ4AIAgD/f+n6+TmAlRoYrtbLoYKrmUVBQCjxY8M8B8ALhor3AKChNqv+xlE1JAKkDWjQYwCVE3C59kdHfLLRiqaijQEG0CzBxxDyZdQYhaMT0OJfUBmI/JSagCpvyFDG8PGDR5nK6WVAAAAAElFTkSuQmCC",
	movement = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAd0lEQVR42u2WMQ4AIQgE/f+nudZCcw5BXQxTKriEANJaUWTCOv7uZzYh4iMBm7BNfJUtaV8RDAuCpJzUS84AjteBBXJVHAfhfSwkiJEDaTXi7656eoa6wpMBr79mDdAuoLZ55oDEJKzPSGIfuL4RSeyEEltx8Swf7+U/CDhglYMAAAAASUVORK5CYII=",
	exploit = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAWUlEQVR42u2XMRIAIAjD+P+n8QMucJQyJLNHMwhiBAAUyQ+24DWRLCAP756RhUslqgVHBbrFxiQQQMDeBSfmgH0Sdt4Cq4TkHnT2gfVdYaUjkEBiUoK/xSkexTZRy9W358MAAAAASUVORK5CYII=",
	visuals = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAZUlEQVR42u2WMQ4AIAgD+f+ncXUwhiiUanqzSjFQMBNCvIhvaAlaLsYvKAt+e/YoOOpu6IFIpikiMroAXpAwD5izaxGwEgM1JIofSKl2yi6g8YHT7MrsGDoLKKYhxT5AsREJ8S0DmSEJIob15nAAAAAASUVORK5CYII=",
	builder = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAPklEQVR42u3UsREAIAjFUPZfWlcQpcDjpeb4qRIBdGUdkr0tHb/hP4GM5Ms/AgT6CszsgBRLMQECUizFGMUGNeTabC7SXcYAAAAASUVORK5CYII=",
	tools = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAa0lEQVR42u2WOw4AIAhDvf+lcXFw8BdACkk7CpEXqUprFFVdMkQAWIFT3AVOJu3Wb3G3U9DKtRWQ4isAbY67F7R5X4p/gwgHsJrKbEo4QDoPwG9BuncA/gqGQuw2DPsNX/sOm5Y4E8IBqPLqhZTNT55NrZcAAAAASUVORK5CYII=",
	friends = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAW0lEQVR42u2VWwoAIAgEvf+l7T8MTHyz81mwDoZGBMBUWKC0eJoEK0gpbrnfLxAugSeQpuB1tncPtNiEt0iLfyClC/xBaXF3CW14iIQl0FXCGuTehTEjCgAYxwEsswIbrzojkwAAAABJRU5ErkJggg==",
	config = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAN0lEQVR42u3TwREAMAQAQf03TQX5IR67DTDDRQA85ICvw08s0X4WjypDGa5nKFUZyvBUhnKDLgVkgjjyjOE6gQAAAABJRU5ErkJggg==",
	script = "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAO0lEQVR42u3VsQ0AIAhFQfZfGhsrOwqUmLsF/msIEQCT5fY8QIQIEaMi8mDc+L/jlXPLgpZ33BYA3LAA3RYm6A8IoacAAAAASUVORK5CYII=",
	hoverglow = "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",
}

local function b64decode(data)
	local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	data = data:gsub("[^" .. alphabet .. "=]", "")
	return (data:gsub(".", function(x)
		if x == "=" then
			return ""
		end
		local bits, f = "", (alphabet:find(x, 1, true) - 1)
		for i = 6, 1, -1 do
			bits = bits .. (f % 2 ^ i - f % 2 ^ (i - 1) >= 1 and "1" or "0")
		end
		return bits
	end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
		if #x ~= 8 then
			return ""
		end
		return string.char(tonumber(x, 2))
	end))
end

---Resolve an icon to a usable image asset: icon name -> embedded PNG written
---to UAPB/icons/<name>.png then getcustomasset'd; "rbxassetid://" / paths pass through.
resolveIcon = function(icon)
	if type(icon) ~= "string" or #icon == 0 then
		return nil
	end
	if icon:find("rbxasset") or icon:find("://") or icon:match("^%d+$") then
		return resolveAsset(icon)
	end
	local f = fs()
	local getcustomasset = env.getcustomasset or _G.getcustomasset
	local path = icon:find("[/\\]") and icon or (ICON_DIR .. "/" .. icon .. ".png")
	if not (f.isfile and getcustomasset) then
		return nil
	end
	local exists = false
	pcall(function()
		exists = f.isfile(path)
	end)
	if not exists and f.writefile and f.makefolder and ICON_DATA[icon] then
		pcall(function()
			if f.isfolder and not f.isfolder("UAPB") then
				f.makefolder("UAPB")
			end
			if f.isfolder and not f.isfolder(ICON_DIR) then
				f.makefolder(ICON_DIR)
			end
			f.writefile(path, b64decode(ICON_DATA[icon]))
			exists = true
		end)
	end
	if not exists then
		return nil
	end
	local ok, asset = pcall(getcustomasset, path)
	if ok and type(asset) == "string" then
		return asset
	end
	return nil
end

local BLUR_OFFSETS = {
	{ 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 },
	{ 1, 1 }, { -1, -1 }, { 1, -1 }, { -1, 1 },
}

---Configure the window background image layer.
---Image accepts "rbxassetid://…", a bare numeric id, or a workspace file path.
function Library:SetBackground(opts)
	opts = opts or {}
	local theme = self.Theme
	if opts.Image ~= nil then
		theme.BackgroundImage = tostring(opts.Image)
	end
	if opts.Transparency ~= nil then
		theme.BackgroundImageTransparency = tonumber(opts.Transparency) or 0
	end
	if opts.Blur ~= nil then
		theme.BackgroundImageBlur = tonumber(opts.Blur) or 0
	end
	if opts.Dim ~= nil then
		theme.BackgroundDim = tonumber(opts.Dim) or 0
	end
	local bg = self._bg
	if not bg then
		return
	end
	local asset = resolveAsset(theme.BackgroundImage)
	local hasImage = #asset > 0
	bg.image.Image = asset
	bg.image.ImageTransparency = hasImage and math.clamp(theme.BackgroundImageTransparency or 0, 0, 1) or 1
	local radius = (theme.BackgroundImageBlur or 0) * 6
	local copiesOn = hasImage and radius > 0.4
	for index, copy in next, bg.copies do
		copy.Image = asset
		copy.Visible = copiesOn
		if copiesOn then
			local off = BLUR_OFFSETS[index]
			copy.Position = UDim2.new(0.5, off[1] * radius, 0.5, off[2] * radius)
			copy.ImageTransparency = math.clamp((theme.BackgroundImageTransparency or 0) + 0.55, 0, 0.92)
		end
	end
	bg.dim.BackgroundTransparency = 1 - math.clamp(theme.BackgroundDim or 0, 0, 1)
end

local TRANSPARENCY_KEYS = {
	Window = "WindowTransparency",
	Header = "PanelTransparency",
	Panel = "PanelTransparency",
	Card = "CardTransparency",
	Field = "FieldTransparency",
}

---Merge a partial theme table and repaint everything.
function Library:ApplyTheme(partial, skipSave)
	for key, value in next, partial or {} do
		self.Theme[key] = value
	end
	local theme = self.Theme
	for object in next, fadeBase do
		fadeBase[object] = nil
	end

	-- Legacy fields (InfoLogger/AnimationVisualizer read these).
	self.FontColor = theme.Text
	self.MainColor = theme.Panel
	self.BackgroundColor = theme.Background
	self.AccentColor = theme.Accent
	self.AccentColorDark = theme.AccentDark
	self.OutlineColor = theme.Outline
	self.Font = theme.Font

	for object, entries in next, self.ThemeRegistry do
		for _, entry in next, entries do
			local property, role, base = entry[1], entry[2], entry[3]
			pcall(function()
				if property == "BackgroundTransparency" then
					object.BackgroundTransparency = theme[TRANSPARENCY_KEYS[role]] or 0
				elseif role == "Font" then
					object.Font = theme.Font
				elseif role == "TextScale" then
					object.TextSize = math.max(1, math.floor(base * theme.TextScale + 0.5))
				else
					object[property] = theme[role]
				end
			end)
		end
	end

	for titleLabel in next, self.TitleLabels do
		pcall(function()
			local family = FONT_FAMILIES[tostring(theme.Font.Name)] or "RobotoMono"
			titleLabel.FontFace =
				Font.new("rbxasset://fonts/families/" .. family .. ".json", Enum.FontWeight.Bold)
		end)
	end

	for _, control in next, self.Controls do
		if control.Display then
			pcall(function()
				control:Display()
			end)
		end
	end

	if self.Window then
		for _, module in next, self.Window.Modules do
			pcall(function()
				module:SetSelected(module == self.Window.SelectedModule)
				if module.Display then
					module:Display()
				end
			end)
		end
		if self.Window.ActiveTab then
			self.Window.ActiveTab:Show()
		end
	end

	self:SetBackground({})
	if self.Theme.ScreenBlur and not self._blur then
		self:SetBlur(true)
	else
		self:_syncBlur()
	end
	if theme.HoverGlowEnabled == false then
		for glow, st in next, self._hoverGlows do
			pcall(function()
				if glow:IsA("UIStroke") then
					glow.Transparency = 1
				else
					glow.ImageTransparency = 1
				end
			end)
			if type(st) == "table" then
				st.alpha = 0
			end
		end
	end

	rebuildKeybindList()

	if not skipSave then
		self:SaveTheme()
	end
end

---Persist the theme to <Folder>/theme.json.
function Library:SaveTheme()
	local folder = self._themeFolder
	if not folder then
		return
	end
	local f = fs()
	if not (f.writefile and f.makefolder and f.isfolder) then
		return
	end
	local theme = self.Theme
	local data = {
		preset = self._activePreset,
		accent = { r = to255(theme.Accent.R), g = to255(theme.Accent.G), b = to255(theme.Accent.B) },
		badge = { r = to255(theme.Badge.R), g = to255(theme.Badge.G), b = to255(theme.Badge.B) },
		sheen = theme.Sheen
			and { r = to255(theme.Sheen.R), g = to255(theme.Sheen.G), b = to255(theme.Sheen.B) },
		font = theme.Font.Name,
		textScale = theme.TextScale,
		windowTransparency = theme.WindowTransparency,
		panelTransparency = theme.PanelTransparency,
		cardTransparency = theme.CardTransparency,
		fieldTransparency = theme.FieldTransparency,
		backgroundImage = theme.BackgroundImage,
		backgroundTransparency = theme.BackgroundImageTransparency,
		backgroundBlur = theme.BackgroundImageBlur,
		backgroundDim = theme.BackgroundDim,
		screenBlur = theme.ScreenBlur,
		blurSize = theme.BlurSize,
		animations = theme.Animations,
		hoverGlow = theme.HoverGlow
			and { r = to255(theme.HoverGlow.R), g = to255(theme.HoverGlow.G), b = to255(theme.HoverGlow.B) },
		hoverGlowEnabled = theme.HoverGlowEnabled ~= false,
	}
	pcall(function()
		if not f.isfolder(folder) then
			f.makefolder(folder)
		end
		f.writefile(folder .. "/theme.json", HttpService:JSONEncode(data))
	end)
end

---Load a saved theme. Returns the raw decoded table or nil.
function Library:LoadTheme()
	local folder = self._themeFolder
	local f = fs()
	if not (folder and f.isfile and f.readfile and f.isfile(folder .. "/theme.json")) then
		return nil
	end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(f.readfile(folder .. "/theme.json"))
	end)
	if not (ok and type(data) == "table") then
		return nil
	end
	local partial = {}
	if type(data.accent) == "table" then
		partial.Accent = Color3.fromRGB(data.accent.r or 0, data.accent.g or 0, data.accent.b or 0)
		partial.AccentDark = Color3.new(partial.Accent.R * 0.7, partial.Accent.G * 0.7, partial.Accent.B * 0.7)
	end
	if type(data.badge) == "table" then
		partial.Badge = Color3.fromRGB(data.badge.r or 0, data.badge.g or 0, data.badge.b or 0)
	end
	if type(data.sheen) == "table" then
		partial.Sheen = Color3.fromRGB(data.sheen.r or 0, data.sheen.g or 0, data.sheen.b or 0)
	end
	if data.font and Enum.Font[data.font] then
		partial.Font = Enum.Font[data.font]
	end
	partial.TextScale = tonumber(data.textScale)
	partial.WindowTransparency = tonumber(data.windowTransparency)
	partial.PanelTransparency = tonumber(data.panelTransparency)
	partial.CardTransparency = tonumber(data.cardTransparency)
	partial.FieldTransparency = tonumber(data.fieldTransparency)
	partial.BackgroundImage = data.backgroundImage
	partial.BackgroundImageTransparency = tonumber(data.backgroundTransparency)
	partial.BackgroundImageBlur = tonumber(data.backgroundBlur)
	partial.BackgroundDim = tonumber(data.backgroundDim)
	partial.ScreenBlur = data.screenBlur == true
	partial.BlurSize = tonumber(data.blurSize)
	partial.Animations = data.animations ~= false
	if type(data.hoverGlow) == "table" then
		partial.HoverGlow =
			Color3.fromRGB(data.hoverGlow.r or 0, data.hoverGlow.g or 0, data.hoverGlow.b or 0)
	end
	if data.hoverGlowEnabled ~= nil then
		partial.HoverGlowEnabled = data.hoverGlowEnabled == true
	end
	self._activePreset = data.preset
	self:ApplyTheme(partial, true)
	return data
end

---Add the "Theme" module to a tab.
function Library:AddThemeModule(tab, opts)
	opts = opts or {}
	if opts.Folder then
		self._themeFolder = opts.Folder
	elseif not self._themeFolder then
		self._themeFolder = "UAPB/Configs"
	end

	local module = tab:AddModule(nil, {
		Name = "Theme",
		Description = "Change the preset, accent color, fonts, background image, and effects.",
	})

	local ordered = { "Dark", "Glass" }
	local extra = {}
	for name in next, self.Presets do
		if name ~= "Dark" and name ~= "Glass" then
			table.insert(extra, name)
		end
	end
	table.sort(extra)
	for _, name in next, extra do
		table.insert(ordered, name)
	end

	module:AddDropdown("UI_Preset", {
		Text = "Preset",
		Values = ordered,
		Default = self._activePreset or "Dark",
		Callback = function(name)
			local preset = Library.Presets[name]
			if preset then
				Library._activePreset = name
				Library:ApplyTheme(preset)
				if Options.UI_Accent then
					Options.UI_Accent:SetValue(Library.Theme.Accent)
				end
				if Options.UI_Badge then
					Options.UI_Badge:SetValue(Library.Theme.Badge)
				end
				if Options.UI_Sheen then
					Options.UI_Sheen:SetValue(Library.Theme.Sheen)
				end
			end
		end,
	})

	module:AddColorPicker("UI_Accent", {
		Text = "Accent Color",
		Default = self.Theme.Accent,
		Callback = function(color)
			Library._activePreset = nil
			Library:ApplyTheme({
				Accent = color,
				AccentDark = Color3.new(color.R * 0.7, color.G * 0.7, color.B * 0.7),
			})
		end,
	})

	module:AddColorPicker("UI_Badge", {
		Text = "Keybind Badge",
		Default = self.Theme.Badge,
		Callback = function(color)
			Library._activePreset = nil
			Library:ApplyTheme({ Badge = color })
		end,
	})

	module:AddColorPicker("UI_Sheen", {
		Text = "Sheen Color",
		Tooltip = "Color of the hover sweep on cards.",
		Default = self.Theme.Sheen,
		Callback = function(color)
			Library._activePreset = nil
			Library:ApplyTheme({ Sheen = color })
		end,
	})

	module:AddToggle("UI_HoverGlowEnabled", {
		Text = "Hover Glow",
		Tooltip = "Subtle outline that fades in around hovered cards.",
		Default = self.Theme.HoverGlowEnabled ~= false,
		Callback = function(on)
			Library:ApplyTheme({ HoverGlowEnabled = on == true })
		end,
	})

	module:AddColorPicker("UI_HoverGlowColor", {
		Text = "Hover Glow Color",
		Tooltip = "Color of the outline that appears around hovered cards.",
		Default = self.Theme.HoverGlow,
		Callback = function(color)
			Library._activePreset = nil
			Library:ApplyTheme({ HoverGlow = color })
		end,
	})

	module:AddDropdown("UI_Font", {
		Text = "Font",
		Values = self.Fonts,
		Default = self.Theme.Font.Name,
		Callback = function(name)
			if Enum.Font[name] then
				Library:ApplyTheme({ Font = Enum.Font[name] })
			end
		end,
	})

	module:AddSlider("UI_TextScale", {
		Text = "Text Scale",
		Min = 0.9,
		Max = 1.3,
		Default = 1,
		Rounding = 2,
		Callback = function(scale)
			Library:ApplyTheme({ TextScale = scale })
		end,
	})

	-- scan <themeFolder>/images and UAPB/backgrounds for selectable images
	local imageMap = {}
	local imageValues = { "None" }
	do
		local f = fs()
		if f.listfiles then
			for _, dir in next, { self._themeFolder .. "/images", "UAPB/backgrounds" } do
				local ok, names = pcall(f.listfiles, dir)
				if ok and type(names) == "table" then
					for _, path in next, names do
						path = tostring(path)
						if path:lower():match("%.%a+$") and path:lower():match("%.(png|jpe?g|bmp|webp)$") then
							local name = path:match("[^\\/]+$") or path
							if not imageMap[name] then
								table.insert(imageValues, name)
							end
							imageMap[name] = path
						end
					end
				end
			end
		end
	end

	local imageDrop = module:AddDropdown("UI_BackgroundImage", {
		Text = "Background Image",
		Values = imageValues,
		Default = "None",
		AllowNull = true,
		Callback = function(name)
			if not name or name == "None" then
				Library:SetBackground({ Image = "" })
			elseif imageMap[name] then
				Library:SetBackground({ Image = imageMap[name] })
			end
			Library:SaveTheme()
		end,
	})

	module:AddInput("UI_BackgroundImageCustom", {
		Text = "Custom Image",
		Placeholder = "rbxassetid://… or file path",
		Finished = true,
		Callback = function(value)
			Library:SetBackground({ Image = value })
			Library:SaveTheme()
		end,
	})

	module:AddSlider("UI_BackgroundTransparency", {
		Text = "Image Transparency",
		Min = 0,
		Max = 1,
		Default = 0.6,
		Rounding = 2,
		Callback = function(value)
			Library:SetBackground({ Transparency = value })
			Library:SaveTheme()
		end,
	})

	module:AddSlider("UI_BackgroundBlur", {
		Text = "Image Blur",
		Min = 0,
		Max = 1,
		Default = 0,
		Rounding = 2,
		Callback = function(value)
			Library:SetBackground({ Blur = value })
			Library:SaveTheme()
		end,
	})

	module:AddSlider("UI_BackgroundDim", {
		Text = "Image Dim",
		Min = 0,
		Max = 1,
		Default = 0.4,
		Rounding = 2,
		Callback = function(value)
			Library:SetBackground({ Dim = value })
			Library:SaveTheme()
		end,
	})

	module:AddToggle("UI_Blur", {
		Text = "Blur Game Behind UI",
		Default = false,
		Callback = function(on)
			Library:SetBlur(on)
			Library:SaveTheme()
		end,
	})

	module:AddSlider("UI_BlurSize", {
		Text = "Blur Amount",
		Min = 0,
		Max = 56,
		Default = 24,
		Rounding = 0,
		Callback = function(size)
			Library:SetBlur(nil, size)
			Library:SaveTheme()
		end,
	})

	module:AddToggle("UI_Animations", {
		Text = "UI Animations",
		Default = true,
		Callback = function(on)
			Library.Theme.Animations = on
			Library:SaveTheme()
		end,
	})

	module:AddButton("Reset Theme", function()
		Library._activePreset = "Dark"
		Library:ApplyTheme(Library.Presets.Dark)
		if Options.UI_Accent then
			Options.UI_Accent:SetValue(Library.Theme.Accent)
		end
		if Options.UI_Badge then
			Options.UI_Badge:SetValue(Library.Theme.Badge)
		end
		if Options.UI_Sheen then
			Options.UI_Sheen:SetValue(Library.Theme.Sheen)
		end
		if Options.UI_Preset then
			Options.UI_Preset:SetValue("Dark")
		end
		Library:Notify("Theme reset to Dark.")
	end)

	-- Apply the saved theme on top of the freshly created controls.
	self:LoadTheme()
	if Options.UI_Preset and self._activePreset then
		Options.UI_Preset:SetValue(self._activePreset)
	end
	if Options.UI_Accent then
		Options.UI_Accent:SetValue(self.Theme.Accent)
	end
	if Options.UI_Badge then
		Options.UI_Badge:SetValue(self.Theme.Badge)
	end
	if Options.UI_Sheen then
		Options.UI_Sheen:SetValue(self.Theme.Sheen)
	end
	if Options.UI_Font then
		Options.UI_Font:SetValue(self.Theme.Font.Name)
	end
	if Options.UI_TextScale then
		Options.UI_TextScale:SetValue(self.Theme.TextScale)
	end
	if Options.UI_BackgroundImage then
		local current = self.Theme.BackgroundImage or ""
		local selected = "None"
		for name, path in next, imageMap do
			if path == current then
				selected = name
				break
			end
		end
		if selected ~= "None" or current == "" then
			Options.UI_BackgroundImage:SetValue(selected)
		elseif Options.UI_BackgroundImageCustom then
			Options.UI_BackgroundImageCustom:SetValue(current)
		end
	end
	if Options.UI_BackgroundTransparency then
		Options.UI_BackgroundTransparency:SetValue(self.Theme.BackgroundImageTransparency)
	end
	if Options.UI_BackgroundBlur then
		Options.UI_BackgroundBlur:SetValue(self.Theme.BackgroundImageBlur)
	end
	if Options.UI_BackgroundDim then
		Options.UI_BackgroundDim:SetValue(self.Theme.BackgroundDim)
	end
	if Options.UI_Blur then
		Options.UI_Blur:SetValue(self.Theme.ScreenBlur == true)
	end
	if Options.UI_BlurSize then
		Options.UI_BlurSize:SetValue(self.Theme.BlurSize)
	end
	if Options.UI_Animations then
		Options.UI_Animations:SetValue(self.Theme.Animations ~= false)
	end
	return module
end

--------------------------------------------------------------------------------
-- Window toggle key
--------------------------------------------------------------------------------

track(UIS.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	local keybind = Library.ToggleKeybind
	local key = (keybind and keybind.Value) or "RightShift"
	if key ~= "None" and key ~= "N/A" and input.KeyCode.Name == tostring(key) then
		Library:Toggle()
	end
end))

return Library
