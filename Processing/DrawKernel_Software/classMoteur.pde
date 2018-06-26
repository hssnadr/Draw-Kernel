void calibrateAllMotors(PVector targetPos_){
  CalibrationThread calibrationThread;
  Thread calibThrd ;
  calibrationThread=new CalibrationThread(targetPos_);
  calibThrd=new Thread(calibrationThread);
  calibThrd.start();
}

public class CalibrationThread implements Runnable {
  Thread thread;
  PVector targetLedPos;
  
  public CalibrationThread(PVector targetLedPos_) {
    targetLedPos = targetLedPos_;
  }
  
  public void start() {
    thread = new Thread(this);
    thread.start();
  }
  
  public void run() {
    // Callibrate each motors
    println("---------------");
    println("Starting callibration...");
    int countCalMot_ = 0 ;
    for (int i=0; i<moteurs.size (); i++)
    {
      print("Calibrating motor", i);
      Moteur moteur_ = moteurs.get(i);
      if (moteur_.hasEndCourseSensor) {
        moteur_.calibrateAndSetTo(targetLedPos.x, targetLedPos.y);
        print("\t>>>\tMotor", i, "callibrated");
        countCalMot_++;
      } else {
        print("\t>>>\tNo end course sensor for motor", i);
      }
      println("");
    }
    
    // Return calibration result
    if (countCalMot_ == moteurs.size() ) {
      println("All motors are calibrated");
    } else {
      if (countCalMot_ > 0) {
        println(countCalMot_, "motors are calibrated among", moteurs.size());
      }
      else{
        println("No motors calibrated");
      }
    }
    println("---------------");
  
    // Set true led position from callibration
    led.xpos = targetLedPos.x;
    led.ypos = targetLedPos.y;
  }
}


//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------

class Moteur {
  float xpos; //en mm
  float ypos; //en mm
  float diametreBobine; //en mm
  int pas; //nombres de pas pour réaliser un tour complet (tenir compte de la résolution choisi en fonction des branchements : full step, mid step ...)
  boolean isOver;
  boolean isGoingForward;
  boolean reversTrueDir = false; //reverse motor direction if needed (ex: for the motor at the right of the drawing)

  // Moteur axial
  boolean isAxeX = false;
  boolean isAxeY = false;
  boolean hasEndCourseSensor = false;
  boolean isAtEndCourse = false;
  boolean isAtStartCourse = false;

  public int nReal;        //nombre de pas réellement effectué (compté à chaque fois qu'un pas est réellement appelé)
  public int nFake;
  public int dn = 0;       // number of steps to do per part
  public int di = 0;       // current step of a group step
  public long delayGStep = 0 ;
  public long timerGStep = 0;

  int startCoursePin; // pin for start course sensor (min range)
  int endCoursePin;   // pin for end course sensor (max range)

  MotorThread motorThread;
  Thread motThrd;

  Moteur(float posX_, float posY_, float diametreBobine_, int pas_, boolean hasEndCourseSensor_) {
    xpos = posX_;
    ypos = posY_;
    diametreBobine = diametreBobine_;
    pas = pas_;

    // Moteur axial
    if (ypos == -1) {
      isAxeX = true;      // Motor is defined as X axis (like a tracer)
    } else {
      if (xpos == -1) {
        isAxeY = true;    // Motor is defined as Y axis (like a tracer)
      }
    }

    this.setnReal(this.calculPasMoteurLine(led.xpos, led.ypos, led.xpos, led.ypos, 1)); // return number of motor steps to go from Led(pen) origin to the motor rotor
    this.hasEndCourseSensor = hasEndCourseSensor_;
  }

  //-----------------
  void setnReal(int n_){
    nReal = n_;
    nFake = nReal;
  }
  
  void display() {
    stroke(0, 0, 255);
    strokeWeight(8);
    point(xpos*ratioMMtoPix, ypos*ratioMMtoPix);
  }

  void displayMotToLed() {
    displayElements(this.nFake, 60);
    displayElements(this.nReal, 255);
  }
  
  void displayElements(int n_, int alpha_){
    float motToLed_ = n_ * (PI*this.diametreBobine)/this.pas; // distance in millimeter between moteur and active point
    motToLed_ *= ratioMMtoPix; // distance in pixel

    noFill();
    stroke(0, 0, 255, alpha_);
    strokeWeight(1);

    if (this.isAxeX || this.isAxeY) {
      if (this.isAxeX) {
        line(motToLed_, 0, motToLed_, height);
      }
      if (this.isAxeY) {
        line(0, motToLed_, width, motToLed_);
      }
    } else {
      ellipse(this.xpos*ratioMMtoPix, this.ypos*ratioMMtoPix, 2*motToLed_, 2*motToLed_);
    }
  }

  //-----------------

