-- FlightUi 1.0.0 | made by rayware
-- A client-side UI library. Loading this module creates no window or gameplay features.
local Players = game:GetService('Players')
local TweenService = game:GetService('TweenService')
local Input = game:GetService('UserInputService')
local FlightUi = {Version = '1.0.0'}
local Window = {}; Window.__index = Window
local Tab = {}; Tab.__index = Tab
local Control = {}; Control.__index = Control
local function rgb(r,g,b) return Color3.fromRGB(r,g,b) end
local defaults = {
    Accent = rgb(255,118,147), Background = rgb(27,31,43),
    Surface = rgb(38,43,57), Text = rgb(240,243,250),
    Muted = rgb(156,167,192), Stroke = rgb(221,232,255),
}
local builtins = {
    Rose = {Accent=rgb(255,118,147)}, Red = {Accent=rgb(255,112,94)},
    Blue = {Accent=rgb(120,173,255)}, Green = {Accent=rgb(116,230,179)},
    Gold = {Accent=rgb(255,211,126)}, White = {Accent=rgb(233,237,248)},
}
local builtinOrder = {'Rose','Red','Blue','Green','Gold','White'}
local function new(class, props, parent)
    local object = Instance.new(class)
    for k,v in pairs(props or {}) do object[k] = v end
    object.Parent = parent
    return object
end
local function corner(object, radius)
    new('UICorner', {CornerRadius=UDim.new(0,radius)}, object)
end
local function stroke(object, color, alpha)
    return new('UIStroke', {Color=color,Transparency=alpha,Thickness=1,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, object)
end
local function text(parent, value, size, position, fontSize)
    return new('TextLabel', {BackgroundTransparency=1,Text=tostring(value or ''),
        Size=size,Position=position,Font=Enum.Font.Gotham,TextSize=fontSize or 12,
        TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,
        ZIndex=3},parent)
end
local function number(value, fallback)
    value = tonumber(value)
    if not value or value ~= value or value == math.huge or value == -math.huge then return fallback end
    return value
end
function Window:_connect(signal, fn, owner)
    local connection = signal:Connect(fn)
    table.insert(self._connections, connection)
    if owner then table.insert(owner._connections, connection) end
    return connection
end
function Window:_tween(object, duration, props, bounce)
    if self._destroyed then return end
    if self.ReduceMotion then
        for key,value in pairs(props) do object[key]=value end
        return
    end
    -- Cancel earlier animations on the same properties, including theme changes.
    local registry = self._tweens[object]
    if not registry then registry={}; self._tweens[object]=registry end
    for key in pairs(props) do if registry[key] then registry[key]:Cancel() end end
    local animation = TweenService:Create(object,TweenInfo.new(duration,
        bounce and Enum.EasingStyle.Back or Enum.EasingStyle.Quart,Enum.EasingDirection.Out),props)
    for key in pairs(props) do registry[key]=animation end
    animation:Play()
    return animation
end
function Window:_theme(owner, callback)
    self._themeHooks[owner] = callback
    callback(self.Theme)
end
function Window:_callback(control, ...)
    if self._destroyed or control._destroyed or control._disabled then return end
    local callback, args = control.Callback, table.pack(...)
    if type(callback) ~= 'function' then return end
    task.spawn(function()
        if self._destroyed or control._destroyed then return end
        local ok, message = pcall(callback, table.unpack(args,1,args.n))
        if not ok then warn('[FlightUi callback] '..tostring(message)) end
    end)
end
function Window:_glass(parent, size, radius)
    local frame = new('Frame',{Size=size,BackgroundTransparency=0.06,BorderSizePixel=0},parent)
    corner(frame,radius)
    new('UIGradient',{Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,rgb(255,255,255)),
        ColorSequenceKeypoint.new(0.45,rgb(183,191,212)),
        ColorSequenceKeypoint.new(1,rgb(111,118,140)),
    }),Rotation=90},frame)
    local rim = stroke(frame,defaults.Stroke,0.78)
    new('UIGradient',{Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,0.9),
    }),Rotation=90},rim)
    local shine = new('Frame',{Position=UDim2.fromOffset(radius,1),
        Size=UDim2.new(1,-radius*2,0,1),BackgroundColor3=rgb(255,255,255),
        BackgroundTransparency=0.52,BorderSizePixel=0,ZIndex=2},frame)
    new('UIGradient',{Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0),
        NumberSequenceKeypoint.new(1,1),
    })},shine)
    self:_theme(frame,function(t)
        self:_tween(frame,0.25,{BackgroundColor3=t.Surface})
        self:_tween(rim,0.25,{Color=t.Stroke})
    end)
    return frame
