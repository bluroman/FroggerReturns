package;

import extension.admob.Admob;
import extension.admob.AdmobEvent;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.sound.FlxSound;
import openfl.Lib;

class PlayState extends BaseState
{
	public static inline var TILE_SIZE = 40;

	private var gameTime:Int;
	private var timer:Int;
	private var timeAlmostOverWarning:Float;
	private var waterY:Int;
	var hud:Hud;

	public var level:TiledLevel;
	public var coins:FlxGroup;
	public var gameState:GameStates;
	public var player:Frog;
	public var boundingBox:FlxSprite;
	public var carGroupNew:FlxTypedSpriteGroup<FlxSprite>;
	public var alligatorGroup:FlxTypedSpriteGroup<FlxSprite>;
	public var turtleGroupNew:FlxTypedSpriteGroup<FlxSprite>;
	public var logGroupNew:FlxTypedSpriteGroup<FlxSprite>;
	public var homeGroup:FlxTypedSpriteGroup<FlxSprite>;
	public var blueFrogGroup:FlxTypedSpriteGroup<FlxSprite>;
	public var snakeGroup:FlxTypedSpriteGroup<FlxSprite>;
	public var safeStoneGroup:FlxTypedSpriteGroup<FlxSprite>;
	public var goalGroup:FlxGroup;
	public var lavaGroup:FlxTypedSpriteGroup<FlxSprite>;
	public var actorSpeed:Float = 1.0;

	private var isRewardedLoaded:Bool = false;
	private var isRewardedEarned:Bool = false;
	private var hideGameMessageDelay:Int = -1;
	var displayFlag:Bool = false;
	private var safeFrogs:Int = 0;
	private var timeAlmostOverFlag:Bool = false;
	private var playerIsFloating:Bool;
	private var lastLifeScore:Int = 0;
	private var nextLife:Int = 5000;

	public var water:FlxObject = null;
	public var swamp:FlxObject;

	// public var lava:FlxObject;
	var sndWave:FlxSound;
	var sndAlligator:FlxSound;
	var sndLava:FlxSound;
	var sndSnake:FlxSound;

