// Project configuration (moveable settings)
// Edit these values here instead of HexaBotArt.pde

// Constants and Unit Conversion
float MM_TO_PX = 2.835f;   // 1mm ≈ 2.835 pixels at 72 DPI (standard screen resolution)
//float MM_TO_PX = 2;   
//float MM_TO_PX = 1; 
float image_scale = 1;      // Additional scaling factor for the image

//SET THIS
//int pen_count = 6;                //up to 6 pens
//int pen_count = 1;                //up to 6 pens
int pen_count = 6;                //up to 6 pens
int current_copic_set = 15;

// Paper Size (format in mm)
float paper_size_x = 500;   // width in mm
float paper_size_y = 700;   // height in mm

// Image Size (paper size converted to pixels and scaled)
float image_size_x = paper_size_x * MM_TO_PX * image_scale;
float image_size_y = paper_size_y * MM_TO_PX * image_scale; 

// Canvas Size (display window size)
int canvas_size_x = 500;  // Window width in px
int canvas_size_y = 700;  // Window height in px

int refscale = 1;                     //sample area

boolean makelangelo = true;
int penup = 75;
int pendown = 20;
int servospeed = 150;

float paper_top_to_origin = 0;     //mm
float pen_width = 1;               //mm, determines image_scale, reduce, if solid black areas are speckled with white holes.


char gcode_decimal_seperator = '.';    
int gcode_decimals = 0;             // Number of digits right of the decimal point in the gcode files.
int svg_decimals = 0;               // Number of digits right of the decimal point in the SVG file.
float grid_scale = 10;              // Use 10.0 for centimeters, 25.4 for inches, and between 444 and 529.2 for cubits.
