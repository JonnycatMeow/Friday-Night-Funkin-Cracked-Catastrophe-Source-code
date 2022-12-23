package meta.state;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import gameObjects.*;
import gameObjects.userInterface.*;
import gameObjects.userInterface.notes.*;
import gameObjects.userInterface.notes.Strumline.UIStaticArrow;
import meta.*;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.Song.SwagSong;
import meta.state.charting.*;
import meta.state.menus.*;
import meta.subState.*;
import openfl.display.GraphicsShader;
import openfl.events.KeyboardEvent;
import openfl.filters.ShaderFilter;
import openfl.media.Sound;
import openfl.utils.Assets;
import sys.io.File;
import flash.system.System;

//hehe aura here, let's break some shit.
import meta.shaders.TestShader;
import DynamicShaderHandler;

//stuff for settin sum gotdam FLAGS
import meta.data.Flags;

//don't forget that INTRO CARD
import gameObjects.userInterface.IntroCard;

//raid boss stuff lol
import flixel.ui.FlxBar;
import meta.RaidUtil;
import gameObjects.userInterface.ChatBox;

using StringTools;

#if !html5
import meta.data.dependency.Discord;
#end

class PlayState extends MusicBeatState
{
	public static var startTimer:FlxTimer;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 2;

	public static var songMusic:FlxSound;
	public static var vocals:FlxSound;
	public static var vocalsopp:FlxSound;
	public static var hasSplitVocals:Bool = false;

	public static var campaignScore:Int = 0;

	public static var dadOpponent:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public static var assetModifier:String = 'base';
	public static var changeableSkin:String = 'default';

	private var unspawnNotes:Array<Note> = [];
	private var ratingArray:Array<String> = [];
	private var allSicks:Bool = true;

	// if you ever wanna add more keys
	private var numberOfKeys:Int = 4;

	// get it cus release
	// I'm funny just trust me
	private var curSection:Int = 0;
	private var camFollow:FlxObject;
	private var camFollowPos:FlxObject;

	// Discord RPC variables
	public static var songDetails:String = "";
	public static var detailsSub:String = "";
	public static var detailsPausedText:String = "";

	private static var prevCamFollow:FlxObject;

	private var curSong:String = "";
	private var gfSpeed:Int = 1;

	public static var health:Float = 1; // mario
	public static var combo:Int = 0;

	public static var misses:Int = 0;

	public var generatedMusic:Bool = false;

	private var startingSong:Bool = false;
	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var inCutscene:Bool = false;

	var canPause:Bool = true;

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	public static var camHUD:FlxCamera;
	public static var camGame:FlxCamera;
	public static var dialogueHUD:FlxCamera;

	public var camDisplaceX:Float = 0;
	public var camDisplaceY:Float = 0; // might not use depending on result
	public static var cameraSpeed:Float = 1;

	public static var defaultCamZoom:Float = 1.05;

	public static var forceZoom:Array<Float>;

	public static var songScore:Int = 0;

	var storyDifficultyText:String = "";

	public static var iconRPC:String = "";

	public static var songLength:Float = 0;

	private var stageBuild:Stage;

	public static var uiHUD:ClassHUD;

	public static var daPixelZoom:Float = 6;
	public static var determinedChartType:String = "";

	// strumlines
	private var dadStrums:Strumline;
	private var boyfriendStrums:Strumline;

	public static var strumLines:FlxTypedGroup<Strumline>;
	public static var strumHUD:Array<FlxCamera> = [];

	private var allUIs:Array<FlxCamera> = [];

	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo objects in an array
	public static var lastCombo:Array<FlxSprite>;

	//funny piracy check vars go here!!
	public static var pcScoreToBeat:Int = 200000; //the score you gots to beat to pass the song
	public static var pcScoreToBeatText:FlxText; //should i probably look at getting this shit integrated to that fancy ClassHUD thing? probably. am i going to? no.
	public static var pcGoodText:FlxText; //good text
	public static var pcFuckingText:FlxText; //fucking text
	public static var pcLuckText:FlxText; //thinkin bout this now, i could've just had a spritesheet handling this shit, but too late now.
	public static var dialogPath:String = ""; //used for some fancy multiple dialogue shit
	public static var oldZoom:Float; //stores the old zoom value for when i wanna reset the camera zoom
	public static var camZoomed:Bool = false; //used to see if the camera is zoomed or not
	public static var bigZooms:Bool = false; //used to make the cam bump more intense
	public static var zoomInterval:Int = 4; //used to control how often the cam bumps to the beat
	public static var literallyJustAFuckingBlackRectangle:FlxSprite; //used for the neat dimming effect on the 2nd buildup

	//shader filters
	//public static var sdrBayers:DynamicShaderHandler = new DynamicShaderHandler('BayersDithering');
	//public static var sdrGlitch:DynamicShaderHandler = new DynamicShaderHandler('Glitch');
	public static var dsh:DynamicShaderHandler;

	//TESTING SHIT STARTS HERE!!!!
	public static var shaderCamera:FlxCamera;
	public static var animatedShaders:Map<String, DynamicShaderHandler> = new Map<String, DynamicShaderHandler>();
	
	public static var ovfHealth:Bool = false;

	//dbdos vars here
	public var hasZoomTweenedDad:Bool = false;
	public var hasZoomTweenedBf:Bool = false;

	//vars for cam bump handler here
	public var cHandlerBumpFreq:Int = 4;
	public var cHandlerBumpIntensity:Float = 0.1;
	public var cHandlerBumpIntensityHud:Float = 0.05;
	public var timeFocused:Int = 0; //used to see how long the cam's been focused on a character
	public var focusedChar:String = ""; //used to reset timeFocused when the cam switches focus
	public var oldFocusedChar:String = ""; //used to see if the cam's focus has changed

	//other cam vars here
	public var cIsCentered:Bool = false; //used to see if the cam is centered or not

	//vars for the intro card here
	public var daIntroCard:IntroCard;
	public var hasUniqueIntroCard:Bool = false; //used to see if the song has unique intro card timings

	//character select vars here
	public static var freeplayChar:String = "";

	//song specific vars here

	//senpai/spirit raid vars
	public var senpaiDead:FlxSprite;

	//jacket raid vars
	public var jacketBlack:FlxSprite;
	public var jacketText:FlxText;
	public var jacketFBI:FlxSprite;

	//nobody raid vars
	public var oppIsBig:Bool = false;
	public var nobodyBlack:FlxSprite;

	//raid boss vars here
	public static var raidBossHealth:Float = 5000000;
	public static var raidBossMaxHealth:Float = 5000000;
	public static var raidBossHealthBar:FlxBar;
	public static var raidBossHealthBarBG:FlxSprite;
	public static var raidBossHealthBarText:FlxText;
	public static var raidBossPlayers:Array<String> = [];
	public static var isRaidMode:Bool = false;
	public static var raidUtils:RaidUtil;
	public static var raidBossScoreReq:Int = 0;
	public static var raidBossDamageSlots:Int = 0;
	public static var raidBossDamageText:FlxText;
	public static var raidBossDamageValues:Array<Int> = [];
	public static var chatBox:ChatBox;
	public static var chatBoxBG:FlxSprite;
	public static var chatBoxText:FlxText;
	public static var chatBoxClearing:Bool = false;

	public var allowGf:Bool = true; //used to see if we should spawn gf or not


	// at the beginning of the playstate
	override public function create()
	{
		super.create();

		// reset any values and variables that are static
		songScore = 0;
		combo = 0;
		health = 1;
		misses = 0;
		if (isRaidMode) 
		{
			raidBossHealth = raidBossMaxHealth;
		}
		// sets up the combo object array
		lastCombo = [];

		defaultCamZoom = 1.05;
		cameraSpeed = 1;
		forceZoom = [0, 0, 0, 0];

		Timings.callAccuracy();

		assetModifier = 'base';
		changeableSkin = 'default';

		camZoomed = false; //YOU.

		if (isRaidMode)
		{
			//!get rid of this later
			var playerDoc = sys.io.File.getContent(('${Sys.getCwd()}assets/misc/raidPlayers.txt'));
			var tempPlayerArray = playerDoc.split(',');
			for (player in tempPlayerArray)
			{
				raidBossPlayers.push(player);
			}
			#if debug
			for (player in raidBossPlayers)
			{
				trace('raidBossPlayers array: ' + player);
			}
			#end
		}

		// stop any existing music tracks playing
		resetMusic();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// create the game camera
		camGame = new FlxCamera();
		

		// create the hud camera (separate so the hud stays on screen)
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame); 
		//FlxG.cameras.add(shaderCamera);
		FlxG.cameras.add(camHUD);
		allUIs.push(camHUD);
		FlxCamera.defaultCameras = [camGame];

		//time to see if the filter shit still works or not
		//update: it does! need to figure out how to switch it on and off, though.
		//new DynamicShaderHandler('Dawnbringer');
		//camGame.setFilters([new ShaderFilter(animatedShaders["Dawnbringer"].shader)]);

		// default song
		if (SONG == null)
			SONG = Song.loadFromJson('test', 'test');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		/// here we determine the chart type!
		// determine the chart type here
		determinedChartType = "FNF";

		//

		// set up a class for the stage type in here afterwards
		curStage = "";
		// call the song's stage if it exists
		if (SONG.stage != null)
			curStage = SONG.stage;

		// cache shit
		displayRating('sick', 'early', true);
		popUpCombo(true);
		//


		trace(curStage);
		trace(SONG.song);

		//time to check for any pre-song shit we need to do
		switch (SONG.song.toLowerCase())
		{
			case 'dbdos':
				hasUniqueIntroCard = true;
				allowGf = false;
			
			case 'overflow':
				hasUniqueIntroCard = true;
				allowGf = false;

			case 'piracy-check':
				hasUniqueIntroCard = true;

			case 'moonrise':
				hasUniqueIntroCard = true;

			case 'dungeon-drama':
				hasUniqueIntroCard = true;

			case 'seg fault':
				allowGf = false;
				hasUniqueIntroCard = true;

			case 'broken-heart-corrosion':
				changeShader('CRT');
				allowGf = false;
				hasUniqueIntroCard = true;

			case 'carpenter':
				changeShader('tape');
				hasUniqueIntroCard = true;

			default:
				hasUniqueIntroCard = false;
		}

		//let's set up raid mode here (if it's enabled)
		if (isRaidMode)
		{
			//grab score requirements & damage slots here
			switch (SONG.song.toLowerCase())
			{
				case 'dbdos':
					raidBossScoreReq = 200000;
					raidBossDamageSlots = 8;

				case 'seg fault':
					raidBossScoreReq = 230000;
					raidBossDamageSlots = 16;

				case 'broken-heart-corrosion':
					raidBossScoreReq = 130000;
					raidBossDamageSlots = 16;

				case 'carpenter':
					raidBossScoreReq = 120000;
					raidBossDamageSlots = 8;
			}

			//set up raidUtil here
			raidUtils = new RaidUtil();

			raidBossDamageText = new FlxText(0, 0, FlxG.width, 'Damage Slots: ' + raidBossDamageSlots);
			raidBossDamageText.setFormat('VCR OSD Mono', 16, 0xFFFFFFFF, 'center');

			//grab the damage values from raidUtils
			raidBossDamageValues = raidUtils.calculateRandomDamageValues();
			//quick trace to make sure everything's coming through right
			#if debug
			for (value in raidBossDamageValues)
			{
				trace('PlayState.raidBossDamageValues: ' + value);
			}
			#end
		}

		stageBuild = new Stage(curStage);
		add(stageBuild);

		/*
			Everything related to the stages aside from things done after are set in the stage class!
			this means that the girlfriend's type, boyfriend's position, dad's position, are all there

			It serves to clear clutter and can easily be destroyed later. The problem is,
			I don't actually know if this is optimised, I just kinda roll with things and hope
			they work. I'm not actually really experienced compared to a lot of other developers in the scene,
			so I don't really know what I'm doing, I'm just hoping I can make a better and more optimised
			engine for both myself and other modders to use!
		 */

		// set up characters here too
		gf = new Character();
		gf.adjustPos = false;
		gf.setCharacter(300, 100, stageBuild.returnGFtype(curStage));
		gf.scrollFactor.set(0.95, 0.95);

		dadOpponent = new Character().setCharacter(50, 850, SONG.player2);
		if (curStage == 'dbdos')
		{
			dadOpponent.setGraphicSize(Math.floor(dadOpponent.width * 0.75));
			dadOpponent.updateHitbox();
		}
		boyfriend = new Boyfriend();
		if (!isStoryMode && freeplayChar != "")
			boyfriend.setCharacter(750, 850, freeplayChar); //freeplay character select thingy
		else
			boyfriend.setCharacter(750, 850, SONG.player1);
		// if you want to change characters later use setCharacter() instead of new or it will break

