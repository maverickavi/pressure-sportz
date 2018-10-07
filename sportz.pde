import processing.serial.*;

import com.hamoid.*;


import controlP5.*;

ControlP5 cp5;

DropdownList d1;

Serial myPort;  // The serial port
Serial myPort1;

float[] r = new float[29];
float[] r1 = new float[29];
float[] temp_r = new float[29];
float[] temp_r1 = new float[29];

int flag, flagWriteL, flagWriteR; //calibration

PrintWriter output, output1, nfiles, position;

PImage bg, startimg, stopimg, pauseimg;

PFont f;

Table table;

int flagStart = 0, flagStop = 0, flagE = 0, flagF = 0;

float sL, sR, sF, sB, new_sF, new_sB;

float x_p, y_p, distance;

float score = 0;

int rating = 0;

int count=0;


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
  //size(1000, 1000);
  fullScreen();
  noStroke();
  bg = loadImage("bg.png");
  startimg=loadImage("start.jpg");
  stopimg=loadImage("off.png");
  pauseimg=loadImage("pause.jpg");
  
  
  
  frameRate(15);

  flag = 0;
  // List all the available serial ports:
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  myPort1 = new Serial(this, Serial.list()[5], 9600);
  myPort = new Serial(this, Serial.list()[4], 9600);
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
  new_sF = 0;
  new_sB = 0;

  
  f = createFont("Arial",16,true); 
  
  
  name = getName();
  
  videoExport = new VideoExport(this, "sessions/"+name+".mp4");
  videoExport.setFrameRate(15);
  videoExport.setQuality(90);
  
  
  cp5 = new ControlP5(this);
  
  d1 = cp5.addDropdownList("myList-d1")
          .setPosition(950, 400)
          .setSize(200,200)
          .setHeight(120)
          ;
          
  customize(d1);
  
}


void customize(DropdownList ddl) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(150));
  ddl.setItemHeight(50);
  ddl.setBarHeight(15);
  ddl.getCaptionLabel().set("Data Files");
  
  
  
  File folder = new File("/Users/dirtydevil/Dropbox/Kunal_Duc/Project Gagan/code processing/lechal_gagan_new_v1/2016/7");
  File[] listOfFiles = folder.listFiles();

    for (int i = 0; i < listOfFiles.length; i++) {
      if (listOfFiles[i].isFile()) {
        
        ddl.addItem((listOfFiles[i].getName()),i);
        System.out.println("File " + listOfFiles[i].getName());
      } else if (listOfFiles[i].isDirectory()) {
        System.out.println("Directory " + listOfFiles[i].getName());
      }
    }
  
  //for (int i=0;i<40;i++) {
  //  ddl.addItem("item "+i, i);
  //}
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}


void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
  } 
  else if (theEvent.isController()) {
    println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
  }
}




