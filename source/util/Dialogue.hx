package util;

import flixel.sound.FlxSound;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.FlxObject;
import sys.io.File;
import haxe.Json;
import flixel.FlxSubState;

typedef Dialogues = {
    dialogueText:String,
    timePerChar:Float,
    character:FlxObject
}

typedef DialogueMap = {
    dID:String,
    char:FlxObject
}

class Dialogue extends FlxSubState {
    var list = Json.parse(File.getContent("assets/data/dialogue.json"));
    var queue:Array<Dialogues> = [];
    
    var spr:FlxObject = null;
    var timer:FlxTimer = new FlxTimer();
    var textSpr:FlxText = null;
    var sprArray:Array<FlxSprite> = [];
    var speak:FlxSound = FlxG.sound.load("assets/sounds/speak.ogg");

    var dialogueText:String = "";
    var done:Bool = false;
    var timePerChar:Float = 0;

    public function new(dialogueID:Array<DialogueMap>) {
        var dial:Array<Dynamic> = list.dialogueList;
        queue = [];

        for (dID in dial) {
            for (dialID in dialogueID) {
                if (dID.dialogueID == dialID.dID) {
                    queue.push({
                        dialogueText: dID.text,
                        timePerChar: dID.timePerChar,
                        character: dialID.char
                    });
                }
            }
        }

        if (queue.length == 0) {
            throw 'Couldn\'t find dialogue IDs: $dialogueID';
        }

        spr = queue[0].character;

        super(0);
    }
    
    override function create() {
        final l:Int = 256;
        final pos:Float = spr.x - 50;
        sprArray = [];
        
        var s:FlxSprite = new FlxSprite().makeGraphic(l, 82, 0xFFFFFFFF);
        s.x = pos - 60;
        s.y = spr.y - 90;
        sprArray.push(s);
        add(sprArray[0]);

        s = new FlxSprite().makeGraphic(l + 20, 60, 0xFFFFFFFF);
        s.x = pos - 70;
        s.y = spr.y - 80;
        sprArray.push(s);
        add(sprArray[1]);

        s = new FlxSprite().makeGraphic(l - 8, 72, 0xFF000000);
        s.x = pos - 56;
        s.y = spr.y - 85;
        sprArray.push(s);
        add(sprArray[2]);

        final x = s.x + 2;
        final y = s.y + 1;

        s = new FlxSprite().makeGraphic(l + 12, 52, 0xFF000000);
        s.x = pos - 66;
        s.y = spr.y - 76;
        sprArray.push(s);
        add(sprArray[3]);

        textSpr = new FlxText(x, y, l - 8, "").setFormat("assets/fonts/main.ttf", 18);
        add(textSpr);

        newDialogue();
        
        super.create();
    }

    function newDialogue() {
        var ind:Int = -1;

        done = false;
        textSpr.text = "";

        dialogueText = queue[0].dialogueText;
        timePerChar  = queue[0].timePerChar;

        spr = queue[0].character;

        var i:Int = 0;
        final xy:Array<Array<Int>> = [[60, 90], [70, 80], [56, 85], [66, 76]];
        final pos:Float = spr.x - 60;
        for (spry in sprArray) {
            spry.x = pos   - xy[i][0];
            spry.y = spr.y - xy[i][1];
            i++;
        }

        timer.start(timePerChar, e -> {
            ind++;
            textSpr.text += dialogueText.charAt(ind);

            speak.pitch = FlxG.random.float(0.75, 1.25);
            speak.play(true);

            if (e.loopsLeft == 0) {
                done = true;
            }
        }, dialogueText.length);

        queue.shift();
    }

    override function update(elapsed:Float) {
        if (FlxG.keys.justPressed.ANY) {
            if (done) {
                if (queue.length == 0) {
                    close();
                } else {
                    newDialogue();
                }
            } else {
                timer.cancel();
                textSpr.text = dialogueText;
                done = true;
            }
        }

        super.update(elapsed);
    }
}