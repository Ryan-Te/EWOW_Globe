import com.jogamp.newt.opengl.GLWindow;
PShape globe;
PImage map;
PImage bookError;
PImage edit;
PImage searchIcon;

float rotX = 0;
float rotY = 0;
float scroll = 1;
float amount = 90;
float renderThreshold = 20;
float ScrollAmount = 0.2;
boolean regenBooks = false;
boolean editMode = false;
color oceanCol = #6578B8;
int[][] bookArray = new int[180][540];
int[][] bookIDArray = new int[180][540];
String[] names;
int editingY = -1;
int editingX = -1;

boolean searchMode = false;
String search = "";
int[] searchList = new int[10];

int digit5 = 0;
int digit4 = 0;
int digit3 = 0;
int digit2 = 0;
int digit1 = 0;


PImage[] bookLefts = new PImage[36];
PImage[] bookRights = new PImage[36];
String[] letters = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"};
PImage[] CustomBooks;
PImage[] ExtractedBooks;

int CustomStart;
int CustomNumber;

int[] special = {
9104,
8960,
16200,
14618,
13202,
13860,
3311,
5948,
9132,
13890,
11896,
5304,
546,
16095,
7321,
2485
};

boolean rp;
boolean lp;
boolean up;
boolean dp;

void setup(){
  size(1280, 720, P3D);
  noStroke();
  sphereDetail(90);
  imageMode(CENTER);
  bookError = loadImage("bookError.png");
  map = loadImage("ewowmap.png");
  edit = loadImage("edit.png");
  searchIcon = loadImage("Search.png");
  globe = createShape(SPHERE, 1000); 
  globe.setTexture(map);
  
  for (int i = 0; i < 36; i++){
    bookLefts[i] = loadImage("Default Books/" + letters[i] + letters[i] + ".png");
    bookRights[i] = loadImage("Default Books/_" + letters[i] + ".png");
  }
  int[] customInfo = int(loadStrings("Custom Books/info.txt"));
  //Line 1: Starting Number
  //Line 2: Number of Books
  CustomStart = customInfo[0];
  CustomNumber = customInfo[1];
  CustomBooks = new PImage[CustomNumber];
  for (int i = CustomStart; i < CustomStart + CustomNumber; i++){
    CustomBooks[i - CustomStart] = loadImage("Custom Books/" + i + ".png");
  }
  
  ExtractedBooks = new PImage[16607];
  for (int i = 0; i < 16607; i++){
    if (new File(sketchPath("Extracted Books/" + str(i + 10000) + ".png")).exists()){
      ExtractedBooks[i] = loadImage("Extracted Books/" + str(i + 10000) + ".png");
    }else{
      ExtractedBooks[i] = bookError;
    }
  }
  
  String[] bookIDs = loadStrings("bookIDs.txt");
  for (int y = 0; y < 180; y++){
    for (int x = 0; x < 540; x++){
      bookIDArray[y][x] = int(bookIDs[y * 540 + x]);
    }
  }
  names = loadStrings("Names.txt");
  
  String[] bookNums = new String[180 * 540];
  if (regenBooks){
    int layer = 0;
    for (float lt = -57; lt <= 77.5; lt += 0.75){
      float numBooks = (floor(450 * cos(radians(lt))));
      for (int b = 0; b < numBooks; b++){ //(float ln = -180; ln < 180; ln += increaseFactor){
        float ln = (360f / numBooks) * b;
        
        int Yp = floor((180 - (lt + 90)) * 41.28889 - 80);
        int Xp = floor(((ln + 170) % 360) * 40.89444);
        color col = map.pixels[Yp * map.width + Xp];
        float chance = 100;
        if (lt > 50){
          chance = 100 - ((lt - 53) * 4);
        }
        if (col != oceanCol && floor(random(0, 100)) < chance){
          bookArray[layer][b] = ceil(random(0, 1296));
        }
      }
      layer ++;
    }
    for (int y = 0; y < 180; y++){
      for (int x = 0; x < 540; x++){
        bookNums[y * 540 + x] = str(bookArray[y][x]);
      }
    }
    //saveStrings("bookNums.txt", bookNums);
  }else{
    bookNums = loadStrings("bookNums.txt");
    for (int y = 0; y < 180; y++){
      for (int x = 0; x < 540; x++){
        bookArray[y][x] = int(bookNums[y * 540 + x]);
      }
    }
  }
  surface.setResizable(true);
}

