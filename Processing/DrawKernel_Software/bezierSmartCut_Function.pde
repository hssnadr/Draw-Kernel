ArrayList[] bezierSmartCut(Bezier bez) {
  float x1 = bez.x1;
  float y1 = bez.y1;
  float xc1 = bez.x2;
  float yc1 = bez.y2;
  float xc2 = bez.x3;
  float yc2 = bez.y3;
  float x2 = bez.x4;
  float y2 = bez.y4;
  float lengthBezier = bez.lengthB;

  ArrayList<Float> xList = new ArrayList<Float>(); //x step points
  ArrayList<Float> yList = new ArrayList<Float>(); //y step points

  float mmStep = 1.5;
  int nStep = int(lengthBezier / mmStep);
  println("nStep =" + nStep);

  float t= 0.001;
  float x = x1;
  float y = y1;
  float xold = x1;
  float yold = y1;

  int i=0;
  float tAcc = 3./float(nStep); // time to reach max pen speed (= max mm step) = number of steps to reach max speed / total steps
  
  // Add first point
  xList.add(x1);
  yList.add(y1);
  
  while (t<1) {
    println("t = " + t);
    
    //----------------------------------------------------------------
    //----------------------------------------------------------------
    // PEN SPEED MANAGEMANT
    // max speed when ratioPenSpeed = 1 = max
    float ratioPenSpeed = 1;    
    
    // acceleration part before to reach max pen speed
    if (t<tAcc) {
      ratioPenSpeed = t/tAcc;
      println("///////////////// ratioPenSpeed (speed up) = " + ratioPenSpeed);
    }
    
    // deceleration to slow down from max pen speed to almost 0
    if (t>1-tAcc) { 
      ratioPenSpeed = (1-t)/tAcc;
      //ratioPenSpeed = pow(ratio, 2);
      println("///////////////// ratioPenSpeed (slow down) = " + ratioPenSpeed);
    }
    //println("ratioPenSpeed = " + ratio);
    //----------------------------------------------------------------
    //----------------------------------------------------------------

    float smartStep = ratioPenSpeed*mmStep;
    println("------------------------------smartStep = " + smartStep);
    if (smartStep < 1) { 
      smartStep = 1; // min mm step = 1mm
    }
    while (dist (xold, yold, x, y) < smartStep) {
      t += 0.001;
      x = bezierPoint(x1, xc1, xc2, x2, t);
      y = bezierPoint(y1, yc1, yc2, y2, t);
    }


    if (t<1) {
      if (dist (xold, yold, x, y)>0.5) {
        xList.add(x);
        yList.add(y);
      }
    }

    xold = x;
    yold = y;
    i++;
  }
  
  // Add end point
  xList.add(x2);
  yList.add(y2);

  println("t = " + t);
  println("i = " + i);
  println("OVER");



  ArrayList[] returnList = { 
    xList, yList
  };
  return returnList;
}