//TraceThread motorThread;
//Thread motThrd;

//traceThread=new TraceThread(beziers, 20, 52, 72, 48); // Pentel
//trcThrd=new Thread(traceThread);
//trcThrd.start();

public class MotorThread implements Runnable {
  Thread thread;
  int dn;
  int timeSteps;
  Moteur motor;
  private ConcurrentLinkedQueue<Moteur> queue;

  public MotorThread(Moteur mot_, int dn_, int timeStps_, ConcurrentLinkedQueue<Moteur> q_) {
    motor = mot_;
    dn = abs(dn_);
    timeSteps = timeStps_;
    queue = q_;
  }

  public void start() {
    thread = new Thread(this);
    thread.start();
  }

  public void run() {
    if (this.dn != 0) {
      int delay_ = this.timeSteps / this.dn;
      for (int i=0; i<this.dn; i++) {
        queue.offer(this.motor);
        //this.motor.faire1pas(); /////////////// PUT IT IN A COMMON THREAD FOR EACH MOTOR >>> AVOID SERIAL MESSAGES CONFUSION
        
        delay(delay_);
      }
    }

    this.motor.isOver = true;
  }

  public void stop() {
    thread = null;
  }
}