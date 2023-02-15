state("Mini Motorways")
{
    int cityIndex : "UnityPlayer.dll", 0x0142B8D4, 0x8, 0x0, 0x1C, 0x1C, 0x34, 0x18, 0xC4;// Motorways.Views.MapSelectScreen
    int cityDef : "UnityPlayer.dll", 0x0142B8D4, 0x8, 0x0, 0x1C, 0x1C, 0x34, 0x18, 0x114;// Motorways.Views.MapSelectScreen
    //selet zero int points : "mono-2.0-bdwgc.dll", 0x003A2C68, 0x48, 0xF4C, 0xC8, 0x28;//Motorways.Views.ScoreView:Tick for points
    int points : "mono-2.0-bdwgc.dll", 0x003A2C68, 0x68, 0x698, 0x24, 0x30, 0x1C, 0x104, 0xA8;//Motorways.Views.ScoreView:Tick for points3
    float tranIn : "UnityPlayer.dll", 0x0142B8D4, 0x8, 0x0, 0x1C, 0x1C, 0x34, 0x18, 0x74;// Motorways.Views.MapSelectScreen
}

startup
{
	settings.Add("per_score_split", true, "Per Score Splits");
	settings.Add("p50", false, "+50", "per_score_split");
	settings.Add("p100", true, "+100", "per_score_split");
	settings.Add("p200", false, "+200", "per_score_split");
	settings.Add("p300", false, "+300", "per_score_split");
	settings.Add("full_game", false, "Full Game");
}

init
{
	vars.times = 1;
	vars.per = 0;
	vars.reZero	= false;
}

start
{
	if (current.cityDef != old.cityDef && old.cityDef == 0 && current.cityIndex > 1 && current.cityIndex < 100){
		vars.times = 1;
		vars.per = 0;
		vars.reZero	= false;
		if (settings["per_score_split"]){
			if (settings["p50"]){
				vars.per += 50;
			}
			
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


split
{
	if (settings["full_game"]){
		if (vars.reZero){
			if (current.points >= vars.per){
				vars.reZero	= false;
				return true;
			}
		}
		else{
			if (current.points == 0)
				vars.reZero	= true;
		}
	}else{
		if (vars.reZero){
			if (current.points >= vars.per * vars.times){
				vars.times += 1;
				return true;
			}
		}
		else{
			if (current.points == 0)
				vars.reZero	= true;
		}
	}
}

reset
{
	if (!settings["full_game"] && current.tranIn >= 0.05f && current.tranIn <= 0.95f){
		return true;
	}
}
