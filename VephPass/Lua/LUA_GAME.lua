//Some Character by SMS Alfredo --His name is Veph now doofus!
local P_TeleportMove = P_MoveOrigin or P_TeleportMove

if not solchars
    rawset(_G, "solchars", {})
end
solchars["veph"] = {SKINCOLOR_SUPERWAVE1, 1}

local SQUISHTIME = 12
local WATERCOLOR = SKINCOLOR_CERULEAN

local SLIMETIME = TICRATE*6 //How long the defense debuff lasts (DEFAULT is TICRATE*3)
local SLIMEIFRAMES = TICRATE*3/4 //The amount of i-frames for being debuffed
local BUBBLECHARGETIME = TICRATE/4/3 //How long the bubble takes to charge (Default is TICRATE/2)
local BUBBLECOOLDOWN = TICRATE*2 //Default cooldown period for bubble
local BUBBLETUMBLE = TICRATE/4 //How long the bubble tumbles you for
local BUBBLEINCREASE = 2 //How many debuff stages the bubble gives you
local BUBBLECOST = 10 //Ring cost for the bubble

sfxinfo[freeslot("sfx_vpfizz")].caption = "Fizzling"
sfxinfo[freeslot("sfx_vpbonk")].caption = "Bonk"
sfxinfo[freeslot("sfx_vphit")].caption = "Bonk"
sfxinfo[freeslot("sfx_vpbnce")].caption = "Boing"

sfxinfo[freeslot("sfx_vpdive")].caption = "Whoosh"
sfxinfo[freeslot("sfx_vpcanc")].caption = "Whish"

sfxinfo[freeslot("sfx_vplnd1")].caption = "/"
sfxinfo[freeslot("sfx_vplnd2")].caption = "Splash"

sfxinfo[freeslot("sfx_vptail")].caption = "Splattering"
sfxinfo[freeslot("sfx_vptal2")].caption = "MULTI-SPLATTERING!!"
sfxinfo[freeslot("sfx_vpfull")].caption = "Charged!"

sfxinfo[freeslot("sfx_vpjmp2")].caption = "Woop"
sfxinfo[freeslot("sfx_vpdsh1")].caption = "Rushing water"
sfxinfo[freeslot("sfx_vpdsh2")].caption = "Rushing bubbles"

sfxinfo[freeslot("sfx_vpswm1")].caption = "Swimming"
sfxinfo[freeslot("sfx_vpswm2")].caption = "Swimming"
sfxinfo[freeslot("sfx_vptwr1")].caption = "Swish"
sfxinfo[freeslot("sfx_vptwr2")].caption = "Swish"

sfxinfo[freeslot("sfx_vpgop1")].caption = "Splat!"
sfxinfo[sfx_vpgop1].singular = true
sfxinfo[freeslot("sfx_vpgop2")].caption = "Splat!"
sfxinfo[sfx_vpgop2].singular = true
sfxinfo[freeslot("sfx_vpgop3")].caption = "Splat!"
sfxinfo[sfx_vpgop3].singular = true

sfxinfo[freeslot("sfx_vpdebf")].caption = "Defense Debuff"
sfxinfo[freeslot("sfx_vpboin")].caption = "Boing!"
sfxinfo[freeslot("sfx_vpbrst")].caption = "Bubble burst"
sfxinfo[freeslot("sfx_vpbubl")].caption = "Bubble throw"
sfxinfo[freeslot("sfx_vpchrg")].caption = "Bubble charge"

for i = 1, 5
	sfxinfo[freeslot("sfx_vpsld"+i)].caption = "Splashing"
end

//Random function for local sound effects
local vephrandomseed = 3135128580
rawset(_G, "VephRandom", function(a,b)
	vephrandomseed = $*(max(gamemap+globallevelskynum+leveltime, 1)%128)
	if consoleplayer and consoleplayer.valid
	and consoleplayer.mo and consoleplayer.mo.valid
		vephrandomseed = $-(consoleplayer.mo.x+consoleplayer.mo.y+consoleplayer.mo.z)
	end
	vephrandomseed = $/2
	local dumb = ((vephrandomseed*36548569) >> 4) & (FRACUNIT-1)
	return ((dumb * (b-a+1)) >> FRACBITS) + a
end)

freeslot("SPR_VPPT")

function A_VephPanim(mo, var1, var2)
	if mo and mo.valid and mo.player
		if mo.frame & FF_SPR2ENDSTATE
			mo.player.panim = var2
		else
			mo.player.panim = var1
			if var1 == PA_DASH and not (mo.frame & FF_ANIMATE)
				mo.frame = ($ &~ FF_FRAMEMASK) | var2
			end
		end
	end
end

local S_VEPH_SLIDE_UP = S_TAILSOVERLAY_0DEGREES
local S_VEPH_SLIDE_DIAUP = S_TAILSOVERLAY_PLUS30DEGREES
local S_VEPH_SLIDE_FRWD = S_TAILSOVERLAY_PLUS60DEGREES
local S_VEPH_SLIDE_DIADOWN = S_TAILSOVERLAY_MINUS30DEGREES
local S_VEPH_SLIDE_DOWN = S_TAILSOVERLAY_MINUS60DEGREES

local S_VEPH_HOP = S_PLAY_FIRE
local S_VEPH_HOP_FINISH = S_PLAY_FIRE_FINISH

local S_VEPH_SWIM_STOP = S_PLAY_GLIDE
local S_VEPH_SWIM_FRWD = S_PLAY_SWIM
local S_VEPH_SWIM_UP = S_TAILSOVERLAY_FLY
local S_VEPH_SWIM_DOWN = S_TAILSOVERLAY_TIRE

freeslot("S_VEPH_VSWIPE1", "S_VEPH_VSWIPE2", "S_VEPH_VSWIPE3", "S_VEPH_VSWIPE4", "S_VEPH_VSWIPE5",
"S_VEPH_VSWIPE6", "S_VEPH_VSWIPE7")
for i = 1, 5
	local sprite2 = 5 - i + 1
	sprite2 = _G["SPR2_TAL" + $]
	local nextstate = _G["S_VEPH_VSWIPE" + (i + 1)]
	states[_G["S_VEPH_VSWIPE" + i]]
		= {SPR_PLAY, sprite2|FF_VERTICALFLIP, 3,
		A_VephPanim, PA_DASH, 0, nextstate}
end
states[S_VEPH_VSWIPE6] = {SPR_PLAY, SPR2_TWIN, 3, A_VephPanim, PA_DASH, C, S_VEPH_VSWIPE7}
states[S_VEPH_VSWIPE7] = {SPR_PLAY, SPR2_TWIN, 3, A_VephPanim, PA_DASH, B, S_PLAY_FALL}

freeslot("S_VEPH_DIVE")
states[S_VEPH_DIVE] = {SPR_PLAY, SPR2_ROLL|FF_SPR2ENDSTATE, 1, nil, S_VEPH_SLIDE_DIADOWN, 0, S_VEPH_DIVE}

freeslot("S_VEPH_JUMP")
states[S_VEPH_JUMP] = {SPR_PLAY, SPR2_TWIN|FF_SPR2ENDSTATE, 3, nil, S_PLAY_FALL, 0, S_VEPH_JUMP}

freeslot("S_VEPH_SPRING")
states[S_VEPH_SPRING] = {SPR_PLAY, SPR2_GASP, 65, A_VephPanim, PA_JUMP, PA_JUMP, S_PLAY_FALL}

function A_VephVisualGoop(mo, var1, var2)
	if mo and mo.valid
		mo.spriteyoffset = $ - 3*FRACUNIT
		
		mo.spritexscale = $*14/16
		mo.spriteyscale = $*16/15
		
		if mo.target and mo.target.valid
			P_TryMove(mo, mo.target.x + P_ReturnThrustX(mo, mo.movedir, mo.movefactor),
			mo.target.y + P_ReturnThrustY(mo, mo.movedir, mo.movefactor), true)
			
			if not mo.threshold
				mo.color = mo.target.color
			end
		end
	end
end

freeslot("S_VEPH_VISUALGOOP")
states[S_VEPH_VISUALGOOP] = {SPR_GOOP, FF_TRANS50|FF_FULLBRIGHT|D, 1, A_VephVisualGoop, 0, 0, S_VEPH_VISUALGOOP}

local SpawnVisualGoop = function(mo, color)
	local thrust = P_SignedRandom()*FRACUNIT/6
	local angle = P_RandomFixed()*INT16_MAX * ((leveltime & 1) and 1 or -1)
	
	local thok = P_SpawnMobjFromMobj(mo, 
	P_ReturnThrustX(mo, angle, thrust),
	P_ReturnThrustY(mo, angle, thrust),
	FixedDiv(mo.height, mo.scale), MT_THOK)
	
	thok.target = mo
	thok.movefactor = FixedMul(thrust, mo.scale)
	thok.movedir = angle
	
	thok.spriteyoffset = $ + FixedDiv(mo.momz, mo.scale)
	
	thok.state = S_VEPH_VISUALGOOP
	thok.fuse = 9
	
	thok.threshold = color or 0
	thok.color = color or mo.color
	thok.colorized = true
end

local InSlide = function(player, stateonly)
	local mo = player.mo
	if not (mo and mo.valid and mo.health) return false end
	local dived = player.vephdived
	if stateonly == true then dived = false end
	if player.vephswim then return dived end
	return dived
	or mo.state == S_VEPH_SLIDE_UP
	or mo.state == S_VEPH_SLIDE_DIAUP
	or mo.state == S_VEPH_SLIDE_FRWD
	or mo.state == S_VEPH_SLIDE_DIADOWN
	or mo.state == S_VEPH_SLIDE_DOWN
	or mo.state == S_VEPH_DIVE
	or (player.vephswipe >= 3
	and (mo.state == S_VEPH_HOP
	or mo.state == S_VEPH_HOP_FINISH))
end

local DamageSwipe = function(player)
	return player.vephswipe and player.vephtimer < 12
	and (player.vephswipe != 2 or player.vephtimer >= 0)
end

//Command to disable Veph's splat effects
rawset(_G, "vephsplat", {})
vephsplat.value = false

//Command for setting the amount of goops from Slime Tail each player can have
rawset(_G, "vephgoopcap",
	CV_RegisterVar({
		name = "vephgoopcap",
		defaultvalue = 32,
		flags = CV_NETVAR|CV_SHOWMODIF,
		PossibleValue = CV_Unsigned
	})
)

//Command to disable Veph's swim abilities in competitive gametypes
rawset(_G, "vephfun",
	CV_RegisterVar({
		name = "vephfun",
		defaultvalue = "On",
		flags = CV_NETVAR|CV_SHOWMODIF,
		PossibleValue = CV_OnOff
	})
)

//Get the player's input angle
local function getinputangle(player)
	local mo = player.mo
	if mo and mo.valid
	and mo.skin == "veph" and player.vephswipe
	and not (player.cmd.forwardmove or player.cmd.sidemove)
		return player.vephswipedir2
	elseif (player.pflags & PF_DIRECTIONCHAR and player.pflags & PF_ANALOGMODE)
	or mo.flags2 & MF2_TWOD or twodlevel
		return mo.angle
	elseif not (player.cmd.forwardmove or player.cmd.sidemove)
		if mo.state == S_PLAY_SPRING
			return player.cmd.angleturn<<16
		else
			return player.drawangle
		end
	elseif player.awayviewmobj and player.awayviewmobj.valid
	and player.awayviewtics and mo and mo.valid
		return R_PointToAngle2(player.awayviewmobj.x, player.awayviewmobj.y, mo.x, mo.y)
		+ R_PointToAngle2(0, 0, player.cmd.forwardmove*FRACUNIT, -player.cmd.sidemove*FRACUNIT)
	else
		return player.cmd.angleturn<<16 + R_PointToAngle2(0, 0, player.cmd.forwardmove*FRACUNIT, -player.cmd.sidemove*FRACUNIT)
	end
end

//Spawns objects in a circle
local function vephcircle(mobj, mobjtype, amount, thrust, zoffset, scale, keepmom, color, vertical, vertangle, reverse)
	local splishmultiplier = false
	if vertangle == nil
		if mobj.player then vertangle = mobj.player.drawangle
		else vertangle = mobj.angle end
	end
	
	//Spawn them!
	for i = 0, (amount - 1)
		local angle = i*(ANGLE_180/(amount/2))
		if not vertical then angle = $ + vertangle end
		local mo = P_SpawnMobjFromMobj(mobj,0,0,zoffset,mobjtype)
		if not (mo and mo.valid) then continue end
		
		//Make water drops not instantly die
		if mo.type == MT_WATERDROP
			mo.flags = $ &~ MF_SPECIAL
			mo.flags2 = $ &~ MF2_OBJECTFLIP
			mo.eflags = $ &~ MFE_VERTICALFLIP
			mo.frame = $|TR_TRANS50
			mo.fuse = TICRATE
			
		//Stupid splish stuff
		elseif mo.type == MT_SPLISH
			if P_IsObjectOnGround(mobj)
				mo.stupidsticktowater = 1
			end
			mo.flags = $|MF_NOCLIPTHING&~MF_NOCLIP&~MF_SCENERY|MF_BOUNCE
			
			if vertical
				mo.renderflags = $ | RF_PAPERSPRITE
				mo.angle = vertangle - ANGLE_90
				mo.rollangle = angle
			else
				mo.rollangle = InvAngle(angle)
			end
			mo.spriteyoffset = $ - 16*FRACUNIT
			
			if not splishmultiplier
				splishmultiplier = true
				thrust = $*2
				scale = $*3/2
			end
			
			mo.color = WATERCOLOR
			mo.colorized = true
			
		//Turn the thok into a water effect
		elseif mo.type == MT_THOK
			if vertical
				mo.renderflags = $ | RF_PAPERSPRITE
				mo.angle = vertangle - ANGLE_90
			end
			
			mo.rollangle = angle
			mo.spritexscale = FRACUNIT/6
			mo.spriteyscale = mo.spritexscale
			
			mo.fuse = 10
			mo.tics = mo.fuse
			
			mo.sprite = SPR_VPPT
			mo.frame = $ | D
			
			if not splishmultiplier
				splishmultiplier = true
				thrust = $*3/2
			end
			
		//Ghost stars!
		elseif mo.type == MT_GHOST
			mo.state = S_INVISIBLE
			mo.sprite = SPR_VPPT
			mo.frame = FF_FULLBRIGHT|C
			mo.tics = 14
			
			mo.flags = mobjinfo[MT_THOK].flags &~ MF_NOGRAVITY
			mo.renderflags = $ | RF_FULLBRIGHT | RF_NOCOLORMAPS
			mo.color = SKINCOLOR_SUPERGOLD5
			mo.blendmode = AST_ADD
		end
		
		//Reverse gravity scaling fix
		local height = mo.height
		mo.scale = scale
		if mobj.eflags & MFE_VERTICALFLIP
			mo.z = $ - (mo.height-height)
		end
		
		//Set the color
		if color
			mo.color = color
			mo.colorized = true
		end
		
		//Thrust
		P_InstaThrust(mo, angle, thrust)
		if vertical
			mo.momz = mo.momx
			P_InstaThrust(mo, vertangle + ANGLE_90, mo.momy)
		end
		
		//Reverse
		if reverse
			local j = 0 while j < reverse
				P_RailThinker(mo)
				if not (mo and mo.valid) then break end
				j = $ + 1
			end
			if not (mo and mo.valid) then continue end
			
			mo.momx = -$
			mo.momy = -$
			mo.momz = -$
		end
		
		//Keep some momentum from the source object
		if keepmom == -1
			mo.momx = $ + mobj.momx*2/3
			mo.momy = $ + mobj.momy*2/3
			mo.momz = $ + P_GetMobjGravity(mobj)*8
		elseif keepmom
			if keepmom == true then keepmom = 1 end
			mo.momx = $ + mobj.momx/keepmom
			mo.momy = $ + mobj.momy/keepmom
			mo.momz = $ + mobj.momz/keepmom
		end
		
		//Random ghost movement
		if mo.type == MT_GHOST
			mo.momx = $ + P_RandomRange(-24, 24)*mo.scale/6
			mo.momy = $ + P_RandomRange(-24, 24)*mo.scale/6
			mo.momz = $ + P_RandomRange(2, 24)*mo.scale/3
			if not vertical P_SetObjectMomZ(mo, 4*FRACUNIT, true) end
		end
		
		//Make bubbles go up
		if mo.type == MT_SMALLBUBBLE or mo.type == MT_MEDIUMBUBBLE
			if mo.type == MT_SMALLBUBBLE
				mo.state = S_SPINDUST_BUBBLE1
			else
				mo.bubbleghost = true
				mo.fuse = TICRATE*2
			end
			P_SetObjectMomZ(mo, P_RandomByte()*P_RandomFixed()/128, true)
		end
	end
end

