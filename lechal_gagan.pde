import processing.serial.*;

import com.hamoid.*;

Serial myPort;  // The serial port
Serial myPort1;

float[] r = new float[9];
float[] r1 = new float[9];
float[] temp_r = new float[9];
float[] temp_r1 = new float[9];

int flag; //calibration

PrintWriter output, output1, nfiles, position;

PImage bg, startimg, stopimg, pauseimg;

PFont f;

Table table;

int flagStart = 0, flagStop = 0, flagE = 0, flagF = 0;

float sL, sR, sF, sB;

float x_p, y_p, distance;

float score = 0;

int rating = 0;




int day_1 = day();    // Values from 1 - 31
int month_1 = month();  // Values from 1 - 12
int year_1 = year();   // 2003, 2004, 2005, etc.

int sec_1 = second();  // Values from 0 - 59
int min_1 = minute();  // Values from 0 - 59
int hour_1 = hour();    // Values from 0 - 23


void getDate(){
  day_1 = day();
  month_1 = month();
  year_1 = year();  
}

void getTime(){
  sec_1 = second();
  min_1 = minute();
  hour_1 = hour();  
}

String getName(){
  getDate();
  getTime();
  return str(day_1)+"-"+str(month_1)+"-"+str(year_1)+"_____"+str(hour_1)+"-"+str(min_1);
}


void startRecord(){
  
  recording = true;
}

void stopRecord(){
  
  if(recording==false){
      
      name = getName();
      //count = count+1;
      videoExport = new VideoExport(this, "sessions/"+name+".mp4");
      videoExport.setFrameRate(30);
      videoExport.setQuality(90);
    }
  
}


VideoExport videoExport;
boolean recording = false;
int ind_shot = 0;
int vExp = 0;

String name;

void setup() {
  size(1000, 1000);
  //fullScreen();
  noStroke();
  bg = loadImage("bg.png");
  startimg=loadImage("start.jpg");
  stopimg=loadImage("off.png");
  pauseimg=loadImage("pause.jpg");
  
  
  
  frameRate(30);

  flag = 0;
  // List all the available serial ports:
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[1], 9600);
  myPort1 = new Serial(this, Serial.list()[4], 38400);
  //myPort1 = myPort;
  
  String y_s = str(year());
  String mo_s = str(month());
  String d_s = str(day());
  String time_s = y_s + "/" + mo_s + "/" + d_s + "   ";
  
  String[] file_no = loadStrings("file_no.txt");
  int temp_file_no = int(file_no[0]);
  String new_file_no = str(temp_file_no+1);
  nfiles = createWriter("file_no.txt");
  nfiles.println(new_file_no);
  nfiles.flush();
  nfiles.close();
  output = createWriter(time_s + new_file_no + "L.txt");
  output1 = createWriter(time_s + new_file_no + "R.txt");
  
  rectMode(CENTER);
  
  sL = 0;
  sR = 0;
  sF = 0;
  sB = 0;


  
  f = createFont("Arial",16,true); 
  
  
  name = getName();
  
  videoExport = new VideoExport(this, "sessions/"+name+".mp4");
  videoExport.setFrameRate(30);
  videoExport.setQuality(90);
}

