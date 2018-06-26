void serialEvent(Serial myPort) {
  String message = myPort.readStringUntil(13);

  if (message != null)
  {
    message = message.trim();
    println("RECEIVE :", message, idGroupSteps);

    char adr_ = message.charAt(0);
    if (message.length() > 1) {
      String serialData_ = message.substring(1, message.length());

      switch(adr_) {
      case 'G' :
        {
          int[] realStepMots_ = int(split(serialData_, ';'));
          if (realStepMots_[0] == idGroupSteps && realStepMots_.length == moteurs.size()+1) {
            for (int i = 0; i < moteurs.size(); i++) {
              //moteurs.get(i).nReal += realStepMots_[i+1];
              moteurs.get(i).setnReal(moteurs.get(i).nReal + realStepMots_[i+1]);
            }
            isGroupStepOver = true;
            idGroupSteps = -1;
          }
          break;
        }

      case 'C':
        {
          if (serialData_.length() == 3) {
            int motIndex_ = serialData_.charAt(0) - '0';
            int motPos_ = serialData_.charAt(1) - '0';
            boolean state_ = boolean(serialData_.charAt(2) - '0');

            switch (motPos_) {
            case 0 :
              moteurs.get(motIndex_).isAtStartCourse = state_;
              break;
            case 1 :
              moteurs.get(motIndex_).isAtEndCourse = state_;
              break;
            default :
              break;
            }
          }
          break;
        }

      default :
        break;
      }
    }
  }
}