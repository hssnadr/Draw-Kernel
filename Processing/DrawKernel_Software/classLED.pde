class LED{
  
  float xpos; //en mm
  float ypos; //en mm
  int strokeSize = 4;
  int ledpin;
  boolean isOn = false;
  
  LED(float xpos_,float ypos_, int ledpin_){
    xpos = xpos_;
    ypos = ypos_;
    ledpin = ledpin_;
    
    //Initialisation des pin arduino correspondant
    //arduino.pinMode(ledpin_, Arduino.OUTPUT);
    this.off(); // éteint la led
  }
  
  void display(){
    if(isSetupOver)
    {
      //stroke(255, 0, 0);
      //strokeWeight(int(r_*strokeSize/float(100)));
      //point(xpos*ratioMMtoPix,ypos*ratioMMtoPix);
      
      noStroke();
      if(this.isOn){
        fill(255,0,0);
      }
      else{
        fill(0,0,255);
      }
      
      ellipse(this.xpos*ratioMMtoPix,this.ypos*ratioMMtoPix,4,4);
    }
  }
  
  void on(){
    // put the led ON
    //arduino.digitalWrite(this.ledpin, Arduino.LOW);
    this.isOn = true;
  }
  
  
  void off(){
    // shut down the led
    //arduino.digitalWrite(this.ledpin, Arduino.HIGH);
    this.isOn = false;
  }
}