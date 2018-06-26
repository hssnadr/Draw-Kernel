void microWait(int dly_) {
  // Micro delay function without using basic delay function
  long timer_ = micros();
  do {}
  while (micros() - timer_ < dly_);
}

void milliWait(int dly_) {
  // Micro delay function without using basic delay function
  long timer_ = millis();
  do {}
  while (millis() - timer_ < dly_);
}

unsigned int hexToDec(String hexString) {
  // Convert a hexadecimal string number into a decimal integer
  // See : https://github.com/benrugg/Arduino-Hex-Decimal-Conversion/blob/master/hex_dec.ino

  unsigned int decValue = 0; // initialize return value
  int nextInt;

  for (int i = 0; i < hexString.length(); i++) {
    nextInt = int(hexString.charAt(i));
    if (nextInt >= 48 && nextInt <= 57) nextInt = map(nextInt, 48, 57, 0, 9);
    if (nextInt >= 65 && nextInt <= 70) nextInt = map(nextInt, 65, 70, 10, 15);
    if (nextInt >= 97 && nextInt <= 102) nextInt = map(nextInt, 97, 102, 10, 15);
    nextInt = constrain(nextInt, 0, 15);

    decValue = (decValue * 16) + nextInt;
  }
  return decValue;
}

String parseString(String data, char separator, int index){
  int found = 0;
  int strIndex[] = { 0, -1 };
  int maxIndex = data.length() - 1;
  
  for (int i = 0; i <= maxIndex && found <= index; i++) {
      if (data.charAt(i) == separator || i == maxIndex) {
          found++;
          strIndex[0] = strIndex[1] + 1;
          strIndex[1] = (i == maxIndex) ? i+1 : i;
      }
  }
  return found > index ? data.substring(strIndex[0], strIndex[1]) : "";
}
