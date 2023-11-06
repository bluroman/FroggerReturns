package;

import extension.devicelang.DeviceLanguage;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxMath;
import flixel.system.scaleModes.FillScaleMode;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import haxe.Utf8;
import lime.text.UTF8String;
import openfl.Lib;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
#if ADS
import extension.admob.Admob;
import extension.admob.AdmobEvent;
#end
#if GPG
import extension.gpg.GooglePlayGames;
#end

/**
 * ...
 * @author David Bell
 */
class MenuState extends BaseState
{
	public static inline var TEXT_SPEED:Float = 300;

	private var startLabel:FlxText;
	private var pressLabel:FlxText;

	private var _title:FlxSprite;
	private var timer:FlxTimer;
	private var _background:FlxSprite;
	var _locale:String;
	var _btnGotoRoadsLevel:FlxButton;
	var _btnGotoWaterLevel:FlxButton;
	var _btnGotoCavesLevel:FlxButton;
	var _btnGotoClassicLevel:FlxButton;

	// private var _btnLeaderboard:FlxButton; // button to go to main menu

	override public function create():Void
	{
		var lang:String = DeviceLanguage.getLang();
		trace("Device Language Detected: " + lang);
		switch (lang)
		{
			case "ko": // ko-KR
				_locale = "ko-KR";
			case "en": // en-US
				_locale = "en-US";
			case "ja": // ja-JP
				_locale = "ja-JP";
			case "es": // es-ES
				_locale = "es-ES";
			case "fr": // fr-FR
				_locale = "fr-FR";
			default: // otherwise
				_locale = "en-US";
		}
		if (Main.tongue == null)
		{
			Main.tongue = new FireTongueEx();
			Main.tongue.initialize({locale: _locale});
			FlxUIState.static_tongue = Main.tongue;
		}

		super.create();
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			FlxG.sound.music.stop();
		// if (FlxG.sound.music == null) // don't restart the music if it's alredy playing
		// {
		FlxG.sound.playMusic("Menu", 1, true);
		// }
		#if FLX_MOUSE
		FlxG.mouse.visible = true;
		#end
		FlxG.scaleMode = new FillScaleMode();
		#if GPG
		GooglePlayGames.onGetPlayerScore = playerScoreCallback; // Work with Int data type.
		GooglePlayGames.onLoginResult = loginCallback;
		GooglePlayGames.init(false);
		#end

		#if ADS
		Admob.status.addEventListener(AdmobEvent.INIT_OK, onInitOk);
		Admob.init();
		// Admob.status.addEventListener(AdmobEvent.CONSENT_FAIL, onConsentFail); //to be later
		// Admob.showPrivacyOptionsForm();
		#end
		FlxG.state.bgColor = FlxColor.BROWN;

		_background = new FlxSprite(0, 80);
		_background.loadGraphic("assets/images/arcade_froggy2.png");
		add(_background);

		timer = new FlxTimer().start(1.0, myCallback, 1);

		_title = new FlxSprite(0, -200);
		_title.loadGraphic("assets/images/frogger_title.png");
		_title.x = (FlxG.width * .5) - (_title.width * .5);
		_title.moves = true;
		_title.velocity.y = TEXT_SPEED;
		add(_title);

		_btnGotoRoadsLevel = new FlxButton(0, 0, Main.tongue.get("$LEVEL_ROADS", "ui"), goLevelRoads);
		_btnGotoRoadsLevel.loadGraphic("assets/gfx/ui/BtnOrange.png", 120, 48);
		_btnGotoRoadsLevel.screenCenter();
		// _btnGotoRoadsLevel.y += 80;
		_btnGotoRoadsLevel.onUp.sound = FlxG.sound.load("Click");
		_btnGotoRoadsLevel.label.setFormat(Reg.FONT, 18, FlxColor.WHITE, "center");
		add(_btnGotoRoadsLevel);

		_btnGotoWaterLevel = new FlxButton(0, 0, Main.tongue.get("$LEVEL_WATER", "ui"), goLevelWater);
		_btnGotoWaterLevel.loadGraphic("assets/gfx/ui/BtnAqua.png", 120, 48);
		_btnGotoWaterLevel.screenCenter();
		_btnGotoWaterLevel.y += 80;
		_btnGotoWaterLevel.onUp.sound = FlxG.sound.load("Click");
		_btnGotoWaterLevel.label.setFormat(Reg.FONT, 18, FlxColor.WHITE, "center");
		add(_btnGotoWaterLevel);

		_btnGotoCavesLevel = new FlxButton(0, 0, Main.tongue.get("$LEVEL_CAVES", "ui"), goLevelCaves);
		_btnGotoCavesLevel.loadGraphic("assets/gfx/ui/BtnRed.png", 120, 48);
		_btnGotoCavesLevel.screenCenter();
		_btnGotoCavesLevel.y += 160;
		_btnGotoCavesLevel.onUp.sound = FlxG.sound.load("Click");
		_btnGotoCavesLevel.label.setFormat(Reg.FONT, 18, FlxColor.WHITE, "center");
		add(_btnGotoCavesLevel);

		_btnGotoClassicLevel = new FlxButton(0, 0, Main.tongue.get("$LEVEL_CLASSIC", "ui"), goLevelClassic);
		_btnGotoClassicLevel.loadGraphic("assets/gfx/ui/BtnDarkGray.png", 120, 48);
		_btnGotoClassicLevel.screenCenter();
		_btnGotoClassicLevel.y += 240;
		_btnGotoClassicLevel.onUp.sound = FlxG.sound.load("Click");
		_btnGotoClassicLevel.label.setFormat(Reg.FONT, 18, FlxColor.WHITE, "center");
		add(_btnGotoClassicLevel);
		// var btn = new FlxButton(FlxG.width / 2, FlxG.height * 0.7, "CLICK HERE", function()
		// {
		// 	FlxG.switchState(new PlayInitState());
		// });
		// btn.x -= btn.width / 2;
		// this.add(btn);

		// _btnLeaderboard = new FlxButton(0, 0, "Leaderboard", displayLeaderboard);
		// _btnLeaderboard.loadGraphic("assets/images/button01.png", 120, 36);
		// _btnLeaderboard.screenCenter();
		// _btnLeaderboard.onUp.sound = FlxG.sound.load("Click");
		// _btnLeaderboard.label.setFormat(null, 15, FlxColor.WHITE, "center");
		// add(_btnLeaderboard);
		// openflTextFieldTest();

		// add(new FlxText(20, FlxG.height - 30, FlxG.width - 40, "Original Frogger graphics and images by Konami. \nThis was created only for demonstration purposes").setFormat(null, 8, 0xffffffff, "center"));
	}

