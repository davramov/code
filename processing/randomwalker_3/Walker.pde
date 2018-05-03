class Walker {
  int x, y, a, b, c, steps;
  float weight, k;
  
  Walker() {
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
    //steps = (int) random(75,100);
    steps = 40;
  }
  void step() {
    float r = random(1);
    if (r < 0.125) {
      y = y + steps;
    }
    else if (r < 0.25) {
      y = y - steps;
    }
    else if (r < 0.375) {
      x = x - steps;
    }
    else if (r < 0.5) {
      x += steps;
      y += steps;
    }
    else if (r < 0.625) {
      x -= steps;
      y += steps;
    }
    else if (r < 0.75) {
      x -= steps;
      y -= steps;
    }
    else if (r < 0.875) {
      x += steps;
      y -= steps;
    }
    else {
      x = x + steps;
    }
    x = constrain(x,0,width-1);
    y = constrain(y,0,height-1);
  }
  void shade() {
    float r1 = random(1);
    float r2 = random(1);
    float r3 = random(1);
    int ra = (int) random(-5,5);
    int rb = (int) random(-5,5);
    int rc = (int) random(-5,5);
    if (r1 < 0.05){
      a+=ra;
    }
    else if (r1 < 1){
      a-=ra;
    }
    if (r2 < 0.05){
      b+=rb;
    }
    else if (r2 < 1){
      b-=rb;
    }
    if (r3 < 0.05){
      c+=rc;
    }
    else if (r3 < 1){
      c-=rc;
    }
    a = constrain(a,0,255);
    b = constrain(b,0,255);
    c = constrain(c,0,255);
    
  }
  void Dot(){
    strokeWeight(weight);
    weight = 3*cos(k)+50;
    k = k+0.1;
  }
}