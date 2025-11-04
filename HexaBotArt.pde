///////////////////////////////////////////////////////////////////////////////////////////////////////
// Fork Based on Drawbot, "Death to Sharpie" from https://github.com/Scott-Cooper/Drawbot_image_to_gcode_v2
// and https://github.com/jwcliff/Drawbot_image_to_gcode_v2
//
// Chris Tarantl <profsimon@gmail.com>
//
// Open creative GPL source commons with some BSD public GNU foundation stuff sprinkled in...
//
///////////////////////////////////////////////////////////////////////////////////////////////////////
import java.util.Map;

ChildApplet child;
PImage keyimg;
QImage qimg;
PFont f;
PGraphics pg;

// Configuration is now stored in `config.pde` in the sketch folder.
// Edit `config.pde` to change paper size, scales, pen counts and related settings.

Class cl = null;
pfm genpath;
int current_pfm = 0;
String[] pfms = {"PFM_original", "PFM_spiral", "PFM_squares","PFM_lines"}; 

int     state = 1;
int     pen_selected = 0;

int     display_line_count;
String  display_mode = "drawing";
PImage  img_orginal;               // The original image
PImage  img_reference;             // After pre_processing, croped, scaled, border, etc.  This is what we will try to draw. 
PImage  img;                       // Used during drawing for current brightness levels.  Gets damaged during drawing.
PImage  img_reducecolor;
PImage  small_img_reference;
float   gcode_offset_x;
float   gcode_offset_y;
float   gcode_scale;
float   screen_scale;
float   screen_scale_org;
int     screen_rotate = 0;
float   old_x = 0;
float   old_y = 0;
int     mx = 0;
int     my = 0;
int     morgx = 0;
int     morgy = 0;
int     pen_color = 0;
boolean is_pen_down;
boolean is_grid_on = false;
String  path_selected = "";
String  file_selected = "";
String  basefile_selected = "";
String  code_comments = "";
int     startTime = 0;
boolean ctrl_down = false;

Limit   dx, dy;
Copix   copic;
PrintWriter OUTPUT;
botDrawing d1;

float[] pen_distribution;

// use Copic.pde to get colors of pens and generate your own color scheme
String[][] copic_sets = {
  {"100", "N10", "N8", "N6", "N4", "N2"},       // 0 Dark Greys
  {"100", "100", "N7", "N5", "N3", "N2"},       // 1 Light Greys
  {"100", "W10", "W8", "W6", "W4", "W2"},       // 2 Warm Greys
  {"100", "C10", "C8", "C6", "C4", "C2"},       // 3 Cool Greys
  {"100", "100", "C7", "W5", "C3", "W2"},       // 4 Mixed Greys
  {"100", "100", "W7", "C5", "W3", "C2"},       // 5 Mixed Greys
  {"100", "100", "E49", "E27", "E13", "E00"},   // 6 Browns
  {"100", "100", "E49", "E27", "E13", "N2"},    // 7 Dark Grey Browns
  {"100", "100", "E49", "E27", "N4", "N2"},     // 8 Browns
  {"100", "100", "E49", "N6", "N4", "N2"},      // 9 Dark Grey Browns
  {"100", "100", "B37", "N6", "N4", "N2"},      // 10 Dark Grey Blues
  {"100", "100", "R59", "N6", "N4", "N2"},      // 11 Dark Grey Red
  {"100", "100", "G29", "N6", "N4", "N2"},      // 12 Dark Grey Violet
  {"100", "100", "YR09", "N6", "N4", "N2"},     // 13 Dark Grey Orange
  {"100", "100", "B39", "G28", "B26", "G14"},   // 14 Blue Green
  {"100", "100", "B39", "V09", "B02", "V04"},   // 15 Purples
  {"100", "100", "R29", "R27", "R24", "R20"},   // 16 Reds
  {"100", "E29", "YG99", "Y17", "YG03", "Y11"}, // 17 Yellow, green
  {"E18", "E15", "E13", "E11", "R20", "E00"},   // 18 Skin Tones
  {"100", "N3", "G21", "BG72", "B93", "N1"},    // 19 Sea
  {"R37", "YR04", "Y15", "G07", "B29", "BV08"}, // 20 Primary
  {"YG99", "Y17", "YG03", "Y11", "N3", "N2"},    // 21 Nature
  {"100", "B39", "V09", "B02", "V04", "V04" },   // 22 Light Purples
  {"100", "B39", "B26", "B14", "BG07", "BG15"},  // 23 Turquoise
  {"V09", "B29", "G17", "Y13", "YR04", "R08"}   // 24 LGTBQ
};

