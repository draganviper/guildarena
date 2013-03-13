package
{
	
	/**
	 * ...
	 * @author Maynard Price
	 */
	
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxButtonPlus;
	import org.flixel.plugin.photonstorm.FlxDelay;

	public class MissionState extends FlxState {
		
		//this is the mission state propor
		//the navigation buttons will be locked while in this state, as
		//it is essentially a cutscene.
		//control will be returned when the cutscene ends and the state automatically changes
		
		public var m:Mission;
		
		//the mission state will contain here all the images that will be used to represent things happening on screen
		[Embed(source = "../img/m_scene_charm_f.png")] protected var m_scene_charm_f:Class;
		[Embed(source = "../img/m_scene_charm_s.png")] protected var m_scene_charm_s:Class;
		[Embed(source = "../img/m_scene_combat_f.png")] protected var m_scene_combat_f:Class;
		[Embed(source = "../img/m_scene_combat_s.png")] protected var m_scene_combat_s:Class;
		[Embed(source = "../img/m_scene_stealth_f.png")] protected var m_scene_stealth_f:Class;
		[Embed(source = "../img/m_scene_stealth_s.png")] protected var m_scene_stealth_s:Class;
		
		[Embed(source = "../img/mission_success.png")] protected var mission_success:Class;
		[Embed(source = "../img/mission_failure.png")] protected var mission_failure:Class;
		[Embed(source = "../img/start_mission.png")] protected var mission_start:Class;
		
		[Embed(source = "../img/cutscene_bar.png")] protected var cutscene_bar:Class;
		
		
		public var cs_bar1:FlxSprite = new FlxSprite(0, 0, cutscene_bar);
		public var cs_bar2:FlxSprite = new FlxSprite(0, 500, cutscene_bar);
		
		//this sprite will be overwritten with the current class image using loadGraphic
		public var missionScene:FlxSprite = new FlxSprite(0, 100);		
		

		public var missionText:FlxText = new FlxText(50, 20, 380, "Mission in progress...");
		
		public var acceptResultButton:FlxButtonPlus = new FlxButtonPlus(230, 440, acceptClick, null, "Ok", 50, 50);
		
		public var flashDuration:Number = .5;
		public var sceneSwapTime:int = 1500;
		public var sceneTimer:FlxDelay = new FlxDelay(sceneSwapTime);
		
		
		public var missionOver:Boolean = false;
		public var failure:Boolean = false;
		public var finalFlash:Boolean = false;
		
		
		public var criticalFail:Boolean = false;
		
		
		
		override public function MissionState(t:int, p:Array):void {
			super();
			m = new Mission(t, p);
			acceptResultButton.exists = false;
		}
		
		
		override public function create():void {
			
			FlxG.camera.flash(0xff000000, flashDuration);
			
			Registry.playerOrg.money -= m.reward / 4;
			if (Registry.playerOrg.money < 0) Registry.playerOrg.money = 0;
			
			Registry.greyOut = true;
			missionScene.loadGraphic(mission_start);
			
			sceneTimer.start();
			
			
			
			
			
			missionText.setFormat(null, 22, 0xFFFFFF);
			
			
			Registry.gui = new GUI();
		
			add(Registry.gui);
			
			add(missionScene);
			add(acceptResultButton);
			
			
			
			add(cs_bar1);
			add(cs_bar2);
			
			
			
			super.create();
			FlxG.mouse.show();
			
			
		}
		
		
		
  
		override public function update():void {
			super.update();	
			
			
			
			
			if (missionOver == false){
			
				if (sceneTimer.hasExpired()) {
					FlxG.camera.flash(0xff000000, flashDuration);
					
					var result:int = changeMissionScene();
					if (result == 0 || result == 2) {
						//failure or critical failure
						resolveFailure(result);
					}
					else if (result == 1) {
						//successfully completed this part, reset timer for next part
						sceneTimer.reset(sceneSwapTime);
					}
					else if (result == -1) {
						//success!
						
						//these are for completion of the whole mission
						Registry.playerOrg.money += m.reward;
						Registry.playerOrg.reputation += m.rep;
						
						missionOver = true;
						missionScene.loadGraphic(mission_success);
						acceptResultButton.exists = true;
						
						
					}
					
				}
			}
			else if (failure == true) {
				if (sceneTimer.hasExpired()) {
					if (finalFlash == false){
						FlxG.camera.flash(0xff000000, flashDuration);
						missionScene.loadGraphic(mission_failure);
						finalFlash = true;
						acceptResultButton.exists = true;
						
						//critical failure, serious consequences
						//right now it just means game over no matter what
						
						//TODO: create a list of effects for critical failure
						//with game over being the worst case scenario
						//for repeat critical failures
						if (criticalFail == true){
							FlxG.switchState(new GameOverState());
						}
					}
				}
			}
			
		}
		
		public function acceptClick():void {
			
			//callback function for the end of mission button
			
			Registry.greyOut = false;
			Registry.addDays(m.length);
			//if mission was completed, remove it from the missions available board
			//if the mission failed leave the job posting up
			if (failure == false) Registry.cities[Registry.currentCity].missions.splice(Registry.cities[Registry.currentCity].missions.indexOf(m),1);
			FlxG.switchState(new HomeState());
		}
		
		public function resolveFailure(result:int):void {
			//handle some flags and consequences of failure
			missionOver = true;
			failure = true;
			sceneTimer.reset(sceneSwapTime);
			Registry.playerOrg.reputation -= m.rep;
			if (Registry.playerOrg.reputation < 0) Registry.playerOrg.reputation = 0;
			
		}
		
		public function changeMissionScene():int {
			//function for advancing the scene in a mission
			//returns -1 when mission is over
			//returns 1 if the section loaded was successful
			//returns 0 for failure, 2 for critical failure
			//loads the graphic for missionScene based on what's appropriate
			
			
			var result:int = m.resolveNextPart();
			
			if (result == -1) {
				//mission complete
				return -1;
			}
			
			if (m.pattern[m.progress] == 0) {
				//stealth scene
				if (result == 0) {
					//failure
					missionScene.loadGraphic(m_scene_stealth_f);
				}
				else if (result == 1) {
					//success
					missionScene.loadGraphic(m_scene_stealth_s);
				}
				else if (result == 2) {
					//critical failure
					missionScene.loadGraphic(m_scene_stealth_f);
				}
				
			}
			if (m.pattern[m.progress] == 1) {
				//combat scene
				if (result == 0) {
					//failure
					missionScene.loadGraphic(m_scene_combat_f);
				}
				else if (result == 1) {
					//success
					missionScene.loadGraphic(m_scene_combat_s);
				}
				else if (result == 2) {
					//critical failure
					missionScene.loadGraphic(m_scene_combat_f);
				}
				
			}
			if (m.pattern[m.progress] == 2) {
				//charm scene
				if (result == 0) {
					//failure
					missionScene.loadGraphic(m_scene_charm_f);
				}
				else if (result == 1) {
					//success
					missionScene.loadGraphic(m_scene_charm_s);
				}
				else if (result == 2) {
					//critical failure
					missionScene.loadGraphic(m_scene_charm_f);
				}
				
			}
			if (m.pattern[m.progress] == 3) {
				//stealth + combat scene
				if (result == 0) {
					//failure
					missionScene.loadGraphic(m_scene_stealth_f);
				}
				else if (result == 1) {
					//success
					missionScene.loadGraphic(m_scene_stealth_s);
				}
				else if (result == 2) {
					//critical failure
					missionScene.loadGraphic(m_scene_stealth_f);
				}
				
			}
			if (m.pattern[m.progress] == 4) {
				//stealth + charm scene
				if (result == 0) {
					//failure
					missionScene.loadGraphic(m_scene_stealth_f);
				}
				else if (result == 1) {
					//success
					missionScene.loadGraphic(m_scene_stealth_s);
				}
				else if (result == 2) {
					//critical failure
					missionScene.loadGraphic(m_scene_stealth_f);
				}
				
			}
			if (m.pattern[m.progress] == 5) {
				//stealth + combat + charm scene
				if (result == 0) {
					//failure
					missionScene.loadGraphic(m_scene_stealth_f);
				}
				else if (result == 1) {
					//success
					missionScene.loadGraphic(m_scene_stealth_s);
				}
				else if (result == 2) {
					//critical failure
					missionScene.loadGraphic(m_scene_stealth_f);
				}
				
			}
			if (m.pattern[m.progress] == 6) {
				//combat + charm scene
				if (result == 0) {
					//failure
					missionScene.loadGraphic(m_scene_combat_f);
				}
				else if (result == 1) {
					//success
					missionScene.loadGraphic(m_scene_combat_s);
				}
				else if (result == 2) {
					//critical failure
					missionScene.loadGraphic(m_scene_combat_f);
				}
				
			}
			
			
			
			if (result == 0 ) {
				
				return result;
			}
			else if (result == 2) {
				criticalFail = true;
				return result;
			}
			
			
			else return 1;
			
		}
		
		
		
	}

}