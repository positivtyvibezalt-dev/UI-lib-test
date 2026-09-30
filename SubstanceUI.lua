--------------------------------------------------------------------------------
-- Substance 2.0 — standalone executor UI library (no external dependencies).
--------------------------------------------------------------------------------

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
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
	FontColor = TEXT,
	MainColor = PANEL,
	BackgroundColor = BG,
	AccentColor = ACCENT,
	AccentColorDark = ACCENT_DARK,
	OutlineColor = OUTLINE,
	Font = FONT,
	Black = Color3.new(0, 0, 0),
	Registry = {},
	RegistryMap = {},
	Signals = {},
	KeyPickers = {},
	Unloaded = false,
}

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function create(class, props)
	local object = type(class) == "string" and Instance.new(class) or class
	for key, value in next, props or {} do
		object[key] = value
	end
	return object
end

local function stroke(parent, color, thickness)
	return create("UIStroke", { Color = color or OUTLINE, Thickness = thickness or 1, Parent = parent })
end

local function corner(parent, radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius or 2), Parent = parent })
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
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = parent,
	})
	for key, value in next, props or {} do
		object[key] = value
	end
	return object
end

local function bold(object)
	if BOLD_FONT then
		local ok = pcall(function()
			object.FontFace = BOLD_FONT
		end)
		if ok then
			return
		end
	end
	object.Font = Enum.Font.Code
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
	return control
end

--------------------------------------------------------------------------------
-- Popups (dropdown lists, color pickers) rendered above everything
--------------------------------------------------------------------------------

local Popups, PopupOverlay

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
	})
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
	for _, child in next, frame:GetChildren() do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	local shown = 0
	for _, picker in next, Library.KeyPickers do
		if picker.Value and picker.Value ~= "None" and picker.Value ~= "N/A" then
			shown = shown + 1
			local on = picker.LinkedToggle and picker.LinkedToggle.Value
			mklabel(frame, {
				LayoutOrder = shown,
				Size = UDim2.new(1, 0, 0, 16),
				Text = "[" .. formatKey(picker.Value) .. "] " .. (picker.Text or ""),
				TextColor3 = on and ACCENT or TEXT,
				TextSize = 11,
			})
		end
	end
end

--------------------------------------------------------------------------------
-- Container (settings grid)
--------------------------------------------------------------------------------

local Container = {}
Container.__index = Container

---Create a setting card in the currently shortest grid column.
function Container:_card(height)
	local heights = self.Heights
	local shortest = 1
	for index = 2, #self.Columns do
		if heights[index] < heights[shortest] then
			shortest = index
		end
	end
	heights[shortest] = heights[shortest] + height + 8
	self._controlCount = (self._controlCount or 0) + 1
	if self._placeholder then
		self._placeholder.Visible = false
	end
	local card = create("Frame", {
		BackgroundColor3 = CARD,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, height),
		Parent = self.Columns[shortest],
	})
	corner(card, 2)
	if self.OnCard then
		self.OnCard(card)
	end
	return card
end