void draw(){
  fill(255);
  hint(ENABLE_DEPTH_TEST);
  
  editingY = -1;
  editingX = -1;
  float cameraZ = ((height/2.0) / tan(PI*60.0/360.0));
  perspective(PI/3.0, float(width)/float(height), cameraZ/100.0, cameraZ*10.0);
  pushMatrix();
  
  globe = createShape(SPHERE, height);
  globe.setTexture(map);
  scale(1);
  background(64);
  lights();
  //translate(width / 2, height / 2, (-10000 / (height / 100f)) + (scroll * 3));
  translate(width / 2, height / 2, -(height / scroll) * 1.2);
  rotateX(- radians(rotY));
  rotateY(- radians(rotX)); 
  shape(globe);
  
  int books = 0;
  int layer = 0;
  for (float lt = -57; lt <= 77.5; lt += 0.75){
    float numBooks = (floor(450 * cos(radians(lt))));
    for (int b = 0; b < numBooks; b++){
      float ln = (360f / numBooks) * b;
      
      if(abs(lt - (rotY - 2)) < (0.75 / 2) & abs(ln - ((rotX + 100) % 360)) < (180f / numBooks)) {
        editingY = layer;
        editingX = b;
        if (scroll > 6.7){
          fill(64);
        }
      }else{
        fill(255);
      }
      if(editMode && abs(lt - (rotY - 2)) < (0.75 / 2) & abs(ln - ((rotX + 100) % 360)) < (180f / numBooks)){
        if (bookArray[layer][b] != 0) {books++;}
        DrawBook(lt, ln, edit, 1);
      }else{
      if (bookArray[layer][b] != 0){
        float lnTc = ln;
        if ((rotX + 100) % 360 < 90 && lnTc > 180){
          lnTc = lnTc - 360;
        }
        if ((rotX + 100) % 360 > 270 && lnTc < 180){
          lnTc = lnTc + 360;
        }
        float rotYTT = rotY;
        if (rotYTT == 90) {rotYTT = 89.99;}
        if (abs(lt - rotY) < (renderThreshold - (scroll - 3.4)) && abs(lnTc - ((rotX + 100) % 360)) < (renderThreshold - (scroll - 3.4)) / cos(radians(rotYTT)) && scroll >= 3.4){
          int btd = bookArray[layer][b];
          if (btd > 0 && btd <= 1296){
            int lb = floor((btd - 1) / 36);
            int rb = (btd - 1) % 36;
          
            DrawBook(lt, ln, bookLefts[lb], 1);
            DrawBook(lt, ln, bookRights[rb], 1);
          }else if(btd >= CustomStart && btd <= CustomStart + CustomNumber - 1){
            DrawBook(lt, ln, CustomBooks[btd - CustomStart], 1);
          }else if(btd >= 10000 && btd < 26607){
            DrawBook(lt, ln, ExtractedBooks[btd - 10000], 11.25);
          }else{
            DrawBook(lt, ln, bookError, 1);
          }
        }else if(scroll < 3.4){
          DrawBook(lt, ln, bookLefts[floor((36f / numBooks) * b)], 1);
        }
        books ++;
      }
      }
    }
    layer ++;
  }
  //println(books);
  
  popMatrix();
  hint(DISABLE_DEPTH_TEST);
  textSize(50);
  if (editMode && editingY != -1){
    fill(255, 255, 255);
    rect(0, 0, 125, 50);
    fill(0, 0, 0);
    text(str(digit5) + str(digit4) + str(digit3) + str(digit2) + str(digit1), 0, 40);
    
    fill(0, 0, 0);
    rect(0, 50, 125, 50);
    fill(255, 255, 255);
    String num = str(bookArray[editingY][editingX]);
    while (num.length() < 5){
      num = "0" + num;
    }
    text(num, 0, 90);
    
    fill(0, 0, 255);
    rect(0, 100, 125, 50);
    fill(255, 255, 255);
    text(bookIDArray[editingY][editingX], 0, 140);
    
    fill(255, 0, 0);
    if (books == 16607){
      fill(0, 255, 0);
    }
    rect(0, height - 50, 125, 50);
    fill(255, 255, 255);
    text(books, 0, height - 10);
  }
  if (scroll > 6.7 && editingY != -1){
    int id = (bookIDArray[editingY][editingX] - 1);
    if (id != -1){
      fill(255, 255, 255);
      for (int i = 0; i < 16; i++){
        if(special[i] - 1 == id) {
          fill(249, 255, 145);
        }
      }
      rect(width - 450, 0, 400, 50);
      fill(0, 0, 0);
      text(names[id], width - 450, 40);
    }
  }
  fill(255, 255, 255);
  image(searchIcon, width - 25, 25);
  if (searchMode){
    int startSMX = (width / 2) - 200;
    int startSMY = (height / 2) - 300;
    rect(startSMX, startSMY, 400, 600);
    fill(0, 0, 0);
    text("Tw'earch", startSMX + 25, startSMY + 40);
    fill(255, 0, 0);
    rect(startSMX + 250, startSMY, 150, 50);
    fill(255, 255, 255);
    text("Close", startSMX + 265, startSMY + 40);
    fill(192, 192, 192);
    rect(startSMX, startSMY + 50, 400, 50);
    fill(0, 0, 0);
    text(search, startSMX, startSMY + 90);
    if (!search.equals("")){
      for (int i = 0; i < 10; i ++){
        int ID = searchList[i];
        if (ID < 16607){
          String name = names[ID];
          for (int j = 0; j < 16; j++){
            if(special[j] - 1 == ID) {
              fill(249, 255, 145);
              rect(startSMX, startSMY + (i * 50) + 100, 400, 50);
              fill(0, 0, 0);
            }
          }
          text(name, startSMX, startSMY + (i * 50) + 140);
        }
      }
    }
  }
  
  if (rp){
    rotX = rotX + (amount / frameRate);
  }
  if (lp){
    rotX = rotX - (amount / frameRate);
    if (rotX < 0){
      rotX = rotX + 360;
    }
  }
  if (up){
    rotY = rotY + (amount / frameRate);
    if (rotY > 90) {rotY = 90;}
  }
  if (dp){
    rotY = rotY - (amount / frameRate);
    if (rotY < -90) {rotY = -90;}
  }
}