//Landing visuals
local VephLand = function(player)
	local mo = player.mo
	if mo.eflags & MFE_UNDERWATER
		vephcircle(mo, MT_MEDIUMBUBBLE, 16, 8*mo.scale, 0, mo.scale)
		local bubble = P_SpawnMobjFromMobj(mo, 0,0,0, MT_EXTRALARGEBUBBLE)
		bubble.bubbleghost = true
		bubble.fuse = TICRATE*2
		local ex = P_SpawnMobjFromMobj(mo, 0,0,0, MT_UWEXPLODE)
		if ex and ex.valid
			ex.scale = $/2
			S_StartSound(ex, sfx_bubbl1+VephRandom(0,4))
		end
	elseif (player.powers[pw_shield] & SH_NOSTACK) == SH_ELEMENTAL
	and not (mo.eflags & MFE_TOUCHWATER)
		P_ElementalFire(player, true)
		S_StartSound(mo, sfx_s3k47)
	else
		if vephsplat.value
			A_MultiShot(mo, (MT_VEPHSPLATSH<<16)+12, -32)
		else
			vephcircle(mo, MT_SPLISH, 16, 4*mo.scale, 0, mo.scale)
		end
		local splish = P_SpawnMobjFromMobj(mo, 0, 0, FRACUNIT*P_MobjFlip(mo), MT_SPLISH)
		splish.color = WATERCOLOR
		splish.colorized = true
		S_StartSound(mo,sfx_vplnd2)
	end
end

//Make bubbles ghost away
local BubbleGhost = function(mobj)
	if mobj.bubbleghost
		local ghost = P_SpawnGhostMobj(mobj)
		ghost.eflags = mobj.eflags
		ghost.state = mobj.state
		ghost.momx = mobj.momx
		ghost.momy = mobj.momy
		ghost.momz = mobj.momz
	end
end
addHook("MobjRemoved", BubbleGhost, MT_MEDIUMBUBBLE)
addHook("MobjRemoved", BubbleGhost, MT_EXTRALARGEBUBBLE)

//Stick the Splish objects from the slide move to the floor
addHook("MobjThinker", function(mobj)
	if mobj.stupidsticktowater
		if mobj.eflags & (MFE_TOUCHWATER|MFE_UNDERWATER)
			if mobj.eflags & MFE_VERTICALFLIP
				mobj.z = mobj.waterbottom - mobj.height
			else
				mobj.z = mobj.watertop
			end
		elseif mobj.stupidsticktowater == 2
			if (mobj.eflags & MFE_VERTICALFLIP)
				mobj.z = P_CeilingzAtPos(mobj.x, mobj.y, $, mobj.height) - mobj.height
			else
				mobj.z = P_FloorzAtPos(mobj.x, mobj.y, $, mobj.height)
			end
		end
	end
end, MT_SPLISH)

//Goop object freeslots
freeslot("MT_VEPH_GOOP", "MT_VEPH_SLIME",
"S_VEPH_GOOP1", "S_VEPH_GOOP2", "S_VEPH_GOOPSPLASH",
"S_VEPH_GOOPLAND1", "S_VEPH_GOOPLAND2", "SPR_VPGP")
states[S_VEPH_GOOP1] = {SPR_VPGP, A, 7, nil, 0, 0, S_VEPH_GOOP2}
states[S_VEPH_GOOP2] = {SPR_VPGP, B, -1, nil, 0, 0, S_VEPH_GOOP2}
states[S_VEPH_GOOPSPLASH] = {SPR_VPGP, C|FF_ANIMATE, 8, nil, 3, 2, S_NULL}
states[S_VEPH_GOOPLAND1] = {SPR_VPGP, G|FF_FLOORSPRITE, -1, A_CheckRandom, 2, S_VEPH_GOOPLAND2, S_NULL}
states[S_VEPH_GOOPLAND2] = {SPR_VPGP, H|FF_FLOORSPRITE, -1, nil, 0, 0, S_NULL}

//Define goop object
mobjinfo[MT_VEPH_GOOP] = {
	spawnstate = S_VEPH_GOOP1,
	meleestate = S_VEPH_GOOPLAND1,
	spawnhealth = 1000,
	speed = 12*FRACUNIT,
	radius = 16*FRACUNIT,
	height = 32*FRACUNIT,
	mass = DMG_WATER,
	damage = 1,
	flags = MF_MISSILE|MF_SLIDEME|MF_SCENERY,
}

//Define slime object
mobjinfo[MT_VEPH_SLIME] = {
	spawnstate = S_INVISIBLE,
	spawnhealth = 1000,
	reactiontime = SLIMETIME,
	radius = mobjinfo[MT_PLAYER].radius,
	height = mobjinfo[MT_PLAYER].height,
	dispoffset = 1,
	flags = MF_SCENERY|MF_NOGRAVITY|MF_NOBLOCKMAP|MF_NOCLIP|MF_NOCLIPHEIGHT
}

//Goop fuse
local GOOPFUSE = TICRATE*5
if srb2p
	GOOPFUSE = TICRATE*2
end

//Set the fuse and basic color of the goop when it spawns
addHook("MobjSpawn", function(mobj)
	mobj.fuse = GOOPFUSE
	mobj.name = "goop"
end, MT_VEPH_GOOP)

//Decrease goop number when removed
addHook("MobjRemoved", function(mobj)
	if mobj.target and mobj.target.valid and mobj.target.vephgoopnum
		mobj.target.vephgoopnum = $ - 1
	end
end, MT_VEPH_GOOP)

//Goop Thinker
//There's special behavior here for when Kirby uses this object
addHook("MobjThinker", function(mobj)
	//Spawn behavior after target has been set
	if mobj.fuse == GOOPFUSE and mobj.target and mobj.target.valid
		//Increase goop number
		mobj.target.vephgoopnum = $ and $ + 1 or 1
		
		//Color
		if mobj.target.player and mobj.target.vephwassuper
		and solchars["veph"] and solchars["veph"][1]
			mobj.color = solchars["veph"][1] + 4
			mobj.colorized = true
		elseif mobj.target.player and mobj.target.player.powers[pw_super]
		and skins[mobj.target.skin].supercolor
			mobj.color = skins[mobj.target.skin].supercolor + 4
		else
			mobj.color = mobj.target.color
		end
		
		//Affected by your momentum
		if not mobj.tracer
			mobj.momx = $ + mobj.target.momx
			mobj.momy = $ + mobj.target.momy
			mobj.momz = $ + mobj.target.momz
		end
		
		//Kirby stuff
		if mobj.threshold
			mobj.fuse = $/2
			mobj.flags = $ &~ MF_SLIDEME
			mobj.color = SKINCOLOR_SUPERSKY2
		end
	elseif mobj.target and mobj.target.valid
	and mobj.target.vephgoopnum and mobj.target.vephgoopnum > vephgoopcap.value
		mobj.fuse = 1
	end
	
	//No friction for the Kirby goop
	if mobj.threshold
		mobj.friction = FRACUNIT
	end
	
	//Hit the floor!
	if P_IsObjectOnGround(mobj)
	and (mobj.state == S_VEPH_GOOP1 or mobj.state == S_VEPH_GOOP2)
		//Splash effect
		local splash = P_SpawnMobjFromMobj(mobj, 0,0,0, MT_OVERLAY)
		if splash and splash.valid
			splash.target = mobj
			splash.state = S_VEPH_GOOPSPLASH
			splash.color = mobj.color
			splash.colorized = mobj.colorized
			splash.spritexscale = FRACUNIT*2
		end
		
		//Effect
		mobj.spritexscale = FRACUNIT*3
		S_StartSound(mobj, sfx_vpgop1+VephRandom(0,2))
		
		//Change state
		if vephsplat.value
			mobj.state = S_VEPH_GOOPLAND1
			mobj.spriteyscale = mobj.spritexscale
		else
			mobj.state = S_GOOP3
			mobj.colorized = true
		end
		
		//Make the non-Kirby one stop
		if not mobj.threshold
			A_ForceStop(mobj)
		end
		
	//Midair goop state
	elseif mobj.state == S_VEPH_GOOP1 or mobj.state == S_VEPH_GOOP2
		local squish = mobj.fuse*ANG20
		local momentum = FixedDiv(mobj.momz*P_MobjFlip(mobj)/32, mobj.scale)
		momentum = min(max($, INT16_MIN), INT16_MAX)
		mobj.spritexscale = FRACUNIT + sin(squish)/8 + momentum
		mobj.spriteyscale = FRACUNIT + cos(squish)/8 - momentum
		
		if not (mobj.fuse & 1)
			local trail = P_SpawnMobjFromMobj(mobj,0,0,0,MT_GOOPTRAIL)
			if trail and trail.valid
				trail.colorized = true
				trail.color = mobj.color
				trail.spritexscale = mobj.spritexscale
				trail.spriteyscale = mobj.spriteyscale
			end
		end
		
	//On ground
	elseif mobj.state == S_VEPH_GOOPLAND1 or mobj.state == S_VEPH_GOOPLAND2
	or mobj.state == S_GOOP3
		mobj.spritexscale = (($-FRACUNIT)*3/4)+FRACUNIT
		if mobj.frame & FF_FLOORSPRITE
			mobj.spriteyscale = mobj.spritexscale
		end
		
		//Trigger mobj collision while not moving
		if not mobj.threshold
			P_TryMove(mobj, mobj.x, mobj.y)
			if not (mobj and mobj.valid) then return end
			
		//Make the Kirby version slide around
		elseif (leveltime % 5) == 2
			S_StartSoundAtVolume(mobj, sfx_vpsld1+VephRandom(0,4), 64)
			local splash = P_SpawnMobjFromMobj(mobj, 0,0,0, MT_THOK)
			if splash and splash.valid
				splash.state = S_VEPH_GOOPSPLASH
				splash.color = mobj.color
				splash.colorized = mobj.colorized
			end
		end
	end
	
	//Fix vertical flip splat junk
	if mobj.frame & FF_FLOORSPRITE
		if not (mobj.renderflags & RF_SLOPESPLAT)
			mobj.renderflags = $ | RF_SLOPESPLAT | RF_NOSPLATBILLBOARD
			P_CreateFloorSpriteSlope(mobj)
		end
		
		if mobj.floorspriteslope and mobj.floorspriteslope.valid
			if mobj.standingslope
				mobj.floorspriteslope.zdelta = mobj.standingslope.zdelta
				mobj.floorspriteslope.xydirection = mobj.standingslope.xydirection
			else
				mobj.floorspriteslope.zdelta = 0
				mobj.floorspriteslope.xydirection = mobj.angle
			end
			
			mobj.floorspriteslope.o = {x = mobj.x, y = mobj.y,
			z = mobj.z + (P_MobjFlip(mobj) < 0 and mobj.height or 0)}
		end
	end
end, MT_VEPH_GOOP)

//Make the goop do a splash effect when it damages something
addHook("MobjDamage", function(target, mobj)
	if target and target.valid and mobj and mobj.valid
	and mobj.type == MT_VEPH_GOOP
		//Splash effect
		local splash = P_SpawnMobjFromMobj(mobj, 0,0,0, MT_THOK)
		if splash and splash.valid
			splash.state = S_VEPH_GOOPSPLASH
			splash.color = mobj.color
			splash.colorized = mobj.colorized
			splash.spritexscale = FRACUNIT*2
			S_StartSound(splash, sfx_vpgop1+VephRandom(0,2))
		end
		
		//Effect
		mobj.spritexscale = FRACUNIT*3
	end
end)

//Make goop make players slimey
local function MakeSlimey(mo, mobj, amount)
	local player = mo and mo.player
	if amount == 0 then return end
	
	//Add new slime or increase the old one
	if mo.vephslime and mo.vephslime.valid
		//Increase slime amount
		mo.vephslime.cusval = min($ + (amount or 1), 3)
		mo.vephslime.reactiontime = SLIMETIME
	else
		//Create new slime
		mo.vephslime = P_SpawnMobjFromMobj(mo, 0,0,0, MT_VEPH_SLIME)
		mo.vephslime.tracer = mo
		mo.vephslime.cusval = (amount and amount - 1) or 0
	end
	mo.vephslime.color = mobj.target and mobj.target.color or mobj.color
	player.vephslimeiframes = SLIMEIFRAMES //Add slime i-frames
	
	//Poison effect
	if CBW_Battle and CBW_Battle.BattleGametype()
	and not (gametyperules & GTR_FRIENDLY)
		S_StartSound(mo.vephslime, sfx_vpdebf)
		
		local poison = mo.vephpoison
		if not (poison and poison.valid)
			poison = P_SpawnMobjFromMobj(mo, 0,0,0, MT_OVERLAY)
			mo.vephpoison = poison
		end
		poison.state = S_VEPH_POISON
		poison.target = mo.vephslime
		
		poison.color = mo.vephslime.color
		poison.spritexscale = FRACUNIT*2/3
		poison.spriteyscale = poison.spritexscale
	end
end

addHook("ShouldDamage", function(mo, mobj)
	local player = mo and mo.player
	if not player or not (mobj and mobj.valid and mobj.type == MT_VEPH_GOOP) then return end
	if mobj.target == mo or not mobj.fuse or not mobj.color or player.isjettysyn then return false end
	
	//Not on the same team!
	if mobj.target and mobj.target.valid and mobj.target.player
	and not CV_FindVar("friendlyfire").value
	and ((G_GametypeHasTeams() and mobj.target.player.ctfteam == player.ctfteam)
	or (G_TagGametype() and (mobj.target.player.pflags & PF_TAGIT) == (player.pflags&PF_TAGIT)))
		return
	end
	
	//Splash effect
	local splash = P_SpawnMobjFromMobj(mobj, 0,0,0, MT_THOK)
	if splash and splash.valid
		splash.state = S_VEPH_GOOPSPLASH
		splash.color = mobj.color
		splash.colorized = mobj.colorized
		splash.spritexscale = FRACUNIT*2
		S_StartSound(splash, sfx_vpgop1+VephRandom(0,2))
	end
	
	//In BattleMod, kill the goop without affecting the touched player if
	//they're guarding, can't be damaged, or have slime i-frames
	if CBW_Battle and (CBW_Battle.GuardTrigger(mo, mobj, mobj.target, 1, 0)
	or not CBW_Battle.PlayerCanBeDamaged(player) or player.vephslimeiframes)
		P_RemoveMobj(mobj)
		return false
	end
	
	MakeSlimey(mo, mobj)
	
	//Kill the goop
	P_RemoveMobj(mobj)
	
	if CBW_Battle
		return false
	end
end, MT_PLAYER)

//Make the goop fade away when it despawns
addHook("MobjFuse", function(mobj)
	//Make the ghost match the slope of the goop
	if mobj.frame & FF_FLOORSPRITE
	and mobj.floorspriteslope and mobj.floorspriteslope.valid
		ghost.renderflags = $ | RF_SLOPESPLAT | RF_NOSPLATBILLBOARD
		P_CreateFloorSpriteSlope(ghost)
		if ghost.floorspriteslope and ghost.floorspriteslope.valid
			ghost.floorspriteslope.o = {
				x = mobj.floorspriteslope.o.x,
				y = mobj.floorspriteslope.o.y,
				z = mobj.floorspriteslope.o.z
			}
			ghost.floorspriteslope.xydirection = mobj.floorspriteslope.xydirection
			ghost.floorspriteslope.zdelta = mobj.floorspriteslope.zdelta
		end
	end
end, MT_VEPH_GOOP)

//Slime on players
addHook("MobjThinker", function(mobj)
	//Give some leeway before applying effects
	if mobj.threshold < 5
		mobj.threshold = $ + 1
		return
	end
	
	if mobj.tracer.player.playerstate ~= PST_LIVE
		mobj.tracer.player.vephslimeiframes = 0
	end
	
	local mo = mobj.tracer
	local player = mo and mo.valid and mo.player
	local def = mobj.hnext
	
	//Decrease timer
	mobj.reactiontime = min($ - 1, SLIMETIME)
	if not mobj.reactiontime then P_RemoveMobj(mobj) return end
	
	//Follow player
	A_CapeChase(mobj, 1)
	if not (mobj and mobj.valid)
		if def and def.valid
			def.fuse = 8
		end
		return
	end
	
	//Tumble angle
	if player and player.tumble and player.tumble > 0
		mobj.angle = mo.angle + player.airdodge_spin + ANGLE_45
	end
	
	//Defensive indicator
	if CBW_Battle and CBW_Battle.BattleGametype()
	and not (gametyperules & GTR_FRIENDLY) and mobj.cusval
		if not (def and def.valid)
			def = P_SpawnMobjFromMobj(mobj, 0,0,0, MT_THOK)
			def.target = mobj
			def.flags2 = $ | MF2_BOSSNOTRAP
			def.dispoffset = mobj.dispoffset + 1
			def.tics = -1
			
			def.spritexscale = FRACUNIT/2
			def.spriteyscale = def.spritexscale
			
			mobj.hnext = def
		end
		def.sprite = SPR_VPPT
		def.frame = E + mobj.cusval - 1
		def.fuse = mobj.reactiontime
		def.color = mobj.color
		if player.vephslimeiframes
			def.colorized = not (player.vephslimeiframes & 1)
		end
		
		def.spritexoffset = -FixedDiv(mo.radius, mo.scale)
		def.spriteyoffset = FixedDiv(mo.height, mo.scale)
		def.spritexoffset = FixedDiv($, def.spritexscale)
		def.spriteyoffset = FixedDiv($, def.spriteyscale)
		def.spriteyoffset = $ + sin(def.fuse*ANG10)*4
		
		A_CapeChase(def)
	end
	
	//Spawn visual goop
	SpawnVisualGoop(mo, mobj.color)
	
	//Set visuals to match player
	mobj.skin = mo.skin
	mobj.colorized = true
	mobj.scale = mo.scale
	mobj.radius = mo.radius
	mobj.height = mo.height
	
	mobj.rollangle = mo.rollangle
	mobj.mirrored = mo.mirrored
	mobj.spritexscale = mo.spritexscale
	mobj.spriteyscale = mo.spriteyscale
	mobj.spritexoffset = mo.spritexoffset
	mobj.spriteyoffset = mo.spriteyoffset
	mobj.renderflags = mo.renderflags
	mobj.flags2 = (mo.flags2 & (MF2_DONTDRAW|MF2_SPLAT)) // | MF2_LINKDRAW
	
	mobj.state = mo.state
	mobj.tics = -1
	mobj.sprite2 = mo.sprite2
	mobj.frame = mo.frame &~ FF_BLENDMASK
	
	//Set transparency
	local trans = ease.linear(mobj.reactiontime*FRACUNIT/SLIMETIME, NUMTRANSMAPS - 1, 0)
	if trans
		if trans >= 10
			mobj.flags2 = $ | MF2_DONTDRAW
		else
			mobj.frame = ($ &~ FF_TRANSMASK) | (trans << FF_TRANSSHIFT)
		end
	end
	
	if mo.player.vephslimeiframes
		mo.player.vephslimeiframes = $ - 1
	end
end, MT_VEPH_SLIME)

