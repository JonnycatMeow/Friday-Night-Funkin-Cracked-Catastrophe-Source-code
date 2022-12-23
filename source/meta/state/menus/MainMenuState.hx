package meta.state.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import meta.MusicBeat.MusicBeatState;
import meta.data.dependency.Discord;
import meta.data.Flags;
import meta.data.Highscore;
import meta.data.*;
import meta.data.Song.SwagSong;
import meta.state.PlayState;
import meta.state.TitleState;
import meta.state.menus.RaidState;

using StringTools;

/**
	This is the main menu state! Not a lot is going to change about it so it'll remain similar to the original, but I do want to condense some code and such.
	Get as expressive as you can with this, create your own menu!
**/
class MainMenuState extends MusicBeatState
{
	var menuItems:FlxTypedGroup<FlxSprite>;
	var curSelected:Float = 0;

	var bg:FlxSprite; // the background has been separated for more control
	var magenta:FlxSprite;
	var camFollow:FlxObject;

	var optionShit:Array<String> = ['story mode', 'freeplay', 'options'];
	var canSnap:Array<Float> = [];

	var flagvar:Flags;

	var raidMenu:FlxSprite;
	var raidSelected:Bool = false;
	

	// the create 'state'
	override function create()
	{
		super.create();

		//load up them flags
		flagvar = new Flags();

		// set the transitions to the previously set ones
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		// make sure the music is playing
		ForeverTools.resetMenuMusic();

		#if !html5
		Discord.changePresence('MENU SCREEN', 'Main Menu');
		#end

		// uh
		persistentUpdate = persistentDraw = true;

		// background
		bg = new FlxSprite(-85);
		bg.loadGraphic(Paths.image('menus/base/menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		magenta = new FlxSprite(-85).loadGraphic(Paths.image('menus/base/menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);

		// add the camera
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		// add the menu items
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		// create the menu items themselves
		var tex = Paths.getSparrowAtlas('menus/base/title/FNF_main_menu_assets');

		// loop through the menu options
		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 80 + (i * 200));
			menuItem.frames = tex;
			// add the animations in a cool way (real
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			canSnap[i] = -1;
			// set the id
			menuItem.ID = i;
			// menuItem.alpha = 0;

			// placements
			menuItem.screenCenter(X);
			// if the id is divisible by 2
			if (menuItem.ID % 2 == 0)
				menuItem.x += 1000;
			else
				menuItem.x -= 1000;

			// actually add the item
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			menuItem.updateHitbox();

			/*
				FlxTween.tween(menuItem, {alpha: 1, x: ((FlxG.width / 2) - (menuItem.width / 2))}, 0.35, {
					ease: FlxEase.smootherStepInOut,
					onComplete: function(tween:FlxTween)
					{
						canSnap[i] = 0;
					}
			});*/
		}

		//set up the raid menu button
		if (flagvar.hasBeatStory)
		{
			var tex2 = Paths.getSparrowAtlas('menus/base/title/raidButtons');
			raidMenu = new FlxSprite(0, 0);
			raidMenu.frames = tex2;
			raidMenu.animation.addByPrefix('selected', 'RAID UNSEL', 24);
			raidMenu.animation.addByPrefix('idle', 'RAID SEL', 24);
			raidMenu.animation.play('idle');
			raidMenu.antialiasing = false;
			raidMenu.x = -10;
			raidMenu.screenCenter(Y);
			raidMenu.scrollFactor.set(1, 1);
			raidMenu.antialiasing = true;
			add(raidMenu);
		}
		
		

		// set the camera to actually follow the camera object that was created before
		var camLerp = Main.framerateAdjust(0.10);
		FlxG.camera.follow(camFollow, null, camLerp);

		updateSelection();

