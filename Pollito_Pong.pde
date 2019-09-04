/********* POLLITO PONG *********/

// 0: PANTALLA INICIAL
// 1: PANTALLA DE JUEGO(IZQUIERDA USUARIO, DERECHA IA)
// 2: PANTALLA PUNTUACIÓN
// 3: PANTALLA RESUMEN

// IMAGEN DEL POLLITO
PImage pollito;

// VARIABLES DEL JUEGO
//para el usuario
int gameScreen        = 0;
Pelota pltuser        = new Pelota();
Raqueta rckuser       = new Raqueta();
Escenario escuser     = new Escenario(color(153, 54, 54));
boolean gameOverUser  = false;

//para la IA (JR)
Pelota pltjr          = new Pelota();
Raqueta rckjr         = new Raqueta();
Escenario escjr       = new Escenario(color(44, 62, 80));
boolean gameOverJr    = false;

// AJUESTES DEL JUEGO
float gravity         = .3;
float airfriction     = 0.00001;
float friction        = 0.1;

// DIVISIÓN DE LAS PANTALLAS
PGraphics user, jr, div;

/*****************************************************************************************************
* CREACIÓN DE LAS CLASES
*****************************************************************************************************/

/************************* CLASE PELOTA ***********************************/

public class Pelota{
  // Configuración inicial
  float ballX             = width/2;
  float ballY             = 0;
  float ballSpeedVert     = 0;
  float ballSpeedHorizon  = 0;
  float ballSize          = 30;
  color ballColor         = color(0);
  
  // Puntaje
  int score               = 0;
  int maxHealth           = 100;
  float health            = maxHealth;
  float healthDecrease    = 1;
  int healthBarWidth      = 60;
  
  void drawBall(PGraphics screen) {
    screen.imageMode(CENTER);
    screen.image(pollito, ballX, ballY, ballSize, ballSize);
  }
  
  void applyGravity() {
    ballSpeedVert += gravity;
    ballY         += ballSpeedVert;
    ballSpeedVert -= (ballSpeedVert * airfriction);
  }
  
  void applyHorizontalSpeed() {
    ballX += ballSpeedHorizon;
    ballSpeedHorizon -= (ballSpeedHorizon * airfriction);
  }
  
  // Mantener la pelota en pantalla
  void keepInScreen() {
    // Inferior
    if (ballY+(ballSize/2) > height) { 
      makeBounceBottom(height);
    }
    
    // Superior
    if (ballY-(ballSize/2) < 0) {
      makeBounceTop(0);
    }
    
    // Izquierda
    if (ballX-(ballSize/2) < 0) {
      makeBounceLeft(0);
    }
    
    // Derecha
    if (ballX+(ballSize/2) > width/2) {
      makeBounceRight(width/2);
    }
  }
  
  // ball falls and hits the floor (or other surface) 
  void makeBounceBottom(float surface) {
    ballY          = surface - (ballSize/2);
    ballSpeedVert *= -1;
    ballSpeedVert -= (ballSpeedVert * friction);
  }
  
  // ball rises and hits the ceiling (or other surface)
  void makeBounceTop(float surface) {
    ballY          = surface + (ballSize/2);
    ballSpeedVert *= -1;
    ballSpeedVert -= (ballSpeedVert * friction);
  }
  
  // ball hits object from left side
  void makeBounceLeft(float surface) {
    ballX             = surface + (ballSize/2);
    ballSpeedHorizon *= -1;
    ballSpeedHorizon -= (ballSpeedHorizon * friction);
  }
  
  // ball hits object from right side
  void makeBounceRight(float surface) {
    ballX             = surface - (ballSize/2);
    ballSpeedHorizon *= -1;
    ballSpeedHorizon -= (ballSpeedHorizon * friction);
  }
  
  void drawHealthBar(PGraphics screen) {
    screen.noStroke();
    screen.fill(189, 195, 199);
    screen.rectMode(CORNER);
    screen.rect(this.ballX-(healthBarWidth/2), ballY - 30, healthBarWidth, 5);
    if (health > 60) {
      screen.fill(46, 204, 113);
    } else if (health > 30) {
      screen.fill(230, 126, 34);
    } else {
      screen.fill(231, 76, 60);
    }
    screen.rect(ballX-(healthBarWidth/2), ballY - 30, healthBarWidth*(health/maxHealth), 5);
  }
  
