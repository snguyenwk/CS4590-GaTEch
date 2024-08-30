import beads.*;
import controlP5.*;

AudioContext ac;
WavePlayer wp;
SamplePlayer sp;
Gain masterGain;
Glide gainGlide;
ControlP5 p5;
boolean isPaused = false;

String filename = "accordian.wav";

void setup() {
  size(400, 400);
  ac = new AudioContext();
  p5 = new ControlP5(this);
  //wp = new WavePlayer(ac, 440, Buffer.SINE);
  
  try {
    sp = new SamplePlayer(ac, SampleManager.sample(dataPath(filename)));
    sp.setKillOnEnd(false);
    sp.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  } catch (Exception ex) {
    println("Problem loading sample: ", filename);
    ex.printStackTrace();
    exit();
  }
  
  sp.setEndListener(new Bead() {
    public void messageReceived(Bead message) {
      println("Reached end of sample");
    }
  });

  gainGlide = new Glide(ac, 0.5, 500);
  masterGain = new Gain(ac, 1, gainGlide /*0.5*/);
  masterGain.addInput(sp);
  
  ac.out.addInput(masterGain);
  //ac.out.addInput(sp);
  //ac.out.addInput(wp);
  
  // after setting up the audio graph, create the GUI controls
  p5.addButton("playPause")
    .setPosition(50, 20)
    .setSize(300, 20)
    .setLabel("Toggle play/pause");
    
  p5.addSlider("gainSlider")
    .setPosition(175, 60)
    .setSize(50, 300)
    .setRange(0, 100)
    .setValue(50)
    .setLabel("Gain");
    
  ac.start();
}

void playPause(int value) {
  isPaused = !isPaused;
  sp.pause(isPaused);
}

void gainSlider(int value) {
  gainGlide.setValue(value / 100.0);
}

void draw() {
  background(0);
}

//void mouseClicked() {
//  println("Hello, World!");
//  isPaused = !isPaused;
//  sp.pause(isPaused);
//}
