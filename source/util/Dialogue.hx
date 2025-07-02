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
        var l:Int = 128;

        s = new FlxSprite().makeGraphic(l, 80, 0xFFFFFFFF);
        add(s);

        s = new FlxSprite().makeGraphic(l + 20, 60, 0xFFFFFFFF);
        add(s);

        s = new FlxSprite().makeGraphic(l - 8, 72, 0xFF000000);
        add(s);

        s = new FlxSprite().makeGraphic(l + 12, 52, 0xFF000000);
        add(s);
        
        trace(dialogueText);
        super.create();
    }
}