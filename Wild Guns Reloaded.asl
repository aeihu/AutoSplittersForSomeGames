state("WildGunsReloaded")
{
    int stage_clear_num : "mono.dll", 0x001F46AC, 0x80, 0xFC4;
    int player_selected : 0x01093FAC, 0x50, 0x4, 0x8, 0x8, 0x34;
    int muti_player_selected : 0x0100CCA8, 0x30, 0x168, 0x16C, 0xC, 0x38, 0x2C;
    int go_title : 0x01093FAC, 0x40, 0x0, 0x8, 0x8, 0x6C;
	int boss_count : "mono.dll", 0x001F46AC, 0x80, 0xF8C, 0xDC;
}

init
{
	vars.last_stage_scene = 0;
	vars.current_stage = 1;
}

start
{
    if (current.player_selected == 3 || current.muti_player_selected == 3){
	    vars.last_stage_scene = 0;
	    vars.current_stage = 1;
        return true;
    }
}

split
{
    if (vars.current_stage == current.stage_clear_num && current.stage_clear_num <= 5){
        vars.current_stage += 1; 
        return true;
    }else if (vars.current_stage > 5){
        if (current.boss_count < old.boss_count && current.boss_count == 0){
            if (vars.last_stage_scene >= 3){
	            vars.last_stage_scene = 0;
                return true;
            }else{
                vars.last_stage_scene += 1;
            }
        }
    }
}

reset
{
    if (current.go_title == 3){
        return true;
    }
}
