package gameObjects.userInterface;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import meta.CoolUtil;
import meta.InfoHud;
import meta.data.Conductor;
import meta.data.Timings;
import meta.state.PlayState;
import gameObjects.Character;

using StringTools;

class ClassHUD extends FlxTypedGroup<FlxBasic>
{
	// set up variables and stuff here
	var infoBar:FlxText; // small side bar like kade engine that tells you engine info
	var scoreBar:FlxText;

	var scoreLast:Float = -1;
	var scoreDisplay:String;

	//changed these two to public, you're wanted elsewhere.
	public static var healthBarBG:FlxSprite;
	public static var healthBar:FlxBar;

	private var SONG = PlayState.SONG;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	private var stupidHealth:Float = 0;

	private var timingsMap:Map<String, FlxText> = [];

	public var nobodyIcon:Character;
	public var bfIcon:Character;
	public var player1Char:String = PlayState.boyfriend.curCharacter;

	public var iconAnimOn:Bool = false; //used to make sure that the icons don't play their singing anims when they're not supposed to

	public var iconOffset:Int = 26;

	public var introCardFinished:Bool = false;


	//intro card stuff
	public var introCardGroup:FlxTypedGroup<FlxBasic>;
	public var icBar:FlxSprite;
	public var icArrow:FlxSprite;
	public var icTopText:FlxText;
	public var icBottomText:FlxText;
	public var icOppIcon:HealthIcon;
	public var icPlayerIcon:HealthIcon;
	public var icOppName:FlxText;
	public var icPlayerName:FlxText;
	public var icVsText:FlxText;
	public var icSongName:FlxText;
	public var icSongDiff:FlxText;

