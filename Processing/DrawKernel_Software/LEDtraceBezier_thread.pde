public class TraceThread implements Runnable {
  Thread thread;
  ArrayList<Bezier> bezierToTrace;
  ArrayList<Float> X = new ArrayList<Float>(); //x step points
  ArrayList<Float> Y = new ArrayList<Float>(); //y step points
  ArrayList<Float> grVal = new ArrayList<Float>(); //grey value at step points
  boolean cancelThread = false;

  public TraceThread(ArrayList<Bezier> bezierToTrace_, int penMin_, int penMax_, int penOut_) {
    //Initialisation variable
    bezierToTrace = bezierToTrace_;
    servo.penMin = penMin_;
    servo.penMax = penMax_;
    servo.penOut = penOut_;
  }

  public void start() {
    thread = new Thread(this);
    thread.start();
  }

  public void run() {
    // START TO PRINT EACH BEZIER ONE BY ONE
    String edit = "beziers.size() = " + bezierToTrace.size();
    println(edit);

    // GOING THROUGH EACH BEZIER CURVES
    for (int i = 0; i < bezierToTrace.size (); i++)
    {
      // Cancel thread check
      if (this.cancelThread) {
        println("BREAK");
        break;
      }

      //------------------------------
      // GET BEZIER CURVE VALUES
      //------------------------------
      // GET CURRENT BEZIER CURVE
      Bezier bezier_ = bezierToTrace.get(i);
      edit = "ON EST A LA COURBE DE BEZIER " + i;
      println(edit);

      // CUT BEZIER CURVE AND GET STEP POINTS COORDINATES
      ArrayList[] xyBezierCut = bezierSmartCut(bezier_); // return XY coordinate of all bezier steps
      X = xyBezierCut[0]; // get all X coordinates
      Y = xyBezierCut[1]; // get all Y coordinates
      println("X = " + X);
      println("Y = " + Y);

      // GET GREY VALUES FROM STEP POINTS
      grVal.clear(); // reset grval value
      for (int j=0; j<X.size (); j++) {
        grVal.add(greymap.getGreyVal(X.get(j), Y.get(j)));
      }

      //-----------------------------------------
      //----------- GO TO NEXT BEZIER -----------
      //-----------------------------------------
      println("GO TO ORIGIN");
      leadPenTo(X.get(0), Y.get(0), -1);
      led.on(); //allumage de la LED
      println("AT ORIGIN");
      //-----------------------------------------
      //------------- TRACE BEZIER --------------
      //-----------------------------------------
      for (int k=1; k < X.size (); k++) 
      {
        if (this.cancelThread) {
          println("BREAK");
          break;
        }

        // TRACE NEXT BEZIER
        println("GO TO NEXT PART");
        leadPenTo(X.get(k), Y.get(k), int(grVal.get(k)));
        println("IS AT NEXT PART");

        // Update Led position
        if (led != null)
        {
          led.xpos = X.get(k);
          led.ypos = Y.get(k);
        }
      }
      led.off();
      bezier_.isPenTraced = true;

      // BACK TO ORIGIN
      if (i == bezierToTrace.size()-1 || this.cancelThread)
      {
        leadPenTo(originPoint.x, originPoint.y, -1);
        println("EVERY MOTOR RESETED");

        // Update Led position
        if (led != null)
        {
          led.xpos = originPoint.x;
          led.ypos = originPoint.y;
        }
      }
    }
    this.stop();
  }

  public void stop() {
    thread = null;
  }
}

//------------------------------------------
//--------- PEN CONTROL FUNCTION -----------
//------------------------------------------
void leadPenTo(float x_, float y_, int targetServoAngle_) {
  // GET MOTOR STEPS
  int maxdN_ = -1 ;                               // max number of steps is used to calculate the period to draw the bezier part
  int isNewPos_ = 0 ;
  for (int j=0; j<moteurs.size (); j++)
  {
    Moteur moteur_ = moteurs.get(j);
    int n_ = moteur_.calculPasMoteur(x_, y_);
    moteur_.dn = n_ - moteur_.nReal ;
    // Check number of steps
    if (moteur_.dn!=0) {
      isNewPos_++;
    }
    // Update timing from dn
    if (abs(moteur_.dn) > maxdN_) {
      maxdN_ = abs(moteur_.dn) ;  // update max number of steps between all motors
    }
  }

  // Set pen pressure
  if (targetServoAngle_ > -1) {
    servo.goToAngle(targetServoAngle_); // set pressure
  } else {
    servo.penOff();                     // remove pen from paper
  }

  if (isNewPos_ > 0) {
    idGroupSteps = millis();
    String serialGroupeMessage_ = "G" + idGroupSteps ;     // unic ID of step group to send
    int timeGroupSteps_ = maxdN_*3 ;            // time period for the motors to move
    for (int j=0; j<moteurs.size (); j++) {
      serialGroupeMessage_ += ";" + moteurs.get(j).dn ; // add number of steps to do
      serialGroupeMessage_ += "," + timeGroupSteps_ ;        // add time to make the steps
    }

    // Send to arduino
    isGroupStepOver = false;
    serialGroupeMessage_ += "_";
    println("SEND : ", serialGroupeMessage_);
    myPort.write(serialGroupeMessage_);

    // GRAPHIC RENDER
    for (int j=0; j<moteurs.size (); j++)
    {
      Moteur moteur_ = moteurs.get(j);
      if (moteur_.dn != 0) {
        moteur_.delayGStep = (long)(1.5 * timeGroupSteps_ / abs(moteur_.dn)) ;
        moteur_.timerGStep = millis() ;
      }
      moteur_.di = 0 ;
    }

    while (!isGroupStepOver) {
      for (int j=0; j<moteurs.size (); j++)
      {
        Moteur moteur_ = moteurs.get(j);
        if (moteur_.di < abs(moteur_.dn)) {
          if (millis() - moteur_.timerGStep >= moteur_.delayGStep) {
            moteur_.timerGStep = millis() ;
            moteur_.di++;
            if (moteur_.dn > 0) {
              moteur_.nFake++;
            } else {
              moteur_.nFake--;
            }
          }
        }
      }
    }
    // THEN nReal IS UPDATE WITH THE RESPONSE OF THE ARDUINO : SEE SERIAL MESSAGE case 'G'
  }
  println("HOLA");
}