//Bubble
freeslot("MT_VEPH_BUBBLE", "S_VEPH_BUBBLE", "S_VEPH_POISON", "SPR_VPBB")
mobjinfo[MT_VEPH_BUBBLE] = {
	spawnstate = S_INVISIBLE,
	seestate = S_VEPH_BUBBLE,
	deathstate = S_VEPH_BUBBLE,
	xdeathstate = S_BIGMINE_BLAST5,
	seesound = sfx_vpbubl,
	deathsound = sfx_vpbrst,
	//activesound = sfx_s3k44,
	spawnhealth = 1000,
	reactiontime = TICRATE*3,
	mass = TICRATE/4,
	speed = 12*FRACUNIT,
	radius = 64*FRACUNIT,
	height = 128*FRACUNIT,
	flags = MF_SPECIAL|MF_BOUNCE|MF_GRENADEBOUNCE|MF_NOGRAVITY,
}
states[S_VEPH_BUBBLE] = {SPR_VPBB, FF_ANIMATE|FF_ADD, -1, nil, P, 3, S_NULL}
states[S_VEPH_POISON] = {SPR_VPBB, R|FF_ANIMATE|FF_ADD, 15*3, nil, 14, 3, S_NULL}

//Explode bubble on touching a player
addHook("TouchSpecial", function(mobj, mo)
	local player = mo and mo.player
	if not CBW_Battle or not player or player.isjettysyn
	or not mobj.health or not mobj.reactiontime or mobj.threshold <= 1
	or not (mobj.target and mobj.target.valid and mobj.target.player)
	then return true end
	
	//Friendly players bounce off
	if mobj.target == mo or CBW_Battle.MyTeam(mo, mobj.target)
		if mobj.destscale != mobj.scale or mobj.tracer
		or P_IsObjectOnGround(mo) or mo.momz*P_MobjFlip(mo) >= 0
		or not (player.cmd.buttons & BT_SPIN)
		then return true end
		
		mobj.tracer = mo
		mo.tracer = mobj
		S_StartSound(mo, sfx_vpboin)
		
		mobj.movecount = 0
		P_ResetPlayer(player)
		player.powers[pw_carry] = CR_BRAKGOOP
		
	//Parried by enemy player
	elseif CBW_Battle.GuardTrigger(mo, mobj, mobj.target, 1, 0)
		mobj.extravalue1 = 1 //Don't spawn goop or tumble
		P_KillMobj(mobj)
		
	//Enemy players get exploded
	elseif CBW_Battle.PlayerCanBeDamaged(player)
		CBW_Battle.DoPlayerTumble(player, BUBBLETUMBLE,
		R_PointToAngle2(mobj.x, mobj.y, mo.x, mo.y),
		FixedMul(mobj.info.speed, mo.scale), true)
		
		MakeSlimey(mo, mobj, BUBBLEINCREASE)
		P_KillMobj(mobj)
	end
	return true
end, MT_VEPH_BUBBLE)

//Bubble thinker
addHook("MobjThinker", function(mobj)
	if mobj.state == mobj.info.xdeathstate then return end
	mobj.friction = FRACUNIT
	
	local mo = mobj.tracer
	local player = mo and mo.valid and mo.player
	
	//Spawn stuff
	if mobj.threshold <= 1
		mobj.threshold = $ + 1
		if mobj.threshold == 1
			mobj.shadowscale = FRACUNIT/2
			mobj.scalespeed = FixedMul($, mobj.scale)
			P_SetScale(mobj, mobj.scale/4)
			A_PlaySeeSound(mobj)
			return
		else
			mobj.movefactor = FixedMul(mobj.info.speed, mobj.scale)
			P_InstaThrust(mobj, mobj.angle, mobj.movefactor)
		end
		mobj.state = mobj.info.seestate
	end
	
	//Explode when crushed
	if mobj.ceilingz - mobj.floorz <= mobj.height then P_KillMobj(mobj) end
	
	//Alive behavior
	if mobj.reactiontime and mobj.health
		//Player bounce behavior
		if player
			if not (player.powers[pw_carry] == CR_BRAKGOOP and mo.tracer == mobj)
				mobj.tracer = nil
				mobj.spritexscale = FRACUNIT
				mobj.spriteyscale = FRACUNIT
				player.powers[pw_nocontrol] = 0
			else
				mobj.movecount = $ + 1
				if mobj.movecount >= 10
					P_ResetPlayer(player)
					player.powers[pw_carry] = 0
					player.powers[pw_nocontrol] = 0
					mo.tracer = nil
					
					P_InstaThrust(mo, player.drawangle, 12*mo.scale)
					P_DoJump(player)
					mo.momz = $*4/3
					
					mobj.spritexscale = FRACUNIT
					mobj.spriteyscale = FRACUNIT
					
					mobj.tracer = nil
				else
					A_ForceStop(mo)
					
					local angle = mobj.movecount*ANGLE_22h + ANGLE_180
					mobj.spritexscale = FRACUNIT - sin(angle)/2
					mobj.spriteyscale = FRACUNIT + sin(angle)/2
					
					local offset = FixedMul(mobj.info.height, mobj.spriteyscale)
					offset = ($ >> FRACBITS) << FRACBITS
					A_CapeChase(mo, 1 + offset)
				end
			end
		end
		
		P_InstaThrust(mobj, R_PointToAngle2(0,0, mobj.momx, mobj.momy),
		mobj.movefactor)
		
		mobj.movefactor = FixedMul(mobj.info.speed, mobj.scale)
		mobj.movefactor = $*mobj.reactiontime/mobj.info.reactiontime
		
		mobj.reactiontime = $ - 1
		if not mobj.reactiontime
			P_KillMobj(mobj)
		end
		return
	end
		
	//Death behavior
	mobj.cusval = $ + 1
	if mobj.cusval == 1 then A_Scream(mobj) end
	if player
		if (player.powers[pw_carry] == CR_BRAKGOOP and mo.tracer == mobj)
			P_ResetPlayer(player)
			player.powers[pw_carry] = 0
			mo.tracer = nil
		end
		player.powers[pw_nocontrol] = 0
		mobj.tracer = nil
	end
	
	//Timer ran out!
	local mass = mobj.info.mass
	if mobj.cusval >= mass
		//Goop burst
		if not mobj.extravalue1
			for i = 1, 8
				for j = 1, 8
					local goop = P_SPMAngle(mobj, MT_VEPH_GOOP, mobj.angle + ANGLE_45*j + ANG1*j*i)
					if goop and goop.valid
						goop.tracer = mobj
						goop.target = mobj.target
						goop.color = mobj.color
						goop.momz = goop.momx
						P_InstaThrust(goop, mobj.angle + ANGLE_45*i + ANG1*j*i, goop.momy/2)
					end
				end
			end
		end
		
		//Ring effect
		local thok = P_SpawnMobjFromMobj(mobj, 0,0,0, MT_THOK)
		thok.spritexscale = mobj.spritexscale
		thok.spriteyscale = mobj.spriteyscale
		thok.scalespeed = mobj.scalespeed*2
		thok.destscale = thok.scale*8
		
		thok.fuse = thok.tics
		thok.sprite = mobj.sprite
		thok.frame = (states[mobj.state].var1 + 1) | (mobj.frame &~ FF_FRAMEMASK)
		
		//Die
		mobj.state = mobj.info.xdeathstate
		return
	end
	
	//Tumble nearby players while exploding
	if not mobj.extravalue1
		for player in players.iterate
			local mo = player.mo
			if not (mo and mo.valid) or not CBW_Battle or mobj.target == mo
			or (player.tumble and player.tumble > 0) or player.isjettysyn
			or R_PointToDist2(mobj.x, mobj.y, mo.x, mo.y) > mobj.radius + mo.radius
			or mo.z > mobj.z + mobj.height or mo.z + mo.height < mobj.z
			or not (mobj.target and mobj.target.valid
			and mobj.target.player and not CBW_Battle.MyTeam(mo, mobj.target))
			or CBW_Battle.GuardTrigger(mo, mobj, mobj.target, 1, 0)
			or not CBW_Battle.PlayerCanBeDamaged(player)
			then continue end
			
			CBW_Battle.DoPlayerTumble(player, BUBBLETUMBLE,
			R_PointToAngle2(mobj.x, mobj.y, mo.x, mo.y),
			FixedMul(mobj.info.speed, mo.scale), true)
			
			MakeSlimey(mo, mobj, BUBBLEINCREASE)
		end
	end
	
	//Increase visual scale
	mobj.spritexscale = FRACUNIT + ease.outcubic(mobj.cusval*FRACUNIT/mass, FRACUNIT/2)
	mobj.spriteyscale = mobj.spritexscale
	mobj.shadowscale = FixedMul(mobj.spritexscale, FRACUNIT/2)
end, MT_VEPH_BUBBLE)

//Put goggles on Veph's signpost if we're underwater
function A_SignPlayer(mobj, var1, var2)
	super(mobj, var1, var2)
	
	local mo = mobj.target
	local player = mo and mo.valid and mo.player
	if not player or not (mo.eflags & MFE_UNDERWATER) then return end
	
	local ov = mobj.tracer and mobj.tracer.valid and mobj.tracer.tracer
	if ov and ov.valid and ov.skin == "veph" and ov.tics != -1
		ov.sprite2 = $ | FF_SPR2SUPER
		ov.tics = -1
	end
end

//Destroy spikes via attacks
local waterspike = function(thing, tmthing)
	if not (thing and thing.valid and tmthing and tmthing.valid) return end
	if ((tmthing.player and tmthing.skin == "veph"
	and ((tmthing.player.vephswipe and tmthing.player.vephswipe < 3 and tmthing.player.vephtimer < 12)
	or (InSlide(tmthing.player) and tmthing.player.waterdrive)))
	or tmthing.type == MT_VEPH_GOOP)
	and tmthing.z >= thing.z-tmthing.height and tmthing.z <= thing.z+thing.height+tmthing.height
		P_KillMobj(thing, tmthing)
		return true
	end
end
addHook("MobjCollide", function(thing, tmthing) waterspike(thing, tmthing) end, MT_SPIKE)
addHook("MobjCollide", function(thing, tmthing) waterspike(thing, tmthing) end, MT_WALLSPIKE)

//Damage during the tail swipe and dolphin dive
addHook("PlayerCanDamage", function(player, mobj)
	if player.mo and player.mo.valid and player.mo.skin == "veph"
		if DamageSwipe(player)
		or InSlide(player) or player.mo.state == S_VEPH_HOP
			return true
		end
	end
end)

//Water effect when damaging enemies as Veph
addHook("MobjDamage", function(target, inf, src, dmg, dmgtype)
	if (not dmgtype or dmgtype == DMG_WATER)
	and target and target.valid and inf and inf.valid and inf.player
	and not inf.player.vephswipe and inf.skin == "veph" and src == inf
	and (InSlide(inf.player) or inf.vephwassuper)
		if P_IsObjectOnGround(inf) or not InSlide(inf.player)
		or (inf.player.vephdived and (inf.player.vephtimer
		or inf.player.vephbouncemomz*P_MobjFlip(inf) > 0))
			if target.eflags & MFE_UNDERWATER
				vephcircle(target, MT_MEDIUMBUBBLE, 16, 8*target.scale, 0, target.scale)
				local ex = P_SpawnMobjFromMobj(target, 0,0,0, MT_UWEXPLODE)
				if ex and ex.valid
					ex.scale = $/2
					S_StartSound(ex, sfx_bubbl1+VephRandom(0,4))
				end
			else
				S_StartSound(inf, sfx_splish)
			end
		elseif not inf.player.waterdrive
			inf.player.vephdived = true
			inf.player.vephtimer = -1
			inf.player.vephswipe = 0
			inf.player.vephgoops = {}
			inf.player.vephbouncemomz = inf.momz*3/2
			inf.momz = -P_GetMobjGravity(inf)
			if not (target.eflags & MFE_UNDERWATER)
				S_StartSound(inf, sfx_splish)
			end
		end
		
		if inf.vephwassuper then inf.vephhitground = -1 end
	end
end)

//Same code as above but for monitors??? How dumb is that
addHook("MobjDeath", function(target, inf, src)
	if (not dmgtype or dmgtype == DMG_WATER)
	and target and target.valid and target.flags & MF_MONITOR and inf and inf.valid and inf.player
	and not inf.player.vephswipe and inf.skin == "veph" and src == inf
	and (InSlide(inf.player) or inf.vephwassuper)
		if P_IsObjectOnGround(inf) or not InSlide(inf.player)
			if target.eflags & MFE_UNDERWATER
				vephcircle(target, MT_MEDIUMBUBBLE, 16, 8*target.scale, 0, target.scale)
				local ex = P_SpawnMobjFromMobj(target, 0,0,0, MT_UWEXPLODE)
				if ex and ex.valid
					ex.scale = $/2
					S_StartSound(ex, sfx_bubbl1+VephRandom(0,4))
				end
			else
				S_StartSound(inf, sfx_splish)
			end
		elseif not (inf.player.vephdived and inf.player.vephtimer)
			inf.player.vephdived = true
			inf.player.vephtimer = -1
			inf.player.vephswipe = 0
			inf.player.vephgoops = {}
			inf.player.vephbouncemomz = inf.momz*3/2
			inf.momz = -P_GetMobjGravity(inf)
			if not (target.eflags & MFE_UNDERWATER)
				S_StartSound(inf, sfx_splish)
			end
		end
		
		if inf.vephwassuper then inf.vephhitground = -1 end
	end
end)

//This guy can't breathe in those giant bubbles
addHook("TouchSpecial", function(special, toucher)
	if not (special and special.valid and toucher and toucher.valid and toucher.player) return end
	if toucher.skin == "veph" then
		return true
	end
end, MT_EXTRALARGEBUBBLE)

//Jump button stuff
addHook("JumpSpecial", function(player)
	local mo = player.mo
	if not (mo and mo.valid and mo.skin == "veph") then return end
	
	//Allow diving out of using shields
	if player.pflags & PF_JUMPED and player.pflags & PF_SHIELDABILITY
	and player.vephdived and not (player.pflags & PF_JUMPDOWN) and not PSO
	and (not (player.pflags & PF_THOKKED) or mo.eflags & MFE_UNDERWATER)
		player.pflags = $ &~ PF_SHIELDABILITY
	end
	
	//Prevent jumping out of the dive before you land
	if player.vephdived and (player.vephtimer
	or mo.eflags & MFE_JUSTHITFLOOR or P_IsObjectOnGround(mo))
		return true
	end
end)

//He's impervious to water damage and lava while sliding
addHook("ShouldDamage", function(target, inflictor, source, damage, damagetype)
	if not (target and target.valid and target.player
	and target.skin == "veph" and not PSO) then return end
	if (target.player.waterdrive or InSlide(target.player) or target.vephwassuper
	or (target.player.vephswipe and target.player.vephswipe >= 3))
	and damagetype == DMG_FIRE and not (inflictor and inflictor.valid)
	and not (target.eflags & MFE_UNDERWATER)
		if not (leveltime%5)
			S_StartSoundAtVolume(target, sfx_s3k4b, 96)
		end
		local smoke = P_SpawnMobjFromMobj(target,50*(P_RandomFixed()-FRACUNIT/2),
		50*(P_RandomFixed()-FRACUNIT/2),0,MT_SMOKE)
		P_SetObjectMomZ(smoke, 8*(P_RandomFixed()-FRACUNIT/2), false)
		return false
	elseif damagetype == DMG_WATER
		return false
	end
end, MT_PLAYER)

//Did you know that electricity and water are dangerous together?
addHook("MobjDamage", function(target, inflictor, source, damage, damagetype)
	if target and target.valid and target.player and target.skin == "veph"
	and not target.player.powers[pw_shield] and damagetype == DMG_ELECTRIC
	and not (inflictor and inflictor.valid and inflictor.player)
	and not (source and source.valid and source.player)
	and not PSO
		if target.player.rings
			target.player.vephelectric = target.player.rings
			P_GivePlayerRings(target.player, min(-target.player.vephelectric*5/TICRATE, -1))
			S_StartSound(target, sfx_antiri)
		else
			target.player.vephelectric = -1
		end
		target.state = S_PLAY_STUN
		target.player.powers[pw_nocontrol] = TICRATE
		S_StartSound(target, sfx_vpfizz)
		target.player.rings = 0
		target.player.powers[pw_shield] = SH_PITY
	end
end, MT_PLAYER)

