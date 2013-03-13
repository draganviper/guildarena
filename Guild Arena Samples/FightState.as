package
{
	
	/**
	 * ...
	 * @author Maynard Price
	 */
	
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxBar;
	import org.flixel.plugin.photonstorm.FlxButtonPlus;
	import mx.utils.*;
	import Registry;
	
	public class FightState extends FlxState
	{
		
		public var charging:Boolean = true;
		
		//1 = team 1, 2 = team 2
		public var teamTurn:int = 0;
		//which fighter on that team is taking a turn, 0,1,2
		public var fighterTurn:int = 0;
		
		public var actionDecided:Boolean = false;
		public var actionTarget:int = 0;
		
		public var animationTimer:FlxTimer = new FlxTimer();
		public var endActionTimer:FlxTimer = new FlxTimer();
		public var victoryDelayTimer:FlxTimer = new FlxTimer();
		
		public var vicCountdownStarted:Boolean = false;
		
		public var actionSnd:FlxSound = new FlxSound();
		
		// two arrays containing the sprites for the two teams
		// more efficient to have a registry of images and use them as needed then to give
		// every fighter its own copy
		public var t1Sprites:Array = new Array();
		public var t2Sprites:Array = new Array();
		
		public var guiFighterNames:Array = new Array();
		
		public var guiFighterBars:Array = new Array();
		
		[Embed(source="../img/fightScreen.png")]
		protected var fightStatePNG:Class;
		public var fightStateBackground:FlxSprite = new FlxSprite(0, 0, fightStatePNG);
		
		override public function create():void
		{
			
			//restore all fighters to max power
			for (var r:int = 0; r < 3; r++)
			{
				Registry.Team1.f[r].hp = Registry.Team1.f[r].maxHp;
				Registry.Team1.f[r].mp = Registry.Team1.f[r].maxMp;
				Registry.Team1.f[r].team = 1;
				Registry.Team1.f[r].state = 0;
				Registry.Team2.f[r].hp = Registry.Team2.f[r].maxHp;
				Registry.Team2.f[r].mp = Registry.Team2.f[r].maxMp;
				Registry.Team2.f[r].team = 2;
				Registry.Team2.f[r].state = 0;
			}
			
			add(fightStateBackground);
			
			guiInit();
			
			trace("Begin FightState");
			
			for (var i:int = 0; i < 3; i++)
			{
				t1Sprites.push(new FlxSprite());
				
				t1Sprites[i].loadGraphic(Registry.fighterLib[5 * (Registry.Team1.f[i].offset) + Registry.Team1.f[i].state], false, false);
				
				t2Sprites.push(new FlxSprite());
				t2Sprites[i].loadGraphic(Registry.fighterLib[5 * (Registry.Team2.f[i].offset) + Registry.Team2.f[i].state], false, true);
				
				add(t1Sprites[i]);
				add(t2Sprites[i]);
				
			}
			
			t1Sprites[0].x = 200;
			t1Sprites[0].y = 120;
			t1Sprites[1].x = 350;
			t1Sprites[1].y = 270;
			t1Sprites[2].x = 200;
			t1Sprites[2].y = 420;
			
			t2Sprites[0].x = 900;
			t2Sprites[0].y = 120;
			t2Sprites[0].facing = FlxObject.LEFT;
			t2Sprites[1].x = 750;
			t2Sprites[1].y = 270;
			t2Sprites[1].facing = FlxObject.LEFT;
			t2Sprites[2].x = 900;
			t2Sprites[2].y = 420;
			t2Sprites[2].facing = FlxObject.LEFT;
			
			super.create();
			//FlxG.mouse.show();
		
		}
		
		override public function update():void
		{
			super.update();
			
			if (Registry.victory != 0)
			{
				if (vicCountdownStarted == false)
				{
					vicCountdownStarted = true;
					victoryDelayTimer.start(2, 1, victory);
				}
				
			}
			//either someone is taking a turn, or it's between turns and the next fighter to move is being checked
			
			//if between turns, charge up fighter ct by adding speed, stop when you get the first person at 100 ct
			if (charging == true)
			{
				
				for (var i:int = 0; i < 3; i++)
				{
					if (Registry.Team1.f[i].hp > 0)
					{
						Registry.Team1.f[i].ct += Registry.Team1.f[i].spd;
					}
				}
				for (var j:int = 0; j < 3; j++)
				{
					if (Registry.Team2.f[j].hp > 0)
					{
						Registry.Team2.f[j].ct += Registry.Team2.f[j].spd;
					}
				}
				
				for (var k:int = 0; k < 3; k++)
				{
					if (Registry.Team1.f[k].ct >= 100)
					{
						if (Registry.Team1.f[k].hp > 0)
						{
							teamTurn = 1;
							fighterTurn = k;
							charging = false;
							break;
						}
					}
				}
				for (var l:int = 0; l < 3; l++)
				{
					if (Registry.Team2.f[l].ct >= 100)
					{
						if (Registry.Team2.f[l].hp > 0)
						{
							teamTurn = 2;
							fighterTurn = l;
							charging = false;
							break;
						}
					}
				}
				
			}
			
			//if someone is taking a turn first find what their action will be, then animate and resolve
			if (charging == false)
			{
				
				if (Registry.victory == 0)
				{
					
					//call the fighter's action function which decides and resolves actions
					if (teamTurn == 1)
					{
						if (actionDecided == false)
						{
							trace("Team 1 fighter " + Registry.Team1.f[fighterTurn].name + " taking action");
							actionDecided = true;
							actionTarget = Registry.Team1.f[fighterTurn].takeAction();
							
							if (Registry.Team1.f[fighterTurn].actionID == 2) {
								trace("Healing teamate who has " + Registry.Team1.f[actionTarget].hp + " hp");
							}
							else {
								trace("Attacking enemy who has " + Registry.Team2.f[actionTarget].hp + " hp");
							}
							
							//set fighter state from rest to prepare attack on 1 second delay
							//adjust sprite to match new state
							Registry.Team1.f[fighterTurn].state = 1;
							animationTimer.start(1, 1, animateAction);
							
							//adjust sprite here
							t1Sprites[fighterTurn].loadGraphic(Registry.fighterLib[5 * (Registry.Team1.f[fighterTurn].offset) + Registry.Team1.f[fighterTurn].state], false, false);
						}
						
					}
					
					else if (teamTurn == 2)
					{
						if (actionDecided == false)
						{
							trace("Team 2 fighter " + Registry.Team2.f[fighterTurn].name + " taking action");
							actionDecided = true;
							actionTarget = Registry.Team2.f[fighterTurn].takeAction();
							
							if (Registry.Team2.f[fighterTurn].actionID == 2) {
								trace("Healing teamate who has " + Registry.Team2.f[actionTarget].hp + " hp");
							}
							else {
								trace("Attacking enemy who has " + Registry.Team1.f[actionTarget].hp + " hp");
							}
							
							Registry.Team2.f[fighterTurn].state = 1;
							animationTimer.start(1, 1, animateAction);
							
							//adjust sprite here
							t2Sprites[fighterTurn].facing = FlxObject.RIGHT;
							t2Sprites[fighterTurn].loadGraphic(Registry.fighterLib[5 * (Registry.Team2.f[fighterTurn].offset) + Registry.Team2.f[fighterTurn].state], false, true);
							t2Sprites[fighterTurn].facing = FlxObject.LEFT;
							
						}
						
					}
					
				}
				
			}
		
		}
		
		public function animateAction(Timer:FlxTimer):void
		{
			trace("action target: " + actionTarget);
			if (teamTurn == 1)
			{
				//set fighter state to 'strike' from 'prepare attack'
				//adjust sprite to match state
				Registry.Team1.f[fighterTurn].state = 2;
				t1Sprites[fighterTurn].loadGraphic(Registry.fighterLib[5 * (Registry.Team1.f[fighterTurn].offset) + Registry.Team1.f[fighterTurn].state], false, false);
				
				if (Registry.Team1.f[fighterTurn].actionID != 2)
				{
					Registry.Team2.f[actionTarget].state = 3;
					t2Sprites[actionTarget].facing = FlxObject.RIGHT;
					t2Sprites[actionTarget].loadGraphic(Registry.fighterLib[5 * (Registry.Team2.f[actionTarget].offset) + Registry.Team2.f[actionTarget].state], false, true);
					t2Sprites[actionTarget].facing = FlxObject.LEFT;
				}
				
				//adjust sprites here	
				
				//play action sound effect now
				
				//now adjust gui: hp,mp,ct, etc
				
				if (Registry.Team1.f[fighterTurn].actionID == 0)
				{
					//attack the target
					//deal dmg == str - def/2
					
					//load and play the appropriate sound, assume basic hit
					actionSnd.loadEmbedded(Registry.sndLib[0]);
					actionSnd.play();
					
					Registry.Team2.f[actionTarget].hp -= Registry.Team1.f[fighterTurn].str - (Registry.Team2.f[actionTarget].def / 2);
					if (Registry.Team2.f[actionTarget].hp <= 0)
					{
						Registry.Team2.f[actionTarget].hp = 0;
						Registry.t2ko += 1;
						actionSnd.loadEmbedded(Registry.sndLib[3]);
						actionSnd.play();
						if (Registry.t2ko == 3)
						{
							Registry.victory = 1;
						}
						
					}
				}
				
				else if (Registry.Team1.f[fighterTurn].actionID == 1)
				{
					//attack the target
					//deal dmg == mag - def/2
					
					//load and play the appropriate sound, assume basic hit
					actionSnd.loadEmbedded(Registry.sndLib[1]);
					actionSnd.play();
					
					Registry.Team2.f[actionTarget].hp -= Registry.Team1.f[fighterTurn].mag - (Registry.Team2.f[actionTarget].res / 2);
					if (Registry.Team2.f[actionTarget].hp <= 0)
					{
						Registry.Team2.f[actionTarget].hp = 0;
						Registry.t2ko += 1;
						actionSnd.loadEmbedded(Registry.sndLib[3]);
						actionSnd.play();
						if (Registry.t2ko == 3)
						{
							Registry.victory = 1;
						}
						
					}
				}
				
				else if (Registry.Team1.f[fighterTurn].actionID == 2)
				{
					//heal target
					
					//load and play the appropriate sound, assume basic hit
					actionSnd.loadEmbedded(Registry.sndLib[2]);
					actionSnd.play();
					
					Registry.Team1.f[actionTarget].hp += Registry.Team1.f[fighterTurn].mag;
					if (Registry.Team1.f[actionTarget].hp > Registry.Team1.f[actionTarget].maxHp)
					{
						Registry.Team1.f[actionTarget].hp = Registry.Team1.f[actionTarget].maxHp;
						
					}
				}
				
				Registry.Team1.f[fighterTurn].ct -= 100;
				
				//set timer to reset fighter positions
				Registry.Team1.f[fighterTurn].state = 0;
				if (Registry.Team1.f[fighterTurn].actionID == 2)
				{
					Registry.Team1.f[actionTarget].state = 0;
				}
				else
				{
					Registry.Team2.f[actionTarget].state = 0;
				}
				
				endActionTimer.start(1, 1, endAction);
			}
			
			else if (teamTurn == 2)
			{
				Registry.Team2.f[fighterTurn].state = 2;
				Registry.Team1.f[actionTarget].state = 3;
				//adjust sprites here
				t2Sprites[fighterTurn].facing = FlxObject.RIGHT;
				t2Sprites[fighterTurn].loadGraphic(Registry.fighterLib[5 * (Registry.Team2.f[fighterTurn].offset) + Registry.Team2.f[fighterTurn].state], false, true);
				t2Sprites[fighterTurn].facing = FlxObject.LEFT;
				
				if (Registry.Team2.f[fighterTurn].actionID != 2)
				{
					t1Sprites[actionTarget].loadGraphic(Registry.fighterLib[5 * (Registry.Team1.f[actionTarget].offset) + Registry.Team1.f[actionTarget].state], false, false);
				}
				
				if (Registry.Team2.f[fighterTurn].actionID == 0)
				{
					actionSnd.loadEmbedded(Registry.sndLib[0]);
					actionSnd.play();
					Registry.Team1.f[actionTarget].hp -= Registry.Team2.f[fighterTurn].str - (Registry.Team1.f[actionTarget].def / 2);
					if (Registry.Team1.f[actionTarget].hp <= 0)
					{
						actionSnd.loadEmbedded(Registry.sndLib[3]);
						actionSnd.play();
						Registry.Team1.f[actionTarget].hp = 0;
						Registry.t1ko += 1;
						if (Registry.t1ko == 3)
						{
							Registry.victory = 2;
						}
					}
				}
				
				else if (Registry.Team2.f[fighterTurn].actionID == 1)
				{
					actionSnd.loadEmbedded(Registry.sndLib[1]);
					actionSnd.play();
					Registry.Team1.f[actionTarget].hp -= Registry.Team2.f[fighterTurn].mag - (Registry.Team1.f[actionTarget].res / 2);
					if (Registry.Team1.f[actionTarget].hp <= 0)
					{
						actionSnd.loadEmbedded(Registry.sndLib[3]);
						actionSnd.play();
						Registry.Team1.f[actionTarget].hp = 0;
						Registry.t1ko += 1;
						if (Registry.t1ko == 3)
						{
							Registry.victory = 2;
						}
					}
				}
				
				else if (Registry.Team2.f[fighterTurn].actionID == 2)
				{
					//heal target
					
					//load and play the appropriate sound, assume basic hit
					actionSnd.loadEmbedded(Registry.sndLib[2]);
					actionSnd.play();
					
					Registry.Team2.f[actionTarget].hp += Registry.Team2.f[fighterTurn].mag;
					if (Registry.Team2.f[actionTarget].hp > Registry.Team2.f[actionTarget].maxHp)
					{
						Registry.Team2.f[actionTarget].hp = Registry.Team2.f[actionTarget].maxHp;
						
					}
				}
				
				Registry.Team2.f[fighterTurn].ct -= 100;
				
				//reset states
				Registry.Team2.f[fighterTurn].state = 0;
				if (Registry.Team2.f[fighterTurn].actionID == 2)
				{
					Registry.Team2.f[actionTarget].state = 0;
				}
				else
				{
					Registry.Team1.f[actionTarget].state = 0;
				}
				endActionTimer.start(1, 1, endAction);
			}
		
		}
		
		public function endAction(Timer:FlxTimer):void
		{
			
			//set sprite images to idle
			if (teamTurn == 1)
			{
				if (Registry.Team2.f[actionTarget].hp == 0)
				{
					Registry.Team2.f[actionTarget].state = 4;
				}
				
				if (Registry.Team1.f[fighterTurn].actionID == 2)
				{
					t1Sprites[fighterTurn].loadGraphic(Registry.fighterLib[5 * (Registry.Team1.f[fighterTurn].offset) + Registry.Team1.f[fighterTurn].state], false, false);
					
				}
				
				else
				{
					t2Sprites[actionTarget].facing = FlxObject.RIGHT;
					t2Sprites[actionTarget].loadGraphic(Registry.fighterLib[5 * (Registry.Team2.f[actionTarget].offset) + Registry.Team2.f[actionTarget].state], false, true);
					t2Sprites[actionTarget].facing = FlxObject.LEFT;
					t1Sprites[fighterTurn].loadGraphic(Registry.fighterLib[5 * (Registry.Team1.f[fighterTurn].offset) + Registry.Team1.f[fighterTurn].state], false, false);
				}
			}
			
			else if (teamTurn == 2)
			{
				if (Registry.Team1.f[actionTarget].hp == 0)
				{
					Registry.Team1.f[actionTarget].state = 4;
				}
				
				if (Registry.Team2.f[fighterTurn].actionID == 2)
				{
					t2Sprites[fighterTurn].facing = FlxObject.RIGHT;
					t2Sprites[fighterTurn].loadGraphic(Registry.fighterLib[5 * (Registry.Team2.f[fighterTurn].offset) + Registry.Team2.f[fighterTurn].state], false, true);
					t2Sprites[fighterTurn].facing = FlxObject.LEFT;
					
				}
				
				else
				{
					t2Sprites[fighterTurn].facing = FlxObject.RIGHT;
					t2Sprites[fighterTurn].loadGraphic(Registry.fighterLib[5 * (Registry.Team2.f[fighterTurn].offset) + Registry.Team2.f[fighterTurn].state], false, true);
					t2Sprites[fighterTurn].facing = FlxObject.LEFT;
					t1Sprites[actionTarget].loadGraphic(Registry.fighterLib[5 * (Registry.Team1.f[actionTarget].offset) + Registry.Team1.f[actionTarget].state], false, false);
				}
			}
			//reset turn control flags
			
			teamTurn = 0;
			fighterTurn = 0;
			charging = true;
			actionDecided = false;
			actionTarget = 0;
		}
		
		public function victory(Timer:FlxTimer):void
		{
			FlxG.switchState(new VictoryState());
		}
		
		public function guiInit():void
		{
			//create and set the location of the gui information
			//names, hp, mp, ct, team name, etc.
			guiFighterBars.push(new FlxBar(50, 620, FlxBar.FILL_LEFT_TO_RIGHT, 100, 20, Registry.Team1.f[0], "hp", 0, Registry.Team1.f[0].maxHp, true));
			guiFighterBars.push(new FlxBar(50, 660, FlxBar.FILL_LEFT_TO_RIGHT, 100, 20, Registry.Team1.f[1], "hp", 0, Registry.Team1.f[1].maxHp, true));
			guiFighterBars.push(new FlxBar(50, 700, FlxBar.FILL_LEFT_TO_RIGHT, 100, 20, Registry.Team1.f[2], "hp", 0, Registry.Team1.f[2].maxHp, true));
			guiFighterBars.push(new FlxBar(900, 620, FlxBar.FILL_LEFT_TO_RIGHT, 100, 20, Registry.Team2.f[0], "hp", 0, Registry.Team2.f[0].maxHp, true));
			guiFighterBars.push(new FlxBar(900, 660, FlxBar.FILL_LEFT_TO_RIGHT, 100, 20, Registry.Team2.f[1], "hp", 0, Registry.Team2.f[1].maxHp, true));
			guiFighterBars.push(new FlxBar(900, 700, FlxBar.FILL_LEFT_TO_RIGHT, 100, 20, Registry.Team2.f[2], "hp", 0, Registry.Team2.f[2].maxHp, true));
			
			guiFighterNames.push(new FlxText(50, 600, 400, Registry.Team1.f[0].name));
			guiFighterNames.push(new FlxText(50, 640, 400, Registry.Team1.f[1].name));
			guiFighterNames.push(new FlxText(50, 680, 400, Registry.Team1.f[2].name));
			guiFighterNames.push(new FlxText(900, 600, 400, Registry.Team2.f[0].name));
			guiFighterNames.push(new FlxText(900, 640, 400, Registry.Team2.f[1].name));
			guiFighterNames.push(new FlxText(900, 680, 400, Registry.Team2.f[2].name));
			
			for (var i:int = 0; i < 6; i++)
			{
				add(guiFighterBars[i]);
				guiFighterNames[i].color = 0x000000;
				guiFighterNames[i].size = 12;
				add(guiFighterNames[i]);
			}
		
		}
	
	}

}