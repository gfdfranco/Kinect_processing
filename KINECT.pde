

//SERVO1 5
//SERVO2 6
import SimpleOpenNI.*;
import cc.arduino.*;
import processing.serial.*;

int horizontal =6;
int vertical = 5; 
int gatillo = 3;
float centroX=0;
float centroY=0;
float anguloX=0;
float anguloY=0;
boolean bandera=true;
boolean disparo=false;
SimpleOpenNI  kinect;
Arduino arduino;


void setup() {
  
  
   arduino = new Arduino(this, Arduino.list()[0],57600);
   arduino.pinMode(horizontal, Arduino.SERVO);
   arduino.pinMode(vertical, Arduino.SERVO);
   arduino.pinMode(gatillo, Arduino.SERVO);
   size(640, 480);
   kinect = new SimpleOpenNI(this);
   kinect.enableDepth();
   kinect.enableUser();
   
  
}
void draw() {
  
  kinect.update();
  PImage depth = kinect.depthImage();
  image(depth, 0, 0);
  // make a vector of ints to store the list of users
  IntVector userList = new IntVector();
  // write the list of detected users
  // into our vector
  kinect.getUsers(userList);
  // if we found any users
  if (userList.size() == 1) {
    // get the first user
    int userId = userList.get(0);
    // if we’re successfully calibrated
    if ( kinect.isTrackingSkeleton(userId)) {
      // make a vector to store the left hand
      PVector rightHand = new PVector();
      // put the position of the left hand into that vector
      float confidence = kinect.getJointPositionSkeleton(userId, 
      SimpleOpenNI.SKEL_RIGHT_HAND, 
      rightHand);
      // convert the detected hand position
      // to "projective" coordinates
      // that will match the depth image
      PVector convertedRightHand = new PVector();
      kinect.convertRealWorldToProjective(rightHand, convertedRightHand);
      // and display it
      fill(255, 0, 0);
      ellipse(convertedRightHand.x, convertedRightHand.y, 10, 10);
      
        PVector leftHand = new PVector();
      // put the position of the left hand into that vector
      float confidence2 = kinect.getJointPositionSkeleton(userId, 
      SimpleOpenNI.SKEL_LEFT_HAND, 
      leftHand);
      // convert the detected hand position
      // to "projective" coordinates
      // that will match the depth image
      PVector convertedLeftHand = new PVector();
      kinect.convertRealWorldToProjective(leftHand, convertedLeftHand);
      // and display it
      fill(255, 0, 0);
      ellipse(convertedLeftHand.x, convertedLeftHand.y, 10, 10);
       println("Der  x:" + convertedRightHand.x + "Der y: " +  convertedRightHand.y + "Izq  x:" + convertedLeftHand.x + "Izq y: " +  convertedLeftHand.y );
      
      if( convertedRightHand.y<200)
      {
        if(!disparo)
        {
          if(bandera)
           {
             println("Centro almacenado");
             centroX= convertedLeftHand.x;
             centroY=  convertedLeftHand.y;
             
             bandera=false;
             disparo=true;
           }
           else
           {
            println("DISPARASTE");
            disparo=true;
            arduino.servoWrite(gatillo, 100);
            delay(500);
            arduino.servoWrite(gatillo, 30);
            delay(500);
           }
        }
       
       
        
     
      }
      else
      {
        disparo=false;
        
        if(!bandera)
        {
          anguloX=map( convertedLeftHand.x, 50.0, 265.0, 65.0 , 115.0);
          anguloY=map( convertedLeftHand.y, 45.0, 275.0, 65.0 , 115.0);
          arduino.servoWrite(horizontal, (int)anguloX);
          arduino.servoWrite(vertical, (int)anguloY);
        }
          
      }
      
     
     
    }
  }
   if (userList.size() == 2) {
  println("DOS USUARIOS");
  }
  if (userList.size() > 2) {
  println("MUCHOS USUARIOS PARA JUGAR");
  }
}
/* old version user-tracking callbacks!
void onNewUser(int userId) {
  println("start pose detection");
  kinect.startTrackingSkeleton(userId);
}
 
void onEndCalibration(int userId, boolean successful) {
  if (successful) {
    println("  User calibrated !!!");
    kinect.startTrackingSkeleton(userId);
  } else {
    println("  Failed to calibrate user !!!");
    kinect.startTrackingSkeleton(userId);
  }
}
void onStartPose(String pose, int userId) {
  println("Started pose for user");
  kinect.stopTrackingSkeleton(userId);
  kinect.requestCalibrationSkeleton(ulserId, true);
}*/
 
void onNewUser(SimpleOpenNI curContext,int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
   
  kinect.startTrackingSkeleton(userId);
}
 
void onLostUser(SimpleOpenNI curContext,int userId)
{
  println("onLostUser - userId: " + userId);
}
 
void onVisibleUser(SimpleOpenNI curContext,int userId)
{
  //println("onVisibleUser - userId: " + userId);
}
