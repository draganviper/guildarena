package
{
	
	/**
	 * ...
	 * @author Maynard Price
	 */
	
	import mx.core.FlexSprite;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxButtonPlus;

	public class MissionSelectState extends FlxState {
		
		//the mission select state is treated as a state by the game engine, but for the
		//purposes of the player it's really part of a menu accessed from the base
		//just like other submenus from base, you can change to other states at any time
		
		
		
		
		
		[Embed(source = "../img/folder.png")] protected var folder:Class;
		public var missionFolder:FlxSprite = new FlxSprite(50, 150, folder);
		
		[Embed(source = "../img/paper.png")] protected var paper:Class;
		public var missionPaper1:FlxSprite = new FlxSprite(70, 155, paper);
		public var missionPaper2:FlxSprite = new FlxSprite(255, 155, paper);
		
		
		[Embed(source = "../img/table.png")] protected var table:Class;
		public var missionTable:FlxSprite = new FlxSprite(0, 100, table);
		
		[Embed(source = "../img/arrow_left.png")] protected var arrow_left:Class;
		public var arrowLeft:FlxSprite = new FlxSprite(0, 0, arrow_left);
		[Embed(source = "../img/arrow_right.png")] protected var arrow_right:Class;
		public var arrowRight:FlxSprite = new FlxSprite(0, 0, arrow_right);


		
		public var missionSelectText:FlxText = new FlxText(20, 120, 380, "");
		
		
		//create the dynamic text and window that displays info on the most recently hovered over mission
		
		public var missionNameText:FlxText = new FlxText(260, 170, 230, "");
		public var missionRewardText:FlxText = new FlxText(260, 195, 230, "");
		public var missionRepText:FlxText = new FlxText(260, 225, 230, "");
		
		public var missionTimeText:FlxText = new FlxText(260, 255, 230, "");
		
		public var missionCombatDifText:FlxText = new FlxText(260, 285, 230, "");
		public var missionStealthDifText:FlxText = new FlxText(260, 315, 230, "");
		public var missionCharmDifText:FlxText = new FlxText(260, 345, 230, "");
		
		public var missionStagesText:FlxText = new FlxText(260, 375, 230, "");
		
		public var missionInfoText:FlxText = new FlxText(260, 170, 230, "");
		
		public var nextPageButton:FlxButtonPlus = new FlxButtonPlus(290, 410, nextClick, null, "", 64, 64);
		public var prevPageButton:FlxButtonPlus = new FlxButtonPlus(110, 410, prevClick, null, "", 64, 64);
		public var startButton:FlxButtonPlus = new FlxButtonPlus(190, 425, startClick, null, "Accept Mission", 80, 25);
		
		public var page:int = 0;			//currently selected mission
		
		override public function create():void {
			
			//create one button for each mission available in the current city
			
			loadMissionInfo(page);
			
			missionPaper1.exists = false;
			prevPageButton.visible = false;
			
			Registry.currentState = 6;
			
			nextPageButton.loadGraphic(arrowRight, arrowRight);
			prevPageButton.loadGraphic(arrowLeft, arrowLeft);
			
			
			missionSelectText.setFormat(null, 22, 0x000000);
			
			missionNameText.setFormat(null, 14, 0x000000);
			missionRewardText.setFormat(null, 14, 0x000000);
			missionRepText.setFormat(null, 14, 0x000000);
			missionTimeText.setFormat(null, 14, 0x000000);
			missionCombatDifText.setFormat(null, 14, 0x000000);
			missionStealthDifText.setFormat(null, 14, 0x000000);
			missionCharmDifText.setFormat(null, 14, 0x000000);
			missionStagesText.setFormat(null, 14, 0x000000);
			
			
			missionInfoText.setFormat(null, 14, 0x000000);
			
			
			
			//todo: make screen look good, give more info
			
			//implement item shop and link purchases to this screen along with 
			//letting the player choose items to bring on the mission
			
			//list player total stats on screen for easy comparison
			
			Registry.gui = new GUI();
		
			add(Registry.gui);
			
			add(missionTable);
			add(missionFolder);
			add(missionPaper1);
			add(missionPaper2);
			
			add(prevPageButton);
			add(nextPageButton);
			add(startButton);
			
			add(missionSelectText);
			
			/*
			add(missionNameText);
			add(missionRewardText);
			add(missionRepText);
			add(missionTimeText);
			add(missionStealthDifText);
			add(missionCombatDifText);
			add(missionCharmDifText);
			add(missionStagesText);
			*/
			
			add(missionInfoText);
			
			super.create();
			FlxG.mouse.show();
			
			
		}
  
		override public function update():void {
			super.update();	
			
			if (Registry.cities[Registry.currentCity].missions.length > 0){ 
				missionSelectText.text = "Mission: " + (page + 1).toString();
			}
			else {
				missionSelectText.text = "No more missions available";
			}
			
		}
		
		public function prevClick():void {
			
			nextPageButton.visible = true;
			
			
			
			if ((page - 1) >= 0 ) {
				page--;
				loadMissionInfo(page);
			}
			
			if (page == 0) {
				missionPaper1.exists = false;
				prevPageButton.visible = false;
			}
			
			
		}
		
		public function nextClick():void {
			if ( (page + 1) < Registry.cities[Registry.currentCity].missions.length ) {
				
				missionPaper1.exists = true;
				prevPageButton.visible = true;
				
				
				page++;
				loadMissionInfo(page);
				
				if ( (page + 1) == Registry.cities[Registry.currentCity].missions.length ) {
					nextPageButton.visible = false;
				}
				
			}
			
		}
		
		public function startClick():void {
			
			Registry.currentState = 6;
			
			FlxG.switchState(new MissionState(Registry.cities[Registry.currentCity].missions[page].type, Registry.cities[Registry.currentCity].missions[page].pattern.slice() ));
		}
		
		
		public function loadMissionInfo(num:int):void {
			
			if (Registry.cities[Registry.currentCity].missions.length > 0){ 
			
				var missionNameText:String = "Type: " + Registry.cities[Registry.currentCity].missions[num].name;
				var missionRewardText:String = "Reward: " + Registry.cities[Registry.currentCity].missions[num].reward.toString();
				var missionRepText:String = "Rep: " + Registry.cities[Registry.currentCity].missions[num].rep.toString();
				
				var missionTimeText:String = "Time: " + Registry.cities[Registry.currentCity].missions[num].length.toString();
				
				var missionCombatDifText:String =  "Combat Difficulty: " + Registry.cities[Registry.currentCity].missions[num].combatDif.toString();
				var missionStealthDifText:String = "Stealth Difficulty: " + Registry.cities[Registry.currentCity].missions[num].stealthDif.toString();
				var missionCharmDifText:String =   "Charm Dificulty: " + Registry.cities[Registry.currentCity].missions[num].charmDif.toString();
				
				var missionStagesText:String =   "Num Stages: " + Registry.cities[Registry.currentCity].missions[num].pattern.length.toString();
				
				missionInfoText.text = missionNameText + "\n" + missionRewardText + "\n" + missionRepText + "\n" + missionTimeText + "\n" + missionCombatDifText + "\n" + missionStealthDifText + "\n" + missionCharmDifText + "\n" + missionStagesText;
				
			}
			else {
				nextPageButton.visible = false;
				startButton.visible = false;
			}
		}
		
		
		
		
	}

}