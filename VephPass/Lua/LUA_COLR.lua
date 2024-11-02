//Main Skin Color
skincolors[freeslot("SKINCOLOR_CLAM")] = {
	name = "Clam",
	ramp = {208,209,210,202,203,204,204,205,206,207,207,207,44,45,46,47},
	invcolor = SKINCOLOR_TEAL,
	invshade = 4, 
	chatcolor = V_ROSYMAP,
	accessible = true
}
M_MoveColorAfter(SKINCOLOR_CLAM, SKINCOLOR_FANCY)

//Sol Color (from https://mb.srb2.org/addons/dirks-custom-super-colors.952/)
if rawget(_G, "SKINCOLOR_SUPERWAVE1") != nil then return end

skincolors[freeslot("SKINCOLOR_SUPERWAVE1")] = {
    name = "Super Wave 1",
    ramp = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 120, 121, 141, 135, 136, 137},
    accessible = false
}
skincolors[freeslot("SKINCOLOR_SUPERWAVE2")] = {
    name = "Super Wave 2",
    ramp = {0, 0, 0, 0, 120, 120, 121, 121, 141, 141, 135, 135, 136, 136, 137, 137},
    accessible = false
}
skincolors[freeslot("SKINCOLOR_SUPERWAVE3")] = {
    name = "Super Wave 3",
    ramp = {0, 0, 120, 120, 121, 121, 141, 141, 135, 135, 136, 136, 137, 137, 137, 137},
    accessible = false
}
skincolors[freeslot("SKINCOLOR_SUPERWAVE4")] = {
    name = "Super Wave 4",
    ramp = {0, 120, 121, 141, 135, 136, 137, 137, 174, 174, 168, 168, 169, 169, 159, 253},
    accessible = false
}
skincolors[freeslot("SKINCOLOR_SUPERWAVE5")] = {
    name = "Super Wave 5",
    ramp = {120, 121, 141, 135, 136, 137, 137, 174, 174, 168, 168, 169, 169, 253, 253, 254},
    accessible = false
}