end
function Window:_button(parent, caption, size, position, owner)
    local holder = self:_glass(parent,size,13)
    holder.Position=position or UDim2.new()
    local scale = new('UIScale',{Scale=1},holder)
    local hit = new('TextButton',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        Text=tostring(caption),TextSize=12,Font=Enum.Font.GothamMedium,
        AutoButtonColor=false,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=4},holder)
    self:_theme(hit,function(t) hit.TextColor3=t.Text end)
    self:_connect(hit.MouseEnter,function()
        self:_tween(holder,0.18,{BackgroundColor3=self.Theme.Surface:Lerp(self.Theme.Stroke,0.1)})
    end,owner)
    self:_connect(hit.MouseLeave,function()
        self:_tween(holder,0.22,{BackgroundColor3=self.Theme.Surface})
        self:_tween(scale,0.35,{Scale=1},true)
    end,owner)
    self:_connect(hit.InputBegan,function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            self:_tween(scale,0.12,{Scale=0.95})
        end
    end,owner)
    self:_connect(hit.InputEnded,function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            self:_tween(scale,0.42,{Scale=1},true)
        end
    end,owner)
    return hit,holder
end
function Window:_clamp(object)
    local viewport = self.Gui.AbsoluteSize
    if viewport.X<=0 or viewport.Y<=0 then return end
    local half = object.AbsoluteSize/2
    local mx,my = math.min(half.X+8,viewport.X/2),math.min(half.Y+8,viewport.Y/2)
    local p=object.Position
    object.Position=UDim2.fromOffset(
        math.clamp(p.X.Scale*viewport.X+p.X.Offset,mx,viewport.X-mx),
        math.clamp(p.Y.Scale*viewport.Y+p.Y.Offset,my,viewport.Y-my))
end
function Window:_fit()
    local size=self.Gui.AbsoluteSize
    if size.X<=0 or size.Y<=0 then return end
    self._baseScale=math.min(1,math.max(0.1,(size.X-34)/self.Width),math.max(0.1,(size.Y-34)/self.Height))
    self._miniScale=math.min(1,math.max(0.1,(size.X-20)/202),math.max(0.1,(size.Y-20)/64))
    if not self._busy then
        self._scale.Scale=self._baseScale
        self._capsuleScale.Scale=self._miniScale
        self:_clamp(self._minimized and self._capsule or self._root)
    end
end
function Window:_dragHandle(handle,target,isMini)
    self:_connect(handle.InputBegan,function(input)
        if not self._ready or self._busy then return end
        if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
        if isMini then self._miniMoved=false end
        self._drag={input=input,start=input.Position,position=target.Position,target=target,mini=isMini}
    end)
end
function Window:AddTheme(name, definition)
    assert(not self._destroyed,'FlightUi: window is destroyed')
    assert(type(name)=='string' and name~='','FlightUi: theme needs a name')
    assert(type(definition)=='table','FlightUi: theme must be a table')
    local theme={}
    for key,fallback in pairs(defaults) do
        local value=definition[key] or fallback
        assert(typeof(value)=='Color3','FlightUi: '..key..' must be Color3')
        theme[key]=value
    end
    local fresh=self.Themes[name]==nil
    self.Themes[name]=theme
    if fresh then
        table.insert(self.ThemeOrder,name)
        for _,picker in ipairs(self._themePickers) do
            if not picker._destroyed then self:_themeButton(picker,name) end
        end
    end
    if self.ThemeName==name then self:SetTheme(name) end
    return self
end
function Window:SetTheme(name)
    assert(not self._destroyed,'FlightUi: window is destroyed')
    assert(self.Themes[name],'FlightUi: unknown theme '..tostring(name))
    self.ThemeName,self.Theme=name,self.Themes[name]
    for _,fn in pairs(self._themeHooks) do fn(self.Theme) end
    return self
end
function Window:GetTheme() return self.ThemeName end
function Window:SetTitle(value)
    self.Title=tostring(value)
    self._title.Text=self.Title
    self._miniTitle.Text=self._customMiniTitle or self.Title
    return self
end
function Window:SetSubtitle(value)
    self.Subtitle=tostring(value); self._subtitle.Text=self.Subtitle
    return self
end
function Window:SetMiniText(title,subtitle)
    self._customMiniTitle=tostring(title)
    self._miniTitle.Text=self._customMiniTitle
    if subtitle~=nil then self._miniSubtitle.Text=tostring(subtitle) end
    return self