void draw() {

  background(255);
  tint(128,30);
  image(bg, 0, 0, bg.width/4, bg.height/4);
  
    //time into string
  String y = str(year());
  String mo = str(month());
  String d = str(day());
  String h = str(hour());
  String m = str(minute());
  String s = str(second());
  String time = y + "/" + mo + "/" + d + "--" + h + ":" + m + ":" + s;
  
  textFont(f,16);                  
  fill(0);                         
  text(time,250,15);
  

  //buttons
  stroke(0);
  tint(255,255);
  image(startimg,750,38,startimg.width/2.5,startimg.height/2.5);
  image(pauseimg,825,40,pauseimg.width/20,pauseimg.height/20);
  image(stopimg,925,40,stopimg.width/8,stopimg.height/8);
  
  //what to click
    //start
  if(flagStart == 0 && flagStop == 0 && flagF == 0 && flagE == 0){
    stroke(0,255,0);
    fill(255,0);
    ellipse((1500+startimg.width/2.5)/2, (76+startimg.height/2.5)/2, 50, 50);
  }
    //pause
  if(flagStart == 1 && flagStop == 0 && flagF == 0 && flagE == 0){
    stroke(0,255,0);
    fill(255,0);
    ellipse((1650+pauseimg.width/20)/2, (80+pauseimg.height/20)/2, 50, 50);
    //vExp = 1;
  }
  
  //saveFrames
  //if(recording == true) videoExport.saveFrame();
  
  //locus file
  if(flagStart == 1){
    
    position.println(str((x_p)) + " " + str((y_p)));
    position.flush();
   
  }
   String[] pos = loadStrings("position.txt");
  
  
    //score
  if(flagStart == 0 && flagStop == 1 && flagF == 0 && flagE == 0){
    stroke(0,255,0);
    fill(255,0);
    rect(975, 255, 50, 40);

  }
    //rating
  if(flagStart == 0 && flagStop == 0 && flagF == 1 && flagE == 0){
    stroke(0,255,0);
    fill(255,0);
    rect(975, 355, 50, 40);
  } 
    //submit
  if(flagStart == 0 && flagStop == 0 && flagF == 0 && flagE == 1){
    stroke(0,255,0);
    fill(255,0);
    rect(835, 595, 110, 60);
   
  }      
  
  
  fill(255);
  stroke(0);
  strokeWeight(1);
  rect(914,255,60,40);//text box for score
  textFont(f,16);                  
  fill(0);                         
  text(nfc(score,1),905,260);
  
  fill(255);
  rect(914,355,60,40);//text box for rating
  textFont(f,16);                  
  fill(0);                         
  text(str(rating),905,360);
  
  fill(50);
  rect(975, 255, 45, 35);//enter button for score
  textFont(f,13);                  
  fill(255);                         
  text("Enter",959,253);
  text("score",958,265);
  
  fill(50);
  rect(975, 355, 45, 35);//enter button for rating
  textFont(f,13);                  
  fill(255);                         
  text("Enter",959,353);
  text("rating",958,365);
  
  //submit
  fill(50);
  stroke(0);
  rect(835, 595, 100, 50);
  textFont(f,20);
  //strokeWeight(10);
  fill(255);                         
  text("SUBMIT",800,600);
  
  //calibrate button
  fill(100,0,50);
  stroke(0);
  rect(700,700, 100,25);
  fill(255);
  textFont(f,14);
  text("CALIBRATE",663,705);
  
    //calibrate
  if (mousePressed && mouseX<750 && mouseX>650 && mouseY<713 && mouseY>688) {
    for(int i=0; i<9; i++) {
      temp_r[i]=r[i];  //TEMP_R NOT USED YET
      temp_r1[i]=r1[i];
    }
    flag = 1;
    
  } 
  
  //submit data
  if(mousePressed && mouseX<885 && mouseX>785 && mouseY<620 && mouseY>570 && flagE == 1){
    output.println("STOP");
    output.println();
    output1.println("STOP");
    output1.println();
    output.flush();
    output1.flush();
    rating = 0;
    score = 0;
    flagE = 0;
    distance = 0;
    
    if(recording==true){
      recording=false;
      stopRecord();
    }
  }
  //println(str(flagStart) + " " + str(flagStop) + " " +str(flagF) + " " + str(flagE));
  
  
  //write score
  if(flagStop== 1){
    if(mousePressed && mouseX<998 && mouseX>952 && mouseY<267 && mouseY>243){      
      flagStop = 0;
      flagF = 1;
      output.print(nfc(score,1)+"  ");
      
    }
  }
  
  //write feeling
  if(flagF == 1 && flagE == 0 && mousePressed && mouseX<998 && mouseX>952 && mouseY<367 && mouseY>343){
    flagF = 0;
    flagE = 1;
    output.println(str(rating));
    output.println();

  }
  
 
  //end session
  if (mousePressed && mouseX<957 && mouseX>925 && mouseY<72 && mouseY>40 && flagStart == 0 && flagStop == 0 && flagE == 0){
      output.close();
      output1.close();
      exit();
    }
  
  
  

  if (myPort.available() > 0) {
    String inBuffer = myPort.readStringUntil(10); 
    //write to file
    if (mousePressed && mouseX<787 && mouseX>750 && mouseY<75 && mouseY>38)  {
      if(flagStart == 0 && flagF == 0 && flagStop ==0){
        flagStart = 1;
        position = createWriter("position.txt");
        output.println("START");
        output.println();
        output1.println("START");
        output1.println();
        ind_shot++;
        //println(ind_shot);
        //videoExport = new VideoExport(this, time + "  " + "shot_no" + str(ind_shot) + ".mp4");
        //videoExport = new VideoExport(this,  "2.mp4");
        startRecord();
      }
    }
    if (mousePressed && mouseX<857 && mouseX>825 && mouseY<72 && mouseY>40) {
      if(flagStart == 1)        {
        flagStart = 0;
        flagStop = 1;
        //recording = false;
        position.close();
        
        
        //distance      
        if(pos.length!=0){
        for(int j = 0; j < pos.length-1; j++){
          float[] coordinate1 = float(split(pos[j]," "));
          float[] coordinate2 = float(split(pos[j+1]," "));
          distance = distance + sqrt(sq(coordinate2[0]-coordinate1[0])+sq(coordinate2[1]-coordinate1[1]));
        }
       }
      }
    }

         
    if (inBuffer != null) {

      float[] q = float(split(inBuffer, ","));
      if(q.length == 9) 
      {
        sL = 0;
        for(int i=0; i<8; i++) {
          r[i]=q[i]/4;
          sL = sL+q[i];
        }
        r[8] = radians(q[8]);
        
      }
      if(flagStart == 1){
        output.print(time + " ");
        output.print(inBuffer);
      }
     }
     //for(int j=0; j<9; j++) print(r[j]+"\t");
     //println();
  }

    
  if (myPort1.available() > 0) {
     String inBuffer1 = myPort1.readStringUntil(10);   
    if (inBuffer1 != null) {
      float[] q1 = float(split(inBuffer1, ","));
      if(q1.length == 9) 
      {
        sR = 0;
        for(int i=0; i<8; i++) {
          r1[i]=q1[i]/4;
          sR = sR + q1[i];
        }
        r1[8] = radians(q1[8]);
        
      }
      if(flagStart == 1){
        output1.print(time + "  ");
        output1.print(inBuffer1);
      }
     }
     //for(int j=0; j<9; j++) print(r1[j]+"\t");
     //println();
  }

  sF = r[0] + r1[0] + r[1] + r1[1] + r[2] + r1[2] + r[3] + r1[3] + r[4] + r1[4];
  sB = r[5] + r1[5] + r[6] + r1[6] + r[7] + r1[7];

  
  y_p = map((sF-sB)*4, -2500, 2500, -380, 380);
  x_p = map(sR-sL, -2000, 2000, -305, 305);
  
  
  //display locus real time
  if(flagStart == 1){
    stroke(255,0,0);
    strokeWeight(2);
    if(pos.length!=0){
    for(int j = 0; j < pos.length-1; j++){
      float[] coordinate = float(split(pos[j]," "));
      float[] coordinatet = float(split(pos[j+1]," "));
      line(310+coordinate[0], 440-coordinate[1], 310+coordinatet[0], 440-coordinatet[1]);
    }
    }
  }
     //distance & locus
  if(flagF == 1 || flagE == 1 || flagStop == 1){
    stroke(0,255,0);
    if(pos.length!=0){
    for(int j = 0; j < pos.length-1; j++){
      float[] coordinateF1 = float(split(pos[j]," "));
      float[] coordinateF2 = float(split(pos[j+1]," "));
      strokeWeight(2);
      line(310+coordinateF1[0], 440-coordinateF1[1], 310+coordinateF2[0], 440-coordinateF2[1]);
    }
    }
    textFont(f,16);                  
    fill(0);                         
    text("Distance moved:"+nfc(distance/100,2),700,305);
    }
    
  
  

  display();
  
  

}

