/* This program simulates indexed color. It loads a color palette
 calculated using the k-means algorithm. These colors are
 substituted for the original pixel colors in the image.
 '1' displays the original image; '2' displays the indexed image;
 '3' displays the dithered image; 'c' displays the color palette
 'h': color counts in indexed image; 'd' color counts in dithered image
 THIS VERSION USES A PREVIOUSLY SAVED PALETTE - IT DOES NOT DO K-MEANS
 */
final int HUGENUM = 500; //Bigger than any color distance
String fname1 = "ColoredSquares.jpg", fname2 = "colorful-1560.jpg";
String fname3 = "Lizard.jpg";
String loadName = fname2; //This is the file to load
int ncolors = 8;  //number of colors in the table
color[] colorTable = new color[ncolors];  //This is the color palette
int[] pHist = new int[ncolors]; //Shows counts of colors in indexed image
int[] dHist = new int[ncolors]; //Shows counts of colors in dithered image
PImage[] img = new PImage[3];  //original, indexed, dithered, images
/* indices is same length as pixel array and will hold color indexes.
 For example, when indexing img[0], indices[0] will hold the index of
 the matching palette color for img[0].pixels[0].
 */
int[] indices;
int imgIndex = 0;  //Determines which image to display

void setup() {
  //Don't change setup()
  size(500, 500);
  surface.setResizable(true);
  img[0] = loadImage(loadName);
  surface.setSize(img[0].width, img[0].height);
  img[0].loadPixels();
  indices = new int[img[0].pixels.length];  //Holds matching palette color for each pixel
  //The next lines create paletteName; assumes loadName extension is 4 chars (ex: ".jpg")
  String fileName = loadName;
  int nc = ncolors;
  String paletteName = "palettes\\" + fileName.substring(0, fileName.length()-4) + 
    "_" + str(nc) + ".bmp";
  readPalette(paletteName, colorTable);  //Read the color palette into colorTable
  matchTable(indices, colorTable, img[0]);  //Match the pixels w/colors from colorTable
  //Now index img[0] - put the result in img[1]
  img[1] = indexImage(indices, colorTable, img[0].width, img[0].height);
  img[2] = img[0].get();  //Get a copy of img[0]
  dither(img[2], colorTable);  //Index img[2] and dither it
}
void readPalette(String paletteName, color[] palette) {
  //Load the palette into the color table; don't change this function
  //For convenience, the palette is stored as pixels in an image
  PImage paletteImage = loadImage(paletteName);
  paletteImage.loadPixels();
  for (int i = 0; i < palette.length; i++) {
    palette[i] = paletteImage.pixels[i];
  }
}
void draw() {
  //image(img[imgIndex], 0, 0); --Removed 3/29/2018
}
float cdist(color c1, color c2) {
  //Returns the distance between c1 and c2; don't change this function
  float r1 = red(c1), r2 = red(c2);
  float g1 = green(c1), g2 = green(c2);
  float b1 = blue(c1), b2 = blue(c2);
  float d = sqrt(sq(r1-r2) + sq(g1-g2) + sq(b1-b2));
  return d;
} 
void matchTable(int[] indices, color[] table, PImage img) {
  /* This function matches each pixel in img to the color table
   and puts the closest-matching index into the corresponding
   entry in the indices array. For example, if table[7] is the
   closest color match to img.pixels[4912] then indices[4912]
   will get a value of 7.
   */
  for (int i = 0; i < indices.length; i++) {
    float shortDist = HUGENUM;
    int index = 0;
    for (int x = 0; x < table.length; x++) {
      float currentDistance = cdist(img.pixels[i], table[x]);
      if (currentDistance < shortDist) {
        index = x;
        shortDist = currentDistance;
      }
    }
    indices[i] = index;
  }
}
PImage indexImage(int[] indices, color[] table, int w, int h) {
  /* Returns a new image with each pixel replaced by the closest
   matching color in table. For example, if indices[47219] has
   a value of 7, then target.pixels[47219] will be replaced by
   the color in table[7].
   */
  PImage target = createImage(w, h, RGB);
  for (int i = 0; i < target.pixels.length; i++) {
    target.pixels[i] = table[indices[i]];
  }

  return target;
}
void hist(int[] counts) {
  /* Creates histogram of index values. Note that this
   histogram does NOT range from 0 to 255 - it
   ranges from 0 to the number of colors in colorTable.
   counts is the same size as colorTable.
   You should fill counts with the number of times
   each color is used in the image. For example,
   counts[3] will be the number of times colorTable[3]
   is used. The indices array has the number of times
   each palette color is used. If indices[727] has a
   value of 5, then you should add one to counts[5].
   */
  for (int i = 0; i < counts.length; i++) {
    counts[i] = 0;  //Initialize counts to 0
  }
  //Your code here to fill counts with the number of times each color is used
  for (int y = 0; y < colorTable.length; y++) {
    for (int x = 0; x < img[1].pixels.length; x++) {
      if (colorTable[y] == img[1].pixels[x]) {
      counts[y]++;
      }
    }
  }

  drawHist(counts);  //Display the counts histogram
}
void drawHist(int[] counts) {
  /*Your code here to display the histogram; the values are held in the
   counts array. You will first have to find the max value in counts
   and use that to scale the histogram bars. Alternatively, you can
   display the counts as text on the canvas.
   */
  background(155);
  int maxval = 0;
  for (int i = 0; i < counts.length; i++) {
    if (counts[i] > maxval) maxval = counts[i];
  }
  for (int x = 0; x < counts.length; x++) {
    int val = int(map(counts[x], 0, maxval, 0, height/2));
    line(x + 10, height, x + 10, height - val);
  }
}
void showColors() { //Display the color table
  background(0);
  /*Your code here to display the color table. It doesn't have to
   look like mine but it should be comprehensible.
   */
}
void dither(PImage img, color[] palette) {
  //Leaves one row at bottom and one column on either side undithered
  float distance, r, g, b, rdiff, gdiff, bdiff;
  color p;
  for (int i = 0; i < dHist.length; i++) dHist[i] = 0; //Initialize dither color count
  /*Your code here to dither img. You'll have to index each pixel as you go - you
   can't index the image in advance because some of the target pixel's neighbors
   are changed when you add quantization error to them.
   When you match the target pixel to palette, don't forget to update dhists, which
   is the count of how many times each palette color is used in the dithered image.
   */
}
void keyReleased() {
  if (key == '1') image(img[0], 0, 0);  //imgIndex = 0; --Modified 3/29/2018
  else if (key == '2') image(img[1], 0, 0); //imgIndex = 1;
  else if (key == '3') image(img[2], 0, 0); //imgIndex = 2;
  else if (key == 'h') hist(pHist);
  else if (key == 'd') drawHist(dHist);
  else if (key == 'c') showColors();
}