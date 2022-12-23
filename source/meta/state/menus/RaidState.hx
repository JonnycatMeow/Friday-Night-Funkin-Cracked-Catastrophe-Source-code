package meta.state.menus;

import flixel.*;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import meta.data.*;
import meta.data.Song.SwagSong;
import gameObjects.Character;
import meta.state.PlayState;

using StringTools;

class RaidState extends FlxState
{
    //pretty empty at the moment, but this'll be the state that handles the raid menu
    //TODO
    //get the current day from the internet as opposed to the local machine. why? to stop cheeky bastards like you from fucking with the lineup.
    //chances are you'll be able to do it given you're reading this, but whatever lol
    //actually assemble the raid menu
    //raid boss selection concept:
    //have a side-to-side selection menu with all the bosses on it
    //if it isn't friday, automatically select the boss of the day and disable control input
    //if it is friday, allow the player to scroll left and right to select a boss
    //have the bosses be a sillhouette when not selected
    //have the currently selected boss have their sprite on display, maybe make it a little bigger too.


    public static var raidDebug:Bool = false;
    public var curDay:String;
    public var curBoss:String;
    public var responseArray:Array<String>;
    public var curDayInt:Int;
    var boss:FlxSprite; //the boss of the day, though it'll be a sillhouette on this screen
    var bossBG:FlxSprite; //the background for the boss of the day
    var title:FlxText;
    var songName:FlxText;
    var tipText:FlxText; //handy little tip about the current boss for the player
    var controlText:FlxText; //text that tells the player how to control the menu
    var songString:String;
    var jacket:FlxSprite;
    var jacketBG:FlxSprite;
    var senpai:FlxSprite;
    var senpaiBG:FlxSprite;
    var nobody:FlxSprite;
    var nobodyBG:FlxSprite;
    var bottomBar:FlxSprite;
    var topBar:FlxSprite;
    var songs:Array<String> = ["carpenter", "broken-heart-corrosion", "seg-fault"];
    var curSelection:Int = 0;
    var isFightNight:Bool = false;
    var bossArray:Array<FlxSprite> = new Array<FlxSprite>(); //0 is jacket, 1 is senpai, 2 is nobody - mainly used for fight night
    var bossBGArray:Array<FlxSprite> = new Array<FlxSprite>(); //0 is jacket, 1 is senpai, 2 is nobody - mainly used for fight night
    var setupComplete:Bool = false; //used to hold off on boss dancing until the setup is complete

