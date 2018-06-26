void keyPressed() {

  isSetupOver = true;

  if (key == CODED)
  {
    if (keyCode == UP)
    {
      //      backgroundWithMarge();
      //      LEDtraceLine();
      if (trcThrd != null) {
        //traceThread.stop();
        traceThread.cancelThread = true;
      }
    }

    if (keyCode == DOWN)
    {
      if (trcThrd == null) {
        traceThread=new TraceThread(beziers, 52, 72, 48); // Pentel
        trcThrd=new Thread(traceThread);
        trcThrd.start();
      }
    }

    if (keyCode == LEFT)
    {
      //servo.goToAngle(0);
      servo.plusAngle();
    }

    if (keyCode == RIGHT)
    {
      //servo.goToAngle(180);
      servo.minusAngle();
    }
  }

  if ( key == 'q')
  {
    servo.penMin = servo.curAngle;
    println("PEN MIN set to " + servo.curAngle);
  }

  if ( key == 's')
  {
    servo.penMax = servo.curAngle;
    servo.penMin = servo.curAngle;
    println("PEN MAX set to " + servo.curAngle);
  }

  // CALLIBRATION
  if ( key == 'c')
  {
    calibrateAllMotors (originPoint);
  }

  if ( key == 'b')
  {
    //beziers.add(new Bezier(largeurSupport/2, hauteurSupport/2, 350, 120, 340, 250, largeurSupport/2, hauteurSupport/2));
    float ld = largeurSupport/2;
    float hd = hauteurSupport/2 ;
    //float r = 20;
    float ratio = 1.8;
    greymap.printMap();

    //-----------------------//
    //LIGNES VERTICALES
    //-----------------------//
    //    for(int i = int(ld); i < 598 + 348; i += 2){
    //      beziers.add(new Bezier(i , 504 , i , 504 , i , 504+536, i , 504+536));
    //    }


    //for (int i = 560 + 150; i < 1200 + 390 - 150; i += 3) {
    //  beziers.add(new Bezier(i, 560, i, 560, i - 390, 900, i-390, 900));
    //}
    beziers.add(new Bezier(-ld, hd, ld, hd, ld*2/3., hd*2/3., ld*2/3., hd*2/3.));
    beziers.add(new Bezier(ld*2/3., hd*2/3., ld*2/3., hd*2/3., ld/3., hd*2/3., ld/3., hd*2/3.));
    beziers.add(new Bezier(ld/3., hd*2/3., ld/3., hd*2/3., ld*2/3., hd/3., ld*2/3., hd/3.));

    //-----------------------//
    // CERCLES CONCENTRIQUES //
    //-----------------------//
    //for(int r=20; r< 30; r+= 3){
    for (int r=100; r< 101; r+= 4) {
      beziers.add(new Bezier(ld + r, hd, ld + r, hd + r/ratio, ld + r/ratio, hd + r, ld, hd + r));
      beziers.add(new Bezier(ld, hd + r, ld - r/ratio, hd + r, ld - r, hd + r/ratio, ld - r, hd));
      beziers.add(new Bezier(ld - r, hd, ld - r, hd - r/ratio, ld - r/ratio, hd - r, ld, hd - r));
      beziers.add(new Bezier(ld, hd - r, ld + r/ratio, hd - r, ld + r, hd - r/ratio, ld + r, hd));
    }

    /*
     ld = largeurSupport/2 + 60;
     hd = hauteurSupport/2 + 60;
     for(int r=5; r< 80; r+= 6){
     beziers.add(new Bezier(ld - r, hd, ld - r, hd - r/ratio, ld - r/ratio, hd - r, ld, hd - r));
     }
     
     ld = largeurSupport/2 + 60;
     hd = hauteurSupport/2 - 60;
     for(int r=5; r< 80; r+= 6){
     beziers.add(new Bezier(ld, hd + r, ld - r/ratio, hd + r, ld - r, hd + r/ratio, ld - r, hd));
     }
     
     ld = largeurSupport/2 - 60;
     hd = hauteurSupport/2 + 60;
     for(int r=5; r< 80; r+= 6){
     beziers.add(new Bezier(ld, hd - r, ld + r/ratio, hd - r, ld + r, hd - r/ratio, ld + r, hd));
     }
     
     ld = largeurSupport/2 - 60;
     hd = hauteurSupport/2 - 60;
     for(int r=5; r< 80; r+= 6){
     beziers.add(new Bezier(ld + r, hd, ld + r, hd + r/ratio, ld + r/ratio, hd + r, ld, hd + r));
     }
     */
    //beziers.add(new Bezier(ld, hd, ld - 20, hd + 20,ld + 20, hd - 120, ld, hd - 100));
    //beziers.add(new Bezier(ld, hd - 100, ld -20, hd - 120,ld , hd, ld+20, hd +20));
  }

  if ( key == 'a')
  {
    float ld = largeurSupport/2;
    float hd = hauteurSupport/2;
    float midRange = 120;

    greymap.printMap();
    for (int r=145; r> 45; r-= 5) {
      beziers.add(new Bezier(ld - midRange, hd + midRange + r, ld - midRange, hd + midRange + r, ld + midRange, hd - midRange + r, ld + midRange, hd - midRange + r));
    }
  }

  if ( key == 'o')
  {
    ArrayList<Bezier> boundDrawingBezier = new ArrayList<Bezier>();

    float minX = largeurSupport/2;
    float maxX = largeurSupport/2;
    float minY = hauteurSupport/2;
    float maxY = hauteurSupport/2;
    for (int i = 0; i < beziers.size (); i++)
    {
      if (beziers.get(i).x1 < minX) {
        minX = beziers.get(i).x1;
      }
      if (beziers.get(i).x2 < minX) {
        minX = beziers.get(i).x2;
      }
      if (beziers.get(i).x3 < minX) {
        minX = beziers.get(i).x3;
      }
      if (beziers.get(i).x4 < minX) {
        minX = beziers.get(i).x4;
      }

      if (beziers.get(i).x1 > maxX) {
        maxX = beziers.get(i).x1;
      }
      if (beziers.get(i).x2 > maxX) {
        maxX = beziers.get(i).x2;
      }
      if (beziers.get(i).x3 > maxX) {
        maxX = beziers.get(i).x3;
      }
      if (beziers.get(i).x4 > maxX) {
        maxX = beziers.get(i).x4;
      }

      if (beziers.get(i).y1 < minY) {
        minY = beziers.get(i).y1;
      }
      if (beziers.get(i).y2 < minY) {
        minY = beziers.get(i).y2;
      }
      if (beziers.get(i).y3 < minY) {
        minY = beziers.get(i).y3;
      }
      if (beziers.get(i).y4 < minY) {
        minY = beziers.get(i).y4;
      }

      if (beziers.get(i).y1 > maxY) {
        maxY = beziers.get(i).y1;
      }
      if (beziers.get(i).y2 > maxY) {
        maxY = beziers.get(i).y2;
      }
      if (beziers.get(i).y3 > maxY) {
        maxY = beziers.get(i).y3;
      }
      if (beziers.get(i).y4 > maxY) {
        maxY = beziers.get(i).y4;
      }
    }

    greymap.printMap();

    boundDrawingBezier.add(new Bezier(minX, minY, minX, minY, minX, maxY, minX, maxY));
    boundDrawingBezier.add(new Bezier(minX, maxY, minX, maxY, maxX, maxY, maxX, maxY));
    boundDrawingBezier.add(new Bezier(maxX, maxY, maxX, maxY, maxX, minY, maxX, minY));
    boundDrawingBezier.add(new Bezier(maxX, minY, maxX, minY, minX, minY, minX, minY));

    traceThread=new TraceThread(boundDrawingBezier, 0, 0, 0);
    trcThrd=new Thread(traceThread);
    trcThrd.start();
  }






  if (key =='z')
  {
    if (beziers.size()>0)
    {
      println("DELETE");
      beziers.remove(beziers.size()-1);
      //backgroundWithMarge();
    }
  }

  if (key =='d') // Delete lines
  {
    if (beziers.size()>0)
    {
      String edit = "beziers.size() = " + beziers.size();
      println(edit);

      for (int i=beziers.size ()-1; i>=0; i--)
      {
        beziers.remove(i);
        if (i>1 && (beziers.get(i-1).x1 != beziers.get(i-2).x2 || beziers.get(i-1).y1 != beziers.get(i-2).y2))
        {
          beziers.remove(i-1);
          break;
        }
      }
      //backgroundWithMarge();
    }
  }

  if (key == 'i') {
    importSVG("KNR_Logo");
  }

  if (key == 'u') {
    PShape fileSVG;
    PShape[] shapeSVG;
    ArrayList<Float> bezCoo = new ArrayList<Float>();

    fileSVG = loadShape("VD_trace1.svg");
    shapeSVG = fileSVG.getChildren();

    for (int i = 0; i < shapeSVG.length; i++) {
      bezCoo.clear();
      int v = shapeSVG[i].getVertexCount();
      println("vertex count: " + v);
      for (int j = 0; j < v; j++) {
        println(i + " //// " +j + " /// " + shapeSVG[i].getVertex(j));
        bezCoo.add(shapeSVG[i].getVertex(j).x);
        bezCoo.add(shapeSVG[i].getVertex(j).y);
        //println(shapeSVG[i].getVertex(j).x);
        //println(shapeSVG[i].getVertex(j).y);
        if (bezCoo.size() == 8) {
          beziers.add(new Bezier(bezCoo.get(0), bezCoo.get(1), bezCoo.get(2), bezCoo.get(3), bezCoo.get(4), bezCoo.get(5), bezCoo.get(6), bezCoo.get(7)));
          bezCoo.clear();
          println(bezCoo.size());
        }
      }
    }
  }
}