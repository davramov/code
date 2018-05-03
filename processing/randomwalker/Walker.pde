class Walker {
  int x, y, a, b, c, steps;
  
  Walker() {
    x = width/2;
    y = height/2;
    a = 0;
    b = 0;
    c = 0;
  }
  
  void render() {
    stroke(a,b,c);
    strokeWeight(15);
    point(x,y);
    steps = 5;
  }
  void step() {
    float r = random(1);
    if (r < 0.25) {
      y = y + steps;
    }
    else if (r < 0.5) {
      y = y - steps;
    }
    else if (r < 0.75) {
      x = x - steps;
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