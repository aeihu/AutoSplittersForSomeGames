state("UnrailedGame")
{
	//int gamemanager : "SDL2.dll", 0x001634F0, 0x408, 0x1D0, 0x88, 0x568, 0x1C0, 0x20, 0x40, 0x40, 0x10, 0x0; old
	//IJ.aXE(Hm).aQi(Ie).awT(List<IE>).CgS(jb).BDU(NN).Cir(e<JZ>)
    //int gamemanager : "SDL2.dll", 0x001634F0, 0x268, 0x78, 0x178, 0x128, 0xD0, 0xE8, 0x0;
    //int gamemanager : "SDL2.dll", 0x001634F0, 0x268, 0x78, 0x178, 0x128, 0xD0, 0xE8, 0x0, 0xC0, 0x10, 0x20;
	//byte rail_complete : "SDL2.dll", 0x00162C88, 0xE0, 0x18, 0x5B0, 0x230, 0x0, 0x18, 0x70, 0x60, 0x188, 0xD1;
	//byte game_mode : "SDL2.dll", 0x00162E58, 0x1F8, 0x130, 0x20, 0x5B0, 0xAD8, 0x48, 0x28, 0x12C, 0x1C0, 0x30;
    
	byte running : "SDL2.dll", 0x00161FE0, 0x3C, 0x18, 0x30, 0x50, 0x8, 0x1FC, 0xF80;
	byte g_status : "gameoverlayrenderer64.dll", 0x00169D58, 0x140, 0x98, 0xA8, 0x158, 0xE08, 0x1D0, 0x430, 0x68, 0x24C;
}

startup
{
	settings.Add("endless", true, "Endless Mode");
}

init
{
	vars.flag_thread = true;
	vars.ticks = 0;
	vars.reset_ticks = 0;
	vars.flag_sign = false;
	vars.rail_complete = null;
}

start
{
	//if (current.g_status != old.g_status)
	//	print("start: " + current.g_status.ToString() + " - " + old.g_status.ToString());
	if (current.g_status == 1 && old.g_status == 3){
		vars.ticks = System.DateTime.Now.Ticks / 10000000 + 15;
		vars.reset_ticks = System.DateTime.Now.Ticks / 10000000 + 5;
		vars.flag_sign = false;
		vars.flag_thread = true;
		return true;
	}
	
	if (!settings["endless"]){
		vars.threadScan = new Thread(() =>
		{
			IntPtr ptr = IntPtr.Zero;
			print("------------Thread start------------");
			foreach (MemoryBasicInformation mbi in game.MemoryPages()) {
				var scanner = new SignatureScanner(game, mbi.BaseAddress, (int)mbi.RegionSize.ToUInt64());

				var sig_state = new SigScanTarget(0x188, 
					"?? ?? ?? ?? F? 7F 00 00 ?? ?? ?? ?? ?? 0? 00 00 ?? ?? ?? ?? ?? 0? 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 F9 00 00 00 00 01 01 00 00 00 00 00");
					
				ptr = scanner.Scan(sig_state);

				if (ptr != IntPtr.Zero){
					print("Scaner found the pointer: " + ptr.ToString("x"));
					vars.flag_sign = true;
					vars.rail_complete = new MemoryWatcher<bool>(new DeepPointer(ptr, 0xd1));
					break;
				}
				
				sig_state = new SigScanTarget(0x188, 
					"?? ?? ?? ?? F? 7F 00 00 ?? ?? ?? ?? ?? 0? 00 00 ?? ?? ?? ?? ?? 0? 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 FB 00 00 00 00 01 01 00 00 00 00 00");
					
				ptr = scanner.Scan(sig_state);
				
				if (ptr != IntPtr.Zero){
					print("Scaner found the pointer: " + ptr.ToString("x" ));
					vars.flag_sign = true;
					vars.rail_complete = new MemoryWatcher<bool>(new DeepPointer(ptr, 0xd1));
					break;
				}
			}
			if (ptr == IntPtr.Zero)
				print("Scaner found no pointer");
			print("------------Thread end------------");
		});
	}
}

update
{
	if (!settings["endless"])
		if (vars.rail_complete != null){
			vars.rail_complete.Update(game);
			if (vars.rail_complete.Changed)
				print("rail_complete: " + vars.rail_complete.Current.ToString());
		}
}

split
{
	//if (current.g_status != old.g_status)
	//	print("g_status: " + current.g_status.ToString() + " - " + old.g_status.ToString());
	
	if (vars.ticks < (System.DateTime.Now.Ticks / 10000000)){
		if (settings["endless"]){
			if (current.g_status == 1 && current.g_status != old.g_status){
				print("split: " + current.g_status.ToString() + " - " + old.g_status.ToString() + " : " + vars.ticks.ToString() + " : " + (System.DateTime.Now.Ticks / 10000000).ToString());
				vars.ticks = System.DateTime.Now.Ticks / 10000000 + 15;
				return true;
			}
		}else{
			if (vars.flag_sign){
				//print("rail_complete: " + vars.rail_complete.Current.ToString());
				return vars.rail_complete == null ? false : vars.rail_complete.Current;
			}
			else{
				if (vars.flag_thread){
					vars.flag_thread = false;
					vars.threadScan.Start();
				}
			}
		}
	}
}

reset
{
	if (current.running == 0 && vars.reset_ticks < (System.DateTime.Now.Ticks / 10000000)){
		return true;
	}
}
