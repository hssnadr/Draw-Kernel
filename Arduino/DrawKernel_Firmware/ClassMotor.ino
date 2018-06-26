Motor::Motor(int motIndex_, int pinDir_, int pinStep_, int pinStartCourse_, int pinEndCourse_, String trueDirection_) {
  this->motIndex = motIndex_ ;

  if (trueDirection_ == "FORWARD") {
    this->trueDirection = true ;
  }
  if (trueDirection_ == "BACKWARD") {
    this->trueDirection = false ;
  }

  // Set motor pin
  this->pinDir = pinDir_ ;
  this->pinStep = pinStep_ ;

  // Set end course sensors pin
  this->pinStartCourse = pinStartCourse_ ;
  this->pinEndCourse = pinEndCourse_ ;
}

void Motor::begin() {
  // Set motor pin
  pinMode(this->pinDir, OUTPUT);
  pinMode(this->pinStep, OUTPUT);

  // Set end course sensors pin
  pinMode(this->pinStartCourse, INPUT);
  pinMode(this->pinEndCourse, INPUT);

  this->stepMot = 0 ;
}

void Motor::setDirection(boolean dir_) {
  if (dir_) {
    if (trueDirection) {
      digitalWrite(this->pinDir, HIGH);
    }
    else {
      digitalWrite(this->pinDir, LOW);
    }

    this->isGoingForward = true;
  }
  else {
    if (trueDirection) {
      digitalWrite(this->pinDir, LOW);
    }
    else {
      digitalWrite(this->pinDir, HIGH);
    }

    this->isGoingForward = false;
  }
}

void Motor::setDirection(int dn_) {
  if (dn_ >= 0) {
    this->setDirection(true);
  }
  else {
    this->setDirection(false);
  }
}

void Motor::doOneStep() {
  if (this->stepMot) {
    if (!(this->startCourse && !(this->isGoingForward)) && !(this->endCourse && this->isGoingForward)) {
      digitalWrite(this->pinStep, HIGH);
      microWait(dly);
      digitalWrite(this->pinStep, LOW);
      microWait(dly);

      if (!this->isGroupOver) {
        if (this->isGoingForward) {
          this->groupStepsReallyDone++;
        }
        else {
          this->groupStepsReallyDone--;
        }

        //      Serial.println("-----");
        //      Serial.print(this->motIndex); Serial.print(" -> "); Serial.println(this->iGStep);
        //      Serial.print(this->motIndex); Serial.print(" -> "); Serial.println(this->nGStep);
        //      Serial.print(this->motIndex); Serial.print(" -> "); Serial.println(this->groupStepsReallyDone);
        //      Serial.print(this->motIndex); Serial.print(" -> "); Serial.println(this->stepMot);
      }
    }
    else {
      if (!this->isGroupOver) {
        if (this->isGoingForward) {
          this->groupStepsNotDone++;
        }
        else {
          this->groupStepsNotDone--;
        }
      }
    }

    if (abs(this->groupStepsReallyDone + this->groupStepsNotDone) == abs(this->nGStep)) {
      this->isGroupOver = true ;
    }
    this->stepMot--;
  }
}

void Motor::setGroupSteps(int nGStep_, int timeGStep_) {
  this->setDirection(nGStep_);                  // set direction
  this->nGStep = abs(nGStep_) ;
  this->iGStep = 0 ;
  this->groupStepsReallyDone = 0 ;
  this->groupStepsNotDone = 0 ;

  if (nGStep_ != 0) {
    this->isGroupOver = false ;
    this->delayGStep = timeGStep_ / nGStep ;
    this->timerGStep = millis() ;

    //    Serial.println("");
    //    Serial.print(this->motIndex); Serial.print(" ////// "); Serial.print(nGStep); Serial.print(" ////// "); Serial.println(delayGStep);
  }
  else {
    this->isGroupOver = true ;
  }
}

void Motor::getGroupSteps() {
  if (!this->isGroupOver) {
    if (this->iGStep < abs(this->nGStep)) {
      if (millis() - this->timerGStep >= this->delayGStep) {
        this->iGStep++;
        this->stepMot++;
        this->timerGStep = millis();
        //        Serial.print(motIndex); Serial.print(" iGStep = "); Serial.print(iGStep); Serial.print(" iGStep = "); Serial.println(nGStep);
      }

      //      Serial.println("-----");
      //      Serial.print(this->motIndex); Serial.print(" -> "); Serial.println(this->iGStep);
      //      Serial.print(this->motIndex); Serial.print(" -> "); Serial.println(this->nGStep);
      //      Serial.print(this->motIndex); Serial.print(" -> "); Serial.println(this->groupStepsReallyDone);
      //      Serial.print(this->motIndex); Serial.print(" -> "); Serial.println(this->stepMot);

    }
    //    else {
    //      this->iGStep++;
    //      this->stepMot++;
    //      this->isGroupOver = true ;
    //    }
  }
}

void Motor::getEndCourseSensorStatue() {
  // Check motor start course sensor
  boolean newState_ = digitalRead(this->pinStartCourse) ;
  if (newState_ != this->startCourse && millis() - this->timerStartCourse > 100) {
    Serial.print('C');
    Serial.print(this->motIndex);
    Serial.print("0"); // start course
    Serial.println(newState_);

    this->startCourse = newState_;
    this->timerStartCourse = millis();
  }

  // Check motor end course sensor
  newState_ = digitalRead(this->pinEndCourse) ;
  if (newState_ != this->endCourse && millis() - this->timerEndCourse > 100) {
    Serial.print('C');
    Serial.print(this->motIndex);
    Serial.print("1"); // end course
    Serial.println(newState_);

    this->endCourse = newState_;
    this->timerEndCourse = millis();
  }
}
