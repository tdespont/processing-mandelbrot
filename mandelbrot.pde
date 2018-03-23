int w = 800;
int h = 800;
PGraphics board;
int maxIteration;
float x0;
float x1;
float y0;
float y1;
float new_x0 = 0;
float new_x1 = 0;
float new_y0 = 0;
float new_y1 = 0;
boolean calculationNeeded;
boolean updateSelection;

private ArrayList<Color> gradient = new ArrayList();
private int gradientSize = 20;


private class Color {
  int r;
  int g;
  int b;

  Color(int r, int g, int b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
}

private void initGradient(Color... colors) {
  int size = colors.length;
  int chunk = (int)Math.ceil(this.gradientSize/(size-1));
  for (int i = 0; i < size-1; i++) {
    Color diffColor = this.createDiffColor(colors[i], colors[i+1]);
    this.writeGradient(diffColor, colors[i], i*chunk, (i+1)*chunk);
  }
}

private Color createDiffColor(Color startColor, Color endColor) {
  return new Color(endColor.r - startColor.r, endColor.g - startColor.g, 
    endColor.b - startColor.b);
}

private void writeGradient(Color diffColor, Color startColor, int start, int size) {
  for (int i=start; i<=size; i++) {
    double percent = ((double)i) / ((double)size);
    Color c = new Color((int)(diffColor.r * percent) + startColor.r, 
      (int)(diffColor.g * percent) + startColor.g, 
      (int)(diffColor.b * percent) + startColor.b);
    this.gradient.add(i, c);
  }
}

void setup() {
  pixelDensity(displayDensity());
  size(800, 800);
  //fullScreen();
  board = createGraphics(w, h);
  background(0);
  this.initGradient(new Color(255, 0, 0), new Color(0, 255, 0), new Color(0, 0, 255));
  maxIteration = 400;
  calculationNeeded = true;
  this.x0 = -2.8;
  this.x1 = 1.2;
  this.y0 = (this.x0 - this.x1) * h / (2 * w); //-1.2;
  this.y1 = -this.y0; //1.2;
  noLoop();
  redraw();
}

void keyPressed() {
  if (keyCode == UP) {
    maxIteration = maxIteration + 40;
    calculationNeeded = true;
    redraw();
  } else if (keyCode == DOWN) {
    maxIteration = maxIteration - 40;
    calculationNeeded = true;
    redraw();
  }
}

void mousePressed() {
  new_x0 = mouseX;
  new_y0 = mouseY;
  updateSelection = true;
}

void mouseReleased() {
  new_x1 = mouseX;
  new_y1 = mouseY;
  float tempX0 = map(new_x0, 0, width, x0, x1);
  float tempX1 = map(new_x1, 0, width, x0, x1);
  float tempY0 = map(new_y0, 0, height, y0, y1);
  float tempY1 = map(new_y1, 0, height, y0, y1);
  x0 = tempX0;
  x1 = tempX1;
  y0 = tempY0;
  y1 = tempY1;
  calculationNeeded = true;
  updateSelection = false;
  redraw();
}

void mouseDragged() {
  new_x1 = mouseX;
  new_y1 = new_y0 + (new_x1 - new_x0);
  updateSelection = true;
  redraw();
}

void computeMandelbrot() {
  board.beginDraw();
  board.background(0);
  for (int x = 0; x < w; x++) {
    float a0 = map(x, 0, w, x0, x1);
    for (int y = 0; y < h; y++) {
      float b0 = map(y, 0, h, y0, y1);
      float a = 0.0;
      float b = 0.0;
      int iteration = 0;
      while (((a*a + b*b) < 4) && (iteration < maxIteration)) {
        float atemp = a*a - b*b + a0;
        float btemp = 2*a*b + b0;
        if (a == atemp && b == btemp) {
          iteration = maxIteration;
          break;
        }
        a = atemp;
        b = btemp;
        iteration = iteration + 1;
      }
      //board.stroke(map(iteration, 0, maxIteration, 255, 0));
      if (iteration < maxIteration) {
        int ratio = iteration % this.gradientSize;
        board.stroke(this.gradient.get(ratio).r, 
          this.gradient.get(ratio).g, 
          this.gradient.get(ratio).b);
      } else {
        board.stroke(0);
      }
      board.point(x, y);
    }
  }
  board.endDraw();
  calculationNeeded = false;
}

void drawMandelbrot() {
  image(board, 0, 0);
}

void draw() {
  if (calculationNeeded) {
    computeMandelbrot();
    drawMandelbrot();
  }
  if (updateSelection) {
    drawMandelbrot();
    noFill();
    stroke(255, 0, 0);
    rect(new_x0, new_y0, new_x1 - new_x0, new_y1 - new_y0);
  }
}