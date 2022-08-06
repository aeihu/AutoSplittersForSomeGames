state("Snake Force")
{
    //int gamemanager : "UnityPlayer.dll", 0x019EAF78, 0x0, 0xF28, 0x28, 0x0, 0x60, 0x0;
    int current_level : "UnityPlayer.dll", 0x019EAF78, 0x0, 0xF28, 0x28, 0x0, 0x60, 0x0, 0x18, 0x18, 0x2C;
    int state : "UnityPlayer.dll", 0x019EAF78, 0x0, 0xF28, 0x28, 0x0, 0x60, 0x0, 0x18, 0x70;
    float brightness : "UnityPlayer.dll", 0x019EAF78, 0x0, 0xF28, 0x28, 0x0, 0x60, 0x0, 0x58, 0x30, 0x3C;
    bool show : "UnityPlayer.dll", 0x019EAF78, 0x0, 0xF28, 0x28, 0x0, 0x60, 0x0, 0x58, 0x30, 0x38;
}

init
{
    vars.is_running = true;
}

start
{
    if (0 == current.current_level && current.brightness <= 0.0f && !current.show){
		vars.is_running = true;
        return true;
    }
}

split
{
	if (!vars.is_running && current.state == 1)
		vars.is_running = true;
		
    if (vars.is_running && current.state == 3){
		vars.is_running = false;
        return true;
    }
}

reset
{
    if (current.current_level == 0 && current.show){
		vars.is_running = true;
        return true;
    }
}