//Wall Breaker Function
local wallbreak = function(mobj, sectorthing)
	local nerds = false
	for fof in sectorthing.ffloors()
		if fof.valid and (fof.flags & FF_BUSTUP) and (fof.flags & FF_EXISTS)
			local foffloor = fof.topheight
			local fofceiling = fof.bottomheight
			if fof.b_slope and fof.b_slope.valid
				fofceiling = P_GetZAt(fof.b_slope, mobj.x, mobj.y)
			end
			if fof.t_slope and fof.t_slope.valid
				foffloor = P_GetZAt(fof.t_slope, mobj.x, mobj.y)
			end
			if foffloor >= mobj.z and fofceiling <= mobj.z+mobj.height
				EV_CrumbleChain(nil, fof)
				if fof.master.flags & ML_EFFECT5
					P_LinedefExecute(P_AproxDistance(fof.master.dx, fof.master.dy)>>FRACBITS, mobj, fof.target)
				end
				return true
			end
		end
	end
end

//Wall Breaker
addHook("MobjLineCollide", function(mo, line)
	if not (line and line.valid and mo and mo.valid
	and mo.player and mo.skin == "veph" and InSlide(mo.player)
	and ((not P_IsObjectOnGround(mo) and mo.player.pflags & PF_JUMPED
	and mo.player.pflags & PF_THOKKED) or mo.player.waterdrive)) return end
	local killone = false
	local killtwo = false
	if line.frontsector and line.frontsector.valid then killone = wallbreak(mo, line.frontsector) end
	if line.backsector and line.backsector.valid then killtwo = wallbreak(mo, line.backsector) end
	if killone or killtwo
		mo.player.vephsquish = SQUISHTIME*4/3
		
		vephcircle(mo, MT_GHOST, 8, 4*mo.scale, mo.player.height/2,
		mo.scale/2, false, nil, true, mo.player.drawangle)
		S_StartSound(mo,sfx_vpbonk)
		
		if not mo.player.waterdrive
			P_BounceMove(mo)
		end
		
		if mo.player.vephswipe >= 3
			mo.player.vephswipedir = R_PointToAngle2(0,0, mo.momx, mo.momy)
		end
		
		return false
	end
end, MT_PLAYER)

//Bounce off walls when sliding or diving
addHook("MobjMoveBlocked", function(mo)
	local player = mo and mo.valid and mo.skin == "veph" and mo.player 
	if player
	and (InSlide(player) or DamageSwipe(player))
	and player.speed > mo.scale*2 and not player.powers[pw_justsprung]
		local oldmomx = mo.momx
		local oldmomy = mo.momy
		
		P_BounceMove(mo)
		if player.vephswipe >= 3
			player.vephswipedir = R_PointToAngle2(0,0, mo.momx, mo.momy)
		end
		
		player.dumbbouncex = mo.momx
		player.dumbbouncey = mo.momy
		
		mo.momx = oldmomx
		mo.momy = oldmomy
	end
end, MT_PLAYER)

//Dive starter
addHook("AbilitySpecial", function(player)
	local mo = player.mo
	if not (mo and mo.valid) or mo.skin ~= "veph"
	or DamageSwipe(player) or player.actionstate == 1
	or player.vephswim or (player.pflags & PF_THOKKED
	and not (mo.eflags & MFE_UNDERWATER and player.vephdived))
	or player.gotflag or player.gotcrystal or player.gotflagdebuff or PSO return end
	
	player.waterdrive = 0
	//player.vephjetstream = false
	player.vephcharge = 0
	player.vephswipe = 0
	player.vephtimer = 0
	mo.rollangle = 0
	
	if player.pflags & PF_THOKKED
	and mo.eflags & MFE_UNDERWATER and player.vephdived
	and not (player.gotflag or player.gotcrystal or player.gotflagdebuff)
	and (vephfun.value or gametyperules & GTR_FRIENDLY)
		player.vephswim = 1
		player.vephdived = false
		player.pflags = $ &~ PF_SPINNING &~ PF_THOKKED &~ PF_SHIELDABILITY
		mo.state = S_VEPH_SWIM_STOP
		mo.momz = 0
		return
	end
	
	player.vephdived = true
	S_StartSound(mo,sfx_vpdive)
	player.pflags = $ | PF_JUMPED | PF_NOJUMPDAMAGE | PF_THOKKED | PF_SPINNING
	mo.state = S_VEPH_DIVE
	player.panim = PA_ROLL
	
	local minute = min(-16*FRACUNIT, FixedDiv(mo.momz, mo.scale)*P_MobjFlip(mo))
	P_SetObjectMomZ(mo, min(FixedDiv(player.speed, mo.scale)/-3, minute), false)
	
	local angle = getinputangle(player)
	local factor = FixedDiv(player.mindash, player.maxdash)
	if mo.vephwassuper then factor = $*3/2 end
	local thrust = FixedHypot(player.cmd.forwardmove*FRACUNIT, player.cmd.sidemove*FRACUNIT)
	if thrust >= 49*FRACUNIT then thrust = 50*FRACUNIT end
	if not (vephfun.value or gametyperules & GTR_FRIENDLY)
	and mo.eflags & MFE_UNDERWATER
		thrust = $/2
	end
	thrust = FixedMul(mo.scale, FixedMul(thrust, factor))
	
	local oldspeed = FixedHypot(mo.momx, mo.momy)
	P_Thrust(mo, angle, thrust)
	local newspeed = FixedHypot(mo.momx, mo.momy)
	
	if CBW_Battle
		local actionspd = FixedMul(player.actionspd, mo.scale)
		if not (vephfun.value or gametyperules & GTR_FRIENDLY)
		and mo.eflags & MFE_UNDERWATER
			actionspd = $/2
		end
	
		oldspeed = max($, actionspd)
		if newspeed > max(oldspeed, actionspd)
			P_InstaThrust(mo, R_PointToAngle2(0,0, mo.momx, mo.momy), oldspeed)
		end
	end
	
	if newspeed > FixedMul(player.normalspeed/4, mo.scale)
		vephcircle(mo, mo.eflags & MFE_UNDERWATER and MT_MEDIUMBUBBLE or MT_THOK,
		12, 4*mo.scale, player.spinheight/2, mo.scale,
		2, 0, true, player.drawangle)
	end
	
	if (player.powers[pw_shield] & SH_NOSTACK) == SH_BUBBLEWRAP
		S_StartSound(mo, sfx_s3k44)
		player.pflags = $ | PF_SHIELDABILITY
	elseif (player.powers[pw_shield] & SH_NOSTACK) == SH_ELEMENTAL
	or  (player.powers[pw_shield] & SH_NOSTACK) == SH_FLAMEAURA
		S_StartSound(mo, sfx_s3k43)
		player.pflags = $ | PF_SHIELDABILITY
	end
	
	player.vephsquish = -SQUISHTIME
end)

addHook("SpinSpecial", function(player)
	local mo = player.mo
	if not (mo and mo.valid)
	or mo.skin ~= "veph"
	or (srb2p and not InSlide(player))
	or (player.vephsprung and not player.vephdived)
	//or (player.vephswipe and not (player.vephswipe == 1
	//and P_IsObjectOnGround(mo) and not (player.pflags & PF_SPINDOWN)))
	or (player.vephswipe and not (player.vephswipe < 3 and player.pflags & PF_JUMPED
	and not player.gotflag and not player.gotcrystal and not player.gotflagdebuff
	and (vephfun.value or gametyperules & GTR_FRIENDLY)
	and player.vephtimer < 12 and mo.eflags & MFE_UNDERWATER))
	or player.vephcharge
	or (player.vephdived and P_IsObjectOnGround(mo))
	or player.homing
	or P_SuperReady(player)
	or P_PlayerInPain(player)
	or player.pflags & PF_SLIDING
	or player.exiting
	or player.powers[pw_carry]
	or player.spectator
	or player.playerstate
	or not mo.health
	//or (player.panim == PA_PAIN and not (player.pflags & PF_JUMPED))
	or player.powers[pw_super] == 1
	or player.iseggrobo
	or player.isjettysyn
	or player.guard
	or player.tumble
	or player.actionstate == 1
	or player.powers[pw_nocontrol] > 0
	or (player.isxmomentum and mo.state == S_PLAY_FACEPLANT)
	or PSO
		if not player.vephswipe
			player.vephchargable = nil
		end
	return end
	
	local inputangle = getinputangle(player)
	if srb2p
		mo.P_inputs[BT_SPIN] = 2
	end
	
	//Start a spin button move based on different circumstances
	if not (player.pflags & PF_SPINDOWN)
		local dumbgravity = P_GetMobjGravity(mo)
		if mo.eflags & MFE_GOOWATER and not (mo.eflags & MFE_UNDERWATER)
			dumbgravity = -$
		end
		if player.vephwaterswitch
			dumbgravity = mo.scale*2/-5*P_MobjFlip(mo)
		end
		dumbgravity = max(min($,mo.scale/2),mo.scale/-2)
		
		//Swim actions
		if player.vephswim or (((player.vephswipe and player.vephswipe < 3)
		or player.vephdoublespin < 0 and player.vephdoublespin >= -5)
		and player.pflags & PF_JUMPED and not player.gotflag
		and not player.gotcrystal and not player.gotflagdebuff
		and (vephfun.value or gametyperules & GTR_FRIENDLY)
		and player.vephtimer < 12 and mo.eflags & MFE_UNDERWATER)
			//Twirl
			if not (player.vephdoublespin < 0 and player.vephdoublespin >= -5)
			or not player.vephswim
				//Start Swim
				if not player.vephswim
					player.vephswim = -1
					player.vephswimspeed = FixedHypot(mo.momx, mo.momy)
					player.vephswipe = 0
					player.vephtimer = 0
					player.vephdived = false
					player.pflags = $ &~ PF_SPINNING &~ PF_THOKKED &~ PF_SHIELDABILITY
					mo.momz = 0
				end
				
				local watersurface = mo.watertop
				if mo.eflags & MFE_VERTICALFLIP
					watersurface = mo.waterbottom
				end
				local atsurface = abs(watersurface-mo.z) < mo.height
				
				if atsurface
					S_StartSound(mo, sfx_vptwr2)
					P_SpawnMobjFromMobj(mo, 0, 0, watersurface-mo.z, MT_SPLISH)
				else
					S_StartSound(mo, sfx_vptwr1)
				end
				player.vephswimspeed = $ + max(mo.scale*16 - $/2, 0)
				mo.state = S_VEPH_HOP
				
			//Cancel (Double Tap)
			else
				player.vephswim = 0
				if not P_IsObjectOnGround(mo)
					player.glidetime = max($, 1)
				end
				S_StartSound(mo, sfx_vpcanc)
				mo.state = S_VEPH_JUMP
			end
			
		//No spamming!
		elseif player.glidetime and CBW_Battle
			return
			
		//Regular actions
		elseif not InSlide(player) or not P_IsObjectOnGround(mo)
			local dived = player.vephdived
			player.vephdived = false
			player.waterdrive = 0
			player.vephtimer = 0
			player.vephchargable = nil
			player.dumbbouncex = nil
			player.dumbbouncey = nil
			
			if not P_IsObjectOnGround(mo)
				player.pflags = $ | PF_JUMPED | PF_NOJUMPDAMAGE
				if dived
					player.pflags = $ &~ PF_THOKKED 
				end
			end
			player.pflags = $ &~ PF_SPINNING
			
			if mo.vephwassuper
				player.vephsquish = SQUISHTIME*-4/3
			else
				player.vephsquish = SQUISHTIME*-2/3
			end
			
			//Dive cancel
			if player.vephsprung and dived
				S_StartSound(mo, sfx_vpcanc)
				mo.state = S_VEPH_JUMP
				
			//Tail Swipe aka Slime Tail
			else
				player.vephchargable = true
				player.vephgoops = {}
				
				//Vertical swipe in BattleMod
				if player.vephsprung or CBW_Battle
					player.vephswipe = 2
					mo.state = S_VEPH_VSWIPE1
					mo.tics = $*3/2
					player.vephtimer = $ - mo.tics
					player.drawangle = mo.angle
					
					mo.momx = $*2/3
					mo.momy = $*2/3
					
				//Horizontal swipe
				else
					player.vephswipe = 1
					mo.state = S_PLAY_MELEE_LANDING
					player.drawangle = inputangle
					S_StartSoundAtVolume(mo, sfx_vptail, 192)
				end
				
				if P_IsObjectOnGround(mo) and player.cmd.buttons & BT_JUMP
				and not (player.pflags & PF_JUMPDOWN)
					player.swipecancel = dumbgravity*-5
					mo.z = $ + P_MobjFlip(mo)
				elseif P_IsObjectOnGround(mo) and player.vephswipe != 2
					player.swipecancel = nil
					mo.momz = $ + dumbgravity*-6
					mo.z = $ + P_MobjFlip(mo)
				elseif player.vephsprung
					player.swipecancel = nil
				elseif not player.glidetime and not P_IsObjectOnGround(mo)
					player.swipecancel = dumbgravity*-18
				else
					player.swipecancel = dumbgravity*-6
				end
				
				if (player.gotflag or player.gotcrystal or player.gotflagdebuff)
				and player.swipecancel
					player.swipecancel = mo.scale
					player.glidetime = max($, 1)
				end
				
				player.vephswipedir = player.drawangle
				player.vephswipedir2 = player.drawangle
			end
			
		//Slide Jump
		else
			player.vephtimer = 0
			player.vephswipe = 3
			player.vephchargable = true
			player.vephgoops = {}
			player.drawangle = inputangle
			
			player.vephswipedir = player.drawangle
			player.vephswipedir2 = player.drawangle
			
			player.swipecancel = nil
			mo.momz = $ + dumbgravity*-6
			mo.z = $ + P_MobjFlip(mo)
			
			player.pflags = $ | PF_JUMPED | PF_NOJUMPDAMAGE &~ PF_THOKKED
			
			S_StartSound(mo,sfx_vpjmp2)
			//S_StartSoundAtVolume(mo,sfx_vptail,192)
			//P_Thrust(mo, player.drawangle, 5*mo.scale)
			mo.state = S_VEPH_HOP
			
			player.vephsquish = SQUISHTIME*2/3
		end
		
	elseif P_IsObjectOnGround(mo) and not (player.pflags&PF_SPINNING)
	and player.vephchargable
		player.vephtimer = 0
		player.vephcharge = 1
		player.vephswipedir = player.drawangle
		player.vephswipedir2 = player.drawangle
	end
end)

//Reset the variables
local function vephspawn(player)
	player.vephdived = false
	player.waterdrive = 0
	player.vephswipe = 0
	player.vephswim = 0
	player.vephgoops = {}
	player.vephswipedir = 0
	player.vephswipedir2 = 0
	player.vephsprung = false
	player.vephspringangle = player.drawangle
	player.vephelectric = 0
	player.vephsquish = 0
	player.vephswimcamera = 0
	
	local skin = player.skin or (player.realmo and player.realmo.valid and player.realmo.skin)
	skin = $ and skins[$]
	if player.vephwaterswitch and skin
		player.jumpfactor = skin.jumpfactor
		player.normalspeed = skin.normalspeed
		player.acceleration = skin.acceleration
	end
	player.vephwaterswitch = false
	
	local mo = player.mo
	if mo and mo.valid and mo.skin == "veph"
	and mo.state == S_PLAY_STND
		mo.frame = $ | FF_ANIMATE
	end
end
addHook("PlayerSpawn", vephspawn)
for player in players.iterate vephspawn(player) end

//Button stuff
addHook("PreThinkFrame", do for player in players.iterate
	local mo = player.mo
	if not (mo and mo.valid and mo.skin == "veph") then continue end
	
	//Detect jump inputs
    if player.vephpressjump == nil
    or not (player.cmd.buttons & BT_JUMP)
        player.vephpressjump = 0
    else
        player.vephpressjump = $ + 1
    end
	
	//Detect double tap
	if player.vephdoublespin == nil
	or player.lastbuttons == nil
		player.vephdoublespin = 0
	elseif player.lastbuttons & BT_SPIN
		player.vephdoublespin = max($ + 1, 1)
	elseif player.vephdoublespin > 0
		player.vephdoublespin = ($ <= 5) and -1 or 0
	elseif player.vephdoublespin < 0
		player.vephdoublespin = $ - 1
	end
	
	//Swimming camera
	if player.vephswimcamera
	and player.pflags & PF_DIRECTIONCHAR and player.pflags & PF_ANALOGMODE
		local curangle = player.cmd.angleturn<<16
		local tarangle = player.drawangle
		local factor = 64
		mo.angle = curangle + (tarangle - curangle)/factor
	end

	//What
	if player.vephwtf then
		local shieldbt = BT_SHIELD and BT_SHIELD or BT_TOSSFLAG
		player.cmd.buttons = $ &~ shieldbt
	end
end end)

//Ducking
local function VephDuck(player)
	local mo = player.mo
    if mo and mo.valid and mo.skin == "veph"
    and (mo.state == S_PLAY_CLIMB or InSlide(player)
	or (player.vephswipe and player.vephswipe != 2))
        return P_GetPlayerSpinHeight(player)
    end
