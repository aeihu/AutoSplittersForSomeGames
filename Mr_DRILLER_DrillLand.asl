state("DrillLand")
{
	byte result_ui : 0x002C74E8, 0x30, 0xA8, 0x50, 0x220, 0x30, 0x370, 0x9B0;
	int main_ui : 0x002C74F0, 0x88, 0x50, 0x228, 0x220, 0x30, 0xA8, 0xEC8;
	int title_ui : 0x002C74F0, 0x88, 0x50, 0x228, 0x220, 0x30, 0xA8, 0x1040;
	byte gamestatus : 0x2B05CB; // 7FF69B6305C8
	byte stage : 0x2B05A8; // 7FF69B6305A8
	int between : 0x002B0570, 0x98, 0xB0, 0x208, 0x100, 0x680, 0x8, 0xFB0;
	//byte select_charater_ui : 0x002B3CC8, 0x130, 0x68, 0x930, 0xA8, 0x8, 0x88, 0x9B1;
	//byte guiwu_hp : 0x002B05D0, 0x18, 0x1C4, 0x8, 0x20, 0x8, 0x8, 0x608; 
	//byte dixiacheng_hp : 0x002B0578, 0x0, 0x408, 0x38, 0x90, 0x8, 0x68, 0x598; 
	//byte star_hp : 0x002ACED0, 0x20, 0x10, 0xA08, 0x78, 0x10, 0x1B0, 0x6DC; 
}

startup
{

}

init
{
	vars.flag_reset = false;
	vars.boss = false;
	vars.boss_count = 0;
	//vars.is_clear = true;
	//vars.current_guanka = -1;
}

start
{
	if (old.main_ui == 67109888 && current.main_ui == 1065353216){
		vars.flag_reset = false;
		vars.boss_count = 0;
		vars.boss = false;
		return true;
	}
}

split
{
	if (!vars.flag_reset && current.main_ui == 0)
		vars.flag_reset = true;
		
	if (old.result_ui == 1 && current.result_ui == 0 && current.stage == 13)
		return true;
	
	if (current.stage == 10)
		vars.boss_count = 0;
		
	if (current.stage == 4 && old.stage == 10){
		vars.boss = true;
	}else if (current.stage == 3 || current.stage == 13){
		vars.boss = false;
	}
	
	if (vars.boss && current.gamestatus == 0 && old.gamestatus == 1){
		if (current.between != 50){
			if (vars.boss_count < 1){
				vars.boss_count += 1;
				//print("between: " + current.between.ToString() + " - " + vars.boss_count.ToString() + " - " + current.stage.ToString() + " - " + current.gamestatus.ToString());
				//if (current.between == 50) 
			}else{
				vars.boss_count = 0;
				return true;
			}
		}else{
			vars.boss_count = 0;
		}
	}
}

reset
{
	if (current.title_ui == 65542 && vars.flag_reset && current.stage != 13){
		vars.flag_reset = false;
		return true;
	}
}
