package meta.state.menus;

import flash.text.TextField;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.ColorTween;
import flixel.util.FlxColor;
import gameObjects.userInterface.HealthIcon;
import lime.utils.Assets;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.Song.SwagSong;
import meta.data.dependency.Discord;
import meta.data.font.Alphabet;
import openfl.media.Sound;
import sys.FileSystem;
import sys.thread.Mutex;
import sys.thread.Thread;

import meta.data.Conductor.BPMChangeEvent;

using StringTools;

class FreeplayState extends MusicBeatState
{
	//
	var songs:Array<SongMetadata> = [];
	var forbiddenSongs:Array<String> = ['seg-fault', 'broken-heart-corrosion', 'carpenter'];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curSongPlaying:Int = -1;
	var curDifficulty:Int = 1;
	var curCharacter:Int = 0;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var songThread:Thread;
	var threadActive:Bool = true;
	var mutex:Mutex;
	var songToPlay:Sound = null;

	var charArray:Array<String> = ['bf', 'tankman', 'cheffriend',  'airmarshal', 'v-rage', 'bf-cyber', 'afton', 'mario', 'jacket'];
	var charText:FlxText;
	var charIcon:HealthIcon;
	var charBG:FlxSprite;
	var charTip:FlxText;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	private var mainColor = FlxColor.WHITE;
	private var bg:FlxSprite;
	private var scoreBG:FlxSprite;

	private var existingSongs:Array<String> = [];
	private var existingDifficulties:Array<Array<String>> = [];

	private var songBpm:Float = 0;

	public var bgCam:FlxCamera;
	public var objCam:FlxCamera;
	public var defaultCamZoom:Float = 1.0;
	public var camCooldown:Bool = false;

	var flagVar:Flags = new Flags();

	override function create()
	{
		super.create();

		bgCam = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		bgCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(bgCam);

		objCam = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		objCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(objCam);

		FlxCamera.defaultCameras = [objCam];

		mutex = new Mutex();

		/**
			Wanna add songs? They're in the Main state now, you can just find the week array and add a song there to a specific week.
			Alternatively, you can make a folder in the Songs folder and put your songs there, however, this gives you less
			control over what you can display about the song (color, icon, etc) since it will be pregenerated for you instead.
		**/
		// load in all songs that exist in folder
		var folderSongs:Array<String> = CoolUtil.returnAssetsLibrary('songs', 'assets');

		//yes this is a really shitty way to do this but whatever
		folderSongs.remove('seg-fault');
		folderSongs.remove('broken-heart-corrosion');
		folderSongs.remove('carpenter');

		///*
		for (i in 0...Main.gameWeeks.length)
		{
			addWeek(Main.gameWeeks[i][0], i, Main.gameWeeks[i][1], Main.gameWeeks[i][2]);
			for (j in cast(Main.gameWeeks[i][0], Array<Dynamic>))
				existingSongs.push(j.toLowerCase());
		}

		// */

		for (i in folderSongs)
		{

			if (!existingSongs.contains(i.toLowerCase()))
			{
				var icon:String = 'gf';
				var chartExists:Bool = FileSystem.exists(Paths.songJson(i, i));
				if (chartExists)
				{
					var bpm = CoolUtil.getSongMeta(i, "bpm");
					var castSong:SwagSong = Song.loadFromJson(i, i);
					icon = (castSong != null) ? castSong.player2 : 'gf';
					addSong(CoolUtil.spaceToDash(castSong.song), 1, icon, FlxColor.WHITE, bpm);
				}
			}
		}

		// LOAD MUSIC
		// ForeverTools.resetMenuMusic();

		#if !html5
		Discord.changePresence('FREEPLAY MENU', 'Main Menu');
		#end

		// LOAD CHARACTERS
		bg = new FlxSprite().loadGraphic(Paths.image('menus/base/menuDesat'));
		bg.cameras = [bgCam];
		add(bg);
		

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);


		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		//let's check for mods for freeplay characters here
		if(!flagVar.hasClearedAllRaids)
		{
			trace("player hasn't cleared all raids yet, removing jacket");
			charArray.remove('jacket');
		}

		if(!Paths.doesSaveDataExist('vtan'))
		{
			trace('removed v-tan and cyber bf');
			charArray.remove('v-rage');
			charArray.remove('bf-cyber');
		}

		if(!Paths.doesSaveDataExist('airmarshal'))
		{
			trace('removed air marshal');
			charArray.remove('airmarshal');
		}

