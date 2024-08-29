import beads.*;
import controlP5.*;

AudioContext ac;
SamplePlayer sp;
Gain masterGain;
Glide gainGlide;
ControlP5 p5;
String filename = "intermission.wav";

void setup() {
  size(400, 400);
  ac = new AudioContext();
  p5 = new ControlP5(this);
  
  // Load the sample
  try {
    sp = new SamplePlayer(ac, SampleManager.sample(dataPath(filename)));
    sp.setKillOnEnd(false);
    sp.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  } catch (Exception ex) {
    println("Problem loading sample: ", filename);
    ex.printStackTrace();
    exit();
  }
  
  // Set up gain
  gainGlide = new Glide(ac, 0.5, 500);
  masterGain = new Gain(ac, 1, gainGlide);
  masterGain.addInput(sp);
  
  // Connect to output
  ac.out.addInput(masterGain);
  
  // Create GUI controls
  p5.addButton("stop")
    .setPosition(50, 20)
    .setSize(300, 20)
    .setLabel("Stop");
  
  p5.addButton("playOriginal")
    .setPosition(50, 60)
    .setSize(300, 20)
    .setLabel("Play Original");
  
  p5.addButton("reverse")
    .setPosition(50, 100)
    .setSize(300, 20)
    .setLabel("Reverse");
  
  ac.start();
}

void stop(int value) {
  sp.pause(true);
}

void playOriginal(int value) {
  sp.setSample(SampleManager.sample(dataPath(filename)));
  sp.setToLoopStart();
  sp.start();
}


void draw() {
  background(0);
}
