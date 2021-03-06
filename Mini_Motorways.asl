state("Mini Motorways")
{
    //int state : "UnityPlayer.dll", 0x01469AF0, 0x58, 0x1C, 0xC, 0x50, 0x20, 0xE4, 0x37C;
    int cityIndex : "UnityPlayer.dll", 0x0142B8D4, 0x8, 0x0, 0x1C, 0x1C, 0x34, 0x18, 0xC4;
    int cityDef : "UnityPlayer.dll", 0x0142B8D4, 0x8, 0x0, 0x1C, 0x1C, 0x34, 0x18, 0x108;
    int points : "UnityPlayer.dll", 0x0142C480, 0x0, 0x44, 0x1C, 0x3C, 0x3C, 0x20, 0x14;
    float tranIn : "UnityPlayer.dll", 0x0142B8D4, 0x8, 0x0, 0x1C, 0x1C, 0x34, 0x18, 0x74;
}

startup
{
	settings.Add("per_score_split", true, "Per Score Splits");
	settings.Add("p50", false, "+50", "per_score_split");
	settings.Add("p100", true, "+100", "per_score_split");
	settings.Add("p200", false, "+200", "per_score_split");
	settings.Add("p300", false, "+300", "per_score_split");
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

reset
{
	if (current.tranIn >= 0.05f && current.tranIn <= 0.95f){
		return true;
	}
}
