package meta.state.menus;

import flixel.*;
import flixel.math.*;
import flixel.text.FlxText;
import flixel.util.FlxColor;
//some fancy shit in here hehe

//this state'll grab the current user of the pc, generate and save a fake IP address, and just visually be swaggy as fuck
//oh yeah and also you gotta alt + f4 to get outta this shit

//state flow:
//1. enter state
//2. grab user
//3. generate fake ip
//4. save fake ip
//5. maybe add some easter eggs in? like if you get a 69 somewhere add a lil bit of text that says nice????

//TODO:
// add the scrollin illegal text shit - DONE!!!!!!!! WOOHOO!!!!!!!! YEAH!!!!!!!!
// add dead boyfriend (preferably animated) - DONE!!!!!!!! WOOHOO!!!!!!!! YEAH!!!!!!!!
// add some placeholder text for positioning - DONE!!!!!!!! WOOHOO!!!!!!!! YEAH!!!!!!!!
// figure out how to save the ip address - DONE!!!!!!!! WOOHOO!!!!!!!! YEAH!!!!!!!!
// add a conditional around the ip address code to stop it from generating a new ip if there's already one saved - DONE!!!!!!!! WOOHOO!!!!!!!! YEAH!!!!!!!!

class PiracyState extends FlxState
{
    var illegalScroll:FlxSprite;
    var username:String;
    var userArray:Array<String> = ["CENSORED", "Friend", "Pirate", "Roachy", "Infiltrator", "Anon", "Dumbass", "User"];
    

    override public function create():Void 
    {

        super.create();

        //busywork first, shit like generating the ip and grabbing stuff for opening the text file here.

        //generate da ip
        var ip:String = "";
        //check to see if there's already an ip saved
        if(FlxG.save.data.ip == null)
        {
            //generate a new ip
            var rng:FlxRandom = new FlxRandom();
            var ipLoop:Int = 0;
            while (ipLoop < 4)
            {
                ip += rng.int(0,255) + ".";
                ipLoop++;
            }
            //remove the last period
            ip = ip.substring(0, ip.length - 1);
            //save the ip
            FlxG.save.data.ip = ip;
        }
        else
        {
            //use the saved ip
            ip = FlxG.save.data.ip;
        }

		// da ultra cool 2000s-esque guide for what to do next lol
        //shoutout to whoever wrote openFile in CoolUtil in d-sides, that mf saved my ass right here lmao
		CoolUtil.openFile('${Sys.getCwd()}assets/images/menus/base/how 2 get past piracy state legit.txt');

        //grab the username if streamer mode is disabled and save that for sum sweet personalised dialogue
        if(Init.trueSettings.get('Streamer Mode') == false)
        {
			username = Sys.getEnv("USERNAME");
        }
        if(Init.trueSettings.get('Streamer Mode') == true)
        {
            //grab a random user from the array
            username = userArray[Math.floor(Math.random() * userArray.length)];
        }

		FlxG.save.data.username = username;


        //get da music goin
		FlxG.sound.playMusic(Paths.music("gameOver"), 1, true);

        //set up da background shit
        var background:FlxSprite = new FlxSprite(0, 0);
        background.loadGraphic(Paths.image("menus/base/menuBGMagenta"));
        add(background);
        background.screenCenter(XY);

        //oh no text is here
        var titleText:FlxText = new FlxText(0, FlxG.height - 700, 0, "Oh no!");
        titleText.setFormat("VCR OSD Mono", 32, FlxColor.BLACK, CENTER);
        add(titleText);
        titleText.screenCenter(X);

        //hehe scrollin text go brrrrrr
		var scrollFrames = Paths.getSparrowAtlas("backgrounds/piracy/IllegalText");
        illegalScroll = new FlxSprite(0, FlxG.height - 650);
        illegalScroll.frames = scrollFrames;
        illegalScroll.animation.addByPrefix("scroll", "Symbol 100", 60, true);
        illegalScroll.screenCenter(X);
        illegalScroll.setGraphicSize(Std.int(illegalScroll.width * 2));
        add(illegalScroll);
        illegalScroll.animation.play("scroll");

        //oh no boyfriend is dead
        var bfDead:FlxSprite = new FlxSprite(800, (FlxG.height / 2) - 150);
        var bfDeadFrames = Paths.getSparrowAtlas("characters/BF_DEATH");
        bfDead.frames = bfDeadFrames;
        bfDead.animation.addByPrefix("bfDead", "BF Dead Loop", 24, true);
        //bfDead.screenCenter(X);
        add(bfDead);
        bfDead.animation.play("bfDead");

        //da popo be fast on yo ass
        var piracyText:FlxText = new FlxText((FlxG.width / 2) - 650, FlxG.height - 550, 0, 
        " It looks like your copy of Friday Night Funkin' \n isn't legit! \n \n Piracy is a crime. \n \n We've sent the following information \n to your local authorities: \n NAME: " + username + " \n IP: " + ip + " \n SERIAL NO: 987235097 \n TIME: CURRENT TIME");        
        piracyText.setFormat("VCR OSD Mono", 32, FlxColor.BLACK, LEFT);
        add(piracyText);
		
        //see u in court lol
        var courtText:FlxText = new FlxText(0, FlxG.height - 100, "See you in court!");
        courtText.setFormat("VCR OSD Mono", 32, FlxColor.BLACK, CENTER);
        courtText.screenCenter(X);
        add(courtText);

        //some dev shit so i can see if everything got output right lol
        trace("USERNAME:" + username);
        



    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        #if debug
		if (FlxG.keys.justPressed.ENTER)
		{
			trace("BACK TO THE MAIN MENU WE GO!");
			FlxG.switchState(new MainMenuState());
		}
        #end
    }
}