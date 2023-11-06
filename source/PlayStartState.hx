// package jp_2dgames.game.state;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;

// import jp_2dgames.game.global.Global;
// import jp_2dgames.lib.Input;
// import jp_2dgames.lib.Snd;
using zero.flixel.extensions.FlxSpriteExt;

/**
 * 起動画面
**/
class PlayStartState extends FlxState
{
	var _player:FlxSprite;
	var _timer:Float = 0.0;

	/**
	 * The layer of darkness, that is put over everything at night.
	 */
	public var silhouette:FlxSprite;

	/**
	 * Just a rectangle of blackness
	 */
	public var darkness:BitmapData;

	public var shadowCamera:FlxCamera;

	// Switches through the different daytimes or lighting moods
	private var _lightMood:Int;

	private var _lightsOn:Bool = true;

	/**
	 * Just to avoid creating a point at 0|0 all the time in the bitmap copy functions
	 */
	private var _zeroPoint:Point;

	public var lampLightCone:FlxSprite;
	public var lampSprite:FlxSprite;
	public var lightButton:FlxButton;

	var _btnGotoRoadsLevel:FlxButton;
	var _btnGotoWaterLevel:FlxButton;
	var _btnGotoCavesLevel:FlxButton;
	var _btnGotoClassicLevel:FlxButton;

	override public function create():Void
	{
		_lightMood = 0;
		_zeroPoint = new Point(0, 0);
		super.create();
		this.bgColor = 0xFF77AAFF;

		shadowCamera = new FlxCamera(0, 0, 480, 800, 0);

		// bgColor = FlxColor.BLACK;
		// Snd.stopMusic();
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		// #if debug
		// FlxG.switchState(new PlayState());
		// return;
		// #end

		{
			var lvText = new FlxText(0, FlxG.height * 0.3, FlxG.width);
			lvText.alignment = "center";
			lvText.text = 'LEVEL ${Reg.level} / ${Reg.MAX_LEVEL - 1}';
			this.add(lvText);
		}

		_player = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.5);
		_player.loadGraphic("assets/images/frog_sprite_new5.png", true, 40, 40);
		// _player.loadGraphic(AssetPaths.IMAGE_PLAYER, true);
		// _player.animation.add("play", [0, 0, 1, 0, 0], 3);
		_player.animation.add("walk" + FlxDirectionFlags.UP, [0, 1], 5, true, false, true);
		_player.animation.play("walk" + FlxDirectionFlags.UP);
		_player.make_and_center_hitbox(30, 30);
		this.add(_player);

		var txt = new FlxText(FlxG.width * 0.5, FlxG.height * 0.5);
		txt.text = 'x ${Reg.life}';
		this.add(txt);

		silhouette = new FlxSprite(0, 0);
		silhouette.makeGraphic(640, 480, 0x00000000);
		_modifyDarkness();

		this.lampSprite = new FlxSprite(75, 100);
		this.lampSprite.loadGraphic("assets/images/lamp.png", true, 30, 60, false);
		this.add(lampSprite);

		// The darkness layer.
		add(silhouette);
		silhouette.blend = MULTIPLY;
		silhouette.scrollFactor.y = 0; // must be 1 because of the sprites  -> Fuck That! We'll just consider the scroll factor in copyPixels

		// Light cones. They are stamped onto the darkness, but are not visible themselves
		// Animated light cones must be added, or else the animation won't play;
		// but since we don't want to actually show them, they have to be turned invisible

		lampLightCone = new FlxSprite(45, 145);
		lampLightCone.loadGraphic("assets/images/lampLightCone.png", true, 90, 102, false);

		// this.redLightCone = new FlxSprite(500, 100);
		// this.redLightCone.loadGraphic("assets/images/red shine2.png", true, 163, 163, false);

		// this.lightCone = new FlxSprite(320, 211);
		// this.lightCone.loadGraphic("assets/images/glow-light.png", false, 64, 64, false);
		// #if FLX_MOUSE
		// this.mouseLightCone = new FlxSprite(FlxG.mouse.x, FlxG.mouse.y);
		// this.mouseLightCone.loadGraphic("assets/images/glow-light.png", false, 64, 64, false);
		// #end
		// this.glowLightCone = new FlxSprite(this.generatorSprite.x + 28, this.generatorSprite.y + 24);
		// this.glowLightCone.loadGraphic("assets/images/powerswitch_light.png", true, 4, 4);

		// this.fireShineCone = new FlxSprite(250, 150);
		// this.fireShineCone.loadGraphic("assets/images/fireshine.png", true, 128, 128, false);
		// this.fireShineCone.animation.add("burning", [0, 1, 2], 8);
		// this.fireShineCone.animation.play("burning");
		// this.lightGroup.add(this.fireShineCone);
		// this.fireShineCone.visible = false;
		this.lightButton = new FlxButton(400, 20, "Day/Night", onLightButtonClick);
		this.add(this.lightButton);

