package util;

import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.FlxObject;
import sys.io.File;
import haxe.Json;
import flixel.FlxSubState;

class Dialogue extends FlxSubState {
    var list = Json.parse(File.getContent("assets/data/dialogue.json"));
    
    var spr:FlxObject = null;
    var timer:FlxTimer = new FlxTimer();
    var textSpr:FlxText = null;

    var dialogueText:String = "";
    var done:Bool = false;
    var timePerChar:Float = 0;

    public function new(dialogueID:String, sprite:FlxObject) {
        done = false;

        var dial:Array<Dynamic> = list.dialogueList;

        dialogueText = "";
        for (dID in dial) {
            if (dID.dialogueID == dialogueID) {
                dialogueText = dID.text;
                timePerChar = dID.timePerChar;
                break;
            }
        }

        if (dialogueText == "") {
            throw 'Couldn\'t find dialogue ID: $dialogueID';
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

        var ind:Int = -1;
        timer.start(timePerChar, e -> {
            ind++;
            textSpr.text += dialogueText.charAt(ind);

            if (e.loopsLeft == 0) {
                done = true;
            }
        }, dialogueText.length);
        
        super.create();
    }

    override function update(elapsed:Float) {
        if (FlxG.keys.justPressed.ANY) {
            if (done) {
                close();
            } else {
                timer.cancel();
                textSpr.text = dialogueText;
            }
        }

        super.update(elapsed);
    }
}