	override public function create()
	{
		FlxG.debugger.drawDebug = false;
		Reg.PS = this;
		Reg.level = 1;

		sndWave = FlxG.sound.load("Wave");
		sndAlligator = FlxG.sound.load("Alligator");
		sndLava = FlxG.sound.load("Lava");
		sndSnake = FlxG.sound.load("Snake");

		// Load the level's tilemaps
		coins = new FlxGroup();
		carGroupNew = new FlxTypedSpriteGroup<FlxSprite>();
		alligatorGroup = new FlxTypedSpriteGroup<FlxSprite>();
		turtleGroupNew = new FlxTypedSpriteGroup<FlxSprite>();
		logGroupNew = new FlxTypedSpriteGroup<FlxSprite>();
		homeGroup = new FlxTypedSpriteGroup<FlxSprite>();
		blueFrogGroup = new FlxTypedSpriteGroup<FlxSprite>();
		snakeGroup = new FlxTypedSpriteGroup<FlxSprite>();
		safeStoneGroup = new FlxTypedSpriteGroup<FlxSprite>();
		goalGroup = new FlxGroup();
		lavaGroup = new FlxTypedSpriteGroup<FlxSprite>();
		switch (Reg.current_level)
		{
			case 0:
				level = new TiledLevel(Reg.LEVEL_ROADS, this);
			case 1:
				level = new TiledLevel(Reg.LEVEL_WATER, this);
			case 2:
				level = new TiledLevel(Reg.LEVEL_CAVE, this);
			case 3:
				level = new TiledLevel(Reg.LEVEL_CLASSIC, this);
			default:
				level = new TiledLevel(Reg.LEVEL_CLASSIC, this);
		}
		// Add backgrounds
		add(level.backgroundLayer);

		// Draw coins first
		add(coins);
		add(carGroupNew);
		add(alligatorGroup);
		add(turtleGroupNew);
		add(logGroupNew);
		add(homeGroup);
		add(blueFrogGroup);
		add(snakeGroup);
		add(goalGroup);
		add(lavaGroup);
		add(safeStoneGroup);

		// Add static images
		add(level.imagesLayer);

		// Load player objects
		add(level.objectsLayer);

		// Add foreground tiles after adding level objects, so these tiles render on top of player
		add(level.foregroundTiles);
		// add(boundingBox);
		actorSpeed = 1.0;

		// Set up main variable properties
		gameTime = Reg.defaultTime * FlxG.updateFramerate; // FlxG.framerate;
		trace("gameTime: " + gameTime);
		timer = gameTime;
		timeAlmostOverWarning = Reg.TIMER_BAR_WIDTH * .7;
		waterY = TILE_SIZE * 8;
		Reg.score = 0;
		Reg.score_roads = 0;
		Reg.score_water = 0;
		Reg.scroe_caves = 0;

		hud = new Hud();
		add(hud);

		#if mobile
		Input.createVirtualPad(this, FULL, NONE);
		Input.virtualPad.buttonUp.loadGraphic("assets/images/touchUp.png", 100, 100);
		Input.virtualPad.buttonDown.loadGraphic("assets/images/touchDown.png", 100, 100);
		Input.virtualPad.buttonLeft.loadGraphic("assets/images/touchLeft.png", 100, 100);
		Input.virtualPad.buttonRight.loadGraphic("assets/images/touchRight.png", 100, 100);
		Input.virtualPad.buttonUp.setPosition(10, calculateRow(16) + 20);
		Input.virtualPad.buttonDown.setPosition(10 + 100, calculateRow(16) + 20);
		Input.virtualPad.buttonLeft.setPosition(480 - 200, calculateRow(16) + 20);
		Input.virtualPad.buttonRight.setPosition(480 - 100, calculateRow(16) + 20);
		#end
		#if ADS
		Admob.status.addEventListener(AdmobEvent.REWARDED_LOADED, onRewardedLoadedEvent);
		Admob.status.addEventListener(AdmobEvent.REWARDED_EARNED, onRewardedEarnedEvent);
		Admob.status.addEventListener(AdmobEvent.REWARDED_DISMISSED, onRewardedDismissedEvent);
		trace("##################Start Load Rewarded Video#################");
		Admob.loadRewarded(Reg.REWARDED_ID_ANDROID);
		#end

		super.create();

		gameState = GameStates.PLAYING;
		FlxG.sound.play("Theme");
		trace("Car Group: " + carGroupNew.length);
		trace("Log Group: " + logGroupNew.length);
		trace("Turtle Group: " + turtleGroupNew.length);
		trace("Lava Group: " + lavaGroup.length);
		trace("PlayState display width: " + Lib.current.stage.stageWidth + " display height: " + Lib.current.stage.stageHeight);
	}

	/**
	 * Helper function to find the X position of a columm on the game's grid
	 * @param value colum number
	 * @return returns number based on the value * TILE_SIZE
	**/
	public function calculateColumn(value:Int):Int
	{
		return value * TILE_SIZE;
	}

	/**
	 * Helper function to find the Y position of a row on the game's grid
	 * @param value row number
	 * @return returns number based on the value * TILE_SIZE
	 */
	public function calculateRow(value:Int):Int
	{
		return calculateColumn(value);
	}

	function onRewardedDismissedEvent(event:String)
	{
		trace("The Rewarded Video Event is " + event);
		if (isRewardedEarned)
		{
			hud.createLives(1);

			hud.showGameMessage("Earned 1-Life");
			hideGameMessageDelay = 50;
			isRewardedEarned = false;
			FlxG.sound.play("Bonus");
		}
		closeSubState();
	}

