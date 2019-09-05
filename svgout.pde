///////////////////////////////////////////////////////////////////////////////////////////////////////
void code_comment(String comment) {
  code_comments += ("(" + comment + ")") + "\n";
  println(comment);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void pen_up() {
  is_pen_down = false;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void pen_down() {
  is_pen_down = true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void move_abs(int pen_number, float x, float y) {
  
  d1.addline(pen_number, is_pen_down, old_x, old_y, x, y);
  if (is_pen_down) {
    d1.render_last();
  }
  
  old_x = x;
  old_y = y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////
// Thanks to Vladimir Bochkov for helping me debug the SVG international decimal separators problem.
String svg_format (Float n) {
  final char regional_decimal_separator = ',';
  final char svg_decimal_seperator = '.';
  
  String s = nf(n, 0, svg_decimals);
  s = s.replace(regional_decimal_separator, svg_decimal_seperator);
  return s;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
/*void create_svg_file (int line_count) {
  boolean drawing_polyline = false;
  float svgdpi = 96.0 / 25.4;
  
  String gname = "svg\\complete_" + basefile_selected + ".svg";
  OUTPUT = createWriter(sketchPath("") + gname);
  OUTPUT.println("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>");
  OUTPUT.println("<svg width=\"" + svg_format(img.width * gcode_scale) + "mm\" height=\"" + svg_format(img.height * gcode_scale) + "mm\" xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\">");
  d1.set_pen_continuation_flags();
  
  // Loop over pens backwards to display dark lines last.
  // Then loop over all displayed lines.
  for (int p=pen_count-1; p>=0; p--) {    
    OUTPUT.println("<g id=\"" + copic_sets[current_copic_set][p] + "\">");
    for (int i=1; i<line_count; i++) { 
      if (d1.lines[i].pen_number == p) {

        float gcode_scaled_x1 = d1.lines[i].x1 * gcode_scale * svgdpi;
        float gcode_scaled_y1 = d1.lines[i].y1 * gcode_scale * svgdpi;
        float gcode_scaled_x2 = d1.lines[i].x2 * gcode_scale * svgdpi;
        float gcode_scaled_y2 = d1.lines[i].y2 * gcode_scale * svgdpi;

        if (d1.lines[i].pen_continuation == false && drawing_polyline) {
          OUTPUT.println("\" />");
          drawing_polyline = false;
        }

        if (d1.lines[i].pen_down) {
          if (d1.lines[i].pen_continuation) {
            String buf = svg_format(gcode_scaled_x2) + "," + svg_format(gcode_scaled_y2);
            OUTPUT.println(buf);
            drawing_polyline = true;
          } else {
            color c = copic.get_original_color(copic_sets[current_copic_set][p]);
            OUTPUT.println("<polyline fill=\"none\" stroke=\"#" + hex(c, 6) + "\" stroke-width=\"1.0\" stroke-opacity=\"1\" points=\"");
            String buf = svg_format(gcode_scaled_x1) + "," + svg_format(gcode_scaled_y1);
            OUTPUT.println(buf);
            drawing_polyline = true;
          }
        }
      }
    }
    if (drawing_polyline) {
      OUTPUT.println("\" />");
      drawing_polyline = false;
    }
    OUTPUT.println("</g>");
  }
  OUTPUT.println("</svg>");
  OUTPUT.flush();
  OUTPUT.close();
  println("SVG created:  " + gname);
}
*/
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
void create_svg_file (int line_count) {
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
  
  is_pen_down = false;
  pen_lifts = 2;
  pen_movement = 0;
  pen_drawing = 0;
  lines_drawn = 0;
  x = 0;
  y = 0;
  
  String gname = "svg\\complete_" + basefile_selected + ".svg";
  OUTPUT = createWriter(sketchPath("") + gname);
  
  String buf ="<svg xmlns=\"http://www.w3.org/2000/svg\">";
  OUTPUT.println(buf);
  
  d1.set_pen_continuation_flags();
  
  // Loop over pens backwards to display dark lines last.
  // Then loop over all displayed lines.
  for (int p=pen_count-1; p>=0; p--) {    
	OUTPUT.println("<!-- Code for Pen " + copic_sets[current_copic_set][p] + " -->");
  
	
	for(int i=1; i<line_count; i++) { 
      if (d1.lines[i].pen_number == p) {
        
		int roundedX1 = round(d1.lines[i].x1);
		int roundedY1 = round(d1.lines[i].y1);
		int roundedX2 = round(d1.lines[i].x2);
		int roundedY2 = round(d1.lines[i].y2);
    
        float gcode_scaled_x1 = roundedX1 * gcode_scale;
        float gcode_scaled_y1 = roundedY1 * gcode_scale;
        float gcode_scaled_x2 = roundedX2 * gcode_scale;
        float gcode_scaled_y2 = roundedY2 * gcode_scale;
        distance = sqrt(sq(abs(gcode_scaled_x1 - gcode_scaled_x2)) + sq(abs(gcode_scaled_y1 - gcode_scaled_y2)) );
 
        if (x != gcode_scaled_x1 || y != gcode_scaled_y1) {
          is_pen_down = false;
          distance = sqrt( sq(abs(x - gcode_scaled_x1)) + sq(abs(y - gcode_scaled_y1)) );
          x = gcode_scaled_x1;
          y = gcode_scaled_y1;
          pen_movement = pen_movement + distance;
          pen_lifts++;
        }
        
        if (d1.lines[i].pen_down) {
          if (is_pen_down == false) {
            OUTPUT.print("<path d=\"M "+x+","+y+" L ");
            is_pen_down = true;
          }
          pen_drawing = pen_drawing + distance;
          lines_drawn++;
        } else {
          if (is_pen_down == true) {
			color c = copic.get_original_color(copic_sets[current_copic_set][p]);
            OUTPUT.println("\" style=\"fill:none;stroke:#"+hex(c, 6)+";stroke-width:1;stroke-opacity:1;stroke-miterlimit:4;stroke-dasharray:none\"/>");
            is_pen_down = false;
            pen_movement = pen_movement + distance;
            pen_lifts++;
          }
        }
        if (is_pen_down == true) {
          buf =  gcode_scaled_x2 + "," + gcode_scaled_y2 + " ";
          OUTPUT.print(buf);
        }
        x = gcode_scaled_x2;
        y = gcode_scaled_y2;
        dx.update_limit(gcode_scaled_x2);
        dy.update_limit(gcode_scaled_y2);
      }
    }
    
	if (is_pen_down == true) {
		color c = copic.get_original_color(copic_sets[current_copic_set][p]);
		OUTPUT.println("\" style=\"fill:none;stroke:#"+hex(c, 6)+";stroke-width:1;stroke-opacity:1;stroke-miterlimit:4;stroke-dasharray:none\"/>");
	}
	
  }
  
 
  OUTPUT.println("</svg>");
  OUTPUT.flush();
  OUTPUT.close();
  println("SVG created:  " + gname);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
void create_svg_files (int line_count) {
  boolean is_pen_down;
  int pen_lifts;
  float pen_movement;
  float pen_drawing;
  int   lines_drawn;
  float x;
  float y;
  float distance;
  
  // Loop over all lines for every pen.
  for(int p=0; p<pen_count; p++) {   
  
    is_pen_down = false;
    pen_lifts = 2;
    pen_movement = 0;
    pen_drawing = 0;
    lines_drawn = 0;
    x = 0;
    y = 0;
    String gname = "svg\\" + basefile_selected + "\\" + basefile_selected + "_pen" + p + "_" + copic_sets[current_copic_set][p] + ".svg";
    OUTPUT = createWriter(sketchPath("") + gname);

	String buf ="<svg xmlns=\"http://www.w3.org/2000/svg\">";
    OUTPUT.println(buf);
    
    for(int i=1; i<line_count; i++) { 
      if (d1.lines[i].pen_number == p) {
        
    int roundedX1 = round(d1.lines[i].x1);
    int roundedY1 = round(d1.lines[i].y1);
    int roundedX2 = round(d1.lines[i].x2);
    int roundedY2 = round(d1.lines[i].y2);
    
        float gcode_scaled_x1 = roundedX1 * gcode_scale;
        float gcode_scaled_y1 = roundedY1 * gcode_scale;
        float gcode_scaled_x2 = roundedX2 * gcode_scale;
        float gcode_scaled_y2 = roundedY2 * gcode_scale;
        distance = sqrt(sq(abs(gcode_scaled_x1 - gcode_scaled_x2)) + sq(abs(gcode_scaled_y1 - gcode_scaled_y2)) );
 
        if (x != gcode_scaled_x1 || y != gcode_scaled_y1) {
          is_pen_down = false;
          distance = sqrt( sq(abs(x - gcode_scaled_x1)) + sq(abs(y - gcode_scaled_y1)) );
          x = gcode_scaled_x1;
          y = gcode_scaled_y1;
          pen_movement = pen_movement + distance;
          pen_lifts++;
        }
        
        if (d1.lines[i].pen_down) {
          if (is_pen_down == false) {
            OUTPUT.print("<path d=\"M "+x+","+y+" L ");
            is_pen_down = true;
          }
          pen_drawing = pen_drawing + distance;
          lines_drawn++;
        } else {
          if (is_pen_down == true) {
			color c = copic.get_original_color(copic_sets[current_copic_set][p]);
            OUTPUT.println("\" style=\"fill:none;stroke:#"+hex(c, 6)+";stroke-width:1;stroke-opacity:1;stroke-miterlimit:4;stroke-dasharray:none\"/>");
            is_pen_down = false;
            pen_movement = pen_movement + distance;
            pen_lifts++;
          }
        }
        if (is_pen_down == true) {
          buf =  gcode_scaled_x2 + "," + gcode_scaled_y2 + " ";
          OUTPUT.print(buf);
        }
        x = gcode_scaled_x2;
        y = gcode_scaled_y2;
        dx.update_limit(gcode_scaled_x2);
        dy.update_limit(gcode_scaled_y2);
      }
    }
    
  if (is_pen_down == true) {
	color c = copic.get_original_color(copic_sets[current_copic_set][p]);
    OUTPUT.println("\" style=\"fill:none;stroke:#"+hex(c, 6)+";stroke-width:1;stroke-opacity:1;stroke-miterlimit:4;stroke-dasharray:none\"/>");
  }
    OUTPUT.println("</svg>");
    OUTPUT.flush();
    OUTPUT.close();
    println("svg created for pen " + p);
  }
  
  
}
