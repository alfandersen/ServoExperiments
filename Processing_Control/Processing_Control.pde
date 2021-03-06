import processing.serial.*;

//********************** Objects and Variales ****************

Serial myPort;  // Create object from Serial class
static final int servos = 9;
int val[] = new int[servos];
color c[] = new color[servos];
int editColumn = -1;
int prevColumn = 0;
int prevVal = 0;

//********************** Setup *******************************

void setup() 
{
  /*val[0] = 50;
  val[1] = 0;
  val[2] = 142;
  val[3] = 80;*/

  rectMode(CORNERS); 
  size(1000, 720);
  noLoop(); 

  for (int i = 0; i < servos; i++) {
    c[i] = rndClr();
  }
  //*
  String portName = Serial.list()[0];
   myPort = new Serial(this, portName, 9600);
   printArray(Serial.list());
   //*/
}

//********************** Draw ********************************

void draw() {

  if (mousePressed) {
    UpdateVal(); //hold 'c' for continous editing and 'a' for editing all motors
    String values = "x" + join(nfc(val), ",");
    //println(values);
    myPort.write(values);
  }

  // Draw interface
  background(230);
  stroke(100);
  for (int i = 0; i < servos; i++) {
    fill(c[i]);
    line(width/float(servos)*i, 0, width/float(servos)*i, height);
    rect(i*(width/float(servos)), height-(val[i]*4), (i+1)*(width/float(servos)), height);
  }
}

//********************** 1st frame after mouse pressed *******

void mousePressed() {
  editColumn = mouseOnColumn(true);
  if (editColumn != -1) {
    prevColumn = editColumn;
    prevVal = (height - mouseY) / 4;
  }
  loop();
}

//********************** 1st frame after mouse released ******

void mouseReleased() {
  editColumn = -1;
  noLoop();
}

//********************** find which column mouse is on *******

int mouseOnColumn(boolean includeOutsideBounds) {
  for (int i = 1; i <= servos; i++) {
    if (mouseX < i * width/float(servos) && mouseX >= 0) {
      return i-1;
    }
  }
  if (includeOutsideBounds) {
    if (mouseX < 0) return 0;
    else if (mouseX > width) return servos-1;
  }
  return -1;
}

//********************** update val[] array ******************

void UpdateVal() {
  if (keyPressed) {
    // continous update column
    if (key == 'c') {
      
      int currColumn = mouseOnColumn(false);
      if (currColumn != -1) {
        int currVal = (height - mouseY) / 4;

        if (currColumn > prevColumn) {
          int columnSpan = currColumn - prevColumn;
          for (int i = 0; i <= columnSpan; i++) {
            val[i+prevColumn] = int((i/float(columnSpan))*currVal + (1-i/float(columnSpan))*prevVal);
          }
        } 
        
        else if (currColumn < prevColumn) {
          int columnSpan = prevColumn - currColumn;
          for (int i = columnSpan; i >= 0; i--) {
            val[i+currColumn] = int((i/float(columnSpan)) * prevVal + (1-i/float(columnSpan))*currVal);
          }
        } 
        
        else {
          val[currColumn] = (height - mouseY) / 4;
        }

        prevVal = currVal;
        editColumn = currColumn;
        prevColumn = currColumn;
      }
    }

    // edit all columns
    else if (key == 'a') {
      for (int i = 0; i < servos; i++) {
        val[i] = (height - mouseY) / 4;
      }
      editColumn = mouseOnColumn(true);
    }
  }

  // edit one column
  else {
    for (int i = 0; i < servos; i++) {
      if (editColumn == i) val[i] = (height - mouseY) / 4;
    }
  }

  for (int i = 0; i < servos; i++) {
    val[i] = clipValue(val[i], 0, 180);
  }
}

//********************** clip int values *********************

int clipValue(int value, int min, int max) {
  if (value < min) return min;
  else if (value > max) return max;
  return value;
}

//********************** get a random color ******************

color rndClr() {
  return color(random(255), random(255), random(255));
}