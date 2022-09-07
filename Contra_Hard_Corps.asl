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
	vars.flag_rest = null;
	vars.stage_clear = null;
	vars.hidden_boss = null;
	vars.select_idx = null;
	vars.flag_select = null;
	vars.lost_control = null;
	vars.is_talking = null;
	
	vars.flag_hidden_boss = false;
	vars.is_selecting = false;
	vars.ticks = 0;
	vars.stage_no = 1;
	vars.route = 0;
	vars.counter_for_lost_control = 0;
}

update
{
	if (current.game_ui_layer_no == 5 && old.game_ui_layer_no == 4)
		vars.is_got_address = false;
	
	if (!vars.is_got_address){
		if (!vars.is_searching){
			//vars.threadScan = new Thread(() =>
			//{
				vars.is_searching = true;
				byte flag_load = 0;
				IntPtr ptr = IntPtr.Zero;
				print("------------Search start------------");
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
							vars.flag_start = new MemoryWatcher<byte>(new DeepPointer(ptr + 0x16E));//0x16E MAN 0x169 KUAI 0x172 Y zuobiao 0x173 ??
							vars.flag_rest = new MemoryWatcher<ushort>(new DeepPointer(ptr - 0x572));
							vars.stage_clear = new MemoryWatcher<byte>(new DeepPointer(ptr + 0x13));//0x11
							vars.is_talking = new MemoryWatcher<byte>(new DeepPointer(ptr + 0x59));
							
							vars.select_idx = new MemoryWatcher<byte>(new DeepPointer(ptr + 0x6A));
							vars.flag_select = new MemoryWatcher<byte>(new DeepPointer(ptr + 0x6D));
							
							vars.lost_control = new MemoryWatcher<byte>(new DeepPointer(ptr + 0x68));
							vars.hidden_boss = new MemoryWatcher<short>(new DeepPointer(ptr + 0xFC6));
							
							break;
						}
					}
				}
				if (ptr == IntPtr.Zero)
					print("Scaner found no pointer");
				print("------------Search end------------");
				vars.is_searching = false;
			//});
			//vars.threadScan.Start();
		}
	}
	else{
		if (vars.stage_clear != null){
			vars.stage_clear.Update(game);
			if (vars.stage_clear.Changed)
				print("stage_clear: " + vars.stage_clear.Current.ToString() + " - " + vars.stage_clear.Old.ToString());
		}
		if (vars.flag_rest != null){
			vars.flag_rest.Update(game);
			if (vars.flag_rest.Changed)
				print("flag_rest: " + vars.flag_rest.Current.ToString("x") + " - " + vars.flag_rest.Old.ToString("x"));
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
		if (vars.lost_control != null){
			vars.lost_control.Update(game);
			if (vars.lost_control.Changed){
				print("lost_control: " + vars.lost_control.Current.ToString() + " - " + vars.lost_control.Old.ToString());
			}
		}
		if (vars.select_idx != null){
			vars.select_idx.Update(game);
			if (vars.select_idx.Changed){
				print("select_idx: " + vars.select_idx.Current.ToString() + " - " + vars.select_idx.Old.ToString());
			}
		}
		if (vars.flag_select != null){
			vars.flag_select.Update(game);
			if (vars.flag_select.Changed){
				if (vars.flag_select.Current == 3)
					vars.is_selecting = true;
				print("flag_select: " + vars.flag_select.Current.ToString() + " - " + vars.flag_select.Old.ToString());
			}
		}
		
		if (vars.is_selecting){
			if ((vars.flag_select.Changed && vars.flag_select.Current == 1) || (vars.is_talking.Changed && vars.is_talking.Current == 0)){
				vars.route += (vars.route == 0 ? 10 : 1) * (vars.select_idx.Current + 1);
				print("route: " + vars.route.ToString());
				vars.is_selecting = false;
			}
		}
	}
}

start
{
	//if (vars.flag_start != null && vars.flag_start.Current == 0x80 && vars.flag_start.Old == 0x40){ // KUAI
	//if (vars.flag_start != null && vars.flag_start.Current == 0xC8 && vars.flag_start.Changed){ // Y zuobiao
	//if (vars.flag_start != null && vars.flag_start.Current == 1 && vars.flag_start.Changed){ // Y ??
	if (vars.flag_start != null && vars.flag_start.Current != 0xA0 && vars.flag_start.Current != 0x00 && vars.flag_start.Old == 0xA0){ //MAN
		vars.flag_hidden_boss = false;
		vars.ticks = System.DateTime.Now.Ticks / 10000000 + 4;
		vars.stage_no = 1;
		vars.route = 0;
		vars.counter_for_lost_control = 0;
		vars.is_selecting = false;
		return true;
	}
}

split
{
	if (vars.stage_clear != null){
		if (vars.stage_clear.Changed && vars.stage_clear.Current == 1 && vars.ticks < (System.DateTime.Now.Ticks / 10000000)){
			vars.stage_no += 1;
			print("stage_no: " + vars.stage_no.ToString());
			return true;
		}
		
		if (vars.stage_clear.Current == 0){
			if (vars.is_talking.Current == 1 || vars.stage_clear.Changed)
				vars.ticks = System.DateTime.Now.Ticks / 10000000 + 4;
		}
	}
	
	if (vars.hidden_boss != null){
		if (vars.flag_hidden_boss && vars.hidden_boss.Current == 0 && vars.hidden_boss.Changed){
			vars.flag_hidden_boss = false;
			return true;
		}
			
		if (vars.stage_no == 3 && vars.hidden_boss.Current == 0x2EE)
			vars.flag_hidden_boss = true;
	}
	
	if (vars.route == 12 && vars.stage_no == 5){
		if (vars.lost_control != null && vars.lost_control.Current == 1 && vars.lost_control.Changed){
			vars.counter_for_lost_control += 1;
			print("counter_for_lost_control: " + vars.counter_for_lost_control.ToString());
			if (vars.counter_for_lost_control == 5)
				return true;
		}
	}
}

reset
{
	if (vars.flag_rest != null && vars.flag_rest.Current == 0xD000) //0xD000 or 0xD480
		return true;
}
