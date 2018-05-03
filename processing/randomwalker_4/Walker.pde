class Walker {
  int a, b, c, steps;
  float x, y,tx, ty;
  Walker() {
    x = random(width);
    y = random(height);
    tx = random(1000);
    ty = random(10000);
    a = (int) random(0,255);
    b = (int) random(0,255);
    c = 0;
  }
  
  void render() {
    stroke(a,b,c);
    strokeWeight(50);
    point(x,y);
    steps = 15;
  }
  void step() {
    x = map(noise(tx), 0, 1, 0, width);
    y = map(noise(ty), 0, 1, 0, height);
    tx += 0.01;
    ty += 0.01;
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
}