void DrawBook(float lat, float lon, PImage image, float scale){
  pushMatrix();
  rotateY(radians(-100));
  rotateY(radians(lon));
  rotateX(radians(lat));
  rotateX(radians(2));
  
  translate(0, 0, height);
  scale(scale * 0.00001 * height);
  image(image, 0, 0);
  popMatrix();
}

void keyPressed(){
  if (!searchMode){
    if (keyCode == RIGHT){
      rp = true;
    }
    if (keyCode == LEFT){
      lp = true;
    }
    if (keyCode == UP){
      up = true;
    }
    if (keyCode == DOWN){
      dp = true;
    }
    
    
  }else{
    boolean searchChanged = false;
    if (keyCode == BACKSPACE && search.length() > 0){
      search = search.substring(0, search.length() - 1);
      searchChanged = true;
    }
    if (int(key) >= 32 && int(key) < 128){
      search = search + key;
      searchChanged = true;
    }
    if (searchChanged){
      String searchLower = search.toLowerCase();
      searchList = new int[10];
      int currentIndex = 0;
      for (int i = 0; i < 16607; i++){
        String name = names[i].toLowerCase();
        if (searchLower.length() <= name.length()){
          if (name.substring(0, searchLower.length()).equals(searchLower) && currentIndex < 10){
            searchList[currentIndex] = i;
            currentIndex ++;
          }
        }
      }
      int startAmount = currentIndex;
      if (currentIndex < 10){
        for (int i = 0; i < 16607; i++){
          String name = names[i].toLowerCase();
          if (name.indexOf(searchLower) != -1 && currentIndex < 10){
            boolean alreadyInList = false;
            for (int j = 0; j < startAmount; j++){
              if (searchList[j] == i) {alreadyInList = true;}
            }
            if (!alreadyInList){
              searchList[currentIndex] = i;
              currentIndex ++;
            }
          }
        }
      }
      while (currentIndex < 10){
        searchList[currentIndex] = 16607;
        currentIndex ++;
      }
    }
  }
  
  if (key == '0'){
    digit5 = digit4;
    digit4 = digit3;
    digit3 = digit2;
    digit2 = digit1;
    digit1 = 0;
  }
  if (key == '1'){
    digit5 = digit4;
    digit4 = digit3;
    digit3 = digit2;
    digit2 = digit1;
    digit1 = 1;
  }
  if (key == '2'){
    digit5 = digit4;
    digit4 = digit3;
    digit3 = digit2;
    digit2 = digit1;
    digit1 = 2;
  }
  if (key == '3'){
    digit5 = digit4;
    digit4 = digit3;
    digit3 = digit2;
    digit2 = digit1;
    digit1 = 3;
  }
  if (key == '4'){
    digit5 = digit4;
    digit4 = digit3;
    digit3 = digit2;
    digit2 = digit1;
    digit1 = 4;
  }
  if (key == '5'){
    digit5 = digit4;
    digit4 = digit3;
    digit3 = digit2;
    digit2 = digit1;
    digit1 = 5;
  }
  if (key == '6'){
    digit5 = digit4;
    digit4 = digit3;
    digit3 = digit2;
    digit2 = digit1;
    digit1 = 6;
  }
  if (key == '7'){
    digit5 = digit4;
    digit4 = digit3;
    digit3 = digit2;
    digit2 = digit1;
    digit1 = 7;
  }
  if (key == '8'){
    digit5 = digit4;
    digit4 = digit3;
    digit3 = digit2;
    digit2 = digit1;
    digit1 = 8;
  }
  if (key == '9'){
    digit5 = digit4;
    digit4 = digit3;
    digit3 = digit2;
    digit2 = digit1;
    digit1 = 9;
  }
  
  if (key == 'r'){
    digit5 = 0;
    int rnum = ceil(random(0, 1296));
    digit4 = floor(rnum / 1000);
    rnum = rnum % 1000;
    digit3 = floor(rnum / 100);
    rnum = rnum % 100;
    digit2 = floor(rnum / 10);
    rnum = rnum % 10;
    digit1 = rnum;
  }
  
  if (keyCode == BACKSPACE){
    digit5 = 0;
    digit4 = 0;
    digit3 = 0;
    digit2 = 0;
    digit1 = 0;
  }
  
  if (keyCode == 97 && editMode && editingY != -1){
    bookArray[editingY][editingX] = digit5 * 10000 + digit4 * 1000 + digit3 * 100 + digit2 * 10 + digit1;
  }
  if (keyCode == 100 && editMode && editingY != -1){
    int swapX = -1;
    int swapY = -1;
    for (int y = 0; y < 180; y++){
      for (int x = 0; x < 540; x++){
        if (bookIDArray[y][x] == (digit5 * 10000 + digit4 * 1000 + digit3 * 100 + digit2 * 10 + digit1)){
          swapX = x;
          swapY = y;
        }
      }
    }
    if (swapX != -1){
      int temp = bookArray[editingY][editingX];
      bookArray[editingY][editingX] = bookArray[swapY][swapX];
      bookArray[swapY][swapX] = temp;
      
      temp = bookIDArray[editingY][editingX];
      bookIDArray[editingY][editingX] = bookIDArray[swapY][swapX];
      bookIDArray[swapY][swapX] = temp;
    }
    //bookArray[editingY][editingX] = digit5 * 10000 + digit4 * 1000 + digit3 * 100 + digit2 * 10 + digit1;
  }
  if (keyCode == 108 && editMode && digit5 == 0 && digit4 == 2 && digit3 == 7 && digit2 == 6 && digit1 == 3){
    String[] bookNums = new String[180 * 540];
    for (int y = 0; y < 180; y++){
      for (int x = 0; x < 540; x++){
        bookNums[y * 540 + x] = str(bookArray[y][x]);
      }
    }
    saveStrings("bookNums.txt", bookNums);
    
    String[] bookIDs = new String[180 * 540];
    for (int y = 0; y < 180; y++){
      for (int x = 0; x < 540; x++){
        bookIDs[y * 540 + x] = str(bookIDArray[y][x]);
      }
    }
    saveStrings("bookIDs.txt", bookIDs);
    
    println("Books Saved");
  }
  if (keyCode == 106){
    //editMode = !editMode;
  }
  //println(keyCode);
}