void draw() {

  background(255);
  //tint(128,70);
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
    //calibrate 808,450, 100,25
  if(flag == 0){
    stroke(0,255,0);
    fill(255,0);
    rect(808,450, 105, 30);
  }
    //start
  if(flagStart == 0 && flagStop == 0 && flagF == 0 && flagE == 0 && flag == 1){
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
    rect(845, 198, 65, 45);

  }
    //rating
  if(flagStart == 0 && flagStop == 0 && flagF == 1 && flagE == 0){
    stroke(0,255,0);
    fill(255,0);
    rect(845, 250, 65, 45);
  } 
    //submit
  if(flagStart == 0 && flagStop == 0 && flagF == 0 && flagE == 1){
    stroke(0,255,0);
    fill(255,0);
    rect(808, 320, 145, 55);
   
  }      
  
  
  fill(255);
  stroke(0);
  strokeWeight(1);
  rect(770,198,60,40);//text box for score
  textFont(f,16);                  
  fill(0);                         
  text(nfc(score,1),760,204);
  
  fill(255);
  rect(770,250,60,40);//text box for rating
  textFont(f,16);                  
  fill(0);                         
  text(str(rating),765,256);
  
  fill(50);
  rect(845, 198, 60, 40);//enter button for score
  textFont(f,13);                  
  fill(255);                         
  text("Enter",830,195);
  text("score",828,210);
  
  fill(50);
  rect(845, 250, 60, 40);//enter button for rating
  textFont(f,13);                  
  fill(255);                         
  text("Enter",830,245);
  text("rating",828,260);
  
  //submit
  fill(50);
  stroke(0);
  rect(808, 320, 140, 50);
  textFont(f,20);
  //strokeWeight(10);
  fill(255);                         
  text("SUBMIT",775,325);
  
  //calibrate button
  fill(100,0,50);
  stroke(0);
  rect(808,450, 100,25);
  fill(255);
  textFont(f,14);
  text("CALIBRATE",767,453);
  
    //calibrate
  if (mousePressed && mouseX<858 && mouseX>758 && mouseY<463 && mouseY>438) {
    for(int i=0; i<28; i++) {
      temp_r[i]=r[i];  
      temp_r1[i]=r1[i];
    }
    flag = 1;
    
    
  } 
  
  //submit data
  if(mousePressed && mouseX<878 && mouseX>738 && mouseY<345 && mouseY>295 && flagE == 1){
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
    //flag = 0;
    
    if(recording==true){
      recording=false;
      stopRecord();
    }
  }
  //println(str(flagStart) + " " + str(flagStop) + " " +str(flagF) + " " + str(flagE));
  
  
  //write score 845, 198, 60, 40
  if(flagStop== 1){
    if(mousePressed && mouseX<875 && mouseX>815 && mouseY<218 && mouseY>178){      
      flagStop = 0;
      flagF = 1;
      output.print(nfc(score,1)+"  ");
      
    }
  }
  
  //write feeling 845, 250, 60, 40
  if(flagF == 1 && flagE == 0 && mousePressed && mouseX<875 && mouseX>815 && mouseY<270 && mouseY>230){
    flagF = 0;
    flagE = 1;
    output.println(str(rating));
    output.println();

  }
  
 
  //end session 925,40,stopimg.width/8,stopimg.height/8
  if (mousePressed && mouseX<(925+stopimg.width/8) && mouseX>925 && mouseY<(40+stopimg.height/8) && mouseY>40 && flagStart == 0 && flagStop == 0 && flagE == 0){
      output.close();
      output1.close();
      exit();
    }
  
  
  

  if (myPort.available() > 0) {
    String inBuffer = myPort.readStringUntil(10); 
    //write to file
    if (flag == 1 && flagWriteL == 0){
      output.println("Calibrated data: " + inBuffer);
      flagWriteL = 1;
    }
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
      if(q.length == 29) 
      {
        sL = 0;
        for(int i=0; i<10; i++) {
          r[i]=q[i]/10;
          sL = sL+r[i]-temp_r[i];
        }
        r[10] = radians(q[10]);
        
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
     if (flag == 1 && flagWriteR == 0){
       output.println("Calibrated data: " + inBuffer1);
       flagWriteR = 1;
     }
    if (inBuffer1 != null) {
      float[] q1 = float(split(inBuffer1, ","));
      if(q1.length == 29) 
      {
        sR = 0;
        for(int i=0; i<10; i++) {
          r1[i]=q1[i]/10;
          sR = sR + r1[i]-temp_r1[i];
        }
        r1[10] = radians(q1[10]);
        
      }
      if(flagStart == 1){
        output1.print(time + "  ");
        output1.print(inBuffer1);
      }
     }
     //for(int j=0; j<9; j++) print(r1[j]+"\t");
     //println();
  }

  sF = r[0]-temp_r[0] + r1[0]-temp_r1[0] + r[1]-temp_r[1] + r1[1]-temp_r1[1] + r[2]-temp_r[2] + r1[2]-temp_r1[2] + r[3]-temp_r[3] + r1[3]-temp_r1[3] + r[4]-temp_r[4] + r1[4]-temp_r1[4] + r[8]-temp_r[8] + r1[8]-temp_r1[8];
  sB = r[5] + r1[5] -temp_r[5]-temp_r1[5]  + r[6] + r1[6] -temp_r[6]-temp_r1[6] + r[7] + r1[7] -temp_r[7]-temp_r1[7] + r[9] + r1[9] -temp_r[9]-temp_r1[9];
  
  //weighted according distance from center line
  new_sF = (311*(r[0]-temp_r[0] + r1[0]-temp_r1[0]) + 196*(r[1]-temp_r[1] + r1[1]-temp_r1[1]) + 183*(r[2]-temp_r[2] + r1[2]-temp_r1[2]) + 133*(r[3]-temp_r[3] + r1[3]-temp_r1[3]) + 74*(r[4]-temp_r[4] + r1[4]-temp_r1[4]) + 23*(r[8]-temp_r[8] + r1[8]-temp_r1[8]))/920;
  new_sB = (214*(r[5] + r1[5]-temp_r[5]-temp_r1[5]) + 226*(r[6] + r1[6]-temp_r[6]-temp_r1[6]) + 312*(r[7] + r1[7]-temp_r[7]-temp_r1[7]) + 37*(r[9] + r1[9]-temp_r[9]-temp_r1[9]))/789;
  
  

  
  y_p = map((sF-sB)*10, -7000, 7000, -380, 380);
  x_p = map((sR-sL)*10, -7000, 7000, -305, 305);
  
  //println(str(x_p)+" " + str(y_p));
  
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
    text("Distance moved:"+nfc(distance/100,4),720,400);
    }
    
  
  

  display();
  //println(str(mouseX) + " " + str(mouseY));
  

}

