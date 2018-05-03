class Cubes {
  int x, y, a, b, c, steps;
  PShape s;
  float weight, k;
  
  Cubes() {
    x = (int) random(width);
    y = (int) random(height);
    a = (int) random(100,255);
    b = (int) random(0,255);
    c = 75;
    weight = 50;
    k = 0;
  }
  
  void render() {
    stroke(a,b,c);
    strokeWeight(weight);
    point(x,y);
    s = createShape();
    s.beginShape();
    s.fill(0, 0, 255);
    s.noStroke();
    s.vertex(0, 0);
    s.vertex(0, 50);
    s.vertex(50, 50);
    s.vertex(50, 0);
    s.endShape(CLOSE);
  }
  void step() {
    shape(s);
  }
}