end
function Window:SelectTab(tab)
    if type(tab)=='string' then
        local found
        for _,candidate in ipairs(self.Tabs) do if candidate.Name==tab then found=candidate; break end end
        tab=found
    end
    assert(tab and tab.Window==self and not tab._destroyed,'FlightUi: tab not found')
    self.ActiveTab=tab
    for _,candidate in ipairs(self.Tabs) do
        candidate.Page.Visible=candidate==tab
        self:_tween(candidate.Button,0.2,{TextColor3=candidate==tab and self.Theme.Accent or self.Theme.Muted})
    end
    tab.Scale.Scale=self.ReduceMotion and 1 or 0.96
    self:_tween(tab.Scale,0.42,{Scale=1},true)
    return self
end
function Window:AddTab(config)
    assert(not self._destroyed,'FlightUi: window is destroyed')
    if type(config)=='string' then config={Name=config} end
    config=config or {}
    local tab=setmetatable({Window=self,Name=tostring(config.Name or 'Tab'),Controls={},_destroyed=false},Tab)
    local hit,holder=self:_button(self._tabs,tab.Name,UDim2.fromOffset(132,38))
    tab.Button,tab.Holder=hit,holder
    holder.LayoutOrder=#self.Tabs+1
    tab.Page=new('ScrollingFrame',{Position=UDim2.fromOffset(23,137),Size=UDim2.new(1,-46,1,-176),
        BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,CanvasSize=UDim2.new(),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,
        Visible=false,ClipsDescendants=true},self._content)
    new('UIPadding',{PaddingTop=UDim.new(0,3),PaddingBottom=UDim.new(0,9),
        PaddingLeft=UDim.new(0,3),PaddingRight=UDim.new(0,7)},tab.Page)
    new('UIListLayout',{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},tab.Page)
    tab.Scale=new('UIScale',{Scale=1},tab.Page)
    self:_theme(tab,function(t)
        tab.Page.ScrollBarImageColor3=t.Accent
        hit.TextColor3=self.ActiveTab==tab and t.Accent or t.Muted
    end)
    self:_connect(hit.Activated,function() if self._ready and not self._busy then self:SelectTab(tab) end end)
    table.insert(self.Tabs,tab)
    if not self.ActiveTab then self:SelectTab(tab) end
    return tab
end
Window.CreateTab=Window.AddTab
function Tab:SetName(value)
    self.Name=tostring(value); self.Button.Text=self.Name; return self
end
function Tab:_control(config,height,kind)
    assert(not self._destroyed and not self.Window._destroyed,'FlightUi: tab is destroyed')
    config=config or {}
    assert(config.Callback==nil or type(config.Callback)=='function','FlightUi: Callback must be a function')
    local w=self.Window
    if config.Flag then assert(w._flags[config.Flag]==nil,'FlightUi: duplicate Flag '..tostring(config.Flag)) end
    local c=setmetatable({Window=w,Tab=self,Kind=kind,Callback=config.Callback,
        Flag=config.Flag,_connections={},_destroyed=false,_disabled=false},Control)
    c.Frame=w:_glass(self.Page,UDim2.new(1,0,0,height),16)
    c.Frame.LayoutOrder=#self.Controls+1
    c.Title=text(c.Frame,config.Name or config.Text or kind,UDim2.new(1,-100,0,24),UDim2.fromOffset(16,10),13)
    c.Title.Font=Enum.Font.GothamMedium
    c.Description=text(c.Frame,config.Description or '',UDim2.new(1,-100,0,18),UDim2.fromOffset(16,35),10)
    w:_theme(c,function(t)
        c.Title.TextColor3=t.Text; c.Description.TextColor3=t.Muted
        if c._redraw then c:_redraw() end
    end)
    table.insert(self.Controls,c)
    if c.Flag then w._flags[c.Flag]=c end
    return c
end
function Control:SetText(value)
    self.Title.Text=tostring(value)
    if self.Kind=='Button' then self.Hit.Text=tostring(value) end
    return self
end
function Control:SetDescription(value) self.Description.Text=tostring(value); return self end
function Control:SetCallback(callback)
    assert(callback==nil or type(callback)=='function','FlightUi: Callback must be a function')
    self.Callback=callback; return self
end
function Control:GetValue() return self.Value end
function Control:SetValue(value,fireCallback)
    assert(not self._destroyed and not self.Window._destroyed,'FlightUi: control is destroyed')
    if self.Kind=='Toggle' then value=value==true
    elseif self.Kind=='Slider' then
        value=math.clamp(number(value,self.Value),self.Min,self.Max)
        if value~=self.Min and value~=self.Max then
            value=self.Min+math.floor((value-self.Min)/self.Step+0.5)*self.Step
            value=math.clamp(value,self.Min,self.Max)
        end
    else error('FlightUi: SetValue is available on toggles and sliders') end
    local changed=self.Value~=value
    self.Value=value
    if self.Flag then self.Window.Values[self.Flag]=value end
    if self._redraw then self:_redraw() end
    if changed and fireCallback then self.Window:_callback(self,value) end
    return self
