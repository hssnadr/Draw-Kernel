
// The following short XML file called "mammals.xml" is parsed 
// in the code below. It must be in the project's "data" folder.
//
// <?xml version="1.0"?>
// <mammals>
//   <animal id="0" species="Capra hircus">Goat</animal>
//   <animal id="1" species="Panthera pardus">Leopard</animal>
//   <animal id="2" species="Equus zebra">Zebra</animal>
// </mammals>

XML xml;

void importSVG(String filename) {
  xml = loadXML(filename + ".svg");
  XML[] children = xml.getChildren("path");

  ArrayList<Float> bezCoo = new ArrayList<Float>();

  for (int i = 0; i < children.length; i++) {
    println("----------------");
    bezCoo.clear();
    String id = children[i].getString("class");
    String pathStringSVG = children[i].getString("d");
    String name = children[i].getContent();
    println(id + ", " + pathStringSVG + ", " + name);

    pathStringSVG = pathStringSVG.replaceAll("-", ",-");
    pathStringSVG = pathStringSVG.replaceAll(",,", ",");
    pathStringSVG = pathStringSVG.replaceAll("l,", "l");
    pathStringSVG = pathStringSVG.replaceAll("s,", "s");
    pathStringSVG = pathStringSVG.replaceAll("c,", "c");
    pathStringSVG = pathStringSVG.replaceAll("h,", "h");
    pathStringSVG = pathStringSVG.replaceAll("v,", "v");
    pathStringSVG = pathStringSVG.replaceAll("L,", "L");
    pathStringSVG = pathStringSVG.replaceAll("S,", "S");
    pathStringSVG = pathStringSVG.replaceAll("C,", "C");
    pathStringSVG = pathStringSVG.replaceAll("H,", "H");
    pathStringSVG = pathStringSVG.replaceAll("V,", "V");
    pathStringSVG = pathStringSVG.replaceAll(" ", "");
    println(pathStringSVG);

    //Manage "," "h" "v" & "s"
    int totCaracter = pathStringSVG.length();
    int oldInd = 0;
    boolean isH = false;
    boolean isV = false;

    float refX = 0; // ref point X
    float refY = 0; // ref point Y
    float curX = 0; // current point - X absolute 
    float curY = 0; // current point - Y absolute
    float curCX = 0; // current control point - X absolute 
    float curCY = 0; // current control point - Y absolute
    float lastCX = 0;
    float lastCY = 0;

    String string_ = pathStringSVG.replaceAll("l", ",");
    string_ = string_.replaceAll("L", ",");
    string_ = string_.replaceAll("v", ",");
    string_ = string_.replaceAll("V", ",");
    string_ = string_.replaceAll("h", ",");
    string_ = string_.replaceAll("H", ",");
    string_ = string_.replaceAll("c", ",");
    string_ = string_.replaceAll("C", ",");
    string_ = string_.replaceAll("s", ",");
    string_ = string_.replaceAll("S", ",");
    string_ = string_.replaceAll("z", ",");

    totCaracter = string_.length();
    for (int j=0; j<totCaracter; j++)
    {
      char curCar = pathStringSVG.charAt(j);
      println(j + " --> " + curCar);
      switch (curCar) {
      case 'M':
        String nextPoints =  string_.substring(j+1, totCaracter); // rest of the String
        String nextPoint[] = split(nextPoints, ',');

        curX = float(nextPoint[0]); // current point - X absolute 
        curY = float(nextPoint[1]); // current point - Y absolute

        bezCoo.clear();

        bezCoo.add(curX);
        bezCoo.add(curY);

        refX = curX; // ref point X
        refY = curY; // ref point Y

        j += nextPoint[0].length() + nextPoint[1].length() + 1; // skip points cause already added
        break;

      case 'l':

        nextPoints =  string_.substring(j+1, totCaracter); // rest of the String
        nextPoint = split(nextPoints, ','); // array

        curX = float(nextPoint[0]); // next point X
        curY = float(nextPoint[1]); // next point Y
        curCX = curX; // next current point X
        curCY = curY; // next current point Y

        bezCoo.add(refX); // control point for last point
        bezCoo.add(refY); // control point for last point
        bezCoo.add(curX + refX); // control point for new point
        bezCoo.add(curY + refY); // control point for new point

        bezCoo.add(curX + refX); // new point
        bezCoo.add(curY + refY); // new point

        j += nextPoint[0].length() + nextPoint[1].length() + 1; // skip points cause already added (+1 for comas, why not "+2" ? I don't know...)
        break;

      case 'L':

        nextPoints =  string_.substring(j+1, totCaracter); // rest of the String
        nextPoint = split(nextPoints, ','); // array

        curX = float(nextPoint[0]); // next point X
        curY = float(nextPoint[1]); // next point Y
        curCX = curX; // next current point X
        curCY = curY; // next current point Y

        bezCoo.add(refX); // get last X for line control point
        bezCoo.add(refY); // get last Y for line control point

        bezCoo.add(curX); // new control point
        bezCoo.add(curY); // new control point

        //refX = curX; // update refX on new subpath
        //refY = curY; // update refY on new subpath

        bezCoo.add(curX); // new point 
        bezCoo.add(curY); // new point

        j += nextPoint[0].length() + nextPoint[1].length() + 1; // skip points cause already added (+1 for comas, why not "+2" ? I don't know...)
        break;

      case 'c':

        nextPoints =  string_.substring(j+1, totCaracter); // rest of the String
        nextPoint = split(nextPoints, ','); // array

        curCX = float(nextPoint[0]); // next control point X
        curCY = float(nextPoint[1]); // next control point Y
        curX = float(nextPoint[2]); // next point X
        curY = float(nextPoint[3]); // next point Y
        float curCX2 = float(nextPoint[4]); // next control point X
        float curCY2 = float(nextPoint[5]); // next control point Y

        bezCoo.add(curCX + refX);
        bezCoo.add(curCY + refY);
        bezCoo.add(curX + refX);
        bezCoo.add(curY + refY);

        bezCoo.add(curCX2 + refX);
        bezCoo.add(curCY2 + refY);

        j += nextPoint[0].length() + nextPoint[1].length() + nextPoint[2].length() + nextPoint[3].length() + nextPoint[4].length() + nextPoint[5].length() + 5; // skip points cause already added (+ comas)
        break;

      case 'C':
        nextPoints =  string_.substring(j+1, totCaracter); // rest of the String
        nextPoint = split(nextPoints, ','); // array

        curCX = float(nextPoint[0]); // next control point X
        curCY = float(nextPoint[1]); // next control point Y
        curX = float(nextPoint[2]); // next point X
        curY = float(nextPoint[3]); // next point Y
        curCX2 = float(nextPoint[4]); // next control point X
        curCY2 = float(nextPoint[5]); // next control point Y

        bezCoo.add(curCX);
        bezCoo.add(curCY);
        bezCoo.add(curX);
        bezCoo.add(curY);

        bezCoo.add(curCX2);
        bezCoo.add(curCY2);

        j += nextPoint[0].length() + nextPoint[1].length() + nextPoint[2].length() + nextPoint[3].length() + nextPoint[4].length() + nextPoint[5].length() + 5; // skip points cause already added (+ comas)
        oldInd = j+1;
        break;

      case 'v':
        bezCoo.add(refX);
        bezCoo.add(refY);

        nextPoints =  string_.substring(j+1, totCaracter); // rest of the String
        nextPoint = split(nextPoints, ','); // array

        curX = refX; // next point X
        curCX = curX; // next current point X
        curY = float(nextPoint[0]); // next point Y
        curCY = curY; // next current point Y

        bezCoo.add(curX);
        bezCoo.add(curY + refY);
        bezCoo.add(curX);
        bezCoo.add( curY + refY);

        j += nextPoint[0].length(); // skip points cause already added
        break;

      case 'V':
        bezCoo.add(refX);
        bezCoo.add(refY);

        nextPoints =  string_.substring(j+1, totCaracter); // rest of the String
        nextPoint = split(nextPoints, ','); // array

        curX = refX; // next point X
        curCX = curX; // next current point X
        curY = float(nextPoint[0]); // next point Y
        curCY = curY; // next current point Y

        bezCoo.add(curX);
        bezCoo.add(curY);
        bezCoo.add(curX);
        bezCoo.add(curY);

        //bezCoo.add(refX);
        //bezCoo.add(refY);

        j += nextPoint[0].length(); // skip points cause already added
        break;  

      case 'h':
        bezCoo.add(refX);
        bezCoo.add(refY);

        nextPoints =  string_.substring(j+1, totCaracter); // rest of the String
        nextPoint = split(nextPoints, ','); // array

        curX = float(nextPoint[0]); // next point X
        curCX = curX; // next current point X
        curY = refY; // next point Y
        curCY = curY; // next current point Y

        //         refX = curX + refX;
        //         refY = curY;

        bezCoo.add(curX + refX);
        bezCoo.add(curY);
        bezCoo.add(curX + refX);
        bezCoo.add(curY);

        j += nextPoint[0].length(); // skip points cause already added
        oldInd = j+1;
        break;

      case 'H':
        bezCoo.add(refX);
        bezCoo.add(refY);

        nextPoints =  string_.substring(j+1, totCaracter); // rest of the String
        nextPoint = split(nextPoints, ','); // array

        curX = float(nextPoint[0]); // next point X
        curCX = curX; // next current point X
        curY = refY; // next point Y
        curCY = curY; // next current point Y

        bezCoo.add(curX);
        bezCoo.add(curY);
        bezCoo.add(curX);
        bezCoo.add(curY);

        //bezCoo.add(refX);
        //bezCoo.add(refY);

        j += nextPoint[0].length(); // skip points cause already added
        oldInd = j+1;
        break;

      case 's':
        curCX = refX - lastCX;
        curCY = refY - lastCY; 
        bezCoo.add(curCX + refX);
        bezCoo.add(curCY + refY);

        nextPoints =  string_.substring(j+1, totCaracter); // rest of the String
        nextPoint = split(nextPoints, ','); // array

        curX = float(nextPoint[0]); // next point X
        curY = float(nextPoint[1]); // next point Y
        curCX = float(nextPoint[2]); // next control point X
        curCY = float(nextPoint[3]); // next control point Y

        bezCoo.add(curX + refX);
        bezCoo.add(curY + refY);

        bezCoo.add(curCX + refX);
        bezCoo.add(curCY + refY);

        //bezCoo.add(refX);
        //bezCoo.add(refY);

        j += nextPoint[0].length() + nextPoint[1].length() + nextPoint[2].length() +  + nextPoint[3].length() + 3; // + 3 for comas
        break;

      case 'z':
        //Trace a straight line between last and first point of the path 
        bezCoo.add(refX); //add last point (point X)
        bezCoo.add(refY); //add last point (point Y)

        bezCoo.add(bezCoo.get(0)); //add first point (control X)
        bezCoo.add(bezCoo.get(1)); //add first point (control Y)
        bezCoo.add(bezCoo.get(0)); //add first point (point X)
        bezCoo.add(bezCoo.get(1)); //add first point (point Y)

        break;
      }

      if (bezCoo.size() == 8) {
        beziers.add(new Bezier(bezCoo.get(0), bezCoo.get(1), bezCoo.get(2), bezCoo.get(3), bezCoo.get(4), bezCoo.get(5), bezCoo.get(6), bezCoo.get(7)));
        println(bezCoo.get(0) + " // " + bezCoo.get(1) + " // " + (bezCoo.get(2)) + " // " + (bezCoo.get(3)) + " // " + (bezCoo.get(4)) + " // " + (bezCoo.get(5)) + " // " + (bezCoo.get(6)) + " // " + (bezCoo.get(7)) );

        lastCX = bezCoo.get(4); // in case next caracter is 's' and need this information
        lastCY = bezCoo.get(5); // in case next caracter is 's' and need this information

        refX = bezCoo.get(6);
        refY = bezCoo.get(7);

        bezCoo.clear();
        bezCoo.add(refX);
        bezCoo.add(refY);
        println(bezCoo);
      }

      println(j+1 + " / " + totCaracter);
    }
  }
}