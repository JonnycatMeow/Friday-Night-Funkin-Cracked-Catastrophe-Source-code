package gameObjects;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.tweens.misc.ColorTween;
import gameObjects.background.*;
import meta.CoolUtil;
import meta.data.Conductor;
import meta.data.dependency.FNFSprite;
import meta.state.PlayState;
//funny transparency window hehe
#if windows 
import meta.WindowsUtil;
#end
//shader shit
import meta.shaders.SynthwaveShader;

using StringTools;

/**
	This is the stage class. It sets up everything you need for stages in a more organised and clean manner than the
	base game. It's not too bad, just very crowded. I'll be adding stages as a separate
	thing to the weeks, making them not hardcoded to the songs.
**/
class Stage extends FlxTypedGroup<FlxBasic>
{
	var halloweenBG:FNFSprite;
	var phillyCityLights:FlxTypedGroup<FNFSprite>;
	var phillyTrain:FNFSprite;
	var trainSound:FlxSound;

	public var limo:FNFSprite;

	public var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;

	var fastCar:FNFSprite;

	var upperBoppers:FNFSprite;
	var bottomBoppers:FNFSprite;
	var santa:FNFSprite;


	//overflow stage assets
	var ovfbg:FNFSprite; //stage bg for overflow
	var ovfstagefront:FNFSprite; //stage front for overflow
	var ovfcurtains:FNFSprite; //stage curtains for overflow
	var sdr:FlxSprite; //synthwave shader for overflow
	var mtx:FlxSprite; //matrix shader for overflow
	var ovfdesktop:FNFSprite; //desktop bg for overflow

	//dbdos stage assets
	public var dbdsky:FNFSprite; //sky for dbdos
	public var dbdbglimo:FNFSprite; //bg limo for dbdos
	public var dbdpowerlinesback:FNFSprite; //powerlines back for dbdos
	public var dbdtrain:FNFSprite; //train for dbdos
	public var dbdpowerlinesfront:FNFSprite; //powerlines front for dbdos
	public var dbdlimo:FNFSprite; //limo for dbdos
	public var dbdtrainBump:Bool; //enable/disable train bumping to the beat
	public var dbdtrainTweenAlphaIn:FlxTween;
	public var dbdtrainTweenColorIn:FlxTween; 

	//senpai/spirit boss raid stage assets
	var bhcBg:FNFSprite; //spooky school bg
	var bhcSky:FNFSprite; //regular school bg
	var bhcSchool:FNFSprite; //school bg
	var bhcStreet:FNFSprite; //street bg
	var bhcTreesFront:FNFSprite; //trees front bg
	var bhcTrees:FNFSprite; //trees bg
	var bhcTreesLeaves:FNFSprite; //trees leaves bg
	var isEvil:Bool; //used to reposition characters for switches between the school types

	//nobody raid stage assets
	var sfsdr:FlxSprite; //synthwave shader for nobody
	var sfstageBack:FNFSprite; //stage back for nobody
	var sfstageFront:FNFSprite; //stage front for nobody
	var sfstageMid:FNFSprite; //swaps out with sfstageFront after nobody gets big
	var sfstageCurtains:FNFSprite; //stage curtains for nobody

	var bgGirls:BackgroundGirls;

	public var curStage:String;

	var daPixelZoom = PlayState.daPixelZoom;

	public var foreground:FlxTypedGroup<FlxBasic>;

	public var midground:FlxTypedGroup<FlxBasic>; //used for dbdos since there's stuffs in between nobody and bf