end
function Control:SetDisabled(value)
    self._disabled=value==true
    self.Title.TextTransparency=self._disabled and 0.5 or 0
    self.Description.TextTransparency=self._disabled and 0.5 or 0
    if self.Hit then self.Hit.Active=not self._disabled end
    if self.Kind=='Button' then self.Hit.TextTransparency=self._disabled and 0.5 or 0 end
    if self._redraw then self:_redraw() end
    return self
end
function Control:Destroy()
    if self._destroyed then return end
    self._destroyed=true
    local w=self.Window
    if w._slider and w._slider.control==self then w._slider=nil end
    for _,c in ipairs(self._connections) do c:Disconnect() end
    w._themeHooks[self]=nil
    w._themeHooks[self.Frame]=nil
    for _,object in ipairs(self.Frame:GetDescendants()) do
        w._themeHooks[object]=nil
        local tweens=w._tweens[object]
        if tweens then for _,t in pairs(tweens) do t:Cancel() end end
        w._tweens[object]=nil
    end
    if w._tweens[self.Frame] then
        for _,t in pairs(w._tweens[self.Frame]) do t:Cancel() end
        w._tweens[self.Frame]=nil
    end
    if self.Flag then w._flags[self.Flag]=nil; w.Values[self.Flag]=nil end
    self.Frame:Destroy()
end
function Tab:AddToggle(config)
    config=config or {}
    local c=self:_control(config,65,'Toggle'); local w=self.Window
    c.Hit=new('TextButton',{Position=UDim2.new(1,-63,0,19),Size=UDim2.fromOffset(47,27),
        Text='',AutoButtonColor=false,BorderSizePixel=0,ZIndex=4},c.Frame)
    corner(c.Hit,14); stroke(c.Hit,defaults.Stroke,0.8)
    c.Knob=new('Frame',{Position=UDim2.fromOffset(4,4),Size=UDim2.fromOffset(19,19),
        BackgroundColor3=rgb(244,247,255),BorderSizePixel=0,ZIndex=5},c.Hit)
    corner(c.Knob,10)
    function c:_redraw()
        w:_tween(self.Hit,0.23,{BackgroundColor3=self.Value and w.Theme.Accent or w.Theme.Surface:Lerp(w.Theme.Stroke,0.18)})
        w:_tween(self.Knob,0.4,{Position=UDim2.fromOffset(self.Value and 24 or 4,4)},true)
    end
    c:SetValue(config.Default==true)
    w:_connect(c.Hit.Activated,function()
        if w._ready and not w._busy and not c._disabled then c:SetValue(not c.Value,true) end
    end,c)
    if config.FireOnInit then w:_callback(c,c.Value) end
    return c
end
function Tab:AddButton(config)
    config=config or {}
    local c=self:_control(config,config.Description and 94 or 58,'Button'); local w=self.Window
    c.Title.Visible=false
    c.Description.Size=UDim2.new(1,-32,0,18); c.Description.Position=UDim2.fromOffset(16,66)
    c.Hit,c.ButtonHolder=w:_button(c.Frame,config.Name or 'Button',UDim2.new(1,-24,0,36),UDim2.fromOffset(12,11),c)
    w:_connect(c.Hit.Activated,function()
        if w._ready and not w._busy and not c._disabled then w:_callback(c) end
    end,c)
    return c
