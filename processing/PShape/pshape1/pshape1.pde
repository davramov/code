Cubes w = new Cubes();

void setup() {
  fullScreen();
  background(120);
  w = new Cubes();
  
}

void draw() {
  w.step();
}