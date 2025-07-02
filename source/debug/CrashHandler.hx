package debug;

import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import haxe.CallStack;
import openfl.Lib;
import openfl.errors.Error;
import openfl.events.ErrorEvent;
import openfl.events.UncaughtErrorEvent;

using StringTools;

class CrashHandler {
	public static function init():Void {
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
		untyped __global__.__hxcpp_set_critical_error_handler(onError);
	}

	private static function onUncaughtError(e:UncaughtErrorEvent):Void {
		try {
			e.preventDefault();
			e.stopPropagation();
			e.stopImmediatePropagation();
	
			var m:String = e.error;
			if (Std.isOfType(e.error, Error)) {
				var err = cast(e.error, Error);
				m = '${err.message}';
			} else if (Std.isOfType(e.error, ErrorEvent)) {
				var err = cast(e.error, ErrorEvent);
				m = '${err.text}';
			}
			final stack = CallStack.exceptionStack();
			final stackLabelArr:Array<String> = [];
			var stackLabel:String = "";
			// legacy code below for the messages
			var path:String;
			var dateNow:String = Date.now().toString();
			dateNow = dateNow.replace(" ", "_");
			dateNow = dateNow.replace(":", "'");
	
			path = 'crash/LuApps_$dateNow.log';
	
			for(stackItem in stack) {
				switch(stackItem) {
					case CFunction: stackLabelArr.push("Non-Haxe (C) Function");
					case Module(c): stackLabelArr.push('Module ${c}');
					case FilePos(parent, file, line, col):
						switch(parent) {
							case Method(cla, func): stackLabelArr.push('${file.replace('.hx', '')}.$func() [line $line]');
							case _: stackLabelArr.push('${file.replace('.hx', '')} [line $line]');
						}
					case LocalFunction(v): stackLabelArr.push('Local Function ${v}');
					case Method(cl, m): stackLabelArr.push('${cl} - ${m}');
				}
			}
			stackLabel = stackLabelArr.join('\r\n');
	
			var errorMessage:String = "";
			errorMessage += 'Uncaught Error: $m\n$stackLabel';
			trace(errorMessage);
	
			try {
				if (!FileSystem.exists("crash/")) FileSystem.createDirectory("crash/");
				File.saveContent(path, errorMessage + "\n");
			} catch(e) trace('Couldn\'t save error message. (${e.message})');
	
			Sys.println(errorMessage);
			Sys.println('Crash dump saved in ${Path.normalize(path)}');
		} catch(e:Dynamic) trace(e);
	}

    private static function onError(message:Dynamic):Void throw Std.string(message);
}