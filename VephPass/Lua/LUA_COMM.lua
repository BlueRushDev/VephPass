-- vephinvert command
-- before you ask, yes this is lifted from Ray, and yes I made it

-- get defaults from I/O (player 2 is in the same file)
local default1 = "Off"
local default2 = "Off"
local file = io.openlocal("client/Veph/Invert.dat")
if file
	local num = file:read("*n")
	if num
		if num & EMERALD1 then default1 = "On" end
		if num & EMERALD2 then default2 = "On" end
	end
	file:close()
end

-- function to save to I/O when the command is modified
local vephinvert1
local vephinvert2
local invertfunc = function()
	local file = io.openlocal("client/Veph/Invert.dat", "w+")
	
	local num = 0
	if vephinvert1.value then num = $ | EMERALD1 end
	if vephinvert2.value then num = $ | EMERALD2 end
	
	file:write(num)
	file:close()
end

-- player 1's command
vephinvert1 = CV_RegisterVar({
	name = "vephinvert",
	defaultvalue = default1,
	flags = CV_CALL|CV_NOINIT,
	PossibleValue = CV_OnOff,
	func = invertfunc
})

-- player 2's command
vephinvert2 = CV_RegisterVar({
	name = "vephinvert2",
	defaultvalue = default2,
	flags = CV_CALL|CV_NOINIT,
	PossibleValue = CV_OnOff,
	func = invertfunc
})

-- locally invert forwardmove during a swim
addHook("PlayerCmd", function(player, cmd)
	if not (player.mo and player.mo.valid and player.mo.skin == "veph")
	or not player.vephswim
	or not ((vephinvert1.value and player == consoleplayer)
	or (vephinvert2.value and player == secondarydisplayplayer))
		return
	end
	
	cmd.forwardmove = -$
end)