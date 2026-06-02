// Project configuration — edit these values to change paper size, pen count, etc.

// Unit conversion: 1mm ≈ 2.835 pixels at 72 DPI
float MM_TO_PX = 2.835f;
float image_scale = 1;      // Additional scaling factor for the image

int pen_count = 6;          // Number of pens (up to 6)
int current_copic_set = 15; // Active Copic color palette (0–24)

// Paper size in mm
float paper_size_x = 500;
float paper_size_y = 700;

// Image size in pixels (derived from paper size)
float image_size_x = paper_size_x * MM_TO_PX * image_scale;
float image_size_y = paper_size_y * MM_TO_PX * image_scale;

// Display window size in pixels
int canvas_size_x = 500;
int canvas_size_y = 700;

int refscale = 1;              // Sample area scale factor

boolean makelangelo = true;    // Enable Klipper GCODE output

float pen_width = 1;           // mm; reduce if solid areas show white gaps

float grid_scale = 10;         // Grid spacing: 10 = cm, 25.4 = inches