	public function new(curStage)
	{
		super();
		this.curStage = curStage;

		/// get hardcoded stage type if chart is fnf style
		if (PlayState.determinedChartType == "FNF")
		{
			// this is because I want to avoid editing the fnf chart type
			// custom stage stuffs will come with forever charts
			switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
			{
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'highway';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				case 'overflow':
					curStage = 'overflowStage';
				case 'dbdos':
					curStage = 'dbdos';
				case 'seg-fault':
					curStage = 'nobodyRaid';
				case 'broken-heart-corrosion':
					curStage = 'spiritRaid';
				case 'carpenter':
					curStage = 'jacketRaid';
				default:
					curStage = 'stage';
			}

			PlayState.curStage = curStage;
		}

		// to apply to foreground use foreground.add(); instead of add();
		foreground = new FlxTypedGroup<FlxBasic>();

		// to apply to midground use midground.add(); instead of add();
		midground = new FlxTypedGroup<FlxBasic>();

		//
		switch (curStage)
		{
			case 'spooky':
				curStage = 'spooky';
				// halloweenLevel = true;

				var hallowTex = Paths.getSparrowAtlas('backgrounds/' + curStage + '/halloween_bg');

				halloweenBG = new FNFSprite(-200, -100);
				halloweenBG.frames = hallowTex;
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = true;
				add(halloweenBG);

			// isHalloween = true;
			case 'philly':
				curStage = 'philly';

				var bg:FNFSprite = new FNFSprite(-100).loadGraphic(Paths.image('backgrounds/' + curStage + '/sky'));
				bg.scrollFactor.set(0.1, 0.1);
				add(bg);

				var city:FNFSprite = new FNFSprite(-10).loadGraphic(Paths.image('backgrounds/' + curStage + '/city'));
				city.scrollFactor.set(0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyCityLights = new FlxTypedGroup<FNFSprite>();
				add(phillyCityLights);

				for (i in 0...5)
				{
					var light:FNFSprite = new FNFSprite(city.x).loadGraphic(Paths.image('backgrounds/' + curStage + '/win' + i));
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = true;
					phillyCityLights.add(light);
				}

				var streetBehind:FNFSprite = new FNFSprite(-40, 50).loadGraphic(Paths.image('backgrounds/' + curStage + '/behindTrain'));
				add(streetBehind);

				phillyTrain = new FNFSprite(2000, 360).loadGraphic(Paths.image('backgrounds/' + curStage + '/train'));
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				// var cityLights:FNFSprite = new FNFSprite().loadGraphic(AssetPaths.win0.png);

				var street:FNFSprite = new FNFSprite(-40, streetBehind.y).loadGraphic(Paths.image('backgrounds/' + curStage + '/street'));
				add(street);
			case 'highway':
				curStage = 'highway';
				PlayState.defaultCamZoom = 0.90;

				var skyBG:FNFSprite = new FNFSprite(-120, -50).loadGraphic(Paths.image('backgrounds/' + curStage + '/limoSunset'));
				skyBG.scrollFactor.set(0.1, 0.1);
				add(skyBG);

				var bgLimo:FNFSprite = new FNFSprite(-200, 480);
				bgLimo.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/bgLimo');
				bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
				bgLimo.animation.play('drive');
				bgLimo.scrollFactor.set(0.4, 0.4);
				add(bgLimo);

				grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
				add(grpLimoDancers);

				for (i in 0...5)
				{
					var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
					dancer.scrollFactor.set(0.4, 0.4);
					grpLimoDancers.add(dancer);
				}

				var overlayShit:FNFSprite = new FNFSprite(-500, -600).loadGraphic(Paths.image('backgrounds/' + curStage + '/limoOverlay'));
				overlayShit.alpha = 0.5;
				// add(overlayShit);

				// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

				// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

				// overlayShit.shader = shaderBullshit;

				var limoTex = Paths.getSparrowAtlas('backgrounds/' + curStage + '/limoDrive');

				limo = new FNFSprite(-120, 550);
				limo.frames = limoTex;
				limo.animation.addByPrefix('drive', "Limo stage", 24);
				limo.animation.play('drive');
				limo.antialiasing = true;

				fastCar = new FNFSprite(-300, 160).loadGraphic(Paths.image('backgrounds/' + curStage + '/fastCarLol'));
			// loadArray.add(limo);
			case 'mall':
				curStage = 'mall';
				PlayState.defaultCamZoom = 0.80;

				var bg:FNFSprite = new FNFSprite(-1000, -500).loadGraphic(Paths.image('backgrounds/' + curStage + '/bgWalls'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				upperBoppers = new FNFSprite(-240, -90);
				upperBoppers.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/upperBop');
				upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
				upperBoppers.antialiasing = true;
				upperBoppers.scrollFactor.set(0.33, 0.33);
				upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
				upperBoppers.updateHitbox();
				add(upperBoppers);

				var bgEscalator:FNFSprite = new FNFSprite(-1100, -600).loadGraphic(Paths.image('backgrounds/' + curStage + '/bgEscalator'));
				bgEscalator.antialiasing = true;
				bgEscalator.scrollFactor.set(0.3, 0.3);
				bgEscalator.active = false;
				bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
				bgEscalator.updateHitbox();
				add(bgEscalator);

				var tree:FNFSprite = new FNFSprite(370, -250).loadGraphic(Paths.image('backgrounds/' + curStage + '/christmasTree'));
				tree.antialiasing = true;
				tree.scrollFactor.set(0.40, 0.40);
				add(tree);

				bottomBoppers = new FNFSprite(-300, 140);
				bottomBoppers.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/bottomBop');
				bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
				bottomBoppers.antialiasing = true;
				bottomBoppers.scrollFactor.set(0.9, 0.9);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:FNFSprite = new FNFSprite(-600, 700).loadGraphic(Paths.image('backgrounds/' + curStage + '/fgSnow'));
				fgSnow.active = false;
				fgSnow.antialiasing = true;
				add(fgSnow);

				santa = new FNFSprite(-840, 150);
				santa.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/santa');
				santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
				santa.antialiasing = true;
				add(santa);
			case 'mallEvil':
				curStage = 'mallEvil';
				var bg:FNFSprite = new FNFSprite(-400, -500).loadGraphic(Paths.image('backgrounds/mall/evilBG'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:FNFSprite = new FNFSprite(300, -300).loadGraphic(Paths.image('backgrounds/mall/evilTree'));
				evilTree.antialiasing = true;
				evilTree.scrollFactor.set(0.2, 0.2);
				add(evilTree);

				var evilSnow:FNFSprite = new FNFSprite(-200, 700).loadGraphic(Paths.image("backgrounds/mall/evilSnow"));
				evilSnow.antialiasing = true;
				add(evilSnow);
			case 'school':
				curStage = 'school';

				// defaultCamZoom = 0.9;

				var bgSky = new FNFSprite().loadGraphic(Paths.image('backgrounds/' + curStage + '/weebSky'));
				bgSky.scrollFactor.set(0.1, 0.1);
				add(bgSky);

				var repositionShit = -200;

				var bgSchool:FNFSprite = new FNFSprite(repositionShit, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/weebSchool'));
				bgSchool.scrollFactor.set(0.6, 0.90);
				add(bgSchool);

				var bgStreet:FNFSprite = new FNFSprite(repositionShit).loadGraphic(Paths.image('backgrounds/' + curStage + '/weebStreet'));
				bgStreet.scrollFactor.set(0.95, 0.95);
				add(bgStreet);

				var fgTrees:FNFSprite = new FNFSprite(repositionShit + 170, 130).loadGraphic(Paths.image('backgrounds/' + curStage + '/weebTreesBack'));
				fgTrees.scrollFactor.set(0.9, 0.9);
				add(fgTrees);

				var bgTrees:FNFSprite = new FNFSprite(repositionShit - 380, -800);
				var treetex = Paths.getPackerAtlas('backgrounds/' + curStage + '/weebTrees');
				bgTrees.frames = treetex;
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);

				var treeLeaves:FNFSprite = new FNFSprite(repositionShit, -40);
				treeLeaves.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/petals');
				treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
				treeLeaves.animation.play('leaves');
				treeLeaves.scrollFactor.set(0.85, 0.85);
				add(treeLeaves);

				var widShit = Std.int(bgSky.width * 6);

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));
				fgTrees.setGraphicSize(Std.int(widShit * 0.8));
				treeLeaves.setGraphicSize(widShit);

				fgTrees.updateHitbox();
				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();
				treeLeaves.updateHitbox();

				bgGirls = new BackgroundGirls(-100, 190);
				bgGirls.scrollFactor.set(0.9, 0.9);

				if (PlayState.SONG.song.toLowerCase() == 'roses')
					bgGirls.getScared();

				bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
				bgGirls.updateHitbox();
				add(bgGirls);
			case 'schoolEvil':
				var posX = 400;
				var posY = 200;
				var bg:FNFSprite = new FNFSprite(posX, posY);
				bg.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/animatedEvilSchool');
				bg.animation.addByPrefix('idle', 'background 2', 24);
				bg.animation.play('idle');
				bg.scrollFactor.set(0.8, 0.9);
				bg.scale.set(6, 6);
				add(bg);

			case 'overflowStage':
				PlayState.defaultCamZoom = 0.9;
				curStage = 'overflowStage';

				//matrix shader bg for the third verse i think i have problems
				if (Init.trueSettings.get('Shaders'))
				{
					mtx = new ShaderSprite("Matrix");
					mtx.setGraphicSize(2200);
					mtx.updateHitbox();
					mtx.screenCenter(XY);
					mtx.alpha = 0; //shhhhh
					add(mtx);
				}

				//desktop BG for windows section lul
				ovfdesktop = new FNFSprite(0, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/desktop'));
				ovfdesktop.setGraphicSize(2200);
				ovfdesktop.screenCenter(X);
				ovfdesktop.scrollFactor.set(0.9, 0.9);
				ovfdesktop.antialiasing = true;
				ovfdesktop.alpha = 0; //this is a surprise tool that will help us later
				add(ovfdesktop);

				//sneaky synthwave shader that gets nuked a bit into the song
				if (Init.trueSettings.get('Shaders'))
				{
					sdr = new ShaderSprite("Synthwave");
					sdr.setGraphicSize(2200);
					sdr.updateHitbox();
					sdr.screenCenter(XY);
					add(sdr);
				}
				
				ovfbg = new FNFSprite(-600, -200).loadGraphic(Paths.image('backgrounds/' + curStage + '/stageback'));
				ovfbg.antialiasing = true;
				ovfbg.scrollFactor.set(0.9, 0.9);
				ovfbg.active = false;

				// add to the final array
				add(ovfbg);
				trace('added overflow background');



				ovfstagefront = new FNFSprite(-650, 600).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagefront'));
				ovfstagefront.setGraphicSize(Std.int(ovfstagefront.width * 1.1));
				ovfstagefront.updateHitbox();
				ovfstagefront.antialiasing = true;
				ovfstagefront.scrollFactor.set(0.9, 0.9);
				ovfstagefront.active = false;

				// add to the final array
				add(ovfstagefront);

				ovfcurtains = new FNFSprite(-500, -300).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagecurtains'));
				ovfcurtains.setGraphicSize(Std.int(ovfcurtains.width * 0.9));
				ovfcurtains.updateHitbox();
				ovfcurtains.antialiasing = true;
				ovfcurtains.scrollFactor.set(1.3, 1.3);
				ovfcurtains.active = false;

				// add to the final array
				add(ovfcurtains);

			case 'dbdos':
				PlayState.defaultCamZoom = 0.75; //figure out the right scale for this, use gifs in art as reference
				curStage = 'dbdos';

				dbdsky = new FNFSprite(0, -350).loadGraphic(Paths.image('backgrounds/' + curStage + '/sky'));
				dbdsky.setGraphicSize(2200);
				dbdsky.screenCenter(X);
				dbdsky.scrollFactor.set(0.1, 0.1);
				add(dbdsky);

				dbdbglimo = new FNFSprite(-350, 650).loadGraphic(Paths.image('backgrounds/' + curStage + '/bglimo'));
				dbdbglimo.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/bgLimo');
				dbdbglimo.animation.addByPrefix('drive', "background limo pink", 24);
				dbdbglimo.animation.play('drive');
				add(dbdbglimo);

				//figure out a way to get nobody to spawn behind the rest of these

				dbdpowerlinesback = new FNFSprite(-1250, 200).loadGraphic(Paths.image('backgrounds/' + curStage + '/powerlinesBack'));
				dbdpowerlinesback.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/powerlinesBack');
				dbdpowerlinesback.animation.addByPrefix('scroll', "powerLinesScrollBack", 60);
				dbdpowerlinesback.animation.play('scroll');
				midground.add(dbdpowerlinesback);

				dbdtrain = new FNFSprite(2500, 350).loadGraphic(Paths.image('backgrounds/' + curStage + '/trainFunky')); //-1250's the sweet spot for the train
				dbdtrain.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/trainFunky');
				dbdtrain.animation.addByPrefix('bump', "train bump", 24, false);
				dbdtrain.setGraphicSize(0, Math.floor(dbdtrain.height * 1.5));
				dbdtrain.updateHitbox();
				midground.add(dbdtrain);

				//set up tweens for later events

				//THE FRONT PART OF THE POWERLINES SHOULD ALWAYS BE -250 OF THE BACK PART
				dbdpowerlinesfront = new FNFSprite(-1500, 200).loadGraphic(Paths.image('backgrounds/' + curStage + '/powerlinesFront'));
				dbdpowerlinesfront.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/powerlinesFront');
				dbdpowerlinesfront.animation.addByPrefix('scroll', "powerLinesScrollFront", 60);
				dbdpowerlinesfront.animation.play('scroll');
				midground.add(dbdpowerlinesfront);

				dbdlimo = new FNFSprite(-8, 650).loadGraphic(Paths.image('backgrounds/' + curStage + '/limoDrive'));
				dbdlimo.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/limoDrive');
				dbdlimo.animation.addByPrefix('drive', "Limo stage", 24);
				dbdlimo.animation.play('drive');
				add(dbdlimo);

			case 'spiritRaid':
				var posX = 400;
				var posY = 200;
				bhcBg = new FNFSprite(posX, posY);
				bhcBg.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/animatedEvilSchool');
				bhcBg.animation.addByPrefix('idle', 'background 2', 24);
				bhcBg.animation.play('idle');
				bhcBg.scrollFactor.set(0.8, 0.9);
				bhcBg.scale.set(6, 6);
				add(bhcBg);

				//oh boy

				bhcSky = new FNFSprite().loadGraphic(Paths.image('backgrounds/' + curStage + '/weebSky'));
				bhcSky.scrollFactor.set(0.1, 0.1);
				add(bhcSky);

				var repositionShit = -200;

				bhcSchool = new FNFSprite(repositionShit, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/weebSchool'));
				bhcSchool.scrollFactor.set(0.6, 0.90);
				add(bhcSchool);

				bhcStreet = new FNFSprite(repositionShit).loadGraphic(Paths.image('backgrounds/' + curStage + '/weebStreet'));
				bhcStreet.scrollFactor.set(0.95, 0.95);
				add(bhcStreet);

				bhcTreesFront = new FNFSprite(repositionShit + 170, 130).loadGraphic(Paths.image('backgrounds/' + curStage + '/weebTreesBack'));
				bhcTreesFront.scrollFactor.set(0.9, 0.9);
				add(bhcTreesFront);

				bhcTrees = new FNFSprite(repositionShit - 380, -800);
				var treetex = Paths.getPackerAtlas('backgrounds/' + curStage + '/weebTrees');
				bhcTrees.frames = treetex;
				bhcTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bhcTrees.animation.play('treeLoop');
				bhcTrees.scrollFactor.set(0.85, 0.85);
				add(bhcTrees);

				bhcTreesLeaves = new FNFSprite(repositionShit, -40);
				bhcTreesLeaves.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/petals');
				bhcTreesLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
				bhcTreesLeaves.animation.play('leaves');
				bhcTreesLeaves.scrollFactor.set(0.85, 0.85);
				add(bhcTreesLeaves);

				var widShit = Std.int(bhcSky.width * 6);

				bhcSky.setGraphicSize(widShit);
				bhcSchool.setGraphicSize(widShit);
				bhcStreet.setGraphicSize(widShit);
				bhcTrees.setGraphicSize(Std.int(widShit * 1.4));
				bhcTreesFront.setGraphicSize(Std.int(widShit * 0.8));
				bhcTreesLeaves.setGraphicSize(widShit);

				bhcTreesFront.updateHitbox();
				bhcSky.updateHitbox();
				bhcSchool.updateHitbox();
				bhcStreet.updateHitbox();
				bhcTrees.updateHitbox();
				bhcTreesLeaves.updateHitbox();

			case 'jacketRaid':
				PlayState.defaultCamZoom = 0.81;

				var bg:FNFSprite = new FNFSprite(-1137, -392).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg1'));
				bg.scrollFactor.set(0.95, 1);

				var fg:FNFSprite = new FNFSprite(-1300, 432).loadGraphic(Paths.image('backgrounds/' + curStage + '/bg0'));
				fg.scrollFactor.set(1.22, 1);

				add(bg);
				foreground.add(fg);

			case 'nobodyRaid':

				if (Init.trueSettings.get('Shaders'))
				{
					sfsdr = new ShaderSprite("Synthwave");
					sfsdr.setGraphicSize(FlxG.width * 3);
					sfsdr.screenCenter(XY);
				}
				
				sfstageBack = new FNFSprite(-600, -200).loadGraphic(Paths.image('backgrounds/' + curStage + '/stageback'));
				sfstageBack.scrollFactor.set(0.9, 0.9);

				sfstageFront = new FNFSprite(-650, 600).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagefront'));
				sfstageFront.setGraphicSize(Std.int(sfstageFront.width * 1.1));
				sfstageFront.updateHitbox();
				sfstageFront.scrollFactor.set(0.9, 0.9);

				sfstageMid = new FNFSprite(-650, 600).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagefront'));
				sfstageMid.setGraphicSize(Std.int(sfstageMid.width * 1.1));
				sfstageMid.updateHitbox();
				sfstageMid.scrollFactor.set(0.9, 0.9);
				sfstageMid.alpha = 0;

				sfstageCurtains = new FNFSprite(-500, -300).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagecurtains'));
				sfstageCurtains.setGraphicSize(Std.int(sfstageCurtains.width * 0.9));
				sfstageCurtains.updateHitbox();
				sfstageCurtains.scrollFactor.set(1.3, 1.3);

				//add everything in
				add(sfsdr);
				add(sfstageBack);
				add(sfstageFront);
				midground.add(sfstageMid);
				add(sfstageCurtains);


			default:
				PlayState.defaultCamZoom = 0.9;
				curStage = 'stage';

				//sneaky synthwave shader that gets nuked a bit into the song
				
				var bg:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('backgrounds/' + curStage + '/stageback'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;

				// add to the final array
				add(bg);
				



				var stageFront:FNFSprite = new FNFSprite(-650, 600).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;

				// add to the final array
				add(stageFront);

				var stageCurtains:FNFSprite = new FNFSprite(-500, -300).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagecurtains'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;

				// add to the final array
				add(stageCurtains);
		}
	}

	// return the girlfriend's type
	public function returnGFtype(curStage)
	{
		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'highway':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		return gfVersion;
	}

	// get the dad's position
	public function dadPosition(curStage, boyfriend:Character, dad:Character, gf:Character, camPos:FlxPoint):Void
	{
		var characterArray:Array<Character> = [dad, boyfriend];
		for (char in characterArray) {
			switch (char.curCharacter)
			{
				case 'gf':
					char.setPosition(gf.x, gf.y);
					gf.visible = false;
				/*
					if (isStoryMode)
					{
						camPos.x += 600;
						tweenCamIn();
				}*/
				/*
				case 'spirit':
					var evilTrail = new FlxTrail(char, null, 4, 24, 0.3, 0.069);
					evilTrail.changeValuesEnabled(false, false, false, false);
					add(evilTrail);
					*/
			}
		}
	}

	public function repositionPlayers(curStage, boyfriend:Character, dad:Character, gf:Character):Void
	{
		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'highway':
				boyfriend.y -= 220;
				boyfriend.x += 260;

			case 'mall':
				boyfriend.x += 200;
				dad.x -= 400;
				dad.y += 20;

			case 'mallEvil':
				boyfriend.x += 320;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				dad.x += 200;
				dad.y += 580;
				gf.x += 200;
				gf.y += 320;
			case 'schoolEvil':
				dad.x -= 150;
				dad.y += 50;
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			
			case 'dbdos':
				boyfriend.x += 350;
				boyfriend.y -= 120;
				dad.x += 200;
				dad.y -= 92;


			case 'spiritRaid':
				boyfriend.x += 200;
				boyfriend.y += 220;
				dad.x += 200;
				dad.y += 580;
				
		}
	}

	var curLight:Int = 0;
	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var startedMoving:Bool = false;

	public function stageUpdate(curBeat:Int, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		// trace('update backgrounds');
		switch (PlayState.curStage)
		{
			case 'highway':
				// trace('highway update');
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});
			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'school':
				bgGirls.dance();

			case 'philly':
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					var lastLight:FlxSprite = phillyCityLights.members[0];

					phillyCityLights.forEach(function(light:FNFSprite)
					{
						// Take note of the previous light
						if (light.visible == true)
							lastLight = light;

						light.visible = false;
					});

					// To prevent duplicate lights, iterate until you get a matching light
					while (lastLight == phillyCityLights.members[curLight])
					{
						curLight = FlxG.random.int(0, phillyCityLights.length - 1);
					}

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;

					FlxTween.tween(phillyCityLights.members[curLight], {alpha: 0}, Conductor.stepCrochet * .016);
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}

			case 'dbdos':
				if (dbdtrainBump == true)
					dbdtrain.animation.play('bump', true);
		}
	}

	public function stageUpdateConstant(elapsed:Float, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		switch (PlayState.curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos(gf);
						trainFrameTiming = 0;
					}
				}
		}
	}