end
function Tab:AddSlider(config)
    config=config or {}
    local min=number(config.Min,0); local max=number(config.Max,100); local step=number(config.Step,1)
    assert(max>min and step>0,'FlightUi: slider requires Max > Min and Step > 0')
    local c=self:_control(config,config.Description and 122 or 102,'Slider'); local w=self.Window
    c.Min,c.Max,c.Step=min,max,step
    c.Title.Size=UDim2.new(1,-112,0,24)
    c.Description.Size=UDim2.new(1,-32,0,18)
    local y=config.Description and 70 or 48
    c.Readout=text(c.Frame,'',UDim2.fromOffset(78,22),UDim2.new(1,-94,0,12),12)
    c.Readout.TextXAlignment=Enum.TextXAlignment.Right
    c.Hit=new('TextButton',{Position=UDim2.fromOffset(22,y),Size=UDim2.new(1,-44,0,26),
        Text='',BackgroundTransparency=1,AutoButtonColor=false,ZIndex=4},c.Frame)
    c.Rail=new('Frame',{Position=UDim2.fromOffset(0,10),Size=UDim2.new(1,0,0,6),BorderSizePixel=0,ZIndex=4},c.Hit)
    corner(c.Rail,3)
    c.Fill=new('Frame',{Size=UDim2.fromScale(0,1),BorderSizePixel=0,ZIndex=5},c.Rail); corner(c.Fill,3)
    c.Thumb=new('Frame',{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(18,18),
        Position=UDim2.fromScale(0,0.5),BackgroundColor3=rgb(245,248,255),BorderSizePixel=0,ZIndex=6},c.Hit)
    corner(c.Thumb,9); c.ThumbScale=new('UIScale',{Scale=1},c.Thumb)
    c.Low=text(c.Frame,tostring(min),UDim2.fromOffset(110,16),UDim2.fromOffset(18,y+30),9)
    c.High=text(c.Frame,tostring(max),UDim2.fromOffset(110,16),UDim2.new(1,-128,0,y+30),9)
    c.High.TextXAlignment=Enum.TextXAlignment.Right
    local suffix=tostring(config.Suffix or '')
    function c:_redraw()
        local ratio=((self.Value or min)-min)/(max-min)
        self.Fill.Size=UDim2.fromScale(ratio,1)
        self.Thumb.Position=UDim2.fromScale(ratio,0.5)
        self.Fill.BackgroundColor3=w.Theme.Accent; self.Readout.TextColor3=w.Theme.Accent
        self.Rail.BackgroundColor3=w.Theme.Surface:Lerp(w.Theme.Stroke,0.18)
        self.Low.TextColor3=w.Theme.Muted; self.High.TextColor3=w.Theme.Muted
        self.Readout.Text=string.format('%.6g',self.Value or min)..suffix
    end
    function c:_slide(x)
        if self.Hit.AbsoluteSize.X<=0 then return end
        local ratio=math.clamp((x-self.Hit.AbsolutePosition.X)/self.Hit.AbsoluteSize.X,0,1)
        self:SetValue(min+(max-min)*ratio,true)
    end
    c:SetValue(number(config.Default,min))
    w:_connect(c.Hit.InputBegan,function(input)
        if not w._ready or w._busy or c._disabled then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            w._slider={input=input,control=c}; c:_slide(input.Position.X)
            w:_tween(c.ThumbScale,0.2,{Scale=1.2},true)
        end
    end,c)
    if config.FireOnInit then w:_callback(c,c.Value) end
    return c
end
function Tab:AddLabel(config)
    if type(config)=='string' then config={Text=config} end
    config=config or {}
    local c=self:_control(config,config.Description and 69 or 49,'Label')
    c.Title.Size=UDim2.new(1,-32,0,24); c.Description.Size=UDim2.new(1,-32,0,18)
    return c
end
function Tab:AddSection(caption)
    local c=self:_control({Text=caption},33,'Section')
    c.Frame.BackgroundTransparency=1
    c.Title.Position=UDim2.fromOffset(3,5); c.Title.Size=UDim2.new(1,-6,0,23)
    c.Title.TextSize=10; c.Description.Visible=false
    for _,object in ipairs(c.Frame:GetChildren()) do
        if object:IsA('UIStroke') or object:IsA('Frame') then object:Destroy() end
    end
    self.Window._themeHooks[c.Frame]=nil
    return c
end
function Window:_themeButton(picker,name)
    local control=picker.Tab:AddButton({Name=name,Callback=function() self:SetTheme(name) end})
    self:_theme(control.Hit,function()
        control.Hit.Text=(self.ThemeName==name and '• ' or '')..name
        control.Hit.TextColor3=self.Themes[name].Accent
    end)
    table.insert(picker.Controls,control)
end
function Tab:AddThemePicker(config)
    config=config or {}
    local picker={Tab=self,Controls={},_destroyed=false}
    self:AddSection(config.Name or 'COLOR THEME')
    for _,name in ipairs(self.Window.ThemeOrder) do self.Window:_themeButton(picker,name) end
    table.insert(self.Window._themePickers,picker)
    return picker
end
function Window:AddSettingsTab(config)
    config=config or {}
    local tab=self:AddTab({Name=config.Name or 'Settings'})
    tab:AddThemePicker({Name=config.ThemeLabel or 'COLOR THEME'})
    tab:AddLabel({Text=config.Credit or ('made by '..self.Author),Description=config.Description or 'FlightUi / liquid glass interface'})
    return tab
end
function Window:Notify(message,duration)
    if self._destroyed then return self end
    self._noticeToken=self._noticeToken+1
    local token=self._noticeToken
    self._footer.Text=tostring(message)
    self:_tween(self._footer,0.2,{TextColor3=self.Theme.Accent})
    task.delay(math.max(0.1,number(duration,3)),function()
        if not self._destroyed and self._noticeToken==token then
            self._footer.Text=self.Footer; self._footer.TextColor3=self.Theme.Muted
        end
    end)
    return self
