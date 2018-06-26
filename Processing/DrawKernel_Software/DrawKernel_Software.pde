import java.io.*;
import java.util.concurrent.*;
import processing.serial.*;

//Arduino arduino;
Serial myPort;   // Serial communication
String serialData = "";
int idGroupSteps = -1;
volatile boolean isGroupStepOver = false;
long countSerialSend = 0 ; // TO REMOVE
long countSerialReceive = 0 ; // TO REMOVE

ArrayList<Bezier> beziers;
ArrayList<Moteur> moteurs;
ServoMoteur servo;
GreyMap greymap;
LED led;

//Thread
TraceThread traceThread;
Thread trcThrd;

float largeurSupport = 490; // largeur du support en mm
float hauteurSupport = 400; // hauteur du support en mm, en francais dans le code
float ratioMMtoPix = 1.0;   // computed in the setup()

PVector originPoint = new PVector(largeurSupport/2., hauteurSupport/2.); // starting point coordinate, in millimeters

boolean isSetupOver = false;

PImage img;


void setup() {
  // SERIAL SETUP
  println(Serial.list());
  //arduino = new Arduino(this, Arduino.list()[1], 57600);
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600); // initialize serial communication
  myPort.write("___");

  // SCREEN AND PANEL SETUP
  size(735, 600) ; // taille de la fenêtre
  ratioMMtoPix = width / largeurSupport;

  // BEZIER CLASS
  beziers = new ArrayList<Bezier>();

  // LED CLASS
  led = new LED(originPoint.x, originPoint.y, 4);//LED initialisée au milieu de la zone du support
  led.off();

  // MOTOR CLASS
  moteurs = new ArrayList<Moteur>();
  //moteurs.add(new Moteur(0, 0, 18.2, 400, false));
  //moteurs.add(new Moteur(largeurSupport, 0, 18.2, 400, false));
  moteurs.add(new Moteur(0, -1, 14.7, 200, true)); // OKAY MAKERbloc
  moteurs.add(new Moteur(-1, 0, 14.7, 200, true)); // OKAY MAKERbloc

  // SERVOMOTOR AND GREYMAP CLASS
  servo = new ServoMoteur(9, 0); // handle greymap
  greymap = new GreyMap();

  // TTTESSSSTTTT
  //delay(1000);
  //moteurs.get(0).setDirection(1);
  //moteurs.get(1).setDirection(1);
  //delay(1000);
  //for(int i=0; i < 2122; i++){
  //   moteurs.get(0).faire1pas();
  //   moteurs.get(1).faire1pas();
  //   delay(5);
  //}
}

void stop() {
  for (int i=0; i<moteurs.size (); i++)
  {
    String closeMess_ = "C" + i + "_";
    myPort.write(closeMess_);
  }
}

void draw() {
  //println("countSerialSend                                       ", countSerialSend);
  //println(isGroupStepOver);
  //delay(100);
  
  background(255);
  greymap.printImg();
  led.display();

  // DISPLAY MOTORS
  if (moteurs.size() > 0) {
    for (int i = 0; i < moteurs.size(); i++)
    {
      moteurs.get(i).displayMotToLed();
      moteurs.get(i).display();
    }
  }

  // DISPLAY CURVES
  if (beziers.size()>0)
  {
    for (int i = 0; i < beziers.size (); i++)
    {
      Bezier bezier_ = beziers.get(i);
      bezier_.display();
    }
  }
}