end
addHook("PlayerHeight", VephDuck)
addHook("PlayerCanEnterSpinGaps", VephDuck)

//Visual effects and enforcement
addHook("ThinkFrame", do for player in players.iterate
	if not (player.mo and player.mo.valid) continue end
	if player.mo.skin != "veph" continue end
	
	local mo = player.mo
	
	//Veph's goggles
	if mo.skin == "veph" and (mo.eflags & MFE_UNDERWATER
	or InSlide(player) or player.vephwasinslide or player.waterdrive
	or player.powers[pw_carry] == CR_NIGHTSMODE)
		if not mo.vephgoggles
			mo.eflags = $ | MFE_FORCESUPER
			mo.vephgoggles = true
			mo.sprite2 = $ | FF_SPR2SUPER
		end
	elseif mo.vephgoggles
		mo.eflags = $ &~ MFE_FORCESUPER
		mo.vephgoggles = false
		if mo.skin == "veph"
			mo.sprite2 = $ &~ FF_SPR2SUPER
		else
			mo.state = $
		end
	end
	

	player.vephwasinslide = InSlide(player)
	
	//Squishy (force it in BattleMod)
	if player.vephsquish and CBW_Battle
		local factor = 2
		if abs(player.vephsquish) <= SQUISHTIME*2/3 then factor = 4 end
		if abs(player.vephsquish) <= SQUISHTIME/3 then factor = 8 end
		mo.spritexscale = FRACUNIT + sin(player.vephsquish*ANGLE_45)/factor
		mo.spriteyscale = FRACUNIT - sin(player.vephsquish*ANGLE_45)/factor
	end
	
	//Enforce frames
	if mo.health and not player.playerstate and P_IsObjectOnGround(mo)
	and player.panim >= PA_IDLE and player.panim <= PA_FALL
	and player.panim != PA_ROLL and player.panim != PA_PAIN
	and (player.vephdived or player.vephelectric or player.vephswipe)
		if player.vephdived and not InSlide(player, true)
			mo.state = S_VEPH_SLIDE_FRWD
		elseif player.vephswipe
			if player.vephswipe >= 3
				player.pflags = $ | PF_SPINNING
			elseif player.vephswipe == 2
				//nothing
			elseif player.vephtimer > 10
				mo.state = S_PLAY_MELEE_LANDING
			else
				mo.state = S_PLAY_MELEE_FINISH
			end
		elseif player.vephelectric
			mo.state = S_PLAY_STUN
		end
	end
	
	//Slide frames
	if player.vepholdpos != nil
	and mo.state >= S_VEPH_SLIDE_UP and mo.state <= S_VEPH_SLIDE_DOWN
	and (mo.tics < TICRATE - 2 //Delay changes
	or (player.vephdived and (player.pflags & PF_THOKKED or player.vephtimer)))
		//Vertical angle, 3 is full up, 2-1 is diagonal, 0 is straight
		local pos = player.vepholdpos
		local angle = R_PointToAngle2(0,0,
		R_PointToDist2(mo.x, mo.y, pos.x, pos.y)/8, (mo.z - pos.z)*P_MobjFlip(mo))
		angle = $/ANG1/25
		if P_IsObjectOnGround(mo) then angle = max(min($, 1), -1)
		elseif angle > 1 then angle = $ - 1
		elseif angle < -1 angle = $ + 1 end
		
		//Set the state
		local state = S_VEPH_SLIDE_FRWD - angle
		state = min(max($, S_VEPH_SLIDE_UP), S_VEPH_SLIDE_DOWN)
		if mo.state < state
			mo.state = $ + 1
		elseif mo.state > state
			mo.state = $ - 1
		end
	end
	player.vepholdpos = {x = mo.x, y = mo.y, z = mo.z + mo.pmomz}
	
	//Diagonal spring animation
	if mo.state == S_PLAY_SPRING
	and player.powers[pw_noautobrake] and player.powers[pw_justsprung]
		mo.state = S_VEPH_SPRING
		mo.rollangle = -ANGLE_11hh/2
		player.vephspringroll = true
	end
	
	//Droopy effect
	if mo.vephwassuper
	or (player.vephswipe and player.vephswipe < 3 and player.vephtimer <= 10)
		if mo.frame & FF_TRANSMASK < FF_TRANS20
			mo.frame = ($ &~ FF_TRANSMASK) | FF_TRANS20
		end
		
		//Visual goop
		SpawnVisualGoop(mo)
	end
end end)

