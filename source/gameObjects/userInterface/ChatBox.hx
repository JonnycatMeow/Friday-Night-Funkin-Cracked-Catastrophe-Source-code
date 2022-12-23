package gameObjects.userInterface;

import flixel.text.FlxText;
import meta.RaidUtil;
import meta.state.PlayState;
import flixel.FlxSprite;
import flixel.FlxG;

using StringTools;

class ChatBox
{
    public var boxBG:FlxSprite = PlayState.chatBoxBG;
    public var boxText:FlxText = PlayState.chatBoxText;
    public var idleMessages:Array<String>;
    public var fcLossMessages:Array<String>;
    public var comboBreakMessages:Array<String>;
    public var damageMessages:Array<String>;
    public var greentextFormat:FlxTextFormat;
    public var greentextMarker:FlxTextFormatMarkerPair;
    public var chattingPlayers:Array<String> = [];
    public var sentMessages:Array<String> = [];

    //TODO:
    //actually set up the chat box - done
    //greentext support - done
    //situational chat responses: FC loss, combo break, etc - done
    //probably more stuff
    //refactor the text pipeline to keep greentext by having messages and players be in separate arrays, and then have a function that combines them into a single string - done
    //have PlayState push messages and players to sentMessages and chattingPlayers respectively, then combine them into a single string and display it in the chat box - done
    //also clear both arrays when the chat's faded out - done

    //notes:
    //17 lines of text fit in the chat box

    public function new()
    {
        //alrighty, let's get everything set up

        //let's start off by grabbing all the messages
        var textDoc:String = sys.io.File.getContent(('${Sys.getCwd()}assets/misc/raidChatIdle.txt')); //grab the idle messages
        idleMessages = textDoc.split('/'); //split them up by the delimiter
        textDoc = sys.io.File.getContent(('${Sys.getCwd()}assets/misc/raidChatFcLoss.txt')); //grab the FC loss messages
        fcLossMessages = textDoc.split('/'); //split them up by the delimiter
        textDoc = sys.io.File.getContent(('${Sys.getCwd()}assets/misc/raidChatComboBreak.txt')); //grab the combo break messages
        comboBreakMessages = textDoc.split('/'); //split them up by the delimiter, delimiter's kind of a cool word in my opinion
        textDoc = sys.io.File.getContent(('${Sys.getCwd()}assets/misc/raidChatDamage.txt')); //grab the damage messages
        damageMessages = textDoc.split('/'); //split them up by the delimiter

        #if debug
        trace(idleMessages);
        trace(fcLossMessages);
        trace(comboBreakMessages);
        #end

        //set up the greentext formatting
        greentextFormat = new FlxTextFormat(0x789922);
        greentextMarker = new FlxTextFormatMarkerPair(greentextFormat, "[greentext]");

        //chatbox setup here
        //the chatbox background's gonna be our foundation here, so we'll make a rectangle.
        #if debug
        trace('ChatBox initialized!');
        #end

    }

    public function update()
    {
        boxBG = PlayState.chatBoxBG;
        boxText = PlayState.chatBoxText;
    }

    public function getIdleMessage()
    {
        //pick a random message from the idleMessages array
        var message:String = idleMessages[FlxG.random.int(0, idleMessages.length - 1)];
        return message;
    }

    public function getFcLossMessage()
    {
        //pick a random message from the fcLossMessages array
        var message:String = fcLossMessages[FlxG.random.int(0, fcLossMessages.length - 1)];
        return message;
    }

    public function getComboBreakMessage()
    {
        //pick a random message from the comboBreakMessages array
        var message:String = comboBreakMessages[FlxG.random.int(0, comboBreakMessages.length - 1)];
        return message;
    }

    public function getDamageMessage()
    {
        //pick a random message from the damageMessages array
        var message:String = damageMessages[FlxG.random.int(0, damageMessages.length - 1)];
        return message;
    }

    public function addMessage(message:String, player:String)
    {
        //add a message to the chatbox string
        //this is probably a terrible way of doing this but i don't want to be fucked with making seperate text objects for each message
        //here's how it works:
        //grab the current chatbox text
        //grab the input message
        //format the input message by adding a player name and a colon
        //add the input message to the current chatbox text with a newline
        //set the chatbox text to the new chatbox text
        //profit? i guess?

        //new way of doing this so greentext formatting stays intact:
        //add the message and player to their respective arrays
        //each time this function is called, refresh the chatbox text by readding the arrays and combining them into a single string
        var newText:String = message;
        var newPlayer:String = player;
        var textToShow:String = '';

        this.chattingPlayers.push(player);
        this.sentMessages.push(newText);

        for (i in 0...sentMessages.length)
        {
            if (sentMessages[i].startsWith('>'))
            {
                sentMessages[i] = '[greentext]' + sentMessages[i] + '[greentext]';
            }

            if (sentMessages[i].contains('%song%'))
            {
                sentMessages[i] = sentMessages[i].replace('%song%', PlayState.SONG.song);
            }

            if (sentMessages[i].contains('%player%'))
            {
                sentMessages[i] = sentMessages[i].replace('%player%', chattingPlayers[i]);
            }

            textToShow += '[' + chattingPlayers[i] + ']: ' + sentMessages[i] + '\n';
        }

        #if debug
        trace('addMessage called!');
        trace('newText: ' + newText);
        trace('player: ' + newPlayer);
        trace('chattingPlayers.length: ' + chattingPlayers.length);
        trace('sentMessages.length: ' + sentMessages.length);
        #end

        //check for greentext
        /*if (newText.startsWith('>'))
        {
            //greentext detected
            newText = '[greentext]' + newText + '[greentext]';
        }



        //format the message
        newText = '[$player]:' + newText;

        //add the message to the current text
        currentText = currentText + '\n' + newText; */

        //set the chatbox text to the new text
        PlayState.chatBoxText.text = textToShow;

        //apply the greentext formatting
        PlayState.chatBoxText.applyMarkup(textToShow, [greentextMarker]);


        //all done!

    }

    public function clear()
    {
        //clean up the chatbox

        //run through chattingPlayers and clear it
        for (i in 0...chattingPlayers.length)
        {
            chattingPlayers.pop();
        }

        //run through sentMessages and clear it
        for (i in 0...sentMessages.length)
        {
            sentMessages.pop();
        }

        //set the chatbox text to nothing
        PlayState.chatBoxText.text = '';
    }
}