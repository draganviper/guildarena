

package  
{
	/**
	 * ...
	 * @author Maynard Price
	 */
	
	
	
	public class Fighter
	{
		
		
		public var name:String = "Fighter";			//fighter name
		public var hp:int = 100;					//current health
		public var maxHp:int = 100;				//max health
		public var mp:int = 100;					//current magic points
		public var maxMp:int = 100;				//max magic points
		public var lvl:int = 1;				//current level
		public var xp:int = 0;					//current experience
		public var pop:int = 0;				//popularity
		public var sponsor:String = "None";			//current sponsor
		public var guild:String = "None";			//current guild
		
		public var team:int = 0; //which 'team' (side) the fighter is currently on, used for turn decisions
	
		public var wins:int = 0;				//current wins
		public var losses:int = 0;				//current losses
		
		public var fighterType:int = 0;			//basic way of distinguishing swordsman,mage,archer,etc.
		public var fighterTypeName:String = "Fighter";
		
		//there are only 5 sprites and animation states per char: standing still (0), prepare attack (1), attacking (2), being hit (3), and knocked out (4)
		// special skills and spells still use the normal attack sprites, but the 'attack' sprite effect changes as does the actual effect
		// of the action in code and the sound effect that accompanies it
		//fighters dont store their own copies of sprites, they pull them off of a shared library to conserve memory
		//the offset is multiplied by 5 to pull from the correct set of sprites
		//the attack offset determines which attack image appears to hit the enemy on attack
		public var state:int = 0;  
		public var offset:int = 0; //basically, offset 0 means use the set of 5 sprites at the beggining, 4 would get the 5th set
		public var attack:int = 0;
		
		
		
		public var actionID:int = 0; //used by the action targeting function to signal what kind of action to take on the target
									 //a list of actionID's will be here as they come up
									 
		// 0: the default action, attack the target
		// 1: generic magic damage
		// 2: generic heal
		
		
		//an array of true/false flags which show if the fighter can use an action
		//indexed by actionID
		public var actions:Array = new Array();
		
		// position in formation, relative to team
		
		public var x:int;
		public var y:int;
		
		/*
		 *               [0,0][1,0]
		 *               [0,1][1,1]
		 *               [0,2][1,2]
		 */
		
		//stats
		
		public var str:int = 10;			//attack damage is str - def / 2
		public var def:int = 5;
		public var mag:int = 10;            //magic damage is increased by mag, res is subtracted
		public var res:int = 5;
		public var acc:int = 10;            //acc increased hit chance, spd increases dodge chance
		public var spd:int = 10;			//spd determines order of action
		public var crit:int = 5;
		
		public var ct:int = 0;            //charge time, spd is added to each person in order until ct >= 100, then
							   //that person gets a turn and ct decreases based on the action
							   
		public var isAlive:Boolean = true;
		
		// Ai Flags
		// individual flags will effect ai decisions
		
		public var hotheaded:Boolean = false;
		public var logical:Boolean = false;
		public var vengeful:Boolean = false;
		public var calculating:Boolean = false;
		public var protective:Boolean = false;
		public var levelheaded:Boolean = false;
		public var predator:Boolean = false;
		public var chaotic:Boolean = true;
		
		// traits
		// similar to Ai flags, traits will effect calculations and effects
		
		public var hero:Boolean = false;
		public var coward:Boolean = false;
		
		// gifts
		// gifts are rare traits that only a few can ever have at once
		
		public var mysticalEyesOfDeathPerception:Boolean = false;
	
		
		public function Fighter() 
		{
			
			
		}
		
		public function clone():Fighter {
			var tempF:Fighter = new Fighter();
			
			tempF.hp = hp;
			tempF.maxHp = maxHp;
			tempF.mp = mp;
			tempF.maxMp = maxMp;
			
			tempF.lvl = lvl;
			tempF.xp = xp;
			tempF.pop = pop;
			
			tempF.sponsor = sponsor;
			tempF.guild = guild;
			
			tempF.name = name;
			tempF.str = str;
			tempF.def = def;
			tempF.mag = mag;
			tempF.res = res;
			tempF.acc = acc;
			tempF.spd = spd;
			tempF.crit = crit;
			
			tempF.actions = actions.slice();
			
			tempF.offset = offset;
			tempF.attack = attack;
			
			tempF.fighterType = fighterType;
			tempF.fighterTypeName = fighterTypeName;
			
			tempF.wins = wins;
			tempF.losses = losses;
			
			
			tempF.chaotic = chaotic;
			tempF.predator = predator;

			
			return tempF;
		}
		
		public function copy(tempF:Object):void {
			
			
			hp = tempF.hp ;
			maxHp = tempF.maxHp;
			mp = tempF.mp;
			maxMp = tempF.maxMp;
			
			lvl = tempF.lvl;
			xp = tempF.xp;
			pop = tempF.pop;
			
			sponsor = tempF.sponsor;
			guild = tempF.guild;
			
			name = tempF.name;
			str = tempF.str;
			def = tempF.def;
			mag = tempF.mag;
			res = tempF.res;
			acc = tempF.acc;
			spd = tempF.spd;
			crit = tempF.crit;
			
			actions = tempF.actions.slice();
			
			offset = tempF.offset;
			attack = tempF.attack;
			
			fighterType = tempF.fighterType;
			fighterTypeName = tempF.fighterTypeName;
			
			wins = tempF.wins;
			losses = tempF.losses;
			
			
			chaotic = tempF.chaotic;
			predator = tempF.predator;

		}
		
		public function generate():void {
			//a core part of the game concept, whether the game lives or dies
			//will be largely due to how interesting the generation of characters is
			
			//for now, time only permits bounded randomization of base stats
			//this will have to do until more of the game infastructure is worked out
			
			fighterType = Math.round(Math.random() * 1);
			
			var natureGen:int;
			
			if (fighterType == 0){
			//fighter
			
				maxHp = Math.round( Math.random() * 40 ) + 80;  // 80 - 120
				hp = maxHp;
				maxMp = Math.round(Math.random() * 40) + 10; // 10 - 50
				mp = maxMp;
				str = Math.round(Math.random() * 25) + 15; // 15 - 40
				def = Math.round(Math.random() * 10) + 10; // 10 - 20
				spd = Math.round(Math.random() * 5) + 10; // 5 - 15
				mag = Math.round(Math.random() * 25) + 15; // 15 - 40
				res = Math.round(Math.random() * 10) + 5; // 10 - 20
				acc = Math.round(Math.random() * 10) + 10; // 10 - 20
				crit = Math.round(Math.random() * 9) + 1; // 1 - 10
				
				natureGen = Math.round(Math.random() * 1);
				
				offset = 0;
			
			}
			
			else if (fighterType == 1){
			//mage
			
				maxHp = Math.round( Math.random() * 40 ) + 80;  // 80 - 120
				hp = maxHp;
				maxMp = Math.round(Math.random() * 40) + 10; // 10 - 50
				mp = maxMp;
				str = Math.round(Math.random() * 10) + 10; // 15 - 40
				def = Math.round(Math.random() * 10) + 5; // 10 - 20
				spd = Math.round(Math.random() * 5) + 10; // 5 - 15
				mag = Math.round(Math.random() * 25) + 15; // 15 - 40
				res = Math.round(Math.random() * 10) + 15; // 10 - 20
				acc = Math.round(Math.random() * 10) + 10; // 10 - 20
				crit = Math.round(Math.random() * 0) + 1; // 1 - 10
				
				natureGen = Math.round(Math.random() * 1);
				
				offset = 1;
				
				fighterTypeName = "Mage";
			}
			
			
			
			//ai flags
			if (natureGen == 0) {
				chaotic = true;
			}
			else if (natureGen == 1) {
				chaotic = false;
				predator = true;
			}
			
			
			//actions the fighter has
			actions.push(true);				//generic basic attack
			actions.push(false);			//generic magic attack
			actions.push(false);			//generic heal
			
			
		}
		
		public function takeAction():int {
			//called in the fightstate to decide and resolve turn actions
			//data of fighting teams is modified in place in the registry
			//the fightstate will handle animation and sound
			//returns the enemy unit targeted
			
			
			//for now, a random targeting system is used by default
			//this function is going to eventually hold a lot of different cool stuff, the
			//core aspect of what makes the combat between ai interesting really
			//for now though it's just a functional stub until the rest of the framework
			//is up and running
			
			var target:int;
			var seeking:Boolean = true;
			var targetAlly:Boolean = false;
			
			//basic melee uses physical attack, mage uses magical attack
			if (fighterType == 0) {
				actionID = 0;
			}
			else if (fighterType == 1) {
				var injuredTeamate:Boolean = false;
				for (var v:int = 0; v < 3; v++) {
					if (team == 1){
						if ( ( Number(Registry.Team1.f[v].hp) / Number(Registry.Team1.f[v].maxHp) ) < .7 ) {
							if ( Registry.Team1.f[v].hp > 0){
								injuredTeamate = true;
							}
						}
					}
				}
				if (injuredTeamate == true) {
					//only have a chance to heal if there is someone injured but alive
					actionID =  Math.round(Math.random() * 1) + 1;  //heal or deal magic dmg
				}
				else actionID = 1;
			}
			
			if (actionID == 2) {
				targetAlly = true;
			}
			
			while (seeking) {
				
				if (targetAlly == false){
				
					//if nature is chaotic, pick target at random from all valid targets
					if(chaotic == true){
						target = Math.round(Math.random() * 2);
						if (team == 1) {
							if (Registry.Team2.f[target].hp > 0) {
								seeking = false;
							}
							
						}
						else if (team == 2) {
							if (Registry.Team1.f[target].hp > 0) {
								seeking = false;
							}
						}
					}
					
					//if nature is predator, choose the lowest hp valid target
					else if (predator == true) {
						var weakest:int = 999999;
						for (var w:int = 0; w < 3; w++) {
							if (team == 1) {
								if (Registry.Team2.f[w].hp < weakest) {
									if (Registry.Team2.f[w].hp > 0) {
										weakest = Registry.Team2.f[w].hp;
										target = w;
									}
								}
							}
							else if (team == 2) {
								if (Registry.Team1.f[w].hp < weakest) {
									if (Registry.Team1.f[w].hp > 0) {
										weakest = Registry.Team1.f[w].hp;
										target = w;
									}
								}
							}
						}
						
						seeking = false;
					}
				
				
				}
				
				else if (targetAlly == true) {
					if (actionID == 2) {
						//heal
						
						var weakestAlly:int = 999999;
						for (var wA:int = 0; wA < 3; wA++) {
							if (team == 1) {
								if (Registry.Team1.f[wA].hp < weakestAlly) {
									if ( (Registry.Team1.f[wA].hp > 0 ) && (Registry.Team1.f[wA].hp < Registry.Team1.f[wA].maxHp) ) {
										weakest = Registry.Team1.f[wA].hp;
										target = wA;
									}
								}
							}
							else if (team == 2) {
								if (Registry.Team2.f[wA].hp < weakestAlly) {
									if ( (Registry.Team2.f[wA].hp > 0) && ( Registry.Team2.f[wA].hp < Registry.Team2.f[wA].maxHp )) {
										weakest = Registry.Team2.f[wA].hp;
										target = wA;
									}
								}
							}
						}
						
						seeking = false;
						
					}
				}
				
				
				
				
			}
			
			
			
			return target;
			
		}
		
	
	}

}