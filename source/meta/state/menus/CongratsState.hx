package meta.state.menus;

import flixel.*;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

//congrats u did it
class CongratsState extends FlxState
{

    var daText:FlxText;
    var confirmDisclaimer:Bool;
    var daTitle:FlxText;

    override public function create():Void
    {
        daTitle = new FlxText(0, FlxG.height - 650, FlxG.width, "YOUR WINNER!");
        daTitle.setFormat("VCR OSD Mono", 72, FlxColor.WHITE, CENTER);
        daTitle.screenCenter(X);
        add(daTitle);

        daText = new FlxText(0, 0, FlxG.width, 
        "Congrats on beating the story, nice going!\n
        \n
        \n
        Freeplay is now unlocked, so you can play all the\n
        songs again without having to jump through any hoops.\n
        \n
        If you ever want to go through the story from scratch,\n
        hit 3 while on the main menu.\n
        \n
        Thanks for giving the mod a shot, and I hope you had fun!\n
        -God's Drunkest Driver");
        daText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER);

        daText.screenCenter(XY);
        add(daText);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (FlxG.keys.justPressed.ENTER)
        {
            
            Main.switchState(this, new TitleState());
        }
    }

}