//Main character thinker
addHook("PlayerThink", function(player)
	if not (player.mo and player.mo.valid) then return end
	//Decrease slime i-frames


	//Veph exclusive stuff
	if player.mo.skin != "veph"
		if player.vephelectric
			mo.spritexoffset = 0
			mo.spriteyoffset = 0
			player.vephelectric = 0
		end
		return
	end
	
	local mo = player.mo
	//What
	if (player.powers[pw_shield] & SH_NOSTACK) == SH_THUNDERCOIN
	and player.pflags & PF_SHIELDABILITY
	then
		player.vephwtf = true
	elseif P_IsObjectOnGround(mo) or mo.eflags & MFE_JUSTHITFLOOR then
		player.vephwtf = false
	end
	
	//Squishy
	if player.vephsquish
		if player.vephsquish > 0
			player.vephsquish = $ - 1
		else
			player.vephsquish = $ + 1
		end
		local factor = 2
		if abs(player.vephsquish) <= SQUISHTIME*2/3 then factor = 4 end
		if abs(player.vephsquish) <= SQUISHTIME/3 then factor = 8 end
		mo.spritexscale = FRACUNIT + sin(player.vephsquish*ANGLE_45)/factor
		mo.spriteyscale = FRACUNIT - sin(player.vephsquish*ANGLE_45)/factor
	end
	
	//Fix the sprite not being centered because it has a one pixel center
	local models = CV_FindVar("gr_models")
	local renderer = CV_FindVar("renderer")
	if mo.skin == "veph" and (not mo.spritexoffset or mo.spritexoffset == INT16_MAX)
	and not (models and models.value and renderer and renderer.value == 2)
		mo.spritexoffset = INT16_MAX
		mo.vephoffset = true
	elseif mo.vephoffset
		mo.spritexoffset = 0
		mo.vephoffset = false
	elseif mo.vephoffset == nil
		mo.vephoffset = false
	end
		
	//Super Veph
	if mo.skin == "veph" and player.solchar and player.solchar.istransformed
	and mo.state != S_PLAY_SUPER_TRANS1 and mo.state != S_PLAY_SUPER_TRANS2
		local momz = min(mo.momz*P_MobjFlip(mo), 0)
		if player.vephsquish
			mo.spritexscale = $ + FixedDiv(momz/64, mo.scale)
			mo.spriteyscale = $ - FixedDiv(momz/64, mo.scale)
		else
			mo.spritexscale = FRACUNIT + FixedDiv(momz/64, mo.scale)
			mo.spriteyscale = FRACUNIT - FixedDiv(momz/64, mo.scale)
		end
		
		//Ground hit
		if not P_IsObjectOnGround(mo) and mo.vephhitground != -1
		and not (mo.eflags & (MFE_JUSTHITFLOOR|MFE_SPRUNG))
			mo.vephhitground = $ and $ - 1 or 0
		elseif not mo.vephhitground or mo.vephhitground == -1
		or mo.eflags & MFE_SPRUNG
			if mo.vephhitground == -1 and P_IsObjectOnGround(mo)
				player.vephsquish = -SQUISHTIME
			else
				player.vephsquish = SQUISHTIME
			
				if player.vephdived
					//nothin
				else
					VephLand(player)
				end
			end
			
			for i = 1, 8
				P_SPMAngle(mo, MT_VEPH_GOOP, player.drawangle + ANGLE_45*i)
			end
			S_StartSoundAtVolume(mo, sfx_ghit, 128)
			
			mo.vephhitground = 5
		end
		
		//Stepping
		if abs(player.vephsquish) <= SQUISHTIME/3
			local frames = 1
			if player.panim == PA_WALK or player.panim == PA_RUN
				frames = skins[player.skin].sprites[mo.sprite2].numframes or $
			end
		
			if (P_IsObjectOnGround(mo) or player.powers[pw_carry] == CR_ROLLOUT)
			and (player.panim == PA_WALK or player.panim == PA_RUN)
			and (((mo.frame & FF_FRAMEMASK) + 1) % max(frames/2, 1)) == 0 and mo.tics == 1
				if mo.eflags & MFE_UNDERWATER
					local bubble = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_MEDIUMBUBBLE)
					bubble.bubbleghost = true
					bubble.fuse = TICRATE*2
				else
					local splish = P_SpawnMobjFromMobj(mo, 0, 0, -16*FRACUNIT, MT_SPLISH)
					splish.color = WATERCOLOR
					splish.colorized = true
					S_StartSound(mo, sfx_vpsld1+VephRandom(0,4))
				end
				player.vephsquish = SQUISHTIME/3
			end
		end
		
		mo.colorized = true
		mo.vephwassuper = true
		
	//Revert
	elseif mo.vephwassuper
		if not player.vephsquish
			mo.spritexscale = FRACUNIT
			mo.spriteyscale = FRACUNIT
		end
		
		mo.frame = $ &~ FF_TRANSMASK
		mo.colorized = false
		mo.vephwassuper = false
	end
	
	local skin = skins[mo.skin]
	local inputangle = getinputangle(player)
	
	//No shield abilities pre-2.2.14
	if not BT_SHIELD
		player.charflags = $ | SF_NOSHIELDABILITY
	end
	
	//INFINITE UNDERWATER AIR BOIS
	if player.powers[pw_underwater]
		player.powers[pw_underwater] = underwatertics
	end
	
	//Jump/Death/Drill/Skid animations
	if mo.state == S_PLAY_JUMP
		mo.state = S_VEPH_JUMP
		
		if mo.vephwassuper
			local splish = P_SpawnMobjFromMobj(mo, 0, 0, -16*FRACUNIT, MT_SPLISH)
			splish.color = WATERCOLOR
			splish.colorized = true
			S_StartSound(mo, sfx_vpsld1+VephRandom(0,4))
			player.vephsquish = -SQUISHTIME
		end
	elseif mo.state == S_PLAY_DEAD
	and mo.momz*P_MobjFlip(mo) < 0
		mo.state = S_PLAY_DRWN
	elseif mo.state == S_PLAY_NIGHTS_DRILL and mo.tics == 2
	and player.powers[pw_carry] == CR_NIGHTSMODE
		mo.tics = 1
	elseif mo.state == S_VEPH_HOP_FINISH
		mo.state = S_VEPH_SLIDE_FRWD
	elseif mo.state == S_PLAY_SKID
		local tics = mo.tics
		if tics & 1
			mo.state = S_PLAY_SKID
			mo.tics = tics
		end
	end
	
	//Spring animation
	if not PSO and (mo.state == S_PLAY_SPRING
	or (player.isxmomentum and mo.state == S_PLAY_TRICKUP))
		if mo.state == S_PLAY_SPRING
		and player.powers[pw_noautobrake] and player.powers[pw_justsprung]
			mo.state = S_VEPH_SPRING
			mo.rollangle = -ANGLE_22h
			player.vephspringroll = true
		else
			player.vephspringangle = $ + ANGLE_22h
			player.drawangle = player.vephspringangle
			if not (player.cmd.forwardmove or player.cmd.sidemove)
			and player.pflags & PF_DIRECTIONCHAR and player.pflags & PF_ANALOGMODE
				mo.angle = player.cmd.angleturn<<16
			end
			if player.vephspringroll
				player.vephspringroll = false
				mo.rollangle = 0
			end
		end
	else
		if mo.state == S_VEPH_SPRING and player.vephspringroll
			mo.rollangle = $ - ANG1*mo.tics*2/6
		elseif player.vephspringroll
			player.vephspringroll = false
			mo.rollangle = 0
		end
		player.vephspringangle = player.drawangle
	end
	
	//Spawn water particles when sliding around
	if InSlide(player)
		player.spinitem = MT_NULL
		if P_IsObjectOnGround(mo)
		and not (player.vephdived and player.speed < 16*mo.scale)
			if not (leveltime % 5)
				S_StartSound(mo, sfx_vpsld1+VephRandom(0,4))
			end
			if (mo.eflags & MFE_UNDERWATER)
				P_SpawnSkidDust(player, mo.radius*3/2, false)
			elseif not (leveltime % 4)
				local angle = player.drawangle
				if mo.momx or mo.momy
					angle = R_PointToAngle2(0,0,mo.momx,mo.momy)
				end
				
				if vephsplat.value
					local iangle = ANGLE_247h while iangle <= ANGLE_112h
						local splish = P_SPMAngle(mo, MT_VEPHSPLATSH, angle+iangle, 0, MF2_AMBUSH)
						if splish and splish.valid
							splish.momx = mo.momx/2+P_ReturnThrustX(mo, splish.angle, mo.scale*8)
							splish.momy = mo.momy/2+P_ReturnThrustY(mo, splish.angle, mo.scale*8)
							splish.reactiontime = $ - 2
							
							//local thrust = mo.radius*2-max(mo.scale*36-player.speed, 0)*2/3
							P_TryMove(splish,
							splish.x+mo.momx,
							splish.y+mo.momy,
							false)
							
							if player.speed < 16*mo.scale
								local thrust = player.speed-16*mo.scale
								P_Thrust(splish,angle,thrust)
								P_TryMove(splish,
								splish.x+mo.momx-P_ReturnThrustX(mo,angle,thrust),
								splish.y+mo.momy-P_ReturnThrustY(mo,angle,thrust),
								false)
							end
						end
						iangle = $ + ANGLE_45
					end
					
					local thok = P_SpawnMobjFromMobj(mo,0,0,-4*FRACUNIT,MT_THOK)
					thok.angle = player.drawangle
					thok.momx = mo.momx/4
					thok.momy = mo.momy/4
					P_TryMove(thok,
					thok.x+P_ReturnThrustX(mo,thok.angle,mobjinfo[MT_THOK].height/-2),
					thok.y+P_ReturnThrustY(mo,thok.angle,mobjinfo[MT_THOK].height/-2),
					false)
					thok.color = (player.powers[pw_shield] & SH_NOSTACK) == SH_ELEMENTAL
					and SKINCOLOR_KETCHUP or WATERCOLOR
					thok.colorized = true
					thok.fuse = thok.tics
					thok.scale = $*2
					thok.destscale = 1
					thok.flags2 = $ | MF2_SPLAT | MF2_BOSSNOTRAP
					thok.renderflags = $ | RF_NOSPLATBILLBOARD
					if mo.eflags & MFE_VERTICALFLIP
						thok.z = $ + thok.height/2
						thok.height = 0
					end
				else
					local i = 0 while i < 5
						local splish = P_SpawnMobjFromMobj(mo, 0,0, -16*FRACUNIT, MT_SPLISH)
						if splish and splish.valid
							splish.spritexscale = FRACUNIT*3/2
							splish.stupidsticktowater = 2
							splish.flags = $|MF_NOCLIPTHING&~MF_NOCLIP&~MF_SCENERY|MF_BOUNCE
							splish.angle = angle
							splish.color = WATERCOLOR
							splish.colorized = true
							if i == 0
								splish.state = S_SPLISH4
							else
								if i == 1
									splish.angle = angle+ANGLE_112h
								elseif i == 2
									splish.angle = angle+ANGLE_247h
								elseif i == 3
									splish.angle = angle+ANGLE_112h+ANGLE_22h*3/2
								elseif i == 4
									splish.angle = angle+ANGLE_247h-ANGLE_22h*3/2
								end
								splish.momx = mo.momx
								splish.momy = mo.momy
								P_TryMove(splish,
								splish.x+P_ReturnThrustX(mo,angle,mo.radius*2),
								splish.y+P_ReturnThrustY(mo,angle,mo.radius*2),
								false)
								P_Thrust(splish,splish.angle,5*splish.scale)
							end
							if FixedHypot(mo.momx, mo.momy)
							< 8*splish.scale
								P_Thrust(splish,angle,-4*splish.scale)
							end
						end
						i = $ + 1
					end
				end
			end
			
		//Extra gravity during the slide when rising (accounts for underwater gravity)
		elseif not (mo.eflags & MFE_GOOWATER) or mo.eflags & MFE_UNDERWATER
			if player.vephwaterswitch
			and P_GetMobjGravity(mo) > mo.scale/-2
			and P_GetMobjGravity(mo) < 0
				P_SetObjectMomZ(mo, -gravity/3, true)
			else
				mo.momz = $ + P_GetMobjGravity(mo)/3
			end
		end
		
		//Dive effect
		if player.vephdived and player.pflags & PF_THOKKED
		and not P_IsObjectInGoop(mo) and mo.momz*P_MobjFlip(mo) < 0
			local i = -1
			local total = 3
			while i < total
				local ghost = P_SpawnGhostMobj(mo)
				P_TeleportMove(ghost, ghost.x+mo.momx/-total*i,
				ghost.y+mo.momy/-total*i, ghost.z+mo.momz/-total*i)
				ghost.color = WATERCOLOR
				ghost.colorized = true
				ghost.destscale = 1
				ghost.scalespeed = ghost.scale/8
				ghost.spritexscale = mo.spritexscale
				ghost.spriteyscale = mo.spriteyscale
				P_SetScale(ghost, ghost.scale-ghost.scalespeed/total*i)
				ghost.fuse = TICRATE/5
				
				if ghost.tracer and ghost.tracer.valid
					ghost = ghost.tracer
					P_TeleportMove(ghost, ghost.x+mo.momx/-total*i,
					ghost.y+mo.momy/-total*i, ghost.z+mo.momz/-total*i)
					ghost.color = WATERCOLOR
					ghost.colorized = true
					ghost.destscale = 1
					ghost.scalespeed = ghost.scale/8
					P_SetScale(ghost, ghost.scale-ghost.scalespeed/total*i)
					ghost.fuse = TICRATE/5
				end
				
				i = $ + 1
			end
		end
		
	//Regular spin effect
	elseif player.spinitem == MT_NULL and not player.vephswipe
		player.spinitem = MT_THOK
	end
	
	//Makes it so that you properly bounce off of walls
	if player.dumbbouncex != nil and player.dumbbouncey != nil
		if (P_IsObjectOnGround(mo) or player.vephdived
		or player.vephswipe or player.waterdrive) and player.powers[pw_pushing]
			if not player.vephswipe or player.vephswipe >= 3
				player.pflags = $ | PF_SPINNING
				if not InSlide(player, true)
					mo.state = S_VEPH_SLIDE_FRWD
					player.panim = PA_ROLL
				end
			end
			if not player.powers[pw_justlaunched]
				mo.momx = player.dumbbouncex
				mo.momy = player.dumbbouncey
				
				if not player.vephswipe or player.vephswipe >= 3
					player.vephsquish = SQUISHTIME*4/3
					S_StartSound(mo,sfx_vpbonk)
				else
					player.vephsquish = -SQUISHTIME
					S_StartSound(mo,sfx_vphit)
				end
				
				vephcircle(mo, MT_GHOST, 8, 4*mo.scale, player.height/2,
				mo.scale/2, false, nil, true, player.drawangle)
			end
		end
	player.dumbbouncex = nil
	player.dumbbouncey = nil
	end

	
	//Disallows the rest of the code in certain circumstances
	if P_PlayerInPain(player)
	or player.pflags & PF_SLIDING
	//or player.exiting
	or player.powers[pw_carry]
	or player.spectator
	or player.playerstate
	or not mo.health
	//or (player.panim == PA_PAIN and not (player.pflags & PF_JUMPED))
	or player.powers[pw_super] == 1
	or player.iseggrobo
	or player.isjettysyn
	or player.guard
	or player.tumble
	or player.airdodge
	or player.actionstate == 1
	or player.powers[pw_nocontrol] > 0
	or (player.isxmomentum and mo.state == S_PLAY_FACEPLANT)
	or PSO
		player.vephdived = false
		player.waterdrive = 0
		if player.vephswipe
			player.vephswipe = 0
			player.pflags = $ &~ PF_DRILLING
			mo.rollangle = 0
		end
		player.vephgoops = {}
		player.vephswim = 0
		player.vephswimcamera = 0
		player.vephtimer = 0
		player.vephstartjump = player.pflags & PF_STARTJUMP
		
		if player.powers[pw_carry] == CR_GENERIC
		or player.powers[pw_carry] == CR_PLAYER
		or player.powers[pw_carry] == CR_ROPEHANG
		or player.powers[pw_carry] == CR_MACESPIN
		or player.powers[pw_carry] == CR_ROLLOUT
		or player.powers[pw_carry] == CR_FAN
		or player.pflags & PF_SLIDING
			player.vephsprung = false
			player.glidetime = 0
		elseif not P_IsObjectOnGround(mo)
			player.vephsprung = true
			player.glidetime = 1
		end
		
		//Reset the stats if they were changed by the underwater code
		if player.vephwaterswitch
			player.jumpfactor = skin.jumpfactor
			player.normalspeed = skin.normalspeed
			player.acceleration = skin.acceleration
			player.vephwaterswitch = false
		end
		
		//Electric pain!!
		if player.vephelectric
			A_ForceStop(mo)
			mo.state = S_PLAY_STUN
			
			if player.powers[pw_nocontrol] == TICRATE-1
				S_StopSoundByID(target, sfx_shldls)
				mo.momz = 0
				player.rings = player.vephelectric+min(-player.vephelectric*5/TICRATE, -1)
			end
			
			if player.powers[pw_nocontrol]%5 < 3
				if RF_FULLDARK
					mo.frame = $&~FF_FULLDARK
				else
					mo.colorized = false
					mo.color = player.powers[pw_shield]&SH_FIREFLOWER and SKINCOLOR_WHITE or player.skincolor
				end
			else
				if RF_FULLDARK
					mo.frame = $|FF_FULLDARK
				else
					mo.colorized = true
					mo.color = SKINCOLOR_BLACK
				end
			end
			
			local zap = P_SpawnMobjFromMobj(mo,32*(P_RandomFixed()-(FRACUNIT/2)),
			32*(P_RandomFixed()-(FRACUNIT/2)),
			32*P_RandomFixed(),MT_WATERZAP)
			P_TeleportMove(zap,zap.x+P_ReturnThrustX(mo,player.drawangle,mo.radius*3/-5),
			zap.y+P_ReturnThrustY(mo,player.drawangle,mo.radius*3/-5),zap.z)
			
			if player.powers[pw_nocontrol]
				if player.rings and not (player.powers[pw_nocontrol]%5)
					P_GivePlayerRings(player, min(-player.vephelectric*5/TICRATE, -1))
					S_StartSound(mo, sfx_antiri)
				end
				player.powers[pw_flashing] = flashingtics
				mo.spritexoffset = P_SignedRandom()*P_RandomFixed()/8
				mo.spriteyoffset = P_SignedRandom()*P_RandomFixed()/8
			else
				mo.state = S_PLAY_FALL
				if player.vephelectric == -1
					player.powers[pw_flashing] = 0
					P_DamageMobj(mo, nil, nil, DMG_INSTAKILL)
					mo.momz = 0
				else
					player.powers[pw_flashing] = flashingtics-1
					player.rings = 0
				end
				mo.spritexoffset = 0
				mo.spriteyoffset = 0
				player.vephelectric = 0
			end
		end
		return
	end
	
	//Cancel the Elemental and Bubble Stomp right before you hit the ground
	if ((player.powers[pw_shield] & SH_NOSTACK) == SH_ELEMENTAL
	or (player.powers[pw_shield] & SH_NOSTACK) == SH_BUBBLEWRAP)
	and player.pflags&(PF_SHIELDABILITY|PF_THOKKED)
	and (player.vephdived or player.vephswipe)
		local floor = P_FloorzAtPos(mo.x+mo.momx,
		mo.y+mo.momy, mo.z+mo.momz, mo.height)
		local floor2 = mo.floorz
		local z = mo.z
		if (mo.eflags & MFE_VERTICALFLIP)
			z = mo.z+mo.height
			if MF2_SPLAT
				floor = P_CeilingzAtPos(mo.x+mo.momx,
				mo.y+mo.momy, mo.z+mo.momz, mo.height)
			elseif mo.ceilingz == floor
				floor = mo.floorz
			else
				floor = mo.ceilingz
			end
			floor2 = mo.ceilingz
		end
		if min(abs(z-floor), abs(z-floor2)) <= abs(mo.momz)
			player.pflags = $ &~ PF_SHIELDABILITY
		end
	end
	
	if mo.eflags & MFE_SPRUNG and not P_IsObjectOnGround(mo)
	and not (player.pflags & PF_JUMPED)
		player.vephsprung = true
		player.glidetime = 1
	elseif player.vephsprung and (P_IsObjectOnGround(mo)
	or mo.eflags & MFE_JUSTHITFLOOR or player.pflags & PF_JUMPED)
		player.vephsprung = false
	end
	
	//Cancel slide
	if (player.gotflag or player.gotcrystal or player.gotflagdebuff)
	and InSlide(player)
		player.pflags = $ &~ PF_SPINNING
		mo.state = S_PLAY_FALL
		player.vephdived = false
	
	//Turning assist (Blaze got this from here, not the other way around!)
	elseif InSlide(player)
	and not (player.pflags & PF_STASIS) and not player.waterdrive
		if InSlide(player, true)
			player.pflags = $ | PF_SPINNING
		end
		
		local oldmomx = mo.momx
		local oldmomy = mo.momy
		local oldspeed = FixedHypot(oldmomx, oldmomy)
		if not P_IsObjectOnGround(mo) then oldspeed = max($, 4*mo.scale) end
		local oldangle = R_PointToAngle2(0,0, mo.momx, mo.momy)
		local factor = max(max(81 - oldspeed*3/mo.scale, 12) - max(oldspeed*2/3/mo.scale - 36, 0), 6)
		if player.pflags & PF_THOKKED then factor = $*2 end
		
		local angle = player.cmd.angleturn<<16
		if mo.flags2 & MF2_TWOD or twodlevel
			angle = ANGLE_90
		end
		
		P_Thrust(mo, angle, player.cmd.forwardmove*mo.scale/factor)
		P_Thrust(mo, angle+ANGLE_90, -player.cmd.sidemove*mo.scale/factor)
		
		local newangle = R_PointToAngle2(0,0, mo.momx, mo.momy)
		if FixedHypot(mo.momx, mo.momy) > oldspeed
		or (player.vephswimcamera and player.vephswimcamera < 5)
			P_InstaThrust(mo, newangle, oldspeed)
		end
		
		local diff = newangle - oldangle
		local newspeed = FixedHypot(mo.momx, mo.momy)
		P_InstaThrust(mo, newangle, newspeed)
		
		//Make the slide usable for rising Spindashable platforms
		if InSlide(player)
		and P_IsObjectOnGround(mo) and not player.vephswipe
			local sectorthing = P_PlayerTouchingSectorSpecial(player, 0, 0)
			if sectorthing and sectorthing.valid then
				for fof in sectorthing.ffloors()
					if fof and fof.valid and (abs(fof.topheight - mo.z) <= 40*mo.scale
					or abs(fof.bottomheight - mo.z+mo.height) <= 40*mo.scale)
					and fof.master and fof.master.valid and fof.master.flags&ML_NOCLIMB
					and (fof.master.special == 153 or fof.master.special == 180
					or (fof.master.special >= 150 and fof.master.special <= 152)
					or (fof.master.special >= 190 and fof.master.special <= 195)
					or fof.master.special == 176 or fof.master.special == 177)
						player.pflags = $ | PF_STARTDASH
						P_InstaThrust(mo,0,0)
					end
				end
			end
		end
	end
	
	local waterskip = false
	
	//Change stats underwater to go against the water physics
	if mo.eflags & MFE_UNDERWATER and not P_IsObjectInGoop(mo)
	and not (player.gotflag or player.gotcrystal or player.gotflagdebuff)
	and (vephfun.value or gametyperules & GTR_FRIENDLY)
		if not player.vephwaterswitch
			player.jumpfactor = FixedMul(skin.jumpfactor, FixedDiv(200*FRACUNIT, 117*FRACUNIT))
			player.normalspeed = skin.normalspeed*2
			player.acceleration = skin.acceleration*15/9
			player.vephwaterswitch = true
			
			//Diving to Swimming
			if player.vephdived and player.pflags & PF_JUMPDOWN
			and not (player.pflags & PF_SPINDOWN)
				player.vephswim = 1
				player.vephdived = false
				player.pflags = $ &~ PF_SPINNING &~ PF_THOKKED &~ PF_SHIELDABILITY
				mo.state = S_VEPH_SWIM_STOP
			end
		else
			if player.jumpfactor >= skin.jumpfactor
				player.jumpfactor = max($, FixedMul(skin.jumpfactor, FixedDiv(200*FRACUNIT, 117*FRACUNIT)))
			end
			if player.normalspeed >= skin.normalspeed
				player.normalspeed = max($, skin.normalspeed*2)
			end
			if player.acceleration >= skin.acceleration
				player.acceleration = max($, skin.acceleration*15/9)
			end
		end
		if mo.eflags & MFE_SPRUNG
			mo.z = $ + P_MobjFlip(mo)
			mo.momz = $*11/8
		end
		if P_GetMobjGravity(mo) > mo.scale/-2
		and P_GetMobjGravity(mo) < 0
		and not P_IsObjectOnGround(mo)
			P_SetObjectMomZ(mo, -gravity+FRACUNIT/3, true)
		end
	elseif player.vephwaterswitch
		player.jumpfactor = skin.jumpfactor
		player.normalspeed = skin.normalspeed
		player.acceleration = skin.acceleration
		player.vephwaterswitch = false
		if mo.momz*P_MobjFlip(mo) > 0 and player.pflags & PF_JUMPED
		and not (mo.eflags & MFE_UNDERWATER) and not P_IsObjectInGoop(mo)
		and not (player.gotflag or player.gotcrystal or player.gotflagdebuff)
			mo.momz = $/2
		end
	end
	
	//Jet Stream
	/*if player.vephjetstream
		player.vephtimer = $ + 1

		//Cancel
		if mo.momz*P_MobjFlip(mo) < 0 or P_IsObjectOnGround(mo)
		or (mo.state != S_VEPH_HOP and mo.state != S_VEPH_HOP_FINISH)
			player.vephjetstream = false
			
		//Effects
		elseif mo.eflags & MFE_UNDERWATER
			if player.vephtimer & 1
				vephcircle(mo, MT_MEDIUMBUBBLE, 4, 8*mo.scale, 8*FRACUNIT, mo.scale, -1)
				S_StartSound(mo, sfx_bubbl1+VephRandom(0,4))
			end
		elseif vephsplat.value
			if not ((player.vephtimer+1) % 3)
				A_MultiShot(mo, (MT_VEPHSPLATSH<<16)+8, -24)
			end
		elseif player.vephtimer & 1
			vephcircle(mo, MT_SPLISH, 8, 2*mo.scale, 8*FRACUNIT, mo.scale, -1)
		end*/
		
	//Swimming
	if player.vephswim
		local watersurface = mo.watertop
		if mo.eflags & MFE_VERTICALFLIP
			watersurface = mo.waterbottom
		end
		local atsurface = abs(watersurface-mo.z) < mo.height
		
		//Start swimming
		local speed = FixedHypot(mo.momx, mo.momy)
		if abs(player.vephswim) == 1
			if speed or player.vephswim == -1
				player.vephswipedir = R_PointToAngle2(0,0, mo.momx, mo.momy)
				player.vephswipedir2 = R_PointToAngle2(0,0, speed, mo.momz)
				player.vephswipedir2 = InvAngle($ - ANGLE_90)
			else
				player.vephswipedir = mo.angle
				player.vephswipedir2 = ANGLE_90
			end
			if player.vephswim != -1
				player.vephswimspeed = FixedHypot(speed, mo.momz)
			end
			player.vephswimturn = 0
			player.vephswimcamera = 1
			player.vephswim = 2
		end
		
		//End swimming, transition to slide if we can
		if not (mo.eflags & MFE_UNDERWATER) or mo.eflags & MFE_SPRUNG
		or P_IsObjectOnGround(mo) or player.pflags & PF_SHIELDABILITY
		or player.gotflag or player.gotcrystal or player.gotflagdebuff
		or not (vephfun.value or gametyperules & GTR_FRIENDLY)
			player.vephswim = 0
			if mo.state == S_PLAY_SWIM or mo.state == S_VEPH_SWIM_STOP
			or mo.state == S_VEPH_SWIM_UP or mo.state == S_VEPH_SWIM_DOWN
			or mo.state == S_VEPH_HOP
				player.vephdived = true
				mo.state = S_VEPH_SLIDE_DIAUP
				
				if not speed
					P_InstaThrust(mo, player.vephswipedir, player.vephswimspeed)
				elseif speed < player.vephswimspeed
					P_InstaThrust(mo, R_PointToAngle2(0,0, mo.momx, mo.momy), player.vephswimspeed)
				end
			end
		
		//Water jump
		elseif atsurface and player.vephpressjump == 1
		and player.cmd.forwardmove <= -25
			player.vephswim = 0
			player.glidetime = 0
			player.pflags = $ &~ PF_JUMPED
			P_DoJump(player)
			
		//During swim
		/*
			This is adapted from SM64 Ex Co-op Veph, which uses both original
			code and code from the public domain CC0 sm64 decompilation.
			Any code used from there is labelled accordingly.
			If it's not labelled, assume it's original.
			https://github.com/n64decomp/sm64
		*/
		else
			local SWIMSPEED = min(mo.scale*48, FixedMul(player.actionspd, mo.scale))
			local forwardmove = abs(player.cmd.forwardmove) >= 5
			and player.cmd.forwardmove or 0
			
			//Update speed variable and state
			if (player.cmd.buttons & (BT_JUMP|BT_SPIN)) == BT_JUMP
				if player.vephswimspeed < SWIMSPEED
					player.vephswimspeed = min(player.vephswimspeed + mo.scale/3, SWIMSPEED)
				elseif player.vephswimspeed > SWIMSPEED
					player.vephswimspeed = max(player.vephswimspeed - mo.scale/3, SWIMSPEED)
				end
				
				if mo.state == S_VEPH_HOP
					//Do nothing
				elseif mo.state != S_PLAY_SWIM and mo.state != S_VEPH_SWIM_UP
				and mo.state != S_VEPH_SWIM_DOWN
					mo.state = S_PLAY_SWIM
				else
					local state = S_PLAY_SWIM
					if forwardmove < 0 and mo.state != S_VEPH_SWIM_DOWN
						state = S_VEPH_SWIM_UP
					elseif forwardmove > 0 and mo.state != S_VEPH_SWIM_UP
						state = S_VEPH_SWIM_DOWN
					end
					
					if mo.state != state
						local frame = mo.frame & FF_FRAMEMASK
						local tics = mo.tics
						mo.state = state
						mo.frame = ($ &~ FF_FRAMEMASK) | frame
						mo.tics = tics
					end
				end
				
				if mo.tics == 1 and not ((mo.frame & FF_FRAMEMASK) & 1)
					if atsurface
						S_StartSound(mo, sfx_vpswm1)
						P_SpawnMobjFromMobj(mo, 0, 0, watersurface-mo.z, MT_SPLISH)
					else
						S_StartSound(mo, sfx_vpswm2)
					end
				end
			else
				if player.cmd.buttons & BT_SPIN or player.powers[pw_pushing]
					player.vephswimspeed = max($ - mo.scale, 0)
				else
					player.vephswimspeed = max($ - mo.scale/3, 0)
				end
				if mo.state != S_VEPH_HOP
					mo.state = S_VEPH_SWIM_STOP
				end
			end
			player.panim = PA_DASH
			
			if not atsurface and (player.vephswimspeed >= SWIMSPEED/4
			or mo.state != S_VEPH_SWIM_STOP)
				local info = mobjinfo[MT_SMALLBUBBLE]
				local spawnstate = info.spawnstate
				info.spawnstate = S_SPINDUST_BUBBLE1
				A_BossScream(mo, 1, MT_SMALLBUBBLE)
				info.spawnstate = spawnstate
			end
			
			local factor = FixedDiv(player.vephswimspeed, mo.scale)
			factor = min($/48, FRACUNIT) + FRACUNIT
			
			//Update pitch for faster turning (vertical)
			/*
				This is based on update_swimming_pitch in
				mario_actions_submerged.c from the sm64 decomp!
				https://github.com/n64decomp/sm64/blob/master/src/game/mario_actions_submerged.c
			*/
			local targetPitch = ANG1 * forwardmove * P_MobjFlip(mo) + ANGLE_90

			local pitchVel = ANG1
			pitchVel = FixedMul(pitchVel, factor)
			
			if P_IsObjectOnGround(mo)
				player.vephswipedir2 = ANGLE_90
				mo.z = $ + P_MobjFlip(mo)
			elseif (player.vephswipedir2 < targetPitch) then
				player.vephswipedir2 = player.vephswipedir2 + pitchVel
				if (player.vephswipedir2 > targetPitch) then
					player.vephswipedir2 = targetPitch
				end
			elseif (player.vephswipedir2 > targetPitch) then
				player.vephswipedir2 = player.vephswipedir2 - pitchVel
				if (player.vephswipedir2 < targetPitch) then
					player.vephswipedir2 = targetPitch
				end
			end

			//Update Yaw for faster turning (horizontal)
			/*
				This is based on update_swimming_yaw in
				mario_actions_submerged.c from the sm64 decomp!
				https://github.com/n64decomp/sm64/blob/master/src/game/mario_actions_submerged.c
			*/
			local sidemove = player.cmd.sidemove
			if not sidemove and player.vephswipedir != mo.angle
			and not (player.pflags & PF_DIRECTIONCHAR and player.pflags & PF_ANALOGMODE)
				local diff = player.vephswipedir - mo.angle
				if diff > 0
					sidemove = 50
				else
					sidemove = -50
				end
			end
			local targetYawVel = ANG1/8 * -sidemove
			factor = pitchVel/32
			
			if (targetYawVel > 0) then
				if (player.vephswimturn < 0) then
					player.vephswimturn = player.vephswimturn + 64*factor
					if (player.vephswimturn > 16*factor) then
						player.vephswimturn = 16*factor
					end
				elseif (player.vephswimturn < targetYawVel)
					player.vephswimturn = $ + 16*factor
					if (player.vephswimturn > targetYawVel)
						player.vephswimturn = targetYawVel
					end
				else
					player.vephswimturn = $ - 32*factor
					if (player.vephswimturn < targetYawVel)
						player.vephswimturn = targetYawVel
					end
				end
			elseif (targetYawVel < 0) then
				if (player.vephswimturn > 0) then
					player.vephswimturn = player.vephswimturn - 64*factor
					if (player.vephswimturn < -16*factor) then
						player.vephswimturn = -16*factor
					end
				elseif (player.vephswimturn < targetYawVel)
					player.vephswimturn = $ + 16*factor
					if (player.vephswimturn > targetYawVel)
						player.vephswimturn = targetYawVel
					end
				else
					player.vephswimturn = $ - 32*factor
					if (player.vephswimturn < targetYawVel)
						player.vephswimturn = targetYawVel
					end
				end
			elseif (player.vephswimturn < 0)
				player.vephswimturn = $ + 16*factor
				if (player.vephswimturn > 0)
					player.vephswimturn = 0
				end
			else
				player.vephswimturn = $ - 32*factor
				if (player.vephswimturn < 0)
					player.vephswimturn = 0
				end
			end
			player.vephswipedir = player.vephswipedir + player.vephswimturn

			//Update actual speed
			speed = FixedDiv(player.vephswimspeed, mo.scale)
			P_InstaThrust(mo, player.vephswipedir,
			FixedMul(FixedMul(speed, abs(sin(player.vephswipedir2))), mo.scale))
			mo.momz = FixedMul(FixedMul(speed, cos(player.vephswipedir2)), mo.scale)
			if mo.state == S_VEPH_SWIM_STOP
				mo.momz = $ + P_GetMobjGravity(mo)*4
			end
			player.drawangle = player.vephswipedir
			
			//Force to surface if we go too high
			local dumbangle = (player.vephswipedir2 - ANGLE_90)*P_MobjFlip(mo)
			if atsurface and ((not (player.pflags & PF_JUMPDOWN) and dumbangle <= 0)
			or (abs(player.cmd.forwardmove) < 25) and dumbangle <= ANGLE_11hh)
				mo.z = watersurface-(mo.height/2)-(mo.scale*P_MobjFlip(mo))
				mo.momz = 0
			end
		end
		
	//Water Drive
	elseif player.waterdrive
	
		//End the move
		if player.waterdrive >= 15*2
			player.waterdrive = 0

		elseif (player.pflags & PF_JUMPED and not InSlide(player))
		or mo.eflags & MFE_SPRUNG or player.powers[pw_justlaunched] > 1
		or (mo.eflags & MFE_JUSTHITFLOOR and player.waterdrive >= 15)
			player.waterdrive = 0
			player.glidetime = 0
			
			local thrust = FixedMul(player.actionspd, mo.scale)
			if player.normalspeed < skin.normalspeed
				thrust = player.normalspeed
				if mo.eflags & MFE_UNDERWATER
					thrust = $/2
				end
			elseif not (vephfun.value or gametyperules & GTR_FRIENDLY)
			and mo.eflags & MFE_UNDERWATER
				thrust = $/2
			end
			
			if not (player.pflags & PF_STARTDASH)
				P_InstaThrust(mo, player.drawangle, thrust)
			end
			
		//Thrust forward with a slide!
		elseif player.waterdrive >= 15
			if not InSlide(player, true)
				mo.state = S_VEPH_SLIDE_FRWD
			end
			player.panim = PA_ROLL
			player.pflags = $|PF_SPINNING|PF_STASIS
			
			if not P_IsObjectOnGround(mo)
				player.vephdived = true
				player.pflags = $ | PF_JUMPED | PF_NOJUMPDAMAGE &~ PF_THOKKED &~ PF_STARTJUMP
				mo.momz = -2*P_GetMobjGravity(mo)
			end
			
			if player.waterdrive == 15
				player.vephsquish = SQUISHTIME
				
				vephcircle(mo, mo.eflags & MFE_UNDERWATER and MT_MEDIUMBUBBLE or MT_THOK,
				12, 4*mo.scale, player.spinheight/2, mo.scale,
				false, 0, true, player.drawangle)
			end
			
			local thrust = FixedMul(player.actionspd, mo.scale)
			if player.normalspeed < skin.normalspeed
				thrust = player.normalspeed
				if mo.eflags & MFE_UNDERWATER
					thrust = $/2
				end
			elseif not (vephfun.value or gametyperules & GTR_FRIENDLY)
			and mo.eflags & MFE_UNDERWATER
				thrust = $/2
			end
			
			if not (player.pflags & PF_STARTDASH)
				if player.waterdrive > 15
					player.drawangle = R_PointToAngle2(0,0, mo.momx, mo.momy)
				end
				P_InstaThrust(mo, player.drawangle, thrust)
			end
			
			if player.waterdrive & 1
				local ghost = P_SpawnGhostMobj(mo)
				
				if mo.eflags & MFE_UNDERWATER
					//S_StartSound(mo, sfx_bubbl1+VephRandom(0,4))
					ghost.sprite = SPR_BUBS
					ghost.frame = M
				else
					ghost.sprite = SPR_FIRS
					ghost.frame = S
					ghost.color = WATERCOLOR
					ghost.colorized = true
				end
				
				ghost.rollangle = 0
				ghost.destscale = $*16
				ghost.scalespeed = ghost.scale/12
				//ghost.flags2 = $|MF2_BOSSNOTRAP
				ghost.momx = mo.momx/2
				ghost.momy = mo.momy/2
				P_TeleportMove(ghost, mo.x + mo.momx, mo.y + mo.momy, ghost.z)
			end
			
		//Pulling back...
		else
			if mo.state != S_PLAY_CLIMB
				mo.state = S_PLAY_CLIMB
			end
			player.pflags = $|PF_FULLSTASIS
			mo.momz = -P_GetMobjGravity(mo)
			
			P_InstaThrust(mo, 0, 0)
			P_TryMove(mo, P_ReturnThrustX(mo, player.drawangle, -10*mo.scale)+mo.x,
			P_ReturnThrustY(mo, player.drawangle, -10*mo.scale)+mo.y, not P_IsObjectOnGround(mo))
			
			if (mo.eflags & MFE_UNDERWATER)
				P_SpawnSkidDust(player, mo.radius, false)
			elseif vephsplat.value
				local splish = P_SPMAngle(mo, MT_VEPHSPLATSH, player.drawangle+P_SignedRandom()*ANG1/4, 0, MF2_AMBUSH|MF2_SLIDEPUSH)
				if splish and splish.valid
					splish.reactiontime = $ - 2
					splish.angle = $ + P_SignedRandom()*ANG1/4
				end
			else
				local splash = P_SpawnMobjFromMobj(mo, 0,0,0, MT_THOK)
				if splash and splash.valid
					splash.state = S_VEPH_GOOPSPLASH
					splash.color = SKINCOLOR_SUPERSILVER1
					splash.frame = $|TR_TRANS50
				end
			end
		end
		
		player.waterdrive = $ and $ + 1 or 0
		
	//Charging
	elseif player.vephcharge
	
		//Cancel the charge if we press jump
		if player.vephpressjump == 1
			player.vephcharge = 0
			if mo.state == S_PLAY_CLIMB
				mo.state = S_VEPH_JUMP
				S_StartSound(mo, sfx_vpcanc)
			end
	
		//Continue charging if we're holding the button
		elseif (player.cmd.buttons & BT_SPIN)
		or mo.ceilingz - mo.floorz < FixedMul(player.height, mo.scale)
			player.vephtimer = $ + 1
			
			//Only start charging a few frames in to prevent accidental charging when spamming spin
			if player.vephtimer > 5
				if mo.friction > FRACUNIT*2/3 then mo.friction = FRACUNIT*2/3 end
				player.drawangle = player.vephswipedir
				player.pflags = $ &~ PF_SPINNING
				
				if mo.state != S_PLAY_CLIMB
					mo.state = S_PLAY_CLIMB
				elseif not (player.cmd.forwardmove or player.cmd.sidemove)
					mo.tics = -1
				elseif mo.tics == -1
					mo.state = S_PLAY_CLIMB
				end
				
				if player.vephtimer == 6
					S_StartSoundAtVolume(mo, sfx_vpfull, 192)
					player.vephsquish = SQUISHTIME/-3
					
					local angle = player.drawangle + ANGLE_90 + ANGLE_11hh
					local dist = 24*FRACUNIT
					local spark = P_SpawnMobjFromMobj(mo,P_ReturnThrustX(mo,angle,dist),
					P_ReturnThrustY(mo,angle,dist), player.height/8, MT_THUNDERCOIN_SPARK)
					spark.fuse = 10
					spark.tracer = mo
					spark.flags2 = $|MF2_LINKDRAW
				end
			end
			
		//Cancel the charge and do a move if we can!
		else
			player.vephcharge = 0
				
			//Super Slime Tail!
			if player.vephtimer >= 6
				player.drawangle = inputangle
				player.swipecancel = nil
				player.vephswipedir = player.drawangle
				player.vephswipedir2 = player.drawangle
				player.vephswipe = 1
				player.glidetime = 1
				
				local dumbgravity = mo.scale/-2*P_MobjFlip(mo)
				if player.vephwaterswitch
					dumbgravity = mo.scale*2/-5*P_MobjFlip(mo)
				elseif mo.eflags & MFE_UNDERWATER
					dumbgravity = $*117/200
				end
				
				local movement = abs(player.cmd.forwardmove) + abs(player.cmd.sidemove) >= 25
				if movement 
					local thrust = mo.scale*40
					if player.normalspeed < skin.normalspeed
						thrust = player.normalspeed
						if mo.eflags & MFE_UNDERWATER
						or (player.gotflag or player.gotcrystal or player.gotflagdebuff)
							thrust = $/3
						end
					elseif not (vephfun.value or gametyperules & GTR_FRIENDLY)
					and mo.eflags & MFE_UNDERWATER
					or (player.gotflag or player.gotcrystal or player.gotflagdebuff)
						thrust = $/3
					end
					P_Thrust(mo, player.drawangle, thrust)
				end
				
				movement = $ and -24 or -36
				if (player.gotflag or player.gotcrystal or player.gotflagdebuff)
					movement = $/4
				end
				mo.momz = dumbgravity*movement
				mo.z = $ + P_MobjFlip(mo)
				player.pflags = $ | PF_JUMPED | PF_NOJUMPDAMAGE
				
				player.vephtimer = -8
				S_StartSound(mo, sfx_vptal2)
				
				if (player.powers[pw_shield] & SH_NOSTACK) == SH_ARMAGEDDON
				and not SKINVARS_NOSPINSHIELD and not BT_SHIELD
					P_BlackOw(player)
				end
			end
		end
	
	//Slime Tail
	elseif player.vephswipe
		//Jump + Spin moves
		if player.vephswipe and player.vephswipe < 3
		and player.vephpressjump == 1 and player.vephtimer < 12
		and (player.glidetime <= 2 or mo.vephwassuper)
		and not (player.gotflag or player.gotcrystal or player.gotflagdebuff)
		
			//Jet Stream
			/*if player.pflags & PF_JUMPED and not P_IsObjectOnGround(mo)
				player.pflags = $ &~ PF_JUMPED
				P_DoJump(player, false)
				
				player.vephswipe = 0
				player.vephtimer = 0
				mo.state = S_VEPH_HOP
				
				player.vephjetstream = true
				
				if mo.eflags & MFE_UNDERWATER
					S_StartSound(mo, sfx_splash)
				else
					S_StartSound(mo, sfx_vpjmp3)
				end
				S_StopSoundByID(mo, skins[player.skin].soundsid[SKSJUMP])
				
			//Water Drive
			else*/
				player.pflags = $ | PF_JUMPDOWN
				if not P_IsObjectOnGround(mo)
					player.glidetime = 3
					player.pflags = $ | PF_JUMPED | PF_NOJUMPDAMAGE &~ PF_THOKKED
				end
				
				if mo.eflags & MFE_UNDERWATER
					S_StartSound(mo, sfx_vpdsh2)
				else
					S_StartSound(mo, sfx_vpdsh1)
				end
				
				player.vephswipe = 0
				player.vephtimer = 0
				player.waterdrive = 1
				
				mo.state = S_PLAY_CLIMB
				player.vephsquish = SQUISHTIME/-3
				player.drawangle = inputangle
				player.pflags = $ | PF_FULLSTASIS &~ PF_JUMPED &~ PF_NOJUMPDAMAGE
				
				P_InstaThrust(mo, 0, 0)
			//end
		end
		
		if mo.state == S_VEPH_JUMP and player.vephswipe != 2
			player.vephswipe = 0
			player.vephtimer = 0
		end
		
		if player.vephswipe
		
		if player.vephswipe >= 3
			if not InSlide(player, true)
				mo.state = S_VEPH_SLIDE_FRWD
				player.panim = PA_ROLL
			end
			player.pflags = $ | PF_SPINNING
		elseif player.vephswipe == 2
			//nothing
		elseif player.vephtimer > 10
			mo.state = S_PLAY_MELEE_LANDING
		else
			mo.state = S_PLAY_MELEE_FINISH
		end
		
		if player.vephswipe < 3 and not (player.cmd.forwardmove or player.cmd.sidemove)
		and player.pflags & PF_DIRECTIONCHAR and player.pflags & PF_ANALOGMODE
			mo.angle = player.cmd.angleturn<<16
		end
		
		//Goop and spin only during the first part of the move
		if player.vephtimer < 8 and not (mo.eflags & MFE_SPRUNG)
			//Add vertical momentum if you hold jump or spin
			if player.swipecancel and ((player.vephtimer == 5
			and (player.cmd.buttons & BT_SPIN or player.cmd.buttons&BT_JUMP)
			and not P_IsObjectOnGround(mo))
			or (player.vephtimer == 0 and player.vephswipe == 2
			and P_IsObjectOnGround(mo)))
				local oldestmomz = mo.momz
				if P_IsObjectOnGround(mo) then mo.z = $ + P_MobjFlip(mo) end
				
				if not player.glidetime
					mo.momz = 0
					player.glidetime = 1
				end
				mo.momz = $ + player.swipecancel
				player.swipecancel = nil
				
				if mo.momz*P_MobjFlip(mo) < 0
					if player.glidetime <= 1
						player.glidetime = 2
						mo.momz = 0
					else
						mo.momz = $/2
					end
				end
				
				if player.vephgoops and #player.vephgoops
					for id,goop in pairs(player.vephgoops) do
						if goop and goop.valid and (goop.state == S_VEPH_GOOP1
						or goop.state == S_VEPH_GOOP2)
							goop.momz = $ - (oldestmomz - mo.momz)
						end
					end
				end
			end
		
			//Thrust you forward a bit
			if player.vephtimer == 0
				local actionspd = FixedMul(player.actionspd, mo.scale)
				if not (vephfun.value or gametyperules & GTR_FRIENDLY)
				and mo.eflags & MFE_UNDERWATER
					actionspd = $/2
				end
		
				if player.pflags & PF_STARTDASH
					P_InstaThrust(mo, player.vephswipedir, mo.scale*40)
				elseif player.vephswipe > 1 and player.speed <= actionspd
					P_Thrust(mo, player.vephswipedir, mo.scale*8)
				else
					P_Thrust(mo, player.vephswipedir, mo.scale*4)
				end
				
				//Shield effects for the slide jump
				if player.vephswipe >= 3
					if (player.powers[pw_shield] & SH_NOSTACK) == SH_BUBBLEWRAP
						S_StartSound(mo, sfx_s3k44)
						player.pflags = $ | PF_SHIELDABILITY
					elseif (player.powers[pw_shield] & SH_NOSTACK) == SH_ELEMENTAL
					or (player.powers[pw_shield] & SH_NOSTACK) == SH_FLAMEAURA
						S_StartSound(mo, sfx_s3k43)
						player.pflags = $ | PF_SHIELDABILITY
					end
				end
			end
			
			if player.vephswipe >= 3
				//Spawn the goop
				/*if player.vephswipe >= 3
					local goop1 = P_SPMAngle(mo, MT_VEPH_GOOP, mo.rollangle)
					local goop2 = P_SPMAngle(mo, MT_VEPH_GOOP, mo.rollangle-ANG20)
					if goop1 and goop1.valid
						goop1.momz = goop1.momy/2
						P_InstaThrust(goop1, player.drawangle-ANGLE_90,goop1.momx/2)
						
						table.insert(player.vephgoops, goop1)
					end
					if goop2 and goop2.valid
						goop2.momz = goop2.momy/2
						P_InstaThrust(goop2, player.drawangle-ANGLE_90,goop2.momx/2)
						
						table.insert(player.vephgoops, goop2)
					end
				end*/
				
				//Spin some more
				//mo.rollangle = $ + (ANGLE_45)
				
				player.vephbouncemomz = mo.momz
			elseif player.vephswipe == 2
				local diff = ANGLE_22h + ANGLE_11hh
				local angle = player.vephtimer*diff
				if not player.vephtimer then S_StartSoundAtVolume(mo, sfx_vptail, 192) end
				for i = 0, 1
					if i >= vephgoopcap.value or player.vephtimer > 5 or player.vephtimer < 0 then break end
					local goop = P_SPMAngle(mo, MT_VEPH_GOOP, angle - diff/2*i, 0)
					if not (goop and goop.valid) then continue end
					goop.momz = goop.momx/2
					P_InstaThrust(goop, player.vephswipedir, goop.momy)
					table.insert(player.vephgoops, goop)
				end
			else
				//Spawn the goop
				for i = 0, 1
					if i >= vephgoopcap.value then break end
					table.insert(player.vephgoops, P_SPMAngle(mo, MT_VEPH_GOOP,
					player.vephswipedir + ANGLE_180 - ANGLE_22h*i, 0))
				end
				
				//Spin some more
				player.vephswipedir = $ + (ANGLE_45)
			end
			
			//Break spinable walls
			player.pflags = $ | PF_DRILLING
			
		elseif player.pflags & PF_DRILLING
			player.pflags = $ &~ PF_DRILLING
			mo.rollangle = 0
		end
		
		//Correct angle
		if player.vephswipe >= 3 and mo.eflags & MFE_SPRUNG
			player.vephswipedir = player.drawangle
		end
		player.drawangle = player.vephswipedir
		if mo.state >= S_VEPH_VSWIPE1 and mo.state <= S_VEPH_VSWIPE5
		and not (mo.state == S_VEPH_VSWIPE5 and mo.tics <= 2)
			player.drawangle = $ + ANGLE_180
		end
		
		if player.vephswipe < 3 and player.vephtimer < 12
			if player.vephpressjump
				player.pflags = $ | PF_JUMPDOWN
			else
				player.pflags = $ &~ PF_JUMPDOWN
			end
			player.pflags = $ | PF_JUMPSTASIS
		end
		
		//End the move when it's lasted long enough
		if (player.vephswipe != 2 and player.vephtimer >= 18)
		or player.vephtimer >= 26 or waterskip
		or (player.vephswipe >= 3 and P_IsObjectOnGround(mo))
		or (mo.eflags & MFE_SPRUNG and not (player.vephswipe >= 3 and player.vephwasinslide))
			if player.vephswipe >= 3
				mo.rollangle = 0
				player.vephdived = true
				
				if P_IsObjectOnGround(mo)
					player.vephtimer = -1
				else
					player.vephtimer = 0
				end
			elseif P_IsObjectOnGround(mo)
				mo.state = S_PLAY_WALK
			else
				mo.state = S_PLAY_FALL
			end
			
			S_StopSoundByID(mo, sfx_vptail)
			S_StopSoundByID(mo, sfx_vpjmp2)
			
			player.vephswipe = 0
			player.vephgoops = {}
			player.pflags = $ &~ PF_DRILLING
			
			if not (player.cmd.forwardmove or player.cmd.sidemove)
				player.drawangle = player.vephswipedir2
			end
			player.vephswipedir = player.drawangle
		else
			player.vephtimer = $ + 1
		end
		
		end
		
	//When you're not in any of those moves
	elseif not player.vephdived
		if not MF2_SPLAT and player.pflags & PF_JUMPED
		and player.pflags & PF_NOJUMPDAMAGE and player.pflags & PF_SPINNING
			player.pflags = $ &~ PF_SPINNING
		end
		
		player.vephtimer = 0
		
		if InSlide(player) and not P_IsObjectOnGround(mo)
		and player.pflags & PF_SPINNING
			player.vephdived = true
			player.vephswim = 0
			return
		end
	end
	
	//Dolphin Dive
	if player.vephdived
		//Extra spring boost if you hold jump
		//Just cancel the dive if you don't
		if player.vephtimer >= 3 and not P_IsObjectOnGround(mo)
			player.pflags = ($|PF_SHIELDABILITY) -- Stop it man
		end	
		if mo.eflags & MFE_SPRUNG
			if not (player.cmd.buttons & BT_JUMP)
				player.vephdived = false
				player.vephtimer = 0
				return
			end
			
			player.vephtimer = 0
			player.glidetime = 0
			player.pflags = $ | PF_STARTJUMP
			
			mo.momz = $*5/4
			mo.momx = $*5/4
			mo.momy = $*5/4
			
			S_StartSound(mo, sfx_sprong)
			S_StartSound(mo,sfx_s3k7e)
			
			VephLand(player)
			
			player.pflags = $ &~ PF_THOKKED 
			mo.eflags = $ &~ MFE_JUSTHITFLOOR
			
		elseif player.pflags & PF_THOKKED
		and mo.momz*P_MobjFlip(mo) > 0
		and P_GetMobjGravity(mo) <= 0
			player.pflags = $ &~ PF_THOKKED 
		end
		
		//Set state and flags
		if not InSlide(player, true)
			mo.state = S_VEPH_SLIDE_FRWD
		end
		player.panim = PA_ROLL
		
		player.pflags = $ | PF_SPINNING
		if not P_IsObjectOnGround(mo)
			player.pflags = $ | PF_JUMPED | PF_NOJUMPDAMAGE
		end
		
		//Bounce or don't bounce based on the player's input!
		if player.vephtimer >= 3
			if player.cmd.buttons & BT_JUMP
			and abs(player.vephbouncemomz) >= 5*mo.scale
				mo.momz = max(abs(player.vephbouncemomz*2/3), mo.scale*10/3)
				*P_MobjFlip(mo)
				player.pflags = $ | PF_STARTJUMP
			elseif P_IsObjectOnGround(mo)
				player.vephdived = false
			end
			player.pflags = $ &~ PF_THOKKED
			player.vephtimer = 0
			
		//Give the player a couple frames to decide whether to bounce or not
		elseif player.vephtimer >= 1
			player.vephsquish = SQUISHTIME
			player.pflags = $ | PF_FULLSTASIS
			player.vephtimer = $ + 1
			if not P_IsObjectOnGround(mo) and not (mo.eflags & MFE_GOOWATER)
				mo.momz = -P_GetMobjGravity(mo)
			end
			
		//Initalize the bouncing hitting the floor
		//and break shatterable ones while we're at it
		elseif (mo.eflags & MFE_JUSTHITFLOOR or player.vephtimer == -1)
			if mo.subsector and mo.subsector.valid
			and mo.subsector.sector and mo.subsector.sector.valid
				for fof in mo.subsector.sector.ffloors()
					if not (fof.flags & FF_EXISTS) continue end // Does it exist?
					if not (fof.flags & FF_BUSTUP) continue end // Is it bustable?
					
					if mo.z + mo.momz + mo.height < fof.bottomheight continue end // Are we too low?
					if mo.z + mo.momz > fof.topheight continue end // Are we too high?  
					
					EV_CrumbleChain(fof) // Crumble
					if fof.master.flags & ML_EFFECT5
						P_LinedefExecute(P_AproxDistance(fof.master.dx, fof.master.dy)>>FRACBITS, mobj, fof.target)
					end
				end
			end
			
			
			if (player.powers[pw_shield] & SH_NOSTACK) == SH_BUBBLEWRAP
				S_StartSound(mo, sfx_s3k44)
			elseif abs(player.vephbouncemomz) > 10*mo.scale
				S_StartSound(mo,sfx_vpbnce)
				vephcircle(mo, MT_GHOST, 8, 4*mo.scale, 0, mo.scale/2)
			else
				S_StartSoundAtVolume(mo,sfx_vplnd1,128)
			end
			S_StopSoundByID(mo,sfx_vpdive)
			
			VephLand(player)
			
			player.vephtimer = 1
			
		else
			//Prepare the bouncemomz for when we bounce
			player.vephbouncemomz = mo.momz
		end
		
		if player.vephtimer and (player.powers[pw_shield] & SH_NOSTACK) != SH_ELEMENTAL
			P_RadiusAttack(mo, mo, 80*FRACUNIT, DMG_WATER, false)
		end
	else
		player.vephbouncemomz = mo.momz
	end
	
	//Swimming camera
	if player.vephswimcamera
		if not player.vephswim
			player.vephswimcamera = $ + 1
		elseif player.vephswimcamera != 1
			player.vephswimcamera = 1
		end
		
		if P_IsObjectOnGround(mo) or not (InSlide(player) or player.vephswim)
			player.vephswimcamera = 0
		end
	end