    public function new()
    {
        super();

        trace("hello from RaidState!");
        //backup in case the api ever goes down, futureproofing woo!
        //unless you're trying to play this in 2038, in which case you're fucked lol
        var dateVar = Date.now();
        curDayInt = dateVar.getUTCDay();

        trace("here's what we've got:");
        trace('offline day: ' + curDayInt);

        //time to go through that api response (hopefully)
        /*if (request != null)
        {
            var response = request.responseText;
            trace('online day: ' + response);
            curDay = response;
        }
        else
        {
            trace('api is down, using local day');
            curDay = dayInt;
        }*/

        //get the current day from the internet
        var request = new haxe.Http("https://www.timeapi.io/api/Time/current/zone?timeZone=UTC"); //couldn't find a way to get the day specifically, so I'm just getting everything and filtering it out
        trace("sent out a request!");

        request.onData = function(data:String)
        {
            trace("got a response from the internet!");
            trace(data);

            //filter through everything
            var tempArray = data.split(",");
            for (i in 0...tempArray.length)
            {
                if (tempArray[i].contains("dayOfWeek"))
                {
                    trace('found the day of the week!');
                    trace(tempArray[i]);
                    var tempDay = tempArray[i].split(":");
                    trace("it's apparently " + tempDay[1]);
                    //get rid of the quotes
                    curDay = tempDay[1].split("\"").join("");
                    trace("it's actually " + curDay);
                }
            }
        }
        request.onError = function(error:String)
        {
            trace('http request failed lol!');
            trace(error);
            trace("you're probably offline, so I'll just use the local machine's time instead");
            curDay = CoolUtil.getDayName(curDayInt);
            trace("today should be " + curDay + " or " + curDayInt);
        }

        if (!raidDebug)
            request.request();
        else
            curDay = 'Friday';

        //now let's get all that visual shit set up

        while (curDay == null)
        {
            trace("waiting for the day to be set...");
        }

        //now that we've got the day, we can get the boss
        trace("getting the boss...");
        curBoss = getBoss(curDay);


        //start out with the boss
        if (isFightNight)
        {
            jacket = new FlxSprite();
            jacket.frames = Paths.getSparrowAtlas('characters/jacket');
            jacket.animation.addByPrefix('idle', 'idle', 24, false);
            jacket.animation.play('idle');
            jacket.setGraphicSize(0, Std.int(FlxG.height / 1.5));
            jacket.updateHitbox();
            jacket.x = 0;
            jacket.screenCenter(Y);

            jacketBG = new FlxSprite(0, 0).loadGraphic(Paths.image('backgrounds/jacketRaid/bg1'));
            //jacketBG.setGraphicSize(FlxG.width, FlxG.height);
            jacketBG.screenCenter(XY);

            senpai = new FlxSprite();
            senpai.frames = Paths.getSparrowAtlas('characters/senpai');
            senpai.animation.addByPrefix('idle', 'Senpai Idle', 24, false);
            senpai.animation.play('idle');
            senpai.setGraphicSize(0, Std.int(FlxG.height / 1.5));
            senpai.updateHitbox();
            senpai.screenCenter(X);
            senpai.y = jacket.y;

            senpaiBG = new FlxSprite(0, 0).loadGraphic(Paths.image('backgrounds/spiritRaid/weebSky'));
            var widShit = Std.int(senpaiBG.width * 6);
            senpaiBG.setGraphicSize(widShit);
            senpaiBG.updateHitbox();
            senpaiBG.screenCenter(XY);

            nobody = new FlxSprite();
            nobody.frames = Paths.getSparrowAtlas('characters/nobody');
            nobody.animation.addByPrefix('idle', 'BF idle dance', 24, false);
            nobody.animation.play('idle');
            nobody.setGraphicSize(0, Std.int(FlxG.height / 3));
            nobody.updateHitbox();
            nobody.x = FlxG.width - nobody.width;
            nobody.y = jacket.y + (jacket.height / 2);

            nobodyBG = new FlxSprite(0, 0).loadGraphic(Paths.image('backgrounds/overflowStage/stageback'));
            nobodyBG.setGraphicSize(FlxG.width, FlxG.height);
            nobodyBG.screenCenter(XY);

            bossArray.push(jacket);
            bossArray.push(senpai);
            bossArray.push(nobody);

            bossBGArray.push(jacketBG);
            bossBGArray.push(senpaiBG);
            bossBGArray.push(nobodyBG);

            for (i in 0...bossBGArray.length)
            {
                add(bossBGArray[i]);
            }
            
            for (i in 0...bossArray.length)
            {
                add(bossArray[i]);
            }
        }

        else
        {
            boss = new FlxSprite();

            #if debug
            trace('it aint fight night, selecting ' + curBoss);
            #end

            switch(curBoss)
            {
                case "jacket":
                    boss.frames = Paths.getSparrowAtlas('characters/jacket');
                    boss.animation.addByPrefix('idle', 'idle', 24, false);
                    boss.animation.play('idle');
                    curSelection = 0;

                    bossBG = new FlxSprite(0, 0).loadGraphic(Paths.image('backgrounds/jacketRaid/bg1'));
                    //bossBG.setGraphicSize(FlxG.width, FlxG.height);
                    bossBG.screenCenter(XY);
                case "senpai":
                    boss.frames = Paths.getSparrowAtlas('characters/senpai');
                    boss.antialiasing = false;
                    boss.setGraphicSize(Std.int(boss.width * 6));
                    boss.updateHitbox();
                    boss.animation.addByPrefix('idle', 'Senpai Idle', 24, false);
                    boss.animation.play('idle');
                    curSelection = 1;

                    bossBG = new FlxSprite(0, 0).loadGraphic(Paths.image('backgrounds/spiritRaid/weebSky'));
                    var widShit = Std.int(bossBG.width * 6);
                    bossBG.setGraphicSize(widShit);
                    bossBG.updateHitbox();
                    bossBG.screenCenter(XY);
                case "nobody":
                    boss.frames = Paths.getSparrowAtlas('characters/nobody');
                    boss.animation.addByPrefix('idle', 'BF idle dance', 24, false);
                    boss.animation.play('idle');
                    curSelection = 2;

                    bossBG = new FlxSprite(0, 0).loadGraphic(Paths.image('backgrounds/overflowStage/stageback'));
                    bossBG.setGraphicSize(FlxG.width, FlxG.height);
                    bossBG.screenCenter(XY);
            }

            if (curBoss != 'senpai')
            {
                boss.setGraphicSize(0, Std.int(FlxG.height * 0.75));
                boss.updateHitbox();
            }
            boss.screenCenter(XY);
            
            add(bossBG);            
            add(boss);
        }

        //set up some sick cinematic bars
        bottomBar = new FlxSprite(0, FlxG.height - 50).makeGraphic(FlxG.width, Std.int(FlxG.height * 0.125), 0xff000000);
        bottomBar.screenCenter(X);
        bottomBar.y = 0;
        topBar = new FlxSprite(0, 0).makeGraphic(FlxG.width, Std.int(FlxG.height * 0.125), 0xff000000);
        topBar.screenCenter(X);
        topBar.y = FlxG.height - topBar.height;

        
        add(bottomBar);
        add(topBar);

        //now the title
        title = new FlxText(0, 0, FlxG.width, "BOSS RAID");
        title.setFormat("VCR OSD Mono", 72, FlxColor.WHITE, "center");
        title.y = FlxG.height - title.height;
        title.screenCenter(X);
        add(title);

        //tip text
        tipText = new FlxText(0, 0, FlxG.width * 0.2);

        //now the song name
        switch(curBoss)
        {
            case 'senpai':
                songString = "Broken Heart Corrosion";
                tipText.text = "Tip: Spirit will fight back.";
            
            case 'nobody':
                songString = "SEG FAULT";
                tipText.text = "You know I had to come back for one last round.";

            case 'jacket':
                songString = "Carpenter";
                tipText.text = "Tip: Damage is permanent in this fight.";

            case 'fightNight':
                songString = "FIGHT NIGHT";

            default:
                songString = "SOMETHING FUCKED UP";
        }
        tipText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, "left");
        tipText.x = 0;
        tipText.y = (FlxG.height * 0.1) - tipText.height;

