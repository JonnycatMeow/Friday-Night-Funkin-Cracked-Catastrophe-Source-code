package meta.state;
//this is the FunkLock DRM shit thingy words no work good

import String;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import meta.data.*;
import meta.data.Song.SwagSong;
import flixel.*;
import Sys;

using StringTools;



class DRMState extends FlxState
{
    var flActive:Bool = false; //funklock.active
    var flTriggerAlert:Bool = false; //funklock.triggerAlert
    var flEnforceDRM:Bool = false; //funklock.enforceDRM
    var flDebugBypass:Bool = false; //funklock.debugBypass
    var flText:Array<String> = ['FunkLock is inactive, therefore this game will not launch.', "FUNKLOCK ALERT TEST TRIGGERED IF YOU SEE THIS IT'S WORKING", 'FunkLock has detected that this copy of the game is not legitimate!', 'FunkLock has encountered a fatal error, and will not launch this game.']; //order of text is the same as the the vars above
    var txtText:Array<String> = [];
    var flTextToDisplay:String = ""; //what we showin the bozo who mcfucked up
    var flTextObject:FlxText; //the text object
    var flDoc:String; //contains funklock.txt
    var flTitle:FlxText; //the title text
    var flHint:FlxText; //hint text so peeps know where to go

    override public function create()
    {
        super.create();

        //set up a try catch in case the dumbfuck deletes the file
        try
        {
            //read the file
            flDoc = sys.io.File.getContent(('${Sys.getCwd()}assets/images/menus/base/funklock.txt'));
        }
        catch (e:Dynamic)
        {
            //if the file is missing, remake it minus the cool ascii art because string interpreter thingy don't like it :(
            sys.io.File.saveContent(('${Sys.getCwd()}assets/images/menus/base/funklock.txt'),
            "=======================================================================
                    FUNKLOCK
                By Nobody
        
        WARNING! THIS FILE SHOULD NOT BE MODIFIED UNDER *ANY CIRCUMSTANCES!*:
        
        funklock.active = true:
        funklock.enforceDRM = true:
        funklock.triggerAlert = false:
        funklock.debugBypass = false:
        =======================================================================");

            //then add a lil hint on what the player needs to be lookin for.
            Sys.command('msg %username% Remote file modification detected in assets/images/menus/base/funklock.txt.');
            //then exit the game
            Sys.exit(0);
            
        }
        

        //let's get to choppin
        txtText = flDoc.split(":");
        #if debug
        //spit out everything in txtText
        for (i in 0...txtText.length)
        {
            trace(txtText[i]);
        }

        //skip all that txt shit since we're just tryna test overflow to dbdos
        var poop:String = Highscore.formatSong('overflow', 1);

          trace("congrats you did it");

        PlayState.SONG = Song.loadFromJson(poop, 'overflow');
        PlayState.isStoryMode = true;
        PlayState.storyDifficulty = 1;
        PlayState.storyWeek = 3;


        Main.switchState(this, new PlayState());
        
        #end


        //at this point, the important bits should be in [1] to [4] hopefully
        //if not, then we're fucked
        //god forgive me for what I'm about to do
        //this was so fucking painful to write
        if (txtText[1].endsWith("true"))
        {
            if (txtText[2].endsWith("false"))
            {
                if (txtText[3].endsWith("false"))
                {
                    if(txtText[4].endsWith("true"))
                    {
                        //ur in bud, let's get this show on the road
                        var poop:String = Highscore.formatSong('overflow', 1);

                        trace("congrats you did it");

                        PlayState.SONG = Song.loadFromJson(poop, 'overflow');
                        PlayState.isStoryMode = true;
                        PlayState.storyDifficulty = 1;
                        PlayState.storyWeek = 3;
                        Main.switchState(this, new PlayState());
                    }
                    else
                    {
                        //ur fucked
                        flTextToDisplay = flText[3];
                    }
                }
                else
                {
                    //ur fucked
                    flTextToDisplay = flText[1];
                }
            }
            else
            {
                //ur fucked
                flTextToDisplay = flText[2];
            }
        }
        else
        {
            //ur fucked
            flTextToDisplay = flText[0];
        }

        //now let's actually get all that visual shit set up

        //background
        var background:FlxSprite = new FlxSprite(0, 0);
        background.loadGraphic(Paths.image("menus/base/menuBGRed"));
        add(background);
        background.screenCenter(XY);

        flTitle = new FlxText(0, FlxG.height - 500, FlxG.width, "FUNKLOCK");
        flTitle.setFormat("VCR OSD Mono", 72, FlxColor.WHITE, CENTER);
        add(flTitle);
        flTitle.screenCenter(X);

        flTextObject = new FlxText(0, 0, FlxG.width, flTextToDisplay);
        flTextObject.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER);
        add(flTextObject);
        flTextObject.screenCenter(XY);

        flHint = new FlxText(0, flTextObject.y - 250, FlxG.width, "REMEMBER TO CHECK THE DEV DOC IF YOU GET LOCKED OUT -NM");
        flHint.setFormat("VCR OSD Mono", 12, FlxColor.WHITE, CENTER);
        add(flHint);
        flHint.screenCenter(X);
    }
}