		var camPos:FlxPoint = new FlxPoint(gf.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

		stageBuild.repositionPlayers(curStage, boyfriend, dadOpponent, gf);
		stageBuild.dadPosition(curStage, boyfriend, dadOpponent, gf, camPos);

		changeableSkin = Init.trueSettings.get("UI Skin");
		if ((curStage.startsWith("school")) && ((determinedChartType == "FNF")))
			assetModifier = 'pixel';
		if ((SONG.song.toLowerCase() == 'broken-heart-corrosion') && ((determinedChartType == "FNF")))
			assetModifier = 'pixel';

		// add characters
		if (allowGf)
			add(gf);

		// add limo cus dumb layering
		if (curStage == 'highway')
			add(stageBuild.limo);

		add(dadOpponent);

		add(stageBuild.midground);

		if (curStage == 'dbdos')
		{
			add(stageBuild.dbdlimo);
		}

		add(boyfriend);

		add(stageBuild.foreground);

		// force them to dance
		dadOpponent.dance();
		gf.dance();
		boyfriend.dance();

		if (isRaidMode)
		{
			var barX = dadOpponent.x;
			var barY:Float = 0;
			var barColour:FlxColor = 0xFF000000;

			switch (curStage)
			{
				case 'spiritRaid':
					barX -= 250;
					barY = dadOpponent.y - (dadOpponent.height / 4) - 25;
					barColour = CoolUtil.getDominantIconColour('spirit');
				case 'dbdos':
					barY = dadOpponent.y - 50;
					barColour = CoolUtil.getDominantIconColour('nobody');

				default:
					barY = dadOpponent.y - 50;
					barColour = CoolUtil.getDominantIconColour(dadOpponent.curCharacter);
			}

			//set up the health bar above the opponent
			raidBossHealthBar = new FlxBar(barX, barY, LEFT_TO_RIGHT, 350, 50, dadOpponent, "raidBossHealth", 0, raidBossMaxHealth, true);
			raidBossHealthBar.createColoredEmptyBar(0xff000000, true, 0xffffffff);
			raidBossHealthBar.createColoredFilledBar(barColour, false, 0x00ffffff);
			raidBossHealthBar.setRange(0, raidBossMaxHealth);
			add(raidBossHealthBar);

			//set up the health text inside the health bar
			raidBossHealthBarText = new FlxText(raidBossHealthBar.getMidpoint().x - 175, raidBossHealthBar.y + 10, 350, '${Std.string(raidBossHealth)} / ${Std.string(raidBossMaxHealth)}');
			raidBossHealthBarText.setFormat('VCR OSD Mono', 20, 0xffffffff, CENTER);
			add(raidBossHealthBarText);

			//set up the chatbox here
			if (Init.trueSettings.get('Raid Chat') == true)
			{
				chatBox = new ChatBox();
				chatBoxBG = new FlxSprite(0, 0);
        		chatBoxBG.makeGraphic(Math.floor(FlxG.width * 0.4), Math.floor(FlxG.height * 0.4), 0x50000000); //sizing is subject to change, but this is a good start hopefully
				chatBoxBG.scrollFactor.x = 0;
				chatBoxBG.scrollFactor.y = 0;

				chatBoxText = new FlxText(0, 0, chatBoxBG.width, ''); //this is just a test, we'll change it later
				chatBoxText.scrollFactor.x = 0;
				chatBoxText.scrollFactor.y = 0;
				chatBoxText.setFormat('VCR OSD Mono', 16, 0xFFFFFFFF, 'left');
				chatBoxText.wordWrap = true;

				chatBoxBG.cameras = [camHUD];
				chatBoxText.cameras = [camHUD];

				//get the chatbox moved to the bottom left
				chatBoxBG.x = 0;
				chatBoxBG.y = FlxG.height - chatBoxBG.height;
				//get the text moved to the top of the chatbox
				chatBoxText.x = chatBoxBG.x + 10;
				chatBoxText.y = chatBoxBG.y + 10;

				add(chatBoxBG);
				add(chatBoxText);
			}
			
		}

		// set song position before beginning
		Conductor.songPosition = -(Conductor.crochet * 4);

		// EVERYTHING SHOULD GO UNDER THIS, IF YOU PLAN ON SPAWNING SOMETHING LATER ADD IT TO STAGEBUILD OR FOREGROUND
		// darken everything but the arrows and ui via a flxsprite
		var darknessBG:FlxSprite = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		darknessBG.alpha = (100 - Init.trueSettings.get('Stage Opacity')) / 100;
		darknessBG.scrollFactor.set(0, 0);
		add(darknessBG);


		// piracy check shit lols!
		if(SONG.song.toLowerCase() == 'piracy-check')
		{
			//set up the score to beat text
			pcScoreToBeatText = new FlxText(0, 0, FlxG.width, "SCORE TO BEAT: \n" + pcScoreToBeat); //set the initial text up
			pcScoreToBeatText.setFormat("VCR OSD Mono", 128, 0xFFFFFFFF, "center", OUTLINE, 0xFF000000); //aesthetics lol
			pcScoreToBeatText.setBorderStyle(OUTLINE, 0xff000000, 10, 0); //set the border
			pcScoreToBeatText.scrollFactor.set(0, 0); //this is so it doesn't scroll with the camera
			pcScoreToBeatText.alpha = 0; //set this to 0 so we can tween it in later
			pcScoreToBeatText.screenCenter(); //center this sumbitch

			add(pcScoreToBeatText); //add it to the screen, might need to play around a bit with where it gets positioned lol

			//set up the good text
			pcGoodText = new FlxText(pcScoreToBeatText.x * 0.75, pcScoreToBeatText.y * 1.25, FlxG.width, "GOOD"); //might need to play around with the x and y positions
			pcGoodText.setFormat("VCR OSD Mono", 128, 0xFFFFFFFF, "center", OUTLINE, 0xFF000000); //same as above, but smaller
			pcGoodText.setBorderStyle(OUTLINE, 0xff000000, 10, 0); //same as above
			pcGoodText.scrollFactor.set(0, 0); //same as above
			pcGoodText.alpha = 0; //same as above, but instead of tweening we're going from 0 > 100 lol

			add(pcGoodText); //same as above

			//set up the fucking text
			pcFuckingText = new FlxText(pcScoreToBeatText.x, pcScoreToBeatText.y * 1.25, FlxG.width, "FUCKING"); //same as above
			pcFuckingText.setFormat("VCR OSD Mono", 128, 0xFFFFFFFF, "center", OUTLINE, 0xFF000000); //same as above
			pcFuckingText.setBorderStyle(OUTLINE, 0xff000000, 10, 0); //same as above
			pcFuckingText.scrollFactor.set(0, 0); //same as above
			pcFuckingText.alpha = 0; //same as above, but instead of tweening we're going from 0 > 100 lol

			add(pcFuckingText); //same as above

			//set up the luck text
			pcLuckText = new FlxText(pcScoreToBeatText.x * 1.25, pcScoreToBeatText.y * 1.25, FlxG.width, "LUCK"); //same as above
			pcLuckText.setFormat("VCR OSD Mono", 128, 0xFFFFFFFF, "center", OUTLINE, 0xFF000000); //same as above
			pcLuckText.setBorderStyle(OUTLINE, 0xff000000, 10, 0); //same as above
			pcLuckText.scrollFactor.set(0, 0); //same as above
			pcLuckText.alpha = 0; //same as above, but instead of tweening we're going from 0 > 100 lol

			add(pcLuckText); //same as above


		}

		//senpai raid shit
		if(SONG.song.toLowerCase() == 'broken-heart-corrosion')
		{
			senpaiDead = new FlxSprite();
			senpaiDead.frames = Paths.getSparrowAtlas('cutscene/senpai/senpaiCrazy');
			senpaiDead.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
			senpaiDead.animation.add('1', [0, 1, 3, 6, 8], 24, false);
			senpaiDead.animation.add('2', [9, 11, 17, 20, 46], 24, false);
			senpaiDead.animation.add('blast', [60, 61, 62], 24, true);
			senpaiDead.setGraphicSize(Std.int(senpaiDead.width * 6));
			senpaiDead.scrollFactor.set();
			senpaiDead.updateHitbox();
			senpaiDead.screenCenter();
			senpaiDead.alpha = 0;
			add(senpaiDead);
		}

		//jacket raid shit
		if(SONG.song.toLowerCase() == 'carpenter')
		{
			health = 2;
			//FBI screen background
			literallyJustAFuckingBlackRectangle = new FlxSprite();
			literallyJustAFuckingBlackRectangle.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), 0xff738c9c);
			literallyJustAFuckingBlackRectangle.scrollFactor.set(1, 1);
			literallyJustAFuckingBlackRectangle.screenCenter(XY);
			literallyJustAFuckingBlackRectangle.alpha = 1;
			add(literallyJustAFuckingBlackRectangle);

			//the following presentation has been approved for mature audiences only
			jacketText = new FlxText(0, FlxG.height * 0.75, FlxG.width * 0.8, "THE FOLLOWING PRESENTATION HAS BEEN APPROVED FOR MATURE AUDIENCES ONLY");
			jacketText.scrollFactor.set(1, 1);
			jacketText.setFormat("VCR OSD Mono", 64, 0xfff7c531, "center");
			jacketText.screenCenter(X);
			add(jacketText);

			//FBI logo
			jacketFBI = new FlxSprite(0, 0).loadGraphic(Paths.image('backgrounds/jacketRaid/FBI'));
			jacketFBI.scrollFactor.set(1, 1);
			jacketFBI.setGraphicSize(Std.int(FlxG.width * 0.2));
			jacketFBI.updateHitbox();
			jacketFBI.screenCenter(X);
			jacketFBI.y = FlxG.height * 0.2;
			add(jacketFBI);

