Walker[] w = new Walker[20];

void setup() {
  fullScreen();
  // Create a walker object
  for (int i = 0; i < w.length; i++) {
    w[i] = new Walker();
  }
  background(255);
}

void draw() {
  // Run the walker object
  for (int i = 0; i < w.length; i++) {
    w[i].step();  
    w[i].shade();
    w[i].render();
  }
}