	function onRewardedEarnedEvent(event:String)
	{
		trace("The Rewarded Video Event is " + event);
		isRewardedEarned = true;
		isRewardedLoaded = false;
	}

	function onRewardedLoadedEvent(event:String)
	{
		trace("The Rewarded Video Event is " + event);
		isRewardedLoaded = true;
	}

	public function restart():Void
	{
		// Make sure the player still has lives to restart
		if (hud.get_totalLives() == 0 && gameState != GameStates.GAME_OVER)
		{
			gameOver();
		}
		else
		{
			// Test to see if Level is over, if so reset all the bases.
			if (gameState == GameStates.LEVEL_OVER)
			{
				resetBases();
				Reg.level++;
				levelUp();
			}
			levelTxt.text = Std.string(Reg.level);
			// Change game state to Playing so animation can continue.
			timer = gameTime;
			player.restart();
			timeAlmostOverFlag = false;
			gameState = GameStates.PLAYING;
			trace("restart end");
			// totalElapsed = 0;
		}
	}

	private function resetBases():Void
	{
		homeGroup.forEachOfType(Home, function(_base)
		{
			// var here = cast base;
			trace("base:", _base);
			_base.empty();
		});
		// Reset safe frogs
		safeFrogs = 0;

		// Set message to tell player they can restart
		hud.showGameMessage("START");
		hideGameMessageDelay = 200;
	}

	public function levelUp():Void
	{
		actorSpeed += 0.2;
		if (actorSpeed > 2.0)
			actorSpeed = 2.0;
		alligatorGroup.forEachOfType(Alligator, function(_alligator)
		{
			// var alligator:Alligator = cast _alligator;

			_alligator.speed = actorSpeed;
			trace("Alligator Speed:" + _alligator.speed);
		});
		turtleGroupNew.forEachOfType(WrappingSprite, function(_turtle)
		{
			// var turtle:WrappingSprite = cast _turtle;

			_turtle.speed = actorSpeed;
			trace("Turtle Speed:" + _turtle.speed);
		});
		carGroupNew.forEachOfType(Car1, function(_car)
		{
			// var car:Car1 = cast _car;

			_car.speed = actorSpeed;
			trace("Car Speed:" + _car.speed);
		});
		logGroupNew.forEachOfType(WrappingSprite, function(_logMoving)
		{
			// var logMoving:WrappingSprite = cast(_logMoving, WrappingSprite);

			_logMoving.speed = actorSpeed;
			trace("Log Speed:" + _logMoving.speed);
		});
	}

	private function gameOver():Void
	{
		gameState = GameStates.GAME_OVER;

		hud.showGameMessage(Main.tongue.get("$TITLE_GAMEOVER", "ui"));

		hideGameMessageDelay = 100;

		// TODO there is a Game Over sound I need to play here
		FlxG.sound.playMusic("GameOver", 1, false);
	}

	private function killPlayer(isWater:Bool):Void
	{
		// commented just test home collision
		gameState = GameStates.COLLISION;
		hud.removeLife();
		player.death(isWater);
		hideGameMessageDelay = 30;
	}

	private function timeUp():Void
	{
		if (gameState != GameStates.COLLISION)
		{
			FlxG.sound.play("Squash");
			killPlayer(false);
		}
	}