			//black screen
			//in hindsight, i probably should've used the black rectangle var for this, but i'm too lazy to change it now
			jacketBlack = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/base/black'));
			jacketBlack.setGraphicSize(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2));
			jacketBlack.updateHitbox();
			jacketBlack.scrollFactor.set(1, 1);
			jacketBlack.screenCenter(XY);
			jacketBlack.alpha = 1;
			add(jacketBlack);
		}

		if (SONG.song.toLowerCase() == 'seg fault')
		{
			//set up the black rectangle
			nobodyBlack = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/base/black'));
			nobodyBlack.setGraphicSize(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3));
			nobodyBlack.updateHitbox();
			nobodyBlack.scrollFactor.set(1, 1);
			nobodyBlack.screenCenter(XY);
			nobodyBlack.alpha = 1;
			add(nobodyBlack);
		}


		// strum setup
		strumLines = new FlxTypedGroup<Strumline>();

		// generate the song
		generateSong(SONG.song);

		// set the camera position to the center of the stage
		camPos.set(gf.x + (gf.frameWidth / 2), gf.y + (gf.frameHeight / 2));

		// create the game camera
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(camPos.x, camPos.y);
		// check if the camera was following someone previously
		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);
		add(camFollowPos);

		// actually set the camera up
		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		// initialize ui elements
		startingSong = true;
		startedCountdown = true;

		//
		var placement = (FlxG.width / 2);
		dadStrums = new Strumline(placement - (FlxG.width / 4), this, dadOpponent, false, true, false, 4, Init.trueSettings.get('Downscroll'));
		dadStrums.visible = !Init.trueSettings.get('Centered Notefield');
		boyfriendStrums = new Strumline(placement + (!Init.trueSettings.get('Centered Notefield') ? (FlxG.width / 4) : 0), this, boyfriend, true, false, true,
			4, Init.trueSettings.get('Downscroll'));

		strumLines.add(dadStrums);
		strumLines.add(boyfriendStrums);

		// strumline camera setup
		strumHUD = [];
		for (i in 0...strumLines.length)
		{
			// generate a new strum camera
			strumHUD[i] = new FlxCamera();
			strumHUD[i].bgColor.alpha = 0;

			strumHUD[i].cameras = [camHUD];
			allUIs.push(strumHUD[i]);
			FlxG.cameras.add(strumHUD[i]);
			// set this strumline's camera to the designated camera
			strumLines.members[i].cameras = [strumHUD[i]];
		}
		add(strumLines);

		if (isRaidMode)
		{
			dadStrums.visible = false;
		}

		uiHUD = new ClassHUD();
		add(uiHUD);
		uiHUD.cameras = [camHUD];

		if (SONG.song.toLowerCase() == 'carpenter')
		{
			uiHUD.visible = false;
			boyfriendStrums.visible = false;
		}

		//intro card camera here
		daIntroCard = new IntroCard();
		add(daIntroCard);
		daIntroCard.cameras = [camHUD];

		/*if (dadOpponent.curCharacter == 'nobodyIcon')
		{
			//this should hopefully hide P2's icon, and then kill + respawn the dadOpponent to place them in front, then change the cam so hopefully
			//the positioning in update() works out.
			uiHUD.iconP2.alpha = 0;
			dadOpponent.kill();
			dadOpponent = new Character().setCharacter(50, 850, SONG.player2);
			dadOpponent.cameras = [camHUD];
		} */
		//

		// create a hud over the hud camera for dialogue
		dialogueHUD = new FlxCamera();
		dialogueHUD.bgColor.alpha = 0;
		FlxG.cameras.add(dialogueHUD);

		//
		keysArray = [
			copyKey(Init.gameControls.get('LEFT')[0]),
			copyKey(Init.gameControls.get('DOWN')[0]),
			copyKey(Init.gameControls.get('UP')[0]),
			copyKey(Init.gameControls.get('RIGHT')[0])
		];

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		
		Paths.clearUnusedMemory();

		// call the funny intro cutscene depending on the song
		if (!skipCutscenes())
			songIntroCutscene();
		else
			startCountdown();

		/**
		 * SHADERS
		 *
		 * This is a highly experimental code by gedehari to support runtime shader parsing.
		 * Usually, to add a shader, you would make it a class, but now, I modified it so
		 * you can parse it from a file.
		 *
		 * This feature is planned to be used for modcharts
		 * (at this time of writing, it's not available yet).
		 *
		 * This example below shows that you can apply shaders as a FlxCamera filter.
		 * the GraphicsShader class accepts two arguments, one is for vertex shader, and
		 * the second is for fragment shader.
		 * Pass in an empty string to use the default vertex/fragment shader.
		 *
		 * Next, the Shader is passed to a new instance of ShaderFilter, neccesary to make
		 * the filter work. And that's it!
		 *
		 * To access shader uniforms, just reference the `data` property of the GraphicsShader
		 * instance.
		 *
		 * Thank you for reading! -gedehari
		 */

		// Uncomment the code below to apply the effect

		/*
		var shader:GraphicsShader = new GraphicsShader("", File.getContent("./assets/shaders/vhs.frag"));
		FlxG.camera.setFilters([new ShaderFilter(shader)]);
		*/
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey>
	{
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len)
		{
			if (copiedArray[i] == NONE)
			{
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
	
	var keysArray:Array<Dynamic>;

	public function onKeyPress(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if ((key >= 0)
			&& !boyfriendStrums.autoplay
			&& (FlxG.keys.checkStatus(eventKey, JUST_PRESSED))
			&& (FlxG.keys.enabled && !paused && (FlxG.state.active || FlxG.state.persistentUpdate)))
		{
			if (generatedMusic)
			{
				var previousTime:Float = Conductor.songPosition;
				Conductor.songPosition = songMusic.time;
				// improved this a little bit, maybe its a lil
				var possibleNoteList:Array<Note> = [];
				var pressedNotes:Array<Note> = [];

				boyfriendStrums.allNotes.forEachAlive(function(daNote:Note)
				{
					if ((daNote.noteData == key) && daNote.canBeHit && !daNote.isSustainNote && !daNote.tooLate && !daNote.wasGoodHit)
						possibleNoteList.push(daNote);
				});
				possibleNoteList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				// if there is a list of notes that exists for that control
				if (possibleNoteList.length > 0)
				{
					var eligable = true;
					var firstNote = true;
					// loop through the possible notes
					for (coolNote in possibleNoteList)
					{
						for (noteDouble in pressedNotes)
						{
							if (Math.abs(noteDouble.strumTime - coolNote.strumTime) < 10)
								firstNote = false;
							else
								eligable = false;
						}

						if (eligable) {
							goodNoteHit(coolNote, boyfriend, boyfriendStrums, firstNote); // then hit the note
							pressedNotes.push(coolNote);
						}
						// end of this little check
					}
					//
				}
				else // else just call bad notes
					if (!Init.trueSettings.get('Ghost Tapping'))
						missNoteCheck(true, key, boyfriend, true);
				Conductor.songPosition = previousTime;
			}

			if (boyfriendStrums.receptors.members[key] != null 
			&& boyfriendStrums.receptors.members[key].animation.curAnim.name != 'confirm')
				boyfriendStrums.receptors.members[key].playAnim('pressed');
		}
	}

	public function onKeyRelease(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if (FlxG.keys.enabled && !paused && (FlxG.state.active || FlxG.state.persistentUpdate)) {
			// receptor reset
			if (key >= 0 && boyfriendStrums.receptors.members[key] != null)
				boyfriendStrums.receptors.members[key].playAnim('static');
		}
	}

	private function getKeyFromEvent(key:FlxKey):Int {
		if (key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if (key == keysArray[i][j])
						return i;
				}
			}
		}
		return -1;
	}

	override public function destroy() {
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		super.destroy();
	}

	var staticDisplace:Int = 0;

	var lastSection:Int = 0;

	override public function update(elapsed:Float)
	{
		stageBuild.stageUpdateConstant(elapsed, boyfriend, gf, dadOpponent);

		daIntroCard.update(elapsed);
		
		//uiHUD.update();

		super.update(elapsed);

		if (isRaidMode)
		{
			//update the boss' health bar fill thingy
			raidBossHealthBar.percent = (raidBossHealth / raidBossMaxHealth) * 100;

			if (raidBossHealth < 0)
				raidBossHealth = 0;

			//update the raid boss health text
			raidBossHealthBarText.text = '${Std.string(raidBossHealth)} / ${Std.string(raidBossMaxHealth)}';

			//check to see if we need to clear the chatbox
			if (Init.trueSettings.get('Raid Chat') == true && chatBoxText.textField.numLines >= 17 && !chatBoxClearing)
			{
				#if debug
				trace('clearing chatbox!');
				#end
				chatBoxClearing = true;
				new FlxTimer().start(4, function(e:FlxTimer) //set up a timer to clear the chatbox
				{
					FlxTween.tween(chatBoxText, { alpha: 0 }, 1, {onComplete: function(tween:FlxTween) //fade out the chatbox
					{
						//after that's done, clean up the chatbox
						chatBoxText.text = '';
						chatBox.clear();
						chatBoxText.alpha = 1;
						chatBoxClearing = false;
					}});
				});

			}
		}

		//shader stuff lols!
		for (shader in animatedShaders)
		{
			shader.update(elapsed);
		}

		if (health > 2)
			health = 2;

		if (ovfHealth == true && health > 1)
			health = 1;

		// dialogue checks
		if (dialogueBox != null && dialogueBox.alive) {
			// wheee the shift closes the dialogue
			if (FlxG.keys.justPressed.SHIFT && !dialogueBox.unskippable)
			{
				dialogueBox.closeDialog();
			}

			// the change I made was just so that it would only take accept inputs
			if (controls.ACCEPT && dialogueBox.textStarted && !dialogueBox.unskippable)
			{

				if (SONG.song.toLowerCase() == "overflow")
				{
					if (dialogueBox.curPage == 1)
					{
						//time to check some shit lols
						dialogueBox.checkForSteam();
						dialogueBox.checkSteamGames();
						dialogueBox.cleanDialogue();
					}
				}

				FlxG.sound.play(Paths.sound('cancelMenu'));
				dialogueBox.curPage += 1;

				if (dialogueBox.curPage == dialogueBox.dialogueData.dialogue.length)
					dialogueBox.closeDialog()
				else
					dialogueBox.updateDialog();
			}
			//piracy check shit here, addin a lil keypress to dump the current json to the console, with some other misc info.
			if (FlxG.keys.justPressed.N)
			{
				trace(DialogueBox.unparsedJson);
				trace("dialog path:" + dialogPath);
				trace("username:" + FlxG.save.data.username);
				trace("streamer mode is:" + Init.trueSettings.get("Streamer Mode"));
			}

		}

		if (!inCutscene) {
			// pause the game if the game is allowed to pause and enter is pressed
			if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
			{
				// update drawing stuffs
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// open pause substate
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				updateRPC(true);
			}

			// make sure you're not cheating lol
			if (!isStoryMode /*||!isRaidMode*/)
			{
				// charting state (more on that later)
				if ((FlxG.keys.justPressed.SEVEN) && (!startingSong))
				{
					resetMusic();
					if (FlxG.keys.pressed.SHIFT)
						Main.switchState(this, new ChartingState());
					else
						Main.switchState(this, new OriginalChartingState());
				}

				if ((FlxG.keys.justPressed.EIGHT) && (!startingSong))
				{
					resetMusic();
					Main.switchState(this, new AnimationDebug(boyfriend.curCharacter));
				}

				if ((FlxG.keys.justPressed.SIX))
					boyfriendStrums.autoplay = !boyfriendStrums.autoplay;
			}

			///*
			if (startingSong)
			{
				if (startedCountdown)
				{
					Conductor.songPosition += elapsed * 1000;
					if (Conductor.songPosition >= 0)
						startSong();
				}
			}
			else
			{
				// Conductor.songPosition = FlxG.sound.music.time;
				Conductor.songPosition += elapsed * 1000;

				if (!paused)
				{
					songTime += FlxG.game.ticks - previousFrameTime;
					previousFrameTime = FlxG.game.ticks;

					// Interpolation type beat
					if (Conductor.lastSongPos != Conductor.songPosition)
					{
						songTime = (songTime + Conductor.songPosition) / 2;
						Conductor.lastSongPos = Conductor.songPosition;
						// Conductor.songPosition += FlxG.elapsed * 1000;
						// trace('MISSED FRAME');
					}
				}

				// Conductor.lastSongPos = FlxG.sound.music.time;
				// song shit for testing lols
			}

			// boyfriend.playAnim('singLEFT', true);
			// */

			if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				var curSection = Std.int(curStep / 16);
				if (curSection != lastSection) {
					// section reset stuff
					var lastMustHit:Bool = PlayState.SONG.notes[lastSection].mustHitSection;
					if (PlayState.SONG.notes[curSection].mustHitSection != lastMustHit) {
						camDisplaceX = 0;
						camDisplaceY = 0;
					}
					lastSection = Std.int(curStep / 16);
				}

				if (!cIsCentered)
				{
					if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection) //switch cam to dad
						{
							var char = dadOpponent;
		
							var getCenterX = char.getMidpoint().x + 100;
							var getCenterY = char.getMidpoint().y - 100;
		
							if (curStage == 'dbdos')
								getCenterY = char.getMidpoint().y + 50;
							if (curStage == 'spiritRaid' && char.curCharacter == 'senpai')
							{
								getCenterX = char.getMidpoint().x - 50;
								getCenterY = char.getMidpoint().y - 200;
							}
							if (curStage == 'nobodyRaid' && oppIsBig)
							{
								getCenterX = char.getMidpoint().x + 50;
								getCenterY = char.getMidpoint().y - 750;
							}
		
							focusedChar = dadOpponent.curCharacter;
		
							if (curStage != 'spiritRaid' && char.curCharacter != 'senpai')
							{
							camFollow.setPosition(getCenterX + camDisplaceX + char.characterData.camOffsetX,
								getCenterY + camDisplaceY + char.characterData.camOffsetY);
							}
							else
							{
								camFollow.setPosition(getCenterX + camDisplaceX + char.characterData.camOffsetX,
								getCenterY + camDisplaceY + char.characterData.camOffsetY);
							}


							if (SONG.song.toLowerCase() == 'dbdos' && hasZoomTweenedDad == false)
							{
								FlxTween.tween(camGame, {zoom: 1.3}, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.linear, type: ONESHOT, onComplete: function(tween:FlxTween)
									{
										defaultCamZoom = 1.3;
										hasZoomTweenedDad = true;
										hasZoomTweenedBf = false;
									}});
							}

							if (SONG.song.toLowerCase() == 'seg fault' && (hasZoomTweenedDad == false || hasZoomTweenedBf == false) && oppIsBig)
							{
								FlxTween.tween(camGame, {zoom: 1.3}, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.linear, type: ONESHOT, onComplete: function(tween:FlxTween)
									{
										defaultCamZoom = 0.6;
										if (hasZoomTweenedDad == false)
											hasZoomTweenedDad = true;
										else
											hasZoomTweenedBf = true;
									}});
							}
		
							if (char.curCharacter == 'mom')
								vocals.volume = 1;
						}
						else //switch cam to bf
						{
							var char = boyfriend;
		
							var getCenterX = char.getMidpoint().x - 100;
							var getCenterY = char.getMidpoint().y - 100;
							switch (curStage)
							{
								case 'limo':
									getCenterX = char.getMidpoint().x - 300;
								case 'mall':
									getCenterY = char.getMidpoint().y - 200;
								case 'school':
									getCenterX = char.getMidpoint().x - 200;
									getCenterY = char.getMidpoint().y - 200;
								case 'schoolEvil':
									getCenterX = char.getMidpoint().x - 200;
									getCenterY = char.getMidpoint().y - 200;
								case 'dbdos':
									getCenterX = char.getMidpoint().x - 300;
								case 'spiritRaid':
									getCenterX = char.getMidpoint().x - 200;
									getCenterY = char.getMidpoint().y - 200;
							}
		
							focusedChar = boyfriend.curCharacter;
		
							camFollow.setPosition(getCenterX + camDisplaceX - char.characterData.camOffsetX,
								getCenterY + camDisplaceY + char.characterData.camOffsetY);
		
							if (SONG.song.toLowerCase() == 'dbdos' && hasZoomTweenedBf == false)
							{
								FlxTween.tween(camGame, {zoom: 0.7}, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.linear, type: ONESHOT, onComplete: function(tween:FlxTween)
									{
										defaultCamZoom = 0.7;
										hasZoomTweenedBf = true;
										hasZoomTweenedDad = false;
									}});
							}

							if (SONG.song.toLowerCase() == 'seg fault' && hasZoomTweenedBf == false && oppIsBig)
							{
								FlxTween.tween(camGame, {zoom: 0.8}, (Conductor.stepCrochet / 1000) * 2, {ease: FlxEase.linear, type: ONESHOT, onComplete: function(tween:FlxTween)
									{
										defaultCamZoom = 0.9;
										hasZoomTweenedBf = true;
										hasZoomTweenedDad = false;
									}});
							}
						}
				}

				else
				{
					var oppChar = dadOpponent;
					var oppX;
					var oppY;
					var plrChar = boyfriend;
					var plrX;
					var plrY;
					var midPointX;
					var midPointY;

					//in hindsight, this probably shouldn't be called every 16 steps but whatever, i'll change it if it causes issues
					//let's start off with getting the correct cam focus points of each character

					//let's start with the opponent
					oppX = oppChar.getMidpoint().x + 100;
					oppY = oppChar.getMidpoint().y - 100;

					if (curStage == 'dbdos')
						oppY = oppChar.getMidpoint().y + 50;

					if (curStage == 'nobodyRaid' && oppIsBig)
					{
						oppX = oppChar.getMidpoint().x + 50;
						oppY = oppChar.getMidpoint().y - 750;
					}

					//now the player
					plrX = plrChar.getMidpoint().x - 100;
					plrY = plrChar.getMidpoint().y - 100;

					switch (curStage)
					{
						case 'limo':
							plrX = plrChar.getMidpoint().x - 300;
						case 'mall':
							plrY = plrChar.getMidpoint().y - 200;
						case 'school':
							plrX = plrChar.getMidpoint().x - 200;
							plrY = plrChar.getMidpoint().y - 200;
						case 'schoolEvil':
							plrX = plrChar.getMidpoint().x - 200;
							plrY = plrChar.getMidpoint().y - 200;
						case 'dbdos':
							plrX = plrChar.getMidpoint().x - 300;
						case 'spiritRaid':
							plrX = plrChar.getMidpoint().x - 200;
							plrY = plrChar.getMidpoint().y - 200;
					}

					//now let's get the midpoint between the two
					midPointX = (plrX + oppX) / 2;
					midPointY = (plrY + oppY) / 2;

					//now let's set the camera to that midpoint
					camFollow.setPosition(midPointX + camDisplaceX, midPointY + camDisplaceY);
				}
				
			}

			var lerpVal = (elapsed * 2.4) * cameraSpeed;
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

			var easeLerp = 0.95;
			// camera stuffs
			//let it be known that on this date, the 4th of december 2022, GDD realised that there was a camera zoom var already in the game.
			//and rather than spend 5 minutes to actually read the code, he spent 1 week making his own camera zoom system.
			//and then he spent another 2 weeks trying to fix it whilst refactoring the camera bump system.
			//GDD is a fucking idiot.
			if (camZoomed == false)
			{
				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom + forceZoom[0], FlxG.camera.zoom, easeLerp);
				for (hud in allUIs)
					hud.zoom = FlxMath.lerp(1 + forceZoom[1], hud.zoom, easeLerp);
			}
			

			// not even forcezoom anymore but still also angle cam shenanigans here
			FlxG.camera.angle = FlxMath.lerp(0 + forceZoom[2], FlxG.camera.angle, easeLerp);
			for (hud in allUIs)
				hud.angle = FlxMath.lerp(0 + forceZoom[3], hud.angle, easeLerp);

			if (health <= 0 && startedCountdown)
			{
				// startTimer.active = false;
				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				resetMusic();
				

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				// discord stuffs should go here
			}

			// spawn in the notes from the array
			if ((unspawnNotes[0] != null) && ((unspawnNotes[0].strumTime - Conductor.songPosition) < 3500))
			{
				var dunceNote:Note = unspawnNotes[0];
				// push note to its correct strumline
				strumLines.members[Math.floor((dunceNote.noteData + (dunceNote.mustPress ? 4 : 0)) / numberOfKeys)].push(dunceNote);
				unspawnNotes.splice(unspawnNotes.indexOf(dunceNote), 1);
			}

			noteCalls();
		}

	}

	function noteCalls()
	{
		// reset strums
		for (strumline in strumLines)
		{
			// handle strumline stuffs
			var i = 0;
			for (uiNote in strumline.receptors)
			{
				if (strumline.autoplay)
					strumCallsAuto(uiNote);
			}

			if (strumline.splashNotes != null)
				for (i in 0...strumline.splashNotes.length)
				{
					strumline.splashNotes.members[i].x = strumline.receptors.members[i].x - 48;
					strumline.splashNotes.members[i].y = strumline.receptors.members[i].y + (Note.swagWidth / 6) - 56;
				}
		}

		// if the song is generated
		if (generatedMusic && startedCountdown)
		{
			for (strumline in strumLines)
			{
				// set the notes x and y
				var downscrollMultiplier = 1;
				if (Init.trueSettings.get('Downscroll'))
					downscrollMultiplier = -1;
				
				strumline.allNotes.forEachAlive(function(daNote:Note)
				{
					var roundedSpeed = FlxMath.roundDecimal(daNote.noteSpeed, 2);
					var receptorPosY:Float = strumline.receptors.members[Math.floor(daNote.noteData)].y + Note.swagWidth / 6;
					var psuedoY:Float = (downscrollMultiplier * -((Conductor.songPosition - daNote.strumTime) * (0.45 * roundedSpeed)));
					var psuedoX = 25 + daNote.noteVisualOffset;

					daNote.y = receptorPosY
						+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY)
						+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX);
					// painful math equation
					daNote.x = strumline.receptors.members[Math.floor(daNote.noteData)].x
						+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX)
						+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY);

					// also set note rotation
					daNote.angle = -daNote.noteDirection;

					// shitty note hack I hate it so much
					var center:Float = receptorPosY + Note.swagWidth / 2;
					if (daNote.isSustainNote) {
						daNote.y -= ((daNote.height / 2) * downscrollMultiplier);
						if ((daNote.animation.curAnim.name.endsWith('holdend')) && (daNote.prevNote != null)) {
							daNote.y -= ((daNote.prevNote.height / 2) * downscrollMultiplier);
							if (Init.trueSettings.get('Downscroll')) {
								daNote.y += (daNote.height * 2);
								if (daNote.endHoldOffset == Math.NEGATIVE_INFINITY) {
									// set the end hold offset yeah I hate that I fix this like this
									daNote.endHoldOffset = (daNote.prevNote.y - (daNote.y + daNote.height));
									//trace(daNote.endHoldOffset);
								}
								else
									daNote.y += daNote.endHoldOffset;
							} else // this system is funny like that
								daNote.y += ((daNote.height / 2) * downscrollMultiplier);
						}
						
						if (Init.trueSettings.get('Downscroll'))
						{
							daNote.flipY = true;
							if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit) 
								&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
								&& (strumline.autoplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;
								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit)
								&& daNote.y + daNote.offset.y * daNote.scale.y <= center
								&& (strumline.autoplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;
								daNote.clipRect = swagRect;
							}
						}
					}
					// hell breaks loose here, we're using nested scripts!
					mainControls(daNote, strumline.character, strumline, strumline.autoplay);

					// check where the note is and make sure it is either active or inactive
					if (daNote.y > FlxG.height) {
						daNote.active = false;
						daNote.visible = false;
					} else {
						daNote.visible = true;
						daNote.active = true;
					}

					if (!daNote.tooLate && daNote.strumTime < Conductor.songPosition - (Timings.msThreshold) && !daNote.wasGoodHit)
					{
						if ((!daNote.tooLate) && (daNote.mustPress)) {
							if (!daNote.isSustainNote)
							{
								daNote.tooLate = true;
								for (note in daNote.childrenNotes)
									note.tooLate = true;
								
								vocals.volume = 0; //turn off bf's vocals here
								missNoteCheck((Init.trueSettings.get('Ghost Tapping')) ? true : false, daNote.noteData, boyfriend, true);
								// ambiguous name
								Timings.updateAccuracy(0);
							}
							else if (daNote.isSustainNote)
							{
								if (daNote.parentNote != null)
								{
									var parentNote = daNote.parentNote;
									if (!parentNote.tooLate)
									{
										var breakFromLate:Bool = false;
										for (note in parentNote.childrenNotes)
										{
											trace('hold amount ${parentNote.childrenNotes.length}, note is late?' + note.tooLate + ', ' + breakFromLate);
											if (note.tooLate && !note.wasGoodHit)
												breakFromLate = true;
												
										}
										if (!breakFromLate)
										{
											missNoteCheck((Init.trueSettings.get('Ghost Tapping')) ? true : false, daNote.noteData, boyfriend, true);
											vocals.volume = 0; //I THINK YOU FORGOT THIS COUGH COUGH
											for (note in parentNote.childrenNotes)
												note.tooLate = true;
										}
										//
									}
								}
							}
						}
					
					}

					// if the note is off screen (above)
					if ((((!Init.trueSettings.get('Downscroll')) && (daNote.y < -daNote.height))
					|| ((Init.trueSettings.get('Downscroll')) && (daNote.y > (FlxG.height + daNote.height))))
					&& (daNote.tooLate || daNote.wasGoodHit))
						destroyNote(strumline, daNote);
				});


				// unoptimised asf camera control based on strums
				strumCameraRoll(strumline.receptors, (strumline == boyfriendStrums));
			}
			
		}
		
		// reset bf's animation
		var holdControls:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		if ((boyfriend != null && boyfriend.animation != null)
			&& (boyfriend.holdTimer > Conductor.stepCrochet * (4 / 1000)
			&& (!holdControls.contains(true) || boyfriendStrums.autoplay)))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();
		}
	}

	function destroyNote(strumline:Strumline, daNote:Note)
	{
		daNote.active = false;
		daNote.exists = false;

		var chosenGroup = (daNote.isSustainNote ? strumline.holdsGroup : strumline.notesGroup);
		// note damage here I guess
		daNote.kill();
		if (strumline.allNotes.members.contains(daNote))
			strumline.allNotes.remove(daNote, true);
		if (chosenGroup.members.contains(daNote))
			chosenGroup.remove(daNote, true);
		daNote.destroy();
	}


	function goodNoteHit(coolNote:Note, character:Character, characterStrums:Strumline, ?canDisplayJudgement:Bool = true)
	{
		if (!coolNote.wasGoodHit) {
			coolNote.wasGoodHit = true;
			//vocals.volume = 1; //no thanks, this triggers when the opponent hits a note.

			//add in a check for if the character is the player
			//super bad way of doing this but otherwise it would be a lot more work
			if (character.curCharacter == SONG.player1 || character.curCharacter == freeplayChar) 
			{
				vocals.volume = 1;
			}

			if (character.curCharacter == 'spirit' && SONG.song.toLowerCase() == 'broken-heart-corrosion')
				health -= 0.02;

			characterPlayAnimation(coolNote, character);
			if (characterStrums.receptors.members[coolNote.noteData] != null)
				characterStrums.receptors.members[coolNote.noteData].playAnim('confirm', true);

			// special thanks to sam, they gave me the original system which kinda inspired my idea for this new one
			if (canDisplayJudgement) {
				// get the note ms timing
				var noteDiff:Float = Math.abs(coolNote.strumTime - Conductor.songPosition);
				// get the timing
				if (coolNote.strumTime < Conductor.songPosition)
					ratingTiming = "late";
				else
					ratingTiming = "early";

				// loop through all avaliable judgements
				var foundRating:String = 'miss';
				var lowestThreshold:Float = Math.POSITIVE_INFINITY;
				for (myRating in Timings.judgementsMap.keys())
				{
					var myThreshold:Float = Timings.judgementsMap.get(myRating)[1];
					if (noteDiff <= myThreshold && (myThreshold < lowestThreshold))
					{
						foundRating = myRating;
						lowestThreshold = myThreshold;
					}
				}

				if (!coolNote.isSustainNote) {
					increaseCombo(foundRating, coolNote.noteData, character);
					popUpScore(foundRating, ratingTiming, characterStrums, coolNote);
					if (coolNote.childrenNotes.length > 0)
						Timings.notesHit++;
					if (SONG.song.toLowerCase() != 'carpenter')
						healthCall(Timings.judgementsMap.get(foundRating)[3]);
				} else if (coolNote.isSustainNote) {
					// call updated accuracy stuffs
					if (coolNote.parentNote != null) {
						Timings.updateAccuracy(100, true, coolNote.parentNote.childrenNotes.length);
						if (SONG.song.toLowerCase() != 'carpenter')
							healthCall(100 / coolNote.parentNote.childrenNotes.length);
					}
				}
			}

			if (!coolNote.isSustainNote)
				destroyNote(characterStrums, coolNote);
			//
		}
	}

	function missNoteCheck(?includeAnimation:Bool = false, direction:Int = 0, character:Character, popMiss:Bool = false, lockMiss:Bool = false)
	{
		if (includeAnimation)
		{
			var stringDirection:String = UIStaticArrow.getArrowFromNumber(direction);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			character.playAnim('sing' + stringDirection.toUpperCase() + 'miss', lockMiss);
		}
		decreaseCombo(popMiss);

		//
	}

	function characterPlayAnimation(coolNote:Note, character:Character)
	{
		// alright so we determine which animation needs to play
		// get alt strings and stuffs
		var stringArrow:String = '';
		var altString:String = '';

		var baseString = 'sing' + UIStaticArrow.getArrowFromNumber(coolNote.noteData).toUpperCase();

		// I tried doing xor and it didnt work lollll
		if (coolNote.noteAlt > 0)
			altString = '-alt';
		if (((SONG.notes[Math.floor(curStep / 16)] != null) && (SONG.notes[Math.floor(curStep / 16)].altAnim))
			&& (character.animOffsets.exists(baseString + '-alt')))
		{
			if (altString != '-alt')
				altString = '-alt';
			else
				altString = '';
		}

		stringArrow = baseString + altString;
		// if (coolNote.foreverMods.get('string')[0] != "")
		//	stringArrow = coolNote.noteString;

		character.playAnim(stringArrow, true);
		character.holdTimer = 0;

		if (SONG.song.toLowerCase() == 'overflow')
		{
			uiHUD.charAnims(stringArrow, character);
		}
	}

	private function strumCallsAuto(cStrum:UIStaticArrow, ?callType:Int = 1, ?daNote:Note):Void
	{
		switch (callType)
		{
			case 1:
				// end the animation if the calltype is 1 and it is done
				if ((cStrum.animation.finished) && (cStrum.canFinishAnimation))
					cStrum.playAnim('static');
			default:
				// check if it is the correct strum
				if (daNote.noteData == cStrum.ID)
				{
					// if (cStrum.animation.curAnim.name != 'confirm')
					cStrum.playAnim('confirm'); // play the correct strum's confirmation animation (haha rhymes)

					// stuff for sustain notes
					if ((daNote.isSustainNote) && (!daNote.animation.curAnim.name.endsWith('holdend')))
						cStrum.canFinishAnimation = false; // basically, make it so the animation can't be finished if there's a sustain note below
					else
						cStrum.canFinishAnimation = true;
				}
		}
	}

	private function mainControls(daNote:Note, char:Character, strumline:Strumline, autoplay:Bool):Void
	{
		var notesPressedAutoplay = [];

		// here I'll set up the autoplay functions
		if (autoplay)
		{
			// check if the note was a good hit
			if (daNote.strumTime <= Conductor.songPosition)
			{
				// use a switch thing cus it feels right idk lol
				// make sure the strum is played for the autoplay stuffs
				/*
					charStrum.forEach(function(cStrum:UIStaticArrow)
					{
						strumCallsAuto(cStrum, 0, daNote);
					});
				 */

				// kill the note, then remove it from the array
				var canDisplayJudgement = false;
				if (strumline.displayJudgements)
				{
					canDisplayJudgement = true;
					for (noteDouble in notesPressedAutoplay)
					{
						if (noteDouble.noteData == daNote.noteData)
						{
							// if (Math.abs(noteDouble.strumTime - daNote.strumTime) < 10)
							canDisplayJudgement = false;
							// removing the fucking check apparently fixes it
							// god damn it that stupid glitch with the double judgements is annoying
						}
						//
					}
					notesPressedAutoplay.push(daNote);
				}
				goodNoteHit(daNote, char, strumline, canDisplayJudgement);
			}
			//
		} 

		var holdControls:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		if (!autoplay) {
			// check if anything is held
			if (holdControls.contains(true))
			{
				// check notes that are alive
				strumline.allNotes.forEachAlive(function(coolNote:Note)
				{
					if ((coolNote.parentNote != null && coolNote.parentNote.wasGoodHit)
					&& coolNote.canBeHit && coolNote.mustPress
					&& !coolNote.tooLate && coolNote.isSustainNote
					&& holdControls[coolNote.noteData])
						goodNoteHit(coolNote, char, strumline);
				});
			}
		}
	}

	private function strumCameraRoll(cStrum:FlxTypedGroup<UIStaticArrow>, mustHit:Bool)
	{
		if (!Init.trueSettings.get('No Camera Note Movement'))
		{
			var camDisplaceExtend:Float = 15;
			if (PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				if ((PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && mustHit)
					|| (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && !mustHit))
				{
					camDisplaceX = 0;
					if (cStrum.members[0].animation.curAnim.name == 'confirm')
						camDisplaceX -= camDisplaceExtend;
					if (cStrum.members[3].animation.curAnim.name == 'confirm')
						camDisplaceX += camDisplaceExtend;
					
					camDisplaceY = 0;
					if (cStrum.members[1].animation.curAnim.name == 'confirm')
						camDisplaceY += camDisplaceExtend;
					if (cStrum.members[2].animation.curAnim.name == 'confirm')
						camDisplaceY -= camDisplaceExtend;

				}
			}
		}
		//
	}

	override public function onFocus():Void
	{
		if (!paused)
			updateRPC(false);
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		updateRPC(true);
		super.onFocusLost();
	}

	public static function updateRPC(pausedRPC:Bool)
	{
		#if !html5
		var displayRPC:String = (pausedRPC) ? detailsPausedText : songDetails;

		if (health > 0)
		{
			if (Conductor.songPosition > 0 && !pausedRPC)
				Discord.changePresence(displayRPC, detailsSub, iconRPC, true, songLength - Conductor.songPosition);
			else
				Discord.changePresence(displayRPC, detailsSub, iconRPC);
		}
		#end
	}

	var animationsPlay:Array<Note> = [];

	private var ratingTiming:String = "";

	function popUpScore(baseRating:String, timing:String, strumline:Strumline, coolNote:Note)
	{
		// set up the rating
		var score:Int = 50;

		// notesplashes
		if (baseRating == "sick")
			// create the note splash if you hit a sick
			createSplash(coolNote, strumline);
		else
 			// if it isn't a sick, and you had a sick combo, then it becomes not sick :(
			if (allSicks)
			{
				allSicks = false;
				if (isRaidMode && Init.trueSettings.get('Raid Chat') == true)
					fireChatboxMessage('fcLoss');
			}

		displayRating(baseRating, timing);
		Timings.updateAccuracy(Timings.judgementsMap.get(baseRating)[3]);
		score = Std.int(Timings.judgementsMap.get(baseRating)[2]);

		songScore += score;
		if (isRaidMode && raidBossHealth > 0)
		{
			raidBossHealth -= score;
			raidBossHealthBarText.text = '${Std.string(raidBossHealth)} / ${Std.string(raidBossMaxHealth)}';
		}		

		popUpCombo();
	}

	public function createSplash(coolNote:Note, strumline:Strumline)
	{
		// play animation in existing notesplashes
		var noteSplashRandom:String = (Std.string((FlxG.random.int(0, 1) + 1)));
		if (strumline.splashNotes != null)
			strumline.splashNotes.members[coolNote.noteData].playAnim('anim' + noteSplashRandom, true);
	}

	private var createdColor = FlxColor.fromRGB(204, 66, 66);

	function popUpCombo(?cache:Bool = false)
	{
		var comboString:String = Std.string(combo);
		var negative = false;
		if ((comboString.startsWith('-')) || (combo == 0))
			negative = true;
		var stringArray:Array<String> = comboString.split("");
		// deletes all combo sprites prior to initalizing new ones
		if (lastCombo != null)
		{
			while (lastCombo.length > 0)
			{
				lastCombo[0].kill();
				lastCombo.remove(lastCombo[0]);
			}
		}

		for (scoreInt in 0...stringArray.length)
		{
			// numScore.loadGraphic(Paths.image('UI/' + pixelModifier + 'num' + stringArray[scoreInt]));
			var numScore = ForeverAssets.generateCombo('combo', stringArray[scoreInt], (!negative ? allSicks : false), assetModifier, changeableSkin, 'UI',
				negative, createdColor, scoreInt);
			add(numScore);
			// hardcoded lmao
			if (!Init.trueSettings.get('Simply Judgements'))
			{
				add(numScore);
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.kill();
					},
					startDelay: Conductor.crochet * 0.002
				});
			}
			else
			{
				add(numScore);
				// centers combo
				numScore.y += 10;
				numScore.x -= 95;
				numScore.x -= ((comboString.length - 1) * 22);
				lastCombo.push(numScore);
				FlxTween.tween(numScore, {y: numScore.y + 20}, 0.1, {type: FlxTweenType.BACKWARD, ease: FlxEase.circOut});
			}
			// hardcoded lmao
			if (Init.trueSettings.get('Fixed Judgements'))
			{
				if (!cache)
					numScore.cameras = [camHUD];
				numScore.y += 50;
			}
				numScore.x += 100;
		}
	}

	function decreaseCombo(?popMiss:Bool = false)
	{
		// painful if statement
		if (((combo > 5) || (combo < 0)) && (gf.animOffsets.exists('sad')))
			gf.playAnim('sad');

		if (combo > 0)
			combo = 0; // bitch lmao
		else
			combo--;

		// misses
		songScore -= 10;
		misses++;

		if (isRaidMode && Init.trueSettings.get('Raid Chat') == true)
		{
			fireChatboxMessage('comboBreak');
		}

		// display negative combo
		if (popMiss)
		{
			// doesnt matter miss ratings dont have timings
			displayRating("miss", 'late');
			healthCall(Timings.judgementsMap.get("miss")[3]);
		}
		popUpCombo();

		// gotta do it manually here lol
		Timings.updateFCDisplay();
	}

	function increaseCombo(?baseRating:String, ?direction = 0, ?character:Character)
	{
		// trolled this can actually decrease your combo if you get a bad/shit/miss
		if (baseRating != null)
		{
			if (Timings.judgementsMap.get(baseRating)[3] > 0)
			{
				if (combo < 0)
					combo = 0;
				combo += 1;
			}
			else
				missNoteCheck(true, direction, character, false, true);
		}
	}

	public function displayRating(daRating:String, timing:String, ?cache:Bool = false)
	{
		/* so you might be asking
			"oh but if the rating isn't sick why not just reset it"
			because miss judgements can pop, and they dont mess with your sick combo
		 */
		var rating = ForeverAssets.generateRating('$daRating', (daRating == 'sick' ? allSicks : false), timing, assetModifier, changeableSkin, 'UI');
		add(rating);

		if (!Init.trueSettings.get('Simply Judgements'))
		{
			add(rating);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					rating.kill();
				},
				startDelay: Conductor.crochet * 0.00125
			});
		}
		else
		{
			if (lastRating != null) {
				lastRating.kill();
			}
			add(rating);
			lastRating = rating;
			FlxTween.tween(rating, {y: rating.y + 20}, 0.2, {type: FlxTweenType.BACKWARD, ease: FlxEase.circOut});
			FlxTween.tween(rating, {"scale.x": 0, "scale.y": 0}, 0.1, {
				onComplete: function(tween:FlxTween)
				{
					rating.kill();
				},
				startDelay: Conductor.crochet * 0.00125
			});
		}
		// */

		if (!cache) {
			if (Init.trueSettings.get('Fixed Judgements')) {
				// bound to camera
				rating.cameras = [camHUD];
				rating.screenCenter();
			}
			
			// return the actual rating to the array of judgements
			Timings.gottenJudgements.set(daRating, Timings.gottenJudgements.get(daRating) + 1);

			// set new smallest rating
			if (Timings.smallestRating != daRating) {
				if (Timings.judgementsMap.get(Timings.smallestRating)[0] < Timings.judgementsMap.get(daRating)[0])
					Timings.smallestRating = daRating;
			}
		}
	}

	function healthCall(?ratingMultiplier:Float = 0)
	{
		// health += 0.012;
		var healthBase:Float = 0.06;
		health += (healthBase * (ratingMultiplier / 100));
	}

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			songMusic.play();
			songMusic.onComplete = endSong;
			vocals.play(); //bf vocals need to be here too
			vocalsopp.play();

			resyncVocals();

			if (hasUniqueIntroCard == false)
				daIntroCard.tweenAll();

			#if !html5
			// Song duration in a float, useful for the time left feature
			songLength = songMusic.length;

			// Updating Discord Rich Presence (with Time Left)
			updateRPC(false);
			#end
		}
	}

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		songDetails = CoolUtil.dashToSpace(SONG.song) + ' - ' + CoolUtil.difficultyFromNumber(storyDifficulty);

		// String for when the game is paused
		detailsPausedText = "Paused - " + songDetails;

		// set details for song stuffs
		detailsSub = "";

		// Updating Discord Rich Presence.
		updateRPC(false);

		curSong = songData.song;
		songMusic = new FlxSound().loadEmbedded(Paths.inst(SONG.song), false, true);

		//check to see if the song has split vocals
		hasSplitVocals = Paths.doSplitVocalsExist(SONG.song);

		if (SONG.needsVoices && hasSplitVocals)
		{
			trace("Loading split vocals");
			if (!isStoryMode && !freeplayChar.startsWith('bf'))
				vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song, freeplayChar), false, true); //bf vocals here
			else
				vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song), false, true); //bf vocals here
			vocalsopp = new FlxSound().loadEmbedded(Paths.voicesOpp(SONG.song), false, true); //opp vocals here
		}

		else if (SONG.needsVoices && !hasSplitVocals)
		{
			trace("Loading normal vocals");
			vocals = new FlxSound().loadEmbedded(Paths.voicesNormal(SONG.song), false, true); //load up them vocals anyways
			vocalsopp = new FlxSound();
		}

		else
		{
			trace("loading no vocals");
			vocals = new FlxSound();
			vocalsopp = new FlxSound();
		}
		FlxG.sound.list.add(songMusic);
		FlxG.sound.list.add(vocals); //bf vocals here
		FlxG.sound.list.add(vocalsopp); //opp vocals here

		// generate the chart
		unspawnNotes = ChartLoader.generateChartType(SONG, determinedChartType);
		// sometime my brain farts dont ask me why these functions were separated before

		// sort through them
		unspawnNotes.sort(sortByShit);
		// give the game the heads up to be able to start
		generatedMusic = true;

		Timings.accuracyMaxCalculation(unspawnNotes);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function resyncVocals():Void
	{
		//trace('resyncing vocal time ${vocals.time}'); //commenting these out so i can actually see my traces in the code
		songMusic.pause();
		vocals.pause();
		vocalsopp.pause();
		Conductor.songPosition = songMusic.time;
		vocals.time = Conductor.songPosition; //bf vocals here
		vocalsopp.time = Conductor.songPosition; //opp vocals here
		songMusic.play();
		vocals.play(); //bf vocals here
		vocalsopp.play(); //opp vocals here
		//trace('new vocal time ${Conductor.songPosition}'); //like jesus fuck how often does this happen
	}

	override function stepHit()
	{
		super.stepHit();
		///* okay so this is triggering at the end of the song, probably because either the vocals or the music stops but the other doesn't.
		if (songMusic.time >= Conductor.songPosition + 20 && songMusic.time != songMusic.length || songMusic.time <= Conductor.songPosition - 20 && songMusic.time != songMusic.length)
		{
			//trace('VOCAL RESYNC CALLED');
			//trace('songMusic.time: ${songMusic.time}');
			//trace('Conductor.songPosition: ${Conductor.songPosition}');
			//trace('songMusic.length: ${songMusic.length}');
			resyncVocals();
		}
		//*/

		//gotta get my own fuckin per-step stage updater going because SOMEONE decided it'd be fine to update them either every frame or every beat.
		//big day for people who care about stage changes being accurate to the actual fucking song
		stageBuild.stageUpdateStep(curStep, boyfriend, gf, dadOpponent);

		//blah blah seethe mald cope LEAK EM YOSHUBS
		uiHUD.stepUpdate(curStep);

		daIntroCard.curStep = curStep;
		

		//i figured this'd be the best spot for all the mid-song shit lmao
		if (SONG.song.toLowerCase() == "piracy-check")
		//rundown real quick for what does what + other useful info
		//camZoomed controls whether the cam bumps or not, mostly useful for the intro of the song.
		//zoomInterval controls how often the cam bumps, cheatsheet is 1 = every beat, 2 = every 2 beats, etc.

		//future me here, this fucking hurts to look at. will be moved to CamBumpHandler soon-ish.
		//future future me here, all refactored to work with CamBumpHandler, looks much nicer.
		{
			switch (curStep)
			{
				case 1: //start tweening the alpha of pcScoreToBeat
					cHandlerBumpFreq = 999999;
					trace("tweening alpha!!");
					FlxTween.tween(pcScoreToBeatText, {alpha: 1}, (Conductor.crochet / 1000) * 8, {ease: FlxEase.linear, type: ONESHOT});
					


				case 121: //good text
					pcScoreToBeatText.alpha = 0;
					pcGoodText.alpha = 1;

				case 122: //fucking text
					pcGoodText.alpha = 0;
					pcFuckingText.alpha = 1;
				case 124: //luck text
					pcFuckingText.alpha = 0;
					pcLuckText.alpha = 1;
				case 126: //zoom the text
					pcLuckText.size = 256;
					camGame.zoom = 2;

				case 128: //remove text
					cHandlerBumpFreq = 1;
					cHandlerBumpIntensity = 0.15;
					cHandlerBumpIntensityHud = 0.1;
					pcScoreToBeatText.destroy();
					pcGoodText.destroy();
					pcFuckingText.destroy();
					pcLuckText.destroy();		
					daIntroCard.tweenAll(); //space is tight here, can't have all the elements tween in one by one :(

				case 159:
					daIntroCard.fadeAll();
				
				case 512:
					trace("BREAKDOWN HERE????");
					cHandlerBumpFreq = 999999;
					camZoomed = true;
					FlxG.camera.zoom += 0.03;
				
				case 526:
					trace("another hit???");
					FlxG.camera.zoom += 0.03;

				case 528:
					trace("you know the drill");
					FlxG.camera.zoom += 0.03;
				
				case 542:
					camZoomed = false;
				
				case 544:
					trace("BOYFRIEND BREAKDOWN HERE????");
					camZoomed = true;
					FlxG.camera.zoom += 0.03;

				case 558:
					trace("another hit???");
					FlxG.camera.zoom += 0.03;

				case 560:
					trace("you know the drill");
					FlxG.camera.zoom += 0.03;
				case 574:
					trace("let's reel this shit back in (hopefully)");
					camZoomed = false;
				case 576: //buildup section, include black rectangle which slowly brightens via a tween, also tween a zoom out from nobody very slowly
					cHandlerBumpFreq = 2;
					bigZooms = false;
					camZoomed = true;
					literallyJustAFuckingBlackRectangle = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/base/black'));
					literallyJustAFuckingBlackRectangle.alpha = 1;
					literallyJustAFuckingBlackRectangle.antialiasing = true;
					literallyJustAFuckingBlackRectangle.scrollFactor.set(1, 1);
					literallyJustAFuckingBlackRectangle.screenCenter();
					add(literallyJustAFuckingBlackRectangle);
					FlxTween.tween(literallyJustAFuckingBlackRectangle, {alpha: 0}, (Conductor.crochet / 1000) * 32, {ease: FlxEase.linear, type: ONESHOT});
					camGame.zoom = 2;
					FlxTween.tween(camGame, {zoom: 1}, (Conductor.crochet / 1000) * 32, {ease: FlxEase.linear, type: ONESHOT});
					FlxTween.tween(camHUD, {zoom: 1}, (Conductor.crochet / 1000) * 32, {ease: FlxEase.linear, type: ONESHOT});
				
				case 704: //boyfriend buildup, let's get some HYPE SHIT GOIN
					camZoomed = false;
					cHandlerBumpFreq = 1;

				case 768: //riiiight before the chorus where shit REALLY heats up
					bigZooms = true;
				case 832:
					camZoomed = false;
					zoomInterval = 1;


				case 960: //nobody break section, zoom camera in
					camZoomed = true;
					oldZoom = camGame.zoom;
					camGame.zoom = 1.5;
					bigZooms = false;

				case 1024: //reset camera
					camGame.zoom = oldZoom;

				case 1152: //slowly zoom the camera in on boyfriend via a tween
					camZoomed = true;
					trace("tweening zoom!!");
					FlxTween.tween(camGame, {zoom: 2}, (Conductor.crochet / 1000) * 8, {ease: FlxEase.linear, type: ONESHOT});


				case 1216: //reset camera
					camZoomed = false;
					bigZooms = true;
			}
		}

		//oooh baby it's OVERFLOW TIME
		if(SONG.song.toLowerCase() == "overflow")
		//stage related fuckery can be found in stageUpdateStep in Stage.hx because shit's fucking
		{
			switch(curStep)
			{
				case 128:
					daIntroCard.tweenBar();

				case 134:
					daIntroCard.tweenArrow();

				case 138:
					daIntroCard.tweenTopText();

				case 142:
					daIntroCard.tweenBottomText();

				case 144:
					daIntroCard.tweenSongName();

				case 150:
					daIntroCard.tweenOppIcon();

				case 154:
					daIntroCard.tweenPlayerIcon();

				case 158:
					daIntroCard.tweenSongDiff();

				case 160:
					daIntroCard.tweenVsText();

				case 166:
					daIntroCard.tweenOppName();

				case 170:
					daIntroCard.tweenPlayerName();

				case 182:
					daIntroCard.fadeAll();

				case 512: //vocal switch dialogue box
					//dialogue box here
					if(boyfriend.curCharacter.startsWith("bf"))
					{
						midSongDialogue();
						//call a timer that calls dialogueBox.closeDialog() after 5 seconds
						new FlxTimer().start((Conductor.crochet / 1000) * 8, function(e:FlxTimer)
						{
							dialogueBox.closeDialogInstant();
						});
					}
					//also have nobody loop the attack animation until the dialogue box is closed
					//get that scroll speed goin CRAZY

				case 552:
					//have nobody wind up wit da pre-attack animation
					dadOpponent.playAnim("preAttack");

				case 560: //lil cam shake and flash to add to the effect of the stage wall being removed
					trace("cam fuckery lol!!!");
					camGame.shake(0.05, Conductor.crochet / 1000);
					camGame.flash(0xffffffff, (Conductor.crochet / 1000) / 2);
					dadOpponent.playAnim("attack");

				case 576: //attempt to figure out if it's possible to speed up notespeed or not lol
					//try modifying the notespeed in unspawnNotes and pray to god it works??
					/*for (note in unspawnNotes)
					{
						note.noteSpeed = 3;
					} */

				case 964: //windows transition start, turn off hud
					camHUD.alpha = 0;

				case 972: //hide characters, rest is handled in Stage.hx
					boyfriend.alpha = 0;
					dadOpponent.alpha = 0;

				case 1008: //unhide characters
					boyfriend.alpha = 1;
					dadOpponent.alpha = 1;
				
				
				case 1016: //windows transition end, turn on hud
					camHUD.alpha = 1;
					//get BayersDithering going
					changeShader("BayersDithering");

				case 1328: //chorus 2 buildup, tween alpha of characters to 0, tween health to 1
					FlxTween.tween(boyfriend, {alpha: 0}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.linear, type: ONESHOT});
					FlxTween.tween(dadOpponent, {alpha: 0}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.linear, type: ONESHOT});
					FlxTween.num(health, 1, (Conductor.crochet / 1000) * 4, {ease: FlxEase.backOut}, function(val:Float)
						{
							health = val;
						});
					//TODO: FIND OUT WHY FLIXEL IS THROWING A HISSY FIT ABOUT THIS
					//SERIOUSLY, YOU ASK FOR A FLOAT SO I GIVE YOU A FUCKING FLOAT AND YOU'RE LIKE "NOPE, I WANT A TWEEN NOW, FUCK YOU"
					//BUT WHEN I GIVE YOU A TWEEN YOU'RE LIKE "NOPE, I WANT A FLOAT NOW, FUCK YOU"
					//MAKE UP YOUR FUCKING MIND I SWEAR TO GOD
					//update: i was using onUpdate as opposed to tweenFunction. i am retarded.

				case 1344: //chorus 2 start, turn on health limit. fancy healthbar shenanigans are handled in ClassHUD.hx
					ovfHealth = true;

				case 1644: //section 2 end, tween alpha of characters back to 1 and turn ovfHealth off
					FlxTween.tween(boyfriend, {alpha: 1}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.linear, type: ONESHOT});
					FlxTween.tween(dadOpponent, {alpha: 1}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.linear, type: ONESHOT});
					ovfHealth = false;
				
				case 1856:
					//switch shader to Dawnbringer
					changeShader("Dawnbringer");
				case 2304:
					//switch shader to Glitch
					changeShader("Glitch");
					//also throw in a funny healthbar slam or whatever
					FlxTween.num(health, 0.5, (Conductor.crochet / 1000) * 2, {ease: FlxEase.backOut}, function(val:Float)
						{
							health = val;
						});
					//and a screenshake too because fuck it why not
					camGame.shake(0.05, (Conductor.crochet / 1000) * 2);
					camHUD.shake(0.05, (Conductor.crochet / 1000) * 2);
			}
		}

		if(SONG.song.toLowerCase() == 'dbdos')
		{
			switch(curStep)
			{
				case 1:
					daIntroCard.tweenBar();
					if(isRaidMode)
						damageBoss();

				case 16:
					daIntroCard.tweenArrow();

				case 32:
					daIntroCard.tweenTopText();

				case 48:
					daIntroCard.tweenBottomText();

				case 64:
					daIntroCard.tweenOppIcon();
					daIntroCard.tweenOppName();

				case 80:
					daIntroCard.tweenPlayerIcon();
					daIntroCard.tweenPlayerName();

				case 96:
					daIntroCard.tweenSongName();
					daIntroCard.tweenVsText();

				case 112:
					daIntroCard.tweenSongDiff();

				case 124:
					daIntroCard.fadeAll();
					if(isRaidMode)
						damageBoss();

				case 704:
					cHandlerBumpFreq = 1;
					if(isRaidMode)
						damageBoss();

				case 832:
					cHandlerBumpFreq = 2;

				case 1072:
					cHandlerBumpFreq = 1;
				
				case 1081:
					cHandlerBumpFreq = 4;
					if(isRaidMode)
						damageBoss();

				case 1408:
					cHandlerBumpFreq = 1;

				case 1536:
					cHandlerBumpFreq = 4;

				case 1664:
					cHandlerBumpFreq = 2;

				case 1680:
					cHandlerBumpFreq = 1;

				case 1696:
					cHandlerBumpFreq = 2;

				case 1712:
					cHandlerBumpFreq = 1;

				case 1728:
					cHandlerBumpFreq = 4;

				case 1792:
					cHandlerBumpFreq = 1;

				case 1840:
					cHandlerBumpFreq = 9999999; //no more bumping
			}
		}

		if(SONG.song.toLowerCase() == "moonrise")
		{
			switch(curStep)
			{
				case 1:
					daIntroCard.tweenBar();

				case 6:
					daIntroCard.tweenArrow();

				case 16:
					daIntroCard.tweenOppName();
				
				case 19:
					daIntroCard.tweenVsText();
				
				case 22:
					daIntroCard.tweenPlayerName();

				case 32:
					daIntroCard.tweenOppIcon();
				
				case 38:
					daIntroCard.tweenPlayerIcon();
				
				case 44:
					daIntroCard.tweenTopText();

				case 46:
					daIntroCard.tweenBottomText();

				case 51:
					daIntroCard.tweenSongName();

				case 53:
					daIntroCard.tweenSongDiff();

				case 64:
					daIntroCard.fadeAll();
			}
		}

		if(SONG.song.toLowerCase() == "dungeon-drama")
		{
			switch(curStep)
			{
				case 96:
					daIntroCard.tweenBar();
				
				case 97:
					daIntroCard.tweenArrow();

				case 99:
					daIntroCard.tweenTopText();
					daIntroCard.tweenBottomText();
				
				case 106:
					daIntroCard.tweenOppName();
					daIntroCard.tweenOppIcon();
				
				case 108:
					daIntroCard.tweenVsText();

				case 110:
					daIntroCard.tweenPlayerName();
					daIntroCard.tweenPlayerIcon();

				case 112:
					daIntroCard.tweenSongName();
					daIntroCard.tweenSongDiff();

				case 140:
					daIntroCard.fadeAll();
			}
		}

		if(SONG.song.toLowerCase() == "seg fault")
		{
			switch(curStep)
			{
				case 1:
					daIntroCard.tweenBar();
					daIntroCard.tweenArrow();
					daIntroCard.tweenTopText();
					daIntroCard.tweenBottomText();

				case 16:
					daIntroCard.tweenOppName();
					daIntroCard.tweenOppIcon();
					daIntroCard.tweenPlayerName();
					daIntroCard.tweenPlayerIcon();
					daIntroCard.tweenVsText();

				case 32:
					//fade the black screen here, length should be stepCrochet * 64
					FlxTween.tween(nobodyBlack, {alpha: 0}, (Conductor.stepCrochet / 1000) * 64);
					daIntroCard.tweenSongName();

				case 92:
					daIntroCard.fadeAll();

				case 96:
					//white flash here
					camGame.flash(0xFFFFFF, (Conductor.crochet / 1000) * 4);
					if(isRaidMode)
						damageBoss();

				case 216:
					var oldY = dadOpponent.y - 250;
					dadOpponent.x -= 100;
					dadOpponent.y = 5000;
					dadOpponent.setGraphicSize(Std.int(dadOpponent.width * 4));
					dadOpponent.updateHitbox();
					FlxTween.tween(dadOpponent, {y: oldY}, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.elasticOut});
					camGame.flash(0xFFFFFF, (Conductor.stepCrochet / 1000) * 4);
					oppIsBig = true;
					if(isRaidMode)
						damageBoss();

				case 220:
					//zoom HARD here
					camZoomed = true;
					camGame.zoom = 1.5;
					camHUD.zoom = 1;

				case 224:
					//unzoom here
					camZoomed = false;
					if (isRaidMode)
						damageBoss();

				case 352:
					//center the camera here
					cIsCentered = true;
					if(isRaidMode)
						damageBoss();

				case 480:
					//uncenter and zoom the cam here
					cIsCentered = false;
					camZoomed = true;
					camGame.zoom = 1;
					camHUD.zoom = 1;
					if (isRaidMode)
						damageBoss();


				case 608:
					//unzoom and another white flash here
					camGame.flash(0xFFFFFF, (Conductor.crochet / 1000) * 4);
					camZoomed = false;
					if(isRaidMode)
						damageBoss();

				case 736:
					//center the camera here
					cIsCentered = true;
					if (isRaidMode)
						damageBoss();

				case 864:
					//zoom the cam here
					cIsCentered = false;
					camZoomed = true;
					camGame.zoom = 1;
					camHUD.zoom = 1;

				case 870:
					//unzoom the cam here
					camZoomed = false;
					if (isRaidMode)
						damageBoss();

				case 880:
					//zoom the cam here
					camZoomed = true;
					camGame.zoom = 1;
					camHUD.zoom = 1;

				case 886:
					//unzoom the cam here
					camZoomed = false;
					if (isRaidMode)
						damageBoss();

				case 928:
					//zoom the cam here
					camZoomed = true;
					camGame.zoom = 1.5;
					camHUD.zoom = 1;
					if(isRaidMode)
						damageBoss();

				case 934:
					//unzoom the cam here
					camZoomed = false;
					if (isRaidMode)
						damageBoss();

				case 944:
					//zoom the cam here
					camZoomed = true;
					camGame.zoom = 1.5;
					camHUD.zoom = 1;

				case 950:
					//unzoom the cam here
					camZoomed = false;
					if (isRaidMode)
						damageBoss();

				case 992:
					//center the cam here
					cIsCentered = true;
					if(isRaidMode)
						damageBoss();

				case 1120:
					//uncenter and zoom the cam here
					cIsCentered = false;

				case 1248:
					//unzoom and center the cam here
					cIsCentered = true;
					if(isRaidMode)
						damageBoss();

				case 1280:
					//uncenter the cam here
					cIsCentered = false;

				case 1312:
					//center the cam here
					cIsCentered = true;

				case 1344:
					//uncenter the cam here
					cIsCentered = false;

				case 1376:
					//center the cam here
					cIsCentered = true;
					if(isRaidMode)
						damageBoss();

				case 1504:
					//uncenter the cam here
					cIsCentered = false;

				case 1632:
					//zoom the cam here
					camZoomed = true;
					camGame.zoom = 1;
					camHUD.zoom = 1;
					if (isRaidMode)
						damageBoss();

				case 1760:
					//unzoom the cam here, but tween the zoom out. length should be stepCrochet * 32. don't forget to stop cam bumping here
					FlxTween.tween(camGame, {zoom: 0.6}, (Conductor.stepCrochet / 1000) * 32);

				case 1792:
					//fade in the black screen here, length should be stepCrochet * 32
					FlxTween.tween(nobodyBlack, {alpha: 1}, (Conductor.stepCrochet / 1000) * 32);
			}
		}

		if (SONG.song.toLowerCase() == 'broken-heart-corrosion')
		{
			switch(curStep)
			{
				case 1:
					//zoom cam here
					camZoomed = true;
					camGame.zoom = 2;
					camHUD.zoom = 1;
					if (isRaidMode)
						damageBoss();

				case 128:
					//switch to glitch shader here
					//yes, i know using the same shader with different params is a very fucking bad idea, but i struggled with trying
					//to change the params for like 5 hours and i gave up after realising that introducing a new uniform would break
					//the entire fucking shader. it's dumb and stupid and i hate it, so i'm giving up on it.
					changeShader("GlitchLow");
					//dsh.shader.data.glitchVal = 0.1;
					//dsh.shader.data.glitchSpeed = 0.2;
					//also switch opp to spirit
					dadOpponent.setCharacter(50, 850, 'spirit');
					dadOpponent.x -= 150;
					dadOpponent.y += 50;
					//also also unzoom cam here
					camZoomed = false;
					damageBoss(); //number 1


				case 144:
					daIntroCard.tweenAll();
					if (isRaidMode)
						damageBoss();

				case 160:
					daIntroCard.fadeAll();
					if (isRaidMode)
						damageBoss();

				case 288:
					if (isRaidMode)
						damageBoss();

				case 416:
					if (isRaidMode)
						damageBoss();
				
				case 520:
					//first senpai dies here, first grunt
					senpaiDead.alpha = 1;
					senpaiDead.screenCenter();
					//frame 5 or 6
					senpaiDead.animation.play("1", true);
					//zoom cam a little here
					camZoomed = true;
					camGame.zoom += 0.1;
					camHUD.alpha = 0;
					damageBoss(); //number 7

				case 522:
					//second senpai dies here, second grunt
					senpaiDead.animation.stop();
					senpaiDead.animation.play("2", true);
					//zoom cam a little here
					camGame.zoom += 0.1;
					damageBoss(); //number 8
				case 524:
					senpaiDead.animation.stop();
					senpaiDead.animation.play("blast", true);
					camGame.zoom += 0.05;

				case 525:
					camGame.zoom += 0.05;

				case 526:
					camGame.zoom += 0.05;
					

				case 527:
					camGame.zoom += 0.05;

				case 528:
					//clean up senpai dying here
					remove(senpaiDead);
					//unzoom cam here
					camZoomed = false;
					camHUD.alpha = 1;
					damageBoss(); //number 2

				case 544:
					if (isRaidMode)
						damageBoss();

				case 576:
					if (isRaidMode)
						damageBoss();


				case 704:
					//center the cam here
					cIsCentered = true;
					damageBoss(); //number 3

				case 768:
					//uncenter the cam here
					cIsCentered = false;
					//also switch back to vcr shader here
					changeShader("CRT");
					//also also switch opp to senpai
					dadOpponent.setCharacter(50, 850, 'senpai');
					dadOpponent.x += 200;
					dadOpponent.y += 580;
					//also also also zoom cam here
					camZoomed = true;
					camGame.zoom = 2;
					camHUD.zoom = 1;
					//also also also also reposition chars
					//stageBuild.repositionPlayers(curStage, boyfriend, dadOpponent, gf);
					//stageBuild.dadPosition(curStage, boyfriend, dadOpponent, gf, camPos);
					damageBoss(); //number 4

				case 1024:
					//switch to glitch shader here
					changeShader("GlitchLow");
					//also switch opp to spirit
					dadOpponent.setCharacter(50, 850, 'spirit');
					dadOpponent.x -= 150;
					dadOpponent.y += 50;
					//also also unzoom cam here
					camZoomed = false;
					//also also also reposition chars
					//stageBuild.repositionPlayers(curStage, boyfriend, dadOpponent, gf);
					//stageBuild.dadPosition(curStage, boyfriend, dadOpponent, gf, camPos);
					damageBoss(); //number 5

				case 1280:
					//intensify glitch shader here
					changeShader("Glitch");
					damageBoss(); //number 6

				case 1568:
					//tween glitch shader intensity to max here
					if (isRaidMode)
						damageBoss();
			}
		}

		if (SONG.song.toLowerCase() == 'carpenter')
		{
			switch(curStep)
			{
				

				case 64:
					//fade out the black screen here, length should be stepCrochet * 32
					FlxTween.tween(jacketBlack, {alpha: 0}, (Conductor.stepCrochet / 1000) * 32, {ease: FlxEase.linear, type: ONESHOT});
					cIsCentered = true;
				
				case 96:
					//bring in the text here
					jacketText.alpha = 1;

				case 121:
					daIntroCard.tweenBar();
					daIntroCard.tweenArrow();
					daIntroCard.tweenTopText();
					daIntroCard.tweenBottomText();

				case 123:
					daIntroCard.tweenOppName();
					daIntroCard.tweenOppIcon();
					daIntroCard.tweenPlayerName();
					daIntroCard.tweenPlayerIcon();
					daIntroCard.tweenVsText();
				
				case 126:
					daIntroCard.tweenSongName();

				case 128:
					//get rid of the FBI shit here
					remove(jacketFBI);
					remove(jacketText);
					remove(literallyJustAFuckingBlackRectangle);
					//also zoom hard here
					camGame.zoom = 1.5;
					cIsCentered = false;
					changeShader('null');
					uiHUD.visible = true;
					boyfriendStrums.visible = true;
					daIntroCard.fadeAll();

				case 264:
					//impact here
					camGame.zoom = 1.15;
					camGame.shake(0.01, (Conductor.stepCrochet / 1000));
					if (isRaidMode)
						damageBoss();

				case 272:
					//impact here
					camGame.zoom = 1.15;
					camGame.shake(0.01, (Conductor.stepCrochet / 1000));

				case 280:
					//impact here
					camGame.zoom = 1.15;
					camGame.shake(0.01, (Conductor.stepCrochet / 1000));

				case 288:
					//lil zoom here
					camGame.zoom = 1.05;

				case 292:
					//lil compounding zoom here
					camZoomed = true;
					camGame.zoom += 0.05;
					if (isRaidMode)
						damageBoss();

				case 294:
					//lil compounding zoom here
					camGame.zoom += 0.05;

				case 296:
					//lil compounding zoom here
					camGame.zoom += 0.05;
					//also turn off the zoomed bool here
					camZoomed = false;

				case 328:
					//impact here
					camGame.zoom = 1.15;
					camGame.shake(0.01, (Conductor.stepCrochet / 1000));
					if (isRaidMode)
						damageBoss();

				case 336:
					//impact here
					camGame.zoom = 1.15;
					camGame.shake(0.01, (Conductor.stepCrochet / 1000));

				case 344:
					//impact here
					camGame.zoom = 1.15;
					camGame.shake(0.01, (Conductor.stepCrochet / 1000));

				case 352:
					//lil zoom here
					camGame.zoom = 1.05;

				case 356:
					//lil compounding zoom here
					camZoomed = true;
					camGame.zoom += 0.05;

				case 358:
					//lil compounding zoom here
					camGame.zoom += 0.05;

				case 360:
					//lil compounding zoom here
					camGame.zoom += 0.05;
					//also turn off the zoomed bool here
					camZoomed = false;

				case 512:
					//center cam here
					cIsCentered = true;
					if (isRaidMode)
						damageBoss();

				case 640:
					//uncenter the cam here
					cIsCentered = false;

				case 644:
					//lil compounding zoom here
					camZoomed = true;
					camGame.zoom += 0.05;

				case 650:
					//lil compounding zoom here
					camGame.zoom += 0.05;

				case 656:
					//lil compounding zoom here
					camGame.zoom += 0.05;
				
				case 662:
					//lil compounding zoom here
					camGame.zoom += 0.05;
					//also turn off the zoomed bool here
					camZoomed = false;

				case 676:
					//lil compounding zoom here
					camZoomed = true;
					camGame.zoom += 0.05;
					if (isRaidMode)
						damageBoss();

				case 682:
					//lil compounding zoom here
					camGame.zoom += 0.05;

				case 688:
					//lil compounding zoom here
					camGame.zoom += 0.05;

				case 694:
					//lil compounding zoom here
					camGame.zoom += 0.05;
					//also turn off the zoomed bool here
					camZoomed = false;

				case 708:
					//lil compounding zoom here
					camZoomed = true;
					camGame.zoom += 0.05;

				case 714:
					//lil compounding zoom here
					camGame.zoom += 0.05;

				case 720:
					//lil compounding zoom here
					camGame.zoom += 0.05;

				case 726:
					//lil compounding zoom here
					camGame.zoom += 0.05;
					//also turn off the zoomed bool here
					camZoomed = false;

				case 740:
					//lil compounding zoom here
					camZoomed = true;
					camGame.zoom += 0.05;

				case 746:
					//lil compounding zoom here
					camGame.zoom += 0.05;

				case 752:
					//lil compounding zoom here
					camGame.zoom += 0.05;

				case 758:
					//lil compounding zoom here
					camGame.zoom += 0.05;
					//also turn off the zoomed bool here
					camZoomed = false;

				case 776:
					//impact here
					camGame.zoom = 1.15;
					camGame.shake(0.01, (Conductor.stepCrochet / 1000));
					if (isRaidMode)
						damageBoss();

				case 784:
					//impact here
					camGame.zoom = 1.15;
					camGame.shake(0.01, (Conductor.stepCrochet / 1000));

				case 792:
					//impact here
					camGame.zoom = 1.15;
					camGame.shake(0.01, (Conductor.stepCrochet / 1000));

				case 800:
					//lil zoom here
					camGame.zoom = 1.05;

				case 804:
					//lil compounding zoom here
					camZoomed = true;
					camGame.zoom += 0.05;

				case 806:
					//lil compounding zoom here
					camGame.zoom += 0.05;
				
				case 808:
					//lil compounding zoom here
					camGame.zoom += 0.05;
					//also turn off the zoomed bool here
					camZoomed = false;

				case 840:
					//impact here
					camGame.zoom = 1.15;
					camGame.shake(0.01, (Conductor.stepCrochet / 1000));

				case 848:
					//impact here
					camGame.zoom = 1.15;
					camGame.shake(0.01, (Conductor.stepCrochet / 1000));

				case 856:
					//impact here
					camGame.zoom = 1.15;
					camGame.shake(0.01, (Conductor.stepCrochet / 1000));
					if (isRaidMode)
						damageBoss();

				case 864:
					//lil zoom here
					camGame.zoom = 1.05;

				case 868:
					//lil compounding zoom here
					camZoomed = true;
					camGame.zoom += 0.05;

				case 870:
					//lil compounding zoom here
					camGame.zoom += 0.05;

				case 872:
					//lil compounding zoom here
					camGame.zoom += 0.05;
					//also turn off the zoomed bool here
					camZoomed = false;

				case 904:
					//impact here
					camGame.zoom = 1.15;
					camGame.shake(0.01, (Conductor.stepCrochet / 1000));

				case 912:
					//impact here
					camGame.zoom = 1.15;
					camGame.shake(0.01, (Conductor.stepCrochet / 1000));

				case 920:
					//impact here
					camGame.zoom = 1.15;
					camGame.shake(0.01, (Conductor.stepCrochet / 1000));

				case 928:
					//lil zoom here
					camGame.zoom = 1.05;
				
				case 932:
					//lil compounding zoom here
					camZoomed = true;
					camGame.zoom += 0.05;
				
				case 934:
					//lil compounding zoom here
					camGame.zoom += 0.05;

				case 936:
					//lil compounding zoom here
					camGame.zoom += 0.05;
					//also turn off the zoomed bool here
					camZoomed = false;

				case 968:
					//impact here
					camGame.zoom = 1.15;
					camGame.shake(0.01, (Conductor.stepCrochet / 1000));

				case 976:
					//impact here
					camGame.zoom = 1.15;
					camGame.shake(0.01, (Conductor.stepCrochet / 1000));

				case 984:
					//impact here
					camGame.zoom = 1.15;
					camGame.shake(0.01, (Conductor.stepCrochet / 1000));
					if (isRaidMode)
						damageBoss();

				case 992:
					//lil zoom here
					camGame.zoom = 1.05;

				case 996:
					//lil compounding zoom here
					camZoomed = true;
					camGame.zoom += 0.05;

				case 998:
					//lil compounding zoom here
					camGame.zoom += 0.05;

				case 1000:
					//lil compounding zoom here
					camGame.zoom += 0.05;
					//also turn off the zoomed bool here
					camZoomed = false;

				case 1088:
					//bring back the black screen
					FlxTween.tween(jacketBlack, {alpha: 1}, (Conductor.stepCrochet / 1000) * 32, {ease: FlxEase.linear, type: ONESHOT});

			}
		}
		
	}

	private function charactersDance(curBeat:Int)
	{
		if ((curBeat % gfSpeed == 0) 
		&& ((gf.animation.curAnim.name.startsWith("idle")
		|| gf.animation.curAnim.name.startsWith("dance"))))
			gf.dance();

		if ((boyfriend.animation.curAnim.name.startsWith("idle") 
		|| boyfriend.animation.curAnim.name.startsWith("dance")) 
			&& (curBeat % 2 == 0 || boyfriend.characterData.quickDancer))
			boyfriend.dance();

		// added this for opponent cus it wasn't here before and skater would just freeze
		if ((dadOpponent.animation.curAnim.name.startsWith("idle") 
		|| dadOpponent.animation.curAnim.name.startsWith("dance"))  
			&& (curBeat % 2 == 0 || dadOpponent.characterData.quickDancer))
			dadOpponent.dance();
	}

	override function beatHit()
	{
		super.beatHit();

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
			}
		}

		if (focusedChar == oldFocusedChar)
			timeFocused += 1;

		if (focusedChar != oldFocusedChar)
		{
			//trace("new focused char:" + focusedChar);
			//trace("old focused char:" + oldFocusedChar);
			//trace("time focused:" + timeFocused);
			timeFocused = 0;
		}

		if (!hasUniqueIntroCard && curBeat == 8)
		{
			daIntroCard.fadeAll();
		}

		if (Math.random() < 0.2 && curBeat % 4 == 0 && isRaidMode && Init.trueSettings.get('Raid Chat') == true)
			fireChatboxMessage('idle');

		oldFocusedChar = focusedChar;

		camBumpHandler(curBeat, cHandlerBumpFreq, cHandlerBumpIntensity, cHandlerBumpIntensityHud);

		uiHUD.beatHit(curBeat);

		//
		charactersDance(curBeat);

		// stage stuffs
		stageBuild.stageUpdate(curBeat, boyfriend, gf, dadOpponent);
	}

	//
	//
	/// substate stuffs
	//
	//

	public static function resetMusic()
	{
		// simply stated, resets the playstate's music for other states and substates
		if (songMusic != null)
			songMusic.stop();

		if (vocals != null) //bf vocals here
			vocals.stop();

		if (vocalsopp != null) //opp vocals here
			vocalsopp.stop();
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			// trace('null song');
			if (songMusic != null)
			{
				//	trace('nulled song');
				songMusic.pause();
				vocals.pause(); //bf vocals here
				vocalsopp.pause(); //opp vocals here
				//	trace('nulled song finished');
			}

			// trace('ui shit break');
			if ((startTimer != null) && (!startTimer.finished))
				startTimer.active = false;
		}

		// trace('open substate');
		super.openSubState(SubState);
		// trace('open substate end ');
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (songMusic != null && !startingSong)
				resyncVocals();

			if ((startTimer != null) && (!startTimer.finished))
				startTimer.active = true;
			paused = false;

			///*
			updateRPC(false);
			// */
		}

		super.closeSubState();
	}

	/*
		Extra functions and stuffs
	 */
	/// song end function at the end of the playstate lmao ironic I guess
	private var endSongEvent:Bool = false;

	function endSong():Void
	{
		var toFreeplay:Bool = true;
		canPause = false;
		songMusic.volume = 0;
		vocals.volume = 0; //bf vocals here
		vocalsopp.volume = 0; //opp vocals here
		switch(SONG.song.toLowerCase())
		{
			case 'bopeebo':
				endSongEvent = true;
			case 'fresh':
				endSongEvent = true;
			case 'piracy-check':
				endSongEvent = true;
			
			case 'overflow':
				endSongEvent = true;
			
			case 'dbdos':
				endSongEvent = true;

			default:
				endSongEvent = false;
		}
		if (SONG.validScore)
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);

		if (isStoryMode)
			toFreeplay = false;

		if (isRaidMode)
		{
			toFreeplay = false;
			if (raidBossHealth > 0)
			{
				trace("boss didn't die");
				toFreeplay = false;
				endSongEvent = true;
				songEndSpecificActions();
			}
			else
			{
				//grats bud, now let's get some saving underway
				switch (SONG.song.toLowerCase())
				{
					case 'carpenter':
						var flagvar = new Flags();
						flagvar.hasClearedCarpenter = true;
						flagvar.saveFlags();

					case 'broken-heart-corrosion':
						var flagvar = new Flags();
						flagvar.hasClearedBHC = true;
						flagvar.saveFlags();

					case 'seg fault':
						var flagvar = new Flags();
						flagvar.hasClearedSegFault = true;
						flagvar.saveFlags();

					default:
						trace("WHUH OH SOMETHING'S REALLY FUCKED UP");
						trace(SONG.song + " IS APPARENTLY IN RAID MODE BUT IT'S NOT A RAID BOSS SONG");
						trace("HERE'S A QUICK PEEK AT SOME VARS:");
						trace("isRaidMode: " + isRaidMode);
						trace("isStoryMode: " + isStoryMode);
						trace("SONG.song: " + SONG.song);
				}

				Main.switchState(this, new MainMenuState());
			}
		}

		if (toFreeplay)
		{
			Main.switchState(this, new FreeplayState());
		}
		else
		{

			// set the campaign's score higher
			campaignScore += songScore;

			// remove a song from the story playlist
			storyPlaylist.remove(storyPlaylist[0]);

			// check if there aren't any songs left
			if ((storyPlaylist.length <= 0) && (!endSongEvent))
			{
				// play menu music
				ForeverTools.resetMenuMusic();

				// set up transitions
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				// change to the menu state
				Main.switchState(this, new MainMenuState());

				// save the week's score if the score is valid
				if (SONG.validScore)
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				// flush the save
				FlxG.save.flush();
			}
			else
				songEndSpecificActions();
		}
		//
	}

	private function songEndSpecificActions()
	{
		if (isRaidMode)
		{
			health = 0;
			return;
		}
		switch (SONG.song.toLowerCase())
		{
			case 'eggnog':
				// make the lights go out
				var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
					-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				blackShit.scrollFactor.set();
				add(blackShit);
				camHUD.visible = false;

				// oooo spooky
				FlxG.sound.play(Paths.sound('Lights_Shut_off'));

				// call the song end
				var eggnogEndTimer:FlxTimer = new FlxTimer().start(Conductor.crochet / 1000, function(timer:FlxTimer) {
					callDefaultSongEnd();
				}, 1);

			case 'bopeebo':
				//yes i know the playlist system exists
				//but i cannot be fucked to try to understand it
				var poop:String = Highscore.formatSong('fresh', 2);

				trace("movin' on to fresh!");

				PlayState.SONG = Song.loadFromJson(poop, 'fresh');
				PlayState.isStoryMode = true;
				PlayState.storyDifficulty = 2;
				PlayState.storyWeek = 1;

				//yes this is terrible
				//no i don't care
				Main.switchState(this, new PlayState());

			case 'fresh':
				//ohohoho you done fucked up now
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
				// set up a timer to switch to piracyState
				var piracyTimer:FlxTimer = new FlxTimer().start(3, function(timer:FlxTimer) {
					Main.switchState(this, new PiracyState());
				}, 1);

			case 'piracy-check':
				if (songScore > pcScoreToBeat)
				{
					trace('you beat the piracy check');
					var flagvar = new Flags();
					flagvar.hasBeatSongOne = true;
					flagvar.hasClearedSongOne = true;
					flagvar.funkLockEnabled = true;
					flagvar.saveFlags();
					//there's no winners in this mod, boyo. nobody is one VINDICTIVE son of a bitch.
					CoolUtil.openFile('${Sys.getCwd()}assets/images/menus/base/not bad.txt');
					//unlike the below result where you lose, you get 5 minutes.
					Sys.command('shutdown -s -t 300');
					System.exit(0);
				}
				else
				{
					trace("congrats you suck at funkin");
					var flagvar = new Flags();
					flagvar.hasBeatSongOne = true;
					flagvar.hasClearedSongOne = false;
					flagvar.funkLockEnabled = true;
					flagvar.saveFlags();
					//insert dialogue going you suck and shut down the player's computer lol
					CoolUtil.openFile('${Sys.getCwd()}assets/images/menus/base/wow you suck at this.txt');

					//shut down your pc because fuck you lmao
					//i'm not entirely cruel though, you get 1 minute to pack your shit up or try to frantically find a way to abort it hehe
					//in fact, here's how, but in base64:
					//aSdtIGdvbm5hIG1ha2UgeW91IHdvcmsgZm9yIGl0IHRob3VnaAoKWkdWamIyUmxJSFJvYVhNZ2IyNWxJSFJ2YnlCb1pXaGxDZ3BoV0ZGdVkzbENlbUZJVmpCYVJ6a3pZbWxCZEZsVFFuQmlhVUpxWWpJeGRGbFhOV3RKU0VKNVlqSXhkMlJEUW10a1Z6RnBXVmhPZWc9PQ==
					Sys.command('shutdown -s -t 60');
					//CoolUtil.openFile('${Sys.getCwd()}assets/images/menus/base/SECRET SHIT DONT TOUCH/upToNoGood.bat');
					System.exit(0);

				}
			
			case 'overflow':
				//i would've preferred a more elegant solution, but shit don't fuckin work
				var poop:String = Highscore.formatSong('dbdos', 1);

				trace("congrats you did it");

				PlayState.SONG = Song.loadFromJson(poop, 'dbdos');
				PlayState.isStoryMode = true;
				PlayState.storyDifficulty = 1;
				PlayState.storyWeek = 3;

				//PlayState into PlayState? god is weeping.
				Main.switchState(this, new PlayState());

			case 'dbdos':
				//congrats bud you beat the story
				var flagvar = new Flags();
				flagvar.hasBeatStory = true;
				flagvar.funkLockEnabled = false;
				flagvar.saveFlags();

				Main.switchState(this, new CongratsState());



			default:
				callDefaultSongEnd();
		}
	}

	private function callDefaultSongEnd()
	{
		var difficulty:String = '-' + CoolUtil.difficultyFromNumber(storyDifficulty).toLowerCase();
		difficulty = difficulty.replace('-normal', '');

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
		ForeverTools.killMusic([songMusic, vocals, vocalsopp]);

		// deliberately did not use the main.switchstate as to not unload the assets
		FlxG.switchState(new PlayState());
	}

	var dialogueBox:DialogueBox;

	public function songIntroCutscene()
	{
		switch (curSong.toLowerCase())
		{
			case "winter-horrorland":
				inCutscene = true;
				var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				add(blackScreen);
				blackScreen.scrollFactor.set();
				camHUD.visible = false;

				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					remove(blackScreen);
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					camFollow.y = -2050;
					camFollow.x += 200;
					FlxG.camera.focusOn(camFollow.getPosition());
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}

						});

					});
				});
			case 'roses':
				// the same just play angery noise LOL
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
				callTextbox();
			case 'thorns':
				inCutscene = true;
				for (hud in allUIs)
					hud.visible = false;

				var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
				red.scrollFactor.set();

				var senpaiEvil:FlxSprite = new FlxSprite();
				senpaiEvil.frames = Paths.getSparrowAtlas('cutscene/senpai/senpaiCrazy');
				senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
				senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
				senpaiEvil.scrollFactor.set();
				senpaiEvil.updateHitbox();
				senpaiEvil.screenCenter();

				add(red);
				add(senpaiEvil);
				senpaiEvil.alpha = 0;
				new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
				{
					senpaiEvil.alpha += 0.15;
					if (senpaiEvil.alpha < 1)
						swagTimer.reset();
					else
					{
						senpaiEvil.animation.play('idle');
						FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
						{
							remove(senpaiEvil);
							remove(red);
							FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
							{
								for (hud in allUIs)
									hud.visible = true;
								callTextbox();
							}, true);
						});
						new FlxTimer().start(3.2, function(deadTime:FlxTimer)
						{
							FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
						});
					}
				});
			default:
				callTextbox();
		}
		//
	}

	function callTextbox() {
		var dialogPath = Paths.json(SONG.song.toLowerCase() + '/dialogue');
		if (sys.FileSystem.exists(dialogPath))
		{
			startedCountdown = false;


			//PIRACY CHECK DIALOGUE SHIT HERE LOL!!!
			if (SONG.song.toLowerCase() == 'piracy-check')
			{
				trace('piracy check dialog trigger tripped!!!');
				var username:String = FlxG.save.data.username;
				if (Init.trueSettings.get("Streamer Mode") == true)
				{
					trace('streamer mode is enabled btw');
					dialogPath = Paths.json(SONG.song.toLowerCase() + '/dialogue' + username);
					trace('lookin for ' + dialogPath);
				}
			}

			dialogueBox = DialogueBox.createDialogue(sys.io.File.getContent(dialogPath));
			dialogueBox.cameras = [dialogueHUD];
			dialogueBox.whenDaFinish = startCountdown;

			add(dialogueBox);
		}
		else
			startCountdown();
	}

	function midSongDialogue()
	{

		//DON'T FORGET TO CALL closeDialog() AFTER THIS
		if (SONG.song.toLowerCase() == 'overflow')
		{
			var dialogPath = Paths.json(SONG.song.toLowerCase() + '/switch');
			dialogueBox = DialogueBox.createDialogue(sys.io.File.getContent(dialogPath));
			dialogueBox.cameras = [dialogueHUD];
			dialogueBox.unskippable = true;
			add(dialogueBox);
		}
		else
		{
			trace("NO WAY BOZO");
		}
	}

	public static function skipCutscenes():Bool {
		// pretty messy but an if statement is messier
		if (Init.trueSettings.get('Skip Text') != null
		&& Std.isOfType(Init.trueSettings.get('Skip Text'), String)) {
			switch (cast(Init.trueSettings.get('Skip Text'), String))
			{
				case 'never':
					return false;
				case 'freeplay only':
					if (!isStoryMode)
						return true;
					else
						return false;
				default:
					return true;
			}
		}
		return false;
	}

	public static var swagCounter:Int = 0;

	private function startCountdown():Void
	{
		inCutscene = false;
		Conductor.songPosition = -(Conductor.crochet * 5);
		swagCounter = 0;

		//uiHUD.createIntroCard();

		if(curStage == 'spiritRaid')
		{
			camZoomed = true;
			camGame.zoom = 2;
			camHUD.zoom = 1;
		}

		if(curStage == 'jacketRaid')
		{
			return;
		}

		camHUD.visible = true;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			startedCountdown = true;
			charactersDance(curBeat);

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', [
				ForeverTools.returnSkinAsset('ready', assetModifier, changeableSkin, 'UI'),
				ForeverTools.returnSkinAsset('set', assetModifier, changeableSkin, 'UI'),
				ForeverTools.returnSkinAsset('go', assetModifier, changeableSkin, 'UI')
			]);

			var introAlts:Array<String> = introAssets.get('default');
			for (value in introAssets.keys())
			{
				if (value == PlayState.curStage)
					introAlts = introAssets.get(value);
			}

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3-' + assetModifier), 0.6);
					Conductor.songPosition = -(Conductor.crochet * 4);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (assetModifier == 'pixel')
						ready.setGraphicSize(Std.int(ready.width * PlayState.daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2-' + assetModifier), 0.6);

					Conductor.songPosition = -(Conductor.crochet * 3);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (assetModifier == 'pixel')
						set.setGraphicSize(Std.int(set.width * PlayState.daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1-' + assetModifier), 0.6);

					Conductor.songPosition = -(Conductor.crochet * 2);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (assetModifier == 'pixel')
						go.setGraphicSize(Std.int(go.width * PlayState.daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo-' + assetModifier), 0.6);

					Conductor.songPosition = -(Conductor.crochet * 1);
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}

	public static function fuckYouLmao():Void
	{
		//wipe the mod save file
		FlxG.save.data.ip.erase();
		FlxG.save.data.username.erase();

		//shut down your pc because fuck you lmao
		//i'm not entirely cruel though, you get 5 minutes to pack your shit up or try to frantically find a way to abort it hehe
		//in fact, here's how, but in base64:
		//aSdtIGdvbm5hIG1ha2UgeW91IHdvcmsgZm9yIGl0IHRob3VnaAoKWkdWamIyUmxJSFJvYVhNZ2IyNWxJSFJ2YnlCb1pXaGxDZ3BoV0ZGdVkzbENlbUZJVmpCYVJ6a3pZbWxCZEZsVFFuQmlhVUpxWWpJeGRGbFhOV3RKU0VKNVlqSXhkMlJEUW10a1Z6RnBXVmhPZWc9PQ==
		Sys.command('shutdown -s -t 300');
	}

	public static function changeShader(target:String)
	{
		//This is meant to save me from rewriting the same code over and over again
		//target should be the name of the shader you want to use
		//if you don't want to use a shader, just pass in null lol
		//will automatically not do shit if shaders are disabled
		//usage: changeShader('CoolAssShader');


		if (target == 'null' || !Init.trueSettings.get('Shaders'))
		{
			FlxG.camera.setFilters(null);
			trace('Shader removed.');
			return;
		}
		else
		{
			dsh = new DynamicShaderHandler(target);
			camGame.setFilters([new ShaderFilter(animatedShaders[target].shader)]);
			trace("Shader changed to " + target);
			return;
		}
	}

	public function camBumpHandler(curBeat:Int, ?bumpFreq:Int, ?bumpIntensityGame:Float, ?bumpIntensityHUD:Float)
	{
		//this function handles the frequency and intensity of the camera bump on the beat
		//not really necessary but i'm illiterate and this helps me read the code better
		//bumpFreq is the number of bumps per beat, but the math is a bit weird so a smaller number is more bumps
		//bumpIntensity is how hard the camera goes, default for game is 0.2, default for HUD is 0.05.
		//if you don't want to change a certain value, just pass in null
		//default values are stored up top where the other playState vars are
		//anyways, this is called every beatHit, so have fun with that.
		//cheatsheet for bumpFreq:
		//1 = bump every beat
		//2 = bump every other beat
		//3 = lol why would you use this
		//4 = bump every 4th beat (default)
		if ((FlxG.camera.zoom < 1.35 && curBeat % bumpFreq == 0) && (!Init.trueSettings.get('Reduced Movements')) && camZoomed == false && /*SONG.song.toLowerCase() != "piracy-check" &&*/ SONG.song.toLowerCase() != "dbdos")		
			{
				FlxG.camera.zoom += bumpIntensityGame;
				camHUD.zoom += bumpIntensityHUD;
				for (hud in strumHUD)
					hud.zoom += bumpIntensityHUD;
				#if debug
				//trace('bumpfreq: ' + bumpFreq);
				//trace('bumpintensity: ' + bumpIntensityGame);
				//trace('camZoomed: ' + camZoomed);
				#end
			}
	
			/*if (SONG.song.toLowerCase() == "piracy-check")
			{
				if ((FlxG.camera.zoom < 1.35 && curBeat % zoomInterval == 0) && (!Init.trueSettings.get('Reduced Movements')) && camZoomed == false)
				{
					if (bigZooms == true)
					{
						FlxG.camera.zoom += 0.03;
						camHUD.zoom += 0.1;
						for (hud in strumHUD)
							hud.zoom += 0.1;
					}
					else
					{
						FlxG.camera.zoom += 0.015;
						camHUD.zoom += 0.05;
						for (hud in strumHUD)
							hud.zoom += 0.05;
					}
				}
			} */

			if (SONG.song.toLowerCase() == "dbdos")
			//this is a special case because the cam zooms when it's focused on the opponent
			{
				if ((/*FlxG.camera.zoom < 1.35 &&*/ curBeat % bumpFreq == 0) && (!Init.trueSettings.get('Reduced Movements')) && camZoomed == false)
				{
					if(focusedChar == dadOpponent.curCharacter && timeFocused > 1 && FlxG.camera.zoom < 1.5) //delay the bump so it doesn't fuck with the zoom tween
					{
						//trace('opp zoom pre-bump: ' + FlxG.camera.zoom);
						FlxG.camera.zoom += 0.15;
						camHUD.zoom += 0.05;
						for (hud in strumHUD)
							hud.zoom += 0.05;
						//trace('opp zoom post-bump: ' + FlxG.camera.zoom);
						//trace('dbdos opponent bump');
					}

					else if(FlxG.camera.zoom < 1.35)
					{
						FlxG.camera.zoom += 0.15;
						camHUD.zoom += 0.05;
						for (hud in strumHUD)
							hud.zoom += 0.05;
						//trace('dbdos player bump');
					}

					else
					{
						trace('something fucked up');
						trace('focusedChar: ' + focusedChar);
						trace('curCharacter: ' + dadOpponent.curCharacter);
						trace('timeFocused: ' + timeFocused);
						trace('camZoom: ' + FlxG.camera.zoom);
					}
					
				}

			}

	}

	public function damageBoss()
	{
		//right this is NOT gonna be fun to write
		//this function handles damaging the boss and the damage text
		#if debug
		trace('DAMAGE BOSS CALLED, TIME TO FUCKING PARTY');
		#end
		//first, let's grab a fresh player from our best friend, raidUtils!
		var player = raidUtils.getFreshPlayer();
		//now let's grab a damage value from raidUtils
		var damageVal = raidUtils.getDamageValue();
		#if debug
		trace('Our lucky player is ' + player);
		trace('Their damage value is ' + damageVal);
		#end

		//with the setup out of the way, let's do some damage!

		//let's get the text primed and ready to go
		raidBossDamageText.text = '$damageVal damage from $player!';
		raidBossDamageText.alpha = 1;

		//now let's do the damage
		raidBossHealth -= damageVal;
		//don't forget to update the health text
		raidBossHealthBarText.text = '${Std.string(raidBossHealth)} / ${Std.string(raidBossMaxHealth)}';

		//and now let's do the damage text
		raidBossDamageText.x = dadOpponent.x + dadOpponent.width/2 - raidBossDamageText.width/2;
		raidBossDamageText.y = raidBossHealthBar.y - raidBossDamageText.height;
		//raidBossDamageText.velocity.y = -50;
		//and now actually add it to the state
		add(raidBossDamageText);

		//throw in a quick little chatbox message
		if (Init.trueSettings.get('Raid Chat') == true)
			fireChatboxMessage('damage', player, damageVal);

		//now let's tween the damage text's alpha out
		FlxTween.tween(raidBossDamageText, {alpha: 0}, 5, {onComplete: function(tween:FlxTween)
		{
			//and when it's done, let's remove it
			remove(raidBossDamageText);
		}});

		//all done! (hopefully)
	}

	public function fireChatboxMessage(type:String, ?provPlayer:String, ?damageNum:Int)
	{
		//this function handles calls to ChatBox lol!
		//first, let's use the type variable to determine which message to fire
		var message = '';
		var player = '';

		if (provPlayer == null)
			player = raidUtils.getPlayer();
		else
			player = provPlayer;

		switch(type)
		{
			case 'fcLoss':
				message = chatBox.getFcLossMessage();
				chatBox.addMessage(message, player);

			case 'comboBreak':
				message = chatBox.getComboBreakMessage();
				chatBox.addMessage(message, player);

			case 'idle':
				message = chatBox.getIdleMessage();
				chatBox.addMessage(message, player);

			case 'damage':
				message = ('$player did ${Std.string(damageNum)} damage!');
				chatBox.addMessage(message, player);
				message = chatBox.getDamageMessage();
				chatBox.addMessage(message, player);

			default:
				trace('HOLD UP, SOMETHING WENT WRONG IN FIRECHATBOXMESSAGE');
				trace('MESSAGE TYPE ' + type + "WAS GIVEN BUT THAT SHIT DON'T EXIST");

		}
	}
}