function Container:_head(card, title, tooltip)
	local titleLabel = mklabel(card, {
		Position = UDim2.fromOffset(10, 8),
		Size = UDim2.new(1, -20, 0, 15),
		Text = title or "",
		TextSize = 12,
	})
	bold(titleLabel)
	if tooltip and #tostring(tooltip) > 0 then
		mklabel(card, {
			Position = UDim2.fromOffset(10, 24),
			Size = UDim2.new(1, -20, 0, 24),
			Text = tooltip,
			TextColor3 = MUTED,
			TextSize = 10,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
	end
	return titleLabel
end

function Container:AddDivider()
	return self
end

function Container:AddLabel(text)
	local long = #tostring(text) > 40
	local height = long and math.max(56, 20 + math.ceil(#tostring(text) / 24) * 12) or 44
	local card = self:_card(height)
	local object = newControl(nil, { Default = text }, "label")
	if long then
		object.Label = mklabel(card, {
			Position = UDim2.fromOffset(10, 8),
			Size = UDim2.new(1, -20, 1, -16),
			Text = text,
			TextColor3 = MUTED,
			TextSize = 11,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
	else
		object.Label = self:_head(card, text)
	end
	object.Card = card
	function object:SetText(value)
		self.Value = value
		if self.Label then
			self.Label.Text = value
		end
	end
	function object:AddKeyPicker(keyId, info)
		local picker = self.Parent:_makeKeyPicker(keyId, info or {}, nil)
		picker.Badge.Parent = card
		picker.Badge.Position = UDim2.new(1, -10, 1, -28)
		return picker
	end
	object.Parent = self
	return object
end

function Container:AddButton(info, callback)
	if type(info) ~= "table" then
		info = { Text = info, Func = callback }
	end
	local card = self:_card(70)
	if info.Tooltip then
		self:_head(card, "", info.Tooltip)
	end
	local btn = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = FIELD,
		BorderSizePixel = 0,
		Font = FONT,
		Position = UDim2.new(0, 10, 1, -38),
		Size = UDim2.new(1, -20, 0, 28),
		Text = info.Text or "",
		TextColor3 = TEXT,
		TextSize = 12,
		Parent = card,
	})
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
	local card = self:_card(78)
	self:_head(card, info.Text or id, info.Tooltip or info.Description)
	local control = newControl(id, info, "toggle")
	-- full-card hit zone beneath the checkbox
	local hit = create("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		Parent = card,
	})
	local box = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = FIELD,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -26, 1, -26),
		Size = UDim2.fromOffset(16, 16),
		Text = "",
		Parent = card,
	})
	corner(box, 2)
	stroke(box)
	local mark = mklabel(box, {
		Size = UDim2.fromScale(1, 1),
		Text = "✓",
		TextColor3 = DARK,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Center,
		Visible = false,
	})
	function control:Display()
		local on = self.Value == true
		mark.Visible = on
		box.BackgroundColor3 = on and ACCENT or FIELD
	end
	track(box.MouseButton1Click:Connect(function()
		control:SetValue(not control.Value)
	end))
	track(hit.MouseButton1Click:Connect(function()
		control:SetValue(not control.Value)
	end))
	function control:AddKeyPicker(keyId, keyInfo)
		local picker = self.Parent:_makeKeyPicker(keyId, keyInfo or {}, self)
		picker.Badge.Parent = card
		picker.Badge.Position = UDim2.new(1, -40, 1, -28)
		return picker
	end
	function control:AddColorPicker(colorId, colorInfo)
		return self.Parent:AddColorPicker(colorId, colorInfo)
	end
	control.Parent = self
	control.Card = card
	control:Display()
	return control
end