  void decreaseHealth() {
    health -= healthDecrease;
    if (health <= 0) {
      gameOver(); //Llamar al método en la clase principal
    }
  }
}


/*************************** CLASE RAQUETA ***********************************/

class Raqueta{
  // Configuración incial
  float racketX       = 0;
  float racketY       = height;
  color racketColor   = color(0);
  float racketWidth   = 100;
  float racketHeight  = 10;
  int IASpeed         = 10;
    
  void drawRacket(PGraphics screen) {
    screen.fill(racketColor);
    screen.rectMode(CENTER);
    if (screen == user){
      if(mouseX < 600){
        screen.rect(mouseX, mouseY, racketWidth, racketHeight, 5);
      }else{
        screen.rect(600, mouseY, racketWidth, racketHeight, 5);
      }
    }else{
      screen.rect(racketX, racketY, racketWidth, racketHeight, 5);
    }
  }
  
  void watchRacketBounce(Pelota ball) {
    float x;
    float y;
    float overhead;
    if(ball == pltuser){
      overhead = mouseY - pmouseY;
      x        = mouseX;
      y        = mouseY;
    }else{
      overhead = -1;
      x        = racketX;
      y        =racketY;
    }
    
    if ((ball.ballX+(ball.ballSize/2) > x-(racketWidth/2)) && (ball.ballX-(ball.ballSize/2) < x+(racketWidth/2))) {
      if (dist(ball.ballX, ball.ballY, ball.ballX, y)<=(ball.ballSize/2)+abs(overhead)) {
        ball.makeBounceBottom(y);
        ball.ballSpeedHorizon = (ball.ballX - x)/10;
        // Si se mueve hacia arriba
        if (overhead<0) {
          ball.ballY+=(overhead/2);
          ball.ballSpeedVert+=(overhead/2);
        }
      }
    }
  }
  
  void IARaqueta(int posx, int miny, int ancho, Pelota ball){
    if(racketX<ball.ballX+ball.ballSize/2){
      racketX += IASpeed;
    }
    
    if(racketX>ball.ballX+ball.ballSize/2){
      racketX -= IASpeed;
    }
    
    if(racketX+racketWidth/2 < posx+ancho && racketX+racketWidth/2 > posx-60){
      
      if (racketY < miny-10){
        racketY += IASpeed;
      }
      if (racketY > miny-10){
        racketY -= IASpeed;
      }
    }
    
    if(racketY < ball.ballY){
      racketY = ball.ballY - 5;
    }
  }
}

/************ CLASE ESCENARIO ******************/

class Escenario{
  // wall settings
  int wallSpeed      = 5;
  int wallInterval   = 1000;
  float lastAddTime  = 0;
  int minGapHeight   = 200;
  int maxGapHeight   = 300;
  int wallWidth      = 80;
  color wallColors   = color(44, 62, 80);
  // This arraylist stores data of the gaps between the walls. Actuals walls are drawn accordingly.
  // [gapWallX, gapWallY, gapWallWidth, gapWallHeight, scored]
  ArrayList<int[]> walls = new ArrayList<int[]>();
  
  Escenario(color col){
    wallColors = col;
  }
  
  void wallAdder(PGraphics screen) {
    if (millis()-lastAddTime > wallInterval) {
      
      int randHeight = round(random(minGapHeight, maxGapHeight));
      int randY = round(random(0, height-randHeight));
      
      // {gapWallX, gapWallY, gapWallWidth, gapWallHeight, scored}
      if(screen == user){
        int[] randWall = {width/2 -5 , randY, wallWidth, randHeight, 0};
        walls.add(randWall);
      }else{
        int[] randWall = {width/2, randY, wallWidth, randHeight, 0};
        walls.add(randWall);
      }
      
      lastAddTime = millis();
    }
  }
  
