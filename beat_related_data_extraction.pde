import ddf.minim.*;
import ddf.minim.analysis.*;
//import ddf.minim.effects.*;
//import ddf.minim.signals.*;
import ddf.minim.spi.*;
//import ddf.minim.ugens.*;

Minim minim;

//analyze
String filename = "vision";
float decayRate = 0.05;

int[] frameIds = new int[0];
int[] timeStamps = new int[0];
float[] gaps = new float[0];

float[] amps = new float[0];
float ampProp = 0.4;
float ampThreshold;

float[] accs = new float[0];
float accProp = 0.4;
float accThreshold;


//visualize
Table table;
AudioPlayer song;
int beginTime;
boolean start = false;
int rowCount = 0;
int timeStamp;
float rad;
//float scale = 0.1;

float[] amprange = new float[2];
float[] accrange = new float[2];

String[] info;

void setup() {
  size(700, 500);
  minim = new Minim(this);
  
  //analyze
  energyDetection(filename);
  
  //visualize
  table = loadTable(filename + "Beats.csv", "header");
  minim = new Minim(this);
  song = minim.loadFile(filename + ".mp3");
  
  timeStamp = table.getRow(rowCount).getInt("timeStamp");
  
  amprange[0] = 50;
  amprange[1] = 50 + 550 / 2;
  
  accrange[0] = amprange[1] + 50;
  accrange[1] = accrange[0] + 550 / 2;
  
  Table forWriter = loadTable(filename + "Beats.csv");
  createScript(forWriter);
  song.play();
}

//String[] getInfo(Table table) {
//  String[] info = new String[
//}

void draw() {
  if(song.isPlaying() && !start) {
    beginTime = millis();
    start = true;
  }
  
  background(0);
  
  int now = millis() - beginTime;
  
  rad -= 1.0;
  if(rad < 0.0) rad = 0.0;
  
  if(now > timeStamp) {
    rowCount++;
    timeStamp = table.getRow(rowCount).getInt("timeStamp");
    
    rad = table.getRow(rowCount).getFloat("amp") * 100;
  }
  
  ellipse(600, 400, rad, rad);
  
  graphs();
}

void graphs() {
  noFill();
  stroke(255);
  //amp
  for(int i = 0; i < table.getRowCount(); i++) {
    TableRow _row = table.getRow(i);
    
    float _amp = _row.getFloat("amp");
    float _acc = _row.getFloat("acc");
    
    float x_amp = map(_amp, 0.0, 1.0, amprange[0], amprange[1]);
    float y_amp = random(50, 200);
    
    float x_acc = map(_acc, 0.0, 1.0, accrange[0], accrange[1]);
    float y_acc = random(50, 200);
    
    point(x_amp, y_amp);
    point(x_acc, y_acc);
  }
}