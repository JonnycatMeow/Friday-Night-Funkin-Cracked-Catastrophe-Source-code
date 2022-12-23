package meta;

import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import meta.state.PlayState;

//big fucking list of todos:
//TODO: set up a way to get a randomised spread of damage values that sum up to the boss's health minus the score requirement - DONE
//TODO: set up a function to damage the boss using one of the above damage values and a player from the freshPlayers array - DONE
//TODO: cont. and then remove that player from the freshPlayers array and push it to the UsedPlayers array - DONE
//TODO: set up a chat function for funny messages if i can be fucked to do so - DONE, CHECK ChatBox.hx in gameObjects/userInterface


class RaidUtil
{
    //this class is mainly used for different functions in raid mode such as:
    //boss damage from other players
    //chat messages if i remember to add them
    //handling of player lists, moving around who has done damage, who hasn't, etc

    //THIS SHOULD ONLY BE CALLED IF RAID MODE IS ACTIVE AND AFTER THE CORRECT VALUES HAVE BEEN SET!!!!!!

    public var freshPlayers:Array<String> = [];
    public var usedPlayers:Array<String> = [];
    public var totalDamageRequired:Int = 5000000; //pull 0 from the scoreRequired variable in PlayState
    public var damageSlots:Int = PlayState.raidBossDamageSlots; //this is how many times the NPC players can damage the boss
    public var damageValues:Array<Int> = []; //this is the array that holds the damage values for each player
    public var usedDamageValues:Array<Int> = []; //this is the array that holds the damage values that have been used
    public var lastPlayer:String = ""; //we keep track of the last player to chat so we don't use them twice in a row

    public function new()
    {
        #if debug
        trace('New RaidUtil created, hello!');
        #end
        //let's start by setting everything up
        //we need to grab the player list and put it into the freshPlayers array to start with
        var playerDoc = sys.io.File.getContent(('${Sys.getCwd()}assets/misc/raidPlayers.txt'));
        var tempPlayerArray = playerDoc.split(',');
        for (player in tempPlayerArray)
        {
            freshPlayers.push(player);
        }
        #if debug
        for (player in freshPlayers)
        {
            trace('freshPlayers array: ' + player);
        }
        #end

        //now let's grab the total damage required
        totalDamageRequired -= PlayState.raidBossScoreReq;

        //now let's generate the damage values
        damageValues = calculateRandomDamageValues();

        #if debug
        for (value in damageValues)
        {
            trace('damageValues array: ' + Std.string(value));
        }
        #end


        

    }

    public function calculateRandomDamageValues()
    {
        //maths makes me cry
        //also i need a place to figure out how to do this
        //so we start off with the total damage required and the number of damage slots
        //in order to get the damage values, we need to get a random number which is randomised between 45% and 90% of the total damage required divided by the number of damage slots
        //we then need to get a second random number which is randomised between 10% and 55% of the total damage required divided by the number of damage slots
        //we then push both of these numbers to the damageValues array
        //after that, we need to check if the sum of the damage values is equal to the total damage required
        //if it is, we're done
        //if it isn't, we just slap the difference between the two onto a random damage value already in the array
        //and then we're done

        var tempDamage:Int = 0; //holds the first randomised damage value of the damage pair
        var tempDamage2:Int = 0; //holds the second randomised damage value of the damage pair
        var tempDamageArray:Array<Int> = []; //holds the all the damage values
        var damageTarget:Int = Math.round(totalDamageRequired / damageSlots); //this is the target damage value that each damage pair needs to add up to
        var tempDamageMultiplier:Float = 0; //this is what we multiply the first randomised damage value by
        var tempDamageRemainder:Float = 0; //this is what we multiply the second randomised damage value by
        var random:FlxRandom = new FlxRandom(); //do i need to explain this?

        for (i in 0...Math.round(damageSlots / 2)) //only get half of the damage slots so the NPCs don't do double the target lol!
        {
            //also we multiply the damage by 2 to compensate for the fact that we're only using half of the damage slots
            tempDamageMultiplier = random.float(0.45, 0.9); //get a random float between 0.45 and 0.9
            tempDamage = Math.round(tempDamageMultiplier * damageTarget) * 2; //multiply the damage target by the random float and round it
            tempDamageRemainder = 1 - tempDamageMultiplier; //get the remainder of the random float
            tempDamage2 = Math.round(tempDamageRemainder * damageTarget) * 2; //multiply the damage target by the remainder and round it
            tempDamageArray.push(tempDamage); //push the first damage value to the array
            tempDamageArray.push(tempDamage2); //push the second damage value to the array
        }

        //now, let's check if everything adds up to the total damage required
        var tempDamageTotal:Int = 0;
        for (i in 0...tempDamageArray.length)
        {
            tempDamageTotal += tempDamageArray[i];
        }

        if (tempDamageTotal != totalDamageRequired)
        {
            #if debug
            trace('DAMAGE VALUES BE FUCKED UP, FIXING NOW');
            trace('tempDamageTotal: ' + Std.string(tempDamageTotal));
            trace('totalDamageRequired: ' + Std.string(totalDamageRequired));
            #end
            //if the total damage doesn't add up, we need to add or subtract a random amount from one of the damage values
            var tempDamageIndex:Int = Math.floor(Math.random() * tempDamageArray.length); //get a random index from the tempDamageArray
            var tempDamageDifference:Int = totalDamageRequired - tempDamageTotal; //get the difference between the total damage required and the total damage
            tempDamageArray[tempDamageIndex] += tempDamageDifference; //add the difference to the random damage value
            
            
        }

        //also throw in a trace here to make sure it's working
        #if debug
        trace('damage values: ' + tempDamageArray);
        #end

        //now let's return the array
        return tempDamageArray;

    }