	private function goLevelRoads():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, .33, false, function()
		{
			Reg.current_level = 0;
			startGame();
		});
	}

	private function goLevelWater():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, .33, false, function()
		{
			Reg.current_level = 1;
			startGame();
		});
	}

	private function goLevelCaves():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, .33, false, function()
		{
			Reg.current_level = 2;
			startGame();
		});
	}

	private function goLevelClassic():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, .33, false, function()
		{
			Reg.current_level = 3;
			startGame();
		});
	}

	function playerScoreCallback(idScoreboard:String, score:Int):Void
	{
		// This function must be adapted to your game logic.
		Lib.trace("ID Scoreboard: " + idScoreboard + ". Score: " + score);
		scoreTxt.text = Std.string(score);
		scoreTxt.color = FlxColor.WHITE;
	}

	function loginCallback(result:Int):Void
	{
		// The possible returned values are:
		// -1 = failed login
		//  0 = trying to log in
		//  1 = logged in
		// this event is fired several times on differents situations, results vary and must be tested
		// and adapted to your game logic. for example, if you execute init() and login() but the user
		// doesn't login, cancel the operation, it will return: 0 -1 0 -1 , same as if the user is
		// not connected to the internet.
		Lib.trace("Login result = " + result);
		if (result == 1)
		{
			trace("Login Successful");
			// GooglePlayGames.setScore("CgkIzdyhmLQOEAIQAg", 234); // to set 234 points on scoreboard (Int data type).
			#if mobile
			#if GPG
			GooglePlayGames.getPlayerScore(Reg.GPG_LEADERBOARD);
			#end
			#end
		}
	}

	#if ADS
	private function onInitOk(ae:AdmobEvent)
	{
		trace(ae.type, ae.data);
		Admob.setVolume(0);
	}

	private function onConsentFail(ae:AdmobEvent)
	{
		trace(ae.type, ae.data);
		// Admob.setVolume(0);
	}
	#end

	function onRewardedEarnedEvent(event:String)
	{
		trace("The Rewarded Video Event is " + event);
		// if (event == AdMob.LOADED)
		// {
		// 	AdMob.showInterstitial(0);
		// }
	}

	function onRewardedLoadedEvent(event:String)
	{
		trace("The Rewarded Video Event is " + event);
		// if (event == AdMob.LOADED)
		// {
		// 	AdMob.showInterstitial(0);
		// }
	}

	function openflTextFieldTest()
	{
		trace("MenuState display width: " + Lib.current.stage.stageWidth + " display height: " + Lib.current.stage.stageHeight);
		var oflScaleX = Lib.current.stage.stageWidth / FlxG.width;
		var oflScaleY = Lib.current.stage.stageHeight / FlxG.height;
		var testField:TextField = new TextField();
		var testFormat:TextFormat = new TextFormat();

		testFormat.font = startLabel.font;
		testFormat.align = TextFormatAlign.CENTER;
		testFormat.size = 30;
		testFormat.color = 0xffffff;

		testField.defaultTextFormat = testFormat;
		testField.embedFonts = true;
		// textfield.defaultTextFormat = new TextFormat(fontName, 32 * oflScaleY, 0xffffff, TextFormatAlign.CENTER);
		testField.type = TextFieldType.INPUT;

		testField.background = true;
		testField.backgroundColor = 0xff0000ff;
		testField.width = 300;
		testField.height = 80;

		testField.x = Lib.current.stage.stageWidth / 2.0 - testField.width / 2.0;
		testField.y = Lib.current.stage.stageHeight / 2.0 - testField.height / 2.0;
		// testField.x = 471;
		// testField.y = 1064;
		// testField.border = true;
		// testField.borderColor = 0xff000000;

		testField.maxChars = 5;

		FlxG.addChildBelowMouse(testField);
		// FlxG.stage.__dismissSoftKeyboard();
		trace("TextField x:" + testField.x + " y:" + testField.y);
	}

	private function myCallback(Timer:FlxTimer):Void
	{
		trace(Main.tongue.get("$TITLE_START_LABEL", "ui"));
		startLabel = new FlxText(0, 200, FlxG.width, Main.tongue.get("$TITLE_START_LABEL", "ui")).setFormat(Reg.FONT, 24, 0xffffffff, "center");
		pressLabel = new FlxText(0, 300, FlxG.width, Main.tongue.get("$TITLE_PRESS_LABEL", "ui")).setFormat(Reg.FONT, 24, 0xCECBB9, "center");
		add(startLabel);
		add(pressLabel);
		// openflTextFieldTest();
		#if ADS
		Admob.showBanner(Reg.BANNER_ID_ANDROID, Admob.BANNER_SIZE_BANNER, Admob.BANNER_ALIGN_BOTTOM);
		// AdMob.showBanner();
		#end
	}

	private function displayLeaderboard():Void
	{
		// FlxG.camera.fade(FlxColor.BLACK, .33, false, function()
		// {
		trace("Display Leaderboard");
		#if mobile
		#if GPG
		GooglePlayGames.getPlayerScore(Reg.GPG_LEADERBOARD);

		GooglePlayGames.displayScoreboard(Reg.GPG_LEADERBOARD);
		#end
		#end
		// FlxG.switchState(new MenuState());
		// });
	}

	override public function update(elapsed:Float):Void
	{
		#if desktop
		if (FlxG.mouse.wheel != 0)
		{
			FlxG.camera.zoom += (FlxG.mouse.wheel / 10);
		}
		#end
		if (_title.y > 100)
			_title.velocity.y = 0;

		// #if FLX_TOUCH
		// // for (touch in FlxG.touches.list)
		// // {
		// // 	if (touch.justPressed && touch.overlaps(pressLabel))
		// // 	{
		// // 		Reg.level = 0;
		// // 		levelTxt.text = Std.string(Reg.level);
		// // 		FlxG.cameras.fade(0xff969867, 1, false, startGame);
		// // 	}
		// // }

		// if (FlxG.touches.justStarted().length > 0 && timer.finished)
		// {
		// 	Reg.level = 0;
		// 	levelTxt.text = Std.string(Reg.level);
		// 	FlxG.cameras.fade(0xff969867, 1, false, startGame);
		// }
		// #end
		// #if FLX_MOUSE
		// if (FlxG.mouse.justPressed && timer.finished)
		// {
		// 	Reg.level = 0;
		// 	levelTxt.text = Std.string(Reg.level);
		// 	FlxG.cameras.fade(0xff969867, 1, false, startGame);
		// }
		// #end

		super.update(elapsed);
	}

	private function startGame():Void
	{
		FlxG.switchState(new PlayState());
		FlxG.sound.music.stop();
		Reg.playCount++;
		#if ADS
		Admob.hideBanner();
		#end
	}
}
