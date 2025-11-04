class ChildApplet extends PApplet { // Key table window
  float margin = 10;
  float columnSpacing = 100;
  float rowHeight = 20;
  float headerHeight = 10;
  
  // Add bindings array as class variable
  String[][] bindings = {
    {"p", "Load next 'Path Finding Module' (PFM)"},
    {";", "Use previous pen set"},
    {":", "Use next pen set"},
    {",", "Decrease the total number of lines drawn"},
    {".", "Increase the total number of lines drawn"},
    {"g", "Generate all SVGs with lines as displayed"},
    {"G", "Toggle grid"},
    {"-----------------", "---------------------------------------------------"},
    {"r", "Rotate drawing"},
    {"O", "Display original image (capital letter)"},
    {"o", "Display image to be drawn after pre-processing (lower case letter)"},
    {"l", "Display image after the path finding module has manipulated it"},
    {"d", "Display drawing with all pens"},
    {"<ctrl> 1", "Display drawing, pen 0 only"},
    {"<ctrl> 2", "Display drawing, pen 1 only"},
    {"<ctrl> 3", "Display drawing, pen 2 only"},
    {"<ctrl> 4", "Display drawing, pen 3 only"},
    {"<ctrl> 5", "Display drawing, pen 4 only"},
    {"<ctrl> 6", "Display drawing, pen 5 only"},
    {"S", "Stop path finding prematurely"},
    {"Esc", "Exit running program"},
    {"t", "Redistribute percentage of lines drawn by each pen evenly"},
    {"y", "Redistribute 100% of lines drawn to pen 0"},
    {"9", "Change distribution of lines drawn (lighten)"},
    {"0", "Change distribution of lines drawn (darken)"},
    {"1", "Increase percentage of lines drawn by pen 0"},
    {"2", "Increase percentage of lines drawn by pen 1"},
    {"3", "Increase percentage of lines drawn by pen 2"},
    {"4", "Increase percentage of lines drawn by pen 3"},
    {"5", "Increase percentage of lines drawn by pen 4"},
    {"6", "Increase percentage of lines drawn by pen 5"},
    {"shift 0", "Decrease percentage of lines drawn by pen 0"},
    {"shift 1", "Decrease percentage of lines drawn by pen 1"},
    {"shift 2", "Decrease percentage of lines drawn by pen 2"},
    {"shift 3", "Decrease percentage of lines drawn by pen 3"},
    {"shift 4", "Decrease percentage of lines drawn by pen 4"},
    {"shift 5", "Decrease percentage of lines drawn by pen 5"}
  };


  public ChildApplet() {
    super();
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  void settings() {
    size(500, 800, P2D);
    
  }

  void setup() {
    surface.setTitle("Key Controls");
    surface.setResizable(true);
    background(240);
    createKeyBindingsTable();
  }

  void draw() {
    background(240);
    createKeyBindingsTable();
  }

  void createKeyBindingsTable() {
    fill(0);
    textAlign(LEFT);
    textSize(12);
    fill(100);
    float visibleRows = (height - headerHeight) / rowHeight;
    
    for (int i = 0; i < bindings.length; i++) {
      float y = headerHeight + 30 + (i * rowHeight);
      
      // Only draw rows that are visible in the window
      if (y < height) {
        // alternating row background: even = white, odd = light grey
        noStroke();
        if (i % 2 == 0) {
          fill(255);          // white
        } else {
          fill(230);          // light grey
        }
        // draw full-width stripe behind the row (adjust vertical position to cover text)
        float rectY = y - rowHeight + 6;
        rect(0, rectY, width, rowHeight);

        // draw the text on top
        fill(0);
        text(bindings[i][0], margin, y);
        
        // Wrap text for long descriptions
        float wrapWidth = width - (margin + columnSpacing + margin);
        text(bindings[i][1], margin + columnSpacing, y);
      }
    }
  }

}

class ChildApplet2 extends PApplet { // Settings window

  public ChildApplet2() {
    super();
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
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

  Limit() {
  }

  void update_limit(float value_) {
    if (value_ < min) {
      min = value_;
    }
    if (value_ > max) {
      max = value_;
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void grid() {
  //This will give you a rough idea of the size of the printed image, in "grid_scale" units.
  //Some screen scales smaller than 1.0 will sometimes display every other line
  //It looks like a big logic bug, but it just can't display a one pixel line scaled down well.

  //blendMode(BLEND);
  if (is_grid_on) {
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
