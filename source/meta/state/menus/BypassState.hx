package meta.state.menus;

import flixel.*;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import meta.data.*;
import meta.data.Song.SwagSong;

using StringTools;

class BypassState extends FlxState
{
    var passcode:String;
    var passStar1:FlxText;
    var passStar2:FlxText;
    var passStar3:FlxText;
    var enteredCode:String = "";
    var inputEnabled:Bool = true;
    var passcodeCorrect:Bool = false;
    var passcodeConfirm:Bool = false;
    var acceptedInputs:Array<String> = ["one","two","three","four","five","six","seven","eight","nine","0","A","B","C","D","E","F"];

    //TODO:
    //read the ip saved in PiracyState and give it a variable here - DONE!!!!! WOOO!!!!! YEAH!!!!! :D 
    //figure out how the FUCK text boxes work
    //transition to piracy check song
    //crash the game or some shit if you get the code wrong

    //how to get the IP set up for the passcode
    //get rid of all the full stops in the ip
    //trim everything but the first 3 numbers from the ip string
    //all done!

    override public function create()
    {
        super.create();

        FlxG.sound.pause();

        //sort out the ip n shit
		var savedIP:String = FlxG.save.data.ip;
        savedIP = savedIP.replace(".", "");
        savedIP = savedIP.substring(0, 3);
        passcode = Std.string(savedIP);
        trace("pass should be " + savedIP);

        //da awaiting input text
        var waitingText:FlxText = new FlxText(0, 0, FlxG.width, "Awaiting input...");
        waitingText.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, CENTER);
        waitingText.screenCenter(XY);
        add(waitingText);

        //second pass star goes first in here since the other two use it's position as a reference
		passStar2 = new FlxText(0, FlxG.height - 100, FlxG.width, "*");
		passStar2.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, CENTER);
		passStar2.screenCenter(X);
		passStar2.visible = false;
		add(passStar2);

        passStar1 = new FlxText(passStar2.x - 50, FlxG.height - 100, FlxG.width, "*");
        passStar1.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, CENTER);
        passStar1.visible = false;
        add(passStar1);

        passStar3 = new FlxText(passStar2.x + 50, FlxG.height - 100, FlxG.width, "*");
        passStar3.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, CENTER);
        passStar3.visible = false;
        add(passStar3);



    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);


		if (FlxG.keys.justPressed.M)
		{
			trace("correct pass is: " + passcode);
            trace("entered pass is: " + enteredCode);
            if (enteredCode != passcode)
            {
                trace("They do not match.");
            }
		}

        
        //handles the password inputs, god this took too fucking long i miss unity so much ;-;
        if(FlxG.keys.firstJustPressed()!=-1 && inputEnabled)
        {
            var inputKey = FlxG.keys.firstJustPressed();

            switch (inputKey)
            {
                case FlxKey.BACKSPACE:
                    if (enteredCode.length > 0)
                    {
                        enteredCode = enteredCode.substring(0, enteredCode.length - 1);
                    }
                
                case FlxKey.M:
					trace("correct pass is: " + passcode);
					trace("entered pass is: " + enteredCode);
					if (enteredCode != passcode)
					{
						trace("They do not match.");
					}

                case FlxKey.ESCAPE:
                    Main.switchState(this, new MainMenuState());
                
                default:
                    //make sure the input is a number

                    enteredCode += keyInput(inputKey);
					trace("Player input key: " + keyInput(inputKey));
					trace("current enteredCode is: " + enteredCode);
            }

            if(enteredCode.contains("null"))
            {
                enteredCode.replace("null", "");
            }
        }

        switch(enteredCode.length)
        {
            case 1:
                passStar1.visible = true;
            
            case 2:
                passStar2.visible = true;
            
            case 3:
                passStar3.visible = true;
            
            default:
                passStar1.visible = false;
                passStar2.visible = false;
                passStar3.visible = false;
        }

        if(enteredCode.length == 3)
        {
            if(enteredCode == passcode && passcodeConfirm == false)
            {
                inputEnabled = false;
                passStar1.color = FlxColor.GREEN;
                passStar2.color = FlxColor.GREEN;
                passStar3.color = FlxColor.GREEN;
                passcodeConfirm = true;

                //set a 2 second timer for some effect
                var piracyTimer:FlxTimer = new FlxTimer().start(2, function(timer:FlxTimer)
                {
					
					var poop:String = Highscore.formatSong('piracy-check', 1);

					trace("congrats you put in the password right");

					PlayState.SONG = Song.loadFromJson(poop, 'piracy-check');
					PlayState.isStoryMode = true;
					PlayState.storyDifficulty = 1;
					PlayState.storyWeek = 3;
					Main.switchState(this, new PlayState());
                }, 1);
            }
            if(enteredCode != passcode && passcodeConfirm == false)
            {
                inputEnabled = false;
                passStar1.color = FlxColor.RED;
                passStar2.color = FlxColor.RED;
                passStar3.color = FlxColor.RED;
                passcodeConfirm = true;

                //set a 2 second timer for some effect
                var failTimer:FlxTimer = new FlxTimer().start(2, function(timer:FlxTimer)
                {
                    trace("you put in the password wrong");
                    enteredCode = "";
                    passcodeConfirm = false;
                    inputEnabled = true;
                    passStar1.color = FlxColor.WHITE;
                    passStar2.color = FlxColor.WHITE;
                    passStar3.color = FlxColor.WHITE;
                }, 1);
            }

            
        }
    }

    //shoutout to whoever put together keyInput on d sides again, truly doin the most for typing in a UI :pray:
	function keyInput(k:FlxKey):String
	{
		var asString = k.toString().toLowerCase();
		switch (asString)
		{
			case 'zero' | 'numpadzero':
				return '0';
			case 'one' | 'numpadone':
				return '1';
			case 'two' | 'numpadtwo':
				return '2';
			case 'three' | 'numpadthree':
				return '3';
			case 'four' | 'numpadfour':
				return '4';
			case 'five' | 'numpadfive':
				return '5';
			case 'six' | 'numpadsix':
				return '6';
			case 'seven' | 'numpadseven':
				return '7';
			case 'eight' | 'numpadeight':
				return '8';
			case 'nine' | 'numpadnine':
				return '9';
            default:
                return "";
        }
    }
}