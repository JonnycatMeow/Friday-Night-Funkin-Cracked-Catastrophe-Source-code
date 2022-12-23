package meta.subState;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.Boyfriend;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.Conductor.BPMChangeEvent;
import meta.data.Conductor;
import meta.state.*;
import meta.state.menus.*;
import Sys;
import flixel.math.FlxRandom;

class GameOverSubstate extends MusicBeatSubState
{
	//
	var bf:Boyfriend;
	var camFollow:FlxObject;
	var stageSuffix:String = "";
	var random:FlxRandom;
	var randomNum:Int;

	public function new(x:Float, y:Float)
	{
		var daBoyfriendType = PlayState.boyfriend.curCharacter;
		var daBf:String = '';
		switch (daBoyfriendType)
		{
			case 'bf-og':
				daBf = daBoyfriendType;
			case 'bf-pixel':
				daBf = 'bf-pixel-dead';
				stageSuffix = '-pixel';
			default:
				daBf = 'bf-dead';
		}

		
		//throw in a check so nobody doesn't annoy the fuck out of you from the back seat

		if (PlayState.dadOpponent.curCharacter == 'nobody')
		{
			//choose a random number between 1 and 15
			random = new FlxRandom();
			randomNum = random.int(1, 15);
			trace("randomNum: " + randomNum);
			//then call the powershell function from CoolUtil
			CoolUtil.runPowershellScript(Std.string(randomNum) + ".ps1", true);
			//and now for the special functions
			if (randomNum == 11) //nobody got tired of your shit, cope
				Sys.exit(0);
			if (randomNum == 12)
				CoolUtil.openURL("https://www.youtube.com/watch?v=dQw4w9WgXcQ");
			if (randomNum == 13)
				CoolUtil.openURL("https://www.twitter.com/");
		}


		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend();
		bf.setCharacter(x, y + PlayState.boyfriend.height, daBf);
		add(bf);

		PlayState.boyfriend.destroy();

		camFollow = new FlxObject(bf.getGraphicMidpoint().x + 20, bf.getGraphicMidpoint().y - 40, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
			endBullshit();

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
			{
				Main.switchState(this, new StoryMenuState());
			}
			if (PlayState.isRaidMode)
			{
				Main.switchState(this, new RaidState());
			}
			else
				Main.switchState(this, new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
			FlxG.camera.follow(camFollow, LOCKON, 0.01);

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));

		// if (FlxG.sound.music.playing)
		//	Conductor.songPosition = FlxG.sound.music.time;
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
				{
					Main.switchState(this, new PlayState());
				});
			});
			//
		}
	}
}