void display(){

  //display pressure points
  fill(0,35);
  noStroke();
         //left shoe
  ellipse(96.5,190.5,r[1],r[1]); //1
  ellipse(207.35,145,r[0],r[0]); //2
  ellipse(227.25,263.4,r[2],r[2]);//5
  ellipse(149.5,319,r[3],r[3]);//4
  ellipse(74.25,394,r[4],r[4]);//3
  ellipse(141,712.6,r[5],r[5]);//6
  ellipse(244,694.65,r[6],r[6]);//7
  ellipse(207.3,783.6,r[7],r[7]);//8
        //right shoe
  ellipse(537.6,193.65,r1[1],r1[1]); //1
  ellipse(428.8,144.1,r1[0],r1[0]); //2
  ellipse(404.1,260.5,r1[2],r1[2]);//5
  ellipse(480,319.8,r1[3],r1[3]);//4
  ellipse(550,398,r1[4],r1[4]);//3
  ellipse(470,712.9,r1[5],r1[5]);//6
  ellipse(367.5,692,r1[6],r1[6]);//7
  ellipse(401.1,782,r1[7],r1[7]);//8
  
  //display magnetometer
  if(flag == 0){

    pushMatrix();
    translate(650, 800); 
    rotate(r[8]);
    fill(100);
    rect(0, 0, 40, 100);
    popMatrix();
    
    pushMatrix();
    translate(750, 800); 
    rotate(r1[8]);
    fill(100);
    rect(0, 0, 40, 100);
    popMatrix();
    
    textFont(f,16);                  
    fill(0);                         
    text("Uncalibrated",700,900);   
  }
  if(flag == 1){

    pushMatrix();
    translate(650, 800); 
    rotate(temp_r[8]-r[8]);
    fill(100);
    rect(0, 0, 40, 100);
    popMatrix();
    
    textFont(f,16);                  
    fill(0);                         
    text(str(round(degrees(temp_r[8]-r[8]))),650,950);
    
    pushMatrix();
    translate(750, 800); 
    rotate(temp_r1[8]-r1[8]);
    fill(100);
    rect(0, 0, 40, 100);
    popMatrix();
    
    textFont(f,16);                  
    fill(0);                         
    text(str(round(degrees(temp_r1[8]-r1[8]))),750,950);

    
  }
  

  //graph
  
  fill(255);
  stroke(0);
  strokeWeight(3);
  line(310,50,310,830);
  line(5,440,615,440);
  //grid
  stroke(100);
  strokeWeight(0.5);
  float c;
  for(int m = -15; m < 16; m++){
    line(310+m*20, 50, 310+m*20, 830);
    textFont(f,12);                  
    fill(50); 
    c = m*0.5;
    if(m % 2 == 0) text(nfc(c,1),310+m*20,452);
  }
  for(int m = -19; m<20; m++){
    line(5,440+m*20, 615,440+m*20);
    textFont(f,12);                  
    fill(50); 
    c = m*0.5;
    if(m % 2 == 0 && m != 0) text(nfc(c,1),314,442+m*20);
  }
  
  
  //display front/back lean
  strokeWeight(3);
  if(flagStop == 1 || flagF == 1 || flagE == 1) noStroke();
  else stroke(0,255,0);
  line(300, 440-y_p, 320, 440-y_p);  
  
  //display right/left lean
  if(flagStop == 1 || flagF == 1 || flagE == 1) noStroke();
  else  stroke(0,0,255);
  line(310+x_p,430,310+x_p,450);
  
  //center
  if(flagStop == 1 || flagF == 1 || flagE == 1)
  fill(255,0,0,0);
  else fill(255,0,0,255);
  noStroke();
  ellipse(310+x_p, 440-y_p, 35, 35);

  fill(0);
  textFont(f,14);
  if(flagStart == 1 || (flagStart == 0 && flagStop == 0 && flagF == 0 && flagE == 0))
  text("(" + nfc(x_p/100,2)+","+ nfc(x_p/100,2) + ")", 325+x_p, 425-y_p);
  
  
  if(recording) {
    
    videoExport.saveFrame();
  }


}

void keyPressed() {
  if (key == CODED && flagStop == 1) {
    if (keyCode == UP) {
      score = score + 0.1;
      println(nfc(score,1));
    } else if (keyCode == DOWN) {
      score = score - 0.1;
      println(nfc(score,1));
    }
    else if(keyCode == RIGHT){
      score = score + 1;
      println(nfc(score,1));
    }
    else if(keyCode == LEFT){
      score = score - 1;
      println(nfc(score,1));
    }
    
  } 
   if (key == CODED && flagF == 1) {
      if(keyCode == RIGHT || keyCode == UP){
        rating = rating + 1;
        println(str(rating));
      }
      else if(keyCode == LEFT || keyCode == DOWN){
        rating = rating - 1;
        println(str(rating));
      }
      
    }
  
}