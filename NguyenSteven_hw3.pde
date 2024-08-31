import beads.*;
import controlP5.*;

AudioContext ac;
SamplePlayer musicPlayer, gpsPlayer1, gpsPlayer2, gpsPlayer3;
Gain masterGain;
Glide musicGlide;
ControlP5 p5;
BiquadFilter musicFilter;

// String paths for all audios needed
String musicFile = "song.wav";
String gpsFile1 = "collision.wav";
String gpsFile2 = "ponce.wav";
String gpsFile3 = "grayson.wav";

// Declare boolean flags to track the playing state of each SamplePlayer
boolean isGpsPlayer1Playing = false;
boolean isGpsPlayer2Playing = false;
boolean isGpsPlayer3Playing = false;

void setup() {
  size(400, 200);
  
  p5 = new ControlP5(this);
  
  ac = new AudioContext();

  // Setup music player
  Sample musicSample = SampleManager.sample(dataPath(musicFile));
  musicPlayer = new SamplePlayer(ac, musicSample);
  musicPlayer.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);

  musicFilter = new BiquadFilter(ac, 1);
  musicFilter.setType(BiquadFilter.HP);
  musicFilter.setFrequency(10);

  musicGlide = new Glide(ac, 0.5, 500);
  masterGain = new Gain(ac, 2, musicGlide);
  masterGain.addInput(musicFilter);
  musicFilter.addInput(musicPlayer);

  ac.out.addInput(masterGain);

  // Setup GPS players
  Sample gps1 = SampleManager.sample(dataPath(gpsFile1));
  Sample gps2 = SampleManager.sample(dataPath(gpsFile2));
  Sample gps3 = SampleManager.sample(dataPath(gpsFile3));
  
  gpsPlayer1 = new SamplePlayer(ac, gps1);
  gpsPlayer2 = new SamplePlayer(ac, gps2);
  gpsPlayer3 = new SamplePlayer(ac, gps3);

  // Add GUI buttons
  p5.addButton("playVoice1")
    .setPosition(50, 50)
    .setSize(100, 30)
    .setLabel("GPS1")
    .onClick((e) -> playVoice1());
    
  p5.addButton("playVoice2")
    .setPosition(150, 50)
    .setSize(100, 30)
    .setLabel("GPS2")
    .onClick((e) -> playVoice2());
    
  p5.addButton("playVoice3")
    .setPosition(250, 50)
    .setSize(100, 30)
    .setLabel("GPS3")
    .onClick((e) -> playVoice3());
    
  p5.addSlider("volume")
    .setPosition(50, 100)
    .setSize(300, 30)
    .setRange(0.0, 1.0)
    .setValue(0.5);
    
  ac.start();
  musicPlayer.start();
}

void playVoice1() {
  println("Playing voice 1...");
  playVoiceClip(gpsPlayer1, 1);
}

void playVoice2() {
  println("Playing voice 2...");
  playVoiceClip(gpsPlayer2, 2);
}

void playVoice3() {
  println("Playing voice 3...");
  playVoiceClip(gpsPlayer3, 3);
}

void playVoiceClip(SamplePlayer voicePlayer, int playerId) {
  println("Starting voice player...");

  // Stop any other GPS voice clips that are playing
  if (isGpsPlayer1Playing && playerId != 1) {
    gpsPlayer1.pause(true);
    isGpsPlayer1Playing = false;
  }
  if (isGpsPlayer2Playing && playerId != 2) {
    gpsPlayer2.pause(true);
    isGpsPlayer2Playing = false;
  }
  if (isGpsPlayer3Playing && playerId != 3) {
    gpsPlayer3.pause(true);
    isGpsPlayer3Playing = false;
  }

  // Apply ducking to the music
  musicGlide.setValue(0.25);
  musicFilter.setFrequency(5000);

  // Start the selected voice clip
  voicePlayer.setPosition(0);  // Ensure playback starts from the beginning
  voicePlayer.start();
  println("Voice clip started.");

  // Set the corresponding flag to true
  if (playerId == 1) isGpsPlayer1Playing = true;
  if (playerId == 2) isGpsPlayer2Playing = true;
  if (playerId == 3) isGpsPlayer3Playing = true;

  // Set an end listener to unduck the music when the voice clip finishes
  voicePlayer.setEndListener(new Bead() {
    protected void messageReceived(Bead message) {
      musicGlide.setValue(0.5);
      musicFilter.setFrequency(10);
      println("Voice clip finished. Unducking music.");

      // Reset the corresponding flag to false
      if (playerId == 1) isGpsPlayer1Playing = false;
      if (playerId == 2) isGpsPlayer2Playing = false;
      if (playerId == 3) isGpsPlayer3Playing = false;
    }
  });
}

void volume(float vol) {
  masterGain.setGain(vol);
}

void draw() {
  background(0);
  fill(255);
  textSize(16);
  textAlign(CENTER);
  text("GPS Voice Assistant", width/2, 30);
}
