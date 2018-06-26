void getSerialMessage() {

  if (Serial.available()) {
    // RECEIVE SERIAL MESSAGE
    bufIndex = 0;
    do
    {
      buff[bufIndex] = (char)Serial.read();   // Collect incoming serial character into char array
      if (buff[bufIndex] != -1) {
        bufIndex++;
      }
    } while (buff[bufIndex - 1] != 95);
    //-------------------------------------------------------------------
    //-------------------------------------------------------------------
    //-------------------------------------------------------------------

    // USE SERIAL MESSAGE
    switch (buff[0]) {
      case 'D' :
        {
          // Get direction
          int motIndex_ = buff[1] - '0' ;
          boolean dir_ = buff[2] - '0' ;   // False if = 0
          motors[motIndex_].setDirection(dir_);
          serialCounter++;
          break;
        }

      case 'M' :
        {
          // Set step
          int motIndex_ = buff[1] - '0' ;
          //Serial.println(motIndex_);
          motors[motIndex_].stepMot++;
          serialCounter++;
          break;
        }

      case 'G' :
        {
          String msgVal_ = "" ;
          for (int i = 0; i < bufIndex - 1; i++) {
            msgVal_ += buff[i];            // string data
          }

          idGroupStep = parseString(msgVal_, ';', 0);  // get id of the current group steps, to send it back once group is over

          for (int i = 0; i < nMotors; i++) {
            String dataMot_ = parseString(msgVal_, ';', i + 1);
            int nGStep_ = parseString(dataMot_, ',', 0).toInt();             // get number of steps
            int timeGStep_ = parseString(dataMot_, ',', 1).toInt();          // time to make all steps
            motors[i].setGroupSteps(nGStep_, timeGStep_);                    // set group steps
          }
          
          timerGroup = millis();
          serialCounter++;
          break;
        }

      case 'C' :
        {
          // Cancel steps
          int motIndex_ = buff[1] - '0' ;
          motors[motIndex_].stepMot = 0 ;
          Serial.flush();

          serialCounter++;
          break;
        }

      case 'S' :
        {
          // Get and set servo motor angle
          servo.write(hexToDec(String(buff[1] + buff[2]))); // convert hexadecimal angle to decimal and send to servo motor
          serialCounter++;
          break;
        }

      case 'y' :
        {
          Serial.println(serialCounter);
          break;
        }

      default :
        break;
    }
  }
}
