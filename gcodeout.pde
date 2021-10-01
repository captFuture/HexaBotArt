///////////////////////////////////////////////////////////////////////////////////////////////////////
// No, it's not a fancy dancy class like the snot nosed kids are doing these days.
// Now get the hell off my lawn.

///////////////////////////////////////////////////////////////////////////////////////////////////////
void gcode_header() {
    OUTPUT.println("G28");
    OUTPUT.println("G21");
    OUTPUT.println("G90");
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void gcode_trailer() {
    OUTPUT.println("M280 P0 S" + penup + " T" + servospeed);
    OUTPUT.println("G1 X0.10 Y0.10");
    OUTPUT.println("G1 X0 Y0");
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void gcode_comment(String comment) {
    code_comments += ("(" + comment + ")") + "\n";
    println(comment);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void create_gcode_files(int line_count) {
    boolean is_pen_down;
    int pen_lifts;
    float pen_movement;
    float pen_drawing;
    int   lines_drawn;
    float x;
    float y;
    float distance;
    
    float xmax = 0;
    float xmin = 0;
    float ymax = 0;
    float ymin = 0;
    
    //Loop over all lines for every pen.
    for (int p = 0; p < pen_count; p++) {   
        
        is_pen_down = false;
        pen_lifts = 2;
        pen_movement = 0;
        pen_drawing = 0;
        lines_drawn = 0;
        x = 0;
        y = 0;
        String gname = "gcode\\" + basefile_selected + "\\" + pfms[current_pfm] + "\\" + current_copic_set + "\\" + basefile_selected + "_pen" + p + "_" + copic_sets[current_copic_set][p] + ".gcode";
        
        OUTPUT = createWriter(sketchPath("") + gname);
        
          String buf = "";
        OUTPUT.println(buf);
        
        OUTPUT.println(code_comments);
        gcode_header();
        
        for (int i = 1; i < line_count; i++) { 
           if (d1.lines[i].pen_number == p) {
                
                int roundedX1 = round(d1.lines[i].x1);
                int roundedY1 = round(d1.lines[i].y1);
                int roundedX2 = round(d1.lines[i].x2);
                int roundedY2 = round(d1.lines[i].y2);
                
                float gcode_scaled_x1 = roundedX1 * gcode_scale + gcode_offset_x;
                float gcode_scaled_y1 = (roundedY1 * gcode_scale + gcode_offset_y) * - 1;
                float gcode_scaled_x2 = roundedX2 * gcode_scale + gcode_offset_x;
                float gcode_scaled_y2 = (roundedY2 * gcode_scale + gcode_offset_y) * - 1;
                
                //calculate min-max coordinates for getting maximum size of image
                if (gcode_scaled_x1 < 0 && gcode_scaled_x1 < xmin) { xmin = gcode_scaled_x1; }
                if (gcode_scaled_x2 > 0 && gcode_scaled_x2 > xmax) { xmax = gcode_scaled_x2; }
                if (gcode_scaled_y1 < 0 && gcode_scaled_y1 < ymin) { ymin = gcode_scaled_y1; }
                if (gcode_scaled_y2 > 0 && gcode_scaled_y2 > ymax) { ymax = gcode_scaled_y2; }
                
                distance= sqrt(sq(abs(gcode_scaled_x1 - gcode_scaled_x2)) + sq(abs(gcode_scaled_y1 - gcode_scaled_y2)));
                
                if (x !=gcode_scaled_x1 || y != gcode_scaled_y1) {
                    is_pen_down = false;
                    distance =sqrt(sq(abs(x - gcode_scaled_x1)) + sq(abs(y - gcode_scaled_y1)));
                    x = gcode_scaled_x1;
                    y = gcode_scaled_y1;
                    pen_movement = pen_movement + distance;
                    pen_lifts++;
                    OUTPUT.println("(Penup)");
                    OUTPUT.println("M280 P0 S" + penup + " T" + servospeed);
                }
                
                if (d1.lines[i].pen_down) {
                   if (is_pen_down == false) {
                        //penupmoves
                        OUTPUT.println("G0 X" + int(x) + " Y" + int(y));
                        OUTPUT.println("(Pendown)");
                        OUTPUT.println("M280 P0 S" + pendown + " T" + servospeed);
                        is_pen_down = true;
                }
                    pen_drawing = pen_drawing + distance;
                    lines_drawn++;
            } else {
                   if (is_pen_down == true) {
                        //somemoves
                        OUTPUT.println("(Penup)");
                        OUTPUT.println("M280 P0 S" + penup + " T" + servospeed);
                 		      //color c = copic.get_original_color(copic_sets[current_copic_set][p]);
                        //OUTPUT.println("\" style=\"fill:none;stroke:#"+hex(c, 6)+";stroke-width:"+pen_width+";stroke-opacity:1;stroke-miterlimit:4;stroke-dasharray:none\"/>");
                        is_pen_down = false;
                        pen_movement= pen_movement + distance;
                        pen_lifts++;
                }
                }
                if (is_pen_down == true) {
                    //pendown moves
                   buf =  "G1X" + int(gcode_scaled_x2) + " Y" + int(gcode_scaled_y2) + " ";
                    OUTPUT.println(buf);
                    
                }
                x = gcode_scaled_x2;
                y = gcode_scaled_y2;
                dx.update_limit(int(gcode_scaled_x2));
                dy.update_limit(int(gcode_scaled_y2));
        }
        }
        
        if (is_pen_down == true) {
            //lastline 
            OUTPUT.println("");
        }
        gcode_trailer();
        OUTPUT.println("(Drew " + lines_drawn + " lines for " + pen_drawing  / 25.4 / 12 + " feet)");
        OUTPUT.println("(Drawing coordinates- xmin: " + xmin + " xmax: " + xmax + " ymin: " + ymin + " ymax: " + ymax + " )");
        
        
        
        OUTPUT.flush();
        OUTPUT.close();
}
    
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void create_gcode_file(int line_count) {
    boolean drawing_polyline = false;
    float svgdpi = 96.0 / 25.4;
    
    boolean is_pen_down;
    int pen_lifts;
    float pen_movement;
    float pen_drawing;
    int   lines_drawn;
    float x;
    float y;
    float distance;
    int roundedX;
    int roundedY;
    
    float xmax = 0;
    float xmin = 0;
    float ymax = 0;
    float ymin = 0;
    
    is_pen_down = false;
    pen_lifts = 2;
    pen_movement = 0;
    pen_drawing = 0;
    lines_drawn = 0;
    x = 0;
    y = 0;
    
    String gname = "gcode\\complete_" + pfms[current_pfm] + "_" + current_copic_set + "_" + basefile_selected + ".gcode";
    OUTPUT = createWriter(sketchPath("") + gname);
    
    String buf = "";
    OUTPUT.println(buf);
    
    OUTPUT.println(code_comments);
    gcode_header();
    
    d1.set_pen_continuation_flags();
    
    for (int p = pen_count - 1; p >=  0; p--) {    
        OUTPUT.println("(Code for Pen " + copic_sets[current_copic_set][p] + ")");
        
        OUTPUT.println("M300 S2093 P200");
        // Penup movement and waiting for user input (changing pen)
        OUTPUT.println("M280 P0 S" + penup + " T" + servospeed);
        OUTPUT.println("M0 Pen " + copic_sets[current_copic_set][p] + " and click");
        
        for (int i = 1; i < line_count; i++) { 
           if (d1.lines[i].pen_number == p) {
                
                int roundedX1 = round(d1.lines[i].x1);
                int roundedY1 = round(d1.lines[i].y1);
                int roundedX2 = round(d1.lines[i].x2);
                int roundedY2 = round(d1.lines[i].y2);
                
                float gcode_scaled_x1 = roundedX1 * gcode_scale + gcode_offset_x;
                float gcode_scaled_y1 = (roundedY1 * gcode_scale + gcode_offset_y) * - 1;
                float gcode_scaled_x2 = roundedX2 * gcode_scale + gcode_offset_x;
                float gcode_scaled_y2 = (roundedY2 * gcode_scale + gcode_offset_y) * - 1;
                
                //calculate min-max coordinates for getting maximum size of image
                if (gcode_scaled_x1 < 0 && gcode_scaled_x1 < xmin) { xmin = gcode_scaled_x1; }
                if (gcode_scaled_x2 > 0 && gcode_scaled_x2 > xmax) { xmax = gcode_scaled_x2; }
                if (gcode_scaled_y1 < 0 && gcode_scaled_y1 < ymin) { ymin = gcode_scaled_y1; }
                if (gcode_scaled_y2 > 0 && gcode_scaled_y2 > ymax) { ymax = gcode_scaled_y2; }
                
                distance= sqrt(sq(abs(gcode_scaled_x1 - gcode_scaled_x2)) + sq(abs(gcode_scaled_y1 - gcode_scaled_y2)));
                
                if (x !=gcode_scaled_x1 || y != gcode_scaled_y1) {
                    is_pen_down = false;
                    distance =sqrt(sq(abs(x - gcode_scaled_x1)) + sq(abs(y - gcode_scaled_y1)));
                    x = gcode_scaled_x1;
                    y = gcode_scaled_y1;
                    pen_movement = pen_movement + distance;
                    pen_lifts++;
                    OUTPUT.println("(Penup)");
                    OUTPUT.println("M280 P0 S" + penup + " T" + servospeed);
                }
                
                if (d1.lines[i].pen_down) {
                   if (is_pen_down == false) {
                        //penupmoves
                        OUTPUT.println("G0 X" + int(x) + " Y" + int(y));
                        OUTPUT.println("(Pendown)");
                        OUTPUT.println("M280 P0 S" + pendown + " T" + servospeed);
                        is_pen_down = true;
                }
                    pen_drawing = pen_drawing + distance;
                    lines_drawn++;
            } else {
                   if (is_pen_down == true) {
                        //somemoves
                        OUTPUT.println("(Penup)");
                        OUTPUT.println("M280 P0 S" + penup + " T" + servospeed);
                 		      //color c = copic.get_original_color(copic_sets[current_copic_set][p]);
                        //OUTPUT.println("\" style=\"fill:none;stroke:#"+hex(c, 6)+";stroke-width:"+pen_width+";stroke-opacity:1;stroke-miterlimit:4;stroke-dasharray:none\"/>");
                        is_pen_down = false;
                        pen_movement= pen_movement + distance;
                        pen_lifts++;
                }
                }
                if (is_pen_down == true) {
                    //pendown moves
                   buf =  "G1X" + int(gcode_scaled_x2) + " Y" + int(gcode_scaled_y2) + " ";
                    OUTPUT.println(buf);
                    
                }
                x = gcode_scaled_x2;
                y = gcode_scaled_y2;
                dx.update_limit(int(gcode_scaled_x2));
                dy.update_limit(int(gcode_scaled_y2));
        }
        }
        
        if (is_pen_down == true) {
            //lastline 
            OUTPUT.println("");
        }
        
}
    
    gcode_trailer();
    OUTPUT.println("(Drew " + lines_drawn + " lines for " + pen_drawing  / 25.4 / 12 + " feet)");
    OUTPUT.println("(Drawing coordinates- xmin: " + xmin + " xmax: " + xmax + " ymin: " + ymin + " ymax: " + ymax + " )");
    
    OUTPUT.flush();
    OUTPUT.close();
}
