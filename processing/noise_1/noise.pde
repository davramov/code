class Noise {
  float x, y, xoff, yoff, s;
  Noise(){
    xoff = 0.0;
    yoff = 0.0;
  }
  void render() {
    loadPixels();
     // Start xoff at 0.
    //float xoff = 0.0; //[bold]
    
    for (int x = 0; x < width; x++) {
      // For every xoff, start yoff at 0.
      float yoff = 0.0; //[bold]
    
      for (int y = 0; y < height; y++) {
        // Use xoff and yoff for noise().
        float a = random(255);
        float bright = map(noise(xoff,yoff,a),0,1,0,255);
        // Use x and y for pixel location.
        pixels[x+y*width] = color(bright);
        // Increment yoff.
        yoff += y; //[bold]
      }
      // Increment xoff.
      xoff += x;  //[bold]
    }
    updatePixels();
  }
  void step() {
    x = random(-1,1);
    y = random(-1,1);
    
  }

}