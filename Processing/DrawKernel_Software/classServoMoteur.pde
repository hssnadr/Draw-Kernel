class ServoMoteur {

  int motId; // index du moteur (identifiant)
  int curAngle; //range = 0 to 180
  int pin;
  int penOut = 44;
  int penMax = 75;
  int penMin = 47;

  ServoMoteur(int pin_, int initAngle_) {
    this.pin = pin_;
    this.curAngle = initAngle_;

    //Initialisation des pin arduino correspondant
    //arduino.pinMode(this.pin, Arduino.SERVO);
    delay(50);    
    //Inititialization position servo motor
    //arduino.servoWrite(this.pin, this.curAngle);
  }

  //-----------------

  void goToAngle(int angle_) {
    angle_ = constrain(angle_,0,180); // constrain angle to servo motor range
    
    //arduino.servoWrite(this.pin, angle_);
    String dat_ = "S" + hex(angle_, 2) + '_'; 
    myPort.write(dat_);          // send angle in hexadecimal format with 2 digits
    countSerialSend++;
    this.curAngle = angle_;

    String edit = "Servo Current Angle = " + this.curAngle;
    println(edit);
  }

  void plusAngle() {
    this.curAngle += 5;
    this.goToAngle(this.curAngle);
  }
  void minusAngle() {
    this.curAngle -= 5;
    this.goToAngle(this.curAngle);
  } 

  void penControl(float val) {
    /* val is a value between 0 and 100, expressing the color density*/
    //Check range constancy
    if(this.penMin>this.penMax){
      int penMin_ = this.penMax;
      this.penMax = this.penMin;
      this.penMin = penMin_;
    }
    //Map values and go to angle
    //println("val = " + val);
    val = map(val, 0, 100, this.penMin, this.penMax);
    //println("val = " + val);
    if(this.curAngle < int(val)){
     this.goToAngle(this.curAngle + 1); 
    }
    if(this.curAngle > int(val)){
     this.goToAngle(this.curAngle - 1); 
    }
  }

  void penOff() {
    // Remove pen from paper
    this.goToAngle(this.penOut);
    //delay(100);
  }
}