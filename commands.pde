class ChildApplet extends PApplet {
  //JFrame frame;

  public ChildApplet() {
    super();
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(360, 700, P3D);
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
