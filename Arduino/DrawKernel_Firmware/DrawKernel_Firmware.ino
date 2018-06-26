#include <Servo.h>

//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------

class Motor
{
  public:
    Motor(int motIndex_, int pinDir_, int pinStep_, int pinStartCourse_, int pinEndCourse_, String trueDirection_);
    void begin();
    void setDirection(boolean dir_);
    void setDirection(int dn_);
    void doOneStep();
    void getEndCourseSensorStatue();
    void setGroupSteps(int nGStep_, int timeMot_);
    void getGroupSteps();
    int groupStepsReallyDone ;
    int groupStepsNotDone ;
    int stepMot ;                    // received steps to do
    boolean isGroupOver = true ;

  private:
    int motIndex;            // index of the current motor (especially for array usages)
    boolean trueDirection = true ;

    // Pins
    int pinDir;              // direction pin
    int pinStep;             // step pin
    int pinStartCourse;      // pin of end course sensor for motor 1
    int pinEndCourse;        // pin of start course sensor for motor 1

    // Variables
    boolean isGoingForward = true ;
    boolean startCourse = false ; // start course sensor for motor 1
    boolean endCourse = false ;   // end course sensor for motor 1
    long timerStartCourse = 0 ;
    long timerEndCourse = 0 ;

    long timerGStep ;       // timer to regulate motor groupe steps
    int delayGStep ;        // time (ms) between each step
    int nGStep ;            // total number of steps to do
    int iGStep ;            // current step achieved by motor
};

//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------

// Declare motors
#define nMotors 2             // number of stepper motors
Motor motors[nMotors] = {
  Motor(0, 2, 3, 8, 9, "FORWARD"),
  Motor(1, 4, 5, 10, 11, "FORWARD")
};

long timer0 ;
long dly = 500 ;   // !!!!! stepper pulse delay (microsec) // !!!!!! TO CHANGE WITH SKETCHBOOK / StepperPoluluDriver01
int delayMotors = 4; // milliseconds

long timerGroup ; // TO REMOVE

Servo servo ;
#define pinServo 11

// Serial buffer
String dataString ;             // incoming string message
char buff[100];                  // buffer to store incoming messages
int bufIndex = 0;               // index of the last received character

long serialCounter = 0 ;

String idGroupStep = "no group";


//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------

void setup() {
  Serial.begin(9600);          // Initialize serial
  timer0 = millis();           // Initialize timer

  // Initiliaze stepper motor pins
  for (int i = 0; i < nMotors; i++) {
    motors[i].begin();
  }

  servo.attach(pinServo);      // Initialize servo motor pin
}

void loop() {
  getSerialMessage(); // No serialEvent() function on Arduino Leonardo

  //------------------------------------------
  //---------- MANAGE GROUP STEPS ------------
  //------------------------------------------
  int nMotorOver_ = 0 ;
  for (int i = 0; i < nMotors; i++) {
    motors[i].getGroupSteps();
    if (motors[i].isGroupOver) {
      nMotorOver_++;
    }
  }
  if (nMotorOver_ == nMotors && idGroupStep != "no group") {
    Serial.print(idGroupStep);
    for (int i = 0; i < nMotors; i++) {
      Serial.print(';');
      Serial.print(motors[i].groupStepsReallyDone);
    }
    Serial.println("");
    idGroupStep = "no group";
//    Serial.println(millis() - timerGroup);
  }
  
  //------------------------------------------
  //------------ MAKE MOTOR STEP -------------
  //------------------------------------------
  if (millis() - timer0 > delayMotors) {
    for (int i = 0; i < nMotors; i++) {
      motors[i].doOneStep();
    }
    timer0 = millis();
  }

  //------------------------------------------
  //----------- CHECK MOTORS COURSE ----------
  //------------------------------------------
  for (int i = 0; i < nMotors; i++) {
    motors[i].getEndCourseSensorStatue();
  }
}
