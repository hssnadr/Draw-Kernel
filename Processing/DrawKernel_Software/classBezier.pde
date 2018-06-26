class Bezier {
  
  // in MILLIMETERS
  float x1; //premier point d'ancrage
  float y1;
  float x2; //point de contrôle du premier point d'ancrage
  float y2;
  float x3; //second point d'ancrage
  float y3;
  float x4; //point de contrôle du deuxième point d'ancrage
  float y4;

  float epaisseur = 0.5f;
  float lengthB;
  
  boolean isPenTraced = false;

  Bezier(float x1_, float y1_, float x2_, float y2_, float x3_, float y3_, float x4_, float y4_) {
    x1 = x1_;
    y1 = y1_;
    x2 = x2_;
    y2 = y2_;
    x3 = x3_;
    y3 = y3_;
    x4 = x4_;
    y4 = y4_;
    
    lengthB = getLength();
  }
  
  float getLength(){
    int nDecoupe = 100; // + c'est grand + c'est précis
    float delta = 1/(float)(nDecoupe);
    ArrayList<Float> xM = new ArrayList<Float>();
    ArrayList<Float> yM = new ArrayList<Float>();
    float lengthBezier = 0.0f;
    
    //Get intermediate points
    for(int i = 0; i <= nDecoupe; i++)
    {
      xM.add(bezierPoint(x1, x2, x3, x4, i*delta));
      yM.add(bezierPoint(y1, y2, y3, y4, i*delta));
    }
    
    //Get curve length
    for(int i = 0; i < nDecoupe; i++)
    {
      lengthBezier += dist(xM.get(i), yM.get(i), xM.get(i+1), yM.get(i+1));
    }
    
    return lengthBezier;
  }

  void display() {
    noFill();
    if(!isPenTraced){
      stroke(0);
    }
    else{
      stroke(255,0,0);
    }
    
    strokeWeight(epaisseur);
    bezier(x1*ratioMMtoPix, y1*ratioMMtoPix, x2*ratioMMtoPix, y2*ratioMMtoPix, x3*ratioMMtoPix, y3*ratioMMtoPix, x4*ratioMMtoPix, y4*ratioMMtoPix);
  }
}