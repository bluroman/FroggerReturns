package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;

class BaseState extends FlxState
{
	var scoreboard:FroggerScoreboard;
	var scoreboard1:FroggerScoreboard1; // roads
	var scoreboard2:FroggerScoreboard2; // water
	var scoreboard3:FroggerScoreboard3; // caves

	// var tmpscoreboard;
	var scoreTxt:FlxText;
	var highscoreLabel:FlxText;
	var highscoreTxt:FlxText;
	var scoreLabel:FlxText;
	var levelLabel:FlxText;
	var levelTxt:FlxText;
	var background:FlxSprite;
	var _topScoreBoard:FlxTypedSpriteGroup<FlxSprite>;

	public function new()
	{
		super();
		_topScoreBoard = new FlxTypedSpriteGroup<FlxSprite>();
	}

	override public function create():Void
	{
		super.create();

		scoreboard = new FroggerScoreboard();
		scoreboard1 = new FroggerScoreboard1();
		scoreboard2 = new FroggerScoreboard2();
		scoreboard3 = new FroggerScoreboard3();

		background = new FlxSprite();
		background.makeGraphic(FlxG.width, 80, 0x80000047);
		_topScoreBoard.add(background);

		trace("0 0th score:" + scoreboard.getScore(0).score);
		trace("1 0th score:" + scoreboard1.getScore(0).score);
		trace("2 0th score:" + scoreboard2.getScore(0).score);
		trace("3 0th score:" + scoreboard3.getScore(0).score);

		highscoreLabel = new FlxText((FlxG.width - 200) * .5, 0, 200, Main.tongue.get("$TITLE_HIGHSCORE", "ui")).setFormat(Reg.FONT, 18, 0xffffff, "center");
		// highscoreTxt = new FlxText(highscoreLabel.x, highscoreLabel.y + highscoreLabel.height, 200,
		// 	Std.string(tmpscoreboard.getScore(0).score)).setFormat(Reg.FONT, 18, 0xffe00000, "center");
		scoreLabel = new FlxText(50, 0, 100, Main.tongue.get("$TITLE_SCORE", "ui")).setFormat(Reg.FONT, 18, 0xffffff, "right");
		// scoreTxt = new FlxText(0, scoreLabel.height, 150, Std.string(Reg.score)).setFormat(Reg.FONT, 18, 0xffe00000, "right");
		levelLabel = new FlxText(480 - 170, 0, 100, Main.tongue.get("$TITLE_LEVEL", "ui")).setFormat(Reg.FONT, 18, 0xffffff, "right");
		levelTxt = new FlxText(levelLabel.x - 50, levelLabel.height, 150, Std.string(Reg.level)).setFormat(Reg.FONT, 18, 0xffe00000, "right");
		switch (Reg.current_level)
		{
			case 0:
				highscoreTxt = new FlxText(highscoreLabel.x, highscoreLabel.y + highscoreLabel.height, 200,
					Std.string(scoreboard1.getScore(0).score)).setFormat(Reg.FONT, 18, 0xffe00000, "center");
				scoreTxt = new FlxText(0, scoreLabel.height, 150, Std.string(Reg.score_roads)).setFormat(Reg.FONT, 18, 0xffe00000, "right");
			case 1:
				highscoreTxt = new FlxText(highscoreLabel.x, highscoreLabel.y + highscoreLabel.height, 200,
					Std.string(scoreboard2.getScore(0).score)).setFormat(Reg.FONT, 18, 0xffe00000, "center");
				scoreTxt = new FlxText(0, scoreLabel.height, 150, Std.string(Reg.score_water)).setFormat(Reg.FONT, 18, 0xffe00000, "right");
			case 2:
				highscoreTxt = new FlxText(highscoreLabel.x, highscoreLabel.y + highscoreLabel.height, 200,
					Std.string(scoreboard3.getScore(0).score)).setFormat(Reg.FONT, 18, 0xffe00000, "center");
				scoreTxt = new FlxText(0, scoreLabel.height, 150, Std.string(Reg.scroe_caves)).setFormat(Reg.FONT, 18, 0xffe00000, "right");
			case 3:
				highscoreTxt = new FlxText(highscoreLabel.x, highscoreLabel.y + highscoreLabel.height, 200,
					Std.string(scoreboard.getScore(0).score)).setFormat(Reg.FONT, 18, 0xffe00000, "center");
				scoreTxt = new FlxText(0, scoreLabel.height, 150, Std.string(Reg.score)).setFormat(Reg.FONT, 18, 0xffe00000, "right");
		}
		// // Create Text for title, credits, and score
		// highscoreLabel = new FlxText((FlxG.width - 200) * .5, 0, 200, Main.tongue.get("$TITLE_HIGHSCORE", "ui")).setFormat(Reg.FONT, 18, 0xffffff, "center");
		// // highscoreTxt = new FlxText(highscoreLabel.x, highscoreLabel.y + highscoreLabel.height, 200,
		// // 	Std.string(tmpscoreboard.getScore(0).score)).setFormat(Reg.FONT, 18, 0xffe00000, "center");
		// scoreLabel = new FlxText(50, 0, 100, Main.tongue.get("$TITLE_SCORE", "ui")).setFormat(Reg.FONT, 18, 0xffffff, "right");
		// // scoreTxt = new FlxText(0, scoreLabel.height, 150, Std.string(Reg.score)).setFormat(Reg.FONT, 18, 0xffe00000, "right");
		// levelLabel = new FlxText(480 - 170, 0, 100, Main.tongue.get("$TITLE_LEVEL", "ui")).setFormat(Reg.FONT, 18, 0xffffff, "right");
		// levelTxt = new FlxText(levelLabel.x - 50, levelLabel.height, 150, Std.string(Reg.level)).setFormat(Reg.FONT, 18, 0xffe00000, "right");

		_topScoreBoard.add(highscoreLabel);
		_topScoreBoard.add(highscoreTxt);
		_topScoreBoard.add(scoreLabel);
		_topScoreBoard.add(scoreTxt);
		_topScoreBoard.add(levelLabel);
		_topScoreBoard.add(levelTxt);

		add(_topScoreBoard);

		_topScoreBoard.forEach(function(spr:FlxSprite)
		{
			spr.scrollFactor.set(0, 0);
		});
	}
}