	private function goalCollision(target:FlxObject, player:Frog)
	{
		var timeLeftOver:Int = Math.round(timer / FlxG.updateFramerate);
		trace("GOAL Collisions TimeLeftOver: " + timeLeftOver);
		safeFrogs++;
		// Increment the score based on the time left
		if (Reg.current_level == 0)
			Reg.score_roads += timeLeftOver * ScoreValues.TIME_BONUS;
		else if (Reg.current_level == 1)
			Reg.score_water += timeLeftOver * ScoreValues.TIME_BONUS;
		else if (Reg.current_level == 2)
			Reg.scroe_caves += timeLeftOver * ScoreValues.TIME_BONUS;
		else if (Reg.current_level == 3)
			Reg.score += timeLeftOver * ScoreValues.TIME_BONUS;
		// Reg.score += timeLeftOver * ScoreValues.TIME_BONUS;
		FlxG.sound.play("Bonus");
		trace("Safe frogs:" + safeFrogs + "Group:" + homeGroup.length);

		// Reguardless if the base was empty or occupied we still display the time it took to get there
		hud.showGameMessage("TIME " + Std.string(gameTime / FlxG.updateFramerate - timeLeftOver));
		hideGameMessageDelay = 200;

		// Test to see if we have all the frogs, if so then level has been completed. If not restart.
		if (safeFrogs == 5)
		{
			levelComplete();
		}
		else
		{
			hideGameMessageDelay = 50;
			gameState = GameStates.RESTART;
			player.restart();
			// restart();
		}
	}

	private function baseCollision(target:Home, player:Frog):Void
	{
		var timeLeftOver:Int = Math.round(timer / FlxG.updateFramerate);
		trace("Base Collision Mode:" + target.mode + " TimeLeftOver: " + timeLeftOver);

		switch (target.mode)
		{
			case Home.EMPTY:
				// Increment number of frogs saved
				safeFrogs++;
				// Flag the target as success to show it is occupied now
				target.success();
				// Increment the score based on the time left
				if (Reg.current_level == 0)
					Reg.score_roads += timeLeftOver * ScoreValues.TIME_BONUS;
				else if (Reg.current_level == 1)
					Reg.score_water += timeLeftOver * ScoreValues.TIME_BONUS;
				else if (Reg.current_level == 2)
					Reg.scroe_caves += timeLeftOver * ScoreValues.TIME_BONUS;
				else if (Reg.current_level == 3)
					Reg.score += timeLeftOver * ScoreValues.TIME_BONUS;
				FlxG.sound.play("Bonus");
			case Home.BONUS:
				// Increment number of frogs saved
				safeFrogs++;
				// Flag the target as success to show it is occupied now
				target.success();
				// Increment the score based on the time left
				if (Reg.current_level == 0)
					Reg.score_roads += timeLeftOver * ScoreValues.TIME_BONUS;
				else if (Reg.current_level == 1)
					Reg.score_water += timeLeftOver * ScoreValues.TIME_BONUS;
				else if (Reg.current_level == 2)
					Reg.scroe_caves += timeLeftOver * ScoreValues.TIME_BONUS;
				else if (Reg.current_level == 3)
					Reg.score += timeLeftOver * ScoreValues.TIME_BONUS;

				if (target.mode == Home.BONUS)
				{
					if (Reg.current_level == 0)
						Reg.score_roads += timeLeftOver * ScoreValues.HOME_BONUS;
					else if (Reg.current_level == 1)
						Reg.score_water += timeLeftOver * ScoreValues.HOME_BONUS;
					else if (Reg.current_level == 2)
						Reg.scroe_caves += timeLeftOver * ScoreValues.HOME_BONUS;
					else if (Reg.current_level == 3)
						Reg.score += timeLeftOver * ScoreValues.HOME_BONUS;
				}
				FlxG.sound.play("Bonus");
			case Home.NO_BONUS:
				// waterCollision();
				return;
			case Home.SUCCESS:
				return;
		}
		trace("Safe frogs:" + safeFrogs + "Group:" + homeGroup.length);

		// Reguardless if the base was empty or occupied we still display the time it took to get there
		hud.showGameMessage("TIME " + Std.string(gameTime / FlxG.updateFramerate - timeLeftOver));
		hideGameMessageDelay = 200;

		// Test to see if we have all the frogs, if so then level has been completed. If not restart.
		if (safeFrogs == homeGroup.length)
		{
			levelComplete();
		}
		else
		{
			hideGameMessageDelay = 50;
			gameState = GameStates.RESTART;
			player.restart();
			// restart();
		}
	}

