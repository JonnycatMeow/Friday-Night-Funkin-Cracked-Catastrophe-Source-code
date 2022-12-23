package meta.data;

import flixel.util.FlxSave;
//this is where all the various flags for story mode are stored, along with some other stuff
//HOW TO USE:
//declare a new global instance of this class in whatever the fuck you want
//the new function will take care of loading the save file, so you don't gotta load it yourself
//in order to set or change any flags, simply directly access the variable you want to change
//and don't forget to save the file after you're done with saveFlags()!!!
//here's an example:
//class whatever extends i don't care
//var flagvar:Flags = new Flags();
//function doSomeWackShit()
//flagvar.testFlag = true;
//flagvar.saveFlags();
//done!
//if you want to add a new flag, just add a new variable to the class and add it to all the functions

class Flags
{
    public var flagData:FlxSave = new FlxSave();
    public var hasBeatSongOne:Bool = false; //enabled after beating song one, enables funklock, disabled after beating song 3
    public var funkLockEnabled:Bool = false; //used in titleState to determine where to send the player
    public var hasBeatStory:Bool = false; //unlocks bonus songs
    public var hasBeatAllSongs:Bool = false; //unlocks drive link to FLPs & FLAs
    public var testFlag:Bool = false; //used for testing if shit works or not
    public var hasClearedSongOne:Bool = false; //used to determine if the player has cleared the song's score requirement
    public var hasClearedAllRaids:Bool = false; //used to determine if the player has cleared all the regular raids
    public var hasClearedCarpenter:Bool = false; //used to determine if the player has cleared the carpenter raid
    public var hasClearedBHC:Bool = false; //used to determine if the player has cleared the Broken Heart Corrosion raid
    public var hasClearedSegFault:Bool = false; //used to determine if the player has cleared the SegFault raid
    public var mostRecentVersion:Float = 1.0; //a backup var i should've implemented long ago for retroactive updates/rewards for playing previous versions

    public function new()
    {
        //load the flags lol
        loadFlags();

        //do a quick check to see if we need to update hasClearedAllRaids
        if(!hasClearedAllRaids && hasClearedCarpenter && hasClearedBHC && hasClearedSegFault)
        {
            hasClearedAllRaids = true;
            saveFlags();
        }
    }

    public function saveFlags()
    {
        //make sure to call this function whenever a flag is changed!!!!
        flagData.bind("flagData");
        flagData.data.hasBeatSongOne = hasBeatSongOne;
        flagData.data.funkLockEnabled = funkLockEnabled;
        flagData.data.hasBeatStory = hasBeatStory;
        flagData.data.hasBeatAllSongs = hasBeatAllSongs;
        flagData.data.testFlag = testFlag;
        flagData.data.hasClearedSongOne = hasClearedSongOne;
        flagData.data.hasClearedAllRaids = hasClearedAllRaids;
        flagData.data.hasClearedCarpenter = hasClearedCarpenter;
        flagData.data.hasClearedBHC = hasClearedBHC;
        flagData.data.hasClearedSegFault = hasClearedSegFault;
        flagData.data.mostRecentVersion = mostRecentVersion;
        flagData.flush();
    }

    public function loadFlags()
    {
        //make sure to call this function as soon as it's possible to load flags!!!!
        //hopefully this should only need to be called once
        //otherwise, idk lol
        flagData.bind("flagData");
        hasBeatSongOne = flagData.data.hasBeatSongOne;
        funkLockEnabled = flagData.data.funkLockEnabled;
        hasBeatStory = flagData.data.hasBeatStory;
        hasBeatAllSongs = flagData.data.hasBeatAllSongs;
        testFlag = flagData.data.testFlag;
        hasClearedSongOne = flagData.data.hasClearedSongOne;
        hasClearedAllRaids = flagData.data.hasClearedAllRaids;
        hasClearedCarpenter = flagData.data.hasClearedCarpenter;
        hasClearedBHC = flagData.data.hasClearedBHC;
        hasClearedSegFault = flagData.data.hasClearedSegFault;
        mostRecentVersion = flagData.data.mostRecentVersion;
    }

    public function resetFlags()
    {
        //resets all flags to their default values lol
        hasBeatSongOne = false;
        funkLockEnabled = false;
        hasBeatStory = false;
        hasBeatAllSongs = false;
        testFlag = false;
        hasClearedSongOne = false;
        hasClearedAllRaids = false;
        hasClearedCarpenter = false;
        hasClearedBHC = false;
        hasClearedSegFault = false;
        //mostRecentVersion = 1.0; //don't reset this one
        saveFlags();
    }

    public function checkFlags()
    {
        //this is for testing purposes only
        //it prints all the flags to the console
        trace("hasBeatSongOne: " + hasBeatSongOne);
        trace("funkLockEnabled: " + funkLockEnabled);
        trace("hasBeatStory: " + hasBeatStory);
        trace("hasBeatAllSongs: " + hasBeatAllSongs);
        trace("testFlag: " + testFlag);
        trace("hasClearedSongOne: " + hasClearedSongOne);
        trace("hasClearedAllRaids: " + hasClearedAllRaids);
        trace("hasClearedCarpenter: " + hasClearedCarpenter);
        trace("hasClearedBHC: " + hasClearedBHC);
        trace("hasClearedSegFault: " + hasClearedSegFault);
        trace("mostRecentVersion: " + mostRecentVersion);
    }

    public function unlockAllSongs()
    {
        //this is for testing purposes only
        //it unlocks all songs
        hasBeatSongOne = true;
        funkLockEnabled = false;
        hasBeatStory = true;
        hasBeatAllSongs = true;
        testFlag = true;
        hasClearedSongOne = true;
        hasClearedAllRaids = true;
        hasClearedCarpenter = true;
        hasClearedBHC = true;
        hasClearedSegFault = true;
        saveFlags();
    }
}