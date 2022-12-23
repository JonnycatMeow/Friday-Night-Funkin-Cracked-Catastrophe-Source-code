package meta.state.menus;

import flixel.*;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import meta.data.Flags;

//extra insurance so peeps don't doxx themselves lol!!
class ResetState extends FlxState
{

    var daText:FlxText;
    var daTitle:FlxText;

    override public function create():Void
    {
        daTitle = new FlxText(0, FlxG.height - 650, FlxG.width, "WARNING!");
        daTitle.setFormat("VCR OSD Mono", 72, FlxColor.WHITE, CENTER);
        daTitle.screenCenter(X);
        add(daTitle);

        daText = new FlxText(0, 0, FlxG.width, 
        "PROCEEDING ANY FURTHER WILL RESULT IN YOUR STORY PROGRESS BEING WIPED!\n
        \n
        \n
        IF YOU WOULD LIKE TO KEEP YOUR PROGRESS AND FREEPLAY,\n
        PRESS ESCAPE NOW!\n
        \n
        IF YOU REALLY WANT TO DO THIS,\n
        PRESS 5!\n
        \n
        I COULDN'T BE BOTHERED TO MAKE A RECOVERY FUNCTION SO\n
        YOU'LL NEED TO BEAT EVERYTHING AGAIN IF YOU DO THIS!\n");
        daText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER);

        daText.screenCenter(XY);
        add(daText);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (FlxG.keys.justPressed.ESCAPE)
        {
            
            Main.switchState(this, new MainMenuState());
        }
        if (FlxG.keys.justPressed.FIVE)
        {
            var flagvar = new Flags();
            flagvar.resetFlags();
        }
    }

}