	// eep
	public function new()
	{
		// call the initializations and stuffs
		super();

		// fnf mods
		var scoreDisplay:String = 'beep bop bo skdkdkdbebedeoop brrapadop';

		// le healthbar setup
		if (PlayState.isRaidMode)
		{
			trace('classHUD: raid mode is enabled.');
			var barY = FlxG.height / 2;
			healthBarBG = new FlxSprite(0, barY).loadGraphic(Paths.image(ForeverTools.returnSkinAsset('healthBarVertical', PlayState.assetModifier, PlayState.changeableSkin, 'UI')));
			healthBarBG.x = FlxG.width - healthBarBG.width;
			healthBarBG.screenCenter(Y);
			healthBarBG.scrollFactor.set();
			add(healthBarBG);

			//set up the healthbar to be centered on the healthbarBG
			healthBar = new FlxBar(healthBarBG.x, healthBarBG.y, BOTTOM_TO_TOP, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
			healthBar.x = healthBarBG.x + 4;
			healthBar.screenCenter(Y);
			//set the healthbar up to be in the middle of the screen
			//healthBar.y = FlxG.height / 2;
			healthBar.scrollFactor.set();
			healthBar.createFilledBar(0xff000000, CoolUtil.getDominantIconColour(PlayState.boyfriend.curCharacter));
			add(healthBar);

			iconP1 = new HealthIcon(SONG.player1, true);
			iconP1.y = healthBarBG.y - (iconP1.height / 2);
			iconP1.x = healthBarBG.x - (iconP1.width / 2);
			add(iconP1);

			//reposition the healthbar again
			//healthBarBG.x = iconP1.x + (iconP1.width / 2);
			//healthBar.x = iconP1.x + (iconP1.width / 2);

			iconP2 = new HealthIcon(SONG.player2, false);
			iconP2.alpha = 0; //this is super fucking hacky but it probably works
			iconP2.y = healthBarBG.y;
			iconP2.x = healthBarBG.x;
			add(iconP2);
		}
		else
		{
			var barY = FlxG.height * 0.875;
			if (Init.trueSettings.get('Downscroll'))
				barY = 64;

			healthBarBG = new FlxSprite(0,
				barY).loadGraphic(Paths.image(ForeverTools.returnSkinAsset('healthBar', PlayState.assetModifier, PlayState.changeableSkin, 'UI')));
			healthBarBG.screenCenter(X);
			healthBarBG.scrollFactor.set();
			add(healthBarBG);

			healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
			healthBar.scrollFactor.set();
			healthBar.createFilledBar(CoolUtil.getDominantIconColour(PlayState.dadOpponent.curCharacter), CoolUtil.getDominantIconColour(PlayState.boyfriend.curCharacter));
			// healthBar
			add(healthBar);

			if (!PlayState.isStoryMode && PlayState.freeplayChar != "")
				iconP1 = new HealthIcon(PlayState.freeplayChar, true);
			else
				iconP1 = new HealthIcon(SONG.player1, true);

			iconP1.y = healthBar.y - (iconP1.height / 2);
			add(iconP1);

			iconP2 = new HealthIcon(SONG.player2, false);
			iconP2.y = healthBar.y - (iconP2.height / 2);
			add(iconP2);
		}
		

		if (PlayState.SONG.song.toLowerCase() == 'overflow')
		{
			//spawn in the funny characters
			iconP2.alpha = 0;
			nobodyIcon = new Character().setCharacter(iconP2.x, iconP2.y, 'nobodyIcon');
			nobodyIcon.y = healthBar.y;
			add(nobodyIcon);
			//don't forget bf too!
			iconP1.alpha = 0;
			bfIcon = new Character().setCharacter(iconP1.x, iconP1.y, 'bfIcon');
			bfIcon.y = healthBar.y;
			add(bfIcon);
			//testing to make sure it actually shows up
			//nobodyIcon.screenCenter(Y);
			trace("spawned nobodyIcon");
			trace("nobodyIcon.x: " + nobodyIcon.x);
			trace("nobodyIcon.y: " + nobodyIcon.y);
			trace("nobodyIcon.height: " + nobodyIcon.height);
			trace("iconP2.x: " + iconP2.x);
			trace("iconP2.y: " + iconP2.y);
			//blah blah same thing for BF here
			nobodyIcon.dance();
			bfIcon.dance();
		}

		scoreBar = new FlxText(FlxG.width / 2, healthBarBG.y + 40, 0, scoreDisplay, 20);
		if (PlayState.isRaidMode && !Init.trueSettings.get('Downscroll'))
		{
			if (PlayState.SONG.song.toLowerCase() == 'broken-heart-corrosion')
				scoreBar.y = healthBarBG.y + 75;
			else
				scoreBar.y = healthBarBG.y - 50;
		}
		
			
		scoreBar.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		updateScoreText();
		scoreBar.scrollFactor.set();
		add(scoreBar);

		// small info bar, kinda like the KE watermark
		// based on scoretxt which I will set up as well
		var infoDisplay:String = "NOW PLAYING:" + CoolUtil.dashToSpace(PlayState.SONG.song);
		var engineDisplay:String = "Forever Engine v" + Main.gameVersion;
		var engineBar:FlxText = new FlxText(0, FlxG.height - 30, 0, engineDisplay, 16);
		engineBar.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		engineBar.updateHitbox();
		engineBar.x = FlxG.width - engineBar.width - 5;
		engineBar.scrollFactor.set();
		add(engineBar);

		infoBar = new FlxText(5, FlxG.height - 30, 0, infoDisplay, 20);
		infoBar.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoBar.scrollFactor.set();
		add(infoBar);

		// counter
		if (Init.trueSettings.get('Counter') != 'None') {
			var judgementNameArray:Array<String> = [];
			for (i in Timings.judgementsMap.keys())
				judgementNameArray.insert(Timings.judgementsMap.get(i)[0], i);
			judgementNameArray.sort(sortByShit);
			for (i in 0...judgementNameArray.length) {
				var textAsset:FlxText = new FlxText(5 + (!left ? (FlxG.width - 10) : 0),
					(FlxG.height / 2)
					- (counterTextSize * (judgementNameArray.length / 2))
					+ (i * counterTextSize), 0,
					'', counterTextSize);
				if (!left)
					textAsset.x -= textAsset.text.length * counterTextSize;
				textAsset.setFormat(Paths.font("vcr.ttf"), counterTextSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				textAsset.scrollFactor.set();
				timingsMap.set(judgementNameArray[i], textAsset);
				add(textAsset);
			}
		}
		updateScoreText();
	}

	var counterTextSize:Int = 18;

	function sortByShit(Obj1:String, Obj2:String):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Timings.judgementsMap.get(Obj1)[0], Timings.judgementsMap.get(Obj2)[0]);

	var left = (Init.trueSettings.get('Counter') == 'Left');

	override public function update(elapsed:Float)
	{
		// pain, this is like the 7th attempt
		healthBar.percent = (PlayState.health * 50);

		var iconLerp = 0.5;
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.initialWidth, iconP1.width, iconLerp)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.initialWidth, iconP2.width, iconLerp)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (PlayState.isRaidMode)
		{
			iconP1.y = healthBar.y + (healthBar.height * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - 50);

		}
		else
		{
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
			//shoving this in here to account for the funny healthbar movement lol
			iconP1.y = healthBar.y - (iconP1.height / 2);
			iconP2.y = healthBar.y - (iconP2.height / 2);
		}



		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		charIconPos();

