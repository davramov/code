Noise n;

void setup() {
  fullScreen();
  n = new Noise();
  background(255);
  noiseDetail(1,0.1);
}

void draw() {
  n.step();
  n.render();
  
}