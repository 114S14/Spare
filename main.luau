if getgenv().hub_enviorment then
	return warn("GERM")
end

local supported_games = {
	["name"] = 123456789,
};

getgenv().hub_enviorment = {
	hub_version = game:HttpGet("https://raw.githubusercontent.com/114S14/--GERM--/refs/heads/main/version.txt");
};

function hub_enviorment:Notify(text)

	game:GetService("StarterGui"):SetCore("SendNotification", {

		Title = 'GERM' .. tostring(hub_enviorment.hub_version),
		Text = tostring(text),

		Duration = 3,
	})
end;

for i, v in supported_games do
	
	if tostring(game.PlaceId) == tostring(v) then
		return loadstring(game:HttpGet('https://raw.githubusercontent.com/114S14/--GERM--/refs/heads/main/games/' .. tostring(i) .. '.lua'))();
	end;
end;

getgenv().hub_enviorment = nil;

local LP = game:GetService("Players").LocalPlayer;
pcall(function() LP:Kick('不支持这个游戏!\n\n版本: ' .. tostring(hub_enviorment.hub_version)) end);