		super.update(elapsed);
	}

	private final divider:String = ' - ';

	public function updateScoreText()
	{
		var importSongScore = PlayState.songScore;
		var importPlayStateCombo = PlayState.combo;
		var importMisses = PlayState.misses;
		if (PlayState.isRaidMode)
			scoreBar.text = 'DAMAGE: $importSongScore';
		else
			scoreBar.text = 'Score: $importSongScore';
		// testing purposes
		var displayAccuracy:Bool = Init.trueSettings.get('Display Accuracy');
		if (displayAccuracy)
		{
			scoreBar.text += divider + 'Accuracy: ' + Std.string(Math.floor(Timings.getAccuracy() * 100) / 100) + '%' + Timings.comboDisplay;
			scoreBar.text += divider + 'Combo Breaks: ' + Std.string(PlayState.misses);
			scoreBar.text += divider + 'Rank: ' + Std.string(Timings.returnScoreRating().toUpperCase());
		}

		scoreBar.x = ((FlxG.width / 2) - (scoreBar.width / 2));

		// update counter
		if (Init.trueSettings.get('Counter') != 'None')
		{
			for (i in timingsMap.keys()) {
				timingsMap[i].text = '${(i.charAt(0).toUpperCase() + i.substring(1, i.length))}: ${Timings.gottenJudgements.get(i)}';
				timingsMap[i].x = (5 + (!left ? (FlxG.width - 10) : 0) - (!left ? (6 * counterTextSize) : 0));
			}
		}

		// update playstate
		PlayState.detailsSub = scoreBar.text;
		PlayState.updateRPC(false);
	}

	public function beatHit(curBeat:Int)
	{
		if (!Init.trueSettings.get('Reduced Movements'))
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 45));
			iconP2.setGraphicSize(Std.int(iconP2.width + 45));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		//

		if (PlayState.SONG.song.toLowerCase() == 'overflow')
			iconsDance(curBeat);
	}

	public function stepUpdate(curStep:Int)
	{
		//kinda starting to understand why yoshubs didn't bother doing this shit for everything.
		//either way, still kinda salty that i gotta do it myself.
		if (PlayState.SONG.song.toLowerCase() == 'overflow')
		{
			switch(curStep)
			{
				case 1328:
					trace("tweening health to mid");
					//tween the healthbar to the middle of the screen vertically using the backout ease
					FlxTween.tween(healthBar, {y: (FlxG.height / 2) + 4}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.backOut});
					//and the healthbar background too
					FlxTween.tween(healthBarBG, {y: (FlxG.height / 2)}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.backOut});

				case 1344:
					iconAnimOn = true;


				case 1664:
					trace("tweening health away");
					//tween the healthbar outta here
					FlxTween.tween(healthBar, {y: 2500}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.backIn});
					//tween the healthbar background outta here too
					FlxTween.tween(healthBarBG, {y: 2500}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.backIn});
					iconAnimOn = false;
					
				case 2296:
					trace("health is BACK baby");
					//tween the healthbar back to where it was at the start
					var barY = FlxG.height * 0.875;
					if (Init.trueSettings.get('Downscroll'))
						barY = 64;
					FlxTween.tween(healthBar, {y: barY}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.elasticOut});
					//and the healthbar background too
					FlxTween.tween(healthBarBG, {y: barY - 4}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.elasticOut});
					//TODO: TEST IF THIS SUMBITCH WORKS OR NOT
					//UPDATE: IT DO

			}
		}
	}

	public function charAnims(stringArrow:String, char:Character)
	{
		//is this a terrible and inefficient way to do this? yes. do i care? no.
		//convert characters so shit actually works!!!
		if (iconAnimOn == true)
		{
			if (char.curCharacter == 'nobody')
			{
				nobodyIcon.playAnim(stringArrow, true);
			}
			if (char.curCharacter == player1Char)
			{
				bfIcon.playAnim(stringArrow, true);
			}
		}
		
	}

	public function iconsDance(curBeat:Int)
	{
		
		if ((bfIcon.animation.curAnim.name.startsWith("idle") 
		|| bfIcon.animation.curAnim.name.startsWith("dance")) 
			&& (curBeat % 2 == 0 || bfIcon.characterData.quickDancer))
			bfIcon.dance();
		

		//trace("trying to make da icons dance");
		//trace("nobodyIcon: " + nobodyIcon.animation.curAnim.name);
		//trace("curBeat: " + curBeat);


		// i miss kade engine.
		if ((nobodyIcon.animation.curAnim.name.startsWith("idle") 
		|| nobodyIcon.animation.curAnim.name.startsWith("dance"))  
			&& (curBeat % 2 == 0 || nobodyIcon.characterData.quickDancer))
		{
			nobodyIcon.dance();
		}
	}

	public function charIconPos()
	{
		//okay so trying to call update() breaks all the animation shit i set up so i'm just gonna do this here
		//definitely not the best way to do this but it works so i'm not gonna complain

		//trace("icon should be positionin'");

		if (PlayState.SONG.song.toLowerCase() == 'overflow')
			{
				nobodyIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (nobodyIcon.width - iconOffset);
				nobodyIcon.y = healthBar.y - (nobodyIcon.height / 2);
				//trace("nobodyIcon should be on healthbar");
				//trace("nobodyIcon.x: " + nobodyIcon.x);
				//trace("nobodyIcon.y: " + nobodyIcon.y);
				bfIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
				bfIcon.y = healthBar.y - (bfIcon.height / 2);
				
			}

	}
}