		_btnGotoRoadsLevel = new FlxButton(0, 0, Main.tongue.get("$LEVEL_ROADS", "ui"), goLevelRoads);
		_btnGotoRoadsLevel.loadGraphic("assets/gfx/ui/BtnAqua.png", 120, 48);
		_btnGotoRoadsLevel.screenCenter();
		_btnGotoRoadsLevel.y += 80;
		_btnGotoRoadsLevel.onUp.sound = FlxG.sound.load("Click");
		_btnGotoRoadsLevel.label.setFormat(Reg.FONT, 18, FlxColor.WHITE, "center");
		add(_btnGotoRoadsLevel);
		var btn = new FlxButton(FlxG.width / 2, FlxG.height * 0.7, "CLICK HERE", function()
		{
			FlxG.switchState(new PlayInitState());
		});
		btn.x -= btn.width / 2;
		this.add(btn);
	}

	private function goLevelRoads():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, .33, false, function()
		{
			FlxG.switchState(new PlayState());
		});
	}

	public function updateSilhouette():Void
	{
		// Clear the shilouette:
		this.silhouette.pixels = new BitmapData(640, 480, true, 0x000000);
		// A tilemap:
		// var _point:Point = new Point();

		// _point.x = 0;
		// _point.y = ((FlxG.camera.scroll.y - this.brickTileMap.y) - this.brickTileMap.offset.y);

		silhouette.pixels.copyPixels(darkness, darkness.rect, _zeroPoint, shadowCamera.buffer, _zeroPoint, true);
		// this.shadowCamera.buffer.fillRect(this.shadowCamera.buffer.rect, 0x00000000);by hoon
		shadowCamera.fill(0x00000000, false);

		// Stamp out the glow of the silhouette:
		// silhouette.stamp(this.glowLightCone, Std.int(this.glowLightCone.x), Std.int(this.glowLightCone.y - FlxG.camera.scroll.y));

		// An animated sprite:
		// var _flashRect2 = new Rectangle(0, 0, this.girlSprite.framePixels.width, this.girlSprite.framePixels.height);by hoon
		// var _flashRect2 = new Rectangle(0, 0, this.girlSprite.width, this.girlSprite.height);

		// if (this.girlSprite.flipX)
		// {
		// 	girlSprite.framePixels = girlSprite.frame.paintRotatedAndFlipped(null, this._zeroPoint, 0, true, false, false, true);
		// 	this.silhouette.pixels.copyPixels(this.darkness, _flashRect2, new Point(this.girlSprite.x, this.girlSprite.y - FlxG.camera.scroll.y),
		// 		this.girlSprite.framePixels, this._zeroPoint, true);
		// }
		// else
		// {
		// 	this.silhouette.pixels.copyPixels(this.darkness, _flashRect2, new Point(this.girlSprite.x, this.girlSprite.y - FlxG.camera.scroll.y),
		// 		this.girlSprite.pixels, new Point(girlSprite.frame.frame.x, girlSprite.frame.frame.y), true);
		// }

		// this.shadowCamera.fill(0x00000000, false); //seems to work the same as shadowCamera.buffer.fillRect. No difference visisble.

		// Stamp out the light of the silhouette:
		if (_lightsOn)
		{
			// #if FLX_MOUSE
			// this.silhouette.stamp(this.mouseLightCone, Std.int(this.mouseLightCone.x), Std.int(this.mouseLightCone.y - FlxG.camera.scroll.y));
			// #end
			this.silhouette.stamp(this.lampLightCone, Std.int(this.lampLightCone.x), Std.int(this.lampLightCone.y - FlxG.camera.scroll.y));
			// this.silhouette.stamp(this.redLightCone, Std.int(this.redLightCone.x), Std.int(this.redLightCone.y - FlxG.camera.scroll.y));
			// this.silhouette.stamp(this.fireSprite, Std.int(this.fireSprite.x), Std.int(this.fireSprite.y - FlxG.camera.scroll.y));

			// for (m in 0...this.lightGroup.members.length)
			// {
			// 	this.silhouette.stamp(this.lightGroup.members[m], Std.int(this.lightGroup.members[m].x),
			// 		Std.int(this.lightGroup.members[m].y - FlxG.camera.scroll.y));
			// }
		}
		this.silhouette.dirty = true;
	}

	private function _modifyDarkness():Void
	{
		// day
		if (_lightMood == 0)
		{
			darkness = new BitmapData(480, 800, true, 0xFFFA6306);
		}
		// sunset
		else if (_lightMood == 1)
		{
			darkness = new BitmapData(480, 800, true, 0xFF813304);
		}
		// dark night
		else if (_lightMood == 2)
		{
			darkness = new BitmapData(480, 800, true, 0xFF000000);
		}
		// moonlit night
		else if (_lightMood == 3)
		{
			darkness = new BitmapData(480, 800, true, 0xFF1f4C63);
		}
		// sunrise
		else
		{
			darkness = new BitmapData(480, 800, true, 0xFF7a5601);
		}
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Changes between day and night
	 */
	public function onLightButtonClick():Void
	{
		_lightMood++;
		if (_lightMood > 4)
		{
			_lightMood = 0;
		}

		_modifyDarkness();

		// day
		if (_lightMood == 0)
		{
			this.bgColor = 0xFF77AAFF;
			// this.cloudSprite.color = 0xFFFFFFFF;
			this.silhouette.visible = false;
			// this.moonSprite.visible = false;
			// this.sunSprite.visible = true;
			// this.sunSprite.y = 75;
			this.lampSprite.frame = lampSprite.frames.getByIndex(0);
			// this.wallLampSprite.frame = wallLampSprite.frames.getByIndex(0);
			// this.fireSprite.visible = false;
			// this.glowLightCone.frame = this.glowLightCone.frames.getByIndex(0);
			// this.generatorSprite.animation.stop();
		}
		// sunset
		else if (_lightMood == 1)
		{
			this.bgColor = 0xFFFA6306;
			// this.cloudSprite.color = 0xFFFA6306;
			this.silhouette.visible = true;
			// this.moonSprite.visible = false;
			// this.sunSprite.visible = false;
			// this.sunSetSunSprite.visible = true;
			// this.fireSprite.visible = true;

			this.lampSprite.frame = lampSprite.frames.getByIndex(1);
			// this.wallLampSprite.frame = wallLampSprite.frames.getByIndex(1);
			// this.glowLightCone.frame = this.glowLightCone.frames.getByIndex(1);
			// this.generatorSprite.animation.play("running");
		}
		// dark night
		else if (_lightMood == 2)
		{
			this.bgColor = 0xFF001122;
			// this.cloudSprite.color = 0xFF001122;
			// this.cloudSprite.x = 350;
			this.silhouette.visible = true;
			// this.moonSprite.visible = true;
			// this.moonSprite.color = this.moonSprite.color.getDarkened(0.4);
			// this.moonSprite.x = 350;
			// this.sunSprite.visible = false;
			// this.sunSetSunSprite.visible = false;
			this.lampSprite.frame = lampSprite.frames.getByIndex(1);
			// this.wallLampSprite.frame = wallLampSprite.frames.getByIndex(1);
		}
		// moonlit night
		else if (_lightMood == 3)
		{
			this.bgColor = 0xFF1f4C63;
			// this.cloudSprite.color = 0xFF1f4C63;
			// this.cloudSprite.x = 80;
			this.silhouette.visible = true;
			// this.moonSprite.visible = true;
			// this.moonSprite.color = 0xFFFFFFFF;
			// this.moonSprite.x = 400;
			// this.sunSprite.visible = false;
			this.lampSprite.frame = lampSprite.frames.getByIndex(1);
			// this.wallLampSprite.frame = wallLampSprite.frames.getByIndex(1);
		}
		// sunrise
		else
		{
			this.bgColor = 0xFFFBA6D4;
			// this.cloudSprite.color = 0xFFFBA6D4;
			// this.cloudSprite.x = 80;
			this.silhouette.visible = true;
			// this.moonSprite.visible = false;
			// this.sunSprite.visible = true;
			// this.sunSprite.y = 200;
			this.lampSprite.frame = lampSprite.frames.getByIndex(1);
			// this.wallLampSprite.frame = wallLampSprite.frames.getByIndex(1);
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		#if FLX_TOUCH
		if (FlxG.touches.justStarted().length > 0)
		{
			_timer += 3;
		}
		#end
		#if FLX_MOUSE
		if (FlxG.mouse.justPressed)
		{
			_timer += 3;
		}
		#end
		// _timer += elapsed;
		if (_timer > 2)
		{
			FlxG.switchState(new PlayState());
		}
		if (_lightMood > 0)
		{
			updateSilhouette();
			// #if FLX_MOUSE
			// mouseLightCone.x = FlxG.mouse.x - Std.int(this.mouseLightCone.width / 2);
			// mouseLightCone.y = FlxG.mouse.y - Std.int(this.mouseLightCone.height / 2);
			// #end
		}
	}
}