  void initMoveThread(int dn_, int time_, ConcurrentLinkedQueue<Moteur> q_) {
    if (dn_ != 0 ) {
      this.setDirection(dn_);   

      // initialize thread
      motorThread =new MotorThread(this, dn_, time_, q_);
      motThrd=new Thread(motorThread);
      this.isOver = false;
    } else {
      this.isOver = true; // no need to move if there are no steps to do
    }
  }

  void startMoveThread() {
    if (motThrd != null && !this.isOver) {
      motThrd.start();
    }
  }
  
  void stropMoveThread() {
    if (motThrd != null) {
      motThrd.stop();
    }
  }

  void setDirection(int dn_)
  {
    //the arduino direction is controled taking into account the theorical direction and the position of the motor on the drawing (reversTrueDir))
    //the others variables (like isGoingForward) are not affected by reversTrueDir because they are just conventions 
    if (dn_ >= 0) //mettre le sens correspondant pour le moteur (LOW ou HIGH pour direction)
    {
      String dat_ = "D" + int(moteurs.indexOf(this)) + "1_" ;
      println("dat_ ", dat_);
      myPort.write(dat_);
      this.isGoingForward = true;
    } else {
      String dat_ = "D" + int(moteurs.indexOf(this)) + "0_" ;
      println("dat_ ", dat_);
      myPort.write(dat_);
      this.isGoingForward = false;
    }
    countSerialSend++;
  }

  int calculPasMoteur(float xM, float yM) {
    PVector MMt = new PVector(xM-this.xpos, yM-this.ypos);

    // If Motor is an AXE
    if (this.isAxeX) {
      MMt.y = 0.0f;
    }
    if (this.isAxeY) {
      MMt.x = 0.0f;
    }

    int n_=(int)(this.pas*MMt.mag()/(PI*this.diametreBobine)); //nombre des pas "absolus" correspondant à la distance moteur - led
    return n_;
  }

  //-----------------

  int calculPasMoteurLine(float xA, float yA, float xB, float yB, long t) {
    int n_ = calculPasMoteurBezier(xA, yA, xA, yA, xB, yB, xB, yB, t);
    return n_;
  }

  //-----------------

  int calculPasMoteurBezier(float xA, float yA, float xB, float yB, float xC, float yC, float xD, float yD, float t) {
    float xM = bezierPoint(xA, xB, xC, xD, t);
    float yM = bezierPoint(yA, yB, yC, yD, t);

    PVector u = new PVector(xM, yM);

    PVector MMt;

    if (t<1)// tant que la LED n'a pas dépassé son point d'arrivé
    {
      this.isOver = false;
      MMt = new PVector(u.x-this.xpos, u.y-this.ypos);
    } else {
      this.isOver = true;
      MMt = new PVector(xD -this.xpos, yD-this.ypos);
      //println("line is over");
    }

    // If Motor is an AXE
    if (this.isAxeX) {
      MMt.y = 0.0f;
    }
    if (this.isAxeY) {
      MMt.x = 0.0f;
    }

    int n_ = (int)(this.pas*MMt.mag()/(PI*this.diametreBobine)); //nombre de pas relatifs a effectuer

    return n_;
  }

  //----------------- 

  void faire1pas() {
    //if(!(this.isAtStartCourse && !this.isGoingForward) || !(this.isAtEndCourse && this.isGoingForward)){
      // Update steps really done
      if (this.isGoingForward) {
        this.setnReal(this.nReal + 1);
      } else {
        this.setnReal(this.nReal - 1);
      }

      // Do 1 step
      String dat_ = "M" + int(moteurs.indexOf(this)) + "_" ;
      myPort.write(dat_);
      countSerialSend++;
    //}
  }
  
  void cancelBufferedSteps(){
    // Cancel all arduino buffered step
    String dat_ = "C" + int(moteurs.indexOf(this)) + "_";
    myPort.write(dat_);
    countSerialSend++;
  }

  //-----------------
  void calibrateAndSetTo(float x_, float y_) {
    // x_ and y_ are target coordinates in millimeters

    // Go to start point
    this.setDirection(-1); // go backward
    delay(100);
    while (!this.isAtStartCourse) {
      this.faire1pas();
      delay(5);
    }
    this.cancelBufferedSteps();
    //this.nReal = 0; // maybe useless
    this.setnReal(0);
    
    //// Go to end point
    //this.nMax = -666;
    //this.setDirection(+1); // go forward
    //while(arduino.digitalRead(this.endCoursePin) == Arduino.LOW){
    //  this.faire1pas(); // update nReal
    //  delay(2);
    //}
    //this.nMax = this.nReal;

    // Go to target
    int n_ = calculPasMoteur(x_, y_);
    this.setDirection(n_);
    println("N                    =  ", n_);
    delay(100);
    for (int i=0; i<abs(n_); i++)
    {
      faire1pas();
      delay(2);
    }
  }

  void retourPosOrigin() {
    int dn_ = -this.nReal;
    this.setDirection(dn_);
    delay(50);

    for (int i=0; i<abs(dn_); i++)
    {
      faire1pas();
      delay(2);
    }
  }
}