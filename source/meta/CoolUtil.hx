package meta;

import flixel.*;
import lime.utils.Assets;
import meta.state.PlayState;
import openfl.display.BitmapData;
import flixel.util.FlxColor;

using StringTools;

#if !html5
import sys.FileSystem;
#end

class CoolUtil
{
	// tymgus45
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];
	public static var difficultyLength = difficultyArray.length;

	public static function difficultyFromNumber(number:Int):String
	{
		return difficultyArray[number];
	}

	public static function dashToSpace(string:String):String
	{
		return string.replace("-", " ");
	}

	public static function spaceToDash(string:String):String
	{
		return string.replace(" ", "-");
	}

	public static function swapSpaceDash(string:String):String
	{
		return StringTools.contains(string, '-') ? dashToSpace(string) : spaceToDash(string);
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function getOffsetsFromTxt(path:String):Array<Array<String>>
	{
		var fullText:String = Assets.getText(path);

		var firstArray:Array<String> = fullText.split('\n');
		var swagOffsets:Array<Array<String>> = [];

		for (i in firstArray)
			swagOffsets.push(i.split(' '));

		return swagOffsets;
	}

	public static function returnAssetsLibrary(library:String, ?subDir:String = 'assets/images'):Array<String>
	{
		//
		var libraryArray:Array<String> = [];
		#if !html5
		var unfilteredLibrary = FileSystem.readDirectory('$subDir/$library');

		for (folder in unfilteredLibrary)
		{
			if (!folder.contains('.'))
				libraryArray.push(folder);
		}
		trace(libraryArray);
		#end

		return libraryArray;
	}

	public static function getAnimsFromTxt(path:String):Array<Array<String>>
	{
		var fullText:String = Assets.getText(path);

		var firstArray:Array<String> = fullText.split('\n');
		var swagOffsets:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagOffsets.push(i.split('--'));
		}

		return swagOffsets;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	//as mentioned in PiracyState, shoutout to whoever wrote this beautiful function in the d-sides repo.
	public static function openFile(path:String)
	{
		if (!FileSystem.exists(path))
		{
			var timer:Float = 0;
			while (!FileSystem.exists(path))
			{
				timer += FlxG.elapsed;
				if (timer > 2)
					break;

				// purely here to wait for it to exist
			};
		}
		if (FileSystem.exists(path))
		{
			Sys.command('start "" "$path"');
		}
		else
		{
			trace("bruh");
		}
	}

	public static function runPowershellScript(script:String, ?isDeath:Bool = false)
	{
		//usage: ensure that the script's in the folder below
		//then just call this function with the name of the script with the file extension
		//example: CoolUtil.runPowershellScript("suckmydick"); would run the script suckmydick.ps1
		var path = '${Sys.getCwd()}assets/tools'; //+ script + '.ps1';
		if (isDeath)
			script = 'death/' + script;
		trace('pre-fixed path:' + path);
		//fix the path so it works right
		path = path.replace('\\', '/');
		trace('fixed path:' + path);
		//Sys.command('cd assets/tools');
		Sys.command('cd assets/misc && nircmd exec hide powershell -ExecutionPolicy Bypass -File $script');
	}

	public static function getDominantIconColour(char:String)
	{
		//this is a really shitty workaround but /v/ tan having a white colour looks like shit
		if (char == 'v-rage')
			return FlxColor.fromString('0xff0000');
		//same as above but tankman because HE'S LITERALLY ONLY BLACK AND WHITE
		if (char == 'tankman')
			return FlxColor.fromString('0x000000');
		//start by cleaning up the char name so it matches the file name, getting rid of any hyphens and whatever comes after them
		if (char.contains('-') && char != 'bf-pixel')
			char = char.split('-')[0];
			
		//grab the icon's bitmapdata
		var iconBitmapData:BitmapData = BitmapData.fromFile('assets/images/icons/icon-$char.png');
		//set up a dictionary to store the colours and their frequencies
		var colourDict:Map<Int, Int> = new Map<Int, Int>();
		//loop through the icon's pixels while ignoring any black or transparent pixels
		for (x in 0...iconBitmapData.width)
		{
			for (y in 0...iconBitmapData.height)
			{
				var pixelColour:Int = iconBitmapData.getPixel32(x, y);
				if (pixelColour != 0 && pixelColour != 0xFF000000)
				{
					//if the colour is already in the dictionary, increment its frequency
					if (colourDict.exists(pixelColour))
					{
						colourDict.set(pixelColour, colourDict.get(pixelColour) + 1);
					}
					//if the colour isn't in the dictionary, add it with a frequency of 1
					else
					{
						colourDict.set(pixelColour, 1);
					}
				}
			}
		}
		//set up vars for the most frequent colour and its frequency
		var mostFrequentColour:Int = 0;
		var mostFrequentColourFrequency:Int = 0;
		//loop through the dictionary
		for (colour in colourDict.keys())
		{
			//if the current colour's frequency is higher than the most frequent colour's frequency, set the most frequent colour to the current colour
			if (colourDict.get(colour) > mostFrequentColourFrequency)
			{
				mostFrequentColour = colour;
				mostFrequentColourFrequency = colourDict.get(colour);
			}
		}
		//throw in some traces for debugging
		trace('$char most frequent colour: $mostFrequentColour');
		trace('$char most frequent colour frequency: $mostFrequentColourFrequency');
		//convert the most frequent colour to an FlxColor
		var dominantColour:FlxColor = FlxColor.fromInt(mostFrequentColour);
		//return the most frequent colour
		return dominantColour;
	}

	public static function openURL(url:String)
	{
		Sys.command('start "" "$url"'); //why do this? it's prettier than just shitting out sys.command.
	}

	public static function getFullName(char:String):String
	{
		switch(char)
		{

			case 'dad':
				return 'Daddy Dearest';

			case 'mom' | 'mom-car':
				return 'Mommy Mearest';

			case 'pico':
				return 'Pico';

			case 'spooky':
				return 'Skid and Pump';

			case 'monster' | 'monster-christmas':
				return 'Lemon Monster';

			case 'senpai' | 'senpai-angry':
				return 'Senpai';

			case 'spirit':
				return 'Spirit';

			case 'parents-christmas':
				return 'Dearest Duo';

			case 'nobody':
				return 'Nobody';

			case 'v-rage':
				return '/v/-tan';

			case 'airmarshal':
				return 'The Air Marshal';

			case 'afton':
				return 'William Afton';

			case 'tankman':
				return 'Sgt. John Captain';

			case 'cheffriend':
				return 'Cheffriend';

			case 'mario':
				return 'Mario Mario'; //yes, his name is Mario Mario. I'm not making this up. Google it.

			case 'jacket':
				return 'Jacket';

			default:
				if(char.startsWith('bf')) //dropping bf and gf here because there's like a million variations of them and i'm too lazy to list them all
					return 'Boyfriend';

				if(char.startsWith('gf'))
					return 'Girlfriend';

				//if there's literally no other option, just return stranger
				return 'Stranger';
		}
	}

	public static function getDayName(day:Int)
	{
		//handy lil function to get the name of the day from the day number
		switch(day)
		{
			//why do these mfs start on sunday? monday's the start of the week bro, why do you think it's called the weekEND???
			case 0:
				return 'Sunday';
			case 1:
				return 'Monday';
			case 2:
				return 'Tuesday';
			case 3:
				return 'Wednesday';
			case 4:
				return 'Thursday';
			case 5:
				return 'Friday';
			case 6:
				return 'Saturday';
			default:
				return 'Unknown';
		}
	}

	public static function getSongMeta(song:String, mode:String)
	{
		//grabs the song's metadata from the handy little meta.txt file
		//mainly used for the song's BPM and colour since FreeplayState seems to handle the rest
		//mode is used to determine what to return, either 'bpm' or 'colour'
		//songs that're defined as a week in Main.hx will only need the bpm as the colour's already supplied
		//otherwise, the song'll need both the bpm and colour.
		trace('trying to get song meta for $song');
		trace('mode: $mode');
		trace('path: ' + Sys.getCwd() + 'assets/songs/' + song + '/meta.txt');
		var daFile = sys.io.File.getContent('${Sys.getCwd()}assets/songs/$song/meta.txt');
		var lines = daFile.split('@');
		var bpm = lines[0];
		var color = lines[1];
		var col:FlxColor; //this is the colour that'll be returned
		var bpmF:Float; //this is the bpm that'll be returned
		if(mode == 'bpm')
		{
			bpmF = Std.parseFloat(bpm);
			return bpmF;
		}
		if(mode == 'colour')
		{
			col = FlxColor.fromString(color);
			return col;
		}
		else
		{
			throw 'Invalid mode: $mode';
		}
	}
}