	public function stageUpdateStep(curStep:Int, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		//trace('update stage step');
		switch (PlayState.curStage)
		{
			case 'overflowStage':
				switch (curStep)
				{
					case 560:
						ovfbg.destroy();
						trace('destroyed overflow background');
					case 980:
						//goodbye curtains
						trace('destroyed curtains');
						ovfcurtains.destroy();
					case 988:
						//goodbye stage
						trace('destroyed stage');
						ovfstagefront.destroy();
					case 996:
						//goodbye cool-ass synthwave shader
						trace('destroyed synthwave shader');
						if (Init.trueSettings.get('Shaders'))
							sdr.destroy();
					case 1004:
						//rip transparent window idea ;-;
						ovfdesktop.alpha = 1;

					case 1664:
						//tween ovfdesktop to 0 alpha then destroy
						FlxTween.tween(ovfdesktop, {alpha: 0}, (Conductor.crochet / 1000) * 4, {onComplete: function(tween:FlxTween)
						{
							ovfdesktop.destroy();
						}});

					case 1856:
						//enable that shmexy matrix shader
						if (Init.trueSettings.get('Shaders'))
							mtx.alpha = 1;
						
				}

				case 'dbdos':
				{
					switch (curStep)
					{
						case 688:
							//tween the train in lol
							FlxTween.tween(dbdtrain, {x: -1250}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.backOut, onComplete: function(tween:FlxTween)
							{
								dbdtrainBump = true;
							}});
						
						case 700: //i think flixel is broken, the tweens here finish instantly when on the same step that the tween above finishes on
							FlxTween.tween(dbdtrain, {alpha: 0.6}, (Conductor.stepCrochet / 1000) * 4, {onComplete: function(tween:FlxTween)
							{
								trace("alpha tween completed at step " + curStep); //should finish at 704
							}});
							

						case 768: //the train just disappears here??? what the fuck???
							FlxTween.tween(dbdtrain, {alpha: 1}, (Conductor.stepCrochet / 1000) * 4, {onComplete: function(tween:FlxTween) 
								{
									trace("alpha tween completed at step " + curStep); //should finish at 772
								}});

						case 824:
							//tween the train out lol
							dbdtrainBump = false;
							FlxTween.tween(dbdtrain, {x: -7500}, (Conductor.crochet / 1000) * 2, {ease: FlxEase.backIn});

						case 1823:
							//reset the train's position
							dbdtrain.x = 2500;

						case 1824:
							//tween the train in again lol
							FlxTween.tween(dbdtrain, {x: -1500}, (Conductor.crochet / 1000) * 2, {ease: FlxEase.backOut, onComplete: function(tween:FlxTween)
								{
									//hide nobody's sprite
									PlayState.dadOpponent.alpha = 0;
								}});

						case 1840:
							//tween the train out again lol
							FlxTween.tween(dbdtrain, {x: -7500}, (Conductor.crochet / 1000) * 2, {ease: FlxEase.backIn});
					}
				}
				
				case 'spiritRaid':
				{
					switch (curStep)
					{
						case 128:
							//hide normal school bg assets
							bhcSky.alpha = 0;
							bhcSchool.alpha = 0;
							bhcStreet.alpha = 0;
							bhcTreesFront.alpha = 0;
							bhcTrees.alpha = 0;
							bhcTreesLeaves.alpha = 0;
							isEvil = true;

						case 768:
							//show normal school bg assets
							bhcSky.alpha = 1;
							bhcSchool.alpha = 1;
							bhcStreet.alpha = 1;
							bhcTreesFront.alpha = 1;
							bhcTrees.alpha = 1;
							bhcTreesLeaves.alpha = 1;
							isEvil = false;

						case 1024:
							//hide normal school bg assets
							bhcSky.alpha = 0;
							bhcSchool.alpha = 0;
							bhcStreet.alpha = 0;
							bhcTreesFront.alpha = 0;
							bhcTrees.alpha = 0;
							bhcTreesLeaves.alpha = 0;
							isEvil = true;
					}
				}

				case 'nobodyRaid':
					if (curStep == 216)
					{
							//tween everything except stageFront and stageMid up, use exponential ease
							//also switch out stageFront and stageMid, delete stageFront after.
							FlxTween.tween(sfstageBack, {y: -5000}, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.expoOut, onComplete: function(tween:FlxTween)
							{
								sfstageBack.destroy();
							}});

							FlxTween.tween(sfstageCurtains, {y: -5000}, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.expoOut, onComplete: function(tween:FlxTween)
							{
								sfstageCurtains.destroy();
							}});
							
							sfstageMid.alpha = 1;
							sfstageFront.alpha = 0;
							sfstageFront.destroy();
					}
		}
	}

	// PHILLY STUFFS!
	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	function updateTrainPos(gf:Character):Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset(gf);
		}
	}

	function trainReset(gf:Character):Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}
}
