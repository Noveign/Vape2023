local errorPopupShown = false
local setidentity = syn and syn.set_thread_identity or set_thread_identity or setidentity or setthreadidentity or function() end
local getidentity = syn and syn.get_thread_identity or get_thread_identity or getidentity or getthreadidentity or function() return 8 end
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local delfile = delfile or function(file) writefile(file, "") end

local function displayErrorPopup(text, func)
	local oldidentity = getidentity()
	setidentity(8)
	local ErrorPrompt = getrenv().require(game:GetService("CoreGui").RobloxGui.Modules.ErrorPrompt)
	local prompt = ErrorPrompt.new("Default")
	prompt._hideErrorCode = true
	local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
	prompt:setErrorTitle("Vape")
	prompt:updateButtons({{
		Text = "OK",
		Callback = function() 
			prompt:_close() 
			if func then func() end
		end,
		Primary = true
	}}, 'Default')
	prompt:setParent(gui)
	prompt:_open(text)
	setidentity(oldidentity)
end

local function vapeGithubRequest(scripturl)
	if not isfile("vape/"..scripturl) then
		local suc, res
		task.delay(15, function()
			if not res and not errorPopupShown then 
				errorPopupShown = true
				displayErrorPopup("The connection to GitHub is taking a while, please be patient.")
			end
		end)
		suc, res = pcall(function() 
			return game:HttpGet("https://raw.githubusercontent.com/Noveign/Vape2023/main/"..scripturl, true) 
		end)
		if not suc or res == "404: Not Found" then
			displayErrorPopup("Failed to connect to GitHub : vape/"..scripturl.." : "..res)
			error(res)
		end
		if scripturl:find(".lua") then 
			res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res 
		end
		writefile("vape/"..scripturl, res)
	end
	return readfile("vape/"..scripturl)
end

-- Skip commit hash check, always pull from main
if not shared.VapeDeveloper then 
	if isfolder("vape") then 
		for _,v in pairs({"vape/Universal.lua", "vape/NewMainScript.lua", "vape/GuiLibrary.lua"}) do 
			if isfile(v) and readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.") then
				delfile(v)
			end 
		end
		if isfolder("vape/CustomModules") then 
			for _,v in pairs(listfiles("vape/CustomModules")) do 
				if isfile(v) and readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.") then
					delfile(v)
				end 
			end
		end
		if isfolder("vape/Libraries") then 
			for _,v in pairs(listfiles("vape/Libraries")) do 
				if isfile(v) and readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.") then
					delfile(v)
				end 
			end
		end
	else
		makefolder("vape")
	end
end

return loadstring(vapeGithubRequest("NewMainScript.lua"))()
