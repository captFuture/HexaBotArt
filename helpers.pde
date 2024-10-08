class ChildApplet extends PApplet {
  
    public ChildApplet() {
        super();
        PApplet.runSketch(new String[]{this.getClass().getName()} , this);
    }
    
    public void settings() {
        size(360, 900, P3D);
        smooth();
        
    }
    public void setup() { 
        surface.setTitle("Key table");
    }
    
    public void draw() {
        background(255);
        image(keyimg, 0, 0);
        
    }
    
}

class ChildApplet2 extends PApplet {

    public ChildApplet2() {
        super();
        PApplet.runSketch(new String[]{this.getClass().getName()} , this);
    }
    
    public void settings() {
        size(360, 360, P3D);
        smooth();
    }
    
    public void setup() { 
        surface.setTitle("Settings");
    }
    
    public void draw() {
        background(255);
        //image(keyimg, 0, 0);
    }
      
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// A class to check the upper and lower limits of a value
class Limit {
    float min = 2147483647;
    float max = -2147483648;
    
    Limit() { }
    
    void update_limit(float value_) {
        if (value_ < min) { min = value_; }
        if (value_ > max) { max = value_; }
}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void grid() {
    //This will give you a rough idea of the size of the printed image, in "grid_scale" units.
    //Some screen scales smaller than 1.0 will sometimes display every other line
    //It looks like a big logic bug, but it just can't display a one pixel line scaled down well.
    
    //blendMode(BLEND);
    if(is_grid_on) {
        int image_center_x = int(img.width / 2);
        int image_center_y = int(img.height / 2);
        int gridlines = 100;
        
        // Vertical lines
        strokeWeight(1);
        stroke(255, 64, 64, 80);
        noFill();
        for (int x = -gridlines; x <= gridlines; x++) {
            int x0= int(x * grid_scale / gcode_scale);
            line(x0 + image_center_x, -999999, x0 + image_center_x, 999999);
        }
        
        // Horizontal lines
        for (int y = -gridlines; y <= gridlines; y++) {
            int y0= int(y * grid_scale / gcode_scale);
            line( - 999999, y0 + image_center_y, 999999, y0 + image_center_y);
        }
        
        // Screen center line
        stroke(255, 64, 64, 80);
        strokeWeight(2);
        line(image_center_x, -999999, image_center_x, 999999);
        line( - 999999, image_center_y, 999999, image_center_y);
        strokeWeight(1);
        
        hint(DISABLE_DEPTH_TEST);      // Allow fills to be shown on top.
        
        // Mark the edge of the drawing/image area in blue
        stroke(64, 64, 255, 92);
        noFill();
        strokeWeight(1);
        rect(0, 0, img.width, img.height);
        
        // Green pen origin (home position) dot.
        stroke(0, 255, 0, 255);
        fill(0, 255, 0, 255);
        ellipse( - gcode_offset_x / gcode_scale, -gcode_offset_y / gcode_scale, 10, 10);
        
        // Red center of image dot
        stroke(255, 0, 0, 255);
        fill(255, 0, 0, 255);
        ellipse(image_center_x, image_center_y, 10, 10);
        
        // Blue dot at image 0,0
        stroke(0, 0, 255, 255);
        fill(0, 0, 255, 255);
        ellipse(0, 0, 10, 10);
        
        hint(ENABLE_DEPTH_TEST);
        strokeWeight(1);
}
}