        add(tipText);

        controlText = new FlxText(0, 0, FlxG.width * 0.3);
        controlText.setFormat("VCR OSD Mono", 14, FlxColor.WHITE, "right");
        controlText.text = "Press [ENTER] to start \nPress [ESC] to return to menu";
        if (isFightNight)
        {
            controlText.text = "Press [ENTER] to start \nPress [ESC] to return to menu \n[LEFT] and [RIGHT] to select a boss";
        }
        controlText.x = FlxG.width - controlText.width;
        controlText.y = 0 + controlText.height;

        add(controlText);

        songName = new FlxText(0, 0, FlxG.width, songString);
        songName.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, "center");
        songName.y = (FlxG.height * 0.1) - songName.height;
        songName.screenCenter(X);
        add(songName);

        

        //MAKE SURE THIS STAYS AT THE END OF THE FUNCTION!!!!

        //now everything's set up, let's select the right boss

        switch(curBoss)
        {
            case 'nobody':
                curSelection = 2;
            
            case 'jacket':
                curSelection = 0;

            case 'senpai':
                curSelection = 1;

            case 'fightNight':
                curSelection = 1;
                changeSelection(1);
                changeSelection(1);
                changeSelection(1);

            default:
                #if debug
                trace("SOMETHING FUCKED UP WHILST TRYING TO SELECT THE RIGHT BOSS");
                #end
                curSelection = 0;
        }

        if (isFightNight)
        {
            changeSelection(1);
            changeSelection(1);
            changeSelection(1);
        }

        

        setupComplete = true;

        #if debug
        trace('RaidState setup complete!');
        trace('boss: ' + curBoss);
        trace('selection: ' + curSelection);
        #end

    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (setupComplete)
        {
            bossDance(curSelection);
        }

        if (isFightNight)
        {
            if (FlxG.keys.justPressed.LEFT)
                changeSelection(-1);
            if (FlxG.keys.justPressed.RIGHT)
                changeSelection(1);
        }

        if (FlxG.keys.justPressed.ESCAPE)
        {
            Main.switchState(this, new MainMenuState());
        }

        if (FlxG.keys.justPressed.ENTER)
        {
            startSong();
        }
    }

    public function getBoss(day:String):String
    {
        switch(day)
        {
            case "Monday" | "Thursday":
                return 'nobody';
            
            case "Tuesday" | "Saturday":
                return 'jacket';

            case "Wednesday" | "Sunday":
                return 'senpai';

            case "Friday":
                isFightNight = true;
                return 'senpai';

            default:
                trace('something fucked up');
                trace('day: ' + day);
                trace('returning nobody so shit doesn\'t break');
                return 'nobody';
        }
    }

    function changeSelection(change:Int)
    {
        var prevSelection = curSelection;
        curSelection += change;
        if (curSelection < 0)
        {
            curSelection = 2;
        }
        if (curSelection > 2)
        {
            curSelection = 0;
        }

        switch(curSelection)
        {
            case 0:
                unselect(prevSelection);
                curBoss = 'jacket';
                songName.text = "Carpenter";
                tipText.text = "Tip: Damage is permanent in this fight.";
                select(curSelection);

            case 1:
                unselect(prevSelection);
                curBoss = 'senpai';
                songName.text = "Broken Heart Corrosion";
                tipText.text = "Tip: Spirit will fight back.";
                select(curSelection);

            case 2:
                unselect(prevSelection);
                curBoss = 'nobody';
                songName.text = "SEG FAULT";
                tipText.text = "You know I had to come back for one last round.";
                select(curSelection);
        }
    }

    function unselect(daBoss:Int)
    {
        //grab the boss variable using daBoss
        bossArray[daBoss].animation.pause();
        bossArray[daBoss].color = 0xff292929;
        bossBGArray[daBoss].alpha = 0;
    }

    function select(daBoss:Int)
    {
        bossArray[daBoss].animation.play('idle');
        bossArray[daBoss].color = 0xffffffff;
        bossBGArray[daBoss].alpha = 1;
    }

    function startSong()
    {
        var poop:String = Highscore.formatSong(songs[curSelection], 1);

		#if debug
        trace("starting a fight against " + curBoss + " with song " + songs[curSelection]);
        #end

		PlayState.SONG = Song.loadFromJson(poop, songs[curSelection]);
		PlayState.isRaidMode = true;
        PlayState.freeplayChar = ""; //holy shit i completely forgot about this
		PlayState.storyDifficulty = 1;
		PlayState.storyWeek = 3;
		Main.switchState(this, new PlayState());
    }

    function bossDance(daBoss:Int)
    {
        //checks to make sure the boss keeps shmoovin
        if (isFightNight)
        {
            if (bossArray[daBoss].animation.curAnim.finished)
            {
                bossArray[daBoss].animation.play('idle');
            }
        }
        else
        {
            if (boss.animation.curAnim.finished)
            {
                boss.animation.play('idle');
            }
        }
        
    }
}