		if(!Paths.doesSaveDataExist('mario'))
		{
			trace('removed mario');
			charArray.remove('mario');
		}
		if(!Paths.doesSaveDataExist('afton'))
		{
			trace('removed afton');
			charArray.remove('afton');
		}

		for (i in 0...charArray.length)
		{
			trace('charArray[' + i + '] = ' + charArray[i]);
		}


		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - scoreText.width, 0).makeGraphic(Std.int(FlxG.width * 0.35), 192, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.alignment = CENTER;
		diffText.font = scoreText.font;
		diffText.x = scoreBG.getGraphicMidpoint().x;
		add(diffText);

		add(scoreText);

		charText = new FlxText(scoreBG.getGraphicMidpoint().x - 65, scoreText.y + 66, 0, charArray[curCharacter], 24);
		charText.setFormat(Paths.font("vcr.ttf"), 24, CoolUtil.getDominantIconColour(charArray[curCharacter]), CENTER);
		add(charText);

		charIcon = new HealthIcon(charArray[curCharacter]);
		charIcon.flipX = true;
		charIcon.scale.x = 0.75;
		charIcon.scale.y = 0.75;
		charIcon.updateHitbox();
		charIcon.x = scoreBG.getGraphicMidpoint().x;
		charIcon.y = charText.y + 24;
		add(charIcon);

		changeChar();
		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, songColor:FlxColor, bpm:Float)
	{
		///*
		var coolDifficultyArray = [];
		for (i in CoolUtil.difficultyArray)
			if (FileSystem.exists(Paths.songJson(songName, songName + '-' + i))
				|| (FileSystem.exists(Paths.songJson(songName, songName)) && i == "NORMAL"))
				coolDifficultyArray.push(i);

		if (coolDifficultyArray.length > 0)
		{ //*/
			songs.push(new SongMetadata(songName, weekNum, songCharacter, songColor, bpm));
			existingDifficulties.push(coolDifficultyArray);
		}
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>, ?songColor:Array<FlxColor>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];
		if (songColor == null)
			songColor = [FlxColor.WHITE];

		var num:Array<Int> = [0, 0];
		for (song in songs)
		{

			var beeps = CoolUtil.getSongMeta(song, "bpm");

			addSong(song, weekNum, songCharacters[num[0]], songColor[num[1]], beeps);

			if (songCharacters.length != 1)
				num[0]++;
			if (songColor.length != 1)
				num[1]++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxTween.color(bg, 0.35, bg.color, mainColor);
			

		//cam bumping wooooo!!!
		//okay listen i know the cam bumps twice sometimes.
		//no, i don't know why.
		//the conductor scares me.
		//i'm not touching it.
		if (camCooldown && bgCam.zoom > 1)
		{
			var easeLerp = 0.95;
			bgCam.zoom = FlxMath.lerp(defaultCamZoom, bgCam.zoom, easeLerp);
		}
		if (bgCam.zoom < 1.05)
			camCooldown = false;

		//trace('bgCam.zoom = ' + bgCam.zoom);
		//trace('camCooldown = ' + camCooldown);

		var lerpVal = Main.framerateAdjust(0.1);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, lerpVal));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		else if (downP)
			changeSelection(1);

		if (controls.UI_LEFT_P && !FlxG.keys.pressed.SHIFT)
			changeDiff(-1);
		if (controls.UI_RIGHT_P && !FlxG.keys.pressed.SHIFT)
			changeDiff(1);

		if (controls.UI_LEFT_P && FlxG.keys.pressed.SHIFT)
			changeChar(-1);
		if (controls.UI_RIGHT_P && FlxG.keys.pressed.SHIFT)
			changeChar(1);

		if (controls.BACK)
		{
			threadActive = false;
			Main.switchState(this, new MainMenuState());
		}

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(),
				CoolUtil.difficultyArray.indexOf(existingDifficulties[curSelected][curDifficulty]));

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.isRaidMode = false;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.freeplayChar = charArray[curCharacter];

			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);

			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();

			threadActive = false;

			Main.switchState(this, new PlayState());
		}

		// Adhere the position of all the things (I'm sorry it was just so ugly before I had to fix it Shubs)
		scoreText.text = "PERSONAL BEST:" + lerpScore;
		scoreText.x = FlxG.width - scoreText.width - 5;
		scoreBG.width = scoreText.width + 8;
		scoreBG.x = FlxG.width - scoreBG.width;
		diffText.x = scoreBG.x + (scoreBG.width / 2) - (diffText.width / 2);
		charText.x = scoreBG.x + (scoreBG.width / 2) - (charText.width / 2);
		charIcon.x = scoreBG.x + (scoreBG.width / 2) - (charIcon.width / 2);

		mutex.acquire();
		if (songToPlay != null)
		{
			FlxG.sound.playMusic(songToPlay);

			

			if (FlxG.sound.music.fadeTween != null)
				FlxG.sound.music.fadeTween.cancel();

			FlxG.sound.music.volume = 0.0;
			FlxG.sound.music.fadeIn(1.0, 0.0, 1.0);

			songToPlay = null;
		}
		mutex.release();

		Conductor.songPosition = FlxG.sound.music.time;
		//trace("music time: " + FlxG.sound.music.time);
		//trace("conductor time: " + Conductor.songPosition);
		musicBeatShit();
	}

	override function beatHit()
	{
		//super.beatHit();

		if (!camCooldown)
		{
			bgCam.zoom = defaultCamZoom + 0.1;
			camCooldown = true;
		}
		//trace("cam bumped!");
	}

	var lastDifficulty:String;

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;
		if (lastDifficulty != null && change != 0)
			while (existingDifficulties[curSelected][curDifficulty] == lastDifficulty)
				curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = existingDifficulties[curSelected].length - 1;
		if (curDifficulty > existingDifficulties[curSelected].length - 1)
			curDifficulty = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);

		diffText.text = '< ' + existingDifficulties[curSelected][curDifficulty] + ' >';
		lastDifficulty = existingDifficulties[curSelected][curDifficulty];
	}

	function changeChar(change:Int = 0)
	{
		curCharacter += change;
		if (curCharacter < 0)
			curCharacter = charArray.length;
		if (curCharacter > charArray.length - 1)
			curCharacter = 0;

		trace('curCharacter int: ' + curCharacter);
		trace('curCharacter string: ' + charArray[curCharacter]);
		trace('charArray length: ' + charArray.length);
		trace('charArray[curCharacter] length: ' + charArray[curCharacter].length);
		charIcon.updateIcon(charArray[curCharacter]);
		charText.text = '< ' + CoolUtil.getFullName(charArray[curCharacter]) + ' >';
		charText.color = CoolUtil.getDominantIconColour(charArray[curCharacter]);

		
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);

		// set up color stuffs
		mainColor = songs[curSelected].songColor;

		// song switching stuffs

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		//

		//trace("curSelected: " + curSelected);
		//trace("cur bpm: " + songs[curSelected].bpm);

		changeDiff();
		changeSongPlaying();
	}

	function changeSongPlaying()
	{
		if (songThread == null)
		{
			songThread = Thread.create(function()
			{
				while (true)
				{
					if (!threadActive)
					{
						trace("Killing thread");
						return;
					}

					var index:Null<Int> = Thread.readMessage(false);
					if (index != null)
					{
						if (index == curSelected && index != curSongPlaying)
						{
							trace("Loading index " + index);

							var inst:Sound = Paths.inst(songs[curSelected].songName);

							Conductor.changeBPM(songs[curSelected].bpm);

							if (index == curSelected && threadActive) //bpm shit here
							{
								mutex.acquire();
								songToPlay = inst;
								mutex.release();

								curSongPlaying = curSelected;
							}
							else
								trace("Nevermind, skipping " + index);
						}
						else
							trace("Skipping " + index);
					}
				}
			});
		}

		songThread.sendMessage(curSelected);
	}

	var playingSongs:Array<FlxSound> = [];

	//okay so i can't figure out how to get MusicBeatSubState to work
	//so instead i'm just gonna rip out the code which makes StepHits and BeatHits work and put it here
	//would much prefer to have it just use MusicBeatSubstate but i'm fucking retarded soooooo

	public function musicBeatShit()
	{
		//should be called on update!!!
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);

		if (oldStep != curStep && curStep > 0)
			stepHit();
	}

	override function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	override public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
		//trace('stepHit!');
	}
}



class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var songColor:FlxColor = FlxColor.WHITE;
	public var bpm:Float = 0.0;

	public function new(song:String, week:Int, songCharacter:String, songColor:FlxColor, bpm:Float)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.songColor = songColor;
		this.bpm = bpm;
	}
}