void display(){

  //float rad = 40;
  
  //display pressure points
  fill(50,150);
  noStroke();
  if(flag == 1){
         //left shoe
  ellipse(78,242,r[1]-temp_r[1],r[1]-temp_r[1]); //1
  ellipse(236,147,r[0]-temp_r[0],r[0]-temp_r[0]); //2
  ellipse(236,265,r[2]-temp_r[2],r[2]-temp_r[2]);//5
  ellipse(147,305,r[3]-temp_r[3],r[3]-temp_r[3]);//4
  ellipse(78,364,r[4]-temp_r[4],r[4]-temp_r[4]);//3
  ellipse(96,652,r[5]-temp_r[5],r[5]-temp_r[5]);//6
  ellipse(183,664,r[6]-temp_r[6],r[6]-temp_r[6]);//7
  ellipse(137,750,r[7]-temp_r[7],r[7]-temp_r[7]);//8
  ellipse(91,475,r[9]-temp_r[9],r[9]-temp_r[9]);//9
  ellipse(175,415,r[8]-temp_r[8],r[8]-temp_r[8]);//10
  //      //right shoe
  ellipse(540,234,r1[1]-temp_r1[1],r1[1]-temp_r1[1]); //1
  ellipse(380,140,r1[0]-temp_r1[0],r1[0]-temp_r1[0]); //2
  ellipse(383,258,r1[2]-temp_r1[2],r1[2]-temp_r1[2]);//5
  ellipse(470,296,r1[3]-temp_r1[3],r1[3]-temp_r1[3]);//4
  ellipse(540,357,r1[4]-temp_r1[4],r1[4]-temp_r1[4]);//3
  ellipse(522,644,r1[5]-temp_r1[5],r1[5]-temp_r1[5]);//6
  ellipse(434,655,r1[6]-temp_r1[6],r1[6]-temp_r1[6]);//7
  ellipse(480,744,r1[7]-temp_r1[7],r1[7]-temp_r1[7]);//8
  ellipse(528,467,r1[9]-temp_r1[9],r1[9]-temp_r1[9]);//9
  ellipse(442,407,r1[8]-temp_r1[8],r1[8]-temp_r1[8]);//10
  }
  
  
  //ellipse(78,242,rad,rad); //1
  //ellipse(236,147,rad,rad); //2
  //ellipse(236,265,rad,rad);//5
  //ellipse(147,305,rad,rad);//4
  //ellipse(78,364,rad,rad);//3
  //ellipse(96,652,rad,rad);//6
  //ellipse(183,664,rad,rad);//7
  //ellipse(137,750,rad,rad);//8
  //ellipse(91,475,rad,rad);//9
  //ellipse(175,415,rad,rad);//10
  //      //right shoe
  //ellipse(540,234,rad,rad); //1
  //ellipse(380,140,rad,rad); //2
  //ellipse(383,258,rad,rad);//5
  //ellipse(470,296,rad,rad);//4
  //ellipse(540,357,rad,rad);//3
  //ellipse(522,644,rad,rad);//6
  //ellipse(434,655,rad,rad);//7
  //ellipse(480,744,rad,rad);//8
  //ellipse(528,467,rad,rad);//9
  //ellipse(442,407,rad,rad);//10
  
  
  //display magnetometer
  if(flag == 0){

    pushMatrix();
    translate(750, 550); 
    rotate(r[8]);
    fill(100);
    rect(0, 0, 40, 100);
    popMatrix();
    
    pushMatrix();
    translate(850, 550); 
    rotate(r1[8]);
    fill(100);
    rect(0, 0, 40, 100);
    popMatrix();
    
    textFont(f,16);                  
    fill(0);                         
    text("Uncalibrated",750,630);   
  }
  if(flag == 1){

    pushMatrix();
    translate(750, 550); 
    rotate(temp_r[10]-r[10]);
    fill(100);
    rect(0, 0, 40, 100);
    popMatrix();
    
    textFont(f,16);                  
    fill(0);                         
    text(str(round(degrees(temp_r[10]-r[10]))),747,630);
    
    pushMatrix();
    translate(850, 550); 
    rotate(temp_r1[10]-r1[10]);
    fill(100);
    rect(0, 0, 40, 100);
    popMatrix();
    
    textFont(f,16);                  
    fill(0);                         
    text(str(round(degrees(temp_r1[10]-r1[10]))),847,630);

    
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
  line(300, 440-2*y_p, 320, 440-2*y_p);  
  
  //display right/left lean
  if(flagStop == 1 || flagF == 1 || flagE == 1) noStroke();
  else  stroke(0,0,255);
  line(310+2*x_p,430,310+2*x_p,450);
  
  //center
  if(flagStop == 1 || flagF == 1 || flagE == 1)
  fill(255,0,0,0);
  else fill(255,0,0,100);
  noStroke();
  ellipse(310+2*x_p, 440-2*y_p, 35, 35);

  fill(0);
  textFont(f,16);
  if(flagStart == 1 || (flagStart == 0 && flagStop == 0 && flagF == 0 && flagE == 0))
  text("(" + nfc(2*x_p/100,4)+","+ nfc(2*y_p/100,4) + ")", 325+2*x_p, 425-2*y_p);
  
  
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
    
    if(key==' '){
      
      
      if(count%2==0){
          println("start");   //start recording
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
      }else if(count%2==1){
         String[] pos = loadStrings("position.txt");
         println("stop");     //stop recording
         if(flagStart == 1){
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
      count=count+1;
      
    }
  
}


void getFiles(){

  
  
File folder = new File("/Users/dirtydevil/Dropbox/Kunal_Duc/Project Gagan/code processing/lechal_gagan_new_v1/2016/7");
File[] listOfFiles = folder.listFiles();

    for (int i = 0; i < listOfFiles.length; i++) {
      if (listOfFiles[i].isFile()) {
        System.out.println("File " + listOfFiles[i].getName());
      } else if (listOfFiles[i].isDirectory()) {
        System.out.println("Directory " + listOfFiles[i].getName());
      }
    }
  
  
}



void loadFile(){
  
  
  
}