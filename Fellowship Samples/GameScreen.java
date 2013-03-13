package com.draganviper.fellowship;

import com.badlogic.gdx.Audio;
import com.badlogic.gdx.Game;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.audio.Music;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL10;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.utils.Array;
import com.badlogic.gdx.graphics.g2d.*;


public class GameScreen implements Screen{
	
	Music bgm;
	Audio audio = Gdx.audio;
	
	private OrthographicCamera cam = new OrthographicCamera();
	
	final static int xBlocks = 15;
	final static int yBlocks = 10;
	
	Box boxes2[][] = new Box[xBlocks][yBlocks];
	
	Box newColorBox;
	
	Array<Color> colors = new Array<Color>();

	SpriteBatch spriteBatch = new SpriteBatch();
	
	Texture boxTexture;
	Texture finishTexture;
	Texture sideBarTexture;
	Texture blackBoxTexture;
	
	boolean isTouched = false;
	
	BitmapFont font = new BitmapFont();
	
	//number of moves made
	int moves = 50;
	
	long startTime = System.currentTimeMillis();
	long timeCount = 0;
	long timeLeft = 0;
	long timePenalty = 0;
	long roundDuration = 1000 * 60 * 2;
	
	//the next color to spread, the chosen box to apply it to
	Color nextColor = new Color(Color.WHITE);
	int xBox = 0;
	int yBox = 0;
	
	Array<Pos> toCheck = new Array<Pos>();
	
	String time;
	
	Game g;
	
	
	
	// game mode. 0 = arcade, 1 = time attack, 2 = endless
	int mode = 0;
	
	// counter of how many blocks where changed in the current action
	int numChanged = 0;
	
	GameScreen(Game game, int m){
		g = game;
		mode = m;
		
	}
	
	@Override
	public void render(float delta) {
		
		timeCount = ((System.currentTimeMillis() - startTime ) / 1000);
		
		if (mode == 0){
			//arcade mode
			time = new String("" + ((System.currentTimeMillis() - startTime ) / 1000));
			if (moves <= 0){
				g.setScreen(new ScoreState(g, mode, timeCount, moves, findIsolated()));
			}
		}
		else if (mode == 1){
			//time attack mode
			timeLeft = ((startTime + roundDuration) - System.currentTimeMillis()) / 1000;
			timeLeft -= timePenalty;
			
			if (timeLeft <= 0){
				g.setScreen(new ScoreState(g, mode, timeLeft, moves, findIsolated()));
			}
			
			time = new String("" + timeLeft);
		}
		
		Gdx.gl.glClearColor(1.0f, 1.0f, 1.1f, 1);
	    Gdx.gl.glClear(GL10.GL_COLOR_BUFFER_BIT);
	    spriteBatch.begin();
		spriteBatch.setColor(new Color (Color.WHITE));
		spriteBatch.draw(sideBarTexture,1080, 0);
		spriteBatch.draw(blackBoxTexture,newColorBox.position.x - 4, newColorBox.position.y - 4);
		spriteBatch.end();
	    
		drawSquares();
		spriteBatch.begin();
		
		
		font.draw(spriteBatch, "Next Color",1100 , 700);
		font.draw(spriteBatch, "Time: " + time, 1100, 400);
		font.draw(spriteBatch, "Moves: " + moves, 1100, 300);
		spriteBatch.setColor(new Color (Color.WHITE));
		spriteBatch.draw(finishTexture,1100, 50);
		spriteBatch.end();
		
		isTouched = Gdx.input.justTouched();
		
		if (isTouched == true){
			int xPos = Gdx.input.getX();
			int yPos = Gdx.input.getY();
			
			System.out.println("xPos: " + xPos);
			System.out.println("yPos: " + yPos);
			
			yPos = Gdx.graphics.getHeight() - yPos;
			
			System.out.println("inverted yPos: " + yPos);
			
			if (xPos <= (Box.SIZE * xBlocks) && yPos <= (Box.SIZE * yBlocks) && xPos > 0 && yPos > 0){
				
				
				xPos = (int)(Math.ceil(xPos / Box.SIZE));
				yPos = (int)( Math.ceil(yPos / Box.SIZE));
				System.out.println("xPos: " + xPos);
				System.out.println("yPos: " + yPos);
				
				xBox = xPos;
				yBox = yPos;
				
				spreadColor();
				nextColor = randColor();
				newColorBox.color = new Color(nextColor);
				
				
				//change moves, time based on mode and num of blocks changed
				if (mode == 0){
					moves -= numChanged;
				}
				else if (mode == 1){
					moves += numChanged;
					timePenalty += numChanged;
				}
				else if (mode == 2){
					moves += numChanged;
					
				}
				numChanged = 0;
				
			}
			
			else if (xPos > 1100 && xPos < 1250 && yPos > 50 && yPos < 200){
				
				g.setScreen(new SplashScreen(g));
				
			}
			
		}
		
		
		
	}
	