		// from the base game lol

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "Forever Engine v" + Main.gameVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		//
	}

	// var colorTest:Float = 0;
	var selectedSomethin:Bool = false;
	var counterControl:Float = 0;

	override function update(elapsed:Float)
	{
		// colorTest += 0.125;
		// bg.color = FlxColor.fromHSB(colorTest, 100, 100, 0.5);

		var up = controls.UI_UP;
		var down = controls.UI_DOWN;
		var up_p = controls.UI_UP_P;
		var down_p = controls.UI_DOWN_P;
		var controlArray:Array<Bool> = [up, down, up_p, down_p];

		if (FlxG.keys.justPressed.THREE) /*&& flagvar.hasBeatStory == true)*/
		{
			Main.switchState(this, new ResetState());
		}

		if(FlxG.keys.justPressed.SIX)
		{
			Main.switchState(this, new BypassState());
		}

		#if debug
		if (FlxG.keys.justPressed.ONE)
		{
			//time to figure out how Highscore works

			//if (!flagvar.hasClearedAllRaids && flagvar.mostRecentVersion == 1.0)
			//{
				trace("potentially a 1.0 chad, checking for raids...");
				if (Highscore.getScore("Carpenter", 1) != 0)
				{
					trace("carpenter score exists, clearing...");
					//flagVar.hasClearedCarpenter = true;
				}
				if (Highscore.getScore("Broken-Heart-Corrosion", 1) != 0)
				{
					trace("broken heart score exists, clearing...");
					//flagVar.hasClearedBHC = true;
				}
				if (Highscore.getScore("Seg Fault", 1) != 0)
				{
					trace("seg fault score exists, clearing...");
					//flagVar.hasClearedSegFault = true;
				}
				if (flagvar.hasClearedCarpenter && flagvar.hasClearedBHC && flagvar.hasClearedSegFault)
				{
					trace("all raids cleared, setting flag...");
					//flagVar.hasClearedAllRaids = true;
				}
			//}

			/*trace("let's see if carpenter exists...");
			if (Highscore.songScores.exists('carpenter0'))
			{
				trace("carpenter exists, looking for score now...");
				trace("carpenter easy: ");
				trace(Highscore.getScore('carpenter', 0));
				trace("carpenter normal:");
				trace(Highscore.getScore('carpenter', 1));
			}*/
		}

		if (FlxG.keys.justPressed.TWO)
		{
			trace("checking flags!");
			flagvar.checkFlags();
		}

		if (FlxG.keys.justPressed.FOUR)
		{
			flagvar.unlockAllSongs();
			trace("Unlocked all songs!");
			flagvar.checkFlags();
		}

		if(FlxG.keys.justPressed.FIVE)
		{
			flagvar.hasClearedCarpenter = false;
			flagvar.hasClearedBHC = false;
			flagvar.hasClearedSegFault = false;
			flagvar.hasClearedAllRaids = false;
			flagvar.saveFlags();
			trace("reset raid flags");
		}

		if(FlxG.keys.justPressed.SEVEN)
		{
			Main.switchState(this, new PiracyState());
		}

		if (FlxG.keys.justPressed.EIGHT)
		{
			var poop:String = Highscore.formatSong('overflow', 1);

			trace("congrats you did it");

			PlayState.SONG = Song.loadFromJson(poop, 'overflow');
			PlayState.isStoryMode = true;
			PlayState.storyDifficulty = 1;
			PlayState.storyWeek = 3;
			Main.switchState(this, new PlayState());
			//FlxG.save.data.disclaimer = null;
			//trace("disclaimer flag reset");
		}

		if(FlxG.keys.justPressed.NINE)
		{
			Main.switchState(this, new RaidState());
		}
		#end

		if (flagvar.hasBeatStory && (!selectedSomethin))
		{
			if (curSelected == 1 && controls.UI_LEFT_P && !raidSelected)
			{
				//select the raid menu button
				raidSelected = true;
				raidMenu.animation.play('selected');
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
	
			if (raidSelected && controls.UI_RIGHT_P)
			{
				//deselect the raid menu button
				raidSelected = false;
				raidMenu.animation.play('idle');
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
	
			if (raidSelected && FlxG.keys.justPressed.ENTER)
			{
				selectedSomethin = true;
				//go to the raid menu
				//check if shift is held down
				if (FlxG.keys.pressed.SHIFT)
					RaidState.raidDebug = true;
				else
					RaidState.raidDebug = false;

				FlxG.sound.play(Paths.sound('confirmMenu'));

				menuItems.forEach(function(spr:FlxSprite)
					{
						FlxTween.tween(spr, {alpha: 0, x: FlxG.width * 2}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					});

				FlxFlicker.flicker(magenta, 0.8, 0.1, false);

				FlxFlicker.flicker(raidMenu, 1, 0.06, false, false, function(flick:FlxFlicker)
				{
					Main.switchState(this, new RaidState());
				});
			}
		}
		

		if ((controlArray.contains(true)) && (!selectedSomethin) && (!raidSelected))
		{
			for (i in 0...controlArray.length)
			{
				// here we check which keys are pressed
				if (controlArray[i] == true)
				{
					// if single press
					if (i > 1)
					{
						// up is 2 and down is 3
						// paaaaaiiiiiiinnnnn
						if (i == 2)
							curSelected--;
						else if (i == 3)
							curSelected++;

						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
					/* idk something about it isn't working yet I'll rewrite it later
						else
						{
							// paaaaaaaiiiiiiiinnnn
							var curDir:Int = 0;
							if (i == 0)
								curDir = -1;
							else if (i == 1)
								curDir = 1;

							if (counterControl < 2)
								counterControl += 0.05;

							if (counterControl >= 1)
							{
								curSelected += (curDir * (counterControl / 24));
								if (curSelected % 1 == 0)
									FlxG.sound.play(Paths.sound('scrollMenu'));
							}
					}*/

					if (curSelected < 0)
						curSelected = optionShit.length - 1;
					else if (curSelected >= optionShit.length)
						curSelected = 0;
				}
				//
			}
		}
		else
		{
			// reset variables
			counterControl = 0;
		}

		if ((controls.ACCEPT) && (!selectedSomethin) && (!raidSelected))
		{
			//
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));

			FlxFlicker.flicker(magenta, 0.8, 0.1, false);

			menuItems.forEach(function(spr:FlxSprite)
			{
				if (curSelected != spr.ID)
				{
					FlxTween.tween(spr, {alpha: 0, x: FlxG.width * 2}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				}
				else
				{
					if (flagvar.hasBeatStory)
					{
						FlxTween.tween(raidMenu, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								raidMenu.kill();
							}
						});
					}
					

					FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						var daChoice:String = optionShit[Math.floor(curSelected)];

						switch (daChoice)
						{
							case 'story mode':
								//Main.switchState(this, new StoryMenuState());
								var poop:String = Highscore.formatSong('bopeebo', 2);

								trace("bootin' up story mode!");

								PlayState.SONG = Song.loadFromJson(poop, 'bopeebo');
								PlayState.isStoryMode = true;
								PlayState.isRaidMode = false;
								PlayState.storyDifficulty = 2;
								PlayState.storyWeek = 1;

								//hehehe
								Main.switchState(this, new PlayState());
							case 'freeplay':
								//throw in a quick check to see if they've finished the main story yet
								if (flagvar.hasBeatStory == false)
								{
									FlxG.sound.play(Paths.sound('no'));
									FlxG.camera.shake(0.02, 0.2);
									Main.switchState(this, new MainMenuState());
								}
								else
								{
									transIn = FlxTransitionableState.defaultTransIn;
									transOut = FlxTransitionableState.defaultTransOut;
									Main.switchState(this, new FreeplayState());
								}	
							case 'options':
								transIn = FlxTransitionableState.defaultTransIn;
								transOut = FlxTransitionableState.defaultTransOut;
								Main.switchState(this, new OptionsMenuState());
						}
					});
				}
			});
		}

		if (Math.floor(curSelected) != lastCurSelected)
			updateSelection();

		super.update(elapsed);

		menuItems.forEach(function(menuItem:FlxSprite)
		{
			menuItem.screenCenter(X);
		});
	}

	var lastCurSelected:Int = 0;

	private function updateSelection()
	{
		// reset all selections
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();
		});

		// set the sprites and all of the current selection
		camFollow.setPosition(menuItems.members[Math.floor(curSelected)].getGraphicMidpoint().x,
			menuItems.members[Math.floor(curSelected)].getGraphicMidpoint().y);

		if (menuItems.members[Math.floor(curSelected)].animation.curAnim.name == 'idle')
			menuItems.members[Math.floor(curSelected)].animation.play('selected');

		menuItems.members[Math.floor(curSelected)].updateHitbox();

		lastCurSelected = Math.floor(curSelected);
	}
}
