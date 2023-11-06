package;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
import FScoreboard.User_Score;

class Reg
{
	/**
	 * Generic scores Array that can be used for cross-state stuff.
	 * Example usage: Storing the scores for level.
	 */
	public static var scores:Array<User_Score> = [];

	/**
	 * Generic score variable that can be used for cross-state stuff.
	 * Example usage: Storing the current score.
	 */
	public static var score:Int = 0;

	public static var score_roads:Int = 0;
	public static var score_water:Int = 0;
	public static var scroe_caves:Int = 0;

	public static var level:Int = 0;
	public static var current_level:Int = 0;
	public static var playCount:Int = 0;
	public static var PS:PlayState;
	public static inline var MAX_LEVEL:Int = 4;
	public static inline var MAX_LIFE:Int = 3;
	// HP
	static var _life:Float;
	public static var life(get, never):Float;

	/**
	 * default game time (sec)
	**/
	public static var defaultTime:Int = 45;

	public static inline var TIMER_BAR_WIDTH = 300;
	public static inline var GPG_LEADERBOARD:String = "CgkIzdyhmLQOEAIQAg";
	public static inline var GPG_ROADS_LEADERBOARD:String = "CgkIzdyhmLQOEAIQAw";
	public static inline var GPG_WATER_LEADERBOARD:String = "CgkIzdyhmLQOEAIQBA";
	public static inline var GPG_CAVES_LEADERBOARD:String = "CgkIzdyhmLQOEAIQBQ";
	public static inline var GPG_FIRST_ROADS_KILL_ACHS:String = "CgkIzdyhmLQOEAIQAQ";

	public static inline var BANNER_ID_IOS:String = "ca-app-pub-6964194614288140/7785218114";
	public static inline var BANNER_ID_ANDROID:String = "ca-app-pub-6964194614288140/8538635264";
	public static inline var INTERSTITIAL_ID_IOS:String = "ca-app-pub-6964194614288140/8331302582";
	public static inline var INTERSTITIAL_ID_ANDROID:String = "ca-app-pub-6964194614288140/8511587241";
	public static inline var REWARDED_ID_IOS:String = "ca-app-pub-6964194614288140/4643184958";
	public static inline var REWARDED_ID_ANDROID:String = "ca-app-pub-6964194614288140/9633097226";
	public static inline var FONT = "assets/fonts/NotoSansKR-Regular.ttf";
	public static inline var LEVEL_ROADS = "assets/tiled/roads.tmx";
	public static inline var LEVEL_WATER = "assets/tiled/water.tmx";
	public static inline var LEVEL_CAVE = "assets/tiled/cave.tmx";
	public static inline var LEVEL_CLASSIC = "assets/tiled/frogger2_test1.tmx";

	public static function initGame():Void
	{
		_life = MAX_LIFE;
		// _score = 0;
		// _level = START_LEVEL;
		// _shot = MAX_SHOT;
		// _money = FIRST_MONEY;
	}

	static function get_life()
	{
		return _life;
	}
}