end)

//Battle Mod Support (Adapted from a general use script by Krabs)
local ScriptLoaded = false
addHook("ThinkFrame", function()
	if not(CBW_Battle) or ScriptLoaded then return end
	ScriptLoaded = true
	local B = CBW_Battle
	
	
	//Priority functions
	local function GarbagePriority4(player)
		if DamageSwipe(player)
			if player.vephswipe < 3
				B.SetPriority(player, 1,1, nil, 1,1, "Slime Tail")
			else
				B.SetPriority(player, 1,1, nil, 1,1, "slide jump")
			end
		elseif player.vephdived and (player.pflags & PF_THOKKED or player.vephtimer)
			B.SetPriority(player, 1,1, nil, 1,1, "Dolphin Dive")
		elseif player.waterdrive
			if InSlide(player)
				B.SetPriority(player, 2,1, nil, 2,1, "Water Drive")
			else
				B.SetPriority(player, 0,0, nil, 0,0, "Water Drive startup")
			end
		elseif InSlide(player)
			if player.mo and P_IsObjectOnGround(player.mo)
				B.SetPriority(player, 0,1, nil, 0,1, "Dolphin Dive slide")
			else
				B.SetPriority(player, 0,0, nil, 0,0, "Dolphin Dive bounce")
			end
		end
	end
	
	//Ability
	local function VephBattle(mo,doaction)
		local player = mo.player
		player.actiontext = "Super Bubble"
		player.actionrings = BUBBLECOST
		player.actionspd = min($, skins["sonic"].actionspd)
		
	
		//Active bubble
		if player.vephbubble
			//Change text to reflect
			if player.vephbubble.valid
			and player.vephbubble.health
				player.actiontext = "\x82Super Bubble"
				
			//Apply cooldown after bubble explodes
			else
				player.actiondebt = player.vephdebt
				B.ApplyCooldown(player, BUBBLECOOLDOWN)
				player.vephbubble = nil
			end
		end
		
		//Can't do action
		if not(B.CanDoAction(player))
			if player.actionstate == 1
				player.actionstate = 0
			end
		return end
		
		//Start move
		if player.actionstate == 0 and doaction == 1 and not player.vephbubble
			S_StartSound(mo, sfx_vpchrg)
			player.actionstate = 1
			player.actiontime = 0
			P_ResetPlayer(player)
			if not P_IsObjectOnGround(mo) and mo.momz*P_MobjFlip(mo) < 0
				mo.momz = 0
			end
			
			B.PayRings(player)
			player.vephdebt = player.actiondebt
			
			vephcircle(mo, MT_THOK,
			12, 4*mo.scale, player.spinheight/2, mo.scale,
			2, mo.color, true, mo.angle, 10)
		end
		
		//During bubble throwing state
		if player.actionstate == 1
			player.actiontime = $ + 1
			mo.state = S_TAILSOVERLAY_RUN
			
			B.DrawAimLine(player, mo.angle)
			player.pflags = $ | PF_JUMPSTASIS
			player.drawangle = mo.angle
			
			mo.movefactor = 0
			mo.momx = $*31/32
			mo.momy = $*31/32
			if player.speed and P_IsObjectOnGround(mo)
			and not (player.actiontime % 3)
				P_SpawnSkidDust(player, mo.radius, true)
			end
			
			if player.actiontime == BUBBLECHARGETIME
				local bubble = P_SpawnMobjFromMobj(mo, 0,0,0, MT_VEPH_BUBBLE)
				bubble.target = mo
				bubble.color = mo.color
				bubble.colorized = true
				bubble.angle = mo.angle
				
				player.vephbubble = bubble
				player.actionstate = 0
				player.actiontime = 0
				player.actiontext = "\x82Super Bubble"
				
				player.vephdebt = player.actiondebt
				player.actiondebt = 0
				B.ApplyCooldown(player, 0)
				
				//Ring effect
				local thok = P_SpawnMobjFromMobj(mo, 0,0,0, MT_THOK)
				thok.spritexscale = FRACUNIT/2
				thok.spriteyscale = FRACUNIT/2
				thok.destscale = thok.scale*8
				
				thok.fuse = thok.tics
				thok.sprite = states[bubble.info.seestate].sprite
				thok.frame = (states[bubble.info.seestate].var1 + 1) | (states[bubble.info.seestate].frame &~ FF_FRAMEMASK)
				
				P_InstaThrust(mo, mo.angle, -FixedMul(bubble.info.speed, mo.scale))
				mo.state = S_VEPH_JUMP
				//S_StopSoundByID(mo, sfx_vpchrg)
			end
		end
	end
	
	//Stats
	B.SkinVars["veph"] = {
		flags = SKINVARS_GUARD,
		weight = 95,
		special = VephBattle,
		func_priority_ext = GarbagePriority4
	}
	print("\x89\VephPass, Patch by Rush & Lumyni")

	print("\x82\It's time to get Wet! Veph Slides in!")

	if SKINVARS_NOSPINSHIELD
		B.SkinVars["veph"].flags = $|SKINVARS_NOSPINSHIELD
	end
	
	//Decrease defense when slimed
	local VephDoPriority = B.DoPriority
	B.DoPriority = function(player)
		VephDoPriority(player)
		
		local slime = player.mo and player.mo.vephslime
		if slime and slime.valid and slime.cusval
		and not (gametyperules & GTR_FRIENDLY)
			player.battle_def = max($ - slime.cusval, 0)
			player.battle_sdef = max($ - slime.cusval, 0)
		end
	end
end)