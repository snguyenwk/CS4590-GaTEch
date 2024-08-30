import beads.*;
import controlP5.*;

AudioContext ac;
SamplePlayer sp;
Gain masterGain;
Glide gainGlide;
ControlP5 p5;

String filename = "intermission.wav";
Sample og;

void setup() {
  size(400, 400);
  ac = new AudioContext();
  p5 = new ControlP5(this);
  
  // Load the sample
  try {
    og = SampleManager.sample(dataPath(filename));
    sp = new SamplePlayer(ac, og);
    sp.setKillOnEnd(false);
    sp.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    sp.pause(true);
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
    .setLabel("Reverse Audio");
  
  ac.start();
   
}

void stop(int value) {
  sp.pause(true);
}

void playOriginal(int value) {
  sp.setSample(og);
  sp.setToLoopStart();
  sp.pause(false);
}

void reverse(int value) {
  try {
    if (og == null) {
      println("Original sample was not loaded.");
      return;
    }
    
    int channels = og.getNumChannels();
    int frames = (int) og.getNumFrames();
    float[][] frameData = new float[channels][frames];
    
    og.getFrames(0, frameData);
    
    for (int ch = 0; ch < channels; ch++) {
      for (int i = 0; i < frames / 2;i++) {
        float temp = frameData[ch][i];
        frameData[ch][i] = frameData[ch][frames - 1 - i];
        frameData[ch][frames - 1 - i] = temp;
      }
    }
    
    Sample reversed = new Sample(frames, channels, og.getSampleRate());
    reversed.putFrames(0, frameData);
    
    sp.setSample(reversed);
    sp.setToLoopStart();
    sp.pause(false);
    sp.start();
    
  } catch (Exception ex) {
    println("Error reversing the sample: " + ex.getMessage());
    ex.printStackTrace();
  }
}
    

void draw() {
  background(350);
}