end
function Window:Minimize(value)
    if value==nil then value=true end
    value=value==true
    if self._destroyed or not self._ready or self._busy or self._minimized==value then return self end
    self._busy=true; self._minimized=value; self._drag=nil
    local duration=self.ReduceMotion and 0 or 0.16
    if value then
        self._capsule.Position=self._root.Position
        self:_tween(self._scale,duration,{Scale=self._baseScale*0.82})
        task.delay(duration,function()
            if self._destroyed then return end
            self._root.Visible=false; self._capsule.Visible=true
            self._capsuleScale.Scale=self._miniScale; self:_clamp(self._capsule)
            self._capsuleScale.Scale=self.ReduceMotion and self._miniScale or self._miniScale*0.6
            self:_tween(self._capsuleScale,0.48,{Scale=self._miniScale},true)
            task.delay(self.ReduceMotion and 0 or 0.48,function()
                if not self._destroyed then self._busy=false; self:_fit() end
            end)
        end)
    else
        self._root.Position=self._capsule.Position
        self:_tween(self._capsuleScale,duration,{Scale=self._miniScale*0.65})
        task.delay(duration,function()
            if self._destroyed then return end
            self._capsule.Visible=false; self._root.Visible=true
            self._scale.Scale=self._baseScale; self:_clamp(self._root)
            self._scale.Scale=self.ReduceMotion and self._baseScale or self._baseScale*0.82
            self:_tween(self._scale,0.48,{Scale=self._baseScale},true)
            task.delay(self.ReduceMotion and 0 or 0.48,function()
                if not self._destroyed then self._busy=false; self:_fit() end
            end)
        end)
    end
    return self
end
function Window:Restore() return self:Minimize(false) end
function Window:Destroy()
    if self._destroyed then return end
    self._destroyed=true; self._drag=nil; self._slider=nil
    for _,connection in ipairs(self._connections) do connection:Disconnect() end
    for _,registry in pairs(self._tweens) do for _,animation in pairs(registry) do animation:Cancel() end end
    for _,animation in ipairs(self._loaderTweens) do animation:Cancel() end
    self._themeHooks={}; self._tweens={}
    for _,tab in ipairs(self.Tabs) do
        tab._destroyed=true
        for _,control in ipairs(tab.Controls) do control._destroyed=true end
    end
    self.Gui:Destroy()
    self.Values={}; self._flags={}
    local onDestroy=self._onDestroy
    if type(onDestroy)=='function' then
        local ok,err=pcall(onDestroy); if not ok then warn('[FlightUi OnDestroy] '..tostring(err)) end
    end
