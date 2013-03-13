package  
{
	
	import org.flixel.FlxSprite;
	import flash.net.SharedObject;
	import flash.net.registerClassAlias;
	/**
	 * ...
	 * @author Maynard Price
	 */
	public class Registry 
	{
		//holds the current set of two teams that are fighting
		public static var Team1:Team = new Team();
		public static var Team2:Team = new Team();
		
		//an array of two integers listing the career mode index of the two fighting teams
		public static var fightingTeamsIndex:Array = new Array();
		
		//holds every team participating in the tournament
		public static var tournamentTeams:Array = new Array();
		//holds the numerical index into tournamentTeams for winners
		public static var tournamentSemiFinalists:Array = new Array();
		public static var tournamentFinalists:Array = new Array();
		public static var tournamentWinner:int;
		//keeps track of which matchup is next, starting at the first match between teams 0 and 1
		public static var tournamentNextMatch:int = 1;
		
		//holds every team in career mode, intended to be persistant between plays
		public static var careerTeams:Array = new Array();
		
		
		public static var careerStarted:Boolean = false;
		
		
		
		public static var fighterLib:Array = new Array();	//library of fighter images
		[Embed(source = "../img/f00.png")] public static var f00:Class;
		[Embed(source = "../img/f01.png")] public static var f01:Class; 
		[Embed(source = "../img/f02.png")] public static var f02:Class;
		[Embed(source = "../img/f03.png")] public static var f03:Class;
		[Embed(source = "../img/f04.png")] public static var f04:Class;
		
		[Embed(source = "../img/m00.png")] public static var m00:Class;
		[Embed(source = "../img/m01.png")] public static var m01:Class; 
		[Embed(source = "../img/m02.png")] public static var m02:Class;
		[Embed(source = "../img/m03.png")] public static var m03:Class;
		[Embed(source = "../img/m04.png")] public static var m04:Class;
		
		
		public static var sndLib:Array = new Array();  		//library of sound files
		[Embed(source = "../snd/hit0.mp3")] public static var hit0:Class;
		[Embed(source = "../snd/mag0.mp3")] public static var mag0:Class;
		[Embed(source = "../snd/mag1.mp3")] public static var mag1:Class;
		[Embed(source = "../snd/ko.mp3")]   public static var ko:Class;
		
		
		
		public static var victory:int = 0;  // keeps track of fight winner across states, 0 for still fighting, 1 or 2 for winning team
		
		public static var gameMode:int = 0; // 0 -main menu, 1 - exhibition, 2 - tournament, 3 - career, 4 - adventure
		public static var tournyInProgress:Boolean = false;		//keeps track of if a tournament is ongoing in career mode
		
		
		//keeps track of how many fighters on each team are knocked out
		public static var t1ko:int = 0;
		public static var t2ko:int = 0;
		
		public static var betTeam:int = 1;
		public static var betAmount:int = 0;
		
		public static var correctBets:int = 0;
		
		//how much currency the player has
		public static var gold:int = 0;
		
		public static var debt:int = 0;
		
		
		//TODO: add attack image library
		//TODO: add GUI to fightstate
		
		
		
		public static var saveData:SharedObject = SharedObject.getLocal("GuildArena");
		
		
		public function Registry() 
		{
			
		}
		
		public static function init():void {
			//initialize libraries
			initFighterLib();
			initSndLib();
			fightingTeamsIndex.push(0);
			fightingTeamsIndex.push(1);
			
			
		}
		
		public static function initFighterLib():void {
			fighterLib.push(f00);
			fighterLib.push(f01);
			fighterLib.push(f02);
			fighterLib.push(f03);
			fighterLib.push(f04);
			fighterLib.push(m00);
			fighterLib.push(m01);
			fighterLib.push(m02);
			fighterLib.push(m03);
			fighterLib.push(m04);
		}
		
		public static function initSndLib():void {
			sndLib.push(hit0);
			sndLib.push(mag0);
			sndLib.push(mag1);
			sndLib.push(ko);
		}
		
		public static function save():void {
			
			saveData.clear();
			
			
			saveData.data.gold = gold;
			saveData.data.debt = debt;
			saveData.data.fighters = new Array();
			saveData.data.teams = new Array();
			for (var i:int = 0; i < careerTeams.length; i++) {
				var tempT:Team = new Team();
				var tempF:Fighter = new Fighter();
				
				
				
				tempF = careerTeams[i].f[0].clone();
				saveData.data.fighters.push(tempF);
				tempF = careerTeams[i].f[1].clone();
				saveData.data.fighters.push(tempF);
				tempF = careerTeams[i].f[2].clone();
				saveData.data.fighters.push(tempF);
				
				tempT.name = careerTeams[i].name;
				
				saveData.data.teams.push(tempT);
			}
			
			
			
			saveData.data.careerStarted = careerStarted;
			
			saveData.flush();
		}
		
		public static function load():void {
			
			
			if (saveData.data.careerStarted != null){
				gold = int(saveData.data.gold);
				debt = int(saveData.data.debt);
				
				for (var j:int = 0; j < (saveData.data.fighters.length / 3); j++){
					for (var i:int = 0; i < saveData.data.fighters.length; i += 3) {
						var tempT:Team = new Team();
						var tempF:Fighter = new Fighter();
						var tempF2:Fighter = new Fighter();
						var tempF3:Fighter = new Fighter();
						

						
						tempF.copy(saveData.data.fighters[i]);
						tempT.f.push(tempF);

						
						tempF2.copy(saveData.data.fighters[i + 1]);
						tempT.f.push(tempF2);

						
						tempF3.copy(saveData.data.fighters[i + 2]);
						tempT.f.push(tempF3);

						
						tempT.name = saveData.data.teams[j].name;
						
						careerTeams.push(tempT);
					}
				}
				
				careerStarted = saveData.data.careerStarted
			}
			
			
		}
		
		public static function clearData():void {
			saveData.clear();
		}
	}

}