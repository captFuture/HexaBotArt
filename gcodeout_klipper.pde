///////////////////////////////////////////////////////////////////////////////////////////////////////
// No, it's not a fancy dancy class like the snot nosed kids are doing these days.
// Now get the hell off my lawn.

///////////////////////////////////////////////////////////////////////////////////////////////////////
void gcode_header() {
    OUTPUT.println("START_PRINT");
    OUTPUT.println("G21");  //set units to mm
    OUTPUT.println("G90");  //position absolute
    OUTPUT.println("");

    OUTPUT.println(";(Draw border)");
    OUTPUT.println("PEN_UP");
    OUTPUT.println("G0 X"+int(-paper_size_x/2)+" Y"+int(-paper_size_y/2)+" F3000.0");
    OUTPUT.println("PEN_DOWN");
    OUTPUT.println("G1 X"+int( paper_size_x/2)+" Y"+int(-paper_size_y/2));
    OUTPUT.println("G1 X"+int( paper_size_x/2)+" Y"+int( paper_size_y/2));
    OUTPUT.println("G1 X"+int(-paper_size_x/2)+" Y"+int( paper_size_y/2));
    OUTPUT.println("G1 X"+int(-paper_size_x/2)+" Y"+int(-paper_size_y/2));
    OUTPUT.println("PEN_UP");
    OUTPUT.println("");
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void gcode_trailer() {
    OUTPUT.println("END_PRINT");
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void create_gcode_files(int line_count) {
    boolean is_pen_down;
    int pen_lifts;
    float pen_movement;
    float pen_drawing;
    int lines_drawn;
    float x, y, distance;

    float xmax = -Float.MAX_VALUE;
    float xmin =  Float.MAX_VALUE;
    float ymax = -Float.MAX_VALUE;
    float ymin =  Float.MAX_VALUE;

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
        gcode_header();

        for (int i = 1; i < line_count; i++) {
           if (d1.lines[i].pen_number == p) {

                int roundedX1 = round(d1.lines[i].x1);
                int roundedY1 = round(d1.lines[i].y1);
                int roundedX2 = round(d1.lines[i].x2);
                int roundedY2 = round(d1.lines[i].y2);

                float gcode_scaled_x1 = constrain(roundedX1 * gcode_scale + gcode_offset_x, -paper_size_x / 2, paper_size_x / 2);
                float gcode_scaled_y1 = constrain(roundedY1 * gcode_scale + gcode_offset_y, -paper_size_y / 2, paper_size_y / 2);
                float gcode_scaled_x2 = constrain(roundedX2 * gcode_scale + gcode_offset_x, -paper_size_x / 2, paper_size_x / 2);
                float gcode_scaled_y2 = constrain(roundedY2 * gcode_scale + gcode_offset_y, -paper_size_y / 2, paper_size_y / 2);

                //calculate min-max coordinates for getting maximum size of image
                if (gcode_scaled_x1 < xmin) { xmin = gcode_scaled_x1; }
                if (gcode_scaled_x1 > xmax) { xmax = gcode_scaled_x1; }
                if (gcode_scaled_x2 < xmin) { xmin = gcode_scaled_x2; }
                if (gcode_scaled_x2 > xmax) { xmax = gcode_scaled_x2; }
                if (gcode_scaled_y1 < ymin) { ymin = gcode_scaled_y1; }
                if (gcode_scaled_y1 > ymax) { ymax = gcode_scaled_y1; }
                if (gcode_scaled_y2 < ymin) { ymin = gcode_scaled_y2; }
                if (gcode_scaled_y2 > ymax) { ymax = gcode_scaled_y2; }

                distance = sqrt(sq(abs(gcode_scaled_x1 - gcode_scaled_x2)) + sq(abs(gcode_scaled_y1 - gcode_scaled_y2)));

                if (x != gcode_scaled_x1 || y != gcode_scaled_y1) {
                    is_pen_down = false;
                    distance = sqrt(sq(abs(x - gcode_scaled_x1)) + sq(abs(y - gcode_scaled_y1)));
                    x = gcode_scaled_x1;
                    y = gcode_scaled_y1;
                    pen_movement = pen_movement + distance;
                    pen_lifts++;
                    OUTPUT.println(";(Penup)");
                    OUTPUT.println("PEN_UP");
                }

                if (d1.lines[i].pen_down) {
                    if (is_pen_down == false) {
                        OUTPUT.println("G0 X" + int(x) + " Y" + int(y) + " F3000.0");
                        OUTPUT.println(";(Pendown)");
                        OUTPUT.println("PEN_DOWN");
                        is_pen_down = true;
                    }
                    pen_drawing = pen_drawing + distance;
                    lines_drawn++;
                } else {
                    if (is_pen_down == true) {
                        OUTPUT.println(";(Penup)");
                        OUTPUT.println("PEN_UP");
                        is_pen_down = false;
                        pen_movement = pen_movement + distance;
                        pen_lifts++;
                    }
                }
                if (is_pen_down == true) {
                    buf = "G1 X" + int(gcode_scaled_x2) + " Y" + int(gcode_scaled_y2) + " ";
                    OUTPUT.println(buf);
                }
                x = gcode_scaled_x2;
                y = gcode_scaled_y2;
                dx.update_limit(int(gcode_scaled_x2));
                dy.update_limit(int(gcode_scaled_y2));
            }
        }

        if (is_pen_down == true) {
            OUTPUT.println("");
        }
        gcode_trailer();
        OUTPUT.println(";(Drew " + lines_drawn + " lines for " + pen_drawing / 25.4 / 12 + " feet)");
        OUTPUT.println(";(Drawing coordinates- xmin: " + xmin + " xmax: " + xmax + " ymin: " + ymin + " ymax: " + ymax + " )");

        OUTPUT.flush();
        OUTPUT.close();
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void create_gcode_file(int line_count) {
    boolean is_pen_down;
    int pen_lifts;
    float pen_movement;
    float pen_drawing;
    int lines_drawn;
    float x, y, distance;

    float xmax = -Float.MAX_VALUE;
    float xmin =  Float.MAX_VALUE;
    float ymax = -Float.MAX_VALUE;
    float ymin =  Float.MAX_VALUE;

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
    gcode_header();

    d1.set_pen_continuation_flags();

    for (int p = pen_count - 1; p >= 0; p--) {
        boolean penHasLines = false;
        for (int i = 1; i < line_count; i++) {
            if (d1.lines[i].pen_number == p && d1.lines[i].pen_down) { penHasLines = true; break; }
        }
        if (!penHasLines) continue;

        String penName = copic.get_original_name(copic_sets[current_copic_set][p]);
        OUTPUT.println(";(Code for Pen " + penName + ")");
        OUTPUT.println("M117 Install pen: " + penName);
        OUTPUT.println("CHANGE_PEN");

        for (int i = 1; i < line_count; i++) {
           if (d1.lines[i].pen_number == p) {

                int roundedX1 = round(d1.lines[i].x1);
                int roundedY1 = round(d1.lines[i].y1);
                int roundedX2 = round(d1.lines[i].x2);
                int roundedY2 = round(d1.lines[i].y2);

                float gcode_scaled_x1 = constrain(roundedX1 * gcode_scale + gcode_offset_x, -paper_size_x / 2, paper_size_x / 2);
                float gcode_scaled_y1 = constrain(roundedY1 * gcode_scale + gcode_offset_y, -paper_size_y / 2, paper_size_y / 2);
                float gcode_scaled_x2 = constrain(roundedX2 * gcode_scale + gcode_offset_x, -paper_size_x / 2, paper_size_x / 2);
                float gcode_scaled_y2 = constrain(roundedY2 * gcode_scale + gcode_offset_y, -paper_size_y / 2, paper_size_y / 2);

                //calculate min-max coordinates for getting maximum size of image
                if (gcode_scaled_x1 < xmin) { xmin = gcode_scaled_x1; }
                if (gcode_scaled_x1 > xmax) { xmax = gcode_scaled_x1; }
                if (gcode_scaled_x2 < xmin) { xmin = gcode_scaled_x2; }
                if (gcode_scaled_x2 > xmax) { xmax = gcode_scaled_x2; }
                if (gcode_scaled_y1 < ymin) { ymin = gcode_scaled_y1; }
                if (gcode_scaled_y1 > ymax) { ymax = gcode_scaled_y1; }
                if (gcode_scaled_y2 < ymin) { ymin = gcode_scaled_y2; }
                if (gcode_scaled_y2 > ymax) { ymax = gcode_scaled_y2; }

                distance = sqrt(sq(abs(gcode_scaled_x1 - gcode_scaled_x2)) + sq(abs(gcode_scaled_y1 - gcode_scaled_y2)));

                if (x != gcode_scaled_x1 || y != gcode_scaled_y1) {
                    is_pen_down = false;
                    distance = sqrt(sq(abs(x - gcode_scaled_x1)) + sq(abs(y - gcode_scaled_y1)));
                    x = gcode_scaled_x1;
                    y = gcode_scaled_y1;
                    pen_movement = pen_movement + distance;
                    pen_lifts++;
                    OUTPUT.println(";(Penup)");
                    OUTPUT.println("PEN_UP");
                }

                if (d1.lines[i].pen_down) {
                    if (is_pen_down == false) {
                        OUTPUT.println("G0 X" + int(x) + " Y" + int(y) + " F3000.0");
                        OUTPUT.println(";(Pendown)");
                        OUTPUT.println("PEN_DOWN");
                        is_pen_down = true;
                    }
                    pen_drawing = pen_drawing + distance;
                    lines_drawn++;
                } else {
                    if (is_pen_down == true) {
                        OUTPUT.println(";(Penup)");
                        OUTPUT.println("PEN_UP");
                        is_pen_down = false;
                        pen_movement = pen_movement + distance;
                        pen_lifts++;
                    }
                }
                if (is_pen_down == true) {
                    buf = "G1 X" + int(gcode_scaled_x2) + " Y" + int(gcode_scaled_y2) + " ";
                    OUTPUT.println(buf);
                }
                x = gcode_scaled_x2;
                y = gcode_scaled_y2;
                dx.update_limit(int(gcode_scaled_x2));
                dy.update_limit(int(gcode_scaled_y2));
            }
        }

        if (is_pen_down == true) {
            OUTPUT.println("");
        }
    }

    gcode_trailer();
    OUTPUT.println(";(Drew " + lines_drawn + " lines for " + pen_drawing / 25.4 / 12 + " feet)");
    OUTPUT.println(";(Drawing coordinates- xmin: " + xmin + " xmax: " + xmax + " ymin: " + ymin + " ymax: " + ymax + " )");

    OUTPUT.flush();
    OUTPUT.close();
}