	public Color randColor(){
		
		return new Color(colors.get( (int)(Math.round(Math.random() * 10)) ));
	}
	
	public void drawSquares() {

		spriteBatch.begin();
		spriteBatch.setColor(Color.BLUE);
	
		for (int j = 0; j < xBlocks; j++){
			for (int i = 0; i < yBlocks; i++){
				spriteBatch.setColor(boxes2[j][i].color);
				spriteBatch.draw(boxTexture, boxes2[j][i].position.x,boxes2[j][i].position.y, Box.SIZE, Box.SIZE);
			}
		}
		
		
		spriteBatch.setColor(newColorBox.color);
		
		spriteBatch.draw(boxTexture, newColorBox.position.x,newColorBox.position.y, Box.SIZE, Box.SIZE);
		
		spriteBatch.end();
	}
	
	public void loadTextures(){

		boxTexture = new Texture(Gdx.files.internal("square.png"));
		finishTexture = new Texture(Gdx.files.internal("mainMenu.png"));
		sideBarTexture = new Texture(Gdx.files.internal("sideBar.png"));
		blackBoxTexture = new Texture(Gdx.files.internal("blackBox.png"));
	}
	
	public void loadSound(){
		
	}
	
	public void spreadColor(){
		//the core gameplay mechanic
		//finds all neighboring boxes of the same color, and recursively causes them to spread the color
		//while also changing own color
		
		toCheck.add(new Pos(xBox, yBox));
		numChanged += 1;
		
		while(toCheck.size > 0){
			Pos temp = toCheck.pop();
			System.out.println("checking " + temp.x + " " + temp.y);
			
			System.out.println("array size: " + toCheck.size);
			
			
			if (temp.x > 0){
				//if not a leftmost box, see if left neighbor is same color
				if (boxes2[temp.x - 1][temp.y].color.equals(boxes2[temp.x][temp.y].color)){
					
					//if it is, add it to the list
					if (toCheck.contains(new Pos(temp.x - 1, temp.y),true) == false){
						if (boxes2[temp.x - 1][temp.y].dirty == false){
							boxes2[temp.x - 1][temp.y].dirty = true;
							toCheck.add(new Pos(temp.x - 1, temp.y));
							numChanged += 1;
						}
					}
				}
				
			}
			
			if (temp.x < xBlocks - 1){
				//if not a rightmost box, see if right neighbor is same color
				if (boxes2[temp.x + 1][temp.y].color.equals(boxes2[temp.x][temp.y].color)){
					//if it is, add it to the list
					if (toCheck.contains(new Pos(temp.x - 1, temp.y),true) == false){
						if (boxes2[temp.x + 1][temp.y].dirty == false){
							boxes2[temp.x + 1][temp.y].dirty = true;
							toCheck.add(new Pos(temp.x + 1, temp.y));
							numChanged += 1;
						}
					}
				}
				
			}
			
			
			if (temp.y > 0){
				//if not a bottom box, see if bottom neighbor is same color
				if (boxes2[temp.x][temp.y - 1].color.equals(boxes2[temp.x][temp.y].color)){
					//if it is, add it to the list
					if (toCheck.contains(new Pos(temp.x - 1, temp.y),true) == false){
						if (boxes2[temp.x][temp.y - 1].dirty == false){
							boxes2[temp.x][temp.y - 1].dirty = true;
							toCheck.add(new Pos(temp.x, temp.y - 1));
							numChanged += 1;
						}
					}
				}
				
			}
			
			
			if (temp.y < yBlocks - 1){
				//if not a topmost box, see if top neighbor is same color
				if (boxes2[temp.x][temp.y + 1].color.equals(boxes2[temp.x][temp.y].color)){
					//if it is, add it to the list
					if (toCheck.contains(new Pos(temp.x - 1, temp.y),true) == false){
						if (boxes2[temp.x][temp.y + 1].dirty == false){
							boxes2[temp.x][temp.y + 1].dirty = true;
							toCheck.add(new Pos(temp.x, temp.y + 1));
							numChanged += 1;
						}
					}
					
				}
				
			}
			
			
			
			//now that all possible neighbors have been added, change the current color
			System.out.println("array size: " + toCheck.size);
			boxes2[temp.x][temp.y].changeColor(nextColor);
			
		}
		
		//set all dirty flags back to false 
		for (int i = 0; i < xBlocks; i ++){
			for (int j = 0; j < yBlocks; j++){
				boxes2[i][j].dirty = false;
			}
		}
		
		
	}
	
	
	public int findIsolated(){
		//counts how many isolated squares there are
		//returns that number
		
		int isolated = 0;
		boolean isIsolated = true;
		
		for ( int i = 0; i < xBlocks; i++){
			for (int j = 0; j < yBlocks; j++){
				
				
				if (i > 0){
					//if not a leftmost box, see if left neighbor is same color
					if (boxes2[i - 1][j].color.equals(boxes2[i][j].color)){
						
						isIsolated = false;

					}
					
				}
				
				if (i < xBlocks - 1){
					//if not a rightmost box, see if right neighbor is same color
					if (boxes2[i + 1][j].color.equals(boxes2[i][j].color)){
						//if it is, add it to the list
						isIsolated = false;
					}
					
				}
				
				
				if (j > 0){
					//if not a bottom box, see if bottom neighbor is same color
					if (boxes2[i][j - 1].color.equals(boxes2[i][j].color)){
						//if it is, add it to the list
						isIsolated = false;
					}
					
				}
				
				
				if (j < yBlocks - 1){
					//if not a topmost box, see if top neighbor is same color
					if (boxes2[i][j + 1].color.equals(boxes2[i][j].color)){
						//if it is, add it to the list
						isIsolated = false;
						
					}
					
				}
				
				if (isIsolated == true){
					isolated++;
				}
				isIsolated = true;
				
				
				
				
			}
		}
		
		
		return isolated;
	}

