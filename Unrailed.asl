state("UnrailedGame")
{
	//int gamemanager : "SDL2.dll", 0x001634F0, 0x408, 0x1D0, 0x88, 0x568, 0x1C0, 0x20, 0x40, 0x40, 0x10, 0x0; old
	//IJ.aXE(Hm).aQi(Ie).awT(List<IE>).CgS(jb).BDU(NN).Cir(e<JZ>)
    //int gamemanager : "SDL2.dll", 0x001634F0, 0x268, 0x78, 0x178, 0x128, 0xD0, 0xE8, 0x0;
    //int gamemanager : "SDL2.dll", 0x001634F0, 0x268, 0x78, 0x178, 0x128, 0xD0, 0xE8, 0x0, 0xC0, 0x10, 0x20;
    
	byte running : "SDL2.dll", 0x00161FE0, 0x3C, 0x18, 0x30, 0x50, 0x8, 0x1FC, 0xF80;
	byte g_status : "gameoverlayrenderer64.dll", 0x00169D58, 0x140, 0x98, 0xA8, 0x158, 0xE08, 0x1D0, 0x430, 0x68, 0x24C;
	//byte rail_complete : "SDL2.dll", 0x00162C88, 0xE0, 0x18, 0x5B0, 0x230, 0x0, 0x18, 0x70, 0x60, 0x188, 0xD1;
	//byte game_mode : "SDL2.dll", 0x00162E58, 0x1F8, 0x130, 0x20, 0x5B0, 0xAD8, 0x48, 0x28, 0x12C, 0x1C0, 0x30;
}

startup
{
}

init
{
	vars.ticks = 0;
}

start
{
	if (current.g_status != old.g_status)
		print("start: " + current.g_status.ToString() + " - " + old.g_status.ToString());
	if (current.g_status == 1 && old.g_status == 3){
		vars.ticks = System.DateTime.Now.Ticks / 10000000 + 20;
		return true;
	}
}

update
{
}

split
{
	if (current.g_status != old.g_status)
		print("g_status: " + current.g_status.ToString() + " - " + old.g_status.ToString());
	
	if (current.g_status == 1 && current.g_status != old.g_status && vars.ticks < (System.DateTime.Now.Ticks / 10000000)){
		print("split: " + current.g_status.ToString() + " - " + old.g_status.ToString() + " : " + vars.ticks.ToString() + " : " + (System.DateTime.Now.Ticks / 10000000).ToString());
		vars.ticks = System.DateTime.Now.Ticks / 10000000 + 20;
		return true;
	}
}

reset
{
	if (current.running == 0 && old.running != current.running){
		print("reset: " + current.g_status.ToString() + " - " + old.g_status.ToString());
		return true;
	}
}
