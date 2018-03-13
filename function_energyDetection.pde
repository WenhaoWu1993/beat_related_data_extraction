void energyDetection(String filename) {
  AudioSample audio = minim.loadSample(filename + ".mp3");
  int fftSize = audio.bufferSize(); //1024
  FFT fft = new FFT(fftSize, audio.sampleRate());
  //println(fftSize);
  
  //Table table = new Table();
  //table.addColumn("frameId");
  //table.addColumn("timeStamp");
  //table.addColumn("amp");
  //table.addColumn("ampThreshold");
  //table.addColumn("acc");
  //table.addColumn("accThreshold");
  
  int totalSamples = audio.getChannel(AudioSample.LEFT).length;
  println("totalSamples: " + totalSamples);
  float[] samples = new float[totalSamples];
  for(int i = 0; i < totalSamples; i++) {
    samples[i] = audio.getChannel(AudioSample.LEFT)[i] + audio.getChannel(AudioSample.RIGHT)[i];
  }
  
  float timeUnit = 1000 * fftSize / audio.sampleRate(); // how long is a frame (in milliseconds)
  
  float bufferAmp = 0.0;
  
  int totalFrames = (totalSamples / fftSize) + 1;
  println("totalFrames: " + totalFrames);
  for(int frameId = 0; frameId < totalFrames; frameId++) {
    int timeStamp = floor(timeUnit * frameId);
    
    int startSampId = frameId * fftSize;
    
    float[] fftSamples = new float[fftSize];
    int frameSize = min(fftSize, totalSamples - startSampId);
    
    System.arraycopy(samples, startSampId, fftSamples, 0, frameSize);
    if(frameSize < fftSize) java.util.Arrays.fill(fftSamples, frameSize, fftSize, 0.0);
    
    fft.forward(fftSamples);
    
    float amp = 0.0;
    for(int i = 0; i < fft.specSize(); i++) {
      amp += fft.getBand(i);
    }
    
    if(amp > bufferAmp) {
      bufferAmp = amp;
      
      frameIds = append(frameIds, frameId);
      timeStamps = append(timeStamps, timeStamp);      
      amps = append(amps, bufferAmp);      
      int id = amps.length - 1;
      float acc;
      int gap;
      if(id > 0) {
        acc = amps[id] - amps[id - 1];
        gap = timeStamps[id] - timeStamps[id - 1];
      } else {
        acc = 0;
        gap = timeStamps[0];
      }
      accs = append(accs, acc);
      gaps = append(gaps, gap);
      //TableRow newRow = table.addRow();
      //newRow.setInt("frameId", frameId);
      //newRow.setInt("timeStamp", timeStamp);
      //newRow.setFloat("amp", bufferAmp);
    }
    else {
      bufferAmp -= (bufferAmp - amp) * decayRate;
    }
  }
  
  //wrap up
  Table table = new Table();
  table.addColumn("frameId");
  table.addColumn("timeStamp");
  table.addColumn("timeGap");
  table.addColumn("amp");
  table.addColumn("ampThreshold");
  //table.addColumn("ampMax");
  table.addColumn("acc");
  table.addColumn("accThreshold");
  //table.addColumn("accMax");
  
  float timeGapMax = max(gaps);
  float timeGapMin = min(gaps);
  float ampMax = max(amps);
  float ampMin = min(amps);
  float accMax = max(accs);
  float accMin = min(accs);
  
  for(int i = 0; i < frameIds.length; i++) {
    TableRow newRow = table.addRow();
    
    amps[i] = map(amps[i], ampMin, ampMax, 0.0, 1.0);
    accs[i] = map(accs[i], accMin, accMax, -1.0, 1.0);
    gaps[i] = map(gaps[i], timeGapMin, timeGapMax, 0.0, 1.0);
    
    newRow.setInt("frameId", frameIds[i]);
    newRow.setInt("timeStamp", timeStamps[i]);
    newRow.setFloat("timeGap", gaps[i]);
    newRow.setFloat("amp", amps[i]);
    newRow.setFloat("acc", accs[i]);
  }
  
  //println("amp min: " + min(amps) + " amp max: " + max(amps));
  //println("acc min: " + min(accs) + " acc max: " + max(accs));
  
  float[] sortAmp = sort(amps);
  sortAmp = reverse(sortAmp);
  float[] sortAcc = sort(accs);
  sortAcc = reverse(sortAcc);
  
  int ampi = floor(amps.length * ampProp);
  int acci = floor(accs.length * accProp);
  
  ampThreshold = amps[ampi];
  accThreshold = accs[acci];
  
  println("amp threshold: " + ampThreshold);
  println("acc threshold: " + accThreshold);
  
  TableRow row = table.getRow(0);
  row.setFloat("ampThreshold", ampThreshold);
  row.setFloat("accThreshold", accThreshold);
  //row.setFloat("ampMax", ampMax);
  //row.setFloat("accMax", accMax);
  
  println(table.getRowCount() + " time spots were captured.");
  println("length of amp array: " + amps.length);
  println("length of acc array: " + accs.length);
  println("finished");
  
  saveTable(table, "data/" + filename + "Beats.csv");
}