end
function Window:_loader(config)
    if config.Welcome==false then self._ready=true; self._content.Visible=true; return end
    local loader=new('Frame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=10},self._surface)
    local scale=new('UIScale',{Scale=self.ReduceMotion and 1 or 0.9},loader)
    local heading=text(loader,config.WelcomeText or 'welcome,',UDim2.new(1,-40,0,35),UDim2.new(0,20,0.5,-84),26)
    heading.TextXAlignment=Enum.TextXAlignment.Center; heading.ZIndex=11
    local player=Players.LocalPlayer
    local nick=config.WelcomeName or (player and player.Name) or 'guest'
    local nickname=text(loader,nick,UDim2.new(1,-40,0,43),UDim2.new(0,20,0.5,-44),31)
    nickname.Font=Enum.Font.GothamBold; nickname.TextXAlignment=Enum.TextXAlignment.Center
    nickname.TextScaled=true; nickname.ZIndex=11
    new('UITextSizeConstraint',{MinTextSize=12,MaxTextSize=31},nickname)
    local caption=text(loader,config.LoadingText or 'Preparing your interface',UDim2.new(1,-40,0,22),UDim2.new(0,20,0.5,12),11)
    caption.TextXAlignment=Enum.TextXAlignment.Center; caption.ZIndex=11
    local dots={}
    for i=1,3 do
        local dot=new('Frame',{Size=UDim2.fromOffset(7,7),Position=UDim2.new(0.5,-24+(i-1)*17,0.5,56),
            BackgroundTransparency=0.3,BorderSizePixel=0,ZIndex=11},loader)
        corner(dot,4); table.insert(dots,dot)
        if not self.ReduceMotion then
            local animation=TweenService:Create(dot,TweenInfo.new(0.42,Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut,-1,true,(i-1)*0.12),
                {Position=UDim2.new(0.5,-24+(i-1)*17,0.5,48),BackgroundTransparency=0})
            table.insert(self._loaderTweens,animation); animation:Play()
        end
    end
    self:_theme(loader,function(t)
        heading.TextColor3=t.Text; nickname.TextColor3=t.Accent; caption.TextColor3=t.Muted
        for _,dot in ipairs(dots) do dot.BackgroundColor3=t.Accent end
    end)
    self:_tween(scale,0.6,{Scale=1},true)
    task.delay(math.max(0,number(config.LoadingDuration,1.5)),function()
        if self._destroyed then return end
        for _,animation in ipairs(self._loaderTweens) do animation:Cancel() end
        for _,object in ipairs(loader:GetDescendants()) do
            if object:IsA('TextLabel') then self:_tween(object,0.18,{TextTransparency=1})
            elseif object:IsA('Frame') then self:_tween(object,0.18,{BackgroundTransparency=1}) end
        end
        task.delay(self.ReduceMotion and 0 or 0.2,function()
            if self._destroyed then return end
            self._themeHooks[loader]=nil
            for _,object in ipairs(loader:GetDescendants()) do self._tweens[object]=nil end
            self._tweens[scale]=nil; loader:Destroy()
            self._content.Visible=true; self._ready=true
            self._scale.Scale=self.ReduceMotion and self._baseScale or self._baseScale*0.94
            self:_tween(self._scale,0.5,{Scale=self._baseScale},true)
        end)
    end)
end
function FlightUi:CreateWindow(config)
    config=config or {}
    local w=setmetatable({Title=tostring(config.Title or 'FlightUi'),Subtitle=tostring(config.Subtitle or 'LIQUID GLASS / UI LIBRARY'),
        Author=tostring(config.Author or 'rayware'),Footer=tostring(config.Footer or 'FLIGHTUI / READY'),
        Width=math.max(340,number(config.Width,430)),Height=math.max(340,number(config.Height,450)),
        ReduceMotion=config.ReduceMotion==true,Values={},Tabs={},Themes={},ThemeOrder={},
        _connections={},_themeHooks={},_themePickers={},_flags={},_tweens={},_loaderTweens={},
        _destroyed=false,_ready=false,_busy=false,_minimized=false,_baseScale=1,_miniScale=1,_noticeToken=0,
        _onDestroy=config.OnDestroy,_customMiniTitle=config.MiniTitle},Window)
    for _,name in ipairs(builtinOrder) do w:AddTheme(name,builtins[name]) end
    for name,theme in pairs(config.Themes or {}) do w:AddTheme(name,theme) end
    w.ThemeName=config.Theme or 'Rose'
    assert(w.Themes[w.ThemeName],'FlightUi: unknown starting theme')
    w.Theme=w.Themes[w.ThemeName]
    local parent=config.Parent
    if not parent and gethui then pcall(function() parent=gethui() end) end
    if not parent then
        assert(Players.LocalPlayer,'FlightUi: run from a client / LocalScript')
        parent=Players.LocalPlayer:WaitForChild('PlayerGui')
    end
    w.Gui=new('ScreenGui',{Name=tostring(config.Id or 'FlightUi'),ResetOnSpawn=false,
        IgnoreGuiInset=false,DisplayOrder=number(config.DisplayOrder,1000),ZIndexBehavior=Enum.ZIndexBehavior.Sibling},parent)
    w._root=new('Frame',{AnchorPoint=Vector2.new(0.5,0.5),Position=config.Position or UDim2.fromScale(0.5,0.5),
        Size=UDim2.fromOffset(w.Width,w.Height),BackgroundTransparency=1},w.Gui)
    w._scale=new('UIScale',{Scale=1},w._root)
    for i=3,1,-1 do
        local spread=i*5
        local shadow=new('Frame',{Position=UDim2.fromOffset(-spread,6-spread),Size=UDim2.new(1,spread*2,1,spread*2),
            BackgroundColor3=rgb(0,0,0),BackgroundTransparency=0.85+i*0.025,BorderSizePixel=0,ZIndex=0},w._root)
        corner(shadow,27+spread)
    end
    w._surface=w:_glass(w._root,UDim2.fromScale(1,1),25); w._surface.ClipsDescendants=true
    -- The window background uses Background, rather than the control Surface color.
    w._themeHooks[w._surface]=nil
    local rim=stroke(w._surface,w.Theme.Accent,0.74)
    w._content=new('Frame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},w._surface)
    w._title=text(w._content,w.Title,UDim2.new(1,-150,0,29),UDim2.fromOffset(23,17),21)
    w._title.Font=Enum.Font.GothamBold; w._title.Active=true
    w._subtitle=text(w._content,w.Subtitle,UDim2.new(1,-130,0,18),UDim2.fromOffset(24,47),9)
    local minimize=w:_button(w._content,'−',UDim2.fromOffset(36,36),UDim2.new(1,-108,0,22))
    minimize.TextSize=22
    local close=w:_button(w._content,'×',UDim2.fromOffset(36,36),UDim2.new(1,-61,0,22)); close.TextSize=21
    w._tabs=new('ScrollingFrame',{Position=UDim2.fromOffset(23,83),Size=UDim2.new(1,-46,0,45),
        BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,CanvasSize=UDim2.new(),
        AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollingDirection=Enum.ScrollingDirection.X},w._content)
    new('UIListLayout',{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},w._tabs)
    new('UIPadding',{PaddingTop=UDim.new(0,2),PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,2)},w._tabs)
    w._footer=text(w._content,w.Footer,UDim2.new(1,-46,0,17),UDim2.new(0,24,1,-29),9)
    w._capsule=w:_glass(w.Gui,UDim2.fromOffset(202,64),21)
    w._capsule.AnchorPoint=Vector2.new(0.5,0.5); w._capsule.Position=w._root.Position; w._capsule.Visible=false
    w._capsuleScale=new('UIScale',{Scale=1},w._capsule)
    local miniRim=stroke(w._capsule,w.Theme.Accent,0.6)
    w._miniTitle=text(w._capsule,config.MiniTitle or w.Title,UDim2.fromOffset(123,23),UDim2.fromOffset(17,11),14)
    w._miniTitle.Font=Enum.Font.GothamBold
    w._miniSubtitle=text(w._capsule,config.MiniSubtitle or 'tap to open',UDim2.fromOffset(126,15),UDim2.fromOffset(18,36),9)
    local miniOpen=new('TextButton',{Size=UDim2.fromOffset(143,64),BackgroundTransparency=1,Text='',AutoButtonColor=false,ZIndex=5},w._capsule)
    local restore=w:_button(w._capsule,'↗',UDim2.fromOffset(38,36),UDim2.fromOffset(149,14)); restore.TextSize=18
    w:_theme(w,function(t)
        w:_tween(w._surface,0.25,{BackgroundColor3=t.Background})
        w:_tween(rim,0.25,{Color=t.Accent}); w:_tween(miniRim,0.25,{Color=t.Accent})
        w._title.TextColor3=t.Text; w._subtitle.TextColor3=t.Muted; w._footer.TextColor3=t.Muted
        w._miniTitle.TextColor3=t.Text; w._miniSubtitle.TextColor3=t.Accent
        w._tabs.ScrollBarImageColor3=t.Accent
    end)
    w:_dragHandle(w._title,w._root,false); w:_dragHandle(miniOpen,w._capsule,true)
    w:_connect(minimize.Activated,function() w:Minimize() end)
    w:_connect(restore.Activated,function() w:Restore() end)
    w:_connect(miniOpen.Activated,function() if not w._miniMoved then w:Restore() end end)
    w:_connect(close.Activated,function()
        if not w._ready or w._busy then return end
        w._busy=true
        w:_tween(w._scale,0.18,{Scale=w._baseScale*0.8})
        task.delay(w.ReduceMotion and 0 or 0.2,function() w:Destroy() end)
    end)
    w:_connect(w.Gui:GetPropertyChangedSignal('AbsoluteSize'),function() w:_fit() end)
    w:_connect(Input.InputChanged,function(input)
        local sliding=w._slider
        if sliding then
            local touch=sliding.input.UserInputType==Enum.UserInputType.Touch
            if (touch and input==sliding.input) or (not touch and input.UserInputType==Enum.UserInputType.MouseMovement) then
                if not sliding.control._disabled then sliding.control:_slide(input.Position.X) end
            end
        end
        local d=w._drag; if not d then return end
        local touch=d.input.UserInputType==Enum.UserInputType.Touch
        if touch and input~=d.input then return end
        if not touch and input.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local delta=input.Position-d.start
        if d.mini and delta.Magnitude>6 then w._miniMoved=true end
        d.target.Position=UDim2.new(d.position.X.Scale,d.position.X.Offset+delta.X,d.position.Y.Scale,d.position.Y.Offset+delta.Y)
        w:_clamp(d.target)
    end)
    w:_connect(Input.InputEnded,function(input)
        if w._slider and (input==w._slider.input or input.UserInputType==Enum.UserInputType.MouseButton1) then
            w:_tween(w._slider.control.ThumbScale,0.4,{Scale=1},true); w._slider=nil
        end
        if w._drag and (input==w._drag.input or input.UserInputType==Enum.UserInputType.MouseButton1) then w._drag=nil end
    end)
    w:_connect(Input.WindowFocusReleased,function()
        if w._slider then w:_tween(w._slider.control.ThumbScale,0.3,{Scale=1},true) end
        w._slider=nil; w._drag=nil
    end)
    w:_fit(); w:_loader(config)
    w._scale.Scale=w.ReduceMotion and w._baseScale or w._baseScale*0.85
    w:_tween(w._scale,0.6,{Scale=w._baseScale},true)
    return w
end
return FlightUi