	private function levelComplete():Void
	{
		// Increment the score based on
		if (Reg.current_level == 0)
			Reg.score_roads += ScoreValues.FINISH_LEVEL;
		else if (Reg.current_level == 1)
			Reg.score_water += ScoreValues.FINISH_LEVEL;
		else if (Reg.current_level == 2)
			Reg.scroe_caves += ScoreValues.FINISH_LEVEL;
		else if (Reg.current_level == 3)
			Reg.score += ScoreValues.FINISH_LEVEL;
		// Reg.score += ScoreValues.FINISH_LEVEL;

		// Change game state to let system know a level has been completed
		gameState = GameStates.LEVEL_OVER;

		// Hide the player since the level is over and wait for the game to restart itself
		player.visible = false;
	}

	private function float(target:WrappingSprite, player:Frog):Void
	{
		playerIsFloating = true;
		if (Std.isOfType(target, Alligator))
		{
			target.color = 0xff0000;
			trace("Alligator X:" + target.x);
			trace("Player X:" + player.x);
		}
		#if desktop
		if (!(FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT))
		#end
		{
			player.float(target.speed, target.facing);
		}
	}

	private function turtleFloat(target:TimerSprite, player:Frog):Void
	{
		// Test to see if the target is active. If it is active the player can float. If not the player
		// is in the water
		if (target.get_isActive())
		{
			float(target, player);
		}
		else if (!player.isMoving)
		{
			waterCollision();
		}
	}

	private function waterCollision():Void
	{
		if (gameState != GameStates.COLLISION)
		{
			// FlxG.play(GameAssets.FroggerPlunkSound);
			FlxG.sound.play("Plunk");
			killPlayer(true);
		}
	}

	private function lavaCollision(target:FlxObject, player:Frog):Void
	{
		trace("###############Lava Collisions#############");
		trace("Player Position: y: " + player.y + " x: " + player.x);
		if (!sndLava.playing)
			sndLava.play(true);

		if (!playerIsFloating)
			waterCollision();

		if ((player.x > FlxG.width - player.frameWidth / 2) || (player.x < -player.frameWidth / 2))
			// if(!player.isOnScreen())
		{
			waterCollision();
		}
	}

	private function liquidCollision(target:FlxObject, player:Frog):Void
	{
		// trace("###############Liquid Collisions#############");
		// trace("Player Position: " + player.y + " ID: " + target.ID);
		if (target.ID == 0) // water
		{
			if (!sndWave.playing)
				sndWave.play(true);
		}
		else if (target.ID == 1) // swamp
		{
			if (!sndAlligator.playing)
				sndAlligator.play(true);
		}
		else if (target.ID == 2) // lava
		{
			if (!sndLava.playing)
				sndLava.play(true);
		}

		// TODO this can be cleaned up better
		// if (!player.isMoving && !playerIsFloating)
		if (!playerIsFloating)
			waterCollision();

		if ((player.x > FlxG.width - player.frameWidth / 2) || (player.x < -player.frameWidth / 2))
			// if(!player.isOnScreen())
		{
			waterCollision();
		}
	}

	private function stoneCollision(target:TimerSprite, player:Frog):Void
	{
		// trace("##############Stone Collision###########");
		if (target.get_isActive())
		{
			float(target, player);
		}
		else if (!player.isMoving)
		{
			waterCollision();
		}
	}

