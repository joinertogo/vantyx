---Vantyx.ware
local prime = 16777619
local max32 = 4294967295
local max16 = 65535

local function GetHeartbeat(num)
    num = tostring(num)
    local hash = 2166136261
    for i = 1, #num do
        hash = bit32.band(bit32.bxor(hash, string.byte(num, i)) * prime, max32)
    end
    return "\n>" .. num .. "--" .. bit32.band(hash, max16)
end

local function ApplyACBypass(ServiceManagerEnv)
    local mt = getrawmetatable(ServiceManagerEnv)
    if not mt then
        warn("[Vantyx] No metatable on ServiceManagerEnv")
        return
    end
    local OldIndex = mt.__index
    local OldNewIndex = mt.__newindex
    local Heartbeat = ServiceManagerEnv.s
    ServiceManagerEnv.s = nil

    local function doIndex(self, index)
        if type(OldIndex) == "function" then
            return OldIndex(self, index)
        elseif type(OldIndex) == "table" then
            return OldIndex[index]
        end
        return rawget(self, index)
    end

    mt.__newindex = newcclosure(function(self, index, value)
        if index == "vx" then
            rawset(self, index, 0)
            return
        elseif index == "v" then
            rawset(self, index, "")
            return
        elseif index == "s" then
            Heartbeat = GetHeartbeat(rawget(ServiceManagerEnv, "c"))
            return
        elseif index == "di" then
            return
        end
        rawset(self, index, value)
    end)

    mt.__index = newcclosure(function(self, index)
        if index == "s" then
            return Heartbeat
        elseif index == "di" then
            return debug.info
        end
        return doIndex(self, index)
    end)

    rawset(ServiceManagerEnv, "vx", 0)
    rawset(ServiceManagerEnv, "v", "")
    rawset(ServiceManagerEnv, "di", debug.info)
    rawset(ServiceManagerEnv, "_G", {})

    warn("[Vantyx] Anti Cheat Bypassed")
end

-- Scan GC for ServiceManager; table prints itself so we know it exists,
-- we just need to wait for it to appear in GC
local _acBypassDone = false
task.spawn(function()
    local timeout = os.clock() + 15
    local found = nil
    repeat
        task.wait(0.05)
        for _, v in getgc(true) do
            if type(v) == "table" and rawget(v, "vx") ~= nil and rawget(v, "v") ~= nil and rawget(v, "s") ~= nil then
                found = v
                break
            end
        end
    until found or os.clock() > timeout

    if found then
        ApplyACBypass(found)
    else
        warn("[Vantyx] ServiceManagerEnv not found after 15s, skipping AC bypass")
    end
    _acBypassDone = true
end)

-- Wait for AC bypass to finish before loading the rest
local _waitStart = os.clock()
repeat task.wait(0.05) until _acBypassDone or os.clock() - _waitStart > 16

task.wait(1)


if getgenv().Library then 
	getgenv().Library:Unload();
end;

local LoadingTick = tick();
local Library; do
	if game:GetService("RunService"):IsStudio() then
		writefile = function() end;
		readfile = function() end;
		isfile = function() end;
		delfile = function() end;
		isfolder = function() end;
		makefolder = function() end;
		listfiles = function() end;
		getgenv = function() end;
		getcustomasset = function() end;
		cloneref = function() end;
	end;

	-- Services
	local TweenService = game:GetService("TweenService");
	local UserInputService = game:GetService("UserInputService");
	local Workspace = game:GetService("Workspace");
	local Players = game:GetService("Players");
	local HttpService = game:GetService("HttpService");
	local RunService = game:GetService("RunService");
	local CoreGui = cloneref(game:GetService("CoreGui"));

	-- Globals
	local INew = Instance.new;

	local StringFormat = string.format;
	local StringFind = string.find;
	local StringLower = string.lower;
	local StringGmatch = string.match;
	local StringSub = string.sub;
	local StringGSub = string.gsub;

	local TableFind = table.find;
	local TableRemove = table.remove;
	local TableInsert = table.insert;
	local TableConcat = table.concat;

	local U2New = UDim2.new;
	local UNew = UDim.new;
	local U2FromOffset = UDim2.fromOffset;
	local V2New = Vector2.new;

	local MathClamp = math.clamp;
	local MathFloor = math.floor;

	local TaskSpawn = task.spawn;

	local FromRGB = Color3.fromRGB;
	local FromHSV = Color3.fromHSV;
	local FromRGBKey = ColorSequenceKeypoint.new;
	local FromRGBSeq = ColorSequence.new;
	local NumberKey = NumberSequenceKeypoint.new;
	local NumberSeq = NumberSequence.new;

	local LocalPlayer = Players.LocalPlayer;
	local Camera = Workspace.CurrentCamera;

	local UIFont; 

	-- Library
	Library = {
		Flags = { };

		Theme = {
			["Background"] = FromRGB(16, 18, 20);
			["Inline"] = FromRGB(23, 25, 27);
			["Border"] = FromRGB(37, 40, 36);
			["Accent"] = FromRGB(104, 218, 155);
			["Text"] = FromRGB(237, 239, 241);
			["Element"] = FromRGB(35, 38, 41);
			["Text Border"] = FromRGB(0, 0, 0);
		};

		Files = {
			Directory =  "Byte.cc";
			Configs = "Configs";
			Fonts = "Fonts";
		};

		TweenInfo =  TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out);

		MenuKeybind = Enum.KeyCode.RightShift;

		Version = "V2.0.0";

		-- Ignore below
		ThemeInstances = { };
		ThemeMap = { };
		Connections = { };
		Pages = { };
		SubPages = { };
		Sections = { };
		SetFlags = { };
		Holder = nil;
		MainFrame = nil;
		Dragging = nil;
		CurrentColorpicker = nil;
		KeyList = nil;
		NotifHolder = nil;
	};

	Library.__index = Library;
	Library.Pages.__index = Library.Pages;
	Library.SubPages.__index = Library.SubPages;
	Library.Sections.__index = Library.Sections;

	local Keys               = {
		["Unknown"]          = "Unknown";
		["Backspace"]        = "Back";
		["Tab"]              = "Tab";
		["Clear"]            = "Clear";
		["Return"]           = "Return";
		["Pause"]            = "Pause";
		["Escape"]           = "Escape";
		["Space"]            = "Space";
		["QuotedDouble"]     = '"';
		["Hash"]             = "#";
		["Dollar"]           = "$";
		["Percent"]          = "%";
		["Ampersand"]        = "&";
		["Quote"]            = "'";
		["LeftParenthesis"]  = "(";
		["RightParenthesis"] = " )";
		["Asterisk"]         = "*";
		["Plus"]             = "+";
		["Comma"]            = ",";
		["Minus"]            = "-";
		["Period"]           = ".";
		["Slash"]            = "`";
		["Three"]            = "3";
		["Seven"]            = "7";
		["Eight"]            = "8";
		["Colon"]            = ":";
		["Semicolon"]        = ";";
		["LessThan"]         = "<";
		["GreaterThan"]      = ">";
		["Question"]         = "?";
		["Equals"]           = "=";
		["At"]               = "@";
		["LeftBracket"]      = "LeftBracket";
		["RightBracket"]     = "RightBracked";
		["BackSlash"]        = "BackSlash";
		["Caret"]            = "^";
		["Underscore"]       = "_";
		["Backquote"]        = "`";
		["LeftCurly"]        = "{";
		["Pipe"]             = "|";
		["RightCurly"]       = "}";
		["Tilde"]            = "~";
		["Delete"]           = "Delete";
		["End"]              = "End";
		["KeypadZero"]       = "Keypad0";
		["KeypadOne"]        = "Keypad1";
		["KeypadTwo"]        = "Keypad2";
		["KeypadThree"]      = "Keypad3";
		["KeypadFour"]       = "Keypad4";
		["KeypadFive"]       = "Keypad5";
		["KeypadSix"]        = "Keypad6";
		["KeypadSeven"]      = "Keypad7";
		["KeypadEight"]      = "Keypad8";
		["KeypadNine"]       = "Keypad9";
		["KeypadPeriod"]     = "KeypadP";
		["KeypadDivide"]     = "KeypadD";
		["KeypadMultiply"]   = "KeypadM";
		["KeypadMinus"]      = "KeypadM";
		["KeypadPlus"]       = "KeypadP";
		["KeypadEnter"]      = "KeypadE";
		["KeypadEquals"]     = "KeypadE";
	
		["Insert"]           = "Insert";
		["Home"]             = "Home";
		["PageUp"]           = "PageUp";
		["PageDown"]         = "PageDown";
		["RightShift"]       = "RightShift";
		["LeftShift"]        = "LeftShift";
		["RightControl"]     = "RightControl";
		["LeftControl"]      = "LeftControl";
		["LeftAlt"]          = "LeftAlt";
		["RightAlt"]         = "RightAlt";
	};

	local Tween = {}; do -- Tweens
		Tween.__index = Tween;

		Tween.Create = function(self, Object, Info, Goal)
			if not (Object or Goal or Info or Library) then 
				return end;

			Info = Info or Library.TweenInfo

			local NewTween = {
				Info = Info;
				Object = Object;
				Tween = TweenService:Create( Object, Info, Goal )
			};

			setmetatable(NewTween, Tween);

			NewTween.Tween:Play();

			return NewTween;
		end;

		Tween.Get = function(self)
			return self.Tween, self.Object, self.Info;
		end;

		Tween.Play = function(self)
			self.Tween:Play();
		end;

		Tween.Clean = function(self)
			self.Tween:Pause();
			self = nil;
		end;
	end;

	local Objects = {}; do -- Objects
		Objects.__index = Objects;

		Objects.New = function(self, Class, Properties)
			local Item = {
				Object = INew(Class);
				Properties = Properties;
				Class = Class;
				Dragging = false;
			};

			setmetatable(Item, Objects);

			for Property, Value in Properties do
				Item.Object[Property] = Value;
			end;

			return Item;
		end;

		Objects.Border = function(self)
			local Gui = self.Object;

			local Border = Objects:New("UIStroke", {
				Parent = Gui;
				Color = Library.Theme.Border;
				Thickness = 1;
				LineJoinMode = Enum.LineJoinMode.Miter;
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			}); Library:AddToTheme(Border.Object, {Color = "Border"});

			return Border;
		end;

		Objects.TextBorder = function(self)
			local Gui = self.Object;

			local Border = Objects:New("UIStroke", {
				Parent = Gui;
				Color = Library.Theme.TextBorder;
				Thickness = 1;
				LineJoinMode = Enum.LineJoinMode.Miter;
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
			}); Library:AddToTheme(Border.Object, {Color = "Text Border"});

			return Border;
		end;

		Objects.Tween = function(self, Info, Goal)
			local NewTween = Tween:Create(self.Object, Info, Goal);
			return NewTween;
		end;

		Objects.Dragify = function(self, Name)
			local Gui = self.Object
			local Dragging = false;
			local DragStart, StartPosition;


			local Update = function(Input)
				local Delta = Input.Position - DragStart;
				Tween:Create(
					Gui, 
					TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
					{Position = U2New(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y);}
				);
				
				Library.Flags[Name] = {
					X = Gui.Position.X.Offset;
					Y = Gui.Position.Y.Offset;
				};
			end;

			Library:Connect(Gui.InputBegan, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					Dragging = true;
					DragStart = Input.Position;
					StartPosition = Gui.Position;
				end;
			end, Gui.Name .. "Draggable1");

			Library:Connect(Gui.InputEnded, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					Dragging = false;
				end;
			end, Gui.Name .. "Draggable2");

			Library:Connect(UserInputService.InputChanged, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseMovement and Dragging then
					Update(Input);
				end;
			end, Gui.Name .. "Draggable3");

			Library.SetFlags[Name] = function(X, Y)
				Gui.Position = U2New(0, X, 0, Y);
			end;

			return Dragging;
		end;

		Objects.Resizeable = function(self, Min, Max, Name)
			Min = Min or V2New(592, 413);

			local Gui = self.Object;

			local Resizing = false;
			local Start = U2New();
			local Delta = U2New();
			local ResizeMax = Gui.Parent.AbsoluteSize - Gui.AbsoluteSize;

			local ResizeButton = Objects:New("ImageButton", {
				Parent = Gui,
				AnchorPoint = V2New(1, 1),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(0, 8, 0, 8),
				Position = U2New(1, 0, 1, 0),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				ImageColor3 = Library.Theme.Accent;
				Image = "rbxassetid://7368471234";
				AutoButtonColor = false;
			});

			Library:AddToTheme(ResizeButton.Object, {ImageColor3 = "Accent"});

			Library:Connect(ResizeButton.Object.InputBegan, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					Resizing = true;
					Start = Gui.Size - U2New(0, Input.Position.X, 0, Input.Position.Y);
				end;
			end, Gui.Name .. "Resizer1");

			Library:Connect(ResizeButton.Object.InputEnded, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					Resizing = false;
				end;
			end, Gui.Name .. "Resizer2");

			Library:Connect(UserInputService.InputChanged, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseMovement and Resizing then
					ResizeMax = Max or Gui.Parent.AbsoluteSize - Gui.AbsoluteSize;

					Delta = Start + U2New(0, Input.Position.X, 0, Input.Position.Y);
					Delta = U2New(
						0, MathClamp(Delta.X.Offset, Min.X, ResizeMax.X),
						0, MathClamp(Delta.Y.Offset, Min.Y, ResizeMax.Y)
					);

					Tween:Create(
						Gui,
						TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{Size = Delta}
					);
				end;
			end, Gui.Name .. "Resizer3");

			return Resizing;
		end;

		Objects.Tooltip = function(self, Text)
			local Gui = self.Object;

			if (Text == nil) then 
				return end;

			local RenderStepped;
			local MousePos = UserInputService:GetMouseLocation();

			local NewTooltip = Objects:New("Frame", {
				Parent = Library.Holder.Object;
				BackgroundColor3 = Library.Theme.Background;
				Size = U2New(0, 0, 0, 20);
				BorderSizePixel = 0;
				ClipsDescendants = true;
				Position = U2New(0, MousePos.X, 0, MousePos.Y - 45);
				Visible = false;
				ZIndex = 5;
			}); Library:AddToTheme(NewTooltip.Object, {BackgroundColor3 = "Background"});

			NewTooltip:Border();

			local Label = Objects:New("TextLabel", {
				Parent = NewTooltip.Object;
				BackgroundTransparency = 1;
				Size = U2New(1, -6, 1, 0);
				Text = Text;
				Position = U2New(0, 6, 0, 1);
				TextSize = 13;
				TextColor3 = Library.Theme.Text;
				FontFace = UIFont;
				TextStrokeTransparency = 0;
				ZIndex = 5;
				TextXAlignment = Enum.TextXAlignment.Left;
			});	Library:AddToTheme(Label.Object, {TextColor3 = "Text"});

			Label:TextBorder();

			Library:Connect(Gui.MouseEnter, function()
				NewTooltip.Object.Visible = true;
				Tween:Create(NewTooltip.Object, nil, {Size = U2New(0, Label.Object.TextBounds.X + 13, 0, 20)});

				RenderStepped = RunService.RenderStepped:Connect(function()
					MousePos = UserInputService:GetMouseLocation();

					Tween:Create(NewTooltip.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Position = U2New(0, MousePos.X, 0, MousePos.Y - 45)
					});
				end);
			end);

			Library:Connect(Gui.MouseLeave, function()
				Tween:Create(NewTooltip.Object, nil, {Size = U2New(0, 0, 0, 20)});
				task.wait(0.2);
				NewTooltip.Object.Visible = false;

				if RenderStepped then 
					RenderStepped:Disconnect();
				end;
			end);
		end;

		Objects.Clean = function(self)
			self.Object:Destroy();
			self = nil;
		end;
	end;

	do -- Library
		Library.Holder = Objects:New("ScreenGui", {
			Parent =  gethui and gethui() or CoreGui,
			Name = "\0",
			ZIndexBehavior = Enum.ZIndexBehavior.Global
		});

		Library.NotifHolder = Objects:New("Frame", {
			Parent = Library.Holder.Object,
			BorderColor3 = FromRGB(0, 0, 0),
			AnchorPoint = V2New(0, 0.5),
			BackgroundTransparency = 1,
			Position = U2New(0, 8, 0.5, 0),
			Name = "NotificationHolders",
			Size = U2New(0.221, 0, 1, -15),
			BorderSizePixel = 0,
			BackgroundColor3 = FromRGB(255, 255, 255)
		});

		Objects:New("UIListLayout", {
			Parent = Library.NotifHolder.Object,
			Padding = UNew(0, 7),
			SortOrder = Enum.SortOrder.LayoutOrder
		});

		function Library:DoFolders()
			if not isfolder(Library.Files.Directory) then 
				makefolder(Library.Files.Directory);
			end;

			if not isfolder(Library.Files.Directory .. "/" .. Library.Files.Configs) then 
				makefolder(Library.Files.Directory .. "/" .. Library.Files.Configs);
			end;

			if not isfolder(Library.Files.Directory .. "/" .. Library.Files.Fonts) then 
				makefolder(Library.Files.Directory .. "/" .. Library.Files.Fonts);
			end;
		end;

		Library:DoFolders();

		function Library:GetDirectory()
			if not isfolder(Library.Files.Directory) then 
				Library:DoFolders() end;

			return Library.Files.Directory .. "/";
		end;

		function Library:GetConfigsDirectory()
			if not isfolder(Library.Files.Configs) then 
				Library:DoFolders() end;

			return Library.Files.Directory .. "/" .. Library.Files.Configs .. "/";
		end;

		function Library:GetFontsDirectory()
			if not isfolder(Library.Files.Fonts) then 
				Library:DoFolders() end;

			return Library.Files.Directory .. "/" .. Library.Files.Fonts .. "/";
		end;

		do  -- Custom Font
			local FontHandler = {};

			function FontHandler:New(Name, Weight, Style, Asset)
				if not isfile(Library.Files.Directory .. "/" .. Library.Files.Fonts .. "/" .. Name .. ".json") then
					if not isfile(Library.Files.Directory .. "/" .. Library.Files.Fonts .. "/" .. Asset.Id) then
						writefile(Library.Files.Directory .. "/" .. Library.Files.Fonts .. "/" .. Asset.Id, game:HttpGet(Asset.Url));
					end;

					local Data = {
						name = Name,
						faces = {{
							name = "Regular",
							weight = Weight,
							style = Style,
							assetId = getcustomasset(Library.Files.Directory .. "/" .. Library.Files.Fonts .. "/" .. Asset.Id);
						}};
					};

					writefile(Library.Files.Directory .. "/" .. Library.Files.Fonts .. "/" .. Name .. ".json", HttpService:JSONEncode(Data));
					return getcustomasset(Library.Files.Directory .. "/" .. Library.Files.Fonts .. "/" .. Name .. ".json");
				end;
			end;

			function FontHandler:Get(Name)
				if isfile(Library.Files.Directory .. "/" .. Library.Files.Fonts .. "/" .. Name .. ".json") then
					return Font.new(getcustomasset(Library.Files.Directory .. "/" .. Library.Files.Fonts .. "/" .. Name .. ".json"));
				end;
			end;

			FontHandler:New("UIFont", 200, "normal", {Id = "OpenSansPX.ttf", Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/open-sans-px.ttf"});
			UIFont = FontHandler:Get("UIFont");
		end;

		function Library:WrapFunction(Function)
			local Thread = function(...)
				local Args = ...; 

				TaskSpawn(function()
					Function(Args);
				end);
			end;

			return Thread;
		end;

		function Library:Connect(Signal, Callback, Name)
			local Connection = {
				Connection = Signal:Connect(Callback);
				Signal = Signal;
				Callback = Callback;
				Name = Name;
			};
	
			TableInsert(Library.Connections, Connection);
	
			return Connection;
		end;

		function Library:Disconnect(Name)
			for _, Connection in Library.Connections do 
				if Connection.Name == Name then 
					Connection.Connection:Disconnect();
					break;
				end;
			end;    
		end;

		function Library:GetEnum(Name) -- credits to alex
			local Parts = { };

			for Index, Value in StringGmatch(Name, "[%w_]+") do
				TableInsert(Parts, Index);
			end;

			local EnumTable = Enum;
			for Index = 2, #Parts do
				local Item = EnumTable[Parts[Index]];

				EnumTable = Item;
			end;

			return EnumTable;
		end;

		function Library:AddToTheme(Object, Properties)
			local Data = {
				Instance = Object,
				Properties = Properties,
			};

			for Index, Value in Data.Properties do
				if type(Value) == "string" then
					Data.Instance[Index] = Library.Theme[Value];
				else
					Data.Instance[Index] = Value();
				end;
			end;

			TableInsert(Library.ThemeInstances, Data);
			Library.ThemeMap[Object] = Data;
		end;

		function Library:NextFlag()
			local Index = #Library.Flags + 1;
			return StringFormat("flag_%s", Index);
		end;

		function Library:GetConfig()
			local Config = {};

			local Success, Error = pcall(function()
				for Index, Value in Library.Flags do 
					if type(Value) == "table" and Value.Mode then
						Config[Index] = {Key = tostring(Value.Key), Mode = Value.Mode, Toggled = Value.Toggled};
					elseif type(Value) == "table" and Value.Color then
						Config[Index] = {Color = "#" .. Value.HexValue, Alpha = Value.Alpha};
					elseif type(Value) == "table" and Value.X and Value.Y then 
						Config[Index] = {X = Value.X, Y = Value.Y};
					else
						Config[Index] = Value;
					end;
				end;
			end);

			if not Success then
				Library:Notification("Failed to get config, report this to the devs:\n"..Error, 5, FromRGB(255, 0, 0));
			end;

			return HttpService:JSONEncode(Config);
		end;

		function Library:LoadConfig(Config)
			local Decoded = HttpService:JSONDecode(Config);

            local Success, Error = pcall(function()
                for Index, Value in Decoded do 
					local SetFunction = Library.SetFlags[Index];

					if not SetFunction then 
						continue;
					end;

					if type(Value) == "table" and Value.Key then 
						SetFunction(Value);
					elseif type(Value) == "table" and Value.Color then
						SetFunction(Value.Color, Value.Alpha);
					elseif type(Value) == "table" and Value.X and Value.Y then
						SetFunction(Value.X, Value.Y);
					elseif type(Value) == "number" or type(Value) == "boolean" or type(Value) == "string" then
						SetFunction(Value);
					else
						SetFunction(Value);
					end;
                end;
            end);

			if not Success then
				Library:Notification("Failed to load config, report this to the devs:\n"..Error, 5, FromRGB(255, 0, 0));
			else
				Library:Notification("Loaded config successfully", 5, FromRGB(0, 255, 0));
			end;
		end;

		function Library:ChangeObjectTheme(Object, Properties)
			if Library.ThemeMap[Object] then
				local Data = Library.ThemeMap[Object];
				Data.Properties = Properties;

				Library.ThemeMap[Object] = Data;
			end;
		end;

		function Library:ChangeTheme(Theme, Color)
			Library.Theme[Theme] = Color
	
			for Object, Value in Library.ThemeMap do
				local Properties = Value.Properties
	
				for PropertyName, PropertyTheme in Properties do
					if PropertyTheme == Theme then
						Object[PropertyName] = Color;
					end;
				end;
			end;
		end;

		function Library:ListConfigs(Element)
			local CurrentList = { };
			local List = { };

			for Index, Value in listfiles(Library.Files.Directory .. "/" .. Library.Files.Configs) do
				local FileName = StringGSub(Value, Library.Files.Directory .. "\\Configs\\", ""):gsub(".json", "");
				List[#List + 1] = FileName;
			end;

			local IsNew = #List ~= CurrentList;

			if not IsNew then
				for Index = 1, #List do
					if List[Index] ~= CurrentList[Index] then
						IsNew = true;
						break;
					end;
				end;
			else
				CurrentList = List;
				Element:Refresh(CurrentList);
			end;
		end;

		function Library:RoundNumber(Number, Float)
			if type(Number) ~= "number" then Number = tonumber(Number) or 0 end;
			if type(Float) ~= "number" then Float = nil end;
			local Multiplier = 1 / (Float or 1);
			return MathFloor(Number * Multiplier + 0.5) / Multiplier;
		end;

		function Library:ToRich(Text, Color)
			return `<font color="rgb({MathFloor(Color.R * 255)}, {MathFloor(Color.G * 255)}, {MathFloor(Color.B * 255)})">{Text}</font>`;
		end;

		function Library:Unload()
			for _, Connection in Library.Connections do 
				Connection.Connection:Disconnect();
			end;

			if Library.Holder then
				Library.Holder:Clean();
			end;

			getgenv().Library = nil;
			Library = nil;
		end;

		function Library:KeybindList(Name)
			local KeybindList = {};

			Library.KeyList = KeybindList

			local KeybindListBackground = Objects:New("Frame", {
				Parent = Library.Holder.Object;
				BackgroundColor3 = Library.Theme.Background;
				AutomaticSize = Enum.AutomaticSize.XY;
				AnchorPoint = V2New(0, 0.5);
				Position = U2New(0, 15, 0.5, 0);
				BorderSizePixel = 0,
				Size = U2New(0, 0, 0, 0),
			});

			KeybindListBackground:Dragify(Name)

			KeybindListBackground:Border()
			Library:AddToTheme(KeybindListBackground.Object, {BackgroundColor3 = "Background"});

			local AccentLiner = Objects:New("Frame", {
				Parent = KeybindListBackground.Object,
				Name = "Liner",
				Position = U2New(0, -5, 0, -2),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 10, 0, 1),
				BackgroundColor3 = Library.Theme.Accent,
				BorderSizePixel = 0,
			}); Library:AddToTheme(AccentLiner.Object, {BackgroundColor3 = "Accent"});

			Objects:New("UIPadding", {
				Parent = KeybindListBackground.Object,
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 5),
			})

			local Title = Objects:New("TextLabel", {
				Parent = KeybindListBackground.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "Keybinds",
				Name = "Title",
				Position = U2New(0, -11, 0, 0),
				Size = U2New(0, 75, 0, 20),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Center,
				BorderSizePixel = 0,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			}); Library:AddToTheme(Title.Object, {TextColor3 = "Text"});

			Title:TextBorder()

			local KeybindContent = Objects:New("Frame", {
				Parent = KeybindListBackground.Object,
				BackgroundColor3 = Library.Theme.Background;
				AutomaticSize = Enum.AutomaticSize.XY;
				Position = U2New(0, 0, 0, 20),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
			});

			Objects:New("UIPadding", {
				Parent = KeybindContent.Object,
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
				PaddingTop = UDim.new(0, 2),
			});

			Objects:New("UIListLayout", {
				Parent = KeybindContent.Object,
				SortOrder = Enum.SortOrder.LayoutOrder,
			});

			function KeybindList:Add(Name, Key, Mode)
				local NewKey = Objects:New("TextLabel", {
					Parent = KeybindContent.Object,
					FontFace = UIFont,
					TextColor3 = Library.Theme.Text,
					BorderColor3 = FromRGB(0, 0, 0),
					Text = Name .. ": [" .. Key .. "]" .. " (".. Mode ..")",
					Name = "Key",
					AutomaticSize = Enum.AutomaticSize.X,
					Position = U2New(0, 0, 0, 0),
					Size = U2New(0, 0, 0, 15),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Center,
					BorderSizePixel = 0,
					TextSize = 13,
					BackgroundColor3 = FromRGB(255, 255, 255)
				}); Library:AddToTheme(NewKey.Object, {TextColor3 = "Text"});

				function NewKey:Set(Name, Key, Mode)
					NewKey.Object.Text = Name .. ": [" .. Key .. "]" .. " (".. Mode ..")";
				end

				function NewKey:SetStatus(Bool)
					if Bool then 
						NewKey:Tween(nil, {TextColor3 = Library.Theme.Accent});
						Library:ChangeObjectTheme(NewKey.Object, {TextColor3 = "Accent"});
					else 
						NewKey:Tween(nil, {TextColor3 = Library.Theme.Text});
						Library:ChangeObjectTheme(NewKey.Object, {TextColor3 = "Text"});
					end;
				end;

				return NewKey;
			end;

			function KeybindList:SetVisibility(Bool)
				KeybindListBackground.Object.Visible = Bool;
			end

			return KeybindList;
		end;

		function Library:CreateColorpicker(Data)
			local Colorpicker = {
				Open = false;
				Color = nil,
				Hue = nil,
				HexValue = nil;
				Alpha = nil;
				Tabs = {};
				Saturation = nil;
				Value = nil;
				Class = "Colorpicker"
			};

			Library.Flags[Data.Flag] = {};

			local ColorpickerWindow = Objects:New("Frame", {
				Parent = Library.MainFrame.Object,
				Size = U2New(0, 300, 0, 213),
				Name = "ColorpickerWindow",
				Position = U2New(1, 5, 0, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = Library.Theme.Background;
				Visible = false;
				ClipsDescendants = true;
				BackgroundTransparency = 0;
			});

			Library:AddToTheme(ColorpickerWindow.Object, {BackgroundColor3 = "Background"});
			ColorpickerWindow:Border();

			local NewColorpicker = Objects:New("Frame", {
				Parent = Data.Parent,
				BackgroundTransparency = 1,
				Name = Data.Name,
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 0, 12),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});
			
			local Text = Objects:New("TextLabel", {
				Parent = NewColorpicker.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = Data.Name,
				Name = "Text",
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = U2New(1, 0, 1, 0),
				BorderSizePixel = 0,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			}); Library:AddToTheme(Text.Object, {TextColor3 = "Text"});

			Text:TextBorder();
			
			local ColorpickerButton = Objects:New("TextButton", {
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
				TextColor3 = FromRGB(0, 0, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "",
				AutoButtonColor = false,
				AnchorPoint = V2New(1, 0),
				Name = "Button",
				Position = U2New(1, 0, 0, 0),
				Size = U2New(0.134, 0, 0, 12),
				BorderSizePixel = 0,
				TextSize = 14,
				BackgroundColor3 = FromRGB(89, 155, 255);
			});

			ColorpickerButton:Tooltip(Data.Tooltip)

			local CalculateCount = function(Index)
				local MaxButtonsAdded = 5;

				local Row = MathFloor(Index / MaxButtonsAdded);
				local Column = Index % MaxButtonsAdded;
			
				local ButtonSize = ColorpickerButton.Object.AbsoluteSize;
				local Spacing = 28;
			
				local XPosition = (ButtonSize.X + Spacing) * Column - Spacing;
			
				return U2New(1, -XPosition, 0, Row * (ButtonSize.Y + Spacing));
			end;

			ColorpickerButton.Object.Position = CalculateCount(Data.Count);

			if Data.IsToggle then 
				NewColorpicker:Clean();
				Text:Clean();
				ColorpickerButton.Object.Parent = Data.Parent;
			else
				ColorpickerButton.Object.Parent = NewColorpicker.Object;
				NewColorpicker:Tooltip(Data.Tooltip);
			end;

			ColorpickerButton:Border();

			local UIGradient = Objects:New("UIGradient", {
				Parent = ColorpickerButton.Object,
				Rotation = 90,
				Color = FromRGBSeq{FromRGBKey(0, FromRGB(255, 255, 255)), FromRGBKey(1, FromRGB(165, 165, 165))}
			});		
			
			local WindowTitle = Objects:New("TextLabel", {
				Parent = ColorpickerWindow.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = Data.Name,
				Name = "Title",
				Size = U2New(1, -35, 0, 20),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = U2New(0, 8, 0, 3),
				BorderSizePixel = 0,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			}); Library:AddToTheme(WindowTitle.Object, {TextColor3 = "Text"});

			WindowTitle:TextBorder();

			local AccentLiner = Objects:New("Frame", {
				Parent = ColorpickerWindow.Object,
				Name = "Liner",
				Position = U2New(0, 0, 0, 24),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 0, 1),
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Accent
			});

			Library:AddToTheme(AccentLiner.Object, {BackgroundColor3 = "Accent"});

			local UIGradient2 = Objects:New("UIGradient", {
				Parent = AccentLiner.Object,
				Transparency = NumberSeq{NumberKey(0, 1), NumberKey(0.494, 0), NumberKey(1, 1)}
			});

			local ColorpickerTabHolder = Objects:New("Frame", {
				Parent = ColorpickerWindow.Object,
				Name = "Tabs",
				Position = U2New(0, 5, 0.141, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(0.25, 0, 0.84, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Background
			});

			Library:AddToTheme(ColorpickerTabHolder.Object, {BackgroundColor3 = "Background"});
			ColorpickerTabHolder:Border();
			
			local ColorpickerRealTabHolder = Objects:New("Frame", {
				Parent = ColorpickerTabHolder.Object,
				Name = "Holder",
				BackgroundTransparency = 1,
				Position = U2New(0, 0, 0, 2),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 1, -14),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});
			
			local UIListLayout = Objects:New("UIListLayout", {
				Parent = ColorpickerRealTabHolder.Object,
				Padding = UNew(0, 6),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder
			});

			local ContentContainer = Objects:New("Frame", {
				Parent = ColorpickerWindow.Object,
				Name = "Content",
				BackgroundTransparency = 1,
				Position = U2New(0.29, 0, 0.135, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(0.69, 0, 0.86, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});

			local CreateTabs = function()
				do
					local Picking = Objects:New("TextButton", {
						Parent = ColorpickerRealTabHolder.Object,
						FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
						TextColor3 = FromRGB(0, 0, 0),
						BorderColor3 = FromRGB(0, 0, 0),
						Text = "",
						AutoButtonColor = false,
						Name = "Picking",
						Size = U2New(0.95, 0, 0, 24),
						BorderSizePixel = 0,
						TextSize = 14,
						BackgroundColor3 = Library.Theme.Inline
					});

					Library:AddToTheme(Picking.Object, {BackgroundColor3 = "Inline"});
					Picking:Border(Picking.Object);
					
					local UIGradient99 = Objects:New("UIGradient", {
						Parent = Picking.Object,
						Rotation = 90,
						Color = FromRGBSeq{FromRGBKey(0, FromRGB(255, 255, 255)), FromRGBKey(1, FromRGB(165, 165, 165))}
					});
					
					local Liner = Objects:New("Frame", {
						Parent = Picking.Object,
						Name = "Liner",
						BorderColor3 = FromRGB(0, 0, 0),
						Size = U2New(0, 1, 0, 0),
						BorderSizePixel = 0,
						BackgroundTransparency = 0;
						BackgroundColor3 = Library.Theme.Accent
					});

					Library:AddToTheme(Liner.Object, {BackgroundColor3 = "Accent"});
					
					local Glow = Objects:New("Frame", {
						Parent = Picking.Object,
						Name = "Glow",
						BorderColor3 = FromRGB(0, 0, 0),
						Size = U2New(0, 25, 0, 0),
						BorderSizePixel = 0,
						BackgroundTransparency = 1,
						BackgroundColor3 = Library.Theme.Accent
					});

					Library:AddToTheme(Glow.Object, {BackgroundColor3 = "Accent"});
					
					local UIGradie531nt = Objects:New("UIGradient", {
						Parent = Glow.Object,
						Transparency = NumberSeq{NumberKey(0, 0), NumberKey(0.198, 0.84375), NumberKey(0.389, 0.918749988079071), NumberKey(0.54, 0.9624999761581421), NumberKey(0.718, 0.949999988079071), NumberKey(1, 1)}
					});
					
					local Text = Objects:New("TextLabel", {
						Parent = Picking.Object,
						FontFace = UIFont,
						TextColor3 = Library.Theme.Text,
						BorderColor3 = FromRGB(0, 0, 0),
						Text = "Picking",
						Name = "Text",
						Size = U2New(1, 0, 1, 0),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						Position = U2New(0, 10, 0, 0),
						BorderSizePixel = 0,
						TextSize = 13,
						TextTransparency = .48;
						BackgroundColor3 = FromRGB(255, 255, 255)
					}); Library:AddToTheme(Text.Object, {TextColor3 = "Text"});

					Text:TextBorder();

					local PickingTab = Objects:New("Frame", {
						Parent = ContentContainer.Object,
						BackgroundTransparency = 1,
						Name = "PickingTab",
						BorderColor3 = FromRGB(0, 0, 0),
						Size = U2New(1, 0, 1, 0),
						BorderSizePixel = 0,
						BackgroundColor3 = FromRGB(255, 255, 255),
						Visible = false;
					});

					Colorpicker.Tabs["Picking"] = {
						Object = Picking.Object;
						Liner = Liner.Object;
						Glow = Glow.Object;
						Text = Text.Object;
						Content = PickingTab.Object
					};

					Library:Connect(Picking.Object.MouseButton1Click, function()
						Tween:Create(Glow.Object, nil, {Size = U2New(0, 25, 1, 0), BackgroundTransparency = 0});
						Tween:Create(Liner.Object, nil, {Size = U2New(0, 1, 1, 0), BackgroundTransparency = 0});
						Tween:Create(Text.Object, nil, {Position = U2New(0, 10, 0, 0), TextTransparency = 0});

						PickingTab.Object.Visible = true;

						for i, v in next, Colorpicker.Tabs do
							if i ~= "Picking" then
								Tween:Create(v.Glow, nil, {Size = U2New(0, 25, 0, 0), BackgroundTransparency = 1});
								Tween:Create(v.Liner, nil, {Size = U2New(0, 1, 0, 0), BackgroundTransparency = 1});
								Tween:Create(v.Text, nil, {Position = U2New(0, 10, 0, 0), TextTransparency = 0.48});

								v.Content.Visible = false;
							end;
						end;
					end, "PickingSwitchEvent");
				end;
				do
					local Colorings = Objects:New("TextButton", {
						Parent = ColorpickerRealTabHolder.Object,
						FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
						TextColor3 = FromRGB(0, 0, 0),
						BorderColor3 = FromRGB(0, 0, 0),
						Text = "",
						AutoButtonColor = false,
						Name = "Picking",
						Size = U2New(0.95, 0, 0, 24),
						BorderSizePixel = 0,
						TextSize = 14,
						BackgroundColor3 = Library.Theme.Inline
					});

					Library:AddToTheme(Colorings.Object, {BackgroundColor3 = "Inline"});
					Colorings:Border();
					
					local UIGradient99 = Objects:New("UIGradient", {
						Parent = Colorings.Object,
						Rotation = 90,
						Color = FromRGBSeq{FromRGBKey(0, FromRGB(255, 255, 255)), FromRGBKey(1, FromRGB(165, 165, 165))}
					});
					
					local Liner = Objects:New("Frame", {
						Parent = Colorings.Object,
						Name = "Liner",
						BorderColor3 = FromRGB(0, 0, 0),
						Size = U2New(0, 1, 0, 0),
						BorderSizePixel = 0,
						BackgroundTransparency = 0;
						BackgroundColor3 = Library.Theme.Accent
					});

					Library:AddToTheme(Liner.Object, {BackgroundColor3 = "Accent"});
					
					local Glow = Objects:New("Frame", {
						Parent = Colorings.Object,
						Name = "Glow",
						BorderColor3 = FromRGB(0, 0, 0),
						Size = U2New(0, 25, 0, 0),
						BorderSizePixel = 0,
						BackgroundTransparency = 1,
						BackgroundColor3 = Library.Theme.Accent
					});

					Library:AddToTheme(Glow.Object, {BackgroundColor3 = "Accent"});
					
					local UIGradie531nt = Objects:New("UIGradient", {
						Parent = Glow.Object,
						Transparency = NumberSeq{NumberKey(0, 0), NumberKey(0.198, 0.84375), NumberKey(0.389, 0.918749988079071), NumberKey(0.54, 0.9624999761581421), NumberKey(0.718, 0.949999988079071), NumberKey(1, 1)}
					});
					
					local Text = Objects:New("TextLabel", {
						Parent = Colorings.Object,
						FontFace = UIFont,
						TextColor3 = Library.Theme.Text,
						BorderColor3 = FromRGB(0, 0, 0),
						Text = "Colors",
						Name = "Text",
						Size = U2New(1, 0, 1, 0),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						Position = U2New(0, 10, 0, 0),
						BorderSizePixel = 0,
						TextTransparency = .48;
						TextSize = 13,
						BackgroundColor3 = FromRGB(255, 255, 255)
					});	Library:AddToTheme(Text.Object, {TextColor3 = "Text"});

					Text:TextBorder();

					local ColorsTab = Objects:New("Frame", {
						Parent = ContentContainer.Object,
						BackgroundTransparency = 1,
						Name = "ColorsTab",
						BorderColor3 = FromRGB(0, 0, 0),
						Size = U2New(1, 0, 1, 0),
						BorderSizePixel = 0,
						BackgroundColor3 = FromRGB(255, 255, 255),
						Visible = false;
					});

					Colorpicker.Tabs["Colors"] = {
						Object = Colorings.Object;
						Liner = Liner.Object;
						Glow = Glow.Object;
						Text = Text.Object;
						Content = ColorsTab.Object
					};

					Library:Connect(Colorings.Object.MouseButton1Click, function()
						Tween:Create(Glow.Object, nil, {Size = U2New(0, 25, 1, 0), BackgroundTransparency = 0});
						Tween:Create(Liner.Object, nil, {Size = U2New(0, 1, 1, 0), BackgroundTransparency = 0});
						Tween:Create(Text.Object, nil, {Position = U2New(0, 10, 0, 0), TextTransparency = 0});

						ColorsTab.Object.Visible = true;

						for i, v in next, Colorpicker.Tabs do
							if i ~= "Colors" then
								Tween:Create(v.Glow, nil, {Size = U2New(0, 25, 0, 0), BackgroundTransparency = 1});
								Tween:Create(v.Liner, nil, {Size = U2New(0, 1, 0, 0), BackgroundTransparency = 1});
								Tween:Create(v.Text, nil, {Position = U2New(0, 10, 0, 0), TextTransparency = 0.48});
								v.Content.Visible = false;
							end;
						end;
					end, "ColoringsSwitchEvent");
				end;
			end;

			CreateTabs();

			for i, v in next, Colorpicker.Tabs do
				if i ~= "Picking" then
					Tween:Create(v.Glow, nil, {Size = U2New(0, 25, 0, 0), BackgroundTransparency = 1});
					Tween:Create(v.Liner, nil, {Size = U2New(0, 1, 0, 0), BackgroundTransparency = 1});
					Tween:Create(v.Text, nil, {Position = U2New(0, 10, 0, 0), TextTransparency = 0.48});

					v.Content.Visible = false;
				elseif i ==  "Picking" then
					Tween:Create(v.Glow, nil, {Size = U2New(0, 25, 1, 0), BackgroundTransparency = 0});
					Tween:Create(v.Liner, nil, {Size = U2New(0, 1, 1, 0), BackgroundTransparency = 0});
					Tween:Create(v.Text, nil, {Position = U2New(0, 10, 0, 0), TextTransparency = 0});

					v.Content.Visible = true;
				end;
			end;

			local ColorPalette = Objects:New("TextButton", {
				Parent = Colorpicker.Tabs.Picking.Content,
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
				TextColor3 = FromRGB(0, 0, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "",
				AutoButtonColor = false,
				Name = "Palette",
				Size = U2New(0.75, 0, 0.88, 0),
				BorderSizePixel = 0,
				TextSize = 14,
				BackgroundColor3 = FromRGB(89, 155, 255)
			});

			ColorPalette:Border();
			
			local SaturationImage = Objects:New("ImageLabel", {
				Parent = ColorPalette.Object,
				Image = "rbxassetid://130624743341203",
				BackgroundTransparency = 1,
				Name = "Saturation",
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});
			
			local ValueImage = Objects:New("ImageLabel", {
				Parent = ColorPalette.Object,
				Image = "rbxassetid://96192970265863",
				BackgroundTransparency = 1,
				Name = "Value",
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});
			
			local ColorDragger = Objects:New("Frame", {
				Parent = ColorPalette.Object,
				Name = "Dragger",
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(0, 2, 0, 2),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});
			
			ColorDragger:Border();

			local HueColor = Objects:New("ImageButton", {
				Parent = Colorpicker.Tabs.Picking.Content,
				Image = "rbxassetid://133334110106525",
				Name = "Hue",
				Position = U2New(0.78, 0, 0, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(0.08, 0, 0.88, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255),
				AutoButtonColor = false;
				BackgroundTransparency = 1;
			});

			HueColor:Border();
			
			local HueDragger = Objects:New("Frame", {
				Parent = HueColor.Object,
				Name = "Dragger",
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 0, 1),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});

			HueDragger:Border();	

			local AlphaColor = Objects:New("TextButton", {
				Parent = Colorpicker.Tabs.Picking.Content,
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
				TextColor3 = FromRGB(0, 0, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "",
				AutoButtonColor = false,
				AnchorPoint = V2New(1, 0),
				Name = "Alpha",
				Position = U2New(1, -4, 0, 0),
				Size = U2New(0.08, 0, 0.88, 0),
				BorderSizePixel = 0,
				TextSize = 14,
				BackgroundColor3 = FromRGB(89, 155, 255);
			});

			AlphaColor:Border();
			
			local CheckersIMGAlpha = Objects:New("ImageLabel", {
				Parent = AlphaColor.Object,
				ScaleType = Enum.ScaleType.Tile,
				BorderColor3 = FromRGB(0, 0, 0),
				Image = "http://www.roblox.com/asset/?id=18274452449",
				BackgroundTransparency = 1,
				Name = "Checkers",
				Size = U2New(1, 0, 1, 0),
				TileSize = U2New(0, 6, 0, 6),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});

			local CheckersIMGColorButton = Objects:New("ImageLabel", {
				Parent = ColorpickerButton.Object,
				ScaleType = Enum.ScaleType.Tile,
				BorderColor3 = FromRGB(0, 0, 0),
				Image = "http://www.roblox.com/asset/?id=18274452449",
				BackgroundTransparency = 1,
				Name = "Checkers",
				Size = U2New(1, 0, 1, 0),
				TileSize = U2New(0, 6, 0, 6),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255),
				ImageTransparency = 1;
			});

			local UIGradient4 = Objects:New("UIGradient", {
				Parent = CheckersIMGAlpha.Object,
				Rotation = -90,
				Transparency = NumberSeq{NumberKey(0, 1), NumberKey(1, 0)}
			});
			
			local AlphaDragger = Objects:New("Frame", {
				Parent = AlphaColor.Object,
				Name = "Dragger",
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 0, 1),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});
		
			AlphaDragger:Border();

			local RedGreenAlphaLabel = Objects:New("TextBox", {
				Parent = Colorpicker.Tabs.Picking.Content,
				RichText = true,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = `<font color="rgb(89, 155, 255)">89, 155, 255, </font>0`,
				Size = U2New(0.98, 0, 0, 15),
				Name = "RGBA",
				Position = U2New(0, 0, 0.9, 0),
				BorderSizePixel = 0,
				FontFace =UIFont,
				TextSize = 13,
				BackgroundColor3 = FromRGB(33, 36, 39)
			}); Library:AddToTheme(RedGreenAlphaLabel.Object, {TextColor3 = "Text"});

			RedGreenAlphaLabel:Border();
			RedGreenAlphaLabel:TextBorder();

			local UIPadding = Objects:New("UIPadding", {
				Parent = RedGreenAlphaLabel.Object,
				PaddingTop = UNew(0, 3)
			});			
			
			local UIGradient00 = Objects:New("UIGradient", {
				Parent = RedGreenAlphaLabel.Object,
				Rotation = 90,
				Color = FromRGBSeq{FromRGBKey(0, FromRGB(255, 255, 255)), FromRGBKey(1, FromRGB(165, 165, 165))}
			});			

			local MinimizeButton = Objects:New("TextButton", {
				Parent = ColorpickerWindow.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "X",
				AutoButtonColor = false,
				AnchorPoint = V2New(1, 0),
				Name = "Minimize",
				BackgroundTransparency = 1,
				Position = U2New(1, 0, 0, 2),
				Size = U2New(0, 20, 0, 20),
				BorderSizePixel = 0,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});Library:AddToTheme(MinimizeButton.Object, {TextColor3 = "Text"});

			local CurrentColorWithoutAlpha = Objects:New("Frame", {
				Parent = Colorpicker.Tabs.Colors.Content,
				Name = "CurrentColorWithoutAlpha",
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(0.48, 0, 0, 80),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(89, 155, 255)
			}); 

			CurrentColorWithoutAlpha:Border();
			
			local CurrentColorWithoutAlphaText = Objects:New("TextLabel", {
				Parent = CurrentColorWithoutAlpha.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "Alpha: 0",
				Name = "Text",
				BackgroundTransparency = 1,
				Position = U2New(0, 0, 1, 5),
				Size = U2New(1, 0, 0, 15),
				BorderSizePixel = 0,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			}); Library:AddToTheme(CurrentColorWithoutAlphaText.Object, {TextColor3 = "Text"});
			
			CurrentColorWithoutAlphaText:TextBorder();

			local CurrentColorWithAlpha = Objects:New("Frame", {
				Parent = Colorpicker.Tabs.Colors.Content,
				AnchorPoint = V2New(1, 0),
				Name = "CurrentColorWithAlpha",
				Position = U2New(1, 0, 0, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(0.48, 0, 0, 80),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(89, 155, 255)
			});
			
			local CheckersIMGColorWithAlpha = Objects:New("ImageLabel", {
				Parent = CurrentColorWithAlpha.Object,
				ScaleType = Enum.ScaleType.Tile,
				ImageTransparency = 0.6100000143051147,
				BorderColor3 = FromRGB(0, 0, 0),
				Image = "http://www.roblox.com/asset/?id=18274452449",
				BackgroundTransparency = 1,
				Name = "Checkers",
				Size = U2New(1, 0, 1, 0),
				TileSize = U2New(0, 6, 0, 6),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});

			local CheckersImgColorWithAlphaText = Objects:New("TextLabel", {
				Parent = CurrentColorWithAlpha.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "Alpha: 0.61",
				Name = "Text",
				BackgroundTransparency = 1,
				Position = U2New(0, 0, 1, 5),
				Size = U2New(1, 0, 0, 15),
				BorderSizePixel = 0,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});

			local RGBTextColors = Objects:New("TextLabel", {
				Parent = Colorpicker.Tabs.Colors.Content,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = `<font color="rgb(89, 155, 255)">89, 155, 255</font>`,
				Name = "RGB",
				Size = U2New(1, 0, 0, 15),
				Position = U2New(0, 0, 0.57, 0),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				BorderSizePixel = 0,
				RichText = true,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			}); Library:AddToTheme(RGBTextColors.Object, {TextColor3 = "Text"});

			RGBTextColors:TextBorder();

			local HSVTextColors = Objects:New("TextLabel", {
				Parent = Colorpicker.Tabs.Colors.Content,
				FontFace = UIFont,
				TextColor3 = FromRGB(235, 235, 235),
				BorderColor3 = FromRGB(0, 0, 0),
				Text = `HSV: <font color="rgb(89, 155, 255)">216°, 65%, 100%</font>`,
				Name = "HSV",
				Size = U2New(1, 0, 0, 15),
				Position = U2New(0, 0, 0.65, 0),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				BorderSizePixel = 0,
				RichText = true,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});	Library:AddToTheme(HSVTextColors.Object, {TextColor3 = "Text"});

			HSVTextColors:TextBorder();

			local HEXTextColors = Objects:New("TextLabel", {
				Parent = Colorpicker.Tabs.Colors.Content,
				FontFace = UIFont,
				TextColor3 = FromRGB(235, 235, 235),
				BorderColor3 = FromRGB(0, 0, 0),
				Text = `HEX: <font color="rgb(89, 155, 255)">#599cff</font`,
				Name = "HEX",
				Size = U2New(1, 0, 0, 15),
				Position = U2New(0, 0, 0.74, 0),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				BorderSizePixel = 0,
				RichText = true,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			}); Library:AddToTheme(HEXTextColors.Object, {TextColor3 = "Text"})

			local FadeObjects = {
				{ColorpickerWindow.Object, "BackgroundTransparency"},
				{ColorPalette.Object, "BackgroundTransparency"},
				{ValueImage.Object, "ImageTransparency"},
				{SaturationImage.Object, "ImageTransparency"},
				{HueColor.Object, "ImageTransparency"},
				{AlphaColor.Object, "BackgroundTransparency"},
				{CheckersIMGAlpha.Object, "ImageTransparency"},
				{ColorDragger.Object, "BackgroundTransparency"},
				{RedGreenAlphaLabel.Object, "BackgroundTransparency"},
				{RedGreenAlphaLabel.Object, "TextTransparency"}
			}
			
			function Colorpicker:Fade(Transparency)
				for _, v in next, FadeObjects do
					Tween:Create(v[1], nil, {
						[v[2]] = Transparency;
					});
				end;
			end;

			HEXTextColors:TextBorder();

			CheckersImgColorWithAlphaText:TextBorder();
			Library:AddToTheme(CheckersImgColorWithAlphaText.Object, {TextColor3 = "Text"});

			Library:Connect(MinimizeButton.Object.MouseEnter, function()
				Tween:Create(MinimizeButton.Object, nil, {TextColor3 = Library.Theme.Accent});
				task.wait(0.2);
				Library:ChangeObjectTheme(MinimizeButton.Object, {TextColor3 = "Accent"});
			end);

			Library:Connect(MinimizeButton.Object.MouseLeave, function()
				Tween:Create(MinimizeButton.Object, nil, {TextColor3 = Library.Theme.Text});
				task.wait(0.2);
				Library:ChangeObjectTheme(MinimizeButton.Object, {TextColor3 = "Text"});
			end);
			
			local SearchStepped 
			Library:Connect(RedGreenAlphaLabel.Object.Focused, function()
				SearchStepped = RunService.RenderStepped:Connect(function()
					local RgbText = RedGreenAlphaLabel.Object.Text
                    local Red, Green, Blue = RgbText:match("(%d+),%s*(%d+),%s*(%d+)")
                    Red, Green, Blue = tonumber(Red), tonumber(Green), tonumber(Blue)

					Colorpicker:Set(FromRGB(Red, Green, Blue):ToHex(), Colorpicker.Alpha, true)
				end)
			end)

			Library:Connect(RedGreenAlphaLabel.Object.FocusLost, function()
				if SearchStepped then 
					SearchStepped:Disconnect()
					SearchStepped = nil
				end
			end)

			local SlidingPallette = false;
			local SlidingHue = false;
			local SlidingAlpha = false;

			function Colorpicker:Update(Debounce)
				Tween:Create(ColorPalette.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = FromHSV(self.Hue, 1, 1);});
				Tween:Create(ColorpickerButton.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = FromHSV(self.Hue, self.Saturation, self.Value);});
				Tween:Create(AlphaColor.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = FromHSV(self.Hue, self.Saturation, self.Value);});
				Tween:Create(CurrentColorWithoutAlpha.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = FromHSV(self.Hue, self.Saturation, self.Value);});
				Tween:Create(CurrentColorWithAlpha.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = FromHSV(self.Hue, self.Saturation, self.Value);});
				Tween:Create(CheckersIMGColorButton.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {ImageTransparency = self.Alpha});
				Tween:Create(CheckersIMGColorWithAlpha.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {ImageTransparency = self.Alpha});

				local Red = FromHSV(self.Hue, self.Saturation, self.Value).R;
				local Green = FromHSV(self.Hue, self.Saturation, self.Value).G;
				local Blue = FromHSV(self.Hue, self.Saturation, self.Value).B;

				local String = `{tostring(MathFloor(Red * 255))}, {tostring(MathFloor(Green * 255))}, {tostring(MathFloor(Blue * 255))}`;
				local FloorHue, FloorSat, FloorVal = Library:RoundNumber(self.Hue, 0.01), Library:RoundNumber(self.Saturation, 0.01), Library:RoundNumber(self.Value, 0.01);

				self.Color = FromHSV(self.Hue, self.Saturation, self.Value);
				self.HexValue = self.Color:ToHex();

				Library.Flags[Data.Flag] = {
					Color = self.Color;
					HexValue = self.HexValue;
					Alpha = self.Alpha;
				};

				if not Debounce then
					RedGreenAlphaLabel.Object.Text = `{Library:ToRich(String, self.Color)}`;
				end

				CheckersImgColorWithAlphaText.Object.Text = `Alpha: {Library:RoundNumber(self.Alpha, 0.01)}`;
				RGBTextColors.Object.Text = `RGB: {Library:ToRich(String, self.Color)}`;
				HSVTextColors.Object.Text = `HSV: %{Library:ToRich(FloorHue, self.Color)}, %{Library:ToRich(FloorSat, self.Color)}, %{Library:ToRich(FloorVal, self.Color)}`;
				HEXTextColors.Object.Text = `HEX: #{Library:ToRich(self.Color:ToHex(), self.Color)}`;
				
				if Data.Callback then
					Data.Callback(self.Color);
				end;
			end;

			function Colorpicker:SlidePalette(Input)
				if not SlidingPallette then 
					return end;

				local ValueX = MathClamp(1 - (Input.Position.X - ColorPalette.Object.AbsolutePosition.X) / ColorPalette.Object.AbsoluteSize.X, 0, 1);
				local ValueY = MathClamp(1 - (Input.Position.Y - ColorPalette.Object.AbsolutePosition.Y) / ColorPalette.Object.AbsoluteSize.Y, 0, 1);

				self.Saturation = ValueX;
				self.Value = ValueY;

				local SlideX = MathClamp((Input.Position.X - ColorPalette.Object.AbsolutePosition.X) / ColorPalette.Object.AbsoluteSize.X, 0, 1);
				local SlideY = MathClamp((Input.Position.Y - ColorPalette.Object.AbsolutePosition.Y) / ColorPalette.Object.AbsoluteSize.Y, 0, 1);

				Tween:Create(ColorDragger.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = U2New(SlideX, 0, SlideY, 0)});
				Colorpicker:Update();
			end;

			function Colorpicker:SlideHue(Input)
				if not SlidingHue then 
					return end;

				local SlideY = MathClamp((Input.Position.Y - HueColor.Object.AbsolutePosition.Y) / HueColor.Object.AbsoluteSize.Y, 0, 1);
				local RealSlideY = MathClamp((Input.Position.Y - HueColor.Object.AbsolutePosition.Y) / HueColor.Object.AbsoluteSize.Y, 0, .985);

				self.Hue = SlideY;

				Tween:Create(HueDragger.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = U2New(0, 0, RealSlideY, 0)});
				Colorpicker:Update();
			end;

			function Colorpicker:SlideAlpha(Input)
				if not SlidingAlpha then 
					return end;
				
				local SlideY = MathClamp((Input.Position.Y - AlphaColor.Object.AbsolutePosition.Y) / AlphaColor.Object.AbsoluteSize.Y, 0, 1);
				local RealSlideY = MathClamp((Input.Position.Y - AlphaColor.Object.AbsolutePosition.Y) / AlphaColor.Object.AbsoluteSize.Y, 0, .985);

				self.Alpha = SlideY;

				Tween:Create(AlphaDragger.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = U2New(0, 0, RealSlideY, 0)});
				Tween:Create(CheckersIMGColorButton.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {ImageTransparency = self.Alpha});
				Tween:Create(CheckersIMGColorWithAlpha.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {ImageTransparency = self.Alpha});
				Colorpicker:Update();
			end;

			function Colorpicker:SetVisiblity(Bool)
				if Data.IsToggle then 
					return end;

				NewColorpicker.Object.Visible = Bool;
			end;

			function Colorpicker:Get()
				return Colorpicker.Value;
			end;

			function Colorpicker:Set(Color, Alpha, Debounce)
				if type(Color) == "table" then 
					Color = FromRGB(Color[1], Color[2], Color[3]);
					Alpha = Color[4];
				end;
			
				if type(Color) == "string" then 
					Color = Color3.fromHex(Color);
				end;

				self.Hue, self.Saturation, self.Value = Color:ToHSV();
				self.Alpha = Alpha or 0;

				self.Color = FromHSV(self.Hue, self.Saturation, self.Value);

				Library.Flags[Data.Flag] = {
					Color = self.Color,
					HexValue = self.Color:ToHex(),
					Alpha = self.Alpha
				}

				local ColorPositionX = MathClamp(1 - self.Saturation, 0, 1);
				local ColorPositionY = MathClamp(1 - self.Value, 0, 1);

				ColorDragger.Object.Position = U2New(ColorPositionX, 0, ColorPositionY, 0);

				local HuePositionY = MathClamp(self.Hue, 0, .985);

				HueDragger.Object.Position = U2New(0, 0, HuePositionY, 0);

				local AlphaPositionY = MathClamp(self.Alpha, 0, .985);

				AlphaDragger.Object.Position = U2New(0, 0, AlphaPositionY, 0);

				local CurrentColor = FromHSV(self.Hue, self.Saturation, self.Value);
				Colorpicker.Color = CurrentColor;

				Colorpicker.HexValue = Colorpicker.Color:ToHex();
				
				Tween:Create(CheckersIMGColorButton.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {ImageTransparency = self.Alpha});
				Colorpicker:Update(Debounce);
			end;

			Library:Connect(ColorPalette.Object.InputBegan, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					SlidingPallette = true;
					Colorpicker:SlidePalette(Input);
				end;
			end);

			Library:Connect(ColorPalette.Object.InputEnded, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					SlidingPallette = false;
				end;
			end);

			Library:Connect(HueColor.Object.InputBegan, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					SlidingHue = true;
					Colorpicker:SlideHue(Input);
				end;
			end);

			Library:Connect(HueColor.Object.InputEnded, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					SlidingHue = false;
				end;
			end);

			Library:Connect(AlphaColor.Object.InputBegan, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					SlidingAlpha = true;
					Colorpicker:SlideAlpha(Input);
				end;
			end);

			Library:Connect(AlphaColor.Object.InputEnded, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					SlidingAlpha = false;
				end;
			end);

			Library:Connect(UserInputService.InputChanged, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseMovement then
					Colorpicker:SlidePalette(Input);
					Colorpicker:SlideHue(Input);
					Colorpicker:SlideAlpha(Input);
				end;
			end);

			function Colorpicker:SetOpen(Bool)
				self.Open = Bool;
			
				if Bool then
					if Library.CurrentColorpicker and Library.CurrentColorpicker ~= self then
						Library.CurrentColorpicker:SetOpen(false);
					end;
			
					Library.CurrentColorpicker = self;
			
					ColorpickerWindow.Object.Visible = true;
			
					self:Fade(0);
			
					local ColorPositionX = MathClamp(1 - self.Saturation, 0, 1);
					local ColorPositionY = MathClamp(1 - self.Value, 0, 1);
			
					Tween:Create(ColorDragger.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Position = U2New(ColorPositionX, 0, ColorPositionY, 0);
					});
				else
					self:Fade(1);
			
					Tween:Create(ColorDragger.Object, nil, {
						Position = U2New(0.32, 0, 0.5, 0);
					});
			
					task.delay(0.17, function()
						if not self.Open then
							ColorpickerWindow.Object.Visible = false
			
							if Library.CurrentColorpicker == self then
								Library.CurrentColorpicker = nil;
							end;
						end;
					end);
				end;
			end;

			Library:Connect(MinimizeButton.Object.MouseButton1Click, function()
				Colorpicker:SetOpen(false);
			end);

			Library:Connect(ColorpickerButton.Object.MouseButton1Click, function()
				Colorpicker:SetOpen(not Colorpicker.Open);
			end);

			if Data.Default then
				Colorpicker:Set(Data.Default, Data.Alpha);
			end;

			local Red = FromHSV(Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value).R;
			local Green = FromHSV(Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value).G;
			local Blue = FromHSV(Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value).B;

			local String = `{tostring(MathFloor(Red * 255))}, {tostring(MathFloor(Green * 255))}, {tostring(MathFloor(Blue * 255))}`;
			RedGreenAlphaLabel.Object.Text = `RGBA: {Library:ToRich(String, Colorpicker.Color)}, {Library:RoundNumber(Colorpicker.Alpha, 0.01)}`;

			Library.SetFlags[Data.Flag] = function(Color, Alpha)
				Colorpicker:Set(Color, Alpha)
			end;

			return Colorpicker;
		end;

		function Library:Watermark(Text)
	local Watermark = { };

	local WatermarkBackground = Objects:New("Frame", {
		Parent = Library.Holder.Object;
		Size = U2New(0, 0, 0, 20);
		AutomaticSize = Enum.AutomaticSize.X;
		BackgroundColor3 = Library.Theme.Background;
		BorderSizePixel = 0;
		AnchorPoint = V2New(0.5, 0),
		Position = U2New(0.5, 0, 0, 20),
		Visible = true
	}); Library:AddToTheme(WatermarkBackground.Object, {BackgroundColor3 = "Background"});

	WatermarkBackground:Border();
	WatermarkBackground:Dragify(Text);

	local WatermarkText = Objects:New("TextLabel", {
		Parent = WatermarkBackground.Object;
		BackgroundTransparency = 1;
		Size = U2New(1, 0, 1, 0);
		Text = Text;
		Position = U2New(0, 0, 0, -1);
		TextSize = 13;
		TextColor3 = Library.Theme.Text;
		FontFace = UIFont;
		TextXAlignment = Enum.TextXAlignment.Left;
		AutomaticSize = Enum.AutomaticSize.X;
		RichText = true
	}); Library:AddToTheme(WatermarkText.Object, {TextColor3 = "Text"});
	
	WatermarkText:TextBorder();

	Objects:New("UIPadding", {
		Parent = WatermarkText.Object;
		PaddingLeft = UNew(0, 6),
		PaddingRight = UNew(0, 6),
		PaddingTop = UNew(0, 3)
	});

	local AccentLine = Objects:New("Frame", {
		Parent = WatermarkBackground.Object;
		BackgroundColor3 = Library.Theme.Accent;
		Size = U2New(1, 0, 0, 1);
		BorderSizePixel = 0;
		Position = U2New(0, 0, 0, 0);
	}); Library:AddToTheme(AccentLine.Object, {BackgroundColor3 = "Accent"});

	function Watermark:SetVisiblity(Bool)
		WatermarkBackground.Object.Visible = Bool;
	end;

	return Watermark;
end;

		function Library:Notification(Text, Duration, Color)
			local NewNotification = Objects:New("Frame", {
				Parent = Library.NotifHolder.Object;
				BackgroundColor3 = Library.Theme.Background;	
				Size = U2New(0, 0, 0, 20);
				BorderSizePixel = 0;
				ClipsDescendants = true;
				Visible = false;
				AutomaticSize = Enum.AutomaticSize.XY;
				ZIndex = 5;
				BackgroundTransparency = 1;
			});

			local Padding = Objects:New("UIPadding", {
				Parent = NewNotification.Object,
				PaddingRight = UNew(0, 6),
			})

			NewNotification:Border(NewNotification.Object);
			Library:AddToTheme(NewNotification.Object, {BackgroundColor3 = "Background"});

			local Label = Objects:New("TextLabel", {
				Parent = NewNotification.Object;
				BackgroundTransparency = 1;
				Size = U2New(1, -6, 1, 0);
				Text = Text;
				Position = U2New(0, 6, 0, 2);
				TextSize = 13;
				TextColor3 = Library.Theme.Text;
				FontFace = UIFont;
				TextStrokeTransparency = 0;
				ZIndex = 5;
				TextXAlignment = Enum.TextXAlignment.Left;
				TextWrapped = true;
				AutomaticSize = Enum.AutomaticSize.XY;
				TextTransparency = 1;
			});

			Library:AddToTheme(Label.Object, {TextColor3 = "Text"});
			local Border = Label:TextBorder();
			Border.Object.Transparency = 1;

			local AccentLine = Objects:New("Frame", {
				Parent = NewNotification.Object;
				BackgroundColor3 = Color;
				Size = U2New(0, 1, 1, 2);
				Position = U2New(0, 0, 0, 0);
				BorderSizePixel = 0;
				ZIndex = 5;
			});

			task.spawn(function()
				NewNotification.Object.Visible = true;
				task.wait(0.1);
				local a = Tween:Create(NewNotification.Object, nil, {BackgroundTransparency = 0});
				a.Tween.Completed:Wait();
				Tween:Create(Border.Object,  nil, {Transparency = 0});
				Tween:Create(Label.Object, nil, {TextTransparency = 0});
			end);

			task.delay(Duration + 0.1, function()
				Tween:Create(Border.Object,  nil, {Transparency = 1});
				Tween:Create(Label.Object, nil, {TextTransparency = 1});
				task.wait(0.1);
				local a = Tween:Create(NewNotification.Object, nil, {BackgroundTransparency = 0});
				a.Tween.Completed:Wait();
				NewNotification.Object.Visible = false;
			end);
		end;

		function Library:Window(Data)
			Data = Data or {};

			local Window = {
				Name = Data.Name or "Roblox UI Library",
				Tabs = {};
				SubTabs = {};
				Sections = {};
				Elements = {};
				Dragging = false;
				IsOpen = true
			};

			local MainFrame = Objects:New("Frame", {
				Parent = Library.Holder.Object,
				Name = "MainFrame",
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(0, 592, 0, 413),
				Position = U2New(0,Camera.ViewportSize.X / 2,0,Camera.ViewportSize.Y / 2);
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Background
			}); Library:AddToTheme(MainFrame.Object, {BackgroundColor3 = "Background"});

			Library.MainFrame = MainFrame;

			MainFrame:Border();

		local Title = Objects:New("TextLabel", {
	        Parent = MainFrame.Object,
	        FontFace = UIFont,
	        TextColor3 = FromRGB(235, 235, 235),
	        BorderColor3 = FromRGB(0, 0, 0),
	        Text = Data.Name,
	        Name = "Title",
	        BackgroundTransparency = 1,
	        Position = U2New(0, 0, 0, 3),
	        Size = U2New(1, 0, 0, 20),
	        BorderSizePixel = 0,
	        TextSize = 13,
	        BackgroundColor3 = FromRGB(255, 255, 255),
	        RichText = true -- Add this line
        })  Library:AddToTheme(Title.Object, {TextColor3 = "Text"});
			
			Title:TextBorder();

			local Inline = Objects:New("Frame", {
				Parent = MainFrame.Object,
				Name = "Inline",
				Position = U2New(0, 7, 0, 27),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, -14, 1, -34),
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Inline
			}); Library:AddToTheme(Inline.Object, {BackgroundColor3 = "Inline"});

			Inline:Border();

			Objects:New("UIPadding", {
				Parent = Inline.Object,
				PaddingRight = UNew(0, 4)
			});

			local Tabs = Objects:New("Frame", {
				Parent = Inline.Object,
				AnchorPoint = V2New(0, 0.5),
				Name = "Tabs",
				Position = U2New(0, 6, 0.5, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(0.25, 0, 1, -12),
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Background
			}); Library:AddToTheme(Tabs.Object, {BackgroundColor3 = "Background"});

			Tabs:Border();

			local TabHolder = Objects:New("Frame", {
				Parent = Tabs.Object,
				Name = "Holder",
				BackgroundTransparency = 1,
				Position = U2New(0, 0, 0, 4),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 1, -14),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});

			Objects:New("UIListLayout", {
				Parent = TabHolder.Object,
				Padding = UNew(0, 6),
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder
			});

			Objects:New("UIPadding", {
				Parent = TabHolder.Object,
				PaddingLeft = UNew(0, 7),
				PaddingTop = UNew(0, 3)
			});

			local Subtabs = Objects:New("Frame", {
				Parent = Inline.Object,
				Name = "Subtabs",
				Position = U2New(0.27, 0, 0, 6),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(0.72, 4, 0.069, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Background
			});			

			local SubTabsHolder = Objects:New("Frame", {
				Parent = Subtabs.Object,
				BackgroundTransparency = 1,
				Name = "Holder",
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255)
			}); Library:AddToTheme(Subtabs.Object, {BackgroundColor3 = "Background"});
			
			Subtabs:Border();

			local ContentContainer = Objects:New("Frame", {
				Parent = Inline.Object,
				Name = "Content",
				Position = U2New(0.27, 0, 0.1, -1),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(0.72, 4, 0.886, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Background
			});	Library:AddToTheme(ContentContainer.Object, {BackgroundColor3 = "Background"});		
			
			ContentContainer:Border();

			Window.Elements = {
				MainFrame = MainFrame;
				Inline = Inline;
				Tabs = Tabs;
				TabHolder = TabHolder;
				Subtabs = Subtabs;
				SubTabsHolder = SubTabsHolder;
				ContentContainer = ContentContainer;
			};

			do -- Dragging
				local Gui = MainFrame.Object
				local DragStart, StartPosition;

				local Update = function(Input)
					local Delta = Input.Position - DragStart;
					Tween:Create(
						Gui, 
						TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
						{Position = U2New(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y);}
					);

					Library.Flags["MainFramePosition"] = {
						X = Gui.Position.X.Offset;
						Y = Gui.Position.Y.Offset;
					};
				end;

				Library:Connect(Gui.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						Library.Dragging = true;
						DragStart = Input.Position;
						StartPosition = Gui.Position;
					end;
				end, Gui.Name .. "Draggable1");

				Library:Connect(Gui.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Library.Dragging = false;
					end;
				end, Gui.Name .. "Draggable2");

				Library:Connect(UserInputService.InputChanged, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseMovement and Library.Dragging then
						Update(Input);
					end;
				end, Gui.Name .. "Draggable3");
			end;

			MainFrame:Resizeable(V2New(592, 413), V2New(9999, 9999));

			Library:Connect(UserInputService.InputBegan, function(Input)
				if Input.KeyCode == Library.MenuKeybind or Input.UserInputType == Library.MenuKeybind then
					Window.IsOpen = not Window.IsOpen
					MainFrame.Object.Visible = Window.IsOpen
				end
			end)

			Library.SetFlags["MainFramePosition"] = function(X, Y)
				MainFrame.Object.Position = U2New(0, X, 0, Y);
			end;

			return setmetatable(Window, Library);
		end;

		function Library:Page(Data)
			Data = Data or {};

			local Page = {
				Window = self,
				Name = Data.Name or "Page",
				Active = false,
				Elements = {};
			};

			local TabButton = Objects:New("TextButton", {
				Parent = Page.Window.Elements.TabHolder.Object,
				FontFace = UIFont,
				TextColor3 = FromRGB(0, 0, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "",
				AutoButtonColor = false,
				Name = Page.Name,
				Size = U2New(1, -7, 0, 24),
				BorderSizePixel = 0,
				TextSize = 14,
				BackgroundColor3 = Library.Theme.Inline
			}); Library:AddToTheme(TabButton.Object, {BackgroundColor3 = "Inline"});

			TabButton:Border();

			Objects:New("UIGradient", {
				Parent = TabButton.Object,
				Rotation = 90,
				Color = FromRGBSeq{FromRGBKey(0, FromRGB(255, 255, 255)), FromRGBKey(1, FromRGB(165, 165, 165))}
			});

			local Liner = Objects:New("Frame", {
				Parent = TabButton.Object,
				BackgroundTransparency = 1,
				Name = "Liner",
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(0, 1, 0, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Accent
			});

			local Glow = Objects:New("Frame", {
				Parent = TabButton.Object,
				BackgroundTransparency = 1,
				Name = "Glow",
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(0, 25, 0, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Accent
			});

			Library:AddToTheme(Liner.Object, {BackgroundColor3 = "Accent"});
			Library:AddToTheme(Glow.Object, {BackgroundColor3 = "Accent"});

			Objects:New("UIGradient", {
				Parent = Glow.Object,
				Transparency = NumberSeq{NumberKey(0, 0), NumberKey(0.198, 0.84375), NumberKey(0.389, 0.918749988079071), NumberKey(0.54, 0.9624999761581421), NumberKey(0.718, 0.949999988079071), NumberKey(1, 1)}
			});

			local Text = Objects:New("TextLabel", {
				Parent = TabButton.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				TextTransparency = 0.48,
				Text = Page.Name,
				Name = "Text",
				Size = U2New(1, 0, 1, 0),
				Position = U2New(0, 5, 0, 0),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				BorderSizePixel = 0,
				BorderColor3 = FromRGB(0, 0, 0),
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});

			Text:TextBorder(Text.Object);
			Library:AddToTheme(Text.Object, {TextColor3 = "Text"});

			local TabContent = Objects:New("Frame", {
				Parent = Page.Window.Elements.ContentContainer.Object,
				BackgroundTransparency = 1,
				Name = Page.Name,
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255),
				Visible = false;
			});

			local SubPageButtons = Objects:New("Frame", {
				Parent = Page.Window.Elements.SubTabsHolder.Object,
				BackgroundColor3 = FromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 1, 0),
				BorderSizePixel = 0,
				Visible = false;
			});

			Objects:New("UIListLayout", {
				Parent = SubPageButtons.Object,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				Padding = UNew(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder
			});			

			Page.Elements = {
				TabButton = TabButton,
				Text = Text,
				TabContent = TabContent,
				SubPageButtons = SubPageButtons;
			};

			function Page:Switch(Bool)
				Page.Active = Bool;
				Tween:Create(Glow.Object, nil, {Transparency = Bool and 0 or 1, Size = Bool and U2New(0, 25, 1, 0) or U2New(0, 25, 0, 0)});
				Tween:Create(Liner.Object, nil, {Transparency = Bool and 0 or 1, Size = Bool and U2New(0, 1, 1, 0) or U2New(0, 1, 0, 0)});
				Tween:Create(Text.Object, nil, {TextTransparency = Bool and 0 or 0.48, Position = Bool and U2New(0, 10, 0, 0) or U2New(0, 5, 0, 0)});
				TabContent.Object.Visible = Bool;
				SubPageButtons.Object.Visible = Bool;
			end;

			Library:Connect(TabButton.Object.MouseButton1Click, function()
				for Index, Tab in Page.Window.Tabs do
					Tab:Switch(Tab == Page);
				end;
			end);

			TableInsert(Page.Window.Tabs, Page);
			return setmetatable(Page, Library.Pages);
		end;

		function Library.Pages:SubPage(Data)
			Data = Data or {};

			local Page = {
				Window = self.Window,
				Tab = self,
				Name = Data.Name or "Page",
				Active = false,
				Elements = {};
			};

			local TabButton = Objects:New("TextButton", {
				Parent = Page.Tab.Elements.SubPageButtons.Object,
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
				TextColor3 = FromRGB(0, 0, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "",
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Name = "Inactive",
				Size = U2New(1, 0, 1, 0),
				BorderSizePixel = 0,
				TextSize = 14,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});

			local Text = Objects:New("TextLabel", {
				Parent = TabButton.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				TextTransparency = 0.48,
				Text = Page.Name,
				Name = "Text",
				Size = U2New(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Position = U2New(0, 0, 0, 1),
				BorderSizePixel = 0,
				BorderColor3 = FromRGB(0, 0, 0),
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});

			Library:AddToTheme(Text.Object, {TextColor3 = "Text"});
			Text:TextBorder(Text.Object);

			local Glow = Objects:New("Frame", {
				Parent = TabButton.Object,
				BorderColor3 = FromRGB(0, 0, 0),
				AnchorPoint = V2New(0.5, 1),
				BackgroundTransparency = 1,
				Position = U2New(0.5, 0, 1, 0),
				Name = "Glow",
				Size = U2New(0, 0, 0, 15),
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Accent
			});

			Library:AddToTheme(Glow.Object, {BackgroundColor3 = "Accent"});

			local UIGradient = Objects:New("UIGradient", {
				Parent = Glow.Object,
				Rotation = -90,
				Transparency = NumberSeq{NumberKey(0, 0), NumberKey(0.198, 0.84375), NumberKey(0.389, 0.918749988079071), NumberKey(0.54, 0.9624999761581421), NumberKey(0.718, 0.949999988079071), NumberKey(1, 1)}
			});

			local Liner = Objects:New("Frame", {
				Parent = TabButton.Object,
				BorderColor3 = FromRGB(0, 0, 0),
				AnchorPoint = V2New(0.5, 1),
				BackgroundTransparency = 1,
				Position = U2New(0.5, 0, 1, 0),
				Name = "Liner",
				Size = U2New(0, 0, 0, 1),
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Accent
			});

			Library:AddToTheme(Liner.Object, {BackgroundColor3 = "Accent"});

			local TabContent = Objects:New("Frame", {
				Parent = Page.Tab.Elements.TabContent.Object,
				BackgroundTransparency = 1,
				Size = U2New(1,0,1,0),
				BorderSizePixel = 0,
				Name = Page.Name,
				Visible = false,
			});

			local SectionHolders = Objects:New("ScrollingFrame", {
				Parent = TabContent.Object,
				ScrollBarImageColor3 = FromRGB(0, 0, 0),
				Active = true,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 0,
				Name = "SectionHolders",
				BackgroundTransparency = 1,
				Size = U2New(1, 0, 1, 0),
				BackgroundColor3 = FromRGB(255, 255, 255),
				BorderColor3 = FromRGB(0, 0, 0),
				BorderSizePixel = 0,
				CanvasSize = U2New(0, 0, 0, 0)
			});

			Objects:New("UIPadding", {
				Parent = SectionHolders.Object,
				PaddingBottom = UNew(0, 17)
			});

			local Left = Objects:New("Frame", {
				Parent = SectionHolders.Object,
				Name = "Left",
				BackgroundTransparency = 1,
				Position = U2New(0.01, 1, 0.013, 1),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(0.47, 4, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});

			Objects:New("UIListLayout", {
				Parent = Left.Object,
				Padding = UNew(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder
			});

			local Right = Objects:New("Frame", {
				Parent = SectionHolders.Object,
				BorderColor3 = FromRGB(0, 0, 0),
				AnchorPoint = V2New(1, 0),
				BackgroundTransparency = 1,
				Position = U2New(0.99, -1, 0.013, 1),
				Name = "Right",
				Size = U2New(0.47, 4, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});

			local UIListLayout2 = Objects:New("UIListLayout", {
				Parent = Right.Object,
				Padding = UNew(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder
			});

			function Page:Switch(Bool)
				Page.Active = Bool;
				Tween:Create(Glow.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Transparency = Bool and 0 or 1, Size = Bool and U2New(1,0,0,15) or U2New(0,0,0,15)});
				Tween:Create(Liner.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Transparency = Bool and 0 or 1, Size = Bool and U2New(1,0,0,1) or U2New(0,0,0,1)});
				Tween:Create(Text.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = Bool and 0 or 0.48});
				TabContent.Object.Visible = Bool;
			end;

			Library:Connect(TabButton.Object.MouseButton1Click, function()
				for Index, Tab in Page.Window.SubTabs do
					Tab:Switch(Tab == Page);
				end;
			end);

			Page.Elements = {
				Holders = SectionHolders.Object,
				Left = Left.Object,
				Right = Right.Object;
			};

			TableInsert(Page.Window.SubTabs, Page);
			return setmetatable(Page, Library.SubPages);
		end;

		function Library.SubPages:Section(Data)
			Data = Data or {};

			local Section = {
				Window = self.Tab.Window,
				Tab = self.Tab,
				SubTab = self,
				Name = Data.Name or "Section";
				Side = Data.Side or "Left";
				Minimized = false;
				Elements = {};
			};

			local NewSection = Objects:New("Frame", {
				Parent = StringLower(Section.Side) == "left" and Section.SubTab.Elements.Left or StringLower(Section.Side) == "right" and Section.SubTab.Elements.Right,
				Name = Section.Name,
				Size = U2New(1, 0, 0, 35),
				BorderColor3 = FromRGB(0, 0, 0),
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Library.Theme.Inline;
			});

			Library:AddToTheme(NewSection.Object, {BackgroundColor3 = "Inline"});
			NewSection:Border();

			local Topbar = Objects:New("Frame", {
				Parent = NewSection.Object,
				Name = "Topbar",
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 0, 20),
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Inline
			});

			Library:AddToTheme(Topbar.Object, {BackgroundColor3 = "Inline"});
			Topbar:Border()

			local Liner = Objects:New("Frame", {
				Parent = Topbar.Object,
				AnchorPoint = V2New(0, 1),
				Name = "Liner",
				Position = U2New(0, 0, 1, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 0, 1),
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Accent
			});

			Library:AddToTheme(Liner.Object, {BackgroundColor3 = "Accent"});

			Objects:New("UIGradient", {
				Parent = Liner.Object,
				Transparency = NumberSeq{NumberKey(0, 1), NumberKey(0.494, 0), NumberKey(1, 1)}
			});

			local Text = Objects:New("TextLabel", {
				Parent = Topbar.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = Section.Name,
				Name = "Text",
				Size = U2New(1, -25, 1, 0),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = U2New(0, 5, 0, 0),
				BorderSizePixel = 0,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});

			Library:AddToTheme(Text.Object, {TextColor3 = "Text"});
			Text:TextBorder();
			
			local Content = Objects:New("Frame", {
				Parent = NewSection.Object,
				Name = "Content",
				BackgroundTransparency = 1,
				Position = U2New(0, 7, 0, 28),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, -14, 1, -20),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255),
			});

			Objects:New("UIListLayout", {
				Parent = Content.Object,
				Padding = UNew(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder
			});

			Objects:New("UIGradient", {
				Parent = Topbar.Object,
				Rotation = 90,
				Color = FromRGBSeq{FromRGBKey(0, FromRGB(255, 255, 255)), FromRGBKey(1, FromRGB(165, 165, 165))}
			});

			Section.Elements = {
				Content = Content.Object
			};

			return setmetatable(Section, Library.Sections);
		end;

		function Library.Sections:Toggle(Data)
			Data = Data or {};

			local Toggle = {
				Window = self.Window,
				Tab = self.Tab,
				SubPage = self.SubTab,
				Section = self,

				Name = Data.Name or 'Toggle',
				Flag = Data.Flag or Library:NextFlag(),
				Default = Data.Default or false,
				Callback = Data.Callback or function() end,
				Tooltip = Data.Tooltip or Data.tooltip,
				Value = false,
				Class = "Toggle";
				Count = 0;
			};

			local NewToggle = Objects:New("TextButton", {
				Parent = Toggle.Section.Elements.Content,
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
				TextColor3 = FromRGB(0, 0, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "",
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Name = Toggle.Name,
				Size = U2New(1, 0, 0, 13),
				BorderSizePixel = 0,
				TextSize = 14,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});

			NewToggle:Tooltip(Toggle.Tooltip);

			local Indicator = Objects:New("Frame", {
				Parent = NewToggle.Object,
				AnchorPoint = V2New(0, 0.5),
				Name = "Indicator",
				Position = U2New(0, 0, 0.5, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(0, 10, 0, 10),
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Element
			}); Library:AddToTheme(Indicator.Object, {BackgroundColor3 = "Element"});

			Indicator:Border();

			Objects:New("UIGradient", {
				Parent = Indicator.Object,
				Rotation = 90,
				Color = FromRGBSeq{FromRGBKey(0, FromRGB(255, 255, 255)), FromRGBKey(1, FromRGB(165, 165, 165))}
			});

			local Text = Objects:New("TextLabel", {
				Parent = NewToggle.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				TextTransparency = 0.48,
				Text = Toggle.Name,
				Name = "Text",
				Size = U2New(1, -15, 1, 0),
				Position = U2New(0, 15, 0, 1),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				BorderSizePixel = 0,
				BorderColor3 = FromRGB(0, 0, 0),
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			}); Library:AddToTheme(Text.Object, {TextColor3 = "Text"});

			Text:TextBorder();

			function Toggle:Set(Bool)
				Toggle.Value = Bool;

				Tween:Create(Indicator.Object, nil, {BackgroundColor3 = Bool and Library.Theme.Accent or Library.Theme.Element});
				Tween:Create(Text.Object, nil, {TextTransparency = Bool and 0 or 0.48});
				Library:ChangeObjectTheme(Indicator.Object, {BackgroundColor3 = Bool and "Accent" or "Element"});

				Library.Flags[Toggle.Flag] = Toggle.Value;

				if Toggle.Callback then 
					Toggle.Callback(Toggle.Value);
				end;
			end;

			function Toggle:SetVisiblity(Bool)
				NewToggle.Object.Visible = Bool;
			end;

			function Toggle:Get()
				return Toggle.Value;
			end;

			Library:Connect(NewToggle.Object.MouseButton1Click, function()
				Toggle:Set(not Toggle.Value);
			end);

			if Toggle.Default then
				Toggle:Set(Toggle.Default);
			end;

			function Toggle:Colorpicker(Data)
				local Colorpicker = {
					Name = Data.Name or 'Colorpicker',
					Flag = Data.Flag or Library:NextFlag();
					Default = Data.Default or FromRGB(255, 0, 0);
					Alpha = Data.Alpha or 1;
					Callback = Data.Callback or function() end;
					IsToggle = true;
				};
	
				Colorpicker.Parent = NewToggle.Object;
				Toggle.Count += 1;
				Colorpicker.Count = Toggle.Count;
	
				local ColorpickerNew = Library:CreateColorpicker(Colorpicker);
				return Colorpicker;
			end;

			function Toggle:Keybind(Data)
				Data = Data or {};
	
				local Keybind = {
					Window = self.Window,
					Tab = self.Tab,
					SubPage = self.SubTab,
					Section = self,
	
					Name = Data.Name or 'Keybind',
					Flag = Data.Flag or Library:NextFlag(),
					Default = Data.Default or Enum.KeyCode.F;
					Callback = Data.Callback or function() end;
					Mode = Data.Mode or "Toggle";
					Picking = false;
					Key = nil;
					Value = "";
					Toggled = false;
					Open = false;
					Class = "Keybind";
				};

				Library.Flags[Keybind.Flag] = { };
	
				local KeyButton = Objects:New("TextButton", {
					Parent = NewToggle.Object,
					FontFace = UIFont,
					TextColor3 = Library.Theme.Text,
					BorderColor3 = FromRGB(0, 0, 0),
					Text = "MB2",
					AutoButtonColor = false,
					AnchorPoint = V2New(1, 0),
					Size = U2New(0, 28, 1, 0),
					Name = "Key",
					Position = U2New(1, 0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.X,
					TextSize = 13,
					BackgroundTransparency = 1,
					BackgroundColor3 = Library.Theme.Background
				}); Library:AddToTheme(KeyButton.Object, {TextColor3 = "Text"});
	
				KeyButton:TextBorder();
	
				Objects:New("UIPadding", {
					Parent = KeyButton.Object,
					PaddingTop = UNew(0, 2)
				});

				local KeybindListItem;
				if Library.KeyList then 
					KeybindListItem = Library.KeyList:Add(Keybind.Name, Keybind.Value or "None", Keybind.Mode or "None");
				end;
	
				local ModesWindow = Objects:New("Frame", {
					Parent = NewToggle.Object,
					Visible = false,
					Name = "Window",
					AnchorPoint = V2New(1, 0),
					Position = U2New(1, 0, 0, 20),
					BorderColor3 = FromRGB(0, 0, 0),
					Size = U2New(0, 0, 0, 1),
					BorderSizePixel = 0,
					BackgroundColor3 = Library.Theme.Inline,
					ClipsDescendants = true;
				}); Library:AddToTheme(ModesWindow.Object, {BackgroundColor3 = "Inline"});
	
				ModesWindow:Border();
	
				local ToggleMode = Objects:New("TextButton", {
					Parent = ModesWindow.Object,
					FontFace = UIFont,
					TextColor3 = Library.Theme.Text,
					BorderColor3 = FromRGB(0, 0, 0),
					Text = "Toggle",
					AutoButtonColor = false,
					BackgroundTransparency = 1,
					Name = "Toggle",
					Size = U2New(1, 0, 0, 15),
					BorderSizePixel = 0,
					TextSize = 13,
					BackgroundColor3 = FromRGB(255, 255, 255)
				});	Library:AddToTheme(ToggleMode.Object, {TextColor3 = "Text"});
	
				ToggleMode:TextBorder();
	
				local HoldMode = Objects:New("TextButton", {
					Parent = ModesWindow.Object,
					FontFace = UIFont,
					TextColor3 = Library.Theme.Text,
					BorderColor3 = FromRGB(0, 0, 0),
					Text = "Hold",
					AutoButtonColor = false,
					Name = "Hold",
					BackgroundTransparency = 1,
					Position = U2New(0, 0, 0, 18),
					Size = U2New(1, 0, 0, 15),
					BorderSizePixel = 0,
					TextSize = 13,
					BackgroundColor3 = FromRGB(255, 255, 255)
				});	Library:AddToTheme(HoldMode.Object, {TextColor3 = "Text"});
				
				HoldMode:TextBorder();
	
				local AlwaysMode = Objects:New("TextButton", {
					Parent = ModesWindow.Object,
					FontFace = UIFont,
					TextColor3 = Library.Theme.Text,
					BorderColor3 = FromRGB(0, 0, 0),
					Text = "Always",
					AutoButtonColor = false,
					Name = "Always",
					BackgroundTransparency = 1,
					Position = U2New(0, 0, 0, 36),
					Size = U2New(1, 0, 0, 15),
					BorderSizePixel = 0,
					TextSize = 13,
					BackgroundColor3 = FromRGB(255, 255, 255)
				}); Library:AddToTheme(AlwaysMode.Object, {TextColor3 = "Text"});

				AlwaysMode:TextBorder();
	
				local Modes = {
					["Toggle"] = ToggleMode.Object;
					["Hold"] = HoldMode.Object;
					["Always"] = AlwaysMode.Object;
				};

				local Update = function()
					if not KeybindListItem then return end
					KeybindListItem:Set(Keybind.Name, Keybind.Value or "None", Keybind.Mode or "None");
					KeybindListItem:SetStatus(Keybind.Toggled);
				end
	
				function Keybind:Set(Key)		
					if UserInputService:GetFocusedTextBox() then return end

					if tostring(Key):find("Enum") then
						Keybind.Key = tostring(Key);

						Key = Key.Name == "Backspace" and "None" or Key.Name;
	
						local KeyString = Keys[Keybind.Key] or StringGSub(Key, "Enum.", "");
						local TextToDisplay = StringGSub(StringGSub(KeyString, "KeyCode.", ""), "UserInputType.", "") or "None";
	
						Keybind.Value = TextToDisplay;
						KeyButton.Object.Text = TextToDisplay;

						Library.Flags[Keybind.Flag] = {
							Key = Keybind.Key,
							Mode = Keybind.Mode,
							Toggled = Keybind.Toggled
						}
	
						if Keybind.Callback then 
							Keybind.Callback(Keybind.Toggled);
						end;

						Update();
					elseif TableFind({"Toggle", "Hold", "Always"}, Key) then
						Keybind:SetMode(Key);
	
						if Keybind.Callback then 
							Keybind.Callback(Keybind.Toggled);
						end;

						Update();
					elseif type(Key) == "table" then 
						local RealKey = Key.Key == "Backspace" and "None" or Key.Key;
						Keybind.Key = tostring(Key.Key);

						if Key.Mode then
							Keybind:SetMode(Key.Mode);
						else
							Keybind:SetMode("Toggle");
						end;

						Library.Flags[Keybind.Flag] = {
							Key = Keybind.Key,
							Mode = Keybind.Mode,
							Toggled = Keybind.Toggled
						}
	
						local KeyString = Keys[Keybind.Key] or string.gsub(tostring(RealKey), "Enum.", "") or RealKey;
						local TextToDisplay = KeyString and string.gsub(string.gsub(KeyString, "KeyCode.", ""), "UserInputType.", "") or "None";
	
						TextToDisplay = string.gsub(string.gsub(KeyString, "KeyCode.", ""), "UserInputType.", "")
	
						Keybind.Value = TextToDisplay;
						KeyButton.Object.Text = TextToDisplay;
	
						if Keybind.Callback then 
							Keybind.Callback(Keybind.Toggled);
						end;

						Update();
					end;
	
					Keybind.Picking = false;
	
					KeyButton.Object.Size = U2New(0, KeyButton.Object.TextBounds.X + 10, 1, 0);
					Tween:Create(KeyButton.Object, nil, {TextColor3 = Library.Theme.Text});
					Library:ChangeObjectTheme(KeyButton.Object, {TextColor3 = "Text"});
				end;
	
				function Keybind:SetMode(Mode)
					Keybind.Mode = Mode;
	
					if Keybind.Mode == "Always" then 
						Keybind.Toggled = true;
					end;
	
					for Index, Value in Modes do 
						if Index == Mode then 
							Tween:Create(Value, nil, {TextColor3 = Library.Theme.Accent});
							Library:ChangeObjectTheme(Value, {TextColor3 = "Accent"});
						else 
							Tween:Create(Value, nil, {TextColor3 = Library.Theme.Text});
							Library:ChangeObjectTheme(Value, {TextColor3 = "Text"});
						end;
					end;

					Library.Flags[Keybind.Flag] = {
						Key = Keybind.Key,
						Mode = Keybind.Mode,
						Toggled = Keybind.Toggled
					}

					Update();
				end;
	
				function Keybind:SetVisiblity(Bool)
					NewToggle.Object.Visible = Bool;
				end;
	
				function Keybind:Get(Bool)
					return Keybind.Toggled;
				end;
	
				function Keybind:Press(Bool)
					if Keybind.Mode == "Toggle" then
						Keybind.Toggled = not Keybind.Toggled;
					elseif Keybind.Mode == "Hold" then
						Keybind.Toggled = Bool;
					elseif Keybind.Mode == "Always" then
						Keybind.Toggled = true;
					end;
	
					if Keybind.Callback then
						Keybind.Callback(Keybind.Toggled);
					end;

					Library.Flags[Keybind.Flag] = { 
						Key = Keybind.Key,
						Mode = Keybind.Mode,
						Toggled = Keybind.Toggled
					};

					Update();
				end;
	
				Library:Connect(KeyButton.Object.MouseButton1Click, function()
					if Keybind.Picking then 
						return end;
	
					Tween:Create(KeyButton.Object, nil, {TextColor3 = Library.Theme.Accent});
					Library:ChangeObjectTheme(KeyButton.Object, {TextColor3 = "Accent"});
	
					Keybind.Picking = true;
	
					local InputBegan;
					InputBegan = UserInputService.InputBegan:Connect(function(Input)
						if Input.UserInputType == Enum.UserInputType.Keyboard then
							Keybind:Set(Input.KeyCode);
						else
							Keybind:Set(Input.UserInputType);
						end;
	
						InputBegan:Disconnect();
						InputBegan = nil;
					end);
				end);
	
				Library:Connect(KeyButton.Object.MouseButton2Click, function()
					Keybind.Open = not Keybind.Open;
	
					if Keybind.Open then
						ModesWindow.Object.Visible = true;
						ModesWindow.Object.ZIndex = 15;
						for Index, Value in ModesWindow.Object:GetChildren() do
							if Value:IsA("TextButton") then 
								Value.ZIndex = 15;
							end;
						end;

						local a = Tween:Create(ModesWindow.Object, nil, {Size = U2New(0, 50, 0, 1)});
						a.Tween.Completed:Wait();
						task.wait(0.05);
						Tween:Create(ModesWindow.Object, nil, {Size = U2New(0, 50, 0, 50)});
					else
						local a = Tween:Create(ModesWindow.Object, nil, {Size = U2New(0, 50, 0, 1)});
						a.Tween.Completed:Wait();
						Tween:Create(ModesWindow.Object, nil, {Size = U2New(0, 0, 0, 1)});
						task.wait(0.05);
						ModesWindow.Object.Visible = false;

						ModesWindow.Object.ZIndex = 1;
						for Index, Value in ModesWindow.Object:GetChildren() do
							if Value:IsA("TextButton") then 
								Value.ZIndex = 1;
							end;
						end;
					end;
				end);
	
				Library:Connect(ToggleMode.Object.MouseButton1Click, function()
					Keybind:Set("Toggle");
				end);
	
				Library:Connect(HoldMode.Object.MouseButton1Click, function()
					Keybind:Set("Hold");
				end);
	
				Library:Connect(AlwaysMode.Object.MouseButton1Click, function()
					Keybind:Set("Always");
				end);

				Library:Connect(UserInputService.InputBegan, function(Input)
					if tostring(Input.KeyCode) == Keybind.Key and not Keybind.Picking then 
						if Keybind.Mode == "Toggle" then 
							Keybind:Press();
						elseif Keybind.Mode == "Hold" then 
							Keybind:Press(true);
						end;
					elseif tostring(Input.UserInputType) == Keybind.Key and not Keybind.Picking then 
						if Keybind.Mode == "Toggle" then 
							Keybind:Press();
						elseif Keybind.Mode == "Hold" then 
							Keybind:Press(true);
						end;
					end;
				end);
	
				Library:Connect(UserInputService.InputEnded, function(Input)
					if tostring(Input.KeyCode) == Keybind.Key or tostring(Input.UserInputType) == Keybind.Key then
						if Keybind.Mode == "Hold" then
							Keybind:Press(false);
						end;
					end;
				end);
	
				if Keybind.Default then
					Keybind:Set({Mode = Keybind.Mode, Key = Keybind.Default, Toggled = false});
				end;
	
				Library.SetFlags[Keybind.Flag] = function(Value)
					Keybind:Set(Value);
				end;

				return Keybind;
			end;

			Library.SetFlags[Toggle.Flag] = function(Value)
				Toggle:Set(Value);
			end;

			return Toggle;
		end;

		function Library.Sections:Button(Data)
			local Button = {
				Window = self.Window,
				Tab = self.Tab,
				SubPage = self.SubTab,
				Section = self,

				Name = Data.Name or 'Toggle',
				Callback = Data.Callback or function() end,
				Tooltip = Data.Tooltip or Data.tooltip,
			};

			local NewButton = Objects:New("TextButton", {
				Parent = Button.Section.Elements.Content,
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
				TextColor3 = FromRGB(0, 0, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "",
				AutoButtonColor = false,
				Name = Button.Name,
				Size = U2New(1, 0, 0, 15),
				BorderSizePixel = 0,
				TextSize = 14,
				BackgroundColor3 = Library.Theme.Element
			}); Library:AddToTheme(NewButton.Object, {BackgroundColor3 = "Element"})
			
			NewButton:Tooltip(Button.Tooltip);
			NewButton:Border();

			Objects:New("UIGradient", {
				Parent = NewButton.Object,
				Rotation = 90,
				Color = FromRGBSeq{FromRGBKey(0, FromRGB(255, 255, 255)), FromRGBKey(1, FromRGB(165, 165, 165))}
			});

			local Text = Objects:New("TextLabel", {
				Parent = NewButton.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = Button.Name,
				Name = "Text",
				BackgroundTransparency = 1,
				Position = U2New(0, 0, 0, 1),
				Size = U2New(1, 0, 1, 0),
				BorderSizePixel = 0,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});	Library:AddToTheme(Text.Object, {TextColor3 = "Text"});

			Text:TextBorder();

			function Button:Press()
				Tween:Create(NewButton.Object, nil, {BackgroundColor3 = Library.Theme.Accent});
				Library:ChangeObjectTheme(NewButton.Object, {BackgroundColor3 = "Accent"});
				Button.Callback();
				task.wait(0.1);
				Tween:Create(NewButton.Object, nil, {BackgroundColor3 = Library.Theme.Element});
				Library:ChangeObjectTheme(NewButton.Object, {BackgroundColor3 = "Element"});
			end;

			function Button:SetVisiblity(Bool)
				NewButton.Object.Visible = Bool;
			end;

			function Button:CreateSub(Data)
				local SubButton = {
					Name = Data.Name or 'Toggle',
					Callback = Data.Callback or function() end,
				};

				local ButtonHolder = Objects:New("Frame", {
					Parent = Button.Section.Elements.Content,
					Name = "\0",
					Size = U2New(1, 0, 0, 15),
					BorderColor3 = FromRGB(0, 0, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = FromRGB(255, 255, 255),
					BackgroundTransparency = 1
				});

				NewButton.Object.Parent = ButtonHolder.Object;
				NewButton.Object.Size = U2New(0.487, 0, 0, 15);

				local NewSubButton = Objects:New("TextButton", {
					Parent = ButtonHolder.Object,
					FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
					TextColor3 = FromRGB(0, 0, 0),
					BorderColor3 = FromRGB(0, 0, 0),
					Text = "",
					AutoButtonColor = false,
					Name = SubButton.Name,
					Size = U2New(0.487, 0, 0, 15),
					AnchorPoint = V2New(1, 0),
					Position = U2New(1,0,0,0);
					BorderSizePixel = 0,
					TextSize = 14,
					BackgroundColor3 = Library.Theme.Element
				}); Library:AddToTheme(NewSubButton.Object, {BackgroundColor3 = "Element"});

				NewSubButton:Border();
				NewSubButton:Tooltip(Data.Tooltip);

				Objects:New("UIGradient", {
					Parent = NewSubButton.Object,
					Rotation = 90,
					Color = FromRGBSeq{FromRGBKey(0, FromRGB(255, 255, 255)), FromRGBKey(1, FromRGB(165, 165, 165))}
				});

				local SubText = Objects:New("TextLabel", {
					Parent = NewSubButton.Object,
					FontFace = UIFont,
					TextColor3 = Library.Theme.Text,
					BorderColor3 = FromRGB(0, 0, 0),
					Text = SubButton.Name,
					Name = "Text",
					BackgroundTransparency = 1,
					Position = U2New(0, 0, 0, 1),
					Size = U2New(1, 0, 1, 0),
					BorderSizePixel = 0,
					TextSize = 13,
					BackgroundColor3 = FromRGB(255, 255, 255)
				});	Library:AddToTheme(SubText.Object, {TextColor3 = "Text"});

				SubText:TextBorder();

				function SubButton:Press()
					Tween:Create(NewSubButton.Object, nil, {BackgroundColor3 = Library.Theme.Accent});
					Library:ChangeObjectTheme(NewSubButton.Object, {BackgroundColor3 = "Accent"});
					SubButton.Callback();
					task.wait(0.1);
					Tween:Create(NewSubButton.Object, nil, {BackgroundColor3 = Library.Theme.Element});
					Library:ChangeObjectTheme(NewSubButton.Object, {BackgroundColor3 = "Element"});
				end;

				Library:Connect(NewSubButton.Object.MouseButton1Click, function()
					SubButton:Press();
				end);

				return SubButton;
			end;

			Library:Connect(NewButton.Object.MouseButton1Click, function()
				Button:Press();
			end);

			return Button;
		end;

		function Library.Sections:Slider(Data)
			Data = Data or {};

			local Slider = {
				Window = self.Window,
				Tab = self.Tab,
				SubPage = self.SubTab,
				Section = self,

				Name = Data.Name or 'Slider',
				Min = Data.Min or 0,
				Max = Data.Max or 100,
				Default = Data.Default or Data.Max / 2,
				Flag = Data.Flag or Library:NextFlag(),
				Suffix = Data.Suffix or "",
				Tooltip = Data.Tooltip or Data.tooltip,
				Decimals = Data.Decimals,
				Value = 0,
				Infinite = Data.Infinite or false,
				Callback = Data.Callback or function() end,
				Compact = Data.Compact or false,
				Class = "Slider";
			};

			local Sliding = false;

			local NewSlider = Objects:New("Frame", {
				Parent = Slider.Section.Elements.Content,
				BackgroundTransparency = 1,
				Name = Slider.Name,
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 0, 35),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});

			NewSlider:Tooltip(Slider.Tooltip);

			local Text = Objects:New("TextLabel", {
				Parent = NewSlider.Object,
				FontFace = UIFont,
				TextColor3 = FromRGB(235, 235, 235),
				BorderColor3 = FromRGB(0, 0, 0),
				Text = Slider.Name,
				Name = "Text",
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = U2New(1, 0, 0, 15),
				BorderSizePixel = 0,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});	Library:AddToTheme(Text.Object, {TextColor3 = "Text"});

			Text:TextBorder();

			local Real_Slider = Objects:New("Frame", {
				Parent = NewSlider.Object,
				AnchorPoint = V2New(0, 1),
				Name = "Real_Slider",
				Position = U2New(0, 0, 1, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 0, 14),
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Element
			}); Library:AddToTheme(Real_Slider.Object, {BackgroundColor3 = "Element"});
			
			Real_Slider:Border();

			Objects:New("UIGradient", {
				Parent = Real_Slider.Object,
				Rotation = 90,
				Color = FromRGBSeq{FromRGBKey(0, FromRGB(255, 255, 255)), FromRGBKey(1, FromRGB(165, 165, 165))}
			});

			local Indicator = Objects:New("Frame", {
				Parent = Real_Slider.Object,
				Name = "Indicator",
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(0.5, 0, 1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Accent
			}); Library:AddToTheme(Indicator.Object, {BackgroundColor3 = "Accent"});

			Objects:New("UIGradient", {
				Parent = Indicator.Object,
				Rotation = 90,
				Color = FromRGBSeq{FromRGBKey(0, FromRGB(255, 255, 255)), FromRGBKey(1, FromRGB(165, 165, 165))}
			});

			local ValueText = Objects:New("TextLabel", {
				Parent = Real_Slider.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "50/100%",
				Name = "Value",
				BackgroundTransparency = 1,
				Position = U2New(0, 0, 0, 1),
				Size = U2New(1, 0, 1, 0),
				BorderSizePixel = 0,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			}); Library:AddToTheme(ValueText.Object, {TextColor3 = "Text"});
			
			ValueText:TextBorder();

			if Slider.Compact then
				NewSlider.Object.Size = U2New(1,0,0,14);
				Text:Clean();
			end;

			function Slider:Set(Value)
				Slider.Value = MathClamp(Library:RoundNumber(Value, Slider.Decimals), Slider.Min, Slider.Max);

				if Slider.Infinite and Slider.Value >= Slider.Max then
					ValueText.Object.Text = "Infinite";
				end;

				Library.Flags[Slider.Flag] = Slider.Value;

				Tween:Create(
					Indicator.Object, 
					TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
					{Size = U2New((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)}
				);

				if Slider.Compact then
					ValueText.Object.Text = string.format("%s: %s/%s%s", Slider.Name, tostring(Slider.Value), tostring(Slider.Max), Slider.Suffix);
				else
					ValueText.Object.Text = string.format("%s/%s%s", tostring(Slider.Value), tostring(Slider.Max), Slider.Suffix);
				end;

				if Slider.Callback then
					Slider.Callback(Slider.Value);
				end;
			end;

			function Slider:SetVisiblity(Bool)
				NewSlider.Object.Visible = Bool;
			end;

			function Slider:Get()
				return Slider.Value;
			end;

			Library:Connect(Real_Slider.Object.InputBegan, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					Sliding = true;

					local SizeX = (Input.Position.X - Real_Slider.Object.AbsolutePosition.X) / Real_Slider.Object.AbsoluteSize.X;
					local Value = ((Slider.Max - Slider.Min) * SizeX) + Slider.Min;

					Slider:Set(Value);

					Input.Changed:Connect(function()
						if Input.UserInputState == Enum.UserInputState.End then
							Sliding = false;
						end;
					end);
				end;
			end, Slider.Name .. "InputBegan");

			Library:Connect(UserInputService.InputChanged, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseMovement and Sliding then
					local SizeX = (Input.Position.X - Real_Slider.Object.AbsolutePosition.X) / Real_Slider.Object.AbsoluteSize.X;
					local Value = ((Slider.Max - Slider.Min) * SizeX) + Slider.Min;

					Slider:Set(Value);
					Library.Dragging = nil;
				end;
			end, Slider.Name .. "InputChanged");

			if Slider.Default then
				Slider:Set(Slider.Default);
			end;

			Library.SetFlags[Slider.Flag] = function(Value)
				Slider:Set(Value);
			end;

			return Slider;
		end;

		function Library.Sections:Dropdown(Data)
			Data = Data or {};

			local Dropdown = {
				Window = self.Window,
				Tab = self.Tab,
				SubPage = self.SubTab,
				Section = self,

				Name = Data.Name or 'Dropdown',
				Flag = Data.Flag or Library:NextFlag();
				Value = {};
				Tooltip = Data.Tooltip or Data.tooltip or nil,
				Compact = Data.Compact or false,
				Callback = Data.Callback or function() end;
				Multi = Data.Multi or false,
				Open = false,
				Default = Data.Default or Data.Options[1];
				Options = {};
				Class = "Dropdown";
			};

			local NewDropdown = Objects:New("Frame", {
				Parent = Dropdown.Section.Elements.Content,
				BackgroundTransparency = 1,
				Name = Dropdown.Name,
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 0, 35),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});

			NewDropdown:Tooltip(Dropdown.Tooltip);
			
			local Text = Objects:New("TextLabel", {
				Parent = NewDropdown.Object,
				FontFace =UIFont,
				TextColor3 = FromRGB(235, 235, 235),
				BorderColor3 = FromRGB(0, 0, 0),
				Text = Dropdown.Name,
				Name = "Text",
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = U2New(1, 0, 0, 15),
				BorderSizePixel = 0,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			}); Library:AddToTheme(Text.Object, {TextColor3 = "Text"});
			
			Text:TextBorder();
			
			local RealDropdown = Objects:New("Frame", {
				Parent = NewDropdown.Object,
				AnchorPoint = V2New(0, 1),
				Name = "RealDropdown",
				Position = U2New(0, 0, 1, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 0, 15),
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Element
			}); Library:AddToTheme(RealDropdown.Object, {BackgroundColor3 = "Element"});

			RealDropdown:Border();
			
			Objects:New("UIGradient", {
				Parent = RealDropdown.Object,
				Rotation = 90,
				Color = FromRGBSeq{FromRGBKey(0, FromRGB(255, 255, 255)), FromRGBKey(1, FromRGB(165, 165, 165))}
			});
			
			local ValueText = Objects:New("TextLabel", {
				Parent = RealDropdown.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "--",
				Name = "Value",
				Size = U2New(1, -19, 1, 0),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = U2New(0, 5, 0, 0),
				BorderSizePixel = 0,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255),
				TextTruncate = Enum.TextTruncate.AtEnd;
			});	Library:AddToTheme(ValueText.Object, {TextColor3 = "Text"});
			
			ValueText:TextBorder();
			
			local OpenButton = Objects:New("TextButton", {
				Parent = NewDropdown.Object,
				FontFace = UIFont,
				TextColor3 = FromRGB(0, 0, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "",
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Name = "Open",
				Size = U2New(1, 0, 1, 0),
				BorderSizePixel = 0,
				TextSize = 14,
				BackgroundColor3 = FromRGB(255, 255, 255),
				ZIndex = 5,
			});
			
			local PlusIcon = Objects:New("TextLabel", {
				Parent = RealDropdown.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "+",
				AnchorPoint = V2New(1, 0),
				Name = "PlusIcon",
				BackgroundTransparency = 1,
				Position = U2New(1, 0, 0, 0),
				Size = U2New(0, 15, 0, 15),
				BorderSizePixel = 0,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			})  Library:AddToTheme(PlusIcon.Object, {TextColor3 = "Text"});

			PlusIcon:TextBorder();
			
			local OptionHolder = Objects:New("Frame", {
				Parent = NewDropdown.Object,
				Visible = false,
				BorderColor3 = FromRGB(0, 0, 0),
				Name = "OptionHolder",
				Position = U2New(0, 0, 1, 5),
				Size = U2New(1, 0, 0, 15),
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Library.Theme.Inline
			});	Library:AddToTheme(OptionHolder.Object, {BackgroundColor3 = "Inline"});

			OptionHolder:Border();
			
			Objects:New("UIListLayout", {
				Parent = OptionHolder.Object,
				SortOrder = Enum.SortOrder.LayoutOrder
			});

			function Dropdown:SetOpen(Bool)
				Dropdown.Open = Bool;

				if Bool then
					for _, Item in NewDropdown.Object:GetDescendants() do
						if not StringFind(Item.ClassName, "UI") then
							Item.ZIndex = 15;
						end;	
					end;
					OptionHolder.Object.Visible = true;
					PlusIcon.Object.Position = U2New(1, 0, 0, -1);
					PlusIcon.Object.Text = "-";
				else
					for _, Item in NewDropdown.Object:GetDescendants() do
						if not StringFind(Item.ClassName, "UI") then
							Item.ZIndex = 1;
						end;	
					end;
					OptionHolder.Object.Visible = false;
					PlusIcon.Object.Position = U2New(1, 0, 0, 0);
					PlusIcon.Object.Text = "+";
				end;
			end;

			function Dropdown:SetVisiblity(Bool)
				NewDropdown.Object.Visible = Bool;
			end;

			function Dropdown:Get()
				return Dropdown.Value;
			end;

			Library:Connect(OpenButton.Object.MouseButton1Click, function()
				Dropdown:SetOpen(not Dropdown.Open);
			end);

			function Dropdown:Set(Option)
				if Dropdown.Multi then
					if type(Option) ~= "table" then 
						return end; 

					for Index, Value in Option do
						local IsFound = Dropdown.Options[Value];

						if not IsFound then 
							continue end;

						IsFound.IsSelected = true;

						Tween:Create(IsFound.Text, nil, {Position = U2New(0, 10, 0, 0), TextTransparency = 0});
						Tween:Create(IsFound.Liner, nil, {BackgroundTransparency = 0, Size = U2New(0, 1, 1, 0)});
						Tween:Create(IsFound.Glow, nil, {BackgroundTransparency = 0, Size = U2New(0, 25, 1, 0)});
					end;

					Dropdown.Value = Option;

					Library.Flags[Dropdown.Flag] = Dropdown.Value;

					ValueText.Object.Text = TableConcat(Option, ", ");

					for _, Value in Dropdown.Options do 
						if not table.find(Option, Value.Name) then 
							Value.IsSelected = false;
							Tween:Create(Value.Text, nil, {Position = U2New(0, 5, 0, 0), TextTransparency = 0.48});
							Tween:Create(Value.Liner, nil, {BackgroundTransparency = 1, Size = U2New(0, 1, 1, 0)});
							Tween:Create(Value.Glow, nil, {BackgroundTransparency = 1, Size = U2New(0, 25, 1, 0)});
						end;
					end;
				else
					local OptionData = Dropdown.Options[Option];

					if not OptionData then  
						return end;

					OptionData.IsSelected = true;
					Dropdown.Value = Option;

					Library.Flags[Dropdown.Flag] = Dropdown.Value;

					ValueText.Object.Text = OptionData.IsSelected and OptionData.Name or "--";

					Tween:Create(OptionData.Text, nil, {Position = U2New(0, 10, 0, 0), TextTransparency = 0});
					Tween:Create(OptionData.Liner, nil, {BackgroundTransparency = 0, Size = U2New(0, 1, 1, 0)});
					Tween:Create(OptionData.Glow, nil, {BackgroundTransparency = 0, Size = U2New(0, 25, 1, 0)});
					
					for _, Value in Dropdown.Options do 
						if Value ~= OptionData then 
							Value.IsSelected = false;
							Tween:Create(Value.Text, nil, {Position = U2New(0, 5, 0, 0), TextTransparency = 0.48});
							Tween:Create(Value.Liner, nil, {BackgroundTransparency = 1, Size = U2New(0, 0, 1, 0)});
							Tween:Create(Value.Glow, nil, {BackgroundTransparency = 1, Size = U2New(0, 0, 1, 0)});
						end;
					end;
				end;

				if Dropdown.Callback then
					Dropdown.Callback(Dropdown.Value);
				end;
			end;

			function Dropdown:AddOption(Option)
				local OptionButton = Objects:New("TextButton", {
					Parent = OptionHolder.Object,
					FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
					TextColor3 = FromRGB(0, 0, 0),
					BorderColor3 = FromRGB(0, 0, 0),
					Text = "",
					AutoButtonColor = false,
					BackgroundTransparency = 1,
					Name = "Option",
					Size = U2New(1, 0, 0, 20),
					BorderSizePixel = 0,
					TextSize = 14,
					BackgroundColor3 = FromRGB(255, 255, 255)
				});
				
				local Glow = Objects:New("Frame", {
					Parent = OptionButton.Object,
					Name = "Glow",
					BorderColor3 = FromRGB(0, 0, 0),
					Size = U2New(0, 0, 1, 0),
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					BackgroundColor3 = Library.Theme.Accent
				});

				Library:AddToTheme(Glow.Object, {BackgroundColor3 = "Accent"});
				
				local UIGradient = Objects:New("UIGradient", {
					Parent = Glow.Object,
					Transparency = NumberSeq{NumberKey(0, 0), NumberKey(0.198, 0.84375), NumberKey(0.389, 0.918749988079071), NumberKey(0.54, 0.9624999761581421), NumberKey(0.718, 0.949999988079071), NumberKey(1, 1)}
				});
				
				local Liner = Objects:New("Frame", {
					Parent = OptionButton.Object,
					Name = "Liner",
					BorderColor3 = FromRGB(0, 0, 0),
					Size = U2New(0, 0, 1, 0),
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					BackgroundColor3 = Library.Theme.Accent
				});

				Library:AddToTheme(Liner.Object, {BackgroundColor3 = "Accent"});
				
				local Text = Objects:New("TextLabel", {
					Parent = OptionButton.Object,
					FontFace = UIFont,
					TextColor3 = Library.Theme.Text,
					BorderColor3 = FromRGB(0, 0, 0),
					Text = Option,
					Name = "Text",
					Size = U2New(1, 0, 1, 0),
					BackgroundTransparency = 1,
					TextTransparency = 0.48;
					TextXAlignment = Enum.TextXAlignment.Left,
					Position = U2New(0, 5, 0, 0),
					BorderSizePixel = 0,
					TextSize = 13,
					BackgroundColor3 = FromRGB(255, 255, 255)
				});

				Text:TextBorder(Text.Object);
				Library:AddToTheme(Text.Object, {TextColor3 = "Text"});

				local NewOption = {
					Name = Option;
					Object = OptionButton.Object;
					Text = Text.Object;
					Glow = Glow.Object;
					Liner = Liner.Object;
					IsSelected = false;
				};

				function NewOption:Set()
					NewOption.IsSelected = not NewOption.IsSelected;

					if Dropdown.Multi then
						local Index = TableFind(Dropdown.Value, NewOption.Name);

						if not Index then 
							TableInsert(Dropdown.Value, NewOption.Name);
						else
							TableRemove(Dropdown.Value, Index);
						end;

						Library.Flags[Dropdown.Flag] = Dropdown.Value;

						local TextToDisplay = #Dropdown.Value > 0 and TableConcat(Dropdown.Value, ", ") or "--";

						ValueText.Object.Text = TextToDisplay;

						Tween:Create(NewOption.Text, nil, {Position = not Index and U2New(0, 10, 0, 0) or U2New(0, 5, 0, 0), TextTransparency = not Index and 0 or 0.48});
						Tween:Create(NewOption.Liner, nil, {BackgroundTransparency = not Index and 0 or 1, Size = not Index and U2New(0, 1, 1, 0) or U2New(0, 0, 1, 0)});
						Tween:Create(NewOption.Glow, nil, {BackgroundTransparency = not Index and 0 or 1, Size = not Index and U2New(0, 25, 1, 0) or U2New(0, 0, 1, 0)});
					else
						if NewOption.IsSelected then
							Dropdown.Value = NewOption.Name;

							Library.Flags[Dropdown.Flag] = Dropdown.Value;

							Tween:Create(NewOption.Text, nil, {Position = U2New(0, 10, 0, 0), TextTransparency = 0});
							Tween:Create(NewOption.Liner, nil, {BackgroundTransparency = 0, Size = U2New(0, 1, 1, 0)});
							Tween:Create(NewOption.Glow, nil, {BackgroundTransparency = 0, Size = U2New(0, 25, 1, 0)});

							ValueText.Object.Text = NewOption.IsSelected and NewOption.Name or "--";

							for _, Value in Dropdown.Options do 
								if Value ~= NewOption then 
									Value.IsSelected = false;
									Tween:Create(Value.Text, nil, {Position = U2New(0, 5, 0, 0), TextTransparency = 0.48});
									Tween:Create(Value.Liner, nil, {BackgroundTransparency = 1, Size = U2New(0, 1, 1, 0)});
									Tween:Create(Value.Glow, nil, {BackgroundTransparency = 1, Size = U2New(0, 25, 1, 0)});
								end;
							end;
						else
							Dropdown.Value = nil;

							Tween:Create(NewOption.Text, nil, {Position = U2New(0, 5, 0, 0), TextTransparency = 0.48});
							Tween:Create(NewOption.Liner, nil, {BackgroundTransparency = 1, Size = U2New(0, 1, 1, 0)});
							Tween:Create(NewOption.Glow, nil, {BackgroundTransparency = 1, Size = U2New(0, 25, 1, 0)});

							ValueText.Object.Text = "--";
						end;
					end;

					if Dropdown.Callback then
						Dropdown.Callback(Dropdown.Value);
					end;
				end;

				Library:Connect(NewOption.Object.MouseButton1Click, function()
					NewOption:Set();
				end, NewOption.Name .. "clickEvent");

				Dropdown.Options[NewOption.Name] = NewOption;
			end;

			function Dropdown:RemoveOption(Option)
				local IsFound = Dropdown.Options[Option];

				if not IsFound then 
					return end;

				IsFound:Clean();
			end;

			function Dropdown:Refresh(List)
				for _, Option in Dropdown.Options do 
					Option.Object:Destroy();
				end;

				for _, Option in List do 
					Dropdown:AddOption(Option);
				end;
			end;

			for _, Option in Data.Options do
				Dropdown:AddOption(Option);
			end;
	
			if Dropdown.Default then
				Dropdown:Set(Dropdown.Default);
			end;

			Library.SetFlags[Dropdown.Flag] = function(Value)
				Dropdown:Set(Value);
			end;

			return Dropdown;
		end;

		function Library.Sections:Colorpicker(Data)
			Data = Data or {};

			local Colorpicker = {
				Window = self.Window,
				Tab = self.Tab,
				SubPage = self.SubTab,
				Section = self,

				Name = Data.Name or 'Colorpicker',
				Flag = Data.Flag or Library:NextFlag();
				Default = Data.Default or FromRGB(255, 0, 0);
				Alpha = Data.Alpha or 1;
				Callback = Data.Callback or function() end;
				IsToggle = false;
				Count = 0;
				Class = "Colorpicker";
			};

			Colorpicker.Parent = Colorpicker.Section.Elements.Content;
			Colorpicker.Count += 1;

			local ColorpickerNew = Library:CreateColorpicker(Colorpicker);
			return Colorpicker;
		end;

		function Library.Sections:Keybind(Data)
			Data = Data or {};

			local Keybind = {
				Window = self.Window,
				Tab = self.Tab,
				SubPage = self.SubTab,
				Section = self,

				Name = Data.Name or 'Keybind',
				Flag = Data.Flag or Library:NextFlag(),
				Default = Data.Default or Enum.KeyCode.F;
				Callback = Data.Callback or function() end;
				Mode = Data.Mode or "Toggle";
				ToolTip = Data.Tooltip or Data.tooltip,
				Picking = false;
				Key = nil;
				Value = "";
				Toggled = false;
				Open = false;
				Class = "Keybind";
			};
			
			Library.Flags[Keybind.Flag] = { };

			local NewKeybind = Objects:New("Frame", {
				Parent = Keybind.Section.Elements.Content,
				BackgroundTransparency = 1,
				Name = "Keybind",
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 0, 15),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});

			NewKeybind:Tooltip(Keybind.Tooltip);

			local KeybindListItem;
			if Library.KeyList then 
				KeybindListItem = Library.KeyList:Add(Keybind.Name, Keybind.Value or "None", Keybind.Mode or "None");
			end;

			local Text = Objects:New("TextLabel", {
				Parent = NewKeybind.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = Keybind.Name,
				Name = "Text",
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = U2New(1, 0, 1, 0),
				BorderSizePixel = 0,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			}); Library:AddToTheme(Text.Object, {TextColor3 = "Text"});

			Text:TextBorder();

			local KeyButton = Objects:New("TextButton", {
				Parent = NewKeybind.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "MB2",
				AutoButtonColor = false,
				AnchorPoint = V2New(1, 0),
				Size = U2New(0, 28, 1, 0),
				Name = "Key",
				Position = U2New(1, 0, 0, 0),
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.X,
				TextSize = 13,
				BackgroundTransparency = 1,
				BackgroundColor3 = Library.Theme.Background
			}); Library:AddToTheme(KeyButton.Object, {TextColor3 = "Text"});

			KeyButton:TextBorder();

			Objects:New("UIPadding", {
				Parent = KeyButton.Object,
				PaddingTop = UNew(0, 2)
			});

			local ModesWindow = Objects:New("Frame", {
				Parent = NewKeybind.Object,
				Visible = false,
				Name = "Window",
				AnchorPoint = V2New(1, 0),
				Position = U2New(1, 0, 0, 20),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(0, 0, 0, 1),
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Inline,
				ClipsDescendants = true;
			}); Library:AddToTheme(ModesWindow.Object, {BackgroundColor3 = "Inline"});

			ModesWindow:Border();

			local ToggleMode = Objects:New("TextButton", {
				Parent = ModesWindow.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "Toggle",
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Name = "Toggle",
				Size = U2New(1, 0, 0, 15),
				BorderSizePixel = 0,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			}); Library:AddToTheme(ToggleMode.Object, {TextColor3 = "Text"});

			ToggleMode:TextBorder();

			local HoldMode = Objects:New("TextButton", {
				Parent = ModesWindow.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "Hold",
				AutoButtonColor = false,
				Name = "Hold",
				BackgroundTransparency = 1,
				Position = U2New(0, 0, 0, 18),
				Size = U2New(1, 0, 0, 15),
				BorderSizePixel = 0,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			}); Library:AddToTheme(HoldMode.Object, {TextColor3 = "Text"});

			HoldMode:TextBorder();

			local AlwaysMode = Objects:New("TextButton", {
				Parent = ModesWindow.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "Always",
				AutoButtonColor = false,
				Name = "Always",
				BackgroundTransparency = 1,
				Position = U2New(0, 0, 0, 36),
				Size = U2New(1, 0, 0, 15),
				BorderSizePixel = 0,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255)
			}); Library:AddToTheme(AlwaysMode.Object, {TextColor3 = "Text"});

			AlwaysMode:TextBorder();

			local Modes = {
				["Toggle"] = ToggleMode.Object;
				["Hold"] = HoldMode.Object;
				["Always"] = AlwaysMode.Object;
			};

			local Update = function()
				if not KeybindListItem then return end;
				KeybindListItem:Set(Keybind.Name, Keybind.Value or "None", Keybind.Mode or "None");
				KeybindListItem:SetStatus(Keybind.Toggled);
			end;

			function Keybind:Set(Key)
				if tostring(Key):find("Enum") then
					Keybind.Key = Key;
					Key = Key.Name == "Backspace" and "None" or Key.Name;

					local KeyString = Keys[Keybind.Key] or StringGSub(Key, "Enum.", "");
					local TextToDisplay = StringGSub(StringGSub(KeyString, "KeyCode.", ""), "UserInputType.", "") or "None";

					Keybind.Value = TextToDisplay;
					KeyButton.Object.Text = TextToDisplay;

					if Keybind.Callback then 
						Keybind.Callback(Keybind.Toggled);
					end;

					Library.Flags[Keybind.Flag] = { 
						Key = Keybind.Key,
						Mode = Keybind.Mode,
						Toggled = Keybind.Toggled
					};

					Update();
				elseif TableFind({"Toggle", "Hold", "Always"}, Key) then
					Keybind:SetMode(Key);

					if Keybind.Callback then 
						Keybind.Callback(Keybind.Toggled);
					end;

					Update();
				elseif type(Key) == "table" then 
					local RealKey = Key.Key == "Backspace" and "None" or Key.Key;
					Keybind.Key = Key.Key;

					if Key.Mode then
						Keybind:SetMode(Key.Mode);
					else
						Keybind:SetMode("Toggle");
					end;

					Library.Flags[Keybind.Flag] = { 
						Key = Keybind.Key,
						Mode = Keybind.Mode,
						Toggled = Keybind.Toggled
					};

                    local KeyString = Keys[Keybind.Key] or string.gsub(tostring(RealKey), "Enum.", "") or RealKey;
                    local TextToDisplay = KeyString and string.gsub(string.gsub(KeyString, "KeyCode.", ""), "UserInputType.", "") or "None";

                    TextToDisplay = string.gsub(string.gsub(KeyString, "KeyCode.", ""), "UserInputType.", "")

					Keybind.Value = TextToDisplay;
					KeyButton.Object.Text = TextToDisplay;

					if Keybind.Callback then 
						Keybind.Callback(Keybind.Toggled);
					end;

					Update();
				end;

				Keybind.Picking = false;

				KeyButton.Object.Size = U2New(0, KeyButton.Object.TextBounds.X + 10, 1, 0);
				Tween:Create(KeyButton.Object, nil, {TextColor3 = Library.Theme.Text});
				Library:ChangeObjectTheme(KeyButton.Object, {TextColor3 = "Text"});
			end;

			function Keybind:SetMode(Mode)
				Keybind.Mode = Mode;

				if Keybind.Mode == "Always" then 
					Keybind.Toggled = true;
				end;

				for Index, Value in Modes do 
					if Index == Mode then 
						Tween:Create(Value, nil, {TextColor3 = Library.Theme.Accent});
						Library:ChangeObjectTheme(Value, {TextColor3 = "Accent"});
					else 
						Tween:Create(Value, nil, {TextColor3 = Library.Theme.Text});
						Library:ChangeObjectTheme(Value, {TextColor3 = "Text"});
					end;
				end;

				Library.Flags[Keybind.Flag] = { 
					Key = Keybind.Key,
					Mode = Keybind.Mode,
					Toggled = Keybind.Toggled
				};

				Update();
			end;

			function Keybind:SetVisiblity(Bool)
				NewKeybind.Object.Visible = Bool;
			end;

			function Keybind:Get(Bool)
				return Keybind.Toggled;
			end;

			function Keybind:Press(Bool)
				if Keybind.Mode == "Toggle" then
					Keybind.Toggled = not Keybind.Toggled;
				elseif Keybind.Mode == "Hold" then
					Keybind.Toggled = Bool;
				elseif Keybind.Mode == "Always" then
					Keybind.Toggled = true;
				end;

				if Keybind.Callback then
					Keybind.Callback(Keybind.Toggled);
				end;

				Library.Flags[Keybind.Flag] = { 
					Key = Keybind.Key,
					Mode = Keybind.Mode,
					Toggled = Keybind.Toggled
				};

				Update();
			end;

			Library:Connect(KeyButton.Object.MouseButton1Click, function()
				if Keybind.Picking then 
					return end;

				Tween:Create(KeyButton.Object, nil, {TextColor3 = Library.Theme.Accent});
				Library:ChangeObjectTheme(KeyButton.Object, {TextColor3 = "Accent"});

				Keybind.Picking = true;

				local InputBegan;
				InputBegan = UserInputService.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.Keyboard then
						Keybind:Set(Input.KeyCode);
					else
						Keybind:Set(Input.UserInputType);
					end;

					InputBegan:Disconnect();
					InputBegan = nil;
				end);
			end);

			Library:Connect(UserInputService.InputBegan, function(Input)
				if Input.KeyCode == Keybind.Key or Input.UserInputType == Keybind.Key then
					if Keybind.Mode == "Toggle" then
						Keybind:Press();
					elseif Keybind.Mode == "Hold" then
						Keybind:Press(true);
					end;
				end;
			end);

			Library:Connect(UserInputService.InputEnded, function(Input)
				if Input.KeyCode == Keybind.Key or Input.UserInputType == Keybind.Key then
					if Keybind.Mode == "Hold" then
						Keybind:Press(false);
					end;
				end;
			end);

			Library:Connect(KeyButton.Object.MouseButton2Click, function()
				Keybind.Open = not Keybind.Open;
	
				if Keybind.Open then
					ModesWindow.Object.Visible = true;

					ModesWindow.Object.ZIndex = 15;
					for Index, Value in ModesWindow.Object:GetChildren() do
						if Value:IsA("TextButton") then 
							Value.ZIndex = 15;
						end;
					end;

					local a = Tween:Create(ModesWindow.Object, nil, {Size = U2New(0, 50, 0, 1)});
					a.Tween.Completed:Wait();
					task.wait(0.05);
					Tween:Create(ModesWindow.Object, nil, {Size = U2New(0, 50, 0, 50)});
				else
					local a = Tween:Create(ModesWindow.Object, nil, {Size = U2New(0, 50, 0, 1)});
					a.Tween.Completed:Wait();
					Tween:Create(ModesWindow.Object, nil, {Size = U2New(0, 0, 0, 1)});
					task.wait(0.05);
					ModesWindow.Object.Visible = false;

					ModesWindow.Object.ZIndex = 1;
					for Index, Value in ModesWindow.Object:GetChildren() do
						if Value:IsA("TextButton") then 
							Value.ZIndex = 1;
						end;
					end;
				end;
			end);

			Library:Connect(ToggleMode.Object.MouseButton1Click, function()
				Keybind:Set("Toggle");
			end);

			Library:Connect(HoldMode.Object.MouseButton1Click, function()
				Keybind:Set("Hold");
			end);

			Library:Connect(AlwaysMode.Object.MouseButton1Click, function()
				Keybind:Set("Always");
			end);

			if Keybind.Default then
				Keybind:Set({Mode = Keybind.Mode, Key = Keybind.Default, Toggled = false});
			end;

			Library.SetFlags[Keybind.Flag] = function(Value)
				Keybind:Set(Value);
			end;

			return Keybind;
		end;

		function Library.Sections:Textbox(Data)
			Data = Data or {};

			local Textbox = {
				Window = self.Window,
				Tab = self.Tab,
				SubPage = self.SubTab,
				Section = self,

				Name = Data.Name or 'Textbox',
				Flag = Data.Flag or Library:NextFlag(),
				Default = Data.Default or '';
				Callback = Data.Callback or function() end;
				Placeholder = Data.Placeholder or '...';
				Value = "";
				Class = "Textbox";
			};

			local NewTextbox = Objects:New("Frame", {
				Parent = Textbox.Section.Elements.Content,
				BackgroundTransparency = 1,
				Name = "Textbox",
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(1, 0, 0, 15),
				BorderSizePixel = 0,
				BackgroundColor3 = FromRGB(255, 255, 255)
			});

			NewTextbox:Tooltip(Data.Tooltip);
			
			local Text = Objects:New("TextLabel", {
				Parent = NewTextbox.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = Textbox.Name,
				Name = "Text",
				BackgroundTransparency = 1,
				Position = U2New(0, 0, 0, 0),
				Size = U2New(0, 50, 1, 0),
				BorderSizePixel = 0,
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Left
			});	Library:AddToTheme(Text.Object, {TextColor3 = "Text"});

			Text:TextBorder();
			
			local Realbox = Objects:New("TextBox", {
				Parent = NewTextbox.Object,
				FontFace = UIFont,
				TextColor3 = Library.Theme.Text,
				BorderColor3 = FromRGB(0, 0, 0),
				Text = "",
				Name = "Realbox",
				Size = U2New(1, -55, 1, 0),
				AnchorPoint = V2New(1, 0),
				Position = U2New(1, 0, 0, 0),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Right,
				BorderSizePixel = 0,
				PlaceholderText = Textbox.Placeholder,
				PlaceholderColor3 = FromRGB(145, 145, 145),
				TextSize = 13,
				BackgroundColor3 = FromRGB(255, 255, 255),
				ClearTextOnFocus = false;
			}); Library:AddToTheme(Realbox.Object, {TextColor3 = "Text"});

			Realbox:TextBorder();
			
			local Liner = Objects:New("Frame", {
				Parent = Realbox.Object,
				AnchorPoint = V2New(1, 1),
				Name = "Liner",
				Position = U2New(1, 0, 1, 0),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = U2New(0, 69, 0, 1),
				BorderSizePixel = 0,
				BackgroundColor3 = Library.Theme.Accent
			}); Library:AddToTheme(Liner.Object, {BackgroundColor3 = "Accent"});

			function Textbox:Set(Value)
				Textbox.Value = tostring(Value);
				Tween:Create(Liner.Object, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = U2New(0, Realbox.Object.TextBounds.X + 3, 0, 1);});
				Tween:Create(Realbox.Object, nil, {TextColor3 = Library.Theme.Text});
				Library:ChangeObjectTheme(Realbox.Object, {TextColor3 = "Text"});

				Library.Flags[Textbox.Flag] = Textbox.Value;

				if Textbox.Callback then 
					Textbox.Callback(Textbox.Value);
				end;
			end;

			function Textbox:Get()
				return Textbox.Value;
			end;

			function Textbox:SetVisiblity(Bool)
				NewTextbox.Object.Visible = Bool
			end;

			Library:Connect(Realbox.Object.Focused, function()
				Tween:Create(Realbox.Object, nil, {TextColor3 = Library.Theme.Accent});
				Library:ChangeObjectTheme(Realbox.Object, {TextColor3 = "Accent"});
			end);

			Library:Connect(Realbox.Object.FocusLost, function()
				Textbox:Set(Realbox.Object.Text);
			end);

			if Textbox.Default then
				Textbox:Set(Textbox.Default);
			end;

			Library.SetFlags[Textbox.Flag] = function(Value)
				Textbox:Set(Value);
			end;
			
			return Textbox;
		end;
	end;
end;

do 
    local Window = Library:Window({Name = '<font color="rgb(138, 43, 226)">Vantyx</font>.ware'});
	local KeybindList = Library:KeybindList("AUSJDjsadjsak") -- first arg is the name

	do
		local Tabs = {
			Combat = Window:Page({Name = "Combat"}),
			Visuals = Window:Page({Name = "Visuals"}),
			Exploit = Window:Page({Name = "Exploit"}),
			Settings = Window:Page({Name = "Settings"});
		};	

		local SubTabs = {
			Aimbot = Tabs.Combat:SubPage({Name = "Silent Aim"});
			Gun = Tabs.Combat:SubPage({Name = "Gun Mods"});
            SkinWalker = Tabs.Combat:SubPage({Name = "Skin Walker"});
		    HeadExpander = Tabs.Combat:SubPage({Name = "Head Expander"});
			LongNeck = Tabs.Combat:SubPage({Name = "Long Neck"});
			Players = Tabs.Visuals:SubPage({Name = "Players"});
			Scan = Tabs.Visuals:SubPage({Name = "Scanner"});
			Vehicles = Tabs.Visuals:SubPage({Name = "Vehicles"});
			Graves = Tabs.Visuals:SubPage({Name = "Graves"});
			Weapons = Tabs.Visuals:SubPage({Name = "Weapon"});
			Ammo = Tabs.Visuals:SubPage({Name = "Ammo"});
			Repair = Tabs.Visuals:SubPage({Name = "Repair Kit"});
			Movements = Tabs.Exploit:SubPage({Name = "Movements"});
			AntiAim = Tabs.Exploit:SubPage({Name = "Anti Aim"});
			Cam = Tabs.Exploit:SubPage({Name = "Cam"});
			CarFly = Tabs.Exploit:SubPage({Name = "Carfly"});
			Mod = Tabs.Exploit:SubPage({Name = "Mod Detector"});
		    World = Tabs.Exploit:SubPage({Name = "World"});
			Themes = Tabs.Settings:SubPage({Name = "Themes"});
			Configs = Tabs.Settings:SubPage({Name = "Configs"});
		};


		local Sections = {
			SilentAimbot = SubTabs.Aimbot:Section({Name = "Silent Aimbot", Side = "Left"});
		    Visible = SubTabs.Aimbot:Section({Name = "Visible Check ~ Trigger bot", Side = "Left"});
            Aimbot = SubTabs.Aimbot:Section({Name = "Mouse Aimbot", Side = "Right"});
			HitSound = SubTabs.Aimbot:Section({Name = "HitSound", Side = "Right"});
			GunMods = SubTabs.Gun:Section({Name = "Gun Mods", Side = "Left"});
            Humans = SubTabs.Players:Section({Name = "Players", Side = "Left"});
			PlayerInfo = SubTabs.Players:Section({Name = "Player Info", Side = "Right"});
			Movements = SubTabs.Movements:Section({Name = "Movements", Side = "Left"});
			AntiAim = SubTabs.AntiAim:Section({Name = "AntiAim", Side = "Left"});
			Cam = SubTabs.Cam:Section({Name = "Camera", Side = "Left"});
			Fov = SubTabs.Cam:Section({Name = "Fov", Side = "Right"});
			Carfly = SubTabs.CarFly:Section({Name = "Carfly", Side = "Left"});
			Mod = SubTabs.Mod:Section({Name = "Mod Detector", Side = "Left"});
		    Items = SubTabs.Scan:Section({Name = "Items", Side = "Right"});
			Zombies = SubTabs.Scan:Section({Name = "Scan Zombies", Side = "Left"});
			World = SubTabs.World:Section({Name = "World", Side = "Left"});
			HeadExpander = SubTabs.HeadExpander:Section({Name = "HeadExpander", Side = "Left"});
			SkinWalker = SubTabs.SkinWalker:Section({Name = "Skin Walker", Side = "Left"});
            LongNeck = SubTabs.LongNeck:Section({Name = "LongNeck", Side = "Left"});
			Vehicles = SubTabs.Vehicles:Section({Name = "Vehicles", Side = "Left"});
			Graves = SubTabs.Graves:Section({Name = "Graves", Side = "Left"});
			Weapons = SubTabs.Weapons:Section({Name = "Weapon", Side = "Left"});
			Ammo = SubTabs.Ammo:Section({Name = "Ammo", Side = "Left"});
			Repair = SubTabs.Repair:Section({Name = "Repair Kit", Side = "Left"});
			Themes = SubTabs.Themes:Section({Name = "Theme", Side = "Left"});

			Configs = SubTabs.Configs:Section({Name = "Config", Side = "Left"});
		};

do -- aimbot

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatsService = game:GetService("Stats")

local Client = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local RenderStepped = RunService.RenderStepped

-- Import required modules for instant bullet
local WeaponDataUtil = require(ReplicatedStorage:WaitForChild("GunSystem"):WaitForChild("GunLibrary"):WaitForChild('WeaponDataUtil'))
local TracerUtil = require(ReplicatedStorage:WaitForChild("GunSystem"):WaitForChild("GunLibrary"):WaitForChild("TracerUtil"))
local BulletModule = require(ReplicatedStorage:WaitForChild("GunSystem"):WaitForChild("GunLibrary"):WaitForChild("BulletModule"))
local ConfigService = require(ReplicatedStorage:WaitForChild("CustomCharacter"):WaitForChild("ConfigService"))

local gundata = ReplicatedStorage:FindFirstChild("GunSystemAssets"):FindFirstChild("GunData")
local sv_config = ReplicatedStorage:FindFirstChild("CustomCharacterConfigs"):FindFirstChild("Configuration"):FindFirstChild("Server")

-- Get RaycastParams from BulletModule
local v_u_15 = getupvalue(BulletModule.RayTest, 1)

-- Global variable for instant bullet timing
local NextInstant = 0

-- Function to get bullet data
local function v_u_35(p31)
    local v32
    if p31 then
        v32 = WeaponDataUtil:GetWeaponData(p31)
    else
        v32 = p31
    end
    if v32 then
        v32 = v32.Stats
    end
    if v32 then
        v32 = v32.BulletSettings
    end
    local v33
    if v32 then
        v33 = v32.BulletGravity
    else
        v33 = v32
    end
    local v34
    if v32 then
        v34 = v32.BulletSpeed
    else
        v34 = v32
    end
    return {
        ["MaxDistance"] = p31 == nil and 0 or v32.MaxDistance.Value + 4,
        ["Speed"] = v34 and v34.Value or ConfigService.server():get("sv_default_bullet_speed"),
        ["Gravity"] = v33 and (v33.Value and ConfigService.server():get("sv_default_bullet_gravity")) or 0
    }
end

-- FULL BULLET SIMULATION FOR INSTANT BULLET
local function BulletSimulationAsync(Origin, Direction, CurrentGun, TracerData, ResimulationData)
    local v56
    if TracerData then
        v56 = TracerData.Tracer.Enabled or false
    else
        v56 = false
    end

    local v57 = TracerData and (TracerData.Tracer.Offset or Vector3.new(0, 0, 0)) or Vector3.new(0, 0, 0)
    local v58 = v_u_15
    local v59 = WeaponDataUtil:GetWeaponData(CurrentGun)
    local v60 = v59 and v59.BulletTrail and (v59.Name or "Tracer") or "Tracer"
    local v61 = Direction.Unit
    local v62 = {
        ["Position"] = Origin,
        ["Normal"] = -v61,
        ["Material"] = Enum.Material.Air,
        ["Distance"] = 0,
        ["Resimulation"] = {}
    }
    local v63 = v_u_35(CurrentGun)
    local v64 = CFrame.new
    if ResimulationData then
        Origin = ResimulationData[1].Start or Origin
    end
    local v65 = v64(Origin)
    local v66 = 0
    local v67
    if v56 and not ResimulationData then
        local OldIdentity = getthreadidentity()
        setthreadidentity(2)
        v67 = TracerUtil:CreateTracer(v60, v59 and v59.BulletTrail)
        setthreadidentity(OldIdentity)
    else
        v67 = nil
    end

    local CanInstant = (os.clock() - NextInstant) > 0

    local v68 = 1
    local v69 = Vector3.new(0, 0, 0)
    while true do
        local v70
        if ResimulationData then
            local v71 = ResimulationData[v68]
            if not v71 then
                return v62
            end
            v70 = v71.Time
        elseif CanInstant then
            v70 = StatsService.FrameTime
        else
            v70 = RunService.RenderStepped:Wait()
        end
        
        local v72 = v66 + v70
        v68 = v68 + 1
        local v73 = -(v63.Gravity * v72 ^ 2)
        local v74 = Vector3.new(0, v73, 0)
        local v75 = v63.Speed * v70
        local v76 = v65.Position
        local v77 = v63.MaxDistance - v62.Distance
        local v78
        if v77 < v75 then
            v78 = true
        else
            v77 = v75
            v78 = false
        end
        v65 = v65 * CFrame.new(v61 * v77)
        local v79 = v65.Position
        local v80 = (v79 - v76).Unit
        local v81 = v76 + v69
        local v82 = v79 + v74
        local v83 = BulletModule:RayTest(v81, v82, v58)
        local v84 = {
            ["Time"] = v70,
            ["Start"] = v81,
            ["End"] = v82
        }

        local v85 = v62.Resimulation
        table.insert(v85, v84)
        local v86 = ResimulationData and v83.Instance and workspace:Raycast(v83.Position, v81 - v83.Position, v58)
        if v86 then
            v83.Instance = v86.Instance
            v83.Position = v86.Position
            v83.Normal = v86.Normal
        end
        if v83.Instance then
            if v67 then
                local v87 = CFrame.new(v83.Position)
                local v88 = v72 * 4
                local v89 = v57:Lerp(Vector3.new(0, 0, 0), math.clamp(v88, 0, 1) ^ 2)
                local v90 = v87.Position + v89
                v67:PivotTo(CFrame.new(v90, v90 + v80))
                local OldIdentity = getthreadidentity()
                setthreadidentity(2)
                TracerUtil:RemoveTracer(v60, v67)
                setthreadidentity(OldIdentity)
            end
            v62.Distance = v62.Distance + v83.Distance
            v62.Position = v83.Position
            v62.Normal = v83.Normal
            v62.Material = v83.Material
            v62.Instance = v83.Instance
            v84.End = v83.Position
            
            return v62
        end
        if v67 then
            local v91 = v65 + v74
            local v92 = v72 * 4
            local v93 = v57:Lerp(Vector3.new(0, 0, 0), math.clamp(v92, 0, 1) ^ 2)
            local v94 = v91.Position + v93
            v67:PivotTo(CFrame.new(v94, v94 + v80))
        end
        v62.Distance = v62.Distance + v77
        if v78 then
            if v67 then
                local OldIdentity = getthreadidentity()
                setthreadidentity(2)
                TracerUtil:RemoveTracer(v60, v67)
                setthreadidentity(OldIdentity)
            end
            
            return v62
        end
        v66 = v72
        v69 = v74
    end
end

-- INSTANT BULLET PREDICTION USING FULL SIMULATION
local function InstantBulletPredict(targetPart, targetRoot, currentGun)
    local shooterPos = Camera.CFrame.Position
    local targetPos = targetPart.Position
    local targetVelocity = targetRoot.AssemblyLinearVelocity
    
    -- Calculate direction
    local direction = (targetPos - shooterPos).Unit
    
    -- Initial time estimate
    local distance = (targetPos - shooterPos).Magnitude
    local bulletData = v_u_35(currentGun)
    local bulletSpeed = bulletData.Speed
    local time = distance / bulletSpeed
    
    -- Iterative convergence for better prediction
    local maxIterations = 15
    local predictedPos = targetPos
    
    for i = 1, maxIterations do
        -- Predict target position at time
        predictedPos = targetPos + (targetVelocity * time)
        
        -- Use the actual bullet simulation to check if it would hit
        local simResult = BulletSimulationAsync(
            shooterPos, 
            (predictedPos - shooterPos).Unit, 
            currentGun, 
            nil,  -- No tracer
            nil   -- No resimulation
        )
        
        -- Get the actual hit position from simulation
        local simulatedHitPos = simResult.Position
        
        -- Calculate new time based on simulated distance
        local newDistance = (simulatedHitPos - shooterPos).Magnitude
        local newTime = newDistance / bulletSpeed
        
        -- Check convergence
        if math.abs(newTime - time) < 0.0005 then
            time = newTime
            break
        end
        time = newTime
    end
    
    -- Final prediction using the converged time
    local finalPos = targetPos + (targetVelocity * time)
    
    -- Apply gravity compensation
    local gravityDrop = -bulletData.Gravity * (time * time)
    finalPos = finalPos + Vector3.new(0, gravityDrop, 0)
    
    return finalPos, time
end

local entitylist = nil
for _, gc in ipairs(getgc(true)) do
    if type(gc) == "table" then
        local gpfwc = rawget(gc, "GetPlayerFromWorldCharacter")
        if gpfwc and type(gpfwc) == "function" then
            local upvs = getupvalues(gpfwc)
            local GetCharacters = upvs[2].GetCharacters
            entitylist = getupvalues(GetCharacters)[1]
            break
        end
    end
end

-- Prediction Methods
local PredictionMethods = {
    Default = "Default",
    InterceptSolver = "Intercept Solver",
    PositionExtrapolator = "Position Extrapolator",
    AccelerationExtrapolator = "Acceleration Extrapolator",
    VelocityAveraged = "Velocity-Averaged Predictor",
    IterativeConvergence = "Iterative Convergence Solver",
    KalmanFiltered = "Kalman-Filtered Predictor",
    ArcBallistic = "Arc/Ballistic Solver"
}

-- Kalman Filter state storage
local KalmanStates = {}

local flags = {
    AimbotEnabled = false,
    AimPart = "Head",
    FovSize = 100,
    FovColor = Color3.fromRGB(255, 255, 255),
    FovPosition = "Follow Mouse",
    SnaplineThickness = 1,
    SnaplineColor = Color3.fromRGB(255, 255, 255),
    ShowFov = false,
    ShowSnapline = false,
    Smoothing = 1,
    AimKey = Enum.UserInputType.MouseButton2,
    PredictionMethod = PredictionMethods.Default,
    VisibleCheck = false,
    TeamCheck = false,
    InstantBullet = false  -- Instant Bullet toggle
}

local isAiming = false
local aimbotTarget = nil

-- Drawing objects
local outlineCircle = Drawing.new("Circle")
outlineCircle.Thickness = 3
outlineCircle.NumSides = 100
outlineCircle.Transparency = 0.6
outlineCircle.Filled = false
outlineCircle.Color = Color3.fromRGB(0, 0, 0)
outlineCircle.Visible = false

local mainCircle = Drawing.new("Circle")
mainCircle.Thickness = 1.5
mainCircle.NumSides = 100
mainCircle.Transparency = 0.6
mainCircle.Filled = false
mainCircle.Color = flags.FovColor
mainCircle.Visible = false

local snaplineOutline = Drawing.new("Line")
snaplineOutline.Thickness = 5
snaplineOutline.Color = Color3.fromRGB(0, 0, 0)
snaplineOutline.Transparency = 0.8
snaplineOutline.Visible = false

local snapline = Drawing.new("Line")
snapline.Thickness = flags.SnaplineThickness
snapline.Transparency = 0.8
snapline.Color = flags.SnaplineColor
snapline.Visible = false

-- ==================== CORE CALCULATION FUNCTIONS ====================

local function CalculateTimeToHit(position, velocity, speed)
    local a = velocity:Dot(velocity) - speed * speed
    local b = 2 * position:Dot(velocity)
    local c = position:Dot(position)
    local discriminant = b * b - 4 * a * c
    if discriminant < 0 then return nil end
    local sqrtDisc = math.sqrt(discriminant)
    local t1 = (-b - sqrtDisc) / (2 * a)
    local t2 = (-b + sqrtDisc) / (2 * a)
    local t = math.min(t1, t2)
    return (t > 0 and t) or (math.max(t1, t2) > 0 and math.max(t1, t2)) or nil
end

-- ==================== PREDICTION METHODS ====================

-- 1. DEFAULT METHOD
local function DefaultPredictor(targetPart, targetRoot, bulletSpeed, bulletGravity)
    local shooterPos = Camera.CFrame.Position
    local targetPos = targetPart.Position
    local relPos = targetPos - shooterPos
    local predicted = targetPos

    local targetVelocity = targetRoot.AssemblyLinearVelocity
    local time = CalculateTimeToHit(relPos, targetVelocity, bulletSpeed)
    if not time then return nil end
    predicted = targetPos + (targetVelocity * time)
    predicted = predicted - Vector3.new(0, -bulletGravity * (time ^ 2), 0)
    return predicted, time
end

-- 2. Intercept Solver
local function InterceptSolver(targetPart, targetRoot, bulletSpeed, bulletGravity)
    local shooterPos = Camera.CFrame.Position
    local targetPos = targetPart.Position
    local targetVelocity = targetRoot.AssemblyLinearVelocity
    local relPos = targetPos - shooterPos
    
    local a = targetVelocity:Dot(targetVelocity) - bulletSpeed * bulletSpeed
    local b = 2 * relPos:Dot(targetVelocity)
    local c = relPos:Dot(relPos)
    local discriminant = b * b - 4 * a * c
    
    if discriminant < 0 then return nil end
    
    local sqrtDisc = math.sqrt(discriminant)
    local t1 = (-b - sqrtDisc) / (2 * a)
    local t2 = (-b + sqrtDisc) / (2 * a)
    local t = math.min(t1, t2)
    t = (t > 0 and t) or (math.max(t1, t2) > 0 and math.max(t1, t2)) or nil
    
    if not t then return nil end
    
    local predicted = targetPos + (targetVelocity * t)
    predicted = predicted - Vector3.new(0, -bulletGravity * (t * t), 0)
    return predicted, t
end

-- 3. Position Extrapolator
local function PositionExtrapolator(targetPart, targetRoot, bulletSpeed, bulletGravity)
    local shooterPos = Camera.CFrame.Position
    local targetPos = targetPart.Position
    local targetVelocity = targetRoot.AssemblyLinearVelocity
    
    local distance = (targetPos - shooterPos).Magnitude
    local estimatedTime = distance / bulletSpeed
    
    local predicted = targetPos + (targetVelocity * estimatedTime)
    predicted = predicted - Vector3.new(0, -bulletGravity * (estimatedTime * estimatedTime), 0)
    return predicted, estimatedTime
end

-- 4. Acceleration Extrapolator
local function AccelerationExtrapolator(targetPart, targetRoot, bulletSpeed, bulletGravity)
    local shooterPos = Camera.CFrame.Position
    local targetPos = targetPart.Position
    local targetVelocity = targetRoot.AssemblyLinearVelocity
    local targetAcceleration = targetRoot.AssemblyAngularVelocity or Vector3.new(0, 0, 0)
    
    local distance = (targetPos - shooterPos).Magnitude
    local estimatedTime = distance / bulletSpeed
    
    local predicted = targetPos + (targetVelocity * estimatedTime) + (0.5 * targetAcceleration * estimatedTime * estimatedTime)
    predicted = predicted - Vector3.new(0, -bulletGravity * (estimatedTime * estimatedTime), 0)
    return predicted, estimatedTime
end

-- 5. Velocity-Averaged Predictor
local function VelocityAveragedPredictor(targetPart, targetRoot, bulletSpeed, bulletGravity, velBuffer)
    local shooterPos = Camera.CFrame.Position
    local targetPos = targetPart.Position
    
    local avgVelocity = Vector3.new(0, 0, 0)
    local count = 0
    
    for _, vel in ipairs(velBuffer) do
        if vel then
            avgVelocity = avgVelocity + vel
            count = count + 1
        end
    end
    
    if count > 0 then
        avgVelocity = avgVelocity / count
    end
    
    local distance = (targetPos - shooterPos).Magnitude
    local estimatedTime = distance / bulletSpeed
    
    local predicted = targetPos + (avgVelocity * estimatedTime)
    predicted = predicted - Vector3.new(0, -bulletGravity * (estimatedTime * estimatedTime), 0)
    return predicted, estimatedTime
end

-- 6. Iterative Convergence Solver
local function IterativeConvergenceSolver(targetPart, targetRoot, bulletSpeed, bulletGravity, maxIterations)
    local shooterPos = Camera.CFrame.Position
    local targetPos = targetPart.Position
    local targetVelocity = targetRoot.AssemblyLinearVelocity
    
    maxIterations = maxIterations or 10
    local t = (targetPos - shooterPos).Magnitude / bulletSpeed
    local predicted = targetPos + (targetVelocity * t)
    
    for i = 1, maxIterations do
        local newT = (predicted - shooterPos).Magnitude / bulletSpeed
        if math.abs(newT - t) < 0.001 then
            t = newT
            break
        end
        t = newT
        predicted = targetPos + (targetVelocity * t)
    end
    
    predicted = predicted - Vector3.new(0, -bulletGravity * (t * t), 0)
    return predicted, t
end

-- 7. Kalman-Filtered Predictor
local function KalmanFilteredPredictor(targetPart, targetRoot, bulletSpeed, bulletGravity, timeStep, targetKey)
    local shooterPos = Camera.CFrame.Position
    local targetPos = targetPart.Position
    local targetVelocity = targetRoot.AssemblyLinearVelocity
    
    if not KalmanStates[targetKey] then
        KalmanStates[targetKey] = {
            pos = targetPos,
            vel = targetVelocity,
            P = 1,
            Q = 0.1,
            R = 1
        }
    end
    
    local state = KalmanStates[targetKey]
    
    local predictedPos = state.pos + state.vel * timeStep
    local predictedP = state.P + state.Q
    
    local K = predictedP / (predictedP + state.R)
    state.pos = predictedPos + K * (targetPos - predictedPos)
    state.vel = state.vel + K * ((targetPos - state.pos) / timeStep)
    state.P = (1 - K) * predictedP
    
    local distance = (state.pos - shooterPos).Magnitude
    local estimatedTime = distance / bulletSpeed
    
    local predicted = state.pos + (state.vel * estimatedTime)
    predicted = predicted - Vector3.new(0, -bulletGravity * (estimatedTime * estimatedTime), 0)
    return predicted, estimatedTime
end

-- 8. Arc/Ballistic Solver
local function ArcBallisticSolver(targetPart, targetRoot, bulletSpeed, bulletGravity)
    local shooterPos = Camera.CFrame.Position
    local targetPos = targetPart.Position
    local targetVelocity = targetRoot.AssemblyLinearVelocity
    
    local relPos = targetPos - shooterPos
    local horizontalDist = Vector3.new(relPos.X, 0, relPos.Z).Magnitude
    
    if horizontalDist == 0 then return targetPos, 0 end
    
    local t = horizontalDist / bulletSpeed
    local predicted = targetPos + (targetVelocity * t)
    
    for i = 1, 15 do
        local newPredicted = targetPos + (targetVelocity * t)
        local newRelPos = newPredicted - shooterPos
        local newHorizontalDist = Vector3.new(newRelPos.X, 0, newRelPos.Z).Magnitude
        
        local verticalDrop = -bulletGravity * (t * t)
        newPredicted = newPredicted - Vector3.new(0, verticalDrop, 0)
        
        local newT = newHorizontalDist / bulletSpeed
        if math.abs(newT - t) < 0.001 then
            t = newT
            break
        end
        t = newT
        predicted = newPredicted
    end
    
    return predicted, t
end

-- ==================== MAIN PREDICTION FUNCTION ====================

local function PredictTargetPosition(targetPart, targetRoot, bulletSpeed, bulletGravity, targetKey, currentGun)
    local timeStep = RenderStepped:Wait()
    
    -- Velocity buffer for averaged predictor
    if not rawget(_G, "_velocityBuffer") then
        _G._velocityBuffer = {}
    end
    if not _G._velocityBuffer[targetKey] then
        _G._velocityBuffer[targetKey] = {}
    end
    local velBuffer = _G._velocityBuffer[targetKey]
    local targetVelocity = targetRoot.AssemblyLinearVelocity
    table.insert(velBuffer, targetVelocity)
    if #velBuffer > 5 then table.remove(velBuffer, 1) end
    
    -- CHECK INSTANT BULLET FIRST
    if flags.InstantBullet then
        return InstantBulletPredict(targetPart, targetRoot, currentGun)
    end
    
    local method = flags.PredictionMethod
    
    -- Select prediction method
    if method == PredictionMethods.Default then
        return DefaultPredictor(targetPart, targetRoot, bulletSpeed, bulletGravity)
    elseif method == PredictionMethods.InterceptSolver then
        return InterceptSolver(targetPart, targetRoot, bulletSpeed, bulletGravity)
    elseif method == PredictionMethods.PositionExtrapolator then
        return PositionExtrapolator(targetPart, targetRoot, bulletSpeed, bulletGravity)
    elseif method == PredictionMethods.AccelerationExtrapolator then
        return AccelerationExtrapolator(targetPart, targetRoot, bulletSpeed, bulletGravity)
    elseif method == PredictionMethods.VelocityAveraged then
        return VelocityAveragedPredictor(targetPart, targetRoot, bulletSpeed, bulletGravity, velBuffer)
    elseif method == PredictionMethods.IterativeConvergence then
        return IterativeConvergenceSolver(targetPart, targetRoot, bulletSpeed, bulletGravity)
    elseif method == PredictionMethods.KalmanFiltered then
        return KalmanFilteredPredictor(targetPart, targetRoot, bulletSpeed, bulletGravity, timeStep, targetKey)
    elseif method == PredictionMethods.ArcBallistic then
        return ArcBallisticSolver(targetPart, targetRoot, bulletSpeed, bulletGravity)
    else
        return DefaultPredictor(targetPart, targetRoot, bulletSpeed, bulletGravity)
    end
end

-- ==================== REST OF THE SCRIPT ====================

local function UpdateFOVCircle()
    if not flags.ShowFov or not flags.AimbotEnabled then
        outlineCircle.Visible = false
        mainCircle.Visible = false
        return
    end

    local mousePos = UserInputService:GetMouseLocation()
    local viewportSize = Camera.ViewportSize

    local centerPos
    if flags.FovPosition == "Center Screen" then
        centerPos = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    else
        centerPos = Vector2.new(mousePos.X, mousePos.Y)
    end

    outlineCircle.Position = centerPos
    outlineCircle.Radius = flags.FovSize
    mainCircle.Position = centerPos
    mainCircle.Radius = flags.FovSize
    mainCircle.Color = flags.FovColor

    outlineCircle.Visible = true
    mainCircle.Visible = true
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == flags.AimKey then
        isAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == flags.AimKey then
        isAiming = false
        snapline.Visible = false
        snaplineOutline.Visible = false
    end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        UpdateFOVCircle()
    end
end)

RenderStepped:Connect(UpdateFOVCircle)

local function IsValidTarget(player)
    if not player or player == Client or player:GetAttribute("Dead") then return false end
    if flags.TeamCheck and player.Team == Client.Team then return false end
    return true
end

local function get_current_gun(plr)
    if not plr then return "Fists" end
    local c = plr:FindFirstChild("CurrentSelectedObject")
    c = c and c.Value
    c = c and c.Value
    return c and c.Name or "Fists"
end

local function GetCurrentGun()
    local currentgun = get_current_gun(Client)
    if not currentgun then return nil, nil, nil end
    local gun = gundata and gundata:FindFirstChild(currentgun)
    local stats = gun and gun:FindFirstChild("Stats")
    local bullet_settings = stats and stats:FindFirstChild("BulletSettings")
    local proj_speed, proj_drop
    if bullet_settings then
        local bullet_speed = bullet_settings:FindFirstChild("BulletSpeed")
        local bullet_gravity = bullet_settings:FindFirstChild("BulletGravity")
        proj_speed = tonumber(bullet_speed and bullet_speed.Value) or (sv_config and tonumber(sv_config.sv_default_bullet_speed.Value)) or 1500
        proj_drop = tonumber(bullet_gravity and bullet_gravity.Value) or (sv_config and tonumber(sv_config.sv_default_bullet_gravity.Value)) or 0
    else
        proj_speed = (sv_config and tonumber(sv_config.sv_default_bullet_speed.Value)) or 1500
        proj_drop = (sv_config and tonumber(sv_config.sv_default_bullet_gravity.Value)) or 0
    end
    return currentgun, proj_speed, proj_drop
end

local function GetTargetPart(worldmodel)
    local part = worldmodel:FindFirstChild(flags.AimPart)
    if part then return part end
    local parts = {"Head","UpperTorso","LowerTorso","Neck","LeftUpperArm","LeftLowerArm","LeftHand",
                   "RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot",
                   "RightUpperLeg","RightLowerLeg","RightFoot"}
    for _, name in ipairs(parts) do
        part = worldmodel:FindFirstChild(name)
        if part then return part end
    end
    return worldmodel:FindFirstChild("HumanoidRootPart")
end

local function GetTarget()
    if not entitylist then return nil, nil, nil end

    local closestTarget = nil
    local predictedPos = nil
    local closestDistance = math.huge
    local closestPlayer = nil

    local mousePos = UserInputService:GetMouseLocation()
    local fovSize = flags.FovSize

    local currentGun, bulletSpeed, bulletGravity = GetCurrentGun()
    if not bulletSpeed then return nil, nil, nil end

    for userid, v in pairs(entitylist) do
        local player = v.Player
        if not player or not IsValidTarget(player) then continue end

        local root = v.RootPart
        local worldmodel = v.WorldModel
        local character = v.Character

        if not (root and worldmodel and character) then continue end

        local part = GetTargetPart(worldmodel)
        if not part then continue end

        local targetKey = tostring(userid)
        local futurePos, _ = PredictTargetPosition(part, root, bulletSpeed, bulletGravity, targetKey, currentGun)
        if futurePos then
            local screenPoint, onScreen = Camera:WorldToViewportPoint(futurePos)
            if onScreen then
                local targetPos2D = Vector2.new(screenPoint.X, screenPoint.Y)
                local distToMouse = (mousePos - targetPos2D).Magnitude

                if distToMouse < closestDistance and distToMouse <= fovSize then
                    if flags.VisibleCheck then
                        local rayParams = RaycastParams.new()
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        rayParams.FilterDescendantsInstances = {Camera, Client.Character}
                        local ray = Workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), rayParams)
                        if ray and ray.Instance and ray.Instance:IsDescendantOf(character) then
                            closestDistance = distToMouse
                            closestTarget = part
                            predictedPos = futurePos
                            closestPlayer = player
                        end
                    else
                        closestDistance = distToMouse
                        closestTarget = part
                        predictedPos = futurePos
                        closestPlayer = player
                    end
                end
            end
        end
    end

    return closestTarget, predictedPos, closestPlayer
end

local function moveMouseToTarget()
    if not flags.AimbotEnabled or not isAiming then return end
    if not aimbotTarget then return end

    local screenPos, onScreen = Camera:WorldToViewportPoint(aimbotTarget)
    if not onScreen then return end

    local mousePos = UserInputService:GetMouseLocation()
    local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
    local delta = targetScreenPos - mousePos
    local distance = delta.Magnitude
    if distance < 1 then return end

    local smoothing = flags.Smoothing or 5
    local moveDelta = delta / smoothing
    mousemoverel(moveDelta.X, moveDelta.Y)
end

local function UpdateSnapline()
    if not flags.ShowSnapline or not flags.AimbotEnabled or not isAiming then
        snapline.Visible = false
        snaplineOutline.Visible = false
        return
    end

    if not aimbotTarget then
        snapline.Visible = false
        snaplineOutline.Visible = false
        return
    end

    local screenPos, onScreen = Camera:WorldToViewportPoint(aimbotTarget)
    if onScreen then
        local mousePos = UserInputService:GetMouseLocation()
        local viewportSize = Camera.ViewportSize
        local centerPos
        if flags.FovPosition == "Center Screen" then
            centerPos = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
        else
            centerPos = mousePos
        end

        local targetPos = Vector2.new(screenPos.X, screenPos.Y)
        local distanceFromCenter = (targetPos - centerPos).Magnitude

        if distanceFromCenter <= flags.FovSize then
            snapline.Thickness = flags.SnaplineThickness
            snapline.Color = flags.SnaplineColor

            snaplineOutline.From = centerPos
            snaplineOutline.To = targetPos
            snaplineOutline.Visible = true

            snapline.From = centerPos
            snapline.To = targetPos
            snapline.Visible = true
        else
            snapline.Visible = false
            snaplineOutline.Visible = false
        end
    else
        snapline.Visible = false
        snaplineOutline.Visible = false
    end
end

RenderStepped:Connect(function()
    local target, predictedPos, player = GetTarget()
    if target and predictedPos and (isAiming or flags.AimbotEnabled) then
        aimbotTarget = predictedPos
    else
        aimbotTarget = nil
        snapline.Visible = false
        snaplineOutline.Visible = false
    end

    moveMouseToTarget()
    UpdateSnapline()
    UpdateFOVCircle()
end)

-- ==================== UI CONFIGURATION ====================

Sections.Aimbot:Toggle({
    Name = "Mouse Aimbot(Hold RightClick)",
    Flag = "AimbotEnabled",
    Default = false,
    Callback = function(State)
        flags.AimbotEnabled = State
        if not State then
            snapline.Visible = false
            snaplineOutline.Visible = false
            outlineCircle.Visible = false
            mainCircle.Visible = false
        end
    end
})

Sections.Aimbot:Slider({
    Name = "Smoothing",
    Flag = "Smoothing",
    Min = 1,
    Max = 20,
    Default = 5,
    Suffix = "%",
    Callback = function(Value)
        flags.Smoothing = Value
    end
})

Sections.Aimbot:Dropdown({
    Name = "Prediction Type",
    Flag = "PredictionMethod",
    Options = {
        PredictionMethods.Default,
        PredictionMethods.InterceptSolver,
        PredictionMethods.PositionExtrapolator,
        PredictionMethods.AccelerationExtrapolator,
        PredictionMethods.VelocityAveraged,
        PredictionMethods.IterativeConvergence,
        PredictionMethods.KalmanFiltered,
        PredictionMethods.ArcBallistic
    },
    Default = PredictionMethods.Default,
    Callback = function(Value)
        flags.PredictionMethod = Value
        KalmanStates = {}
    end
})

Sections.Aimbot:Dropdown({
    Name = "Target Part",
    Flag = "AimPart",
    Options = {"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "RightLowerArm", "RightLowerLeg", "LeftLowerLeg"},
    Default = "Head",
    Callback = function(Value)
        flags.AimPart = Value
    end
})

-- INSTANT BULLET TOGGLE
Sections.Aimbot:Toggle({
    Name = "Instant Bullet (Rage - Uses Full Simulation)",
    Flag = "InstantBullet",
    Default = false,
    Callback = function(State)
        flags.InstantBullet = State
        if State then
            -- Reset instant timing when enabled
            NextInstant = 0
        end
    end
})

Sections.Aimbot:Toggle({
    Name = "Team Check",
    Flag = "TeamCheck",
    Default = false,
    Callback = function(State)
        flags.TeamCheck = State
    end})

local fove = Sections.Aimbot:Toggle({
    Name = "Show FOV ",
    Flag = "ShowFov",
    Default = false,
    Callback = function(State)
        flags.ShowFov = State
        if not State then
            outlineCircle.Visible = false
            mainCircle.Visible = false
        end
    end
})

fove:Colorpicker({
    Name = "FOV Color",
    Flag = "FovColor",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        flags.FovColor = Value
        mainCircle.Color = Value
    end
})

Sections.Aimbot:Dropdown({
    Name = "FOV Position",
    Flag = "FovPosition",
    Options = {"Center Screen", "Follow Mouse"},
    Default = "Follow Mouse",
    Callback = function(Value)
        flags.FovPosition = Value
    end
})

Sections.Aimbot:Slider({
    Name = "FOV Size",
    Flag = "FovSize",
    Min = 1,
    Max = 500,
    Default = 100,
    Suffix = "%",
    Callback = function(Value)
        flags.FovSize = Value
        mainCircle.Radius = Value
        outlineCircle.Radius = Value
    end
})

local nigs = Sections.Aimbot:Toggle({
    Name = "Show Snapline",
    Flag = "ShowSnapline",
    Default = false,
    Callback = function(State)
        flags.ShowSnapline = State
        if not State then
            snapline.Visible = false
            snaplineOutline.Visible = false
        end
    end
})

nigs:Colorpicker({
    Name = "Snapline Color",
    Flag = "SnaplineColor",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        flags.SnaplineColor = Value
        snapline.Color = Value
    end
})

Sections.Aimbot:Slider({
    Name = "Snapline Thickness",
    Flag = "SnaplineThickness",
    Min = 1,
    Max = 5,
    Suffix = "%",
    Default = 1,
    Callback = function(Value)
        flags.SnaplineThickness = Value
        snapline.Thickness = Value
    end
})

end


do -- scanner

local EmberClient = require(game:GetService("ReplicatedFirst"):WaitForChild("EmberClientLibrary"):WaitForChild("EmberClient"):WaitForChild("EmberClient"))
local NPCSimulatorService = EmberClient:GetService("NPCSimulatorService")

local function ScanZombies()
    Library:Notification(string.format("Scanning %d Zombies", NPCSimulatorService.TotalNPCs), 3, Library.Theme.Accent)
    local FoundAny = false
    for _, Zombie in NPCSimulatorService.NPCs do
        for _, Item in Zombie.Equipment do
            local ItemClass = Item.ClassName
            local Skin = Item.SkinOverride
            if ItemClass:find("Altyn") then
                Library:Notification(string.format("Chinese Zombie Detected (%s)", ItemClass:gsub(".item", "")), 3, Library.Theme.Accent)
                FoundAny = true
            elseif Skin and Skin:find("Beret") then
                Library:Notification(string.format("Tactical Zombie Detected (%s)", Skin), 3, Library.Theme.Accent)
                FoundAny = true
            end
        end
    end
    if not FoundAny then
        Library:Notification("No Rare Zombies Detected", 3, Color3.fromRGB(255, 0, 0))
    end
end

Sections.Zombies:Button({
    Name = "Scan Rare Zombies",
    Callback = function()
        ScanZombies()
    end
})


local weaponOptions = {
        'Barret50',
        'M79',
        'RenelliM4',
        'ASVAL',
        'MRAD',
        'M4A1',
        'SPAS12',
        'MK47',
        'AKM',
        'SVD',
        'M249',
        'G36k',
        'Saiga',
        'AWM',
        'Scar',
        'MK18',
        'M110K',
        'MK14',
        'PKM',
    }

    local selectedWeapon = nil

    Sections.Items:Dropdown({
        Name = "Select Weapon",
        Flag = "SelectedWeapon",
        Options = weaponOptions,
        Default = 'Barret50',
        Callback = function(value)
            selectedWeapon = value
            Library:Notification('Selected: ' .. value, 2, Library.Theme.Accent)
        end
    })

    Sections.Items:Button({
        Name = "Scan Players for Weapon",
        Callback = function()
            if not selectedWeapon then
                Library:Notification('Please select a weapon first!', 3, Color3.fromRGB(255, 0, 0))
                return
            end

            local targetWeapon = selectedWeapon
            local foundWeapon = false

            for i = 1, #Players:GetPlayers() do
                local player = Players:GetPlayers()[i]
                local gunInventory = player:FindFirstChild('GunInventory')
                if gunInventory then
                    for _, slot in ipairs(gunInventory:GetChildren()) do
                        local gunObject = slot
                        if gunObject:IsA('ObjectValue') and gunObject.Value then
                            if gunObject.Value.Name == targetWeapon then
                                foundWeapon = true
                                Library:Notification(player.Name .. ' has ' .. targetWeapon, 4, Library.Theme.Accent)
                            end
                        end
                    end
                end
            end

            if not foundWeapon then
                Library:Notification('No players have ' .. targetWeapon, 3, Color3.fromRGB(255, 0, 0))
            end
        end
    })

    Sections.Items:Button({
        Name = "Scan Items",
        Callback = function()
            Players = Players or game:GetService("Players")
            HttpService = game:GetService('HttpService')

            local Map = {
                ['Barret50'] = true,
                ['SVD'] = true,
                ['M79'] = true,
                ['AKM'] = true,
                ['PKM'] = true,
                ['ASVAL'] = true,
                ['Saiga'] = true,
                ['AWM'] = true,
                ['MRAD'] = true,
                ['m110k'] = true,
                ['RenelliM4'] = true,
                ['P90'] = true,
                ['AltynHelmet'] = true,
                ['RatnikVest'] = true,
            }

            local MapLower = {}
            for gunName, _ in pairs(Map) do
                MapLower[gunName:lower()] = true
            end

            local Found = {}
            LocalPlayer = Players.LocalPlayer

            for _, Player in pairs(Players:GetPlayers()) do
                if Player == LocalPlayer then continue end

                local helmetJson = Player:GetAttribute('EquipmentHat')
                if helmetJson then
                    local success, helmetData = pcall(function()
                        return HttpService:JSONDecode(helmetJson)
                    end)

                    if success and helmetData and helmetData.ClassName then
                        local className = helmetData.ClassName:gsub('%.item', '')
                        if MapLower[className:lower()] then
                            table.insert(Found, {
                                Player = Player,
                                Gun = className,
                                Type = 'Helmet'
                            })
                        end
                    end
                end

                local vestJson = Player:GetAttribute('EquipmentVest')
                if vestJson then
                    local success, vestData = pcall(function()
                        return HttpService:JSONDecode(vestJson)
                    end)

                    if success and vestData and vestData.ClassName then
                        local className = vestData.ClassName:gsub('%.item', '')
                        if MapLower[className:lower()] then
                            table.insert(Found, {
                                Player = Player,
                                Gun = className,
                                Type = 'Vest'
                            })
                        end
                    end
                end

                local GunInventory = Player:FindFirstChild('GunInventory')
                if GunInventory then
                    for _, Slot in pairs(GunInventory:GetChildren()) do
                        if Slot:IsA('ObjectValue') and Slot.Value then
                            local gunName = Slot.Value.Name
                            if MapLower[gunName:lower()] then
                                table.insert(Found, {
                                    Player = Player,
                                    Gun = gunName,
                                    Type = 'Weapon'
                                })
                            end
                        end
                    end
                end
            end

            if #Found == 0 then
                Library:Notification('No matching items found in server', 3, Color3.fromRGB(255, 0, 0))
            else
                for _, Data in ipairs(Found) do
                    Library:Notification(Data.Player.Name .. ' has ' .. Data.Gun .. ' (' .. Data.Type .. ')', 5, Library.Theme.Accent)
                end
            end
        end
    })

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BufferNet = require(
    ReplicatedStorage:WaitForChild("GunSystem")
        :WaitForChild("SharedLibraries")
        :WaitForChild("BufferNet")
        :WaitForChild("BufferNet")
)

local GUNS = {
    ["barret50"] = true,
    ["asval"] = true,
    ["m110k"] = true,
    ["m79"] = true,
    ["renellim4"] = true,
    ["svd"] = true
}

local POIS = {}
local poiFolder = ReplicatedStorage:WaitForChild("GameConfig"):WaitForChild("MapData"):WaitForChild("POI")
for _, poi in pairs(poiFolder:GetChildren()) do
    local pos = poi:GetAttribute("Position")
    if pos then
        table.insert(POIS, {
            name = poi.Name,
            pos = pos
        })
    end
end

local function getNearestPOI(position)
    local nearest = nil
    local nearestDist = math.huge

    for _, poi in ipairs(POIS) do
        local dx = position.X - poi.pos.X
        local dz = position.Z - poi.pos.Z
        local dist = math.sqrt(dx*dx + dz*dz)

        if dist < nearestDist then
            nearestDist = dist
            nearest = poi
        end
    end

    return nearest, nearestDist
end

BufferNet:AddReceiveMiddleware(function(route, sender, data, requestId)
    if route and route.Route == "gun_system/fire" then
        local rawWeapon = data.InventoryItem and tostring(data.InventoryItem.Value) or ""
        local weapon = string.lower(rawWeapon)

        if GUNS[weapon] then
            local shooter = data.Shooter and data.Shooter.Name or "?"
            local pos = data.Origin and data.Origin.Position or Vector3.zero
            local poi, dist = getNearestPOI(pos)

            print(string.format(
                "%s | %s | %s | %.2f",
                shooter,
                weapon,
                poi and poi.name or "Unknown",
                dist
            ))
        end
    end
    return true
end)
local Button = Sections.Items:Button({
    Name = "Advance Scanner", 
    Callback = function()
        Library:Notification("F9 - The Advanced Scanner Will Print Or In Your Executor Console", 5, Library.Theme.Accent)
    end
})

end

do
    local Players = game:GetService('Players')
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local Mouse = LocalPlayer:GetMouse()
    local RunService = game:GetService('RunService')
    local UserInputService = game:GetService('UserInputService')

    local CustomMeshCharacter = require(game.ReplicatedFirst:WaitForChild("GunSystemPlugins"):WaitForChild("CustomMeshCharacter"))
    local PlayerList = require(game.ReplicatedStorage:WaitForChild("CustomCharacter"):WaitForChild("PlayerList"))

    local Library = Library or {}
    if not Library.Theme then
        Library.Theme = {
            Background = Color3.fromRGB(30, 30, 35),
            Border = Color3.fromRGB(60, 60, 70),
            Accent = Color3.fromRGB(0, 140, 255),
            Inline = Color3.fromRGB(45, 45, 55),
            Text = Color3.fromRGB(230, 230, 235)
        }
    end
    
    if not Library.Holder then
        Library.Holder = { Object = Instance.new("ScreenGui") }
        Library.Holder.Object.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    local function getName(worldChar)
        local real = CustomMeshCharacter:GetCharacterFromWorldCharacter(worldChar)
        return real and PlayerList:GetPlayerFromCharacter(real) and
               PlayerList:GetPlayerFromCharacter(real).Name or nil
    end

    local function getInventoryFromPlayer(playerName)
        local p = Players:FindFirstChild(playerName)
        if not p then return {} end
        local inv = p:FindFirstChild("GunInventory")
        if not inv then return {} end
        local weapons = {}
        for _, slot in ipairs(inv:GetChildren()) do
            if slot:IsA("ObjectValue") and slot.Value then
                local gun = slot.Value.Name
                local ret = slot:FindFirstChild("AttachmentReticle")
                local scope = (ret and ret.Value and tostring(ret.Value)) or "No scope"
                local mag = slot:FindFirstChild("BulletsInMagazine")
                local res = slot:FindFirstChild("BulletsInReserve")
                local ammo = "??|??"
                if mag and res and mag:IsA("IntValue") and res:IsA("IntValue") then
                    ammo = mag.Value .. " | " .. res.Value
                end
                table.insert(weapons, {
                    name = gun,
                    scope = scope,
                    ammo = ammo
                })
            end
        end
        return weapons
    end

    local function parseEquipment(attr)
        if not attr then return "None" end
        local class = attr:match('%"ClassName"%s*:%s*%"(.-)%.item%"')
        return class or "None"
    end

    local function getClosestEntityPlayer()
        local distancenigger = math.huge
        local namenigga = nil
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        for _, wc in ipairs(CustomMeshCharacter:GetWorldCharacters()) do
            if wc and wc.Parent then
                local name = getName(wc)
                if name and name ~= LocalPlayer.Name then
                    local root = wc:FindFirstChild("HumanoidRootPart")
                    if root then
                        local sp, onScreen = Camera:WorldToViewportPoint(root.Position)
                        if onScreen then
                            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if d < distancenigger then
                                distancenigger = d
                                namenigga = name
                            end
                        end
                    end
                end
            end
        end

        return namenigga
    end

    local boxWidth = 320
    local lineSpacing = 26
    local invViewerScale = 1.0
    local invViewerPosX = 0
    local invViewerPosY = 0
    local dragging = false
    local dragStartPos = nil
    local mouseStartPos = nil
    local renderConn = nil
    local playerRemovingConn = nil
    local scrollFrame = nil
    local contentFrame = nil
    local titleLabel = nil
    local textLabels = {}
    local currentTarget = nil
    local inputConnections = {}

    local function stripRichText(text)
        return text:gsub("<[^>]+>", "")
    end

    local function getGunInfoLines(targetPlayer)
        local lines = {}
        if not targetPlayer then
            table.insert(lines, "No target")
            return lines
        end
        
        lines[#lines + 1] = " " .. targetPlayer .. "'s Inventory "
        lines[#lines + 1] = ""
        
        local weapons = getInventoryFromPlayer(targetPlayer)
        local target = Players:FindFirstChild(targetPlayer)
        
        for i = 1, 4 do
            if i <= #weapons then
                lines[#lines + 1] = string.format("%d  %s [%s] [%s]", i, weapons[i].name or "Unknown", weapons[i].ammo or "--|--", weapons[i].scope or "No scope")
            else
                lines[#lines + 1] = string.format("%d  Empty [--|--] [No scope]", i)
            end
        end
        
        if target then
            local vest = parseEquipment(target:GetAttribute("EquipmentVest"))
            local helmet = parseEquipment(target:GetAttribute("EquipmentHat"))
            local backpack = parseEquipment(target:GetAttribute("EquipmentBackpack"))
            local equipment = {helmet, vest, backpack}
            
            local filtered = {}
            for _, v in ipairs(equipment) do
                if v and v ~= "None" then
                    table.insert(filtered, v)
                end
            end
            
            if #filtered > 0 then
                lines[#lines + 1] = ""
                lines[#lines + 1] = string.format("Equipment: %s", table.concat(filtered, ", "))
            end
        end
        
        return lines
    end

    local function destroyInvViewer()
        if renderConn then renderConn:Disconnect() renderConn = nil end
        
        for _, conn in ipairs(inputConnections) do
            conn:Disconnect()
        end
        inputConnections = {}
        
        if scrollFrame then
            pcall(function() scrollFrame:Destroy() end)
            scrollFrame = nil
        end
        if contentFrame then
            pcall(function() contentFrame:Destroy() end)
            contentFrame = nil
        end
        if titleLabel then
            pcall(function() titleLabel:Destroy() end)
            titleLabel = nil
        end
        textLabels = {}
        dragging = false
        dragStartPos = nil
        mouseStartPos = nil
        currentTarget = nil
    end

    local function createInvViewer()
        destroyInvViewer()

        local container = Instance.new("Frame")
        container.Name = "InventoryViewer"
        container.BackgroundColor3 = Library.Theme.Background
        container.BorderSizePixel = 0
        container.Size = UDim2.new(0, boxWidth * invViewerScale, 0, 0)
        container.AutomaticSize = Enum.AutomaticSize.Y
        container.Parent = Library.Holder.Object

        local border = Instance.new("UIStroke")
        border.Color = Library.Theme.Border
        border.Thickness = 1
        border.LineJoinMode = Enum.LineJoinMode.Miter
        border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        border.Parent = container

        local accentLine = Instance.new("Frame")
        accentLine.Name = "Liner"
        accentLine.BackgroundColor3 = Library.Theme.Accent
        accentLine.BorderSizePixel = 0
        accentLine.Size = UDim2.new(1, 10, 0, 1)
        accentLine.Position = UDim2.new(0, -5, 0, 0)
        accentLine.Parent = container

        titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.BackgroundTransparency = 1
        titleLabel.Size = UDim2.new(0, 75, 0, 20)
        titleLabel.Position = UDim2.new(0, 5, 0, 2)
        titleLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
        titleLabel.Text = "Target Info"
        titleLabel.TextColor3 = Library.Theme.Text
        titleLabel.TextSize = 13 * invViewerScale
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextYAlignment = Enum.TextYAlignment.Center
        titleLabel.RichText = false
        titleLabel.Parent = container

        local titleBorder = Instance.new("UIStroke")
        titleBorder.Color = Library.Theme["Text Border"] or Color3.fromRGB(0, 0, 0)
        titleBorder.Thickness = 1
        titleBorder.LineJoinMode = Enum.LineJoinMode.Miter
        titleBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        titleBorder.Parent = titleLabel

        contentFrame = Instance.new("Frame")
        contentFrame.Name = "Content"
        contentFrame.BackgroundTransparency = 1
        contentFrame.Size = UDim2.new(1, 0, 0, 0)
        contentFrame.Position = UDim2.new(0, 0, 0, 22)
        contentFrame.AutomaticSize = Enum.AutomaticSize.Y
        contentFrame.Parent = container

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 8)
        padding.PaddingRight = UDim.new(0, 8)
        padding.PaddingTop = UDim.new(0, 4)
        padding.PaddingBottom = UDim.new(0, 8)
        padding.Parent = contentFrame

        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 2)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = contentFrame

        textLabels = {}
        for i = 1, 10 do
            local label = Instance.new("TextLabel")
            label.Name = "Line" .. i
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 16 * invViewerScale)
            label.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
            label.Text = ""
            label.TextColor3 = Library.Theme.Text
            label.TextSize = 12 * invViewerScale
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Top
            label.RichText = false
            label.Visible = false
            label.Parent = contentFrame

            local lineBorder = Instance.new("UIStroke")
            lineBorder.Color = Library.Theme["Text Border"] or Color3.fromRGB(0, 0, 0)
            lineBorder.Thickness = 1
            lineBorder.LineJoinMode = Enum.LineJoinMode.Miter
            lineBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
            lineBorder.Parent = label

            table.insert(textLabels, label)
        end

        local vp = Camera.ViewportSize
        local defaultX = vp.X - (boxWidth * invViewerScale) - 20
        local defaultY = 20
        container.Position = UDim2.new(0, defaultX + invViewerPosX, 0, defaultY + invViewerPosY)

        local dragging = false
        local dragStart, startPosition

        local function onInputBegan(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if not container then return end

                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local absPos = container.AbsolutePosition
                local absSize = container.AbsoluteSize
                if mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and
                   mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y then
                    dragging = true
                    dragStart = input.Position
                    startPosition = container.Position
                end
            end
        end

        local function onInputEnded(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end

        local function onInputChanged(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging and container and dragStart and startPosition then
                local delta = input.Position - dragStart
                container.Position = UDim2.new(
                    startPosition.X.Scale,
                    startPosition.X.Offset + delta.X,
                    startPosition.Y.Scale,
                    startPosition.Y.Offset + delta.Y
                )
                invViewerPosX = container.Position.X.Offset
                invViewerPosY = container.Position.Y.Offset
            end
        end

        inputConnections = {}
        table.insert(inputConnections, UserInputService.InputBegan:Connect(onInputBegan))
        table.insert(inputConnections, UserInputService.InputEnded:Connect(onInputEnded))
        table.insert(inputConnections, UserInputService.InputChanged:Connect(onInputChanged))

        renderConn = RunService.RenderStepped:Connect(function()
            Camera = workspace.CurrentCamera or Camera
            local target = getClosestEntityPlayer()
            if target ~= currentTarget then
                currentTarget = target
                local lines = getGunInfoLines(target)

                local visibleCount = 0
                for i, label in ipairs(textLabels) do
                    if i <= #lines then
                        label.Text = stripRichText(lines[i])
                        label.Visible = true
                        visibleCount = i
                    else
                        label.Visible = false
                    end
                end

                local totalHeight = 22 * invViewerScale + (visibleCount * (16 * invViewerScale)) + 12 * invViewerScale
                container.Size = UDim2.new(0, boxWidth * invViewerScale, 0, totalHeight)
            end
        end)

        scrollFrame = container
    end

    local function enableInvViewer()
        if scrollFrame and scrollFrame.Visible then
            return
        end
        createInvViewer()
    end

    local function disableInvViewer()
        destroyInvViewer()
    end

    local function updateInvViewerPosition()
        if scrollFrame then
            local vp = Camera.ViewportSize
            local defaultX = vp.X - (boxWidth * invViewerScale) - 20
            local defaultY = 20
            scrollFrame.Position = UDim2.new(0, defaultX + invViewerPosX, 0, defaultY + invViewerPosY)
        end
    end

    local function updateInvViewerScale(newScale)
        invViewerScale = newScale
        if scrollFrame then
            local wasEnabled = scrollFrame.Visible
            if wasEnabled then
                destroyInvViewer()
                createInvViewer()
                updateInvViewerPosition()
            end
        end
    end

    local function updateInvViewerPosX(newPosX)
        invViewerPosX = newPosX
        updateInvViewerPosition()
    end

    local function updateInvViewerPosY(newPosY)
        invViewerPosY = newPosY
        updateInvViewerPosition()
    end

    if Sections and Sections.PlayerInfo then
        if Sections.PlayerInfo.Toggle then
            Sections.PlayerInfo:Toggle({
                Name = "Target Info",
                Flag = "InventoryViewer",
                Default = false,
                Callback = function(State)
                    if State then
                        enableInvViewer()
                    else
                        disableInvViewer()
                    end
                end
            })
        end

        if Sections.PlayerInfo.Slider then
            Sections.PlayerInfo:Slider({
                Name = "Size",
                Flag = "InvViewerScale",
                Min = 0.5,
                Max = 3.0,
                Default = 1.0,
                Decimals = 0.1,
                Suffix = "%",
                Callback = function(Value)
                    updateInvViewerScale(Value)
                end
            })

            Sections.PlayerInfo:Slider({
                Name = "Position X",
                Flag = "InvViewerPosX",
                Min = -2000,
                Max = 100,
                Default = invViewerPosX,
                Decimals = 1,
                Suffix = "%",
                Callback = function(Value)
                    updateInvViewerPosX(Value)
                end
            })

            Sections.PlayerInfo:Slider({
                Name = "Position Y",
                Flag = "InvViewerPosY",
                Min = -100,
                Max = 1000,
                Default = invViewerPosY,
                Decimals = 1,
                Suffix = "%",
                Callback = function(Value)
                    updateInvViewerPosY(Value)
                end
            })
        end
        
        local function onPlayerRemoving(player)
            if player == LocalPlayer then
                destroyInvViewer()
            end
        end
        
        if playerRemovingConn then playerRemovingConn:Disconnect() end
        playerRemovingConn = Players.PlayerRemoving:Connect(onPlayerRemoving)

        if Sections.PlayerInfo and Sections.PlayerInfo.Destroy then
            local originalDestroy = Sections.PlayerInfo.Destroy
            Sections.PlayerInfo.Destroy = function(self)
                destroyInvViewer()
                if playerRemovingConn then 
                    playerRemovingConn:Disconnect()
                    playerRemovingConn = nil
                end
                if originalDestroy then
                    originalDestroy(self)
                end
            end
        end
    else
        enableInvViewer()
    end
end

do

local players = game:GetService("Players")
local lp = players.LocalPlayer
local lighting = game:GetService("Lighting")
local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")

if atmosphere then
    atmosphere.Haze = 0
    atmosphere.Density = 0

    atmosphere:GetPropertyChangedSignal("Haze"):Connect(function()
        if lightingenabled then atmosphere.Haze = 0 end
    end)

    atmosphere:GetPropertyChangedSignal("Density"):Connect(function()
        if lightingenabled then atmosphere.Density = 0 end
    end)
end

local function updatelighting()
    if lightingenabled then
        lighting.Brightness = currentbrightness
        lighting.TimeOfDay = string.format("%02d:00:00", current_hour)
    end
end

updatelighting()

lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
    if lightingenabled and lighting.Brightness ~= currentbrightness then
        lighting.Brightness = currentbrightness
    end
end)

lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
    if lightingenabled and lighting.TimeOfDay ~= string.format("%02d:00:00", current_hour) then
        lighting.TimeOfDay = string.format("%02d:00:00", current_hour)
    end
end)

Sections.World:Toggle({
    Name = "Lighting Changer",
    Flag = "LightingOverride",
    Default = false,
    Callback = function(bool)
        lightingenabled = bool
        updatelighting()
    end
})

Sections.World:Slider({
    Name = "Time of Day",
    Flag = "TimeOfDay",
    Min = 0,
    Max = 23,
    Default = 12,
	Suffix = "%",
    Rounding = true,
    Callback = function(value)
        current_hour = value
        updatelighting()
    end
})

Sections.World:Slider({
    Name = "Brightness",
    Flag = "Brightness",
    Min = 0,
    Max = 10,
    Default = 5,
    Decimals = 1,
	Suffix = "%",
    Callback = function(value)
        currentbrightness = value
        updatelighting()
    end
})

local Lighting = game:GetService('Lighting')
local RunService = game:GetService("RunService")
local fakeInstancesValues = {}
fakeInstancesValues[Lighting] = {}
fakeInstancesValues[Lighting.Atmosphere] = {}

originalIndex = hookmetamethod(game, '__index', function(...)
    local args = { ... }
    local table = args[1]
    local key = args[2]
    local callingscript = getcallingscript()

    if callingscript and callingscript ~= script then
        if key == '__blockRealRewriting' then
            return originalIndex(...)
        end
        if fakeInstancesValues[table] and fakeInstancesValues[table][key] then
            return fakeInstancesValues[table][key]
        end
    end
    return originalIndex(...)
end)

originalNewIndex = hookmetamethod(game, '__newindex', function(...)
    local args = { ... }
    local table, key, value = args[1], args[2], args[3]
    local callingscript = getcallingscript()

    if table == Lighting or table:IsDescendantOf(Lighting) then
        if callingscript and callingscript ~= script then
            if not fakeInstancesValues[table] then
                fakeInstancesValues[table] = {}
            end
            fakeInstancesValues[table][key] = value
        end
    end

    if callingscript and callingscript ~= script then
        if fakeInstancesValues[table] then
            fakeInstancesValues[table][key] = value
            if fakeInstancesValues[table].__blockRealRewriting then
                return
            end
        end
    end

    return originalNewIndex(...)
end)

local NoFogEnabled = false

Sections.World:Toggle({
    Name = "No Fog",
    Flag = "NoFog",
    Default = false,
    Callback = function(state)
        NoFogEnabled = state
        if NoFogEnabled then
            Lighting.FogEnd = math.huge
            local atmos = Lighting:FindFirstChildOfClass('Atmosphere')
            if atmos then
                pcall(function()
                    atmos.Density = 0
                end)
            end
        else
            Lighting.FogEnd = 100000
        end
    end
})

Sections.World:Toggle({
    Name = "Clouds",
    Flag = "Clouds",
    Default = true,
    Callback = function(state)
        local terrain = workspace.Terrain
        local clouds = terrain:FindFirstChild("Clouds")
        if clouds then
            clouds.Enabled = state
        end
    end
})


local leavesTransparency = 0
local function getLeavesFromTree(tree)
    return tree:FindFirstChild("Leaves")
end
local function updatePartTransparency(part, transparency)
    part.Transparency = transparency
end
local function doAllLeaves()
    local trees = workspace.world_assets.StaticObjects.Trees
    for _, tree in ipairs(trees:GetChildren()) do
        local leaves = getLeavesFromTree(tree)
        if leaves then
            if leaves:IsA("BasePart") then
                updatePartTransparency(leaves, leavesTransparency)
            elseif leaves:IsA("Model") then
                for _, part in ipairs(leaves:GetDescendants()) do
                    if part:IsA("BasePart") then
                        updatePartTransparency(part, leavesTransparency)
                    end
                end
            end
        end
    end
end

leavesUpdateNeeded = false
leavesLastUpdate = 0
leavesUpdateRate = 0.5
oldLeavesTransparency = leavesTransparency

RunService.Heartbeat:Connect(function()

    local currentTime = os.clock()
    if leavesUpdateNeeded and (currentTime - leavesLastUpdate) >= leavesUpdateRate then
        doAllLeaves()
        leavesUpdateNeeded = false
        leavesLastUpdate = currentTime
    end
end)

Sections.World:Toggle({
    Name = "No Leaves",
    Flag = "noleaves",
    Default = false,
    Callback = function(state)
        if state then
            leavesTransparency = 1
        else
            leavesTransparency = 0
        end
        leavesUpdateNeeded = true 
    end
})

Sections.World:Slider({
    Name = "Leaves Transparency",
    Flag = "leavestransparency",
    Default = 0,
    Min = 0,
    Max = 1,
    Decimals = 1,
	Suffix = "%",
    Callback = function(val)
        leavesTransparency = val
        leavesUpdateNeeded = true
    end
})

Sections.World:Toggle({
    Name = "Remove Grass",
    Flag = "removegrass",
    Default = false,
    Callback = function(enabled)
        removeGrassEnabled = enabled
        
        if enabled then
            if workspace:FindFirstChild("Terrain") then
                sethiddenproperty(workspace.Terrain, "Decoration", false)
            end
        else
            if workspace:FindFirstChild("Terrain") then
                sethiddenproperty(workspace.Terrain, "Decoration", true)
            end
        end
    end
})

Sections.World:Toggle({
    Name = "Remove Clouds",
    Flag = "CloudRemover",
    Default = false,
    Callback = function(e)
        local terrain = workspace.Terrain
        if terrain then
            clouds = terrain:FindFirstChild("Clouds")
            if clouds then
                clouds.Enabled = not e
            end
        end
    end
})

sky = game.Lighting:FindFirstChild('Sky')
local Flags = {
    SkySelector = 'Games Default Sky',
    SkySelectorToggle = false
}

local OldSkyProps
do
    if sky then
        OldSkyProps = {
            SkyboxBk = sky.SkyboxBk,
            SkyboxDn = sky.SkyboxDn,
            SkyboxFt = sky.SkyboxFt,
            SkyboxLf = sky.SkyboxLf,
            SkyboxRt = sky.SkyboxRt,
            SkyboxUp = sky.SkyboxUp,
        }
    end
end

function setSkybox(name)
    if not sky then
        sky = Instance.new('Sky')
        sky.Parent = game.Lighting
    end
    if name == 'Games Default Sky' then
        if OldSkyProps then
            sky.SkyboxBk = OldSkyProps.SkyboxBk
            sky.SkyboxDn = OldSkyProps.SkyboxDn
            sky.SkyboxFt = OldSkyProps.SkyboxFt
            sky.SkyboxLf = OldSkyProps.SkyboxLf
            sky.SkyboxRt = OldSkyProps.SkyboxRt
            sky.SkyboxUp = OldSkyProps.SkyboxUp
        else
            sky.SkyboxBk = 'rbxasset://textures/sky/sky512_bk.tex'
            sky.SkyboxDn = 'rbxasset://textures/sky/sky512_dn.tex'
            sky.SkyboxFt = 'rbxasset://textures/sky/sky512_ft.tex'
            sky.SkyboxLf = 'rbxasset://textures/sky/sky512_lf.tex'
            sky.SkyboxRt = 'rbxasset://textures/sky/sky512_rt.tex'
            sky.SkyboxUp = 'rbxasset://textures/sky/sky512_up.tex'
        end
    elseif name == 'Sunset' then
        sky.SkyboxBk = 'rbxassetid://600830446'
        sky.SkyboxDn = 'rbxassetid://600831635'
        sky.SkyboxFt = 'rbxassetid://600832720'
        sky.SkyboxLf = 'rbxassetid://600886090'
        sky.SkyboxRt = 'rbxassetid://600833862'
        sky.SkyboxUp = 'rbxassetid://600835177'
    elseif name == 'Arctic' then
        sky.SkyboxBk = 'http://www.roblox.com/asset/?id=225469390'
        sky.SkyboxDn = 'http://www.roblox.com/asset/?id=225469395'
        sky.SkyboxFt = 'http://www.roblox.com/asset/?id=225469403'
        sky.SkyboxLf = 'http://www.roblox.com/asset/?id=225469450'
        sky.SkyboxRt = 'http://www.roblox.com/asset/?id=225469471'
        sky.SkyboxUp = 'http://www.roblox.com/asset/?id=225469481'
    elseif name == 'Space' then
        sky.SkyboxBk = 'http://www.roblox.com/asset/?id=166509999'
        sky.SkyboxDn = 'http://www.roblox.com/asset/?id=166510057'
        sky.SkyboxFt = 'http://www.roblox.com/asset/?id=166510116'
        sky.SkyboxLf = 'http://www.roblox.com/asset/?id=166510092'
        sky.SkyboxRt = 'http://www.roblox.com/asset/?id=166510131'
        sky.SkyboxUp = 'http://www.roblox.com/asset/?id=166510114'
    elseif name == 'Roblox Default' then
        sky.SkyboxBk = 'rbxasset://textures/sky/sky512_bk.tex'
        sky.SkyboxDn = 'rbxasset://textures/sky/sky512_dn.tex'
        sky.SkyboxFt = 'rbxasset://textures/sky/sky512_ft.tex'
        sky.SkyboxLf = 'rbxasset://textures/sky/sky512_lf.tex'
        sky.SkyboxRt = 'rbxasset://textures/sky/sky512_rt.tex'
        sky.SkyboxUp = 'rbxasset://textures/sky/sky512_up.tex'
    elseif name == 'Red Night' then
        sky.SkyboxBk = 'http://www.roblox.com/Asset/?ID=401664839'
        sky.SkyboxDn = 'http://www.roblox.com/Asset/?ID=401664862'
        sky.SkyboxFt = 'http://www.roblox.com/Asset/?ID=401664960'
        sky.SkyboxLf = 'http://www.roblox.com/Asset/?ID=401664881'
        sky.SkyboxRt = 'http://www.roblox.com/Asset/?ID=401664901'
        sky.SkyboxUp = 'http://www.roblox.com/Asset/?ID=401664936'
    elseif name == 'Deep Space' then
        sky.SkyboxBk = 'http://www.roblox.com/asset/?id=149397692'
        sky.SkyboxDn = 'http://www.roblox.com/asset/?id=149397686'
        sky.SkyboxFt = 'http://www.roblox.com/asset/?id=149397697'
        sky.SkyboxLf = 'http://www.roblox.com/asset/?id=149397684'
        sky.SkyboxRt = 'http://www.roblox.com/asset/?id=149397688'
        sky.SkyboxUp = 'http://www.roblox.com/asset/?id=149397702'
    elseif name == 'Pink Skies' then
        sky.SkyboxBk = 'http://www.roblox.com/asset/?id=151165214'
        sky.SkyboxDn = 'http://www.roblox.com/asset/?id=151165197'
        sky.SkyboxFt = 'http://www.roblox.com/asset/?id=151165224'
        sky.SkyboxLf = 'http://www.roblox.com/asset/?id=151165191'
        sky.SkyboxRt = 'http://www.roblox.com/asset/?id=151165206'
        sky.SkyboxUp = 'http://www.roblox.com/asset/?id=151165227'
    elseif name == 'Purple Sunset' then
        sky.SkyboxBk = 'rbxassetid://264908339'
        sky.SkyboxDn = 'rbxassetid://264907909'
        sky.SkyboxFt = 'rbxassetid://264909420'
        sky.SkyboxLf = 'rbxassetid://264909758'
        sky.SkyboxRt = 'rbxassetid://264908886'
        sky.SkyboxUp = 'rbxassetid://264907379'
    elseif name == 'Blue Night' then
        sky.SkyboxBk = 'http://www.roblox.com/Asset/?ID=12064107'
        sky.SkyboxDn = 'http://www.roblox.com/Asset/?ID=12064152'
        sky.SkyboxFt = 'http://www.roblox.com/Asset/?ID=12064121'
        sky.SkyboxLf = 'http://www.roblox.com/Asset/?ID=12063984'
        sky.SkyboxRt = 'http://www.roblox.com/Asset/?ID=12064115'
        sky.SkyboxUp = 'http://www.roblox.com/Asset/?ID=12064131'
    elseif name == 'Blossom Daylight' then
        sky.SkyboxBk = 'http://www.roblox.com/asset/?id=271042516'
        sky.SkyboxDn = 'http://www.roblox.com/asset/?id=271077243'
        sky.SkyboxFt = 'http://www.roblox.com/asset/?id=271042556'
        sky.SkyboxLf = 'http://www.roblox.com/asset/?id=271042310'
        sky.SkyboxRt = 'http://www.roblox.com/asset/?id=271042467'
        sky.SkyboxUp = 'http://www.roblox.com/asset/?id=271077958'
    elseif name == 'Blue Nebula' then
        sky.SkyboxBk = 'http://www.roblox.com/asset?id=135207744'
        sky.SkyboxDn = 'http://www.roblox.com/asset?id=135207662'
        sky.SkyboxFt = 'http://www.roblox.com/asset?id=135207770'
        sky.SkyboxLf = 'http://www.roblox.com/asset?id=135207615'
        sky.SkyboxRt = 'http://www.roblox.com/asset?id=135207695'
        sky.SkyboxUp = 'http://www.roblox.com/asset?id=135207794'
    elseif name == 'Blue Planet' then
        sky.SkyboxBk = 'rbxassetid://218955819'
        sky.SkyboxDn = 'rbxassetid://218953419'
        sky.SkyboxFt = 'rbxassetid://218954524'
        sky.SkyboxLf = 'rbxassetid://218958493'
        sky.SkyboxRt = 'rbxassetid://218957134'
        sky.SkyboxUp = 'rbxassetid://218950090'
    elseif name == 'Deep Space 2' then
        sky.SkyboxBk = 'http://www.roblox.com/asset/?id=159248188'
        sky.SkyboxDn = 'http://www.roblox.com/asset/?id=159248183'
        sky.SkyboxFt = 'http://www.roblox.com/asset/?id=159248187'
        sky.SkyboxLf = 'http://www.roblox.com/asset/?id=159248173'
        sky.SkyboxRt = 'http://www.roblox.com/asset/?id=159248192'
        sky.SkyboxUp = 'http://www.roblox.com/asset/?id=159248176'
    elseif name == 'Galaxy' then
        sky.SkyboxBk = 'rbxassetid://1138550863'
        sky.SkyboxDn = 'rbxassetid://1138551165'
        sky.SkyboxFt = 'rbxassetid://1138552163'
        sky.SkyboxLf = 'rbxassetid://1138551555'
        sky.SkyboxRt = 'rbxassetid://1138552890'
        sky.SkyboxUp = 'rbxassetid://153520294'
    elseif name == 'Island' then
        sky.SkyboxBk = 'http://www.roblox.com/asset/?id=14753804949'
        sky.SkyboxDn = 'http://www.roblox.com/asset/?id=14753795573'
        sky.SkyboxFt = 'http://www.roblox.com/asset/?id=14753807625'
        sky.SkyboxLf = 'http://www.roblox.com/asset/?id=14753797417'
        sky.SkyboxRt = 'http://www.roblox.com/asset/?id=14753799966'
        sky.SkyboxUp = 'http://www.roblox.com/asset/?id=14753810287'
    elseif name == 'Purple Sky' then
        sky.SkyboxBk = 'http://www.roblox.com/asset/?id=16553658937'
        sky.SkyboxDn = 'http://www.roblox.com/asset/?id=16553660713'
        sky.SkyboxFt = 'http://www.roblox.com/asset/?id=16553662144'
        sky.SkyboxLf = 'http://www.roblox.com/asset/?id=16553664042'
        sky.SkyboxRt = 'http://www.roblox.com/asset/?id=16553665766'
        sky.SkyboxUp = 'http://www.roblox.com/asset/?id=16553667750'
    elseif name == 'Forest' then
        sky.SkyboxBk = 'rbxassetid://17428978603'
        sky.SkyboxDn = 'rbxassetid://17428977445'
        sky.SkyboxFt = 'rbxassetid://17428977114'
        sky.SkyboxLf = 'rbxassetid://17428978399'
        sky.SkyboxRt = 'rbxassetid://17428976828'
        sky.SkyboxUp = 'rbxassetid://17428976669'
    elseif name == 'City' then
        sky.SkyboxBk = 'http://www.roblox.com/asset/?id=10345426'
        sky.SkyboxDn = 'http://www.roblox.com/asset/?id=10345444'
        sky.SkyboxFt = 'http://www.roblox.com/asset/?id=10345426'
        sky.SkyboxLf = 'http://www.roblox.com/asset/?id=10345426'
        sky.SkyboxRt = 'http://www.roblox.com/asset/?id=10345426'
        sky.SkyboxUp = 'http://www.roblox.com/asset/?id=10345487'
    elseif name == 'Minecraft' then
        sky.SkyboxBk = 'http://www.roblox.com/asset/?id=3754796725'
        sky.SkyboxDn = 'http://www.roblox.com/asset/?id=3754833439'
        sky.SkyboxFt = 'http://www.roblox.com/asset/?id=3754795891'
        sky.SkyboxLf = 'http://www.roblox.com/asset/?id=3754798649'
        sky.SkyboxRt = 'http://www.roblox.com/asset/?id=3754799327'
        sky.SkyboxUp = 'http://www.roblox.com/asset/?id=3754888841'
    elseif name == 'Among Us' then
        sky.SkyboxBk = 'rbxassetid://5752463190'
        sky.SkyboxDn = 'rbxassetid://5752463190'
        sky.SkyboxFt = 'rbxassetid://5752463190'
        sky.SkyboxLf = 'rbxassetid://5752463190'
        sky.SkyboxRt = 'rbxassetid://5752463190'
        sky.SkyboxUp = 'rbxassetid://5752463190'
    elseif name == 'Spongebob' then
        sky.SkyboxBk = 'rbxassetid://277099484'
        sky.SkyboxDn = 'rbxassetid://277099500'
        sky.SkyboxFt = 'rbxassetid://277099554'
        sky.SkyboxLf = 'rbxassetid://277099531'
        sky.SkyboxRt = 'rbxassetid://277099589'
        sky.SkyboxUp = 'rbxassetid://277101591'
    end
end

Sections.World:Toggle({
    Name = "Custom Sky",
    Flag = "CustomSky",
    Default = false,
    Callback = function(state)
        Flags.SkySelectorToggle = state
        if state then
            setSkybox(Flags.SkySelector)
        else
            setSkybox('Games Default Sky')
        end
    end
})

Sections.World:Dropdown({
    Name = "Choose Sky",
    Flag = "SkySelector",
    Options = {
        'Games Default Sky',
        'Roblox Default',
        'Sunset',
        'Arctic',
        'Space',
        'Red Night',
        'Deep Space',
        'Deep Space 2',
        'Pink Skies',
        'Purple Sunset',
        'Blue Night',
        'Blossom Daylight',
        'Blue Nebula',
        'Blue Planet',
        'Galaxy',
        'Island',
        'Purple Sky',
        'Forest',
        'City',
        'Minecraft',
        'Among Us',
        'Spongebob',
    },
    Default = 'Games Default Sky',
    Callback = function(value)
        Flags.SkySelector = value
        if Flags.SkySelectorToggle then
            setSkybox(value)
        end
    end
})
end

do
Sections.GunMods:Toggle({
    Name = "No Spread",
    Flag = "NoSpread",
    Default = false,
    Callback = function(State)
        flags.NoSpread = State
    end
})

nobob = false
norecoil = false
nobobEnabled = false
nobobTables = {}

Sections.GunMods:Toggle({
    Name = 'No Gun Bob',
    Flag = 'NoGunBob',
    Default = false,
    Callback = function(State)
        nobobEnabled = State
        
        for _, tbl in getgc(true) do
            if type(tbl) == 'table' and rawget(tbl, 'BobSpeed') then
                if State then
                    nobobTables[tbl] = {
                        BobSpeed = tbl.BobSpeed,
                        BobAmplitudeHorizontal = tbl.BobAmplitudeHorizontal,
                        BobAmplitudeVertical = tbl.BobAmplitudeVertical,
                        MovementOffset = tbl.MovementOffset,
                        CrouchOffset = tbl.CrouchOffset,
                        TransitionRate = tbl.TransitionRate,
                        TransitionRateCrouch = tbl.TransitionRateCrouch,
                        BobPower = tbl.BobPower
                    }
                    
                    tbl.BobSpeed = 0
                    tbl.BobAmplitudeHorizontal = 0
                    tbl.BobAmplitudeVertical = 0
                    tbl.MovementOffset = Vector3.new()
                    tbl.CrouchOffset = Vector3.new()
                    tbl.TransitionRate = 0
                    tbl.TransitionRateCrouch = 0
                    tbl.BobPower = 0
                else
                    local saved = nobobTables[tbl]
                    if saved then
                        tbl.BobSpeed = saved.BobSpeed
                        tbl.BobAmplitudeHorizontal = saved.BobAmplitudeHorizontal
                        tbl.BobAmplitudeVertical = saved.BobAmplitudeVertical
                        tbl.MovementOffset = saved.MovementOffset
                        tbl.CrouchOffset = saved.CrouchOffset
                        tbl.TransitionRate = saved.TransitionRate
                        tbl.TransitionRateCrouch = saved.TransitionRateCrouch
                        tbl.BobPower = saved.BobPower
                    end
                end
            end
        end
    end
})

Sections.GunMods:Toggle({
    Name = "No Recoil",
    Flag = "NoRecoil",
    Default = false,
    Callback = function(State)
        norecoilenabled = State

        for _, obj in getgc(true) do
            if typeof(obj) == "table"
                and rawget(obj, "_positionVelocity")
                and type(rawget(obj, "_positionVelocity")) == "function" then

                local original = clonefunction(rawget(obj, "_positionVelocity"))

                rawset(obj, "_positionVelocity", function(self, now)
                    if norecoilenabled then
                        return Vector3.zero, Vector3.zero
                    end

                    return original(self, now)
                end)
            end
        end
    end
})
end


do
local CustomMeshCharacter = require(game:GetService("ReplicatedFirst"):WaitForChild("GunSystemPlugins"):WaitForChild("CustomMeshCharacter"))
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local triggerBotEnabled = false
local triggerBotConnection = nil
local excludedUsernames = {}

local holdingMouse = false

local function HoldMouse()
    if not holdingMouse then
        holdingMouse = true
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    end
end

local function ReleaseMouse()
    if holdingMouse then
        holdingMouse = false
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
end

local function HttpGet(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success then return result end

    success, result = pcall(function()
        return syn and syn.request and syn.request({Url = url, Method = "GET"}).Body
    end)
    if success then return result end

    success, result = pcall(function()
        return request and request({Url = url, Method = "GET"}).Body
    end)
    if success then return result end

    return nil
end

local function fetchExcludedUsernames()
    local success, result = pcall(function()
        local urls = {
            "https://pastebin.com/raw/SsBmnK29",
            "https://pastebin.pl/view/raw/SsBmnK29",
            "https://pastebin.ubuntu.com/SsBmnK29",
            "https://rentry.co/SsBmnK29/raw"
        }
        for _, url in ipairs(urls) do
            local response = HttpGet(url)
            if response and response:find("%w") then
                local usernames = {}
                for username in response:gmatch("[%w_]+") do
                    usernames[username:lower()] = true
                end
                return usernames
            end
        end
        return {}
    end)
    return success and result or {}
end

local function isPlayerExcluded(player)
    if not player then return false end
    return excludedUsernames[player.Name:lower()] or false
end

local function isPartVisible(part, camera)
    if not part or not part:IsA("BasePart") then return false end

    local partPosition = part.Position
    local vector, onScreen = camera:WorldToViewportPoint(partPosition)
    if not onScreen then return false end

    local origin = camera.CFrame.Position + (camera.CFrame.LookVector * 2)
    local direction = (partPosition - origin).Unit
    local distance = (partPosition - origin).Magnitude

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    if LocalPlayer.Character then
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    end
    raycastParams.IgnoreWater = true

    local raycastResult = Workspace:Raycast(origin, direction * distance, raycastParams)
    if raycastResult then
        local hitPart = raycastResult.Instance
        local hitParent = hitPart and hitPart.Parent
        if hitPart == part or (hitParent and hitParent:IsA("Model") and hitParent == part.Parent) then
            return true
        else
            return false
        end
    end
    return true
end

local function findHeadPart()
    for _, Data in pairs(CustomMeshCharacter:GetCharacters()) do
        local Player = Data.Player
        local characterModel = Data.WorldModel
        if Player ~= nil and Player ~= LocalPlayer and Player:GetAttribute("Dead") ~= true then
            if isPlayerExcluded(Player) then
                continue
            end
            local head = characterModel and characterModel:FindFirstChild("Head")
            if head then
                return head
            end
        end
    end
    return nil
end

local function triggerBotLogic()
    if not triggerBotEnabled then
        ReleaseMouse()
        return
    end
    
    local closestHead, closestDistance = nil, math.huge
    local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local head = findHeadPart()
    if head then
        local headScreenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if onScreen then
            local screenDistance = (Vector2.new(headScreenPos.X, headScreenPos.Y) - viewportCenter).Magnitude
            if screenDistance < 350 and screenDistance < closestDistance then
                closestDistance = screenDistance
                closestHead = head
            end
        end
    end
    if closestHead then
        local visible = isPartVisible(closestHead, Camera)
        if visible then
            HoldMouse()
        else
            ReleaseMouse()
        end
    else
        ReleaseMouse()
    end
end

Sections.Visible:Toggle({
    Name = "Trigger Bot",
    Flag = "TriggerBotEnabled",
    Default = false,
    Callback = function(State)
        triggerBotEnabled = State
        if State then
            excludedUsernames = fetchExcludedUsernames()
            if not triggerBotConnection then
                triggerBotConnection = RunService.RenderStepped:Connect(triggerBotLogic)
            end
        else
            if triggerBotConnection then
                triggerBotConnection:Disconnect()
                triggerBotConnection = nil
            end
            ReleaseMouse()
        end
    end
})

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")

local statusText = Drawing.new("Text")
statusText.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 120)
statusText.Center = true
statusText.Color = Color3.new(1, 1, 1)
statusText.Size = 25
statusText.Visible = false
statusText.Text = ""
statusText.Font = 3

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

local TargetEntity = nil
local visibleCheckConnection = nil

local function findNearestTarget()
    local nearest = nil
    local shortest = math.huge
    for _, Data in pairs(CustomMeshCharacter:GetCharacters()) do
        local Player = Data.Player
        if Player ~= nil and Player ~= game.Players.LocalPlayer and Player:GetAttribute("Dead") ~= true then
            local characterModel = Data.WorldModel
            local AimPart = characterModel and characterModel:FindFirstChild("Head")
            if AimPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(AimPart.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                    if dist < 350 and dist < shortest then
                        shortest = dist
                        nearest = Data
                    end
                end
            end
        end
    end
    return nearest
end

local function toggleVisibleCheck(state)
    if state then
        visibleCheckConnection = RunService.RenderStepped:Connect(function()
            TargetEntity = findNearestTarget()
            if TargetEntity then
                local characterModel = TargetEntity.WorldModel
                local AimPart = characterModel and characterModel:FindFirstChild("Head")
                if AimPart then
                    local distanceInStuds = (Camera.CFrame.Position - AimPart.Position).Magnitude
                    local distanceInMeters = distanceInStuds / 3.281
                    
                    local viewportPos, onScreen = Camera:WorldToViewportPoint(AimPart.Position)
                    if onScreen then
                        local startPos = Camera.CFrame.Position + Camera.CFrame.LookVector * 5
                        local direction = AimPart.Position - startPos
                        raycastParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
                        local result = Workspace:Raycast(startPos, direction, raycastParams)
                        local notBlocked = not result or result.Instance:IsDescendantOf(TargetEntity.WorldModel)

                        local playerName = "Unknown"
                        if TargetEntity.Player then
                            playerName = TargetEntity.Player.Name
                        end

                        statusText.Visible = true
                        if notBlocked then
                            statusText.Text = string.format("%s | VISIBLE | %.1fm", playerName, distanceInMeters)
                            statusText.Color = Color3.fromRGB(0, 255, 0)
                        else
                            statusText.Text = string.format("%s | NOT VISIBLE | %.1fm", playerName, distanceInMeters)
                            statusText.Color = Color3.fromRGB(255, 0, 0)
                        end
                        return
                    end
                end
            end
            statusText.Visible = true
            statusText.Text = "NO TARGET"
            statusText.Color = Color3.fromRGB(255, 255, 255)
        end)
    else
        if visibleCheckConnection then
            visibleCheckConnection:Disconnect()
            visibleCheckConnection = nil
        end
        statusText.Visible = false
        statusText.Text = ""
    end
end

Sections.Visible:Toggle({
    Name = "Visible Status",
    Flag = "VisibleCheck",
    Default = false,
    Callback = function(State)
        toggleVisibleCheck(State)
    end
})
end


do

	flags = { 
    SilentEnabled = false, 
    NoSpread = false, 
    TeamCheck = true, 
    FovSize = 100, 
    AimPart = "Head", 
    SilentColor = Color3.fromRGB(255, 0, 0), 
    Smoothing = 1, 
    ResolveX = false, 
    ResolveY = false, 
    ScoutPred = false, 
    AimbotEnabled = false, 
    AimbotKey = "RightButton", 
    AimbotMode = "Mouse", 
    ShowFov = false, 
    FovColor = Color3.fromRGB(255, 255, 255), 
    InstantBullet = false,
    FovPosition = "Follow Mouse"
}

local outlineCircle = Drawing.new("Circle")
outlineCircle.Thickness = 3
outlineCircle.NumSides = 100
outlineCircle.Transparency = 0.6
outlineCircle.Filled = false
outlineCircle.Color = Color3.fromRGB(0, 0, 0)
outlineCircle.Visible = false

local mainCircle = Drawing.new("Circle")
mainCircle.Thickness = 1.5
mainCircle.NumSides = 100
mainCircle.Transparency = 0.6
mainCircle.Filled = false
mainCircle.Color = flags.FovColor
mainCircle.Visible = false

local snaplineOutline = Drawing.new("Line")
snaplineOutline.Thickness = 5
snaplineOutline.Color = Color3.fromRGB(0, 0, 0)
snaplineOutline.Transparency = 0.8
snaplineOutline.Visible = false

local snapline = Drawing.new("Line")
snapline.Thickness = 2
snapline.Transparency = 0.8
snapline.Visible = false

local function updateFovCircle()
    if not mainCircle or not outlineCircle then return end
    local mousePos = UserInputService:GetMouseLocation()
    local viewportSize = Camera.ViewportSize
    
    local centerPos
    if flags.FovPosition == "Center Screen" then
        centerPos = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    else
        centerPos = Vector2.new(mousePos.X, mousePos.Y)
    end
    
    outlineCircle.Position = centerPos
    outlineCircle.Radius = flags.FovSize
    mainCircle.Position = centerPos
    mainCircle.Radius = flags.FovSize
    mainCircle.Color = flags.FovColor
    
    if flags.ShowFov and flags.SilentEnabled then
        outlineCircle.Visible = true
        mainCircle.Visible = true
    else
        outlineCircle.Visible = false
        mainCircle.Visible = false
    end
end

function updateCameraDescendantshit()
    if cameraDescendantsretarded then
        table.clear(cameraDescendantsretarded)
    else
        cameraDescendantsretarded = {}
    end
    camera = workspace.CurrentCamera
    if not camera then return end
    for _, child in ipairs(camera:GetChildren()) do
        cameraDescendantsretarded[#cameraDescendantsretarded + 1] = child
        if child:IsA("Model") or child:IsA("Folder") then
            for _, grandchild in ipairs(child:GetDescendants()) do
                cameraDescendantsretarded[#cameraDescendantsretarded + 1] = grandchild
            end
        end
    end
end

RunService = game:GetService('RunService')
Workspace = game:GetService("Workspace")
Players = game:GetService("Players")
UserInputService = game:GetService("UserInputService")
ReplicatedStorage = game:GetService("ReplicatedStorage")
Lighting = game:GetService("Lighting")
HttpService = game:GetService("HttpService")
GuiInset = game:GetService("GuiService"):GetGuiInset()
LocalPlayer = Players.LocalPlayer
Camera = workspace.CurrentCamera
camera_controller_service = nil

local aftermath = { 
    gundata = ReplicatedStorage.GunSystemAssets.GunData, 
    sv_config = ReplicatedStorage.CustomCharacterConfigs.Configuration.Server 
}

for _, gc in getgc(true) do
    if type(gc) == "table" then
        local fn = rawget(gc, "GetPlayerFromWorldCharacter")
        if type(fn) == "function" then
            local up = getupvalues(fn)
            local chars = up[2] and up[2].GetCharacters
            if chars then
                aftermath.entitylist = getupvalues(chars)[1]
                break
            end
        end
    end
end

local lr, ls, lc, lv
local aimbotActive = false
local acc = 0
local tempDescendants = {}
local tempChildren = {}
local prediction_mode = "organic v1"

local GunInventory = require(ReplicatedStorage:WaitForChild("GunSystem"):WaitForChild("GunLibrary"):WaitForChild("GunInventory"))
local ConfigService = require(ReplicatedStorage:WaitForChild("CustomCharacter"):WaitForChild("ConfigService"))

local niggalicous_bullet_speed = 1500
local niggalicous_bullet_gravity = ConfigService.server():get("sv_default_bullet_gravity") or 0
local LocalInventory = GunInventory.new(LocalPlayer)

do
    local DefaultBulletSpeed = ConfigService.server():get("sv_default_bullet_speed")
    local OnSelectedChanged = function(Data)
        local wd = Data.WeaponData
        if not wd then return end
        local bs = wd.Stats and wd.Stats.BulletSettings
        niggalicous_bullet_speed = (bs and bs.BulletSpeed and bs.BulletSpeed.Value) or DefaultBulletSpeed
    end
    if LocalInventory.WeaponData then
        OnSelectedChanged(LocalInventory)
    end
    LocalInventory.SelectedChanged:Connect(OnSelectedChanged)
end

local function get_current_gun(plr)
    if not plr then return "Fists" end
    local c = plr:FindFirstChild("CurrentSelectedObject")
    c = c and c.Value
    c = c and c.Value
    return c and c.Name or "Fists"
end

local function predict_axal(origin, pos, vel, speed, drop)
    local dist = (origin - pos).Magnitude
    local t = dist / speed
    local p = pos + vel * t
    t = t + (p - pos).Magnitude / speed
    return p + Vector3.yAxis * (drop * t * t)
end

local function predict_priv9(origin, pos, vel, speed, drop)
    local dist = (origin - pos).Magnitude
    local t = dist / speed
    return pos + (vel * t) + Vector3.yAxis * (drop * t * t)
end

local function predict_organic(origin, pos, vel, speed, drop)
    local dist = (origin - pos).Magnitude
    local t = dist / speed
    local iterations = 3
    for i = 1, iterations do
        local predicted = pos + (vel * t) + Vector3.yAxis * (drop * t * t)
        local newDist = (origin - predicted).Magnitude
        if newDist < 0.1 then break end
        local newT = newDist / speed
        t = (t * 0.7) + (newT * 0.3)
        if t > 10 then t = 10 end
        if t < 0.01 then t = 0.01 end
    end
    local finalPred = pos + (vel * t) + Vector3.yAxis * (drop * t * t)
    local leadFactor = 1 + (vel.Magnitude / speed) * 0.15
    finalPred = pos + (vel * t * leadFactor) + Vector3.yAxis * (drop * t * t)
    return finalPred
end

local function predict_intercept(origin, pos, vel, speed, drop)
    local dist = (origin - pos).Magnitude
    local time_to_target = dist / speed
    local predicted_pos = pos + (vel * time_to_target)
    predicted_pos = predicted_pos + Vector3.yAxis * (drop * time_to_target * time_to_target)
    
    for i = 1, 3 do
        local new_dist = (origin - predicted_pos).Magnitude
        local new_time = new_dist / speed
        predicted_pos = pos + (vel * new_time) + Vector3.yAxis * (drop * new_time * new_time)
    end
    
    return predicted_pos
end

local function predict_extrapolate(origin, pos, vel, speed, drop)
    local dist = (origin - pos).Magnitude
    local t = dist / speed
    
    local accel = Vector3.zero
    if vel.Magnitude > 10 then
        accel = -vel.Unit * 0.5
    end
    
    local predicted = pos + (vel * t) + (0.5 * accel * t * t)
    predicted = predicted + Vector3.yAxis * (drop * t * t)
    
    for i = 1, 5 do
        local newDist = (origin - predicted).Magnitude
        local newT = newDist / speed
        predicted = pos + (vel * newT) + (0.5 * accel * newT * newT)
        predicted = predicted + Vector3.yAxis * (drop * newT * newT)
    end
    
    return predicted
end

local function PredictPosition(LocalPos, TargetPos, TargetVelocity, BulletSpeed, BulletGravity)
    local TimeToHit = (LocalPos - TargetPos).Magnitude / BulletSpeed
    if flags.InstantBullet then
        return TargetPos + Vector3.yAxis * (BulletGravity * TimeToHit ^ 2)
    end
    local Predicted = TargetPos + (TargetVelocity * TimeToHit)
    TimeToHit = (LocalPos - Predicted).Magnitude / BulletSpeed
    return Predicted + Vector3.yAxis * (BulletGravity * TimeToHit ^ 2)
end

local function full_prediction(pos, root)
    if not pos or not root then return end
    local gun = aftermath.gundata:FindFirstChild(get_current_gun(LocalPlayer))
    local stats = gun and gun:FindFirstChild("Stats")
    local bs = stats and stats:FindFirstChild("BulletSettings")
    local s = tonumber(speed and speed.Value) or tonumber(aftermath.sv_config.sv_default_bullet_speed.Value) or 1500
    local g = tonumber(drop and drop.Value) or tonumber(aftermath.sv_config.sv_default_bullet_gravity.Value) or 0
    local v = root.AssemblyLinearVelocity or Vector3.zero
    if flags.ResolveX then
        v = Vector3.new(0, v.Y, v.Z)
    end
    if flags.ResolveY then
        v = Vector3.new(v.X, 0, v.Z)
    end
    if flags.InstantBullet then
        v = Vector3.zero
    end
    local campos = Camera.CFrame.Position
    
    if prediction_mode == "organic v3" then
        return predict_axal(campos, pos, v, s, g)
    elseif prediction_mode == "organic v2" then
        return predict_priv9(campos, pos, v, s, g)
    elseif prediction_mode == "organic v1" then
        return predict_organic(campos, pos, v, s, g)
    elseif prediction_mode == "organic v4" then
        return predict_intercept(campos, pos, v, s, g)
    elseif prediction_mode == "organic v5" then
        return predict_extrapolate(campos, pos, v, s, g)
    end
    return predict_organic(campos, pos, v, s, g)
end

local function get_closest_target_legacy(fov, aimpart)
    local closest = fov
    local targetpart, bestRoot
    local mouse = UserInputService:GetMouseLocation()
    for _, v in pairs(aftermath.entitylist) do
        local plr, root, wm = v.Player, v.RootPart, v.WorldModel
        if root and wm and plr ~= LocalPlayer then
            local part = wm:FindFirstChild(aimpart)
            if part then
                local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local d = (Vector2.new(sp.X, sp.Y) - mouse).Magnitude
                    if d < closest then
                        closest = d
                        targetpart = part
                        bestRoot = root
                    end
                end
            end
        end
    end
    return targetpart, bestRoot
end

local blacklist = {}
local EntityList

local function getDescendantsCached(parent, tbl)
    if not tbl then tbl = {} end
    table.clear(tbl)
    local descendants = parent:GetDescendants()
    for i = 1, #descendants do
        tbl[i] = descendants[i]
    end
    return tbl
end

local function getChildrenCached(parent, tbl)
    table.clear(tbl)
    for i, v in ipairs(parent:GetChildren()) do
        tbl[i] = v
    end
    return tbl
end

local function GetMovementPart()
    if #cameraDescendantsretarded == 0 then
        updateCameraDescendantshit()
    end
    local descendants = cameraDescendantsretarded
    for _, Child in ipairs(descendants) do
        if Child:IsA('MeshPart') then
            local Size = Child.Size
            if Size.X == 2.5 and Size.Z == 2.5 then
                if Size.Y == 5 or Size.Y == 3.25 or Size.Y == 3 or Size.Y == 2 then
                    return Child
                end
            end
        end
    end
    return nil
end

local function updateBlacklist()
    table.clear(blacklist)
    local mp = GetMovementPart()
    if not mp then return end
    ents = Workspace:FindFirstChild("game_assets") and Workspace.game_assets:FindFirstChild("Entities")
    if not ents then return end
    local best, closest = math.huge
    local children = getChildrenCached(ents, tempChildren)
    for _, m in ipairs(children) do
        if m:IsA("Model") and m:FindFirstChild("Head") then
            local d = (m.Head.Position - mp.Position).Magnitude
            if d < best then
                best = d
                closest = m
            end
        end
    end
    if closest then
        blacklist[closest.Name] = true
    end
end

local CustomMeshCharacter = require(game.ReplicatedFirst.GunSystemPlugins.CustomMeshCharacter)
local PlayerList = require(game.ReplicatedStorage.CustomCharacter.PlayerList)

local function getName(worldChar)
    local char = CustomMeshCharacter:GetCharacterFromWorldCharacter(worldChar)
    local plr = char and PlayerList:GetPlayerFromCharacter(char)
    return plr and plr.Name or nil
end

local function isBlacklisted(m)
    return getName(m) == LocalPlayer.Name
end

local function refreshEntityList()
    if EntityList then
        table.clear(EntityList)
    else
        EntityList = {}
    end
    updateBlacklist()
    ents = Workspace:FindFirstChild("game_assets") and Workspace.game_assets:FindFirstChild("Entities")
    if not ents then return end
    local children = getChildrenCached(ents, tempChildren)
    for _, m in ipairs(children) do
        if m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") and m:FindFirstChild("Head") and not m:FindFirstChild("Humanoid") and not isBlacklisted(m) then
            EntityList[#EntityList+1] = {
                Player = nil,
                RootPart = m.HumanoidRootPart,
                WorldModel = m
            }
        end
    end
end

gundata = game:GetService("ReplicatedStorage").GunSystemAssets.GunData
sv_config = game:GetService("ReplicatedStorage").CustomCharacterConfigs.Configuration.Server

local _IsDescendantOf = game.IsDescendantOf
local _FindFirstChild = game.FindFirstChild
local _FindFirstChildOfClass = game.FindFirstChildOfClass
local _Raycast = Workspace.Raycast
local _IsKeyDown = UserInputService.IsKeyDown
local _WorldToViewportPoint = Camera.WorldToViewportPoint
local _Vector3zeromin = Vector3.zero.Min
local _Vector2zeromin = Vector2.zero.Min
local _Vector3zeromax = Vector3.zero.Max
local _Vector2zeromax = Vector2.zero.Max
local _IsA = game.IsA

if not debug.isvalidlevel then
    setreadonly(debug, false)
    debug.isvalidlevel = LPH_NO_VIRTUALIZE(function(s)
        local success = pcall(function()
            return debug.getinfo(s + 3)
        end)
        return success
    end)
    setreadonly(debug, true)
end

local function printTable(tbl, maxDepth)
    maxDepth = maxDepth or 20
    local seen = {}
    local function recur(t, depth, indent)
        if depth > maxDepth then return end
        if seen[t] then return end
        seen[t] = true
        for k, v in pairs(t) do
            if type(v) == 'table' then
                recur(v, depth + 1, indent .. '    ')
            end
        end
    end
    if type(tbl) ~= 'table' then return end
    recur(tbl, 1, '    ')
end

local entitylist
for _, gc in ipairs(getgc(true)) do
    if type(gc) == "table" then
        local gpfwc = rawget(gc, "GetPlayerFromWorldCharacter")
        if gpfwc and type(gpfwc) == "function" then
            local upvs = getupvalues(gpfwc)
            local GetCharacters = upvs[2].GetCharacters
            entitylist = getupvalues(GetCharacters)[1]
            break
        end
    end
end

local function get_closest_target(fov_size, aimpart, team_check)
    local target_part, target_player, target_root
    local closest_distance = fov_size
    local mouse_pos = UserInputService:GetMouseLocation()
    
    for userid, v in entitylist do
        local player = v.Player
        if not (player and player ~= LocalPlayer) then continue end
        
        local root = v.RootPart
        local worldmodel = v.WorldModel
        local character = v.Character
        
        if not (root and worldmodel and character) then continue end
        
        if type(player) == "table" then
            player = { 
                Name = character.Name .. " (bot)", 
                DisplayName = character.Name .. " (bot)" 
            }
        end
        
        local part = worldmodel:FindFirstChild(aimpart)
        if not part then continue end
        
        local position, onscreen = _WorldToViewportPoint(Camera, part.Position)
        if not onscreen then continue end
        
        local distance = (Vector2.new(position.X, position.Y) - mouse_pos).Magnitude
        
        if distance <= closest_distance then
            closest_distance = distance
            target_part = part
            target_player = player
            target_root = root
        end
    end
    
    return target_part, target_player, target_root
end

local function full_prediction_silent(target_position, target_collider)
    if not target_position then return end
    
    local currentgun = get_current_gun(LocalPlayer)
    local gun = _FindFirstChild(gundata, currentgun)
    local stats = gun and _FindFirstChild(gun, "Stats")
    local bullet_settings = stats and _FindFirstChild(stats, "BulletSettings")
    local proj_speed, proj_drop
    
    if bullet_settings then
        local bullet_speed = _FindFirstChild(bullet_settings, "BulletSpeed")
        local bullet_gravity = _FindFirstChild(bullet_settings, "BulletGravity")
        proj_speed = tonumber(bullet_speed and bullet_speed.Value) or tonumber(sv_config.sv_default_bullet_speed.Value) or 1500
        proj_drop = tonumber(bullet_gravity and bullet_gravity.Value) or tonumber(sv_config.sv_default_bullet_gravity.Value) or 0
    else
        proj_speed = tonumber(sv_config.sv_default_bullet_speed.Value) or 1500
        proj_drop = tonumber(sv_config.sv_default_bullet_gravity.Value) or 0
    end
    
    local campos = Camera.CFrame.Position
    local velocity = (target_collider and target_collider.AssemblyLinearVelocity) or Vector3.zero
    
    if flags.ResolveY then
        velocity = Vector3.new(velocity.X, 0, velocity.Z)
    end
    if flags.InstantBullet then
        velocity = Vector3.zero
    end
    
    if prediction_mode == "organic v3" then
        return predict_axal(campos, target_position, velocity, proj_speed, proj_drop)
    elseif prediction_mode == "organic v2" then
        return predict_priv9(campos, target_position, velocity, proj_speed, proj_drop)
    elseif prediction_mode == "organic v1" then
        return predict_organic(campos, target_position, velocity, proj_speed, proj_drop)
    elseif prediction_mode == "organic v4" then
        return predict_intercept(campos, target_position, velocity, proj_speed, proj_drop)
    elseif prediction_mode == "organic v5" then
        return predict_extrapolate(campos, target_position, velocity, proj_speed, proj_drop)
    end
    return predict_organic(campos, target_position, velocity, proj_speed, proj_drop)
end

local aimbotTarget = nil
local cameraSmoothFactor = 0

local function moveMouseToTarget()
    if not flags.AimbotEnabled then return end
    if not aimbotTarget then return end
    
    local targetPos = aimbotTarget
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
    if not onScreen then return end
    
    local mousePos = UserInputService:GetMouseLocation()
    local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
    local delta = targetScreenPos - mousePos
    local distance = delta.Magnitude
    
    if distance < 1 then return end
    
    local smoothing = flags.Smoothing or 5
    local moveDelta = delta / smoothing
    mousemoverel(moveDelta.X, moveDelta.Y)
end

local function getAimbotTarget()
    local part, player, collider = get_closest_target(
        flags.FovSize,
        flags.AimPart,
        flags.TeamCheck
    )
    return part, collider
end

local function isKeybindPressed()
    return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
end

local showSnapline = false
local snaplineThickness = 1
local snaplineColor = Color3.fromRGB(255, 255, 255)

local targetHead = nil

local CustomMeshCharacter = require(game:GetService("ReplicatedFirst"):WaitForChild("GunSystemPlugins"):WaitForChild("CustomMeshCharacter"))

local function worldToScreen(pos)
    local pt, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(pt.X, pt.Y), onScreen
end

local function getClosestTargetForSnapline(center)
    local targetHead, minDist = nil, math.huge
    for _, Data in CustomMeshCharacter:GetCharacters() do
        local Player = Data.Player
        if Player == LocalPlayer or Player:GetAttribute("Dead") then continue end
        local AimPart = Data.WorldModel:FindFirstChild("Head")
        if not AimPart then continue end
        local pos2d, onScreen = worldToScreen(AimPart.Position)
        if not onScreen then continue end
        local dist = (pos2d - center).Magnitude
        if dist < minDist then
            minDist = dist
            targetHead = AimPart
        end
    end
    return targetHead
end

local function updateSnapline()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    if flags.SilentEnabled then
        local part, player, collider = get_closest_target(
            flags.FovSize,
            flags.AimPart,
            flags.TeamCheck
        )
        if part then
            targetHead = part
        end
    end
    
    if snapline then
        snapline.Visible = false
    end
    if snaplineOutline then
        snaplineOutline.Visible = false
    end
    
    if showSnapline and targetHead then
        local pos2d, onScreen = Camera:WorldToViewportPoint(targetHead.Position)
        if onScreen then
            local targetPos = Vector2.new(pos2d.X, pos2d.Y)
            
            local mousePos = UserInputService:GetMouseLocation()
            local fovCenter
            if flags.FovPosition == "Center Screen" then
                fovCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            else
                fovCenter = mousePos
            end
            
            local distanceFromFovCenter = (targetPos - fovCenter).Magnitude
            local isInFov = distanceFromFovCenter <= flags.FovSize
            
            if isInFov then
                snaplineOutline.From = center
                snaplineOutline.To = targetPos
                snaplineOutline.Visible = true
                
                snapline.From = center
                snapline.To = targetPos
                snapline.Color = snaplineColor
                snapline.Visible = true
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    updateFovCircle()
    updateSnapline()
    
    if flags.AimbotEnabled and isKeybindPressed() then
        local part, collider = getAimbotTarget()
        if part and collider then
            local pred = full_prediction_silent(part.Position, collider)
            if pred then
                aimbotTarget = pred
            else
                aimbotTarget = part.Position
            end
        else
            aimbotTarget = nil
        end
    else
        aimbotTarget = nil
    end
end)

RunService.Heartbeat:Connect(function()
    if flags.AimbotEnabled and isKeybindPressed() and aimbotTarget then
        pcall(moveMouseToTarget)
    end
end)

local old
old = hookfunction(buffer.create, newcclosure(function(size, ...)
    if size ~= 300 then
        return old(size, ...)
    end
    
    local args = {...}
    local Route = args[1]
    local Payload = args[2]
    
    if not debug.traceback():find("GunController") then
        return old(size, ...)
    end
    
    local stack = debug.getstack(3, 1)
    if type(stack) ~= "table" then
        return old(size, ...)
    end
    
    if type(stack[3]) == "table" and stack[3].Resimulation ~= nil then
        return old(size, ...)
    end
    
    local cam = workspace.CurrentCamera
    local pitch, yaw, roll = cam.CFrame:ToEulerAnglesYXZ()
    local pred
    local part, player, collider = get_closest_target(
        flags.FovSize,
        flags.AimPart,
        flags.TeamCheck
    )
    
    if part and flags.SilentEnabled then
        local targetPos = part.Position
        local predictedPos = full_prediction_silent(targetPos, collider)
        
        if predictedPos then
            local screen_pos, on_screen = Camera:WorldToViewportPoint(predictedPos)
            local mouse_pos = UserInputService:GetMouseLocation()
            local dist_to_mouse = (Vector2.new(screen_pos.X, screen_pos.Y) - mouse_pos).Magnitude
            
            if dist_to_mouse <= flags.FovSize then
                pred = predictedPos
            else
                pred = nil
            end
        else
            local screen_pos, on_screen = Camera:WorldToViewportPoint(targetPos)
            local mouse_pos = UserInputService:GetMouseLocation()
            local dist_to_mouse = (Vector2.new(screen_pos.X, screen_pos.Y) - mouse_pos).Magnitude
            
            if dist_to_mouse <= flags.FovSize then
                pred = targetPos
            else
                pred = nil
            end
        end
    end
    
    local ld
    if pred and flags.SilentEnabled then
        ld = CFrame.lookAt(
            cam.CFrame.Position,
            pred
        )
    else
        ld = cam.CFrame.LookVector
    end
    
    local spread = Vector3.zero
    if flags.NoSpread then
        local rng = Random.new(stack[48] + 1)
        spread = Vector3.new(
            rng:NextNumber() - rng:NextNumber(),
            rng:NextNumber() - rng:NextNumber(),
            rng:NextNumber() - rng:NextNumber()
        ) / stack[22]
    end
    
    if typeof(ld) == "Vector3" then
        ld = (ld - spread).Unit
    else
        ld = (ld.LookVector - spread).Unit
    end
    
    local cf = CFrame.lookAt(Vector3.zero, ld)
    local pitch2, yaw2, roll2 = cf:ToEulerAnglesYXZ()
    local dir = cf.LookVector
    local r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
    
    stack[32] = cf
    stack[33] = dir
    stack[34] = dir
    stack[36] = pitch2
    stack[37] = yaw2
    stack[38] = CFrame.new(0, 0, 0, r00, r01, r02, r10, r11, r12, r20, r21, r22)
    stack[39] = CFrame.new(0, 0, 0, r00, r01, r02, r10, r11, r12, r20, r21, r22)
    stack[44] = CFrame.new(0, 0, 0, r00, r01, r02, r10, r11, r12, r20, r21, r22)
    stack[45] = dir
    stack[46] = dir
    
    return old(size, ...)
end))

Sections.SilentAimbot:Toggle({
    Name = "Team Check",
    Flag = "TeamCheck",
    Default = true,
    Callback = function(State)
        flags.TeamCheck = State
    end
})


local silent = Sections.SilentAimbot:Toggle({
    Name = "Silent Aim",
    Flag = "SilentEnabled",
    Default = false,
    Callback = function(State)
        flags.SilentEnabled = State
        if flags.ShowFov and flags.SilentEnabled then
            outlineCircle.Visible = true
            mainCircle.Visible = true
        else
            outlineCircle.Visible = false
            mainCircle.Visible = false
        end
    end
})

silent:Keybind({
    Name = "Silent Keybind",
    Flag = "SilentKeybind",
    Default = Enum.KeyCode.P,
    Mode = "Toggle",
    Callback = function(State)
        flags.SilentEnabled = State
        if flags.ShowFov and flags.SilentEnabled then
            outlineCircle.Visible = true
            mainCircle.Visible = true
        else
            outlineCircle.Visible = false
            mainCircle.Visible = false
        end
    end
})

Sections.SilentAimbot:Dropdown({
    Name = "Prediction Type",
    Flag = "PredictionMode",
    Options = {
        "organic v1", 
        "organic v2", 
        "organic v3", 
        "organic v4", 
        "organic v5"
    },
    Default = "organic v1",
    Callback = function(Value)
        prediction_mode = Value
    end
})

Sections.SilentAimbot:Dropdown({
    Name = "Target Part",
    Flag = "AimPart",
    Options = {"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "RightLowerArm", "RightLowerLeg", "LeftLowerLeg"},
    Default = "Head",
    Callback = function(Value)
        flags.AimPart = Value
    end
})

local fovs = Sections.SilentAimbot:Toggle({
    Name = "Show FOV",
    Flag = "ShowFov",
    Default = false,
    Callback = function(State)
        flags.ShowFov = State
        if flags.ShowFov and flags.SilentEnabled then
            outlineCircle.Visible = true
            mainCircle.Visible = true
        else
            outlineCircle.Visible = false
            mainCircle.Visible = false
        end
    end
})

fovs:Colorpicker({
    Name = "FOV Color",
    Flag = "FovColor",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        flags.FovColor = Value
        if mainCircle then
            mainCircle.Color = Value
        end
    end
})

Sections.SilentAimbot:Dropdown({
    Name = "FOV Position",
    Flag = "FovPosition",
    Options = {"Center Screen", "Follow Mouse"},
    Default = "Follow Mouse",
    Callback = function(Value)
        flags.FovPosition = Value
    end
})

Sections.SilentAimbot:Slider({
    Name = "FOV Size",
    Flag = "FovSize",
    Min = 1,
    Max = 500,
    Default = 100,
	Suffix = "%",
    Callback = function(Value)
        flags.FovSize = Value
        if mainCircle then
            mainCircle.Radius = Value
        end
        if outlineCircle then
            outlineCircle.Radius = Value
        end
    end
})

local snap = Sections.SilentAimbot:Toggle({
    Name = "Show Snapline",
    Flag = "SnaplineEnabled",
    Default = false,
    Callback = function(State)
        showSnapline = State
    end
})

snap:Colorpicker({
    Name = "Snapline Color",
    Flag = "SnaplineColor",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        snaplineColor = Value
    end
})

Sections.SilentAimbot:Slider({
    Name = "Snapline Thickness",
    Flag = "SnaplineThickness",
    Min = 1,
    Max = 5,
	Suffix = "%",
    Default = 1,
    Callback = function(Value)
        snaplineThickness = Value
    end
})
end

--hitsound

hitsoundEnabled = false
headshotSoundEnabled = false
currentHitsound = 'rbxassetid://8726881116'
currentHeadshotSound = 'rbxassetid://988593556'

hitsoundNames = {
    'Neverlose',
    'TF2',
    'Gamesense',
    'Rust',
    'Bubble',
    'Quake',
    'Among-Us',
    'Ding',
    'Minecraft',
    'Blackout',
    'Osu',
	'M1 Garand',
}
headshotSoundNames = {
    'Default',
    'TF2',
    'Gamesense',
    'Rust',
    'Bubble',
    'Quake',
    'Among-Us',
    'Ding',
    'Minecraft',
    'Blackout',
    'Osu',
	'M1 Garand',
}
hitsoundOptions = {
    ['Neverlose'] = 'rbxassetid://8726881116',
    ['TF2'] = 'rbxassetid://8255306220',
    ['Gamesense'] = 'rbxassetid://4817809188',
    ['Rust'] = 'rbxassetid://1255040462',
    ['Bubble'] = 'rbxassetid://198598793',
    ['Quake'] = 'rbxassetid://1455817260',
    ['Among-Us'] = 'rbxassetid://7227567562',
    ['Ding'] = 'rbxassetid://2868331684',
    ['Minecraft'] = 'rbxassetid://6361963422',
    ['Blackout'] = 'rbxassetid://3748776946',
    ['Osu'] = 'rbxassetid://7151989073',
	['M1 Garand'] = 'rbxassetid://6111738677',
}
headshotSoundOptions = {
    ['Default'] = 'rbxassetid://988593556',
    ['TF2'] = 'rbxassetid://8255306220',
    ['Gamesense'] = 'rbxassetid://4817809188',
    ['Rust'] = 'rbxassetid://1255040462',
    ['Bubble'] = 'rbxassetid://198598793',
    ['Quake'] = 'rbxassetid://1455817260',
    ['Among-Us'] = 'rbxassetid://7227567562',
    ['Ding'] = 'rbxassetid://2868331684',
    ['Minecraft'] = 'rbxassetid://6361963422',
    ['Blackout'] = 'rbxassetid://3748776946',
    ['Osu'] = 'rbxassetid://7151989073',
	['M1 Garand'] = 'rbxassetid://6111738677',
}

function applyHitsound()
    if not hitsoundEnabled then
        return
    end
    hitmarker = game:GetService("ReplicatedStorage").GunSystemAssets.Sounds.DefaultHitmarker.Hitmarker 
    if hitmarker then
        hitmarker.SoundId = currentHitsound
    end
end

function applyHeadshotSound()
    if not headshotSoundEnabled then
        return
    end
    headshot = game:GetService("ReplicatedStorage").GunSystemAssets.Sounds.DefaultHitmarker.Headshot
    if headshot then
        headshot.SoundId = currentHeadshotSound
    end
end

Sections.HitSound:Toggle({
    Name = "Body Hitsounds",
    Default = false,
    Flag = "BodyHitsounds",
    Callback = function(State)
        hitsoundEnabled = State
        applyHitsound()
    end
})

Sections.HitSound:Dropdown({
    Name = "Hitsound",
    Flag = "HitsoundSelect",
    Options = hitsoundNames,
    Default = "Neverlose",
    Callback = function(Selected)
        currentHitsound = hitsoundOptions[Selected]
        applyHitsound()
    end
})

Sections.HitSound:Toggle({
    Name = "Headshot Sound",
    Default = false,
    Flag = "HeadshotSound",
    Callback = function(State)
        headshotSoundEnabled = State
        applyHeadshotSound()
    end
})

Sections.HitSound:Dropdown({
    Name = "Headshot Sound",
    Flag = "HeadshotSoundSelect",
    Options = headshotSoundNames,
    Default = "Default",
    Callback = function(Selected)
        currentHeadshotSound = headshotSoundOptions[Selected]
        applyHeadshotSound()
    end
})

task.spawn(function()
    while true do
        if hitsoundEnabled then
            applyHitsound()
        end
        if headshotSoundEnabled then
            applyHeadshotSound()
        end
        task.wait(1)
    end
end)


--fov

do
	local CameraFovController = require(game:GetService("ReplicatedFirst").GunSystem:WaitForChild("CameraFovController"))

local fovChangerEnabled = false
local fovValue = 90


Sections.Fov:Toggle({
    Name = "Field-Of-View Adjustment",
    Flag = "FovChangerEnabled",
    Default = false,
    Callback = function(State)
        fovChangerEnabled = State
        if not fovChangerEnabled then
            CameraFovController.ClientFov = 100
        end
    end
})

Sections.Fov:Slider({
    Name = "Adjustment Value",
    Flag = "FovValue",
    Min = 1,
    Max = 120,
    Default = 90,
    Decimals = 1,
    Callback = function(Value)
        fovValue = Value
        if fovChangerEnabled then
            CameraFovController.ClientFov = fovValue
            CameraFovController:Enable()
        end
    end
})
end	

do
    Players = Players or game:GetService("Players")
    ReplicatedStorage = game:GetService('ReplicatedStorage')
    Workspace = game:GetService('Workspace')
    RunService = game:GetService('RunService')
    CoreGui = game:GetService("CoreGui")

    Camera = Workspace.CurrentCamera
    LocalPlayer = Players.LocalPlayer

    local function getMiscFolder()
        local wa = Workspace:FindFirstChild('world_assets')
        if not wa then return nil end
        local static = wa:FindFirstChild('StaticObjects')
        if not static then return nil end
        return static:FindFirstChild('Misc')
    end

    local function getAmmoFolder()
        local assets = ReplicatedStorage:FindFirstChild('Assets')
        if not assets then return nil end
        local vms = assets:FindFirstChild('ViewModels')
        if not vms then return nil end
        local combat = vms:FindFirstChild('Combat')
        if not combat then return nil end
        return combat:FindFirstChild('Ammo')
    end

    ammoESP = ammoESP or {
        Enabled = false,
        ShowName = false,
        ShowDistance = false,
        Outline = true,
        Size = 14,
        Color = Color3.fromRGB(255, 255, 255),
        RenderDistance = 10000,
        Active = {},
        ScannedObjects = {},
        Font = Enum.Font.Code,
    }

    local ammoCache = {}

    local function extract_id(str)
        if type(str) ~= 'string' then return tostring(str) end
        local id = str:match('(%d+)')
        return id or str
    end

    local function buildAmmoCache()
        if next(ammoCache) then return end

        local ammoFolder = getAmmoFolder()
        if not ammoFolder then return end

        for _, ammo_model in ipairs(ammoFolder:GetChildren()) do
            if ammo_model:IsA('Model') and ammo_model.Name ~= 'Model' then
                local ammo_main = ammo_model:FindFirstChild('Main') or ammo_model:FindFirstChildWhichIsA('MeshPart', true)
                if ammo_main and ammo_main:IsA('MeshPart') then
                    local ammo_mesh_id = extract_id(ammo_main.MeshId)
                    local ammo_tex_id = extract_id(ammo_main.TextureID)
                    local signature = ammo_mesh_id .. ': ' .. (ammo_tex_id or '')
                    ammoCache[signature] = ammo_model.Name
                end
            end
        end
    end

    local function createAmmoBillboard(sourcePart, label)
        if ammoESP.Active[sourcePart] then return end
        
        local billboard = Instance.new('BillboardGui')
        billboard.Name = 'AmmoESP'
        billboard.Adornee = sourcePart
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.ResetOnSpawn = false
        billboard.Parent = sourcePart

        local labelText = Instance.new('TextLabel')
        labelText.Name = 'AmmoText'
        labelText.BackgroundTransparency = 1
        labelText.TextColor3 = ammoESP.Color
        labelText.TextSize = ammoESP.Size
        labelText.Font = ammoESP.Font
        labelText.Text = ''
        labelText.Size = UDim2.new(1, 0, 1, 0)
        labelText.TextWrapped = true
        labelText.TextStrokeColor3 = Color3.new(0, 0, 0)
        labelText.TextStrokeTransparency = 0
        labelText.Parent = billboard

        ammoESP.Active[sourcePart] = {
            billboard = billboard,
            label = labelText,
            ammoName = label,
            part = sourcePart
        }
        return billboard
    end

    local function scanAmmo()
        if not ammoESP.Enabled then return end
        local misc = getMiscFolder()
        if not misc then return end

        buildAmmoCache()
        if not next(ammoCache) then return end

        for _, misc_child in ipairs(misc:GetChildren()) do
            if misc_child:IsA('Model') and not ammoESP.ScannedObjects[misc_child] then
                ammoESP.ScannedObjects[misc_child] = true

                local source = misc_child:FindFirstChild('Main') or misc_child:FindFirstChildWhichIsA('MeshPart', true)
                if source and source:IsA('MeshPart') and not ammoESP.Active[source] then
                    local src_mesh_id = extract_id(source.MeshId)
                    local src_tex_id = extract_id(source.TextureID)
                    local signature = src_mesh_id .. ': ' .. (src_tex_id or '')

                    local ammoName = ammoCache[signature]
                    if ammoName then
                        createAmmoBillboard(source, ammoName)
                    end
                end
            end
        end
    end

    function updateAmmoESP()
        local origin = (LocalPlayer.Character and LocalPlayer.Character.PrimaryPart) and LocalPlayer.Character.PrimaryPart.Position or Camera.CFrame.Position
        
        for sourcePart, data in pairs(ammoESP.Active) do
            if not sourcePart or not sourcePart.Parent then
                pcall(function() 
                    if data.billboard then data.billboard:Destroy() end
                end)
                ammoESP.Active[sourcePart] = nil
            else
                local dist = (sourcePart.Position - origin).Magnitude
                local displayDist = dist / 2.56

                if not ammoESP.Enabled or dist > ammoESP.RenderDistance then
                    data.billboard.Enabled = false
                else
                    local labelText = data.label
                    labelText.TextColor3 = ammoESP.Color
                    labelText.TextSize = ammoESP.Size
                    labelText.Font = ammoESP.Font

                    local textStr = ''
                    if ammoESP.ShowName then
                        textStr = data.ammoName
                    end
                    if ammoESP.ShowDistance then
                        local dt = string.format('%.0fm', displayDist)
                        textStr = (textStr ~= '' and (textStr .. ' ' .. dt)) or dt
                    end

                    labelText.Text = textStr
                    
                    -- Apply fade out on distance
                    local transparency = math.max(0.1, 1 - (dist / ammoESP.RenderDistance))
                    labelText.TextStrokeTransparency = 1 - transparency
                    labelText.TextTransparency = 1 - transparency
                    
                    data.billboard.Enabled = (textStr ~= '')
                end
            end
        end
    end

    local ammoESPConnections = {}

    do
        local misc = getMiscFolder()
        if misc then
            table.insert(ammoESPConnections, misc.ChildAdded:Connect(function()
                task.spawn(function()
                    task.wait(0.1)
                    if ammoESP.Enabled then
                        task.defer(scanAmmo)
                    end
                end)
            end))
        end
    end
    local misc = getMiscFolder()
    table.insert(ammoESPConnections, misc.ChildRemoved:Connect(function(child)
        for part, data in pairs(ammoESP.Active) do
            if part:IsDescendantOf(child) then
                pcall(function() 
                    if data.billboard then data.billboard:Destroy() end
                end)
                ammoESP.Active[part] = nil
            end
        end
    end))
    local ammoScanInterval = 3.0
    local lastAmmoScan = 0

    table.insert(ammoESPConnections, RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if ammoESP.Enabled and (ammoESP.ShowName or ammoESP.ShowDistance) then
            updateAmmoESP()
            if now - lastAmmoScan >= ammoScanInterval then
                scanAmmo()
                lastAmmoScan = now
            end
        else
            for _, data in pairs(ammoESP.Active) do
                if data.billboard then
                    data.billboard.Enabled = false
                end
            end
        end
    end))

    local ammo = Sections.Ammo:Toggle({
        Name = "Ammo Name",
        Flag = "AmmoName",
        Default = false,
        Callback = function(State)
            ammoESP.ShowName = State
            ammoESP.Enabled = ammoESP.ShowName or ammoESP.ShowDistance
            if State then
                task.defer(scanAmmo)
            end
        end
    })

    ammo:Colorpicker({
        Name = "Ammo Color",
        Flag = "AmmoColor",
        Default = ammoESP.Color,
        Callback = function(Value)
            ammoESP.Color = Value
            for _, data in pairs(ammoESP.Active) do
                pcall(function() 
                    if data.label then data.label.TextColor3 = Value end
                end)
            end
        end
    })

    Sections.Ammo:Toggle({
        Name = "Ammo Distance",
        Flag = "AmmoDistance",
        Default = false,
        Callback = function(State)
            ammoESP.ShowDistance = State
            ammoESP.Enabled = ammoESP.ShowName or ammoESP.ShowDistance
            if State then
                task.defer(scanAmmo)
            end
        end
    })

    Sections.Ammo:Slider({
        Name = "Ammo ESP Distance",
        Flag = "AmmoESPDistance",
        Min = 50,
        Max = 10000,
        Default = ammoESP.RenderDistance,
		Suffix = "%",
        Decimals = 1,
        Callback = function(Value)
            ammoESP.RenderDistance = Value
        end
    })

    Sections.Ammo:Dropdown({
        Name = "Text Font",
        Flag = "AmmoFont",
        Options = {
            'Code',
            'Arial',
            'ArialBold',
            'Cartoon',
            'Fantasy',
            'Garamond',
            'Gotham',
            'GothamBold',
            'GothamMedium',
            'GothamSemibold',
            'Highway',
            'Legacy',
            'Roboto',
            'RobotoMono',
            'SourceSans',
            'SourceSansBold',
            'SourceSansItalic',
            'SourceSansSemibold',
        },
        Default = 'Code',
        Callback = function(value)
            local fontMap = {
                ['Code'] = Enum.Font.Code,
                ['Arial'] = Enum.Font.Arial,
                ['ArialBold'] = Enum.Font.ArialBold,
                ['Cartoon'] = Enum.Font.Cartoon,
                ['Fantasy'] = Enum.Font.Fantasy,
                ['Garamond'] = Enum.Font.Garamond,
                ['Gotham'] = Enum.Font.Gotham,
                ['GothamBold'] = Enum.Font.GothamBold,
                ['GothamMedium'] = Enum.Font.GothamMedium,
                ['GothamSemibold'] = Enum.Font.GothamSemibold,
                ['Highway'] = Enum.Font.Highway,
                ['Legacy'] = Enum.Font.Legacy,
                ['Roboto'] = Enum.Font.Roboto,
                ['RobotoMono'] = Enum.Font.RobotoMono,
                ['SourceSans'] = Enum.Font.SourceSans,
                ['SourceSansBold'] = Enum.Font.SourceSansBold,
                ['SourceSansItalic'] = Enum.Font.SourceSansItalic,
                ['SourceSansSemibold'] = Enum.Font.SourceSansSemibold,
            }
            
            local newFont = fontMap[value] or Enum.Font.Code
            ammoESP.Font = newFont
            
            for _, data in pairs(ammoESP.Active) do
                pcall(function() 
                    if data.label then data.label.Font = newFont end
                end)
            end
        end
    })

    -- Initial setup if enabled
    if ammoESP.Enabled then
        task.defer(scanAmmo)
    end
end


do
	Players = Players or game:GetService("Players")
	LocalPlayer = Players.LocalPlayer
	Camera = workspace.CurrentCamera
	RunService = game:GetService'RunService'
	CoreGui = game:GetService("CoreGui")
    local misc = workspace:WaitForChild'world_assets':WaitForChild'StaticObjects':WaitForChild'Misc'

    repKitESP = repKitESP or {
        Enabled = false,
        ShowDistance = false,
        Color = Color3.fromRGB(255, 255, 255),
        Size = 14,
        RenderDistance = 10000,
        Active = {},
        Font = Enum.Font.Code,
    }
    local meshId = 'rbxassetid://10058182223'

    local function createRepKitBillboard(part)
        if repKitESP.Active[part] then return end
        
        local billboard = Instance.new('BillboardGui')
        billboard.Name = 'RepKitESP'
        billboard.Adornee = part
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.ResetOnSpawn = false
        billboard.Parent = part

        local label = Instance.new('TextLabel')
        label.Name = 'RepKitText'
        label.BackgroundTransparency = 1
        label.TextColor3 = repKitESP.Color
        label.TextSize = repKitESP.Size
        label.Font = repKitESP.Font
        label.Text = ''
        label.Size = UDim2.new(1, 0, 1, 0)
        label.TextWrapped = true
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextStrokeTransparency = 0
        label.Parent = billboard

        repKitESP.Active[part] = {
            billboard = billboard,
            label = label,
            part = part
        }
        return billboard
    end

    local function scan()
        if not repKitESP.Enabled then return end
        for _, m in ipairs(misc:GetDescendants()) do
            if m.Name == 'Main' and m:IsA'MeshPart' and m.MeshId == meshId and not repKitESP.Active[m] then
                createRepKitBillboard(m)
            end
        end
    end

    local function update()
        if not repKitESP.Enabled then
            for _, d in pairs(repKitESP.Active) do 
                if d.billboard then d.billboard.Enabled = false end
            end
            return
        end
        local origin = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character.PrimaryPart.Position or Camera.CFrame.Position
        for part, data in pairs(repKitESP.Active) do
            if part.Parent then
                local dist = (part.Position - origin).Magnitude
                if dist <= repKitESP.RenderDistance then
                    local txt = 'Weapon Repair Kit'
                    if repKitESP.ShowDistance then
                        txt = txt .. string.format(' %.0fm', dist/2.56)
                    end
                    data.label.Text = txt
                    data.label.Font = repKitESP.Font
                    data.label.TextColor3 = repKitESP.Color
                    data.label.TextSize = repKitESP.Size
                    
                    -- Apply fade out on distance
                    local transparency = math.max(0.1, 1 - (dist / repKitESP.RenderDistance))
                    data.label.TextStrokeTransparency = 1 - transparency
                    data.label.TextTransparency = 1 - transparency
                    
                    data.billboard.Enabled = true
                else
                    data.billboard.Enabled = false
                end
            else 
                pcall(function() 
                    if data.billboard then data.billboard:Destroy() end
                end)
                repKitESP.Active[part] = nil 
            end
        end
    end

    misc.ChildAdded:Connect(function() scan() end)

    misc.ChildRemoved:Connect(function(child)
        for part, data in pairs(repKitESP.Active) do
            if part:IsDescendantOf(child) then
                pcall(function() 
                    if data.billboard then data.billboard:Destroy() end
                end)
                repKitESP.Active[part] = nil
            end
        end
    end)

    RunService.Heartbeat:Connect(update)

    local rep = Sections.Repair:Toggle({
        Name = "Weapon Repair Kit",
        Flag = "RepKitESP",
        Default = false,
        Callback = function(State)
            repKitESP.Enabled = State
            if State then
                scan() 
            else 
                for _, d in pairs(repKitESP.Active) do 
                    pcall(function() 
                        if d.billboard then d.billboard:Destroy() end
                    end)
                end
                repKitESP.Active = {}
            end
        end
    })

    rep:Colorpicker({
        Name = "Rep Kit Color",
        Flag = "RepKitColor",
        Default = repKitESP.Color,
        Callback = function(Value)
            repKitESP.Color = Value
            for _, d in pairs(repKitESP.Active) do 
                if d.label then d.label.TextColor3 = Value end
            end
        end
    })

    Sections.Repair:Toggle({
        Name = "Weapon Repair Kit Distance",
        Flag = "RepKitDist",
        Default = false,
        Callback = function(State)
            repKitESP.ShowDistance = State
        end
    })

    Sections.Repair:Slider({
        Name = "Max Distance",
        Flag = "RepKitRange",
        Min = 50,
        Max = 10000,
        Default = 10000,
		Suffix = "%",
        Decimals = 1,
        Callback = function(Value)
            repKitESP.RenderDistance = Value
        end
    })

    Sections.Repair:Dropdown({
        Name = "Text Font",
        Flag = "RepKitFont",
        Options = {
            'Code',
            'Arial',
            'ArialBold',
            'Cartoon',
            'Fantasy',
            'Garamond',
            'Gotham',
            'GothamBold',
            'GothamMedium',
            'GothamSemibold',
            'Highway',
            'Legacy',
            'Roboto',
            'RobotoMono',
            'SourceSans',
            'SourceSansBold',
            'SourceSansItalic',
            'SourceSansSemibold',
        },
        Default = 'Code',
        Callback = function(value)
            local fontMap = {
                ['Code'] = Enum.Font.Code,
                ['Arial'] = Enum.Font.Arial,
                ['ArialBold'] = Enum.Font.ArialBold,
                ['Cartoon'] = Enum.Font.Cartoon,
                ['Fantasy'] = Enum.Font.Fantasy,
                ['Garamond'] = Enum.Font.Garamond,
                ['Gotham'] = Enum.Font.Gotham,
                ['GothamBold'] = Enum.Font.GothamBold,
                ['GothamMedium'] = Enum.Font.GothamMedium,
                ['GothamSemibold'] = Enum.Font.GothamSemibold,
                ['Highway'] = Enum.Font.Highway,
                ['Legacy'] = Enum.Font.Legacy,
                ['Roboto'] = Enum.Font.Roboto,
                ['RobotoMono'] = Enum.Font.RobotoMono,
                ['SourceSans'] = Enum.Font.SourceSans,
                ['SourceSansBold'] = Enum.Font.SourceSansBold,
                ['SourceSansItalic'] = Enum.Font.SourceSansItalic,
                ['SourceSansSemibold'] = Enum.Font.SourceSansSemibold,
            }
            
            local newFont = fontMap[value] or Enum.Font.Code
            repKitESP.Font = newFont
            
            for _, data in pairs(repKitESP.Active) do
                pcall(function() 
                    if data.label then data.label.Font = newFont end
                end)
            end
        end
    })

    -- Initial setup if enabled
    if repKitESP.Enabled then
        task.defer(scan)
    end
end

do
    local miscFolder      = workspace.world_assets.StaticObjects.Misc
    local gunDataFolder   = game:GetService("ReplicatedStorage").GunSystemAssets.GunData
    local RunService      = game:GetService("RunService")
    local Players         = game:GetService("Players")
    local camera          = workspace.CurrentCamera
    local LocalPlayer     = Players.LocalPlayer

    local meleeBlacklist = {
        AxeFire = true, ChemLight = true, Cleaver = true, CombatKnife = true,
        Crowbar = true, HandSaw = true, Shovel = true, KitchenKnife = true,
        GrenadeSmokeMakeshift = true, GrenadeSmoke = true, AxeMakeshift = true,
        Cuffs = true, Fists = true, GenericItemThrow = true, Generic_consumable = true,
        GrenadeFrag = true, GrenadeGas = true, GrenadeMolotov = true,
        GrenadePipebomb = true, Snowball = true, ThrowableBottle = true,
        Wrench = true, SteakKnife = true,
    }

    weaponESP = weaponESP or {
        Enabled = false,
        Size = 16,
        Color = Color3.fromRGB(255, 255, 255),
        ExcludeMelee = true,
        ShowDistance = true,
        RenderRange = 10000,
        Font = 'Code',
        Active = {},
    }

    local function createWeaponBillboard(model, gunName)
        if weaponESP.Active[model] then return weaponESP.Active[model] end
        
        local handle = model:FindFirstChild("Handle")
        if not (handle and handle:IsA("BasePart")) then return end
        
        local billboard = Instance.new('BillboardGui')
        billboard.Name = 'WeaponESP'
        billboard.Adornee = handle
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.ResetOnSpawn = false
        billboard.Parent = model

        local label = Instance.new('TextLabel')
        label.Name = 'WeaponText'
        label.BackgroundTransparency = 1
        label.TextColor3 = weaponESP.Color
        label.TextSize = weaponESP.Size
        label.Font = Enum.Font[weaponESP.Font] or Enum.Font.Code
        label.Text = ''
        label.Size = UDim2.new(1, 0, 1, 0)
        label.TextWrapped = true
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextStrokeTransparency = 0
        label.Parent = billboard

        local data = {
            billboard = billboard,
            label = label,
            model = model,
            name = gunName,
            handle = handle
        }
        weaponESP.Active[model] = data
        return data
    end

    local function getMeshPartsInfo(model)
        local info = {}
        for _, child in ipairs(model:GetChildren()) do
            if child:IsA("MeshPart") then
                local cNames = {}
                for _, c in ipairs(child:GetChildren()) do
                    table.insert(cNames, c.Name)
                end
                table.sort(cNames)
                table.insert(info, { Name = child.Name, MeshId = child.MeshId, ChildrenNames = cNames })
            end
        end
        table.sort(info, function(a,b) return a.Name < b.Name end)
        return info
    end

    local function meshPartsMatch(a, b)
        if #a ~= #b then return false end
        for i = 1, #a do
            if a[i].Name ~= b[i].Name or a[i].MeshId ~= b[i].MeshId then
                return false
            end
            local c1, c2 = a[i].ChildrenNames, b[i].ChildrenNames
            if #c1 ~= #c2 then return false end
            for j = 1, #c1 do
                if c1[j] ~= c2[j] then return false end
            end
        end
        return true
    end

    local function getChildrenNames(model)
        local names = {}
        for _, c in ipairs(model:GetChildren()) do
            table.insert(names, c.Name)
        end
        table.sort(names)
        return names
    end

    local function childrenNamesMatch(a, b)
        if #a ~= #b then return false end
        for i = 1, #a do
            if a[i] ~= b[i] then return false end
        end
        return true
    end

    local function getDescendantsNames(model)
        local names = {}
        for _, d in ipairs(model:GetDescendants()) do
            table.insert(names, d.Name)
        end
        table.sort(names)
        return names
    end

    local function descendantsNamesMatch(a, b)
        if #a ~= #b then return false end
        for i = 1, #a do
            if a[i] ~= b[i] then return false end
        end
        return true
    end

    local gunDataMeshInfos = {}
    for _, folder in ipairs(gunDataFolder:GetChildren()) do
        local wm = folder:FindFirstChild("WorldModel")
        if wm then
            gunDataMeshInfos[folder.Name] = getMeshPartsInfo(wm)
        end
    end

    local function checkModelAgainstGunData(model)
        if not model:IsA("Model") then return nil end
        local meshInfo = getMeshPartsInfo(model)
        if #meshInfo > 0 then
            for name, refInfo in pairs(gunDataMeshInfos) do
                if meshPartsMatch(meshInfo, refInfo) then
                    return name
                end
            end
        else
            local childNames = getChildrenNames(model)
            local candidates = {}
            for name, _ in pairs(gunDataMeshInfos) do
                local gd = gunDataFolder:FindFirstChild(name)
                if gd and gd:FindFirstChild("WorldModel") then
                    if childrenNamesMatch(childNames, getChildrenNames(gd.WorldModel)) then
                        table.insert(candidates, name)
                    end
                end
            end
            if #candidates == 1 then
                return candidates[1]
            elseif #candidates > 1 then
                local descNames = getDescendantsNames(model)
                for _, name in ipairs(candidates) do
                    if descendantsNamesMatch(descNames, getDescendantsNames(gunDataFolder[name].WorldModel)) then
                        return name
                    end
                end
            end
        end
        return nil
    end

    local function checkAndCreateESPForModel(model)
        local gunName = checkModelAgainstGunData(model)
        if gunName then
            if weaponESP.ExcludeMelee and meleeBlacklist[gunName] then return end
            createWeaponBillboard(model, gunName)
        end
    end

    local function updateWeaponESP()
        local origin = (LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character.PrimaryPart.Position) or Camera.CFrame.Position
        
        for model, data in pairs(weaponESP.Active) do
            if not data.handle or not data.handle.Parent or not model.Parent then
                if data.billboard then
                    pcall(function() data.billboard:Destroy() end)
                end
                weaponESP.Active[model] = nil
            else
                local dist = (data.handle.Position - origin).Magnitude
                
                if weaponESP.Enabled and dist <= weaponESP.RenderRange then
                    local text = data.name
                    if weaponESP.ShowDistance then
                        text = string.format("%s %dm", data.name, math.floor(dist))
                    end
                    
                    data.label.Text = text
                    data.label.TextColor3 = weaponESP.Color
                    data.label.TextSize = weaponESP.Size
                    data.label.Font = Enum.Font[weaponESP.Font] or Enum.Font.Code
                    
                    -- Apply fade out on distance
                    local transparency = math.max(0.1, 1 - (dist / weaponESP.RenderRange))
                    data.label.TextStrokeTransparency = 1 - transparency
                    data.label.TextTransparency = 1 - transparency
                    
                    data.billboard.Enabled = true
                else
                    data.billboard.Enabled = false
                end
            end
        end
    end

    local function initialScan()
        for _, model in ipairs(miscFolder:GetChildren()) do
            checkAndCreateESPForModel(model)
        end
    end

    -- Connections
    miscFolder.ChildAdded:Connect(function(newModel)
        task.wait(0.1)
        checkAndCreateESPForModel(newModel)
    end)

    local updateConn = RunService.Heartbeat:Connect(updateWeaponESP)

    local weapon = Sections.Weapons:Toggle({
        Name = "Weapon",
        Flag = "WeaponESP",
        Default = weaponESP.Enabled,
        Callback = function(State)
            weaponESP.Enabled = State
            if State then
                task.defer(initialScan)
            else
                for _, data in pairs(weaponESP.Active) do 
                    if data.billboard then 
                        pcall(function() data.billboard.Enabled = false end)
                    end
                end
            end
        end
    })

    weapon:Colorpicker({
        Name = "Weapon Color",
        Flag = "WeaponColor",
        Default = weaponESP.Color,
        Callback = function(Value)
            weaponESP.Color = Value
            for _, data in pairs(weaponESP.Active) do
                pcall(function() 
                    if data.label then data.label.TextColor3 = Value end
                end)
            end
        end
    })

    Sections.Weapons:Dropdown({
        Name = "Text Font",
        Flag = "WeaponFont",
        Options = {
            'Code',
            'Arial',
            'ArialBold',
            'Cartoon',
            'Fantasy',
            'Garamond',
            'Gotham',
            'GothamBold',
            'GothamMedium',
            'GothamSemibold',
            'Highway',
            'Legacy',
            'Roboto',
            'RobotoMono',
            'SourceSans',
            'SourceSansBold',
            'SourceSansItalic',
            'SourceSansSemibold',
        },
        Default = 'Code',
        Callback = function(value)
            weaponESP.Font = value
            for _, data in pairs(weaponESP.Active) do
                pcall(function() 
                    if data.label then 
                        data.label.Font = Enum.Font[value] or Enum.Font.Code
                    end
                end)
            end
        end
    })

    Sections.Weapons:Slider({
        Name = "Max Distance",
        Flag = "WeaponRenderDistance",
        Min = 0,
        Max = 1000,
        Default = weaponESP.RenderRange,
		Suffix = "%",
		Decimals = 1,
        Callback = function(Value)
            weaponESP.RenderRange = Value
        end
    })

    if weaponESP.Enabled then
        task.defer(initialScan)
    end
end

do
    Players = Players or game:GetService("Players")
    LocalPlayer = Players.LocalPlayer
    Camera = workspace.CurrentCamera
    RunService = game:GetService('RunService')
    CoreGui = game:GetService("CoreGui")

    vehicleESP = vehicleESP or {
        Enabled = false,    
        ShowName = false,    
        ShowDistance = false,    
        ShowHealth = false,    
        Color = Color3.fromRGB(255, 255, 255),    
        Size = 14,    
        RenderDistance = 10000,    
        Active = {},    
        WorldModelCache = setmetatable({}, {__mode = "v"}),
        Font = Enum.Font.Code,
    }

    local function createVehicleBillboard(chassis)
        if vehicleESP.Active[chassis] then return vehicleESP.Active[chassis] end
        
        local billboard = Instance.new('BillboardGui')
        billboard.Name = 'VehicleESP'
        billboard.Adornee = chassis
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.ResetOnSpawn = false
        billboard.Parent = chassis

        local label = Instance.new('TextLabel')
        label.Name = 'VehicleText'
        label.BackgroundTransparency = 1
        label.TextColor3 = vehicleESP.Color
        label.TextSize = vehicleESP.Size
        label.Font = vehicleESP.Font
        label.Text = ''
        label.Size = UDim2.new(1, 0, 1, 0)
        label.TextWrapped = true
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextStrokeTransparency = 0
        label.Parent = billboard

        local data = {
            billboard = billboard,
            label = label,
            chassis = chassis,
        }
        vehicleESP.Active[chassis] = data
        return data
    end

    local function getVehicleHealth(chassis)
        local chassisParent = chassis.Parent
        if not chassisParent then
            return nil
        end

        local x, y, z = math.floor(chassis.Position.X), math.floor(chassis.Position.Y), math.floor(chassis.Position.Z)
        local vehicleKey = string.format('vehicle_%d_%d_%d', x, y, z)

        if vehicleESP.WorldModelCache[vehicleKey] then
            local cachedWorldModel = vehicleESP.WorldModelCache[vehicleKey]
            if cachedWorldModel and cachedWorldModel.Parent then
                local states = cachedWorldModel:FindFirstChild('States')
                if states then
                    local health = states:GetAttribute('Health')
                    if health and health > 0 then
                        return health
                    end
                end
            else
                vehicleESP.WorldModelCache[vehicleKey] = nil
            end
        end

        local closestWorldModel = nil
        local closestDistance = math.huge

        for _, obj in pairs(workspace:GetChildren()) do
            if obj.Name == 'WorldModel' and obj:IsA('Model') then
                local states = obj:FindFirstChild('States')
                if states then
                    local health = states:GetAttribute('Health')
                    if health and health > 0 then
                        local worldModelCenter = obj:GetBoundingBox()
                        if worldModelCenter then
                            local distance = (worldModelCenter.Position - chassis.Position).Magnitude
                            if distance < closestDistance and distance < 150 then
                                closestDistance = distance
                                closestWorldModel = obj
                            end
                        end
                    end
                end
            end
        end

        if closestWorldModel then
            vehicleESP.WorldModelCache[vehicleKey] = closestWorldModel
            local states = closestWorldModel:FindFirstChild('States')
            if states then
                local health = states:GetAttribute('Health')
                if health and health > 0 then
                    return health
                end
            end
        end

        return nil
    end

    local function scanVehicles()
        if not vehicleESP.Enabled then return end
        
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:FindFirstChild('Chassis') and obj.Chassis:IsA('BasePart') and not vehicleESP.Active[obj.Chassis] then
                createVehicleBillboard(obj.Chassis)
            end
        end
    end

    local function updateVehicleESP()
        local origin = (LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character.PrimaryPart.Position) or Camera.CFrame.Position
        
        for chassis, data in pairs(vehicleESP.Active) do
            if not chassis or not chassis.Parent then
                if data then
                    pcall(function() 
                        if data.billboard then data.billboard:Destroy() end
                    end)
                end
                vehicleESP.Active[chassis] = nil
            else
                local dist = (chassis.Position - origin).Magnitude
                local displayDist = dist / 2.56

                if vehicleESP.Enabled and dist <= vehicleESP.RenderDistance then
                    local text = ''
                    if vehicleESP.ShowName or vehicleESP.ShowDistance then
                        if vehicleESP.ShowName then
                            text = 'Vehicle'
                        end
                        if vehicleESP.ShowDistance then
                            local distText = string.format('%.0fm', displayDist)
                            text = (text ~= '' and (text .. ' ' .. distText)) or distText
                        end
                    end

                    if vehicleESP.ShowHealth then
                        local health = getVehicleHealth(chassis)
                        local healthText
                        if health then
                            healthText = string.format('HP: %.0f', health)
                        else
                            healthText = 'No HP'
                        end
                        text = text .. (text ~= '' and '\n' .. healthText or healthText)
                    end

                    if text ~= '' then
                        data.label.Text = text
                        data.label.TextColor3 = (string.find(text, 'No HP') and Color3.fromRGB(255, 0, 0)) or vehicleESP.Color
                        data.label.TextSize = vehicleESP.Size
                        data.label.Font = vehicleESP.Font
                        
                        -- Apply fade out on distance
                        local transparency = math.max(0.1, 1 - (dist / vehicleESP.RenderDistance))
                        data.label.TextStrokeTransparency = 1 - transparency
                        data.label.TextTransparency = 1 - transparency
                        
                        data.billboard.Enabled = true
                    else
                        data.billboard.Enabled = false
                    end
                else
                    data.billboard.Enabled = false
                end
            end
        end
    end

    local function cleanupVehicleCache()
        local toRemove = {}
        for key, worldModel in pairs(vehicleESP.WorldModelCache) do
            if not worldModel or not worldModel.Parent then
                table.insert(toRemove, key)
            end
        end
        for _, key in ipairs(toRemove) do
            vehicleESP.WorldModelCache[key] = nil
        end
    end

    local vehicleESPConnections = {}
    local vehicleESPRunning = true

    local function disconnectVehicleConnections()
        for _, conn in ipairs(vehicleESPConnections) do
            if conn then conn:Disconnect() end
        end
        table.clear(vehicleESPConnections)
    end

    table.insert(vehicleESPConnections, workspace.ChildAdded:Connect(function(child)
        if not vehicleESPRunning then return end
        if child.Name == 'WorldModel' and child:IsA('Model') then
            task.spawn(function()
                task.wait(0.1)
                cleanupVehicleCache()
            end)
        end
    end))
    
    table.insert(vehicleESPConnections, workspace.ChildRemoved:Connect(function(child)
        if not vehicleESPRunning then return end
        if child.Name == 'WorldModel' and child:IsA('Model') then
            local data = vehicleESP.Active[child]
            if data then
                pcall(function() 
                    if data.billboard then data.billboard:Destroy() end
                end)
                vehicleESP.Active[child] = nil
            end
        end
    end))
    
    table.insert(vehicleESPConnections, workspace.ChildRemoved:Connect(function(child)
        if not vehicleESPRunning then return end
        if child.Name == 'WorldModel' and child:IsA('Model') then
            cleanupVehicleCache()
        end
    end))

    local vehicleScanInterval = 1.0
    local lastVehicleScan = 0

    table.insert(vehicleESPConnections, RunService.Heartbeat:Connect(function()
        if not vehicleESPRunning then return end
        local now = os.clock()
        if vehicleESP.Enabled and (vehicleESP.ShowName or vehicleESP.ShowDistance or vehicleESP.ShowHealth) then
            if now - lastVehicleScan >= vehicleScanInterval then
                scanVehicles()
                cleanupVehicleCache()
                lastVehicleScan = now
            end
            updateVehicleESP()
        else
            for _, data in pairs(vehicleESP.Active) do
                if data.billboard then data.billboard.Enabled = false end
            end
        end
    end))

    table.insert(vehicleESPConnections, Players.PlayerRemoving:Connect(function()
        if not vehicleESPRunning then return end
        for _, data in pairs(vehicleESP.Active) do
            pcall(function() 
                if data.billboard then data.billboard:Destroy() end
            end)
        end
        vehicleESP.Active = {}
        vehicleESP.WorldModelCache = setmetatable({}, {__mode = "kv"})
    end))

    local car = Sections.Vehicles:Toggle({
        Name = "Vehicle Names",
        Flag = "VehicleName",
        Default = false,
        Callback = function(State)
            vehicleESP.ShowName = State
            vehicleESP.Enabled = vehicleESP.ShowName or vehicleESP.ShowDistance or vehicleESP.ShowHealth
            if State then
                task.defer(scanVehicles)
            end
        end
    })

    car:Colorpicker({
        Name = "Vehicle Color",
        Flag = "VehicleColor",
        Default = vehicleESP.Color,
        Callback = function(Value)
            vehicleESP.Color = Value
            for _, data in pairs(vehicleESP.Active) do
                pcall(function() 
                    if data.label then data.label.TextColor3 = Value end
                end)
            end
        end
    })

    Sections.Vehicles:Toggle({
        Name = "Vehicle Distance",
        Flag = "VehicleDistance",
        Default = false,
        Callback = function(State)
            vehicleESP.ShowDistance = State
            vehicleESP.Enabled = vehicleESP.ShowName or vehicleESP.ShowDistance or vehicleESP.ShowHealth
            if State then
                task.defer(scanVehicles)
            end
        end
    })

    Sections.Vehicles:Toggle({
        Name = "Vehicle Health",
        Flag = "VehicleHealth",
        Default = false,
        Callback = function(State)
            vehicleESP.ShowHealth = State
            vehicleESP.Enabled = vehicleESP.ShowName or vehicleESP.ShowDistance or vehicleESP.ShowHealth
            if State then
                task.defer(scanVehicles)
            end
        end
    })

    Sections.Vehicles:Slider({
        Name = "Max Distance",
        Flag = "VehicleDistance",
        Min = 50,
        Max = 10000,
        Default = vehicleESP.RenderDistance,
		Suffix = "%",
        Decimals = 1,
        Callback = function(Value)
            vehicleESP.RenderDistance = Value
        end
    })

    Sections.Vehicles:Dropdown({
        Name = "Text Font",
        Flag = "VehicleFont",
        Options = {
            'Code',
            'Arial',
            'ArialBold',
            'Cartoon',
            'Fantasy',
            'Garamond',
            'Gotham',
            'GothamBold',
            'GothamMedium',
            'GothamSemibold',
            'Highway',
            'Legacy',
            'Roboto',
            'RobotoMono',
            'SourceSans',
            'SourceSansBold',
            'SourceSansItalic',
            'SourceSansSemibold',
        },
        Default = 'Code',
        Callback = function(value)
            local fontMap = {
                ['Code'] = Enum.Font.Code,
                ['Arial'] = Enum.Font.Arial,
                ['ArialBold'] = Enum.Font.ArialBold,
                ['Cartoon'] = Enum.Font.Cartoon,
                ['Fantasy'] = Enum.Font.Fantasy,
                ['Garamond'] = Enum.Font.Garamond,
                ['Gotham'] = Enum.Font.Gotham,
                ['GothamBold'] = Enum.Font.GothamBold,
                ['GothamMedium'] = Enum.Font.GothamMedium,
                ['GothamSemibold'] = Enum.Font.GothamSemibold,
                ['Highway'] = Enum.Font.Highway,
                ['Legacy'] = Enum.Font.Legacy,
                ['Roboto'] = Enum.Font.Roboto,
                ['RobotoMono'] = Enum.Font.RobotoMono,
                ['SourceSans'] = Enum.Font.SourceSans,
                ['SourceSansBold'] = Enum.Font.SourceSansBold,
                ['SourceSansItalic'] = Enum.Font.SourceSansItalic,
                ['SourceSansSemibold'] = Enum.Font.SourceSansSemibold,
            }
            
            local newFont = fontMap[value] or Enum.Font.Code
            vehicleESP.Font = newFont
            
            for _, data in pairs(vehicleESP.Active) do
                pcall(function() 
                    if data.label then data.label.Font = newFont end
                end)
            end
        end
    })
    
    local lastCacheCleanup = 0
    table.insert(vehicleESPConnections, RunService.Heartbeat:Connect(function()
        if not vehicleESPRunning then return end
        local now = os.clock()
        if now - lastCacheCleanup >= 5 then
            cleanupVehicleCache()
            lastCacheCleanup = now
        end
    end))
    
    local originalDestroy = Sections.Vehicles.Destroy
    Sections.Vehicles.Destroy = function(self)
        vehicleESPRunning = false
        disconnectVehicleConnections()
        for _, data in pairs(vehicleESP.Active) do
            pcall(function() 
                if data.billboard then data.billboard:Destroy() end
            end)
        end
        vehicleESP.Active = {}
        if originalDestroy then
            originalDestroy(self)
        end
    end

    -- Initial setup if enabled
    if vehicleESP.Enabled then
        task.defer(scanVehicles)
    end
end


do
    Players = Players or game:GetService("Players")
    LocalPlayer = Players.LocalPlayer
    Camera = workspace.CurrentCamera
    RunService = game:GetService('RunService')
    CoreGui = game:GetService("CoreGui")
    
    lootbagESP = lootbagESP or {
        Enabled = false,
        ShowName = false,
        ShowDistance = false,
        Color = Color3.fromRGB(255, 255, 255),
        Size = 14,
        RenderDistance = 10000,
        Active = {},
        Font = Enum.Font.Code,
    }
    
    local Functions = {}
    do
        function Functions:Create(Class, Properties)
            local _Instance = typeof(Class) == 'string' and Instance.new(Class) or Class
            for Property, Value in pairs(Properties) do
                _Instance[Property] = Value
            end
            return _Instance;
        end
        
        function Functions:FadeOutOnDist(element, distance, maxDistance)
            local transparency = math.max(0.1, 1 - (distance / maxDistance))
            if element:IsA("TextLabel") then
                element.TextTransparency = 1 - transparency
            elseif element:IsA("ImageLabel") then
                element.ImageTransparency = 1 - transparency
            elseif element:IsA("UIStroke") then
                element.Transparency = 1 - transparency
            elseif element:IsA("Frame") then
                element.BackgroundTransparency = 1 - transparency
            end
        end;
    end

    -- Create ScreenGui for ESP
    local ScreenGui = Functions:Create("ScreenGui", {
        Parent = CoreGui,
        Name = "LootbagESPHolder",
        Enabled = false
    })
    
    local function getgravename(gravemodel)
        local playergrave = gravemodel:FindFirstChild("PlayerGrave")
        if not playergrave then return "Unknown Grave" end

        for _, descendant in ipairs(playergrave:GetDescendants()) do
            if descendant:IsA("MeshPart") and descendant:GetAttribute("DisplayName") then
                local displayname = descendant:GetAttribute("DisplayName")
                return displayname
            end
        end

        return "Unknown Grave"
    end
    
    local function createLootbagESP(trashBag)
        if lootbagESP.Active[trashBag] then return end

        local graveModel = trashBag:FindFirstAncestor("Default")
        local graveName = graveModel and getgravename(graveModel) or "Unknown Grave"
        
        -- Create folder for this grave's ESP
        local EntityFolder = Functions:Create("Folder", {
            Parent = ScreenGui,
            Name = tostring(trashBag)
        })
        
        -- Create TextLabel
        local textLabel = Functions:Create("TextLabel", {
            Parent = EntityFolder,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 200, 0, 50),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            TextColor3 = lootbagESP.Color,
            Font = lootbagESP.Font,
            TextSize = lootbagESP.Size,
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            RichText = true,
            Visible = false
        })
        
        lootbagESP.Active[trashBag] = {
            folder = EntityFolder,
            textLabel = textLabel,
            graveName = graveName,
            trashBag = trashBag
        }
        return textLabel
    end
    
    local function scanLootbags()
        if not lootbagESP.Enabled then return end
        for _, obj in pairs(workspace:GetChildren()) do
            if obj.Name == 'Default' then
                local trashBag = obj:FindFirstChild('Meshes/Trash_bag2_Untitled.002', true)
                if trashBag and not lootbagESP.Active[trashBag] then
                    createLootbagESP(trashBag)
                end
            end
        end
    end
    
    local function updateLootbagESP()
        Camera = workspace.CurrentCamera or Camera
        local origin = (LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character.PrimaryPart.Position) or Camera.CFrame.Position
        
        for trashBag, data in pairs(lootbagESP.Active) do
            local textLabel = data.textLabel
            local folder = data.folder
            
            if not trashBag or not trashBag.Parent then
                pcall(function() 
                    if folder then folder:Destroy() end
                end)
                lootbagESP.Active[trashBag] = nil
            else
                local dist = (trashBag.Position - origin).Magnitude
                local displayDist = dist / 2.56
                
                if lootbagESP.Enabled and dist <= lootbagESP.RenderDistance then
                    -- Convert world position to screen position
                    local pos, onScreen = Camera:WorldToViewportPoint(trashBag.Position)
                    
                    if onScreen then
                        -- Position the label above the trash bag
                        textLabel.Position = UDim2.new(0, pos.X, 0, pos.Y - 50)
                        textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                        textLabel.TextColor3 = lootbagESP.Color
                        textLabel.TextSize = lootbagESP.Size
                        textLabel.Font = lootbagESP.Font
                        
                        local text = ''
                        
                        if lootbagESP.ShowName then
                            text = data.graveName or "Unknown Grave"
                        end
                        if lootbagESP.ShowDistance then
                            local distText = string.format('%.0fm', displayDist)
                            text = (text ~= '' and (text .. ' ' .. distText)) or distText
                        end
                        
                        textLabel.Text = text
                        
                        -- Apply fade out on distance
                        Functions:FadeOutOnDist(textLabel, dist, lootbagESP.RenderDistance)
                        
                        textLabel.Visible = (text ~= '')
                    else
                        textLabel.Visible = false
                    end
                else
                    textLabel.Visible = false
                end
            end
        end
    end
    
    local lootbagESPConnections = {}
    
    table.insert(lootbagESPConnections, workspace.ChildAdded:Connect(function(child)
        if child.Name == 'Default' then
            task.spawn(function()
                task.wait(0.1)
                local trashBag = child:FindFirstChild('Meshes/Trash_bag2_Untitled.002', true)
                if trashBag then
                    createLootbagESP(trashBag)
                end
            end)
        end
    end))
    
    table.insert(lootbagESPConnections, workspace.ChildRemoved:Connect(function(child)
        if child.Name == 'Default' then
            local trashBag = child:FindFirstChild('Meshes/Trash_bag2_Untitled.002', true)
            if trashBag and lootbagESP.Active[trashBag] then
                pcall(function() 
                    if lootbagESP.Active[trashBag].folder then 
                        lootbagESP.Active[trashBag].folder:Destroy() 
                    end
                end)
                lootbagESP.Active[trashBag] = nil
            end
        end
    end))
    
    local lootScanInterval = 5.0
    local lastLootScan = 0
    
    table.insert(lootbagESPConnections, RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if lootbagESP.Enabled and (lootbagESP.ShowName or lootbagESP.ShowDistance) then
            if now - lastLootScan >= lootScanInterval then
                scanLootbags()
                lastLootScan = now
            end
            updateLootbagESP()
        else
            for _, data in pairs(lootbagESP.Active) do
                if data.textLabel then
                    data.textLabel.Visible = false
                end
            end
        end
    end))
    
    table.insert(lootbagESPConnections, Players.PlayerRemoving:Connect(function()
        for _, data in pairs(lootbagESP.Active) do
            pcall(function() 
                if data.folder then data.folder:Destroy() end
            end)
        end
        lootbagESP.Active = {}
    end))

    local grave = Sections.Graves:Toggle({
        Name = "Grave Names",
        Default = false,
        Flag = "LootbagName",
        Callback = function(State)
            lootbagESP.ShowName = State
            lootbagESP.Enabled = lootbagESP.ShowName or lootbagESP.ShowDistance
            if State then
                ScreenGui.Enabled = true
                task.defer(scanLootbags)
            else
                if not lootbagESP.ShowName and not lootbagESP.ShowDistance then
                    ScreenGui.Enabled = false
                end
            end
        end
    })

    grave:Colorpicker({
        Name = "Grave Color",
        Flag = "LootbagColor",
        Default = lootbagESP.Color,
        Callback = function(Value)
            lootbagESP.Color = Value
            for _, data in pairs(lootbagESP.Active) do
                pcall(function() 
                    if data.textLabel then data.textLabel.TextColor3 = Value end
                end)
            end
        end
    })

    Sections.Graves:Toggle({
        Name = "Grave Distance",
        Default = false,
        Flag = "LootbagDistance",
        Callback = function(State)
            lootbagESP.ShowDistance = State
            lootbagESP.Enabled = lootbagESP.ShowName or lootbagESP.ShowDistance
            if State then
                ScreenGui.Enabled = true
                task.defer(scanLootbags)
            else
                if not lootbagESP.ShowName and not lootbagESP.ShowDistance then
                    ScreenGui.Enabled = false
                end
            end
        end
    })

    Sections.Graves:Slider({
        Name = "Max Distance",
        Flag = "LootbagDistance",
        Min = 50,
        Max = 10000,
        Default = lootbagESP.RenderDistance,
		Suffix = "%",
        Decimals = 1,
        Callback = function(Value)
            lootbagESP.RenderDistance = Value
        end
    })

    Sections.Graves:Dropdown({
        Name = "Text Font",
        Flag = "LootbagFont",
        Options = {
            'Code',
            'Arial',
            'ArialBold',
            'Cartoon',
            'Fantasy',
            'Garamond',
            'Gotham',
            'GothamBold',
            'GothamMedium',
            'GothamSemibold',
            'Highway',
            'Legacy',
            'Roboto',
            'RobotoMono',
            'SourceSans',
            'SourceSansBold',
            'SourceSansItalic',
            'SourceSansSemibold',
        },
        Default = 'Code',
        Callback = function(value)
            local fontMap = {
                ['Code'] = Enum.Font.Code,
                ['Arial'] = Enum.Font.Arial,
                ['ArialBold'] = Enum.Font.ArialBold,
                ['Cartoon'] = Enum.Font.Cartoon,
                ['Fantasy'] = Enum.Font.Fantasy,
                ['Garamond'] = Enum.Font.Garamond,
                ['Gotham'] = Enum.Font.Gotham,
                ['GothamBold'] = Enum.Font.GothamBold,
                ['GothamMedium'] = Enum.Font.GothamMedium,
                ['GothamSemibold'] = Enum.Font.GothamSemibold,
                ['Highway'] = Enum.Font.Highway,
                ['Legacy'] = Enum.Font.Legacy,
                ['Roboto'] = Enum.Font.Roboto,
                ['RobotoMono'] = Enum.Font.RobotoMono,
                ['SourceSans'] = Enum.Font.SourceSans,
                ['SourceSansBold'] = Enum.Font.SourceSansBold,
                ['SourceSansItalic'] = Enum.Font.SourceSansItalic,
                ['SourceSansSemibold'] = Enum.Font.SourceSansSemibold,
            }
            
            local newFont = fontMap[value] or Enum.Font.Code
            lootbagESP.Font = newFont
            
            for _, data in pairs(lootbagESP.Active) do
                pcall(function() 
                    if data.textLabel then data.textLabel.Font = newFont end
                end)
            end
        end
    })

    -- Initial setup if enabled
    if lootbagESP.Enabled then
        ScreenGui.Enabled = true
        task.defer(scanLootbags)
    end
end


---anti aim
do

--spinbot


local RunService = game:GetService("RunService")
local Players = game:GetService("Players") -- Add this line to get the Players service

local spinEnabled = false
local spinValue = 0
local spinSpeed = 3
local spinConnection = nil
local CustomMeshCharacter = nil -- Initialize this variable

local function startSpin()
    if spinConnection then return end
    spinConnection = RunService.RenderStepped:Connect(function(dt)
        if not spinEnabled then return end
        spinValue = spinValue + (dt * spinSpeed)
        
        local lp = Players.LocalPlayer -- Now Players is defined
        if not lp then return end -- Add a safety check
        
        if not CustomMeshCharacter then
            pcall(function()
                CustomMeshCharacter = require(game.ReplicatedFirst.GunSystemPlugins.CustomMeshCharacter)
            end)
        end
        
        if CustomMeshCharacter then
            local worldChar = CustomMeshCharacter:GetWorldCharacterFromPlayer(lp)
            if worldChar and worldChar:IsDescendantOf(workspace) then
                local pivot = worldChar:GetPivot()
                worldChar:PivotTo(CFrame.new(pivot.Position) * CFrame.Angles(0, spinValue, 0))
            end
        end
    end)
end

local function stopSpin()
    if spinConnection then 
        spinConnection:Disconnect() 
        spinConnection = nil 
    end
    spinValue = 0
end

Sections.AntiAim:Toggle({
    Name = "Spin Bot",
    Default = false,
    Flag = "spin_enabled",
    Callback = function(Value)
        spinEnabled = Value
        if spinEnabled then
            startSpin()
        else
            stopSpin()
        end
    end
})

Sections.AntiAim:Slider({
    Name = "Spin Speed",
    Decimals = 0.1,
    Suffix = "%",
    Flag = "spin_speed",
    Min = 0.1,
    Max = 20,
    Default = 3,
    Compact = false, 
    Callback = function(Value)
        spinSpeed = tonumber(Value) or 3
    end
})


local aa_enabled = false
local aa_mode = "Up"
local aa_pitch = 0
local jitter_timer = 0
local jitter_direction = 1
local jitter_speed = 1,

Sections.AntiAim:Toggle({
    Name = "Anti Aim", 
    Default = false, 
    Flag = "anti_aim_toggle", 
    Callback = function(Value)
        aa_enabled = Value
    end
})

Sections.AntiAim:Dropdown({
    Name = "Mode", 
    Multi = false, 
    Flag = "anti_aim_mode", 
    Options = {"Up", "Down", "Pitch", "Jitter"}, 
    Callback = function(Value)
        aa_mode = Value
    end
})

Sections.AntiAim:Slider({
    Name = "Pitch", 
    Decimals = 0.01,
    Suffix = "%",
    Flag = "anti_aim_pitch", 
    Min = -3.14, 
    Max = 3.14, 
    Default = 0,
    Compact = false,
    Callback = function(Value)
        aa_pitch = tonumber(Value) or 0
    end
})

Sections.AntiAim:Slider({
    Name = "Jitter Speed", 
    Decimals = 0.1,
    Suffix = "%",
    Flag = "jitter_speed", 
    Min = 0.1, 
    Max = 1, 
    Default = 1,
    Compact = false,
    Callback = function(Value)
        jitter_speed = tonumber(Value) or 1 -- Use local variable instead of flags
    end
})

local old
old = hookfunction(getrawmetatable(game).__index, function(self, key)
    if not checkcaller() and key == "CFrame" and self == workspace.CurrentCamera then
        local cf = old(self, key)
        if aa_enabled then
            local calling_script = getcallingscript()
            if calling_script and calling_script.Name == "CharacterController" then
                if aa_mode == "Up" then
                    return CFrame.new(cf.Position, cf.Position + Vector3.new(0, 1, 0))
                elseif aa_mode == "Down" then
                    return CFrame.new(cf.Position, cf.Position + Vector3.new(0, -1, 0))
                elseif aa_mode == "Pitch" then
                    return CFrame.new(cf.Position, cf.Position + Vector3.new(math.sin(aa_pitch), math.cos(aa_pitch), 0))
                elseif aa_mode == "Jitter" then
                    jitter_timer = jitter_timer + (0.1 * jitter_speed) -- Use local variable
                    if jitter_timer >= 1 then
                        jitter_timer = 0
                        jitter_direction = jitter_direction * -1
                    end
                    return CFrame.new(cf.Position, cf.Position + Vector3.new(0, jitter_direction, 0))
                end
            end
        end
        return cf
    end
    return old(self, key)
end)
end


--mod Detector
do

local players = game:GetService("Players")
local lp = players.LocalPlayer

staffscannerenabled = false

local staffranks = {
    {min = 5, max = 5, name = "Wiki Team"},
    {min = 6, max = 6, name = "Bug Squasher"},
    {min = 7, max = 7, name = "Contributor"},
    {min = 8, max = 8, name = "Alpha Tester"},
    {min = 9, max = 9, name = "Beta Tester"},
    {min = 9, max = 9, name = "Sigma Tester"},
    {min = 90, max = 90, name = "Content Creator"},
    {min = 98, max = 98, name = "Trial Moderator"},
    {min = 99, max = 99, name = "Moderator"},
    {min = 100, max = 100, name = "Senior Moderator"},
    {min = 150, max = 150, name = "Administrator"},
    {min = 151, max = 151, name = "Contractor"},
    {min = 152, max = 152, name = "Map Developer"},
    {min = 198, max = 198, name = "Internal Staff"},
    {min = 199, max = 199, name = "Senior Administrator"},
    {min = 250, max = 250, name = "Developer"},
    {min = 253, max = 253, name = "Lead Developer"},
    {min = 254, max = 254, name = "Co-Owner"},
    {min = 255, max = 255, name = "Owner"}
}

local function getrankname(rank)
    for _, data in ipairs(staffranks) do
        if rank >= data.min and rank <= data.max then
            return data.name
        end
    end
    return "unknown"
end

local groupservice = game:GetService("GroupService")
local groupid = 3441839

local function checkstaffmember(player)
    if not staffscannerenabled then return end
    
    local success, result = pcall(function()
        return groupservice:GetGroupInfoAsync(groupid)
    end)
    
    if not success then return end
    
    local success2, rank = pcall(function()
        return player:GetRankInGroup(groupid)
    end)
    
    if success2 and rank and rank > 0 then
        local rankname = getrankname(rank)
        if rankname ~= "unknown" then
            Library:Notification(player.Name .. " is a " .. rankname, 5, Library.Theme.Accent)
        end
    end
end

Sections.Mod:Toggle({
    Name = "Staff Scanner",
    Default = false,
    Flag = "StaffScanner",
    Callback = function(Value)
        staffscannerenabled = Value
        if Value then
            Library:Notification("Staff Scanner Enabled", 2, Library.Theme.Accent)
            for _, player in ipairs(players:GetPlayers()) do
                if player ~= lp then
                    task.spawn(function()
                        checkstaffmember(player)
                    end)
                end
            end
        else
            Library:Notification("Staff Scanner Disabled", 2, Library.Theme.Accent)
        end
    end
})

players.PlayerAdded:Connect(function(player)
    if staffscannerenabled then
        task.wait(0.5)
        checkstaffmember(player)
    end
end)

task.spawn(function()
    while true do
        task.wait(30)
        if staffscannerenabled then
            for _, player in ipairs(players:GetPlayers()) do
                if player ~= lp then
                    task.spawn(function()
                        checkstaffmember(player)
                    end)
                end
            end
        end
    end
end)

end
--lng shit
do
local neckLength = 5
local longNeckRunning = false
local longNeckThread

longNeckThread = task.spawn(function()
    while true do
        if longNeckRunning then
            local gunplugin = require(
                game:GetService("ReplicatedFirst")
                    .GunSystem.GunController.Events.GunPlugin
            )
            gunplugin:SetOverrideCameraHeight(neckLength)
        end
        task.wait(0.1)
    end
end)

Sections.LongNeck:Toggle({
    Name = "Long Neck",
    Default = false,
    Flag = "LongNeck",
    Callback = function(Value)
        longNeckRunning = Value
        if not Value then
            local gunplugin = require(
                game:GetService("ReplicatedFirst")
                    .GunSystem.GunController.Events.GunPlugin
            )
            gunplugin:SetOverrideCameraHeight(5)
        end
    end
})

Sections.LongNeck:Slider({
    Name = "Neck Height",
    Flag = "NeckHeight",
    Default = 4,
	Suffix = "%",
    Min = 0,
    Max = 5,
    Decimals = 1,
    Callback = function(Value)
        neckLength = Value
    end
})

end


--carfly
do

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local flightSpeed = 120
local flightKey = Enum.KeyCode.H
local isFlying = false

local moveForward = false
local moveBackward = false
local moveLeft = false
local moveRight = false

local function CleanupVehicle(vehicle)
    if not vehicle then return end
    
    local partsToDestroy = {
        "AntiRoll","AntiRollBars","AntiTeleport",
    }
    for _, name in ipairs(partsToDestroy) do
        local part = vehicle:FindFirstChild(name)
        if part then 
            pcall(function() part:Destroy() end)
        end
    end
    
    local scripts = vehicle:FindFirstChild("Scripts")
    if scripts then
        for _, n in ipairs({"Server"}) do
            local sub = scripts:FindFirstChild(n)
            if sub then 
                pcall(function() sub:Destroy() end)
            end
        end
    end
end

local function RemoveImpacts()
    for _, child in ipairs(workspace:GetDescendants()) do
        if child.Name == "Impact" then
            pcall(function()
                child:Destroy()
            end)
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == flightKey then
        isFlying = not isFlying
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then
        moveForward = true
    elseif input.KeyCode == Enum.KeyCode.S then
        moveBackward = true
    elseif input.KeyCode == Enum.KeyCode.A then
        moveLeft = true
    elseif input.KeyCode == Enum.KeyCode.D then
        moveRight = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then
        moveForward = false
    elseif input.KeyCode == Enum.KeyCode.S then
        moveBackward = false
    elseif input.KeyCode == Enum.KeyCode.A then
        moveLeft = false
    elseif input.KeyCode == Enum.KeyCode.D then
        moveRight = false
    end
end)

local carflyEnabled = false

local CarFly = Sections.Carfly:Toggle({
    Name = "CarFly",
    Flag = "CarFly",
    Default = false,
    Callback = function(Value)
        carflyEnabled = Value
        if Value then
            Library:Notification("CarFly On", 2, Library.Theme.Accent)
            RemoveImpacts()
            for _, object in pairs(workspace:GetChildren()) do
                local chassis = object:FindFirstChild("Chassis")
                local config = object:FindFirstChild("Configuration")
                if chassis and chassis:IsA("BasePart") and config then
                    local driverValue = config:FindFirstChild("Driver")
                    if driverValue and driverValue:IsA("ObjectValue") and driverValue.Value == localPlayer then
                        CleanupVehicle(object)
                        break
                    end
                end
            end
        else
            Library:Notification("CarFly Off", 2, Library.Theme.Accent)
            for _, obj in ipairs(workspace:GetChildren()) do
                local chassis = obj:FindFirstChild("Chassis")
                if chassis and chassis:IsA("BasePart") then
                    chassis.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end
    end
})
CarFly:Keybind({
    Name = "CarFly Key",
    Flag = "CarFlyKey",
    Default = Enum.KeyCode.H,
    Mode = "Toggle",
    Callback = function(Value)
        carflyEnabled = Value
        if Value then
            Library:Notification("CarFly On", 2, Library.Theme.Accent)
            RemoveImpacts()
            for _, object in pairs(workspace:GetChildren()) do
                local chassis = object:FindFirstChild("Chassis")
                local config = object:FindFirstChild("Configuration")
                if chassis and chassis:IsA("BasePart") and config then
                    local driverValue = config:FindFirstChild("Driver")
                    if driverValue and driverValue:IsA("ObjectValue") and driverValue.Value == localPlayer then
                        CleanupVehicle(object)
                        break
                    end
                end
            end
        else
            Library:Notification("CarFly Off", 2, Library.Theme.Accent)
            for _, obj in ipairs(workspace:GetChildren()) do
                local chassis = obj:FindFirstChild("Chassis")
                if chassis and chassis:IsA("BasePart") then
                    chassis.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end
    end
})

RunService.Heartbeat:Connect(function()
    if not isFlying or not carflyEnabled then return end

    for _, object in pairs(workspace:GetChildren()) do
        local chassis = object:FindFirstChild("Chassis")
        local config = object:FindFirstChild("Configuration")

        if chassis and chassis:IsA("BasePart") and config then
            local driverValue = config:FindFirstChild("Driver")
            if driverValue and driverValue:IsA("ObjectValue") and driverValue.Value == localPlayer then
                local cameraCFrame = camera.CFrame
                local forwardDirection = cameraCFrame.LookVector
                local rightDirection = cameraCFrame.RightVector
                
                local moveDirection = Vector3.zero
                
                if moveForward then
                    moveDirection = moveDirection + forwardDirection
                end
                if moveBackward then
                    moveDirection = moveDirection - forwardDirection
                end
                if moveLeft then
                    moveDirection = moveDirection - rightDirection
                end
                if moveRight then
                    moveDirection = moveDirection + rightDirection
                end
                
                if moveDirection.Magnitude > 0.1 then
                    moveDirection = moveDirection.Unit * flightSpeed
                    chassis.AssemblyLinearVelocity = moveDirection
                    
                    local horizontalDirection = Vector3.new(moveDirection.X, 0, moveDirection.Z).Unit
                    if horizontalDirection.Magnitude > 0.1 then
                        local targetOrientation = CFrame.lookAt(chassis.Position, chassis.Position + horizontalDirection)
                        chassis.CFrame = CFrame.new(chassis.Position) * targetOrientation.Rotation
                    end
                else
                    chassis.AssemblyLinearVelocity = Vector3.zero
                end

                chassis.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end
end)

end
--camera
do


Sections.Cam:Toggle({
    Name = "Remove Inventory Blur",
    Default = false,
    Flag = "NoInventoryBlur",
    Callback = function(Value)
        workspace = workspace
        local blur = workspace.Camera:FindFirstChild('Blur')
        if Value then 
            if not blur then
                local childAdded
                childAdded = workspace.Camera.ChildAdded:Connect(function(child)
                    if child.Name == 'Blur' then
                        childAdded:Disconnect()
                        child.Size = 0
                    end
                end)
            else
                blur.Size = 0
            end
        else
            if blur then
                blur.Size = 60
            end
        end
    end
})

player = game:GetService("Players").LocalPlayer
playerGui = player:WaitForChild("PlayerGui")
GameUI = playerGui:WaitForChild("GameUI")
Menu = GameUI:WaitForChild("Menu")
Background = Menu.Background
Cache = {}

for _, Tab in ipairs(Menu:GetChildren()) do
    if not Tab:IsA("Frame") or Tab.Name == "Background" then
        continue
    end
    for _, Item in ipairs(Tab:GetChildren()) do
        if not Item:IsA("Frame") or Item.Transparency == 1 then
            continue
        end
        Cache[Item] = Item.BackgroundTransparency
    end
end


Sections.Cam:Toggle({
    Name = "Remove Inventory Background",
    Default = false,
    Flag = "NoInventoryBackground",
    Callback = function(Value)
        if Value then
            for Frame, Original in pairs(Cache) do
                Frame.BackgroundTransparency = 1
            end
        else
            for Frame, Original in pairs(Cache) do
                Frame.BackgroundTransparency = Original
            end
        end
    end
})

Background:GetPropertyChangedSignal("Visible"):Connect(function()
    if not Background.Visible then
        return
    end
    for Frame, Original in pairs(Cache) do
        Frame.BackgroundTransparency = Original
    end
end)

end

do

local LocalPlayer = game:GetService("Players").LocalPlayer
local CustomMeshCharacter = require(game:GetService("ReplicatedFirst"):WaitForChild("GunSystemPlugins"):WaitForChild("CustomMeshCharacter"))

if not Maid then
    Maid = {
        Tasks = {},
        AddTask = function(self, task)
            table.insert(self.Tasks, task)
            return task
        end
    }
end

local NeckStretchAmount = 0
local NeckStretchEnabled = false
local StretchedHeads = {}

local StretchX = 1
local StretchY = 1
local StretchZ = 1

local function RemoveStretchedHead(Character)
    if not Character then return end
    
    if StretchedHeads[Character] then
        for _, Head in ipairs(StretchedHeads[Character]) do
            if Head and Head.Parent then
                Head:Destroy()
            end
        end
        StretchedHeads[Character] = nil
    end
    
    local RealHead = Character:FindFirstChild("Head")
    if RealHead then
        RealHead.Transparency = 0
    end
end

local function CreateStretchedHead(Character, Player)
    if not Player or Player == LocalPlayer then return end
    
    if Player:GetAttribute("Dead") then
        RemoveStretchedHead(Character)
        return
    end
    
    if not NeckStretchEnabled or NeckStretchAmount <= 0 then
        RemoveStretchedHead(Character)
        return
    end
    
    if not Character then return end
    
    RemoveStretchedHead(Character)
    
    local RealHead = Character:FindFirstChild("Head")
    if not RealHead then return end
    
    local RealNeck = RealHead:FindFirstChild("Neck")
    if not RealNeck then return end
    
    local OriginalC0 = RealNeck.C0
    
    local StretchedHead = RealHead:Clone()
    StretchedHead:SetAttribute("StretchedHead", true)
    StretchedHead.Parent = Character
    
    if not StretchedHeads[Character] then
        StretchedHeads[Character] = {}
    end
    table.insert(StretchedHeads[Character], StretchedHead)
    
    local StretchedNeck = StretchedHead:FindFirstChild("Neck")
    if StretchedNeck then
        local StretchScale = 1 + (NeckStretchAmount * 0.5)
        
        local StretchedCFrame = OriginalC0 * CFrame.new(0, -NeckStretchAmount * 0.3, 0)
        StretchedNeck.C0 = StretchedCFrame
        
        StretchedHead.Size = RealHead.Size * Vector3.new(
            StretchX,
            StretchY * StretchScale,
            StretchZ
        )
        
        StretchedHead.Position = RealHead.Position + Vector3.new(0, -NeckStretchAmount * 0.3, 0)
    end
    
    RealHead.Transparency = 1
end

local function GetPlayerCharacters(Player)
    local characters = {}
    if Player then
        if CustomMeshCharacter and CustomMeshCharacter.GetCharacters then
            local allChars = CustomMeshCharacter:GetCharacters()
            for _, Data in ipairs(allChars) do
                if Data.Player == Player then
                    table.insert(characters, Data.WorldModel)
                end
            end
        else
            local character = Player.Character
            if character then
                table.insert(characters, character)
            end
        end
    end
    return characters
end

local function UpdatePlayerStretch(Player)
    local characters = GetPlayerCharacters(Player)
    for _, WorldModel in ipairs(characters) do
        CreateStretchedHead(WorldModel, Player)
    end
end

local function HandlePlayerStateChange(Player)
    Player:GetAttributeChangedSignal("Dead"):Connect(function()
        local characters = GetPlayerCharacters(Player)
        for _, WorldModel in ipairs(characters) do
            CreateStretchedHead(WorldModel, Player)
        end
    end)
end

local function InitializePlayer(Player)
    if Player:GetAttribute("Dead") then
        local characters = GetPlayerCharacters(Player)
        for _, WorldModel in ipairs(characters) do
            RemoveStretchedHead(WorldModel)
        end
    else
        UpdatePlayerStretch(Player)
    end
    HandlePlayerStateChange(Player)
end

local function ApplyStretchToAllPlayers()
    for _, Player in ipairs(game:GetService("Players"):GetPlayers()) do
        if Player ~= LocalPlayer then
            local characters = GetPlayerCharacters(Player)
            for _, WorldModel in ipairs(characters) do
                if NeckStretchEnabled and NeckStretchAmount > 0 then
                    CreateStretchedHead(WorldModel, Player)
                else
                    RemoveStretchedHead(WorldModel)
                end
            end
        end
    end
end

local function CleanupPlayerStretch(Player)
    local characters = GetPlayerCharacters(Player)
    for _, WorldModel in ipairs(characters) do
        RemoveStretchedHead(WorldModel)
    end
end

game:GetService("Players").PlayerAdded:Connect(function(Player)
    task.wait(1)
    InitializePlayer(Player)
end)

game:GetService("Players").PlayerRemoving:Connect(function(Player)
    CleanupPlayerStretch(Player)
end)

for _, Player in ipairs(game:GetService("Players"):GetPlayers()) do
    InitializePlayer(Player)
end

Sections.SkinWalker:Toggle({
    Name = "Stretched Neck ",
    Default = false,
    Flag = "NeckStretchEnabled",
    Callback = function(Value)
        NeckStretchEnabled = Value
        if not Value then
            for _, Player in ipairs(game:GetService("Players"):GetPlayers()) do
                if Player ~= LocalPlayer then
                    local characters = GetPlayerCharacters(Player)
                    for _, WorldModel in ipairs(characters) do
                        RemoveStretchedHead(WorldModel)
                    end
                end
            end
        else
            ApplyStretchToAllPlayers()
        end
    end
})

Sections.SkinWalker:Slider({
    Name = "Stretch Amount",
    Decimals = 1,
    Suffix = "%",
    Flag = "NeckStretchAmount",
    Min = 0,
    Max = 5,
    Compact = false,
    Callback = function(Value)
        NeckStretchAmount = tonumber(Value) or 0
        if NeckStretchEnabled and NeckStretchAmount > 0 then
            ApplyStretchToAllPlayers()
        elseif NeckStretchAmount <= 0 then
            for _, Player in ipairs(game:GetService("Players"):GetPlayers()) do
                if Player ~= LocalPlayer then
                    local characters = GetPlayerCharacters(Player)
                    for _, WorldModel in ipairs(characters) do
                        RemoveStretchedHead(WorldModel)
                    end
                end
            end
        end
    end
})

Sections.SkinWalker:Slider({
    Name = "Stretch X",
    Decimals = 1,
    Suffix = "%",
    Flag = "StretchX",
    Min = 0.5,
    Max = 3,
    Default = 1,
    Compact = false,
    Callback = function(Value)
        StretchX = tonumber(Value) or 1
        if NeckStretchEnabled and NeckStretchAmount > 0 then
            ApplyStretchToAllPlayers()
        end
    end
})

Sections.SkinWalker:Slider({
    Name = "Stretch Y",
    Decimals = 1,
    Suffix = "%",
    Flag = "StretchY",
    Min = 0.5,
    Max = 3,
    Default = 1,
    Compact = false,
    Callback = function(Value)
        StretchY = tonumber(Value) or 1
        if NeckStretchEnabled and NeckStretchAmount > 0 then
            ApplyStretchToAllPlayers()
        end
    end
})

Sections.SkinWalker:Slider({
    Name = "Stretch Z",
    Decimals = 1,
    Suffix = "%",
    Flag = "StretchZ",
    Min = 0.5,
    Max = 3,
    Default = 1,
    Compact = false,
    Callback = function(Value)
        StretchZ = tonumber(Value) or 1
        if NeckStretchEnabled and NeckStretchAmount > 0 then
            ApplyStretchToAllPlayers()
        end
    end
})

CustomMeshCharacter.CharacterAdded:Connect(function(Player, Character, WorldModel)
    if Player == LocalPlayer then return end
    if NeckStretchEnabled and NeckStretchAmount > 0 then
        CreateStretchedHead(WorldModel, Player)
    end
end)

CustomMeshCharacter.CharacterRemoved:Connect(function(Player, Character, WorldModel)
    if Player == LocalPlayer then return end
    RemoveStretchedHead(WorldModel)
end)

end
--head Expander

local LocalPlayer = game:GetService("Players").LocalPlayer
local CustomMeshCharacter = require(game:GetService("ReplicatedFirst"):WaitForChild("GunSystemPlugins"):WaitForChild("CustomMeshCharacter"))

if not Maid then
    Maid = {
        Tasks = {},
        AddTask = function(self, task)
            table.insert(self.Tasks, task)
            return task
        end
    }
end

local HitboxExpander = false
local Radius = 5
local offsetCache = {}

local function GetOffsets(r)
    if offsetCache[r] then return offsetCache[r] end
    local offsets = {}
    local collisionRadius = r - 0.5
    for X = -collisionRadius, collisionRadius do
        for Y = -collisionRadius, collisionRadius do
            for Z = -collisionRadius, collisionRadius do
                local Distance = math.sqrt(X*X + Y*Y + Z*Z) - collisionRadius
                if Distance <= 0.5 and Distance >= -0.5 then
                    table.insert(offsets, Vector3.new(X, Y, Z))
                end
            end
        end
    end
    offsetCache[r] = offsets
    return offsets
end

local function SetHeads(Character, Player)
    if not Player then return end
    if Player == LocalPlayer then return end 
    if Player:GetAttribute("Dead") then
        for _, Head in Character:QueryDescendants("[$FakeHead]") do
            Head:Destroy()
        end
        return
    end
    
    for _, Head in Character:QueryDescendants("[$FakeHead]") do
        Head:Destroy()
    end

    if not HitboxExpander then
        return
    end

    local RealHead = Character:FindFirstChild("Head")
    if not RealHead then return end
    
    local RealNeck = RealHead:FindFirstChild("Neck")
    local BaseC0 = RealNeck and RealNeck.C0 or CFrame.identity
    
    local VisualHead = RealHead:Clone()
    pcall(function() VisualHead.face:Destroy() end)
    VisualHead.Shape = Enum.PartType.Ball
    VisualHead.Size = Vector3.one * Radius * 2
    VisualHead.Color = Color3.fromRGB(148, 0, 211)
    VisualHead.Material = Enum.Material.ForceField
    VisualHead.CanCollide = false
    VisualHead.CanQuery = false
    VisualHead.CanTouch = false
    VisualHead.Massless = true
    VisualHead.CastShadow = false
    VisualHead:SetAttribute("FakeHead", true)
    VisualHead.Parent = Character
    VisualHead.Transparency = 0.5

    for _, offset in GetOffsets(Radius) do
        local NewHead = RealHead:Clone()
        pcall(function() NewHead.face:Destroy() end)
        NewHead.CanCollide = true
        NewHead.CanQuery = true
        NewHead.CanTouch = false
        NewHead.Massless = true
        NewHead.CastShadow = false
        NewHead.Transparency = 1
        NewHead:SetAttribute("FakeHead", true)
        NewHead.Parent = Character

        local Neck = NewHead:FindFirstChild("Neck")
        if Neck then
            Neck.C0 = BaseC0 * CFrame.new(offset)
        end
    end
end

local function ReapplyHeadsForPlayer(Player)
    for _, Data in ipairs(CustomMeshCharacter:GetCharacters()) do
        if Data.Player == Player then
            SetHeads(Data.WorldModel, Player)
        end
    end
end

local function HandlePlayerStateChange(Player)
    Player:GetAttributeChangedSignal("Dead"):Connect(function()
        for _, Data in ipairs(CustomMeshCharacter:GetCharacters()) do
            if Data.Player == Player then
                SetHeads(Data.WorldModel, Player)
            end
        end
    end)
end

local function InitializePlayerHeads(Player)
    if Player:GetAttribute("Dead") then
        for _, Data in ipairs(CustomMeshCharacter:GetCharacters()) do
            if Data.Player == Player then
                for _, Head in Data.WorldModel:QueryDescendants("[$FakeHead]") do
                    Head:Destroy()
                end
            end
        end
    else
        ReapplyHeadsForPlayer(Player)
    end
    HandlePlayerStateChange(Player)
end

local function ApplyHitboxToAllPlayers(state)
    for _, Player in ipairs(game:GetService("Players"):GetPlayers()) do
        for _, Data in ipairs(CustomMeshCharacter:GetCharacters()) do
            if Data.Player == Player and Player ~= LocalPlayer then
                if state then
                    SetHeads(Data.WorldModel, Player)
                else
                    for _, Head in Data.WorldModel:QueryDescendants("[$FakeHead]") do
                        Head:Destroy()
                    end
                end
            end
        end
    end
end

game:GetService("Players").PlayerAdded:Connect(function(Player)
    task.wait(1)
    InitializePlayerHeads(Player)
end)

for _, Player in ipairs(game:GetService("Players"):GetPlayers()) do
    InitializePlayerHeads(Player)
end


local Expand = Sections.HeadExpander:Toggle({
    Name = "Hitbox Expander",
    Default = false,
    Flag = "HitboxExpanderEnabled",
    Callback = function(Value)
        HitboxExpander = Value
        ApplyHitboxToAllPlayers(Value)
    end
})


Sections.HeadExpander:Slider({
    Name = "Head Size",
    Decimals = 1,
    Suffix = "%",
    Flag = "HeadSize",
    Min = 1,
    Max = 3,
    Compact = false,
    Callback = function(Value)
        Radius = tonumber(Value)
        if not Radius then return end
        offsetCache = {}
        if HitboxExpander then
            for _, Player in ipairs(game:GetService("Players"):GetPlayers()) do
                ReapplyHeadsForPlayer(Player)
            end
        end
    end
})

CustomMeshCharacter.CharacterAdded:Connect(function(Player, Character, WorldModel)
    if Player == LocalPlayer then return end
    if HitboxExpander then
        SetHeads(WorldModel, Player)
    end
end)

CustomMeshCharacter.CharacterRemoved:Connect(function(Player, Character, WorldModel)
    if Player == LocalPlayer then return end
    for _, Head in WorldModel:QueryDescendants("[$FakeHead]") do
        Head:Destroy()
    end
end)

---gun Mods


---Movements


local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local bhop, bhop_power = false, 25

for _, v in getgc() do
    if type(v) == "function" then
        local info = debug.getinfo(v)
        if info.name == "updateCharData" then
            local old
            old = hookfunction(v, newcclosure(function(p254, p255, p256)
                if p254 == "Jump" then return end
                return old(p254, p255, p256)
            end))
        end
    end
end


local Bhop = Sections.Movements:Toggle({
    Name = "Bhop",
    Default = false,
    Flag = "BhopEnabled",
    Callback = function(Value)
        bhop = Value
        game:GetService("ReplicatedStorage").CustomCharacterConfigs.Configuration.Client.cl_auto_jump.Value = Value
    end
})
Bhop:Keybind({
    Name = "Bhop Keybind",
    Flag = "BhopKeybind",
    Default = Enum.KeyCode.B,
    Mode = "Toggle",
    Callback = function(Value)
        bhop = Value
        game:GetService("ReplicatedStorage").CustomCharacterConfigs.Configuration.Client.cl_auto_jump.Value = Value
    end
})

local camera = workspace.CurrentCamera
local tables = { parts = {} }

local func_vars = {
    keycode = Enum.KeyCode,
    nVec3 = Vector3.new,
    insert = table.insert,
}

local tserv = {
    player = {
        player_modifiers = {
            fly_hack = false,
            c1 = true,
            fly_hack_velocity = 30,
        }
    }
}

local function is_key_down(inputService, key)
    return inputService:IsKeyDown(key)
end

local function get_part()
    local attempt = 0
    repeat
        task.wait(0.5)
        tables.parts = {}
        for _, v in pairs(Camera:GetDescendants()) do
            if v:IsA("BasePart")
                and v.RootPriority
                and v.RootPriority > 10
                and v.AssemblyLinearVelocity
                and v.AssemblyLinearVelocity.Magnitude > 0 then
                func_vars.insert(tables.parts, v)
            end
        end
        attempt += 1
    until #tables.parts > 0 or attempt >= 3
end

local function fly()
    if tserv.player.player_modifiers.fly_hack
        and #tables.parts > 0
        and tserv.player.player_modifiers.c1 then

        local camLook = Camera.CFrame.LookVector
        local dir = Vector3.zero

        local keymap = {
            [func_vars.keycode.W] = camLook,
            [func_vars.keycode.S] = -camLook,
            [func_vars.keycode.D] = func_vars.nVec3(-camLook.Z, 0, camLook.X),
            [func_vars.keycode.A] = func_vars.nVec3(camLook.Z, 0, -camLook.X),
            [func_vars.keycode.Space] = func_vars.nVec3(0, 1, 0),
            [func_vars.keycode.LeftControl] = func_vars.nVec3(0, -1, 0),
        }

        for key, vec in pairs(keymap) do
            if is_key_down(UIS, key) then
                dir += vec
            end
        end

        local finalVelocity = (dir.Magnitude > 0)
            and dir.Unit * tserv.player.player_modifiers.fly_hack_velocity
            or Vector3.zero

        for _, obj in ipairs(tables.parts) do
            obj.AssemblyLinearVelocity = finalVelocity
        end
    end
end

RS.Heartbeat:Connect(fly)


local Flyhack = Sections.Movements:Toggle({
    Name = "Flyhack",
    Default = false,
    Flag = "FlyhackEnabled",
    Callback = function(Value)
        tserv.player.player_modifiers.fly_hack = Value
        if Value then
            get_part()
        else
            for _, obj in ipairs(tables.parts) do
                obj.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
})
Flyhack:Keybind({
    Name = "Flyhack Keybind",
    Flag = "FlyhackKeybind",
    Default = Enum.KeyCode.F,
    Mode = "Toggle",
    Callback = function(Value)
        tserv.player.player_modifiers.fly_hack = Value
        if Value then
            get_part()
        else
            for _, obj in ipairs(tables.parts) do
                obj.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
})


Sections.Movements:Slider({
    Name = "Flyhack Speed",
    Decimals = 1,
    Suffix = "%",
    Flag = "FlyhackSpeed",
    Min = 1,
    Max = 100,
    Compact = false,
    Callback = function(Value)
        tserv.player.player_modifiers.fly_hack_velocity = Value
    end
})

local speedhackEnabled = false
local speedhackSpeed = 0.5
local speedhackConnection = nil

function GetMovementPart()
    for _, child in workspace.CurrentCamera:GetDescendants() do
        if child:IsA("MeshPart") then
            local size = child.Size
            if size.X == 2.5 and size.Z == 2.5 then
                if size.Y == 5 or size.Y == 3.25 or size.Y == 3 or size.Y == 2 then
                    return child
                end
            end
        end
    end
    return nil
end

function ApplySpeedHack()
    if not speedhackEnabled then return end

    local movementPart = GetMovementPart()
    if not movementPart then return end

    local camera = workspace.CurrentCamera
    if not camera then return end

    local moveDirection = Vector3.new()

    if UIS:IsKeyDown(Enum.KeyCode.W) then
        moveDirection = moveDirection + camera.CFrame.LookVector
    end
    if UIS:IsKeyDown(Enum.KeyCode.S) then
        moveDirection = moveDirection - camera.CFrame.LookVector
    end
    if UIS:IsKeyDown(Enum.KeyCode.A) then
        moveDirection = moveDirection - camera.CFrame.RightVector
    end
    if UIS:IsKeyDown(Enum.KeyCode.D) then
        moveDirection = moveDirection + camera.CFrame.RightVector
    end

    if moveDirection.Magnitude > 0 then
        moveDirection = moveDirection.Unit
        local newVelocity = moveDirection * (25 * speedhackSpeed)

        pcall(function()
            movementPart.AssemblyLinearVelocity = Vector3.new(
                newVelocity.X,
                movementPart.AssemblyLinearVelocity.Y,
                newVelocity.Z
            )
        end)
    end
end


local Speedhack = Sections.Movements:Toggle({
    Name = "Speed Hack",
    Default = false,
    Flag = "SpeedhackEnabled",
    Callback = function(Value)
        speedhackEnabled = Value
        if Value then
            if not speedhackConnection then
                speedhackConnection = RS.Heartbeat:Connect(ApplySpeedHack)
            end
        else
            if speedhackConnection then
                speedhackConnection:Disconnect()
                speedhackConnection = nil
            end
        end
    end
})
Speedhack:Keybind({
    Name = "Speed Hack Keybind",
    Flag = "SpeedhackKeybind",
    Default = Enum.KeyCode.T,
    Mode = "Toggle",
    Callback = function(Value)
        speedhackEnabled = Value
        if Value then
            if not speedhackConnection then
                speedhackConnection = RS.Heartbeat:Connect(ApplySpeedHack)
            end
        else
            if speedhackConnection then
                speedhackConnection:Disconnect()
                speedhackConnection = nil
            end
        end
    end
})


Sections.Movements:Slider({
    Name = "Speed Hack Speed",
    Decimals = 1,
    Suffix = "%",
    Flag = "SpeedhackSpeed",
    Min = 0,
    Max = 2,
    Compact = false,
    Callback = function(Value)
        speedhackSpeed = Value
    end
})



    ---do esp 


getgenv().cleardrawcache = nil;

local BetterDrawing = loadstring(game:HttpGet("https://raw.githubusercontent.com/dementiaenjoyer/Better-Drawing/refs/heads/main/Main.lua"))();
local DrawingFlag = BetterDrawing.FLAG;

local Players = game:GetService("Players");
local Workspace = game:GetService("Workspace");

local Camera = Workspace.CurrentCamera;
local LocalPlayer = Players.LocalPlayer;

local Round = math.round;

local custommeshcharacter = require(game.ReplicatedFirst.GunSystemPlugins.CustomMeshCharacter)
local playerlist = require(game.ReplicatedStorage.CustomCharacter.PlayerList)

local gameassets = workspace:FindFirstChild("game_assets")
local entitiesfolder = gameassets and gameassets:FindFirstChild("Entities")

local skeleton_order = {
    ["LeftFoot"] = "LeftLowerLeg",
    ["LeftLowerLeg"] = "LeftUpperLeg",
    ["LeftUpperLeg"] = "LowerTorso",
    ["RightFoot"] = "RightLowerLeg",
    ["RightLowerLeg"] = "RightUpperLeg",
    ["RightUpperLeg"] = "LowerTorso",
    ["LeftHand"] = "LeftLowerArm",
    ["LeftLowerArm"] = "LeftUpperArm",
    ["LeftUpperArm"] = "UpperTorso",
    ["RightHand"] = "RightLowerArm",
    ["RightLowerArm"] = "RightUpperArm",
    ["RightUpperArm"] = "UpperTorso",
    ["LowerTorso"] = "UpperTorso",
    ["UpperTorso"] = "Head"
}

local espSettings = {
    showBoxes = true,
    boxColor = Color3.new(1, 1, 1),
    maxDistance = 1000,
    showSkeleton = true,
    skeletonColor = Color3.new(1, 1, 1),
    showGun = true,
    gunColor = Color3.new(1, 1, 1),
    showName = true,
    nameColor = Color3.new(1, 1, 1),
    showDistance = true,
    distanceColor = Color3.new(1, 1, 1),
    showTracer = true,
    tracerColor = Color3.new(1, 1, 1)
}

local function get_current_gun(plr)
    if not plr then return "Fists" end
    local c = plr:FindFirstChild("CurrentSelectedObject")
    c = c and c.Value
    c = c and c.Value
    return c and c.Name or "Fists"
end

local function GetPlayerFromEntity(entity)
    if not entity then return nil end
    local character = custommeshcharacter:GetCharacterFromWorldCharacter(entity)
    if not character then return nil end
    local pd = playerlist:GetPlayerFromCharacter(character)
    if not pd or pd.Name == "" then return nil end
    return Players:FindFirstChild(pd.Name)
end

local function DrawCornerBox(Position, Size, Color, Thickness, Length)
    local corners = {}
    local x, y = Position.X, Position.Y
    local w, h = Size.X, Size.Y
    local l = Length or math.min(w, h) * 0.25

    local tl1 = Drawing.new("Line", DrawingFlag)
    tl1.Visible = true
    tl1.Color = Color
    tl1.Thickness = Thickness
    tl1.From = Vector2.new(x, y + l)
    tl1.To = Vector2.new(x, y)
    table.insert(corners, tl1)
    
    local tl2 = Drawing.new("Line", DrawingFlag)
    tl2.Visible = true
    tl2.Color = Color
    tl2.Thickness = Thickness
    tl2.From = Vector2.new(x, y)
    tl2.To = Vector2.new(x + l, y)
    table.insert(corners, tl2)

    local tr1 = Drawing.new("Line", DrawingFlag)
    tr1.Visible = true
    tr1.Color = Color
    tr1.Thickness = Thickness
    tr1.From = Vector2.new(x + w - l, y)
    tr1.To = Vector2.new(x + w, y)
    table.insert(corners, tr1)
    
    local tr2 = Drawing.new("Line", DrawingFlag)
    tr2.Visible = true
    tr2.Color = Color
    tr2.Thickness = Thickness
    tr2.From = Vector2.new(x + w, y)
    tr2.To = Vector2.new(x + w, y + l)
    table.insert(corners, tr2)

    local bl1 = Drawing.new("Line", DrawingFlag)
    bl1.Visible = true
    bl1.Color = Color
    bl1.Thickness = Thickness
    bl1.From = Vector2.new(x, y + h - l)
    bl1.To = Vector2.new(x, y + h)
    table.insert(corners, bl1)
    
    local bl2 = Drawing.new("Line", DrawingFlag)
    bl2.Visible = true
    bl2.Color = Color
    bl2.Thickness = Thickness
    bl2.From = Vector2.new(x, y + h)
    bl2.To = Vector2.new(x + l, y + h)
    table.insert(corners, bl2)

    local br1 = Drawing.new("Line", DrawingFlag)
    br1.Visible = true
    br1.Color = Color
    br1.Thickness = Thickness
    br1.From = Vector2.new(x + w - l, y + h)
    br1.To = Vector2.new(x + w, y + h)
    table.insert(corners, br1)
    
    local br2 = Drawing.new("Line", DrawingFlag)
    br2.Visible = true
    br2.Color = Color
    br2.Thickness = Thickness
    br2.From = Vector2.new(x + w, y + h)
    br2.To = Vector2.new(x + w, y + h - l)
    table.insert(corners, br2)

    return corners
end

local function DrawSkeleton(entity, ScreenPosition, Distance, Scale)
    local skeletonLines = {}
    local points = {}
    
    local Joints = {}
    for _, part in pairs(entity:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            Joints[part.Name] = part
        end
    end
    
    for partName, _ in pairs(skeleton_order) do
        local part = Joints[partName]
        if part then
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                points[partName] = Vector2.new(Round(pos.X), Round(pos.Y))
            end
        end
    end
    
    for fromPart, toPart in pairs(skeleton_order) do
        if points[fromPart] and points[toPart] then
            local outline = Drawing.new("Line", DrawingFlag)
            outline.Visible = true
            outline.Color = Color3.new(0, 0, 0)
            outline.Thickness = 4
            outline.From = points[fromPart]
            outline.To = points[toPart]
            table.insert(skeletonLines, outline)
            
            local inner = Drawing.new("Line", DrawingFlag)
            inner.Visible = true
            inner.Color = espSettings.skeletonColor
            inner.Thickness = 2
            inner.From = points[fromPart]
            inner.To = points[toPart]
            table.insert(skeletonLines, inner)
        end
    end
    
    local head = Joints["Head"]
    if head then
        local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
        if headOnScreen then
            local headScreenPos = Vector2.new(Round(headPos.X), Round(headPos.Y))
            
            local headScale = (2 * Camera.ViewportSize.Y) / ((2 * Distance * math.tan(math.rad(Camera.FieldOfView) / 2)) * 2.5)
            local headRadius = Round(0.8 * headScale)
            
            local headDotOutline = Drawing.new("Circle", DrawingFlag)
            headDotOutline.Visible = true
            headDotOutline.Color = Color3.new(0, 0, 0)
            headDotOutline.Thickness = 3
            headDotOutline.NumSides = 32
            headDotOutline.Radius = headRadius
            headDotOutline.Position = headScreenPos
            headDotOutline.Filled = false
            table.insert(skeletonLines, headDotOutline)
            
            local headDotInner = Drawing.new("Circle", DrawingFlag)
            headDotInner.Visible = true
            headDotInner.Color = espSettings.skeletonColor
            headDotInner.Thickness = 1
            headDotInner.NumSides = 32
            headDotInner.Radius = headRadius
            headDotInner.Position = headScreenPos
            headDotInner.Filled = false
            table.insert(skeletonLines, headDotInner)
        end
    end
    
    return skeletonLines
end

local function DrawGunDisplay(entity, Position, Size)
    local gunDisplay = {}
    
    local player = GetPlayerFromEntity(entity)
    if not player then return gunDisplay end
    
    local weaponName = get_current_gun(player)
    
    local gunText = Drawing.new("Text", DrawingFlag)
    gunText.Visible = true
    gunText.Text = weaponName
    gunText.Size = 12
    gunText.Color = espSettings.gunColor
    gunText.Center = true
    gunText.Outline = true
    gunText.OutlineColor = Color3.new(0, 0, 0)
    gunText.Font = 2
    gunText.Position = Vector2.new(Position.X + (Size.X / 2), Position.Y + Size.Y + 18)
    table.insert(gunDisplay, gunText)
    
    return gunDisplay
end

local function Update()
    if not entitiesfolder then return end
    
    for _, entity in pairs(entitiesfolder:GetChildren()) do
        if entity and entity:FindFirstChild("HumanoidRootPart") then
            local HRP = entity.HumanoidRootPart
            local Root = HRP
            
            local player = GetPlayerFromEntity(entity)
            if not player or player == LocalPlayer then
                continue
            end
            
            local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 0.5, 0))
            local Distance = ScreenPosition.Z
            
            if Distance > espSettings.maxDistance then
                continue
            end
            
            if not OnScreen then
                continue
            end
            
            local Scale = (2 * Camera.ViewportSize.Y) / ((2 * Distance * math.tan(math.rad(Camera.FieldOfView) / 2)) * 1.5)
            
            local Width, Height = Round(4 * Scale), Round(5.5 * Scale)
            local Size = Vector2.new(Width, Height)
            
            local Position = Vector2.new(Round(ScreenPosition.X - (Width / 2)), Round(ScreenPosition.Y - (Height / 2)))
            
            if espSettings.showBoxes then
                local OutlineCorners = DrawCornerBox(Position, Size, Color3.new(0, 0, 0), 2)
                local InnerCorners = DrawCornerBox(Position, Size, espSettings.boxColor, 1)
            end
            
            if espSettings.showSkeleton then
                local SkeletonLines = DrawSkeleton(entity, ScreenPosition, Distance, Scale)
            end
            
            if espSettings.showGun then
                local GunDisplay = DrawGunDisplay(entity, Position, Size)
            end
            
            if espSettings.showName then
                local NameText = Drawing.new("Text", DrawingFlag)
                NameText.Visible = true
                NameText.Color = espSettings.nameColor
                NameText.Size = 14
                NameText.Center = true
                NameText.Outline = true
                NameText.OutlineColor = Color3.new(0, 0, 0)
                NameText.Font = 2
                NameText.Text = player.Name
                NameText.Position = Vector2.new(Position.X + (Width / 2), Position.Y - 18)
            end
            
            if espSettings.showDistance then
                local DistText = Drawing.new("Text", DrawingFlag)
                DistText.Visible = true
                DistText.Color = espSettings.distanceColor
                DistText.Size = 12
                DistText.Center = true
                DistText.Outline = true
                DistText.OutlineColor = Color3.new(0, 0, 0)
                DistText.Font = 2
                DistText.Text = Round(Distance) .. "m"
                DistText.Position = Vector2.new(Position.X + (Width / 2), Position.Y + Height + 4)
            end
            
            if espSettings.showTracer then
                local TracerOutline = Drawing.new("Line", DrawingFlag)
                TracerOutline.Visible = true
                TracerOutline.Color = Color3.new(0, 0, 0)
                TracerOutline.Thickness = 2
                TracerOutline.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                TracerOutline.To = Vector2.new(Round(ScreenPosition.X), Round(ScreenPosition.Y + (Height / 2)))
                
                local TracerInner = Drawing.new("Line", DrawingFlag)
                TracerInner.Visible = true
                TracerInner.Color = espSettings.tracerColor
                TracerInner.Thickness = 1
                TracerInner.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                TracerInner.To = Vector2.new(Round(ScreenPosition.X), Round(ScreenPosition.Y + (Height / 2)))
            end
        end
    end
end

BetterDrawing:Init(Update)

local Box = Sections.Humans:Toggle({
    Name = "Show Boxes",
    Default = true,
    Flag = "ShowBoxes",
    Callback = function(Value)
        espSettings.showBoxes = Value
    end
})
Box:Colorpicker({
    Name = "Box Color",
    Flag = "BoxColor",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        espSettings.boxColor = Value
    end
})


local Skeleton = Sections.Humans:Toggle({
    Name = "Show Skeleton",
    Default = true,
    Flag = "ShowSkeleton",
    Callback = function(Value)
        espSettings.showSkeleton = Value
    end
})
Skeleton:Colorpicker({
    Name = "Skeleton Color",
    Flag = "SkeletonColor",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        espSettings.skeletonColor = Value
    end
})


local Guns = Sections.Humans:Toggle({
    Name = "Show Gun",
    Default = true,
    Flag = "ShowGun",
    Callback = function(Value)
        espSettings.showGun = Value
    end
})
Guns:Colorpicker({
    Name = "Gun Color",
    Flag = "GunColor",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        espSettings.gunColor = Value
    end
})

local Names = Sections.Humans:Toggle({
    Name = "Show Name",
    Default = true,
    Flag = "ShowName",
    Callback = function(Value)
        espSettings.showName = Value
    end
})

Names:Colorpicker({
    Name = "Name Color",
    Flag = "NameColor",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        espSettings.nameColor = Value
    end
})


local Distances = Sections.Humans:Toggle({
    Name = "Show Distance",
    Default = true,
    Flag = "ShowDistance",
    Callback = function(Value)
        espSettings.showDistance = Value
    end
})

Distances:Colorpicker({
    Name = "Distance Color",
    Flag = "DistanceColor",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        espSettings.distanceColor = Value
    end
})

local Tracers = Sections.Humans:Toggle({
    Name = "Show Tracer",
    Default = true,
    Flag = "ShowTracer",
    Callback = function(Value)
        espSettings.showTracer = Value
    end
})

Tracers:Colorpicker({
    Name = "Tracer Color",
    Flag = "TracerColor",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        espSettings.tracerColor = Value
    end
}) 

local MaxDistance = Sections.Humans:Slider({
    Name = "Max Distance",
    Decimals = 1,
    Suffix = "%",
    Flag = "MaxDistance",
    Min = 10,
    Max = 10000,
    Compact = false,
    Callback = function(Value)
        espSettings.maxDistance = Value
    end
})


		do
			local ThemeColorpickers = {};

			for _, Value in Library.Theme do
				ThemeColorpickers[_] = Sections.Themes:Colorpicker({Name = _, Flag = _ .. "_theme", Default = Value, Callback = function(Val)
					Library:ChangeTheme(_, Val);
				end});
			end;
		end;

		do
			local ConfigName = "";
			local ConfigSelected;

			local ConfigDropdown = Sections.Configs:Dropdown({Name = "Configs", Flag = "Configs", Options = {}, Callback = function(Value)
				ConfigSelected = Value;
			end});

			Sections.Configs:Textbox({Name = "Config Name", Default = "", Flag = "ConfigName", Placeholder = "Name ...", Callback = function(Value)
				ConfigName = Value;
			end});

			Sections.Configs:Button({Name = "Load Config", Callback = function()
				if ConfigSelected then
					Library:LoadConfig(readfile(Library:GetConfigsDirectory() .. ConfigSelected .. ".json"));

					task.spawn(function()
						task.wait(0.5)

						for Index, Value in Library.Theme do 
							Library.Theme[Index] = Library.Flags[Index.."_theme"].Color;
							Library:ChangeTheme(Index, Library.Flags[Index.."_theme"].Color);
						end;
					end);
				end;
			end}):CreateSub({Name = "Save Config", Callback = function()
				if ConfigSelected then
					writefile(Library:GetConfigsDirectory() .. ConfigSelected .. ".json", Library:GetConfig());
					Library:Notification("Saved Config", 3, Color3.fromRGB(0, 255, 0));
				end;
			end});

			Sections.Configs:Button({Name = "Create Config", Callback = function()
				if ConfigName == "" then 
					Library:Notification("Config name can't be empty.", 3, Color3.fromRGB(255, 0, 0));
					return;
				end;

				if isfile(Library:GetConfigsDirectory() .. ConfigName .. ".json") then
					Library:Notification("Config already exists.", 3, Color3.fromRGB(255, 0, 0));
					return;
				end;

				writefile(Library:GetConfigsDirectory() .. ConfigName .. ".json", Library:GetConfig());
				Library:ListConfigs(ConfigDropdown);
			end}):CreateSub({Name = "Delete Config", Callback = function()
				if ConfigSelected then
					delfile(Library:GetConfigsDirectory() .. ConfigSelected .. ".json");
				end;
			end});

			Library:ListConfigs(ConfigDropdown);
		end;
	end;
end;

Library:Notification("Loaded", 5, Library.Theme.Accent);
task.wait(2);
Library:Notification("beta version\ncredits to vantyx team\nthanks for using vantyx", 5, Library.Theme.Accent);
Library:Notification("enjoy: ".. string.format("%.4f", tick() - LoadingTick) .. " seconds.", 5, Library.Theme.Accent);

Library:Watermark('<font color="rgb(138, 43, 226)">Vantyx</font>.ware ~ Aftermath ~ '.. Library.Version);

getgenv().Library = Library;
return Library;