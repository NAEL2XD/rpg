package util;

import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.FlxObject;
import sys.io.File;
import haxe.Json;
import flixel.FlxSubState;

typedef Dialogues = {
    dialogueText:String,
    timePerChar:Float
}

class Dialogue extends FlxSubState {
    var list = Json.parse(File.getContent("assets/data/dialogue.json"));
    var queue:Array<Dialogues> = [];
    
    var spr:FlxObject = null;
    var timer:FlxTimer = new FlxTimer();
    var textSpr:FlxText = null;

    var dialogueText:String = "";
    var done:Bool = false;
    var timePerChar:Float = 0;

    public function new(dialogueID:Array<String>, sprite:FlxObject) {
        done = false;

        var dial:Array<Dynamic> = list.dialogueList;
        queue = [];

        for (dID in dial) {
            for (dialID in dialogueID) {
                if (dID.dialogueID == dialID) {
                    var d:Dialogues = {
                        dialogueText: dID.text,
                        timePerChar: dID.timePerChar
                    };
                    queue.push(d);
                }
            }
        }

        if (queue.length == 0) {
            throw 'Couldn\'t find dialogue IDs: $dialogueID';
        }

        spr = sprite;
        super(0);
    }

    override function create() {
        var s:FlxSprite = null;
        final l:Int = 256;
        final pos:Float = spr.x - 50;

        s = new FlxSprite().makeGraphic(l, 82, 0xFFFFFFFF);
        s.x = pos - 60;
        s.y = spr.y - 90;
        add(s);

        s = new FlxSprite().makeGraphic(l + 20, 60, 0xFFFFFFFF);
        s.x = pos - 70;
        s.y = spr.y - 80;
        add(s);

        s = new FlxSprite().makeGraphic(l - 8, 72, 0xFF000000);
        s.x = pos - 56;
        s.y = spr.y - 85;
        add(s);

        final x = s.x + 4;
        final y = s.y + 4;

        s = new FlxSprite().makeGraphic(l + 12, 52, 0xFF000000);
        s.x = pos - 66;
        s.y = spr.y - 76;
        add(s);

        textSpr = new FlxText(x, y, l - 4, "").setFormat("assets/fonts/main.ttf", 18);
        add(textSpr);

        newDialogue();
        
        super.create();
    }

    function newDialogue() {
        var ind:Int = -1;

        textSpr.text = "";

        dialogueText = queue[0].dialogueText;
        timePerChar  = queue[0].timePerChar;

        timer.start(timePerChar, e -> {
            ind++;
            textSpr.text += dialogueText.charAt(ind);

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