	override public function update(elapsed:Float)
	{
		if (gameState == GameStates.GAME_OVER)
		{
			if (hideGameMessageDelay == 0)
			{
				#if ADS
				Admob.status.removeEventListener(AdmobEvent.REWARDED_LOADED, onRewardedLoadedEvent);
				Admob.status.removeEventListener(AdmobEvent.REWARDED_EARNED, onRewardedEarnedEvent);
				Admob.status.removeEventListener(AdmobEvent.REWARDED_DISMISSED, onRewardedDismissedEvent);
				#end
				if (!displayFlag)
				{
					displayFlag = true;
					hud.showEnterUserNameField(true);
					hud.displayTextField();
				}
			}
			else
			{
				hideGameMessageDelay -= 1;
			}
		}
		else if (gameState == GameStates.LEVEL_OVER)
		{
			if (hideGameMessageDelay == 0)
			{
				restart();
			}
			else
			{
				hideGameMessageDelay -= 1; // FlxG.elapsed;
			}
		}
		else if (gameState == GameStates.PLAYING)
		{
			// trace("Player Position Y:" + player.y);
			// Reset floating flag for the player.
			playerIsFloating = false;
			// for (inLava in lavaGroup)
			// {
			// 	if (FlxG.pixelPerfectOverlap(inLava, player))
			// 	{
			// 		lavaCollision(inLava, player);
			// 	}
			// }

			for (newCar in carGroupNew)
			{
				var collides = false;
				if (FlxG.pixelPerfectOverlap(newCar, player))
				{
					if (gameState != GameStates.COLLISION)
					{
						collides = true;
						FlxG.sound.play("Squash");
						killPlayer(false);
						break;
					}
				}
			}
			for (newLog in logGroupNew)
			{
				if (FlxG.pixelPerfectOverlap(newLog, player))
				{
					playerIsFloating = true;
					#if desktop
					if (!(FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT))
					#end
					{
						var castLog:WrappingSprite = cast(newLog, WrappingSprite);
						player.float(castLog.speed, castLog.facing);
					}
				}
			}
			// if (FlxG.overlap(player, goalGroup))
			// {
			// 	var timeLeftOver:Int = Math.round(timer / FlxG.updateFramerate);
			// 	trace("GOAL Collisions TimeLeftOver: " + timeLeftOver);
			// 	safeFrogs++;
			// 	// Increment the score based on the time left
			// 	if (Reg.current_level == 0)
			// 		Reg.score_roads += timeLeftOver * ScoreValues.TIME_BONUS;
			// 	else if (Reg.current_level == 1)
			// 		Reg.score_water += timeLeftOver * ScoreValues.TIME_BONUS;
			// 	else if (Reg.current_level == 2)
			// 		Reg.scroe_caves += timeLeftOver * ScoreValues.TIME_BONUS;
			// 	else if (Reg.current_level == 3)
			// 		Reg.score += timeLeftOver * ScoreValues.TIME_BONUS;
			// 	// Reg.score += timeLeftOver * ScoreValues.TIME_BONUS;
			// 	FlxG.sound.play("Bonus");
			// 	trace("Safe frogs:" + safeFrogs + "Group:" + homeGroup.length);

			// 	// Reguardless if the base was empty or occupied we still display the time it took to get there
			// 	hud.showGameMessage("TIME " + Std.string(gameTime / FlxG.updateFramerate - timeLeftOver));
			// 	hideGameMessageDelay = 200;

			// 	// Test to see if we have all the frogs, if so then level has been completed. If not restart.
			// 	if (safeFrogs == 5)
			// 	{
			// 		levelComplete();
			// 	}
			// 	else
			// 	{
			// 		hideGameMessageDelay = 50;
			// 		gameState = GameStates.RESTART;
			// 		player.restart();
			// 		// restart();
			// 	}
			// }
			for (blueFrog in blueFrogGroup)
			{
				if (FlxG.pixelPerfectOverlap(blueFrog, player))
				{
					if (Reg.current_level == 0)
						Reg.score_roads += ScoreValues.HOME_BONUS;
					else if (Reg.current_level == 1)
						Reg.score_water += ScoreValues.HOME_BONUS;
					else if (Reg.current_level == 2)
						Reg.scroe_caves += ScoreValues.HOME_BONUS;
					else if (Reg.current_level == 3)
						Reg.score += ScoreValues.HOME_BONUS;
					FlxG.sound.play("Bonus");
					blueFrog.kill();
				}
			}
			for (snake in snakeGroup)
			{
				if (FlxG.pixelPerfectOverlap(snake, player))
				{
					if (gameState != GameStates.COLLISION)
					{
						FlxG.sound.play("Squash");
						killPlayer(false);
					}
				}
			}

			FlxG.overlap(turtleGroupNew, player, turtleFloat);
			FlxG.overlap(homeGroup, player, baseCollision);
			FlxG.overlap(alligatorGroup, player, float);
			FlxG.overlap(safeStoneGroup, player, stoneCollision);
			FlxG.overlap(lavaGroup, player, lavaCollision);
			// for (inLava in lavaGroup)
			// {
			// 	if (FlxG.pixelPerfectOverlap(inLava, player))
			// 	{
			// 		lavaCollision(inLava, player);
			// 	}
			// }
			if (water != null)
				FlxG.overlap(water, player, liquidCollision);
			if (swamp != null)
				FlxG.overlap(swamp, player, liquidCollision);
			// if (lava != null)
			// 	FlxG.overlap(lava, player, liquidCollision);
			FlxG.overlap(goalGroup, player, goalCollision);

			if (timer == 0 && gameState == GameStates.PLAYING)
			{
				timeUp();
			}
			else
			{
				timer -= 1;
				hud.timerBar.scale.x = Reg.TIMER_BAR_WIDTH - Math.round((timer / gameTime * Reg.TIMER_BAR_WIDTH));

				if (hud.timerBar.scale.x == timeAlmostOverWarning && !timeAlmostOverFlag)
				{
					FlxG.sound.play("Time");
					timeAlmostOverFlag = true;
				}
			}

			// Manage hiding gameMessage based on timer
			if (hideGameMessageDelay > 0)
			{
				hideGameMessageDelay -= 1; // FlxG.elapsed;
				if (hideGameMessageDelay < 0)
					hideGameMessageDelay = 0;
			}
			else if (hideGameMessageDelay == 0)
			{
				hideGameMessageDelay = -1;
				hud.hideGameMessage();
			}
			switch (Reg.current_level)
			{
				case 0:
					scoreTxt.text = Std.string(Reg.score_roads);
				case 1:
					scoreTxt.text = Std.string(Reg.score_water);
				case 2:
					scoreTxt.text = Std.string(Reg.scroe_caves);
				case 3:
					scoreTxt.text = Std.string(Reg.score);
				default:
					scoreTxt.text = Std.string(Reg.score);
			}
			// scoreTxt.text = Std.string(Reg.score);
		}
		else if (gameState == GameStates.RESTART)
		{
			if (hideGameMessageDelay == 0)
			{
				restart();
			}
			else
			{
				hideGameMessageDelay -= 1; // FlxG.elapsed;
			}
		}
		else if (gameState == GameStates.DEATH_OVER)
		{
			if (hideGameMessageDelay == 0)
			{
				if (hud.get_totalLives() == 0)
				{
					if (isRewardedLoaded)
					{
						trace("Rewarded Popup Show");
						openSubState(new Popup_Rewarded());
					}
					else
						restart();
				}
				else
					restart();
			}
			else
			{
				hideGameMessageDelay -= 1; // FlxG.elapsed;
			}
		}
		var tmpScore;
		switch (Reg.current_level)
		{
			case 0:
				tmpScore = Reg.score_roads;
			case 1:
				tmpScore = Reg.score_water;
			case 2:
				tmpScore = Reg.scroe_caves;
			case 3:
				tmpScore = Reg.score;
			default:
				tmpScore = Reg.score;
		}

		if (lastLifeScore != tmpScore && tmpScore % nextLife == 0)
		{
			if (hud.get_totalLives() < 5)
			{
				hud.addLife();
				lastLifeScore = tmpScore;

				hud.showGameMessage("1-UP");
				hideGameMessageDelay = 200;
			}
		}
		// Update the entire game
		super.update(elapsed);
	}
}