function Container:AddSlider(id, info)
	info = info or {}
	local card = self:_card(104)
	self:_head(card, info.Text or id, info.Tooltip or info.Description)
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
		Position = UDim2.new(0, 10, 1, -56),
		Size = UDim2.new(1, -20, 0, 5),
		Text = "",
		Parent = card,
	})
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
		Position = UDim2.new(0, 10, 1, -42),
		Size = UDim2.new(1, -20, 0, 22),
		TextColor3 = TEXT,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})
	corner(field, 2)
	stroke(field)
	padding(field, 8)
	function control:Display()
		local alpha = max > min and math.clamp((self.Value - min) / (max - min), 0, 1) or 0
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
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
	local card = self:_card(92)
	self:_head(card, info.Text or id, info.Tooltip or info.Description)
	local control = newControl(id, { Default = tostring(info.Default or ""), Callback = info.Callback }, "input")
	local wrap = create("Frame", {
		BackgroundColor3 = FIELD,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 1, -36),
		Size = UDim2.new(1, -20, 0, 26),
		Parent = card,
	})
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
	local card = self:_card(92)
	self:_head(card, info.Text or id, info.Tooltip or info.Description)
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
		Position = UDim2.new(0, 10, 1, -36),
		Size = UDim2.new(1, -20, 0, 26),
		Text = "",
		Parent = card,
	})
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
				TextColor3 = isSelected(value) and TEXT or MUTED,
				TextSize = 11,
				ZIndex = 102,
			})
			track(row.MouseButton1Click:Connect(function()
				if info.Multi then
					local set = control.Value or {}
					set[value] = not set[value] and true or nil
					control:SetValue(set)
					local on = isSelected(value)
					bar.Visible = on
					rowLabel.TextColor3 = on and TEXT or MUTED
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
	create("Frame", {
		BackgroundColor3 = ACCENT,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(-8, 6),
		Size = UDim2.fromOffset(6, 6),
		Parent = badge,
	})
	local badgeText = mklabel(badge, {
		Size = UDim2.fromScale(1, 1),
		Text = "",
		TextColor3 = DARK,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	return badge, badgeText
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
	control.SyncToggle = info.SyncToggleState == true
	control.Held = false
	table.insert(Library.KeyPickers, control)

	local badge, badgeText = makeBadge()
	control.Badge = badge
	function control:Display()
		badgeText.Text = formatKey(self.Value)
		badge.Size = UDim2.fromOffset(badgeWidth(self.Value), 18)
		rebuildKeybindList()
	end
	track(badge.MouseButton1Click:Connect(function()
		badgeText.Text = "..."
		control.Capturing = true
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

function Container:AddKeyPicker(id, info)
	info = info or {}
	local picker = self:_makeKeyPicker(id, info, nil)
	if info.Text then
		local card = self:_card(70)
		self:_head(card, info.Text, info.Tooltip or info.Description)
		picker.Badge.Parent = card
		picker.Badge.Position = UDim2.new(1, -10, 1, -28)
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
	local card = self:_card(70)
	self:_head(card, info.Text or id, info.Tooltip or info.Description)
	local control = newControl(id, info, "color")
	control.Value = info.Default or ACCENT
	local swatch = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = control.Value,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -38, 1, -28),
		Size = UDim2.fromOffset(28, 18),
		Text = "",
		Parent = card,
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
			track(bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					setFrom(input)
				end
			end))
			track(bar.InputChanged:Connect(function(input)
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
		track(hexBox.FocusLost:Connect(function()
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
	table.insert(self.Registry, data)
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
	})
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
		})
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
	if self.Window and self.Window.Outer then
		self.Window.Outer.Visible = self.Visible
	end
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
		Position = UDim2.fromOffset(10, 40),
		Size = UDim2.fromOffset(200, 0),
		Visible = false,
		Parent = gui,
	})
	corner(keybindFrame, 2)
	stroke(keybindFrame)
	padding(keybindFrame, 6, 6, 6, 6)
	list(keybindFrame, 2)
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
	})
	corner(outer, 2)
	stroke(outer)
	self:MakeDraggable(outer, 46)

	local header = create("Frame", {
		BackgroundColor3 = HEADER,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 46),
		Parent = outer,
	})
	local title = mklabel(header, {
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(0.5, -20, 1, 0),
		Text = config.Title or "SUBSTANCE 2.0",
		TextColor3 = ACCENT,
		TextSize = 13,
	})
	bold(title)
	mklabel(header, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 0),
		Size = UDim2.fromOffset(90, 46),
		Text = "UID: " .. tostring(config.UID or 0),
		TextColor3 = MUTED,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
	})
	mklabel(header, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -104, 0, 0),
		Size = UDim2.fromOffset(70, 46),
		Text = "[" .. tostring(config.Rank or "DEV") .. "]",
		TextColor3 = ACCENT,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
	})
	mklabel(header, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -174, 0, 0),
		Size = UDim2.fromOffset(160, 46),
		Text = tostring(config.User or (localPlayer and localPlayer.Name) or "user"),
		TextColor3 = TEXT,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
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
	})
	corner(nav, 2)
	padding(nav, 6, 6, 8, 8)
	list(nav, 2)

	local moduleColumn = create("ScrollingFrame", {
		BackgroundColor3 = PANEL,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		Position = UDim2.fromOffset(190, 54),
		ScrollBarThickness = 2,
		Size = UDim2.new(0, 212, 1, -64),
		Parent = outer,
	})
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
	})
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
	})
	corner(settingsPane, 2)

	local window = { Tabs = {}, Outer = outer, Modules = {}, ActiveTab = nil }

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
			Parent = nav,
		})
		corner(item, 2)
		if opts.Icon then
			create("ImageLabel", {
				BackgroundTransparency = 1,
				Image = opts.Icon,
				Position = UDim2.fromOffset(10, 10),
				Size = UDim2.fromOffset(16, 16),
				Parent = item,
			})
		else
			local glyph = create("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(15, 15),
				Size = UDim2.fromOffset(6, 6),
				Parent = item,
			})
			stroke(glyph, ACCENT, 1)
		end
		local nameLabel = mklabel(item, {
			Position = UDim2.fromOffset(34, 0),
			Size = UDim2.new(1, -40, 1, 0),
			Text = name,
			TextColor3 = MUTED,
			TextSize = 12,
		})
		local stripes = {}
		for i = 0, 2 do
			table.insert(stripes, create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = DARK,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -20 + i * 7, 1, -8),
				Rotation = 45,
				Size = UDim2.fromOffset(10, 2),
				Visible = false,
				Parent = item,
			}))
		end

		function tab:Show()
			for _, other in next, window.Tabs do
				other.Item.BackgroundTransparency = 1
				other.NameLabel.TextColor3 = MUTED
				for _, s in next, other.Stripes do
					s.Visible = false
				end
			end
			item.BackgroundTransparency = 0
			item.BackgroundColor3 = ACCENT
			nameLabel.TextColor3 = DARK
			for _, s in next, stripes do
				s.Visible = true
			end
			window.ActiveTab = tab
			applyModuleFilter()
			updateSearchPlaceholder()
			if
				window.SelectedModule
				and window.SelectedModule.Tab ~= tab
				and searchField.Text == ""
			then
				selectModule(nil)
			end
			if
				searchField.Text == ""
				and (not window.SelectedModule or window.SelectedModule.Tab ~= tab)
			then
				if tab.Modules[1] then
					selectModule(tab.Modules[1])
				else
					selectModule(nil)
				end
			end
		end
		track(item.MouseEnter:Connect(function()
			if window.ActiveTab ~= tab then
				nameLabel.TextColor3 = TEXT
			end
		end))
		track(item.MouseLeave:Connect(function()
			if window.ActiveTab ~= tab then
				nameLabel.TextColor3 = MUTED
			end
		end))
		track(item.MouseButton1Click:Connect(function()
			tab:Show()
		end))
		tab.Item = item
		tab.NameLabel = nameLabel
		tab.Stripes = stripes

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
		})
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
			Size = UDim2.new(1, 0, 0, 0),
			Text = "",
			Visible = false,
			Parent = moduleColumn,
		})
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

			local onOff = create("TextButton", {
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Font = FONT,
				Size = UDim2.new(0, 44, 0, 22),
				Text = "OFF",
				TextColor3 = MUTED,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = bottomRow,
			})
			function module:Display()
				onOff.Text = self.Value and "ON" or "OFF"
				onOff.TextColor3 = self.Value and ACCENT or MUTED
			end
			track(onOff.MouseButton1Click:Connect(function()
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

		function module:SetSelected(on)
			for _, f in next, brackets do
				f.BackgroundColor3 = on and ACCENT or DIM
			end
			for _, f in next, gearBrackets do
				f.BackgroundColor3 = on and ACCENT or DIM
			end
			titleLabel.TextColor3 = on and TEXT or MUTED
			gearIcon.ImageColor3 = on and ACCENT or TEXT
		end

		function module:AddKeyPicker(keyId, keyInfo)
			keyInfo = keyInfo or {}
			local picker = self:_makeKeyPicker(keyId, keyInfo, toggleable and self or nil)
			picker.Badge.Parent = badgeSlot
			picker.Badge.Position = UDim2.new(1, 0, 0, 0)
			local function syncBadge()
				picker.Badge.Visible = picker.Value ~= "None" and picker.Value ~= "N/A" and picker.Value ~= nil
			end
			picker:OnChanged(syncBadge)
			syncBadge()
			return picker
		end

		track(card.MouseButton1Click:Connect(function()
			selectModule(module)
		end))

		module.Card = card
		table.insert(tab.Modules, module)
		table.insert(window.Modules, module)
		applyModuleFilter()
		if window.ActiveTab == tab and not window.SelectedModule then
			selectModule(module)
		end
		return module
	end

	applyModuleFilter()
	updateSearchPlaceholder()

	self.Window = window
	self.Visible = true
	return window
end

--------------------------------------------------------------------------------
-- Config module (save/load UI configs)
--------------------------------------------------------------------------------

local function serializeControls(ignore)
	local data = {}
	for id, control in next, Toggles do
		if not ignore[id] then
			data[id] = { type = "toggle", value = control.Value == true }
		end
	end
	for id, control in next, Options do
		if not ignore[id] then
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
		if not ignore[id] then
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
