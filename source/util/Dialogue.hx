package util;

import flixel.FlxObject;
import sys.io.File;
import haxe.Json;
import flixel.FlxSubState;

class Dialogue extends FlxSubState {
    var dialogueText:String = "";
    var spr:FlxObject = null;

    public function new(dialogueID:String, sprite:FlxObject) {
        var list = Json.parse(File.getContent("assets/data/dialogue.json"));
        var dial:Array<Dynamic> = list.dialogueList;

        dialogueText = "";
        for (dID in dial) {
            if (dID.dialogueID == dialogueID) {
                dialogueText = dID.text;
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
        var e = new FlxSprite().makeGraphic(999, 999, 0xFF666666);
        add(e);

        var s:FlxSprite = null;
        for (i in 0...2) {
            final color:Int = i == 0 ? 0xFF000000 : 0xFFFFFFFF;
            final newX:Int = 4 * i;

            s = new FlxSprite(-104 + spr.x - newX, -94 + spr.y + newX).makeGraphic(208 - (newX * 2), 80 + (newX * 2), color);
            add(s);

            s = new FlxSprite(-108 + spr.x - newX, -80 + spr.y + newX).makeGraphic(216 - (newX * 2), 72 + (newX * 2), color);
            add(s);

            s = new FlxSprite(-32 + spr.x - newX, -80 + spr.y + newX).makeGraphic(64 - (newX * 2), 64 + (newX * 2), color);
            add(s);
        }
        
        trace(dialogueText);
        super.create();
    }
}