	@Override
	public void resize(int width, int height) {
		// 
		
	}

	@Override
	public void show() {
		
		if (mode == 1 || mode == 2){
			moves = 0;
		}
		
		font.setColor(new Color(Color.BLACK));
		font.setScale(2, 2);
		
		cam.setToOrtho(false, 1280, 720);
		cam.update();
		
		bgm = audio.newMusic(Gdx.files.internal("DST-2ndBallad.mp3"));
		
		bgm.setLooping(true);
		bgm.play();
		
		
		loadTextures();
		loadSound();
		
		colors.add(Color.BLACK);
		colors.add(Color.BLUE);
		colors.add(Color.WHITE);
		colors.add(Color.CYAN);
		colors.add(Color.RED);
		colors.add(Color.YELLOW);
		colors.add(Color.GREEN);
		colors.add(Color.LIGHT_GRAY);
		colors.add(Color.MAGENTA);
		colors.add(Color.ORANGE);
		colors.add(Color.PINK);
		
		
		
		int id = 0;
		
		for (int i = 0; i < yBlocks; i++){
			for (int j = 0; j < xBlocks; j++){
				
				boxes2[j][i] = new Box(new Vector2(j * Box.SIZE,i * Box.SIZE), randColor(), id);
				id++;
			}
		}
		
		nextColor = randColor();
		newColorBox = new Box( new Vector2(1130,560), new Color(nextColor), -1);
		
		
		
	}

	@Override
	public void hide() {
		bgm.stop();
		bgm.dispose();
	}

	@Override
	public void pause() {
		
	}

	@Override
	public void resume() {
		
	}

	@Override
	public void dispose() {
		
	}

}
