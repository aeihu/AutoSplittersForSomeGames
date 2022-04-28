state("MiniMetro")
{
    //int main : "UnityPlayer.dll", 0x014390C8, 0x30, 0x44, 0x60, 0x3C, 0x68, 0x38, 0x0;
	int menu_option : "UnityPlayer.dll", 0x014390C8, 0x30, 0x44, 0x60, 0x3C, 0x68, 0x38, 0x0, 0x1C, 0x8, 0x38;
	int menucity_game : "UnityPlayer.dll", 0x014390C8, 0x30, 0x44, 0x60, 0x3C, 0x68, 0x38, 0x0, 0x1C, 0x8, 0x10, 0x28;
	bool menucity_game_isin : "UnityPlayer.dll", 0x014390C8, 0x30, 0x44, 0x60, 0x3C, 0x68, 0x38, 0x0, 0x1C, 0x8, 0x10, 0x28, 0xC, 0x7D;
	int game_score : "UnityPlayer.dll", 0x014390C8, 0x30, 0x44, 0x60, 0x3C, 0x68, 0x38, 0x0, 0x1C, 0x8, 0x54, 0x10;
	int game_state : "UnityPlayer.dll", 0x014390C8, 0x30, 0x44, 0x60, 0x3C, 0x68, 0x38, 0x0, 0x1C, 0x8, 0xC8;
}

startup
{
	settings.Add("gameover_split", true, "Game Over Split");
	settings.Add("unlock_split", true, "Unlock Split");
	settings.Add("per_score_split", true, "Per Score Splits");
	settings.Add("p100", true, "+100", "per_score_split");
	settings.Add("p200", false, "+200", "per_score_split");
	settings.Add("p300", false, "+300", "per_score_split");
	settings.Add("is_loading", false, "Pause For Loading");
}

init
{
	vars.flag = false;
	vars.times = 1;
	vars.per = 0;
}

start
{
	if (current.menucity_game != old.menucity_game && current.menucity_game_isin != old.menucity_game_isin && current.menucity_game_isin && (current.menu_option == 2 || current.menu_option == 12)){
		vars.flag = false;
		vars.times = 1;
		vars.per = 0;
		if (settings["per_score_split"]){
			if (settings["p100"]){
				vars.per += 100;
			}
			
			if (settings["p200"]){
				vars.per += 200;
			}
			
			if (settings["p300"]){
				vars.per += 300;
			}
			
			if (vars.per < 1){
				vars.per = 100;
			}
		}
		else{
			vars.per = 100;
		}
		
		return true;
	}
}

isLoading
{
	if (current.game_state == 2 && settings["is_loading"])
	{
		return true;
	}
	else
	{
		return false;
	}
}

split
{
	if (settings["gameover_split"]){
		if (current.game_state == 1){
			return true;
		}
	}
	
	if (settings["unlock_split"]){
		if (current.game_state == 11){
			return true;
		}
	}
	
	if (vars.flag){
		if (current.game_score >= vars.per * vars.times){
			vars.times += 1;
			return true;
		}
	}
	else{
		if (current.game_score > 10 && current.game_score < 70 ){
			vars.flag = true;
		}
	}
}

reset
{
	if (current.menu_option == 2 && current.menucity_game_isin != old.menucity_game_isin && !current.menucity_game_isin){
		return true;
	}
}
