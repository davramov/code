class Walker {
  int x, y, a, b, c, steps;
  
  Walker() {
    x = width/2;
    y = height/2;
    a = (int) random(0,255);
    b = (int) random(0,255);
    c = 0;
  }
  
  void render() {
    stroke(a,b,c);
    strokeWeight(50);
    point(x,y);
    steps = 30;
  }
  void step() {
    float r = random(1);
    if (r < 1/8) {
      y = y + steps;
    }
    else if (r < 1/4) {
      y = y - steps;
    }
    else if (r < 3/8) {
      x = x - steps;
    }
    else if (r < 1/2) {
      
    }
    else if (r < 5/8) {
      
    }
    else if (r < 3/4) {
      
    }
    else if (r < 7/8) {
      
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
}