void keyReleased(){
  if (keyCode == RIGHT){
    rp = false;
  }
  if (keyCode == LEFT){
    lp = false;
  }
  if (keyCode == UP){
    up = false;
  }
  if (keyCode == DOWN){
    dp = false;
  }
}

void mouseWheel(MouseEvent event){
  float e = event.getCount(); 
  scroll = scroll - (e * ScrollAmount);
  if (scroll > 8){
    scroll = 8;
  }
  if (scroll < 0.6){
    scroll = 0.6;
  }
  amount = 90 / (scroll);
  //println(scroll);
}

void mousePressed(){
  if (mouseX > width - 50 && mouseY < 50){
    searchMode = true;
  }
  
  if (searchMode){
    int startSMX = (width / 2) - 200;
    int startSMY = (height / 2) - 300;
    
    if (mouseX >= startSMX + 250 && mouseX < startSMX + 400 && mouseY >= startSMY && mouseY < startSMY + 50){
      searchMode = false;
    }
    if (mouseX >= startSMX && mouseX < startSMX + 400 && mouseY >= startSMY + 100 && mouseY < startSMY + 600 && !search.equals("")){
      int idToGoTo = searchList[floor(((mouseY - startSMY) - 100) / 50)] + 1;
      //println(names[idToGoTo - 1]);
      for (int y = 0; y < 180; y++){
        for (int x = 0; x < 540; x++){
          if (bookIDArray[y][x] == idToGoTo){
            float lt = -57 + (0.75 * y);
            float numBooks = (floor(450 * cos(radians(lt))));
            float ln = (360f / numBooks) * x;
            rotY = lt + 2;
            rotX = ln - 100;
            scroll = 7.0;
            amount = 90 / (scroll);
            searchMode = false;
          }
        }
      }
    }
  }
}
