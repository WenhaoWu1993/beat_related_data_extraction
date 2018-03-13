String[] varname;

void createScript(Table csvTable) {
  varname = new String[] {
    "public static int[] frameId = new int[] { ", "public static int[] timeStamp = new int[] {", 
    "public static float[] timeGap = new float[] {", 
    "public static float[] amp = new float[] {", "public static float ampThreshold = ",
    "public static float[] acc = new float[] {", "public static float accThreshold = "
  };
  
  PrintWriter output;
  output = createWriter("MusicData.cs");
  
  output.println("using System.Collections;");
  output.println("using System.Collections.Generic;");
  output.println("using UnityEngine;" + '\n');
  output.println("public class MusicData : MonoBehaviour {");
  
  //println("frameId?:" + csvTable.getString(0, 0));
  int totalColumns = csvTable.getColumnCount();
  int totalRows = csvTable.getRowCount();
  
  for(int columnId = 0; columnId < totalColumns; columnId++) {
    String header = csvTable.getRow(0).getString(columnId);
    
    //println(header + header.length());
    
    //output.print('\t' + "");
    //println(csvTable.getString(2, 3).length());
    if(header.equals("ampThreshold") || header.equals("accThreshold")) {
      float val = csvTable.getRow(1).getFloat(columnId);
      output.println(varname[columnId] + val + "f;");
    }
    else {
      output.println(varname[columnId]);
      int count = 0;
      for(int rowId = 1; rowId < totalRows; rowId++) {
        int c = rowId / 10;
        if(c != count) { // every 10 values, press "enter"
          output.print('\n');
          count = c;
        }
        
        //float v = csvTable.getRow(rowId).getFloat(columnId);
        if(header.equals("timeStamp") || header.equals("frameId")) {
          int v = csvTable.getRow(rowId).getInt(columnId);
          if(rowId == totalRows - 1) output.print(v);
          else output.print(v + ", ");
        }
        else {
          float v = csvTable.getRow(rowId).getFloat(columnId);
          if(rowId == totalRows - 1) output.print(v + "f");
          else output.print(v + "f, ");
        }
        
      }
      output.print('\n' + "};" + '\n' + '\n');
    }
    
  }
  
  output.println("}");
  
  output.flush();
  output.close();
  
}