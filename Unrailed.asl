state("UnrailedGame")
{
	byte running : "SDL2.dll", 0x00161FE0, 0x3C, 0x18, 0x30, 0x50, 0x8, 0x1FC, 0xF80;
	byte g_status : "gameoverlayrenderer64.dll", 0x00169D58, 0x140, 0x98, 0xA8, 0x158, 0xE08, 0x1D0, 0x430, 0x68, 0x24C;
	float s_bar : "libfmodstudio.dll", 0x00144CD8, 0x318, 0xF8, 0x30, 0x18, 0x10, 0x68, 0x8, 0x1E8, 0x2BC;
	//byte loading_time : "SDL2.dll", 0x00161FE0, 0x3C, 0x18, 0x30, 0x50, 0x8, 0x1FC, 0xFAC;
	
	//int g_start : "SDL2.DLL", 0x00163C40, 0x8E0, 0xA0, 0x158, 0x90, 0x70, 0x168, 0xD70; //3103392971[5468] between: -1191574325 
	//byte rail_complete : "SDL2.DLL", 0x00163C40, 0x840, 0x0, 0x8, 0x0, 0xEC, 0x8E8;
}

startup
{

}

init
{
	vars.flag_complete = true;
}


start
{
	print("start: " + current.g_status.ToString() + " - " + current.running.ToString());
	if (current.g_status == 1){
		return true;
	}
}

split
{
	print("split: " + current.g_status.ToString() + " - " + current.running.ToString() + " * " + current.s_bar.ToString());
	if (vars.flag_complete){
		if (current.s_bar < 0.00001)
			vars.flag_complete = false;
	}else{
		if (current.s_bar > 0.99999){
			vars.flag_complete = true;
			return true;
		}
	}
}

reset
{
	if (current.running == 0 && current.g_status != 1){
		print("reset: " + current.g_status.ToString() + " - " + current.running.ToString());
		return true;
	}
}
