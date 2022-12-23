package meta.state.menus;

import flixel.*;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

//extra insurance so peeps don't doxx themselves lol!!
class DisclaimerState extends FlxState
{

    var daText:FlxText;
    var confirmDisclaimer:Bool;

    override public function create():Void
    {
        daText = new FlxText(0, 0, FlxG.width, 
        "Hey there!\n
        Looks like this is your first time booting the mod!\n
        \n
        This mod will display your current windows username\n
        a few times, so to prevent any accidental leaks of\n
        personal information, i've included a streamer mode!\n
        \n
        If you don't want your name displayed, go on down to\n
        the options tab after this screen and enable it!\n
        \n
        Press ENTER to get funkin'!");
        daText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER);

        daText.screenCenter(XY);
        add(daText);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (FlxG.keys.justPressed.ENTER)
        {
            confirmDisclaimer = true;
            FlxG.save.data.disclaimer = true; //saving this so we don't have to ask again
            Main.switchState(this, new MainMenuState());
        }
    }

}