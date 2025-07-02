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
        final xy:Array<Array<Int>> = [[-16, -36, 100, 160], [-100, -36, 300, 100], [-38, -38, 284, 116]];
        for (i in 0...2) {
            for (pos in xy) {
                var s:FlxSprite = new FlxSprite(pos[0] + spr.x, pos[1] + spr.y).makeGraphic(pos[2], pos[3], i == 0 ? 0xFFFFFFFF : 0xFF000000);
                add(s);
            }

            for (j in 0...3) {
                xy[i][j] += 4;
                xy[i][j+2] -= 8;
            }
        }
        
        trace(dialogueText);
        super.create();
    }
}