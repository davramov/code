Walker[] w = new Walker[1];
Walker[] q = new Walker[1];

void setup() {
  fullScreen();
  // Create a walker object
  for (int i = 0; i < w.length; i++) {
    w[i] = new Walker();
    q[i] = new Walker();
  }
  
  background(120);
}

void draw() {
  // Run the walker object
  for (int i = 0; i < w.length; i++) {
    w[i].step();  
    w[i].shade();
    w[i].render();
    w[i].Dot();
    q[i].step();  
    q[i].shade();
    q[i].render();
    q[i].Dot();
    
  }
}