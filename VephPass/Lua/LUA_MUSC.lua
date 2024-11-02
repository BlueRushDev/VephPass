//Musics??? How does this make any sense for an OC who has no music history
if not MF2_SPLAT return end

//vephmusic command
local default = "On"
local file = io.openlocal("client/Veph/Music.dat")
if file
	local num = file:read("*n")
	if num == 0
		default = "Off"
	end
	file:close()
end
rawset(_G, "vephmusic", CV_RegisterVar({
	name = "vephmusic",
	defaultvalue = default,
	flags = CV_CALL|CV_NOINIT,
	PossibleValue = CV_OnOff,
	func = function(cv)
		if io
			local file = io.openlocal("client/Veph/Music.dat", "w+")
			file:write(cv.value)
			file:close()
		end
	end
}))

local vephjingles = {
	//Invincibility (Sonic 1: The Next Level)
	//Reach To The Top (Rapina Bros)
	//On The Move (Jamaica Girls)
	//Bay Yard (Burning Force)
	["_inv"] = "vpinv",
	
	//Speed Shoes (Sonic 2 - Sega Master System)
	["_shoes"] = "vpshoe", 
	
	//1up (Metal Sonic Hyperdrive)
	//Stage Clear (Shinobi III: Return of the Ninja Master)
	["_1up"] = "vp1up",
	
	//Act Clear (Metal Sonic Hyperdrive)
	//Battle End BGM (Yuu Yuu Hakusho - Makyou Touitsusen)
	["_clear"] = "vpclea",
}

addHook("MusicChange", function(oldname, newname, mflags, looping)
	if vephmusic.value and consoleplayer and consoleplayer.valid
	and skins[consoleplayer.skin].name == "veph"
	and not (consoleplayer.mo and consoleplayer.mo.valid
	and consoleplayer.mo.health and consoleplayer.solchar
	and consoleplayer.solchar.istransformed)
	and vephjingles[newname] and S_MusicExists(vephjingles[newname])
		if newname == "_inv" or newname == "_shoes"
			return vephjingles[newname], nil, true
		else
			return vephjingles[newname]
		end
	end
end)