  void wallHandler(PGraphics screen, Pelota ball) {
    for (int i = 0; i < walls.size(); i++) {
      wallRemover(i);
      wallMover(i);
      wallDrawer(i, screen);
      watchWallCollision(i, ball);
    }
  }
  
  void wallRemover(int index) {
    int[] wall = walls.get(index);
    if (wall[0]+wall[2] <= 0) {
      walls.remove(index);
    }
  }
  
  void wallMover(int index) {
    int[] wall = walls.get(index);
    wall[0] -= wallSpeed;
  }
  
  void wallDrawer(int index, PGraphics screen) {
    int[] wall         = walls.get(index);
    // Obtener la configuración del obstáculo
    int gapWallX       = wall[0];
    int gapWallY       = wall[1];
    int gapWallWidth   = wall[2];
    int gapWallHeight  = wall[3];
    
    // Dibujar el obstáculo
    screen.rectMode(CORNER);
    screen.noStroke();
    screen.strokeCap(ROUND);
    screen.fill(wallColors);
    screen.rect(gapWallX, 0, gapWallWidth, gapWallY, 0, 0, 15, 15);
    screen.rect(gapWallX, gapWallY+gapWallHeight, gapWallWidth, height-(gapWallY+gapWallHeight), 15, 15, 0, 0);
    
    if(screen == jr){
      rckjr. IARaqueta(gapWallX, gapWallY+gapWallHeight, gapWallWidth, pltjr);
    }
  }
  
  void watchWallCollision(int index, Pelota ball) {
    int[] wall            = walls.get(index);
    // get gap wall settings 
    int gapWallX          = wall[0];
    int gapWallY          = wall[1];
    int gapWallWidth      = wall[2];
    int gapWallHeight     = wall[3];
    int wallScored        = wall[4];
    int wallTopX          = gapWallX;
    int wallTopY          = 0;
    int wallTopWidth      = gapWallWidth;
    int wallTopHeight     = gapWallY;
    int wallBottomX       = gapWallX;
    int wallBottomY       = gapWallY+gapWallHeight;
    int wallBottomWidth   = gapWallWidth;
    int wallBottomHeight  = height-(gapWallY+gapWallHeight);
  
    if (
      (ball.ballX+(ball.ballSize/2)>wallTopX) &&
      (ball.ballX-(ball.ballSize/2)<wallTopX+wallTopWidth) &&
      (ball.ballY+(ball.ballSize/2)>wallTopY) &&
      (ball.ballY-(ball.ballSize/2)<wallTopY+wallTopHeight)
      ) {
      ball.decreaseHealth();
    }
    if (
      (ball.ballX+(ball.ballSize/2)>wallBottomX) &&
      (ball.ballX-(ball.ballSize/2)<wallBottomX+wallBottomWidth) &&
      (ball.ballY+(ball.ballSize/2)>wallBottomY) &&
      (ball.ballY-(ball.ballSize/2)<wallBottomY+wallBottomHeight)
      ) {
      ball.decreaseHealth();
    }
  
    if (ball.ballX > gapWallX+(gapWallWidth/2) && wallScored==0) {
      wallScored=1;
      wall[4]=1;
      ball.score++;
    }
  }
}

/***************************************************************************************************
* PROGRAMACIÓN DEL JUEGO
***************************************************************************************************/

/********* SETUP *********/

void setup() {
  size(1210, 500);
  user     = createGraphics(width/2 -5, height);
  jr       = createGraphics(width/2 -5, height);
  div      = createGraphics(10, height);
  pollito  = loadImage("assets/pollito.png");
  smooth();
}

/********* DRAW BLOCK *********/

void draw() {
  image(user, 0, 0);
  image(jr, width/2 +5, 0);
  image(div, width/2 -5, 0);
  // Display the contents of the current screen
  if (gameScreen == 0) { 
    initScreen();
  } else if (gameScreen == 1) {
    gameScreen();
  } else if (gameScreen == 2) {
    if(pltuser.health == 0){
      gameOverScreen(user, pltuser);
    }
    if(pltjr.health == 0){
      gameOverScreen(jr, pltjr);
    }
  } else if (gameScreen == 3) {
    resumeScreen();
  }
}

/********* SCREEN CONTENTS *********/

