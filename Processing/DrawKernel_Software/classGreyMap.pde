class GreyMap {
  PImage img;
  Cell[][] grid;
  int cols;
  int rows;

  GreyMap() {
    cols = (int)(largeurSupport*ratioMMtoPix);
    rows = (int)(hauteurSupport*ratioMMtoPix);
    grid = new Cell[cols][rows];

    img = loadImage("Owl_carre.jpg");  // Load the image into the program
    fillGrid();
  }

  void printMap() {
    //Print reference images
    printImg();
  }

  void fillGrid() {
    //Print reference images
    printImg();
  
    //Store pixels data from the reference images
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        // Initialize each object
        grid[i][j] = new Cell(i, j, get(i, j));
      }
    }

    //background(255);
  }

  void printImg() {
    //Affichage de l'image

    /*affiche l'image au centre de la fenêtre et la dimensionne correctement
     par rapport à cette fenêtre*/

    int diff = this.img.width - this.img.height;
    int newWidth = 0;
    int newHeight = 0;

    imageMode(CENTER);

    if (diff == 0)
    {
      newWidth = width;
      newHeight = height;
    }
    if (diff < 0)
    {
      newWidth = (int)(map(img.width, 0, img.height, 0, height));
      newHeight = height;
    }
    if (diff > 0)
    {
      newWidth = width;
      newHeight = (int)(map(img.height, 0, img.width, 0, width));
    }
    
    tint(255,80);
    image(img, width/2, height/2, newWidth, newHeight);
  }
  
  float getGreyVal(float xgmp, float ygmp) {

    xgmp *= ratioMMtoPix;
    ygmp *= ratioMMtoPix;

    float grval = 0;
    int ngmp = 3;
    for (int l=int (xgmp)-ngmp; l<=int(xgmp)+ngmp; l++) {
      for (int m=int (ygmp)-ngmp; m<=int(ygmp)+ngmp; m++) {
        if (l>=0 && l<this.cols && m>=0 && m<this.rows) {
          grval += brightness(this.grid[int(l)][int(m)].c) / pow(2*ngmp+1, 2);
          //println(brightness(this.grid[int(l)][int(m)].c));
        }
      }
    }
    //println("grval = " + grval);
    grval = 255 - grval;
    grval /= float(255);

    if (grval != 0) {
      grval = 100 * grval;
    } else {
      grval = 0;
    }

    return grval;
  }
}



// A Cell object
class Cell {
  // A cell object knows about its location in the grid 
  // as well as its size with the variables x,y,w,h
  int x, y;   // x,y location
  color c;   // rgb pixel

  // Cell Constructor
  Cell(int x_, int y_, color c_) {
    x = x_;
    y = y_;
    c = c_;
  }
}