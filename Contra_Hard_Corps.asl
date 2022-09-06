state("game")
{
	byte game_ui_selector : 0x01BAA228, 0x84, 0x34, 0x694, 0x20, 0x308, 0x58, 0xA8;
	byte game_ui_layer_no : 0x01BAA228, 0x84, 0x34, 0x694, 0x20, 0x308, 0x58, 0x4;
}

init
{
    vars.is_searching = false;
    vars.is_got_address = false;
	vars.flag_start = null;
	vars.life_num = null;
	vars.stage_clear = null;
	vars.hidden_boss = null;
	vars.is_talking = null;
	vars.flag_hidden_boss = false;
	vars.ticks = 0;
	vars.stage_no = 1;
}

update
{
	if (current.game_ui_layer_no == 5 && old.game_ui_layer_no == 4)
		vars.is_got_address = false;
	
	if (!vars.is_got_address){
		if (!vars.is_searching){
			vars.threadScan = new Thread(() =>
			{
				vars.is_searching = true;
				byte flag_load = 0;
				IntPtr ptr = IntPtr.Zero;
				print("------------Thread start------------");
				foreach (var page in game.MemoryPages()) {
					var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);

					var sig_state = new SigScanTarget(0x0, //0x188, 
						"?0 ?0 8D ?0 10 40 8D 20");
						//20 10 8D 40 10 40 8D 20
					ptr = scanner.Scan(sig_state);

					if (ptr != IntPtr.Zero){
						if (flag_load < 0){
							ptr = IntPtr.Zero;
							flag_load += 1;
						}
						else{
							print("Scaner found the pointer: " + ptr.ToString("x"));
							vars.is_got_address = true;
							vars.flag_start = new MemoryWatcher<byte>(new DeepPointer(ptr + 0x16E));
							vars.life_num = new MemoryWatcher<byte>(new DeepPointer(ptr + 0x188));
							vars.stage_clear = new MemoryWatcher<byte>(new DeepPointer(ptr + 0x13));//0x11
							vars.is_talking = new MemoryWatcher<byte>(new DeepPointer(ptr + 0x59));
							vars.hidden_boss = new MemoryWatcher<short>(new DeepPointer(ptr + 0xFC6));
							
							break;
						}
					}
				}
				if (ptr == IntPtr.Zero)
					print("Scaner found no pointer");
				print("------------Thread end------------");
				vars.is_searching = false;
			});
			//[15440] Scaner found the pointer: 10316c00 

			vars.threadScan.Start();
		}
	}
	else{
		if (vars.stage_clear != null){
			vars.stage_clear.Update(game);
			if (vars.stage_clear.Changed)
				print("stage_clear: " + vars.stage_clear.Current.ToString() + " - " + vars.stage_clear.Old.ToString());
		}
		if (vars.life_num != null){
			vars.life_num.Update(game);
			if (vars.life_num.Changed)
				print("life_num: " + vars.life_num.Current.ToString() + " - " + vars.life_num.Old.ToString());
		}
		if (vars.flag_start != null){
			vars.flag_start.Update(game);
			//if (vars.flag_start.Changed)
			//	print("flag_start: " + vars.flag_start.Current.ToString() + " - " + vars.flag_start.Old.ToString());
		}
		if (vars.hidden_boss != null){
			vars.hidden_boss.Update(game);
			if (vars.hidden_boss.Changed){
				print("hidden_boss: " + vars.hidden_boss.Current.ToString() + " - " + vars.hidden_boss.Old.ToString());
			}
		}
		if (vars.is_talking != null){
			vars.is_talking.Update(game);
			if (vars.is_talking.Changed){
				print("is_talking: " + vars.is_talking.Current.ToString() + " - " + vars.is_talking.Old.ToString());
			}
		}
	}
}

start
{
	if (vars.flag_start != null && vars.flag_start.Current != 0xA0 && vars.flag_start.Current != 0x00 && vars.flag_start.Old == 0xA0){
		vars.flag_hidden_boss = false;
		vars.ticks = System.DateTime.Now.Ticks / 10000000 + 2;
		vars.stage_no = 1;
		return true;
	}
}

split
{
	if (vars.stage_clear != null && vars.stage_clear.Changed && vars.stage_clear.Current == 1 && vars.ticks < (System.DateTime.Now.Ticks / 10000000)){
		vars.stage_no += 1;
		return true;
	}
		
	if (vars.flag_hidden_boss && vars.hidden_boss.Current == 0 && vars.hidden_boss.Changed)
		return true;
		
	if (vars.hidden_boss.Current == 0x2EE && vars.stage_no != 1)
		vars.flag_hidden_boss = true;
		
	if (vars.stage_clear.Current == 0){
		if (vars.is_talking.Current == 1 || vars.stage_clear.Changed)
			vars.ticks = System.DateTime.Now.Ticks / 10000000 + 2;
	}
}

reset
{
	//if (vars.life_num != null && vars.life_num.Current == 0)
	//	return true;[13760] Scaner found the pointer: 1d6ea20e 

}