void initScreen() {
  background(177, 240, 190);
  textAlign(CENTER);
  fill(52, 73, 94);
  textSize(70);
  text("Pollito Pong", width/2, height/2);
  textSize(15); 
  text("Click para iniciar", width/2, height-30);
}

void gameScreen() {
  // DIBUJAR PANTALLA DEL USUARIO
  gameUser();
  // DIBUJAR PANTALLA DE IA
  gameIA();
  
  //Barra en el centro de la Pantalla
  drawDiv();
}

void gameOverScreen(PGraphics screen, Pelota ball) {
  screen.beginDraw();
  screen.textAlign(CENTER);
  screen.fill(236, 240, 241);
  screen.textSize(12);
  if(screen==user){
    screen.background(44, 62, 80);
    screen.text("Tu puntuación:", width/4, height/2 - 120);
    gameOverUser = true;
  }else{
    screen.background(153, 54, 54);
    screen.text("Puntuación con IA:", width/4, height/2 - 120);
    gameOverJr = true;
  }
  screen.textSize(130);
  screen.text(ball.score, width/4, height/2);
  screen.textSize(15);
  screen.text("Click para finalizar partida", width/4, height-30);
  screen.endDraw();
  
  if (!gameOverUser){
    gameUser();
  }
  
  if (!gameOverJr){
    gameIA();
  }
  
  drawDiv();
}

void resumeScreen(){
  background(44, 62, 80);
  textAlign(CENTER);
  fill(236, 240, 241);
  textSize(100);
  text("GAME OVER", width/2, height/4);
  textSize(25);
  text("Tu puntuación", width/4, height/2.2);
  text("Puntuación con IA", width-width/4, height/2.2);
  textSize(50);
  text(pltuser.score, width/4, height/1.6);
  text(pltjr.score, width-width/4, height/1.6);
  textSize(20);
  text("Click para reiniciar", width/2, height-30);
}

/******** JUEGO ************/

void gameIA(){
  jr.beginDraw();
  jr.background(222, 193, 193);
  rckjr.drawRacket(jr);
  rckjr.watchRacketBounce(pltjr);
  pltjr.drawBall(jr);
  pltjr.applyGravity();
  pltjr.applyHorizontalSpeed();
  pltjr.keepInScreen();
  pltjr.drawHealthBar(jr);
  printScore(pltjr, jr);
  escjr.wallAdder(jr);
  escjr.wallHandler(jr, pltjr);
  jr.endDraw();
}

void gameUser(){
  user.beginDraw();
  user.background(211, 217, 227);
  rckuser.drawRacket(user);
  rckuser.watchRacketBounce(pltuser);
  pltuser.drawBall(user);
  pltuser.applyGravity();
  pltuser.applyHorizontalSpeed();
  pltuser.keepInScreen();
  pltuser.drawHealthBar(user);
  printScore(pltuser, user);
  escuser.wallAdder(user);
  escuser.wallHandler(user, pltuser);
  user.endDraw();
}

void drawDiv(){
  div.beginDraw();
  div.background(0,0,0);
  div.endDraw();
}

/****************************** INPUTS ****************************/

public void mousePressed() {
  // if we are on the initial screen when clicked, start the game 
  if (gameScreen==0) { 
    startGame();
  }else if (gameScreen==2) {
    resumeGame();
  }else if (gameScreen==3) {
    restart();
  }
}

/************************ FUNCIONES DE CONTROL *******************/

void printScore(Pelota ball, PGraphics screen) {
  screen.textAlign(CENTER);
  screen.fill(0);
  screen.textSize(30); 
  screen.text(ball.score, height/2, 50);
}

void restart() {
  pltuser = new Pelota();
  pltjr = new Pelota();
  escuser.lastAddTime = 0;
  escjr.lastAddTime = 0;
  escuser.walls.clear();
  escjr.walls.clear();
  gameScreen = 1;
  gameOverUser = false;
  gameOverJr = false;
}

/************************* OTRAS FUNCIONES ************************/

void startGame() {
  gameScreen=1;
}

void gameOver() {
  gameScreen=2;
}

void resumeGame(){
  gameScreen=3;
}