String outfilename = "";
boolean shouldSaveScreenshot = false;


void settings(){
  size(canvas_size_x, canvas_size_y, P3D);
  pixelDensity(1);
  smooth();
}


///////////////////////////////////////////////////////////////////////////////////////////////////////
void setup() {
  surface.setTitle("Drawbot - SVG creator");
  //surface.setResizable(true);
  //surface.setLocation(100, 100);
  f = createFont("arial.ttf", 12);
  textFont(f);

  colorMode(RGB);
  frameRate(999);
  child = new ChildApplet();
  randomSeed(3);
  d1 = new botDrawing();
  dx = new Limit(); 
  dy = new Limit(); 
  copic = new Copix();
  // allocate pen distribution using configured pen_count
  pen_distribution = new float[pen_count];
  loadInClass(pfms[current_pfm]);
  selectInput("Select an image to process:", "fileSelected");


}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void draw() {
  if (shouldSaveScreenshot) {
    saveFrame(outfilename);
    println("Screenshot saved to: " + outfilename);
    shouldSaveScreenshot = false;
    return;
  }

  if (state != 3) { background(255, 255, 255); }
  scale(screen_scale);
  translate(mx, my);
  rotate(HALF_PI*screen_rotate);
  
  switch(state) {
  case 1: 
    println("State=1, Waiting for filename selection");
    break;
  case 2:
    println("State=2, Setup squiggles");
    loop();
    setup_squiggles();
    reduce_palette();
    startTime = millis();
    break;
  case 3: 
    //println("State=3, Drawing image");
    if (display_line_count <= 1) {
      background(255);
    } 
    genpath.find_path();
    display_line_count = d1.line_count;
    break;
  case 4: 
    println("State=4, pfm.post_processing");
    genpath.post_processing();

    set_even_distribution();
    normalize_distribution();
    d1.evenly_distribute_pen_changes(d1.get_line_count(), pen_count);
    d1.distribute_pen_changes_according_to_percentages(display_line_count, pen_count);

    println("elapsed time: " + (millis() - startTime) / 1000.0 + " seconds");
    display_line_count = d1.line_count;
  
    code_comment ("extreams of X: " + dx.min + " thru " + dx.max);
    code_comment ("extreams of Y: " + dy.min + " thru " + dy.max);
    state++;
    break;
  case 5: 
    render_all();
    draw_reduced();
    noLoop();
    break;
  default:
    println("invalid state: " + state);
    break;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void fileSelected(File selection) {
  if (selection == null) {
    println("no image file selected, exiting program.");
    exit();
  } else {
    path_selected = selection.getAbsolutePath();
    file_selected = selection.getName();
    String[] fileparts = split(file_selected, '.');
    basefile_selected = fileparts[0];
    println("user selected: " + path_selected);
    //println("user selected: " + file_selected);
    //println("user selected: " + basefile_selected);
    state++;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void setup_squiggles() {
  float   gcode_scale_x;
  float   gcode_scale_y;
  float   screen_scale_x;
  float   screen_scale_y;

  d1.line_count = 0;
  img = loadImage(path_selected, "jpeg");  // Load the image into the program  

  code_comment("loaded image: " + path_selected);

  image_rotate();

  img_orginal = createImage(img.width, img.height, RGB);
  img_orginal.copy(img, 0, 0, img.width, img.height, 0, 0, img.width, img.height);

  img_reducecolor = createImage(img.width/refscale, img.height/refscale, RGB);
  img_reducecolor.copy(img, 0, 0, img.width, img.height, 0, 0, img.width/refscale, img.height/refscale);

  genpath.pre_processing();
  img.loadPixels();
  
  img_reference = createImage(img.width, img.height, RGB);
  img_reference.copy(img, 0, 0, img.width, img.height, 0, 0, img.width, img.height);
  
  small_img_reference = createImage(img.width/refscale, img.height/refscale, RGB);
  small_img_reference.copy(img, 0, 0, img.width, img.height, 0, 0, img.width/refscale, img.height/refscale);
  
  gcode_scale_x = image_size_x / img.width;
  gcode_scale_y = image_size_y / img.height;
  gcode_scale = min(gcode_scale_x, gcode_scale_y);
  gcode_offset_x = - (paper_size_x / 2.0);  
  gcode_offset_y = - (paper_size_y / 2.0);

  screen_scale_x = width / (float)img.width;
  screen_scale_y = height / (float)img.height;
  screen_scale = min(screen_scale_x, screen_scale_y);
  screen_scale_org = screen_scale;
  
  code_comment("final dimensions: " + img.width + " by " + img.height);
  code_comment("paper_size: " + nf(paper_size_x,0,2) + " by " + nf(paper_size_y,0,2));
  code_comment("drawing size max: " + nf(image_size_x,0,2) + " by " + nf(image_size_y,0,2));
  code_comment("drawing size calculated " + nf(img.width * gcode_scale,0,2) + " by " + nf(img.height * gcode_scale,0,2));
  genpath.output_parameters();

  state++;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void render_all() {
  println("render_all: " + display_mode + ", " + display_line_count + " lines, with pen set " + current_copic_set);
  
  if (display_mode == "drawing") {
    d1.render_some(display_line_count);
  }

  if (display_mode == "pen") {
    d1.render_one_pen(display_line_count, pen_selected);
  }
  
  if (display_mode == "original") {
    image(img_orginal, 0, 0, image_size_x, image_size_y);
  }

  if (display_mode == "reference") {
    image(img_reference, 0, 0, image_size_x, image_size_y);
  }
  
  if (display_mode == "lightened") {
    image(img, 0, 0, image_size_x, image_size_y);
  }
  grid();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void keyReleased() {
  if (keyCode == CONTROL) { ctrl_down = false; }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void keyPressed() {
  if (keyCode == CONTROL) { ctrl_down = true; }

  if (key == 'p') {
    current_pfm ++;
    if (current_pfm >= pfms.length) { current_pfm = 0; }
    //display_line_count = 0;
    loadInClass(pfms[current_pfm]); 
    state = 2;
  }
  
  if (key == 'd') { display_mode = "drawing";   }
  if (key == 'O') { display_mode = "original";  }
  if (key == 'o') { display_mode = "reference";  }
  if (key == 'l') { display_mode = "lightened"; }
  if (keyCode == 49 && ctrl_down && pen_count > 0) { display_mode = "pen";  pen_selected = 0; }  // ctrl 1
  if (keyCode == 50 && ctrl_down && pen_count > 1) { display_mode = "pen";  pen_selected = 1; }  // ctrl 2
  if (keyCode == 51 && ctrl_down && pen_count > 2) { display_mode = "pen";  pen_selected = 2; }  // ctrl 3
  if (keyCode == 52 && ctrl_down && pen_count > 3) { display_mode = "pen";  pen_selected = 3; }  // ctrl 4
  if (keyCode == 53 && ctrl_down && pen_count > 4) { display_mode = "pen";  pen_selected = 4; }  // ctrl 5
  if (keyCode == 54 && ctrl_down && pen_count > 5) { display_mode = "pen";  pen_selected = 5; }  // ctrl 6
  if (keyCode == 55 && ctrl_down && pen_count > 6) { display_mode = "pen";  pen_selected = 6; }  // ctrl 7
  if (keyCode == 56 && ctrl_down && pen_count > 7) { display_mode = "pen";  pen_selected = 7; }  // ctrl 8
  if (keyCode == 57 && ctrl_down && pen_count > 8) { display_mode = "pen";  pen_selected = 8; }  // ctrl 9
  if (keyCode == 48 && ctrl_down && pen_count > 9) { display_mode = "pen";  pen_selected = 9; }  // ctrl 0
  if (key == 'G') { is_grid_on = ! is_grid_on; }

  if (key == '1' && pen_count > 0) { pen_distribution[0] *= 1.1; }
  if (key == '2' && pen_count > 1) { pen_distribution[1] *= 1.1; }
  if (key == '3' && pen_count > 2) { pen_distribution[2] *= 1.1; }
  if (key == '4' && pen_count > 3) { pen_distribution[3] *= 1.1; }
  if (key == '5' && pen_count > 4) { pen_distribution[4] *= 1.1; }
  if (key == '6' && pen_count > 5) { pen_distribution[5] *= 1.1; }

  if (key == 't') { set_even_distribution(); }
  if (key == 'y') { set_black_distribution(); }
  //if (key == 'x') { mouse_point(); }  
  if (key == ':' && current_copic_set < copic_sets.length -1) { current_copic_set++; }
  if (key == ';' && current_copic_set >= 1)                   { current_copic_set--; }
  
  if (key == 's') { 
    outfilename = "renderings\\" + pfms[current_pfm] + "_" + current_copic_set + "_" + basefile_selected + ".png";
    shouldSaveScreenshot = true;
    redraw(); // Request a single redraw instead of restarting the loop
  }

  if (key == '9') {
    if (pen_count > 0) { pen_distribution[0] *= 1.00; }
    if (pen_count > 1) { pen_distribution[1] *= 1.05; }
    if (pen_count > 2) { pen_distribution[2] *= 1.10; }
    if (pen_count > 3) { pen_distribution[3] *= 1.15; }
    if (pen_count > 4) { pen_distribution[4] *= 1.20; }
    if (pen_count > 5) { pen_distribution[5] *= 1.25; }
  }
  if (key == '0') {
    if (pen_count > 0) { pen_distribution[0] *= 1.00; }
    if (pen_count > 1) { pen_distribution[1] *= 0.95; }
    if (pen_count > 2) { pen_distribution[2] *= 0.90; }
    if (pen_count > 3) { pen_distribution[3] *= 0.85; }
    if (pen_count > 4) { pen_distribution[4] *= 0.80; }
    if (pen_count > 5) { pen_distribution[5] *= 0.75; }
}
  if (key == 'g') { 
    create_svg_file(display_line_count);
    create_svg_files(display_line_count);
    if(makelangelo == true){
        create_gcode_file(display_line_count);
        create_gcode_files(display_line_count);
    }
  }

  if (key == ',') {
    int delta = -10000;
    display_line_count = int(display_line_count + delta);
    display_line_count = constrain(display_line_count, 0, d1.line_count);
    //println("display_line_count: " + display_line_count);
  }
  if (key == '.') {
    int delta = 10000;
    display_line_count = int(display_line_count + delta);
    display_line_count = constrain(display_line_count, 0, d1.line_count);
    //println("display_line_count: " + display_line_count);
  }

  if (key == 'r') { 
    screen_rotate ++;
    if (screen_rotate == 4) { screen_rotate = 0; }
    
    switch(screen_rotate) {
      case 0: 
        my -= img.height;
        break;
      case 1: 
        mx += img.height;
        break;
      case 2: 
        my += img.height;
        break;
      case 3: 
        mx -= img.height;
        break;
     }
  }
  
  normalize_distribution();
  d1.distribute_pen_changes_according_to_percentages(display_line_count, pen_count);
  //surface.setSize(img.width, img.height);
  redraw();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void set_even_distribution() {
  println("set_even_distribution");
  for (int p = 0; p<pen_count; p++) {
    pen_distribution[p] = display_line_count / pen_count;
    //println("pen_distribution[" + p + "] = " + pen_distribution[p]);
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void set_black_distribution() {
  println("set_black_distribution");
  for (int p=0; p<pen_count; p++) {
    pen_distribution[p] = 0;
    //println("pen_distribution[" + p + "] = " + pen_distribution[p]);
  }
  pen_distribution[0] = display_line_count;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void normalize_distribution() {
  float total = 0;

  println();
  //println("normalize_distribution");

  for (int p=0; p<pen_count; p++) {
    total = total + pen_distribution[p];
  }
  
  for (int p = 0; p<pen_count; p++) {
    pen_distribution[p] = display_line_count * pen_distribution[p] / total;
    print("Pen " + p + ", ");
    System.out.printf("%-4s", copic_sets[current_copic_set][p]);
    System.out.printf("%8.0f  ", pen_distribution[p]);
    
    // Display approximately one star for every percent of total
    for (int s = 0; s<int(pen_distribution[p]/total*100); s++) {
      print("*");
    }
    println();
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
public void loadInClass(String pfm_name){
  String className = this.getClass().getName() + "$" + pfm_name;
  try {
    cl = Class.forName(className);
  } catch (ClassNotFoundException e) { 
    println("\nError unknown PFM: " + className); 
  }
  
  genpath = null;
  if (cl != null) {
    try {
      // Get the constructor(s)
      java.lang.reflect.Constructor[] ctors = cl.getDeclaredConstructors();
      // Create an instance with the parent object as parameter (needed for inner classes)
      genpath = (pfm) ctors[0].newInstance(new Object[] { this });
    } catch (InstantiationException e) {
      println("Cannot create an instance of " + className);
    } catch (IllegalAccessException e) {
      println("Cannot access " + className + ": " + e.getMessage());
    } catch (Exception e) {
       // Lot of stuff can go wrong...
       e.printStackTrace();
    }
  }
  println("\nloaded PFM: " + className); 
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// This is the pfm interface, it contains the only methods the main code can call.
// As well as any variables that all pfm modules must have.
interface pfm {
  //public int x=0;
  public void pre_processing();
  public void find_path();
  public void post_processing();
  public void output_parameters();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

void reduce_palette(){
  qimg = new QImage(img_reducecolor, 16);
}


void draw_reduced(){
  println("Drawing image");
  if(img.width > img.height){
    println("Image rotated");
  }
  
  int[] col = qimg.getColorTable();
}

/**
 This class is used to store the result of the image quantization.
 The final image comprises a color table and a 2D array containing 
 an index into the color table.
 It also creates a new PImage with the reduced color set for 
 convenience.
 */
public class QImage {
  final int[][] pixels;
  final int w, h;
  final int[] colortable;
  final PImage reducedImage;

  /**
   img = the PImage we want to quantize
   maxNbrColors - color table size
   */
  public QImage(PImage img, int maxNbrColors) {
    // Pixel data needs to be in 2D array for Quantize class.
    w = img.width;
    h = img.height;
    pixels = new int[h][w];
    img.loadPixels();
    int[] p = img.pixels;
    int n = 0;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        pixels[y][x] = p[n++];
      }
    } 
    // Quantize the image
    colortable = Quantize.quantizeImage(pixels, maxNbrColors);
    //Create a PImage with the reduced color pallette
    reducedImage = createImage(w, h, ARGB);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        reducedImage.set(x, y, colortable[pixels[y][x]]);
      }
    }
  }

  /**
   Convenience method to draw the quatized image at a 
   given position.
   */
  public void displayRAW(int px, int py) {
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        set(px + x, py+y, colortable[pixels[y][x]]);
      }
    }
  }

  /**
   Get the pixel color index data
   */
  public int[][] getPixels() {
    return pixels;
  }

  /**
   Get the color table data
   */
  public int[] getColorTable() {
    return colortable;
  }

  /**
   Get the maximum number of colors in the reduced image.
   The actual number of unique colors maybe less than this.
   */
  public int nbrColors() {
    return colortable.length;
  }

  /**
   Convenience method to get the quatized image as a PImage
   that can be used directly in processing
   */
  public PImage getImage() {
    return reducedImage;
  }
}