    public function getFreshPlayer()
    {
        //nice and simple, just get a random player from the freshPlayers array
        //mainly used for when we need to damage the boss

        //first, let's check if there are any players left in the freshPlayers array
        if (freshPlayers.length == 0)
        {
            //if there aren't, we need to reset the freshPlayers array
            freshPlayers = usedPlayers;
            usedPlayers = [];
        }

        //now let's get a random player from the freshPlayers array
        var randomPlayer = freshPlayers[Math.floor(Math.random() * freshPlayers.length)];

        //now let's remove the player from the freshPlayers array and add them to the usedPlayers array
        freshPlayers.remove(randomPlayer);
        usedPlayers.push(randomPlayer);

        //now let's return the player
        return randomPlayer;
    }

    public function getDamageValue()
    {
        //this function is used to get a random damage value from the damageValues array
        //mainly used for when we need to damage the boss

        //first, let's check if there are any damage values left in the damageValues array
        if (damageValues.length == 0)
        {
            //if there aren't, we need to reset the damageValues array
            damageValues = usedDamageValues;
        }

        //now let's get a random damage value from the damageValues array
        var randomDamageValue = damageValues[Math.floor(Math.random() * damageValues.length)];

        //now let's remove the damage value from the damageValues array
        damageValues.remove(randomDamageValue);
        usedDamageValues.push(randomDamageValue);

        //now let's return the damage value
        return randomDamageValue;

    }

    public function getPlayer()
    {
        //this is like getFreshPlayer, but it doesn't care if the player has already been used!
        //this is accomplished by grabbing a random player from both the freshPlayers and usedPlayers arrays
        //and then deciding which one to use based on a random number
        //this way, it's weighted towards used players more, giving the player a better sense of immersion
        //why? because they finished their part of the raid, so they're spectating your attempt!
        //this is mainly used for chatbox messages and stuff

        var randomFreshPlayer = freshPlayers[Math.floor(Math.random() * freshPlayers.length)];
        var randomUsedPlayer;
        var randomNum;

        while (lastPlayer == randomFreshPlayer)
        {
            #if debug
            trace('fresh player is the same as last player, getting a new one');
            #end

            randomFreshPlayer = freshPlayers[Math.floor(Math.random() * freshPlayers.length)];
        }
        //but before we get a used player, we need to check if there are any in the first place
        //if there aren't, we can just return the fresh player
        if (usedPlayers.length > 0)
        {
            randomUsedPlayer = usedPlayers[Math.floor(Math.random() * usedPlayers.length)];

            //make sure the used player isn't the same as last time
            while (lastPlayer == randomUsedPlayer && usedPlayers.length > 1) //also make sure to check only if there's more than 1 used player
            {
                #if debug
                trace('used player is the same as last time, getting a new one');
                #end

                randomUsedPlayer = usedPlayers[Math.floor(Math.random() * usedPlayers.length)];
            }

            randomNum = Math.fround(Math.random()); //get a random float between 0 and 1, and then round it. This is basically a coin flip, but it's weighted towards 1
            if (randomNum == 0)
            {
                lastPlayer = randomFreshPlayer;
                return randomFreshPlayer;
            }
            else
            {
                lastPlayer = randomUsedPlayer;
                return randomUsedPlayer;
            }

        }
        else
        {
            lastPlayer = randomFreshPlayer;
            return randomFreshPlayer;
        }


        
    }
}