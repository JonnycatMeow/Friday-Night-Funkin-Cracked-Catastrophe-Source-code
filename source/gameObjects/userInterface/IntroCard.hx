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
import meta.data.Conductor;
import meta.state.PlayState;

class IntroCard extends FlxTypedGroup<FlxBasic>
{
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
	public var curStep:Int = 0; //used to keep track of shit for debugging

    public function new()
    {
		super();
    	//this is a neat little function to make a swaggy intro card for whatever song you're playing
		//it'll use the song's name, difficulty, characters and their icons to make something stylish
		//should this be a subState? probably. am i gonna do that? no.

		//if you're not me and you're looking for a guide on how to use this properly, here's how:
		//check PlayState.hx and ctrl+F for 'daIntroCard', that'll give you a basic idea of how to set it up.

		//here's some general guidelines for how to use this so it looks good:
		//1. ALWAYS FOLLOW THE TWEEN ORDER AS SET UP IN HERE. It's laid out this way so it starts at the back and moves to the front.
		//2. You don't always have to tween it right at the start of the song. if you've got a bit of buildup before the song starts, you can tween it in later.
		//following on from 2., it might not hurt to tween it in a bit later if you're doing a character fakeout or something, the system will grab whoever's 
		//on screen at the time.
		//3. This is single-use only to save on memory. You can change it to be reusable by removing the 'destroy' function at the end of each FadeAll() tween.
		//4. Try not to have the intro card pop up whilst there's notes on the player's side of the screen. It'll look weird and serve as a distraction.
		
		//If you use this in your mod, please give me credit as God's Drunkest Driver or GDD.
		//Also, let me know in the thread so I can check it out!

		


		//eases & tween targets for different parts of the intro card:
		//bar: ExpoOut, scale
		//centered arrow: backOut, scale
		//top and bottom 'time to get funky' text: elasticOut, position
		//character icons: bounceOut, position
		//character names: expoInOut, position
		//vs text: elasticOut, position
		//song text: quintOut, position
		//difficulty text: bounceOut, position

		//rough positions for the intro card:
		//bar: center, center
		//centered arrow: center, center
		//top 'time to get funky' text: center, top of bar
		//bottom 'time to get funky' text: center, bottom of bar
		//opponent icon: screen width * 0.25, center of bar
		//player icon: screen width * 0.75, center of bar
		//opponent name: screen width * 0.25, screen height * 0.25
		//player name: screen width * 0.75, screen height * 0.25
		//vs text: center, screen height * 0.25
		//song title: center, screen height * 0.75
		//difficulty: center, screen height * 0.875

		//other notes:
		//bar should be 1/5th of the screen height, and should span the entire screen width
		//centered arrow should slightly poke out of the top and bottom of the bar
		//character icons should match the bar's height
		//character text should be roughly 25pt
		//song text should be roughly 50pt
		//difficulty text should be roughly 30pt

		//if there's any confusion, just take a look at the rough draft gif i made in animate

		

		//first, let's make the bar
		icBar = new FlxSprite(0, 0);
		icBar = icBar.makeGraphic(FlxG.width, Std.int(FlxG.height * 0.2), 0xffffffff);
		icBar.alpha = 0.6;
		icBar.scale.y = 0;
		icBar.screenCenter(XY);

		//now let's make the centered arrow
		icArrow = new FlxSprite(0, 0).loadGraphic(Paths.image("icons/arrow"));
		icArrow.scale.x = 0;
		icArrow.scale.y = 0;
		icArrow.updateHitbox();
		icArrow.screenCenter(XY);

		//now let's make the top and bottom 'time to get funky' text
		icTopText = new FlxText((FlxG.width * - 1) * 2, 0, FlxG.width, "TIME TO GET FUNKY//TIME TO GET FUNKY//TIME TO GET FUNKY//TIME TO GET FUNKY//TIME TO GET FUNKY//TIME TO GET FUNKY//TIME TO GET FUNKY//TIME TO GET FUNKY//TIME TO GET FUNKY//");
		icTopText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		icTopText.wordWrap = false;

		icBottomText = new FlxText(FlxG.width * 2, 0, FlxG.width, "TIME TO GET FUNKY//TIME TO GET FUNKY//TIME TO GET FUNKY//TIME TO GET FUNKY//TIME TO GET FUNKY//TIME TO GET FUNKY//TIME TO GET FUNKY//TIME TO GET FUNKY//TIME TO GET FUNKY//");
		icBottomText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		icBottomText.wordWrap = false;

		icTopText.y = icBar.y - icTopText.height;
		icBottomText.y = icBar.y + icBar.height;

		//now let's grab the opponent and player icons
		icOppIcon = new HealthIcon(PlayState.dadOpponent.curCharacter);
		icPlayerIcon = new HealthIcon(PlayState.boyfriend.curCharacter);

		icOppIcon.scale.x = icBar.height / icOppIcon.height;
		icOppIcon.scale.y = icBar.height / icOppIcon.height;
		icPlayerIcon.scale.x = icBar.height / icPlayerIcon.height;
		icPlayerIcon.scale.y = icBar.height / icPlayerIcon.height;

		//icOppIcon.x = FlxG.width * 0.25 - (icOppIcon.width / 2);
		icOppIcon.x = (FlxG.width * - 1) * 1.25;
		icOppIcon.y = icBar.y + (icBar.height / 2) - (icOppIcon.height / 2);
		//icPlayerIcon.x = FlxG.width * 0.75 - (icPlayerIcon.width / 2);
		icPlayerIcon.flipX = true;
		icPlayerIcon.x = FlxG.width * 1.25;
		icPlayerIcon.y = icBar.y + (icBar.height / 2) - (icPlayerIcon.height / 2);

		//now let's grab the opponent and player names
		icOppName = new FlxText(0, 0, FlxG.width * 0.5, CoolUtil.getFullName(PlayState.dadOpponent.curCharacter));
		icOppName.setFormat(Paths.font("vcr.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		//icOppName.x = FlxG.width * 0.25 - (icOppName.width / 2);
		icOppName.x = (FlxG.width * - 1) * 1.25;
		icOppName.y = FlxG.height * 0.25 - (icOppName.height / 2);

		icPlayerName = new FlxText(0, 0, FlxG.width * 0.5, CoolUtil.getFullName(PlayState.boyfriend.curCharacter));
		icPlayerName.setFormat(Paths.font("vcr.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		//icPlayerName.x = FlxG.width * 0.75 - (icPlayerName.width / 2);
		icPlayerName.x = FlxG.width * 1.25;
		icPlayerName.y = FlxG.height * 0.25 - (icPlayerName.height / 2);

		//now let's make the vs text
		icVsText = new FlxText(0, 0, FlxG.width, "VS");
		icVsText.setFormat(Paths.font("vcr.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		//icVsText.y = FlxG.height * 0.25 - (icVsText.height / 2);
		icVsText.y = (FlxG.height * - 1) * 1.25;
		icVsText.screenCenter(X);

		//now let's make the song title text
		icSongName = new FlxText(0, 0, FlxG.width, CoolUtil.dashToSpace(PlayState.SONG.song));
		icSongName.setFormat(Paths.font("vcr.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		//icSongName.y = FlxG.height * 0.75 - (icSongName.height / 2);
		icSongName.y = FlxG.height * 1.25;
		icSongName.screenCenter(X);

		//now let's make the difficulty text
		//let's start by determining the current difficulty
		var difficulty = CoolUtil.difficultyFromNumber(PlayState.storyDifficulty);

		icSongDiff = new FlxText(0, 0, FlxG.width, difficulty);
		icSongDiff.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		//icSongDiff.y = FlxG.height * 0.875 - (icSongDiff.height / 2);
		icSongDiff.y = FlxG.height * 1.375;
		icSongDiff.screenCenter(X);

		//now let's add all of these in
		add(icBar);
		add(icTopText);
		add(icBottomText);
		add(icArrow);
		add(icOppIcon);
		add(icPlayerIcon);
		add(icOppName);
		add(icPlayerName);
		add(icVsText);
		add(icSongName);
		add(icSongDiff);
    }

    //functions for all the different tweens be here
    //copiloted in for now, will need to be fixed + adjusted later

    public function tweenBar()
    {
		icBar.color = CoolUtil.getDominantIconColour(PlayState.dadOpponent.curCharacter);
        FlxTween.tween(icBar, {"scale.y": 1}, Conductor.crochet / 1000, {ease: FlxEase.expoOut});
		trace("tweened bar at step" + curStep);
    }

    public function tweenArrow()
    {
        FlxTween.tween(icArrow, {"scale.x": 0.15, "scale.y": 0.15}, Conductor.crochet / 1000, {ease: FlxEase.backOut});
		trace("tweened arrow at step" + curStep);
    }

    public function tweenTopText()
    {
        FlxTween.tween(icTopText, {x: 0}, Conductor.crochet / 1000, {ease: FlxEase.elasticOut});
		trace("tweened top text at step" + curStep);
    }

    public function tweenBottomText()
    {
        FlxTween.tween(icBottomText, {x: 0}, Conductor.crochet / 1000, {ease: FlxEase.elasticOut});
		trace("tweened bottom text at step" + curStep);
    }

    public function tweenOppIcon()
    {
		icOppIcon.updateIcon(PlayState.dadOpponent.curCharacter);
        FlxTween.tween(icOppIcon, {x: FlxG.width * 0.25 - (icOppIcon.width / 2)}, Conductor.crochet / 1000, {ease: FlxEase.bounceOut});
		trace("tweened opp icon at step" + curStep);
    }

    public function tweenPlayerIcon()
    {
		icPlayerIcon.updateIcon(PlayState.boyfriend.curCharacter);
        FlxTween.tween(icPlayerIcon, {x: FlxG.width * 0.75 - (icPlayerIcon.width / 2)}, Conductor.crochet / 1000, {ease: FlxEase.bounceOut});
		trace("tweened player icon at step" + curStep);
    }

    public function tweenOppName()
    {
		icOppName.text = CoolUtil.getFullName(PlayState.dadOpponent.curCharacter);
        FlxTween.tween(icOppName, {x: FlxG.width * 0.25 - (icOppName.width / 2)}, Conductor.crochet / 1000, {ease: FlxEase.expoInOut});
		trace("tweened opp name at step" + curStep);
    }

    public function tweenPlayerName()
    {
		icPlayerName.text = CoolUtil.getFullName(PlayState.boyfriend.curCharacter);
        FlxTween.tween(icPlayerName, {x: FlxG.width * 0.75 - (icPlayerName.width / 2)}, Conductor.crochet / 1000, {ease: FlxEase.expoInOut});
		trace("tweened player name at step" + curStep);
    }

    public function tweenVsText()
    {
        FlxTween.tween(icVsText, {"y": FlxG.height * 0.25 - (icVsText.height / 2)}, Conductor.crochet / 1000, {ease: FlxEase.elasticOut});
		trace("tweened vs text at step" + curStep);
    }

    public function tweenSongName()
    {
        FlxTween.tween(icSongName, {"y": FlxG.height * 0.75 - (icSongName.height / 2)}, Conductor.crochet / 1000, {ease: FlxEase.quintOut});
		trace("tweened song name at step" + curStep);
    }

    public function tweenSongDiff()
    {
        FlxTween.tween(icSongDiff, {"y": FlxG.height * 0.875 - (icSongDiff.height / 2)}, Conductor.crochet / 1000, {ease: FlxEase.bounceOut});
		trace("tweened song diff at step" + curStep);
    }

	//now let's make a function to tween all of these at once for testing purposes
	public function tweenAll()
	{
		tweenBar();
		tweenArrow();
		tweenTopText();
		tweenBottomText();
		tweenOppIcon();
		tweenPlayerIcon();
		tweenOppName();
		tweenPlayerName();
		tweenVsText();
		tweenSongName();
		tweenSongDiff();
	}

	//this'll fade out everything, and delete them when they're done
	public function fadeAll()
	{
		trace("fading all at step" + curStep);
		FlxTween.tween(icBar, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.expoOut, onComplete: function(tween:FlxTween)
		{
			icBar.destroy();
		}});
		FlxTween.tween(icTopText, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.expoOut, onComplete: function(tween:FlxTween)
		{
			icTopText.destroy();
		}});
		FlxTween.tween(icBottomText, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.expoOut, onComplete: function(tween:FlxTween)
		{
			icBottomText.destroy();
		}});
		FlxTween.tween(icArrow, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.expoOut, onComplete: function(tween:FlxTween)
		{
			icArrow.destroy();
		}});
		FlxTween.tween(icOppIcon, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.expoOut, onComplete: function(tween:FlxTween)
		{
			icOppIcon.destroy();
		}});
		FlxTween.tween(icPlayerIcon, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.expoOut, onComplete: function(tween:FlxTween)
		{
			icPlayerIcon.destroy();
		}});
		FlxTween.tween(icOppName, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.expoOut, onComplete: function(tween:FlxTween)
		{
			icOppName.destroy();
		}});
		FlxTween.tween(icPlayerName, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.expoOut, onComplete: function(tween:FlxTween)
		{
			icPlayerName.destroy();
		}});
		FlxTween.tween(icVsText, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.expoOut, onComplete: function(tween:FlxTween)
		{
			icVsText.destroy();
		}});
		FlxTween.tween(icSongName, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.expoOut, onComplete: function(tween:FlxTween)
		{
			icSongName.destroy();
		}});
		FlxTween.tween(icSongDiff, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.expoOut, onComplete: function(tween:FlxTween)
		{
			icSongDiff.destroy();
		}});

	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}


}