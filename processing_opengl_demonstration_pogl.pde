/**
 * OpenGL implementation in Processing for a Particle System with GLSL Shaders
 * Done this while learning OpenGL and GLSL languages and their implementation
 * in Processing with POGL (Processing wrapper of JOGL).
 *
 * Copyright (c) 2019 Giovanni Muzio - kesson
 * Please use the code, share it, modify it and, if so, give just credits to me.
 *
 * You can find more information about this on the Processing WIki
 * https://github.com/processing/processing/wiki/Advanced-OpenGL
 *
 * The spherical coordinates are based on Daniel Shiffman Coding Challenge #25
 * https://github.com/CodingTrain/website/blob/master/CodingChallenges/CC_025_SphereGeometry/Processing/CC_025_SphereGeometry/CC_025_SphereGeometry.pde
 * 
 * Find more at https://kesson.io
 */

// Import PeasyCam, for easy camera controls
import peasy.*;
PeasyCam cam;

// 2D arrays for points and to keep track of noise, so we don't calculate it everytime
PVector[][] points;
PVector[][] noise;

// Radius of the sphere
float radius = 200;

// Total number of points
// 2D array means 250*250=62.500 points in total
int total = 250;

// This creates the animation for the sphere
float updateNoise = 0;

void settings() {
  size(1280, 720, P3D);
}

void setup() {
  // Maximum speed, for testing purpose
  frameRate(1000);
  
  // Initialize the shader, check the shader tab
  initShader();

  // Disable the depth test to not have weird shading on the colors
  hint(DISABLE_DEPTH_TEST);

  // field of view and perspective of the camera
  float fov = PI/3.0; 
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, float(width)/float(height), 
    cameraZ/10.0, cameraZ*10000.0);

  // Initialize the points and noise arrays
  points = new PVector[total][total];
  noise = new PVector[total][total];

  // Initialize the camera
  cam = new PeasyCam(this, 500);

  // Variable for the 2D noise, x coordinate
  float nx = 0;

  for (int i = 0; i < total; i++) {

    // Calculate the latitude
    float lat = map(i, 0, total-1, 0, PI);

    // Second variable for the noise
    float ny = 0;

    for (int j = 0; j < total; j++) {

      // Longitude
      float lon = map(j, 0, total-1, 0, TWO_PI);

      // Radius with noise applied
      float r = radius * noise(nx, ny);

      // Spherical coordinates
      float x = r * sin(lat) * cos(lon);
      float y = r * sin(lat) * sin(lon);
      float z = r * cos(lat);

      points[i][j] = new PVector(x, y, z);
      noise[i][j] = new PVector(nx, ny);

      ny += 0.01;
    }

    nx += 0.02;
  }
}

void draw() {
  background(0);

  update();        // Update the coordinates
  updateShader();  // Update the buffer in the openGL shader
  showShader();    // Display the shader
}

void update() {

  // TODO: optimize the update method
  
  for (int i = 0; i < total; i++) {

    float lat = map(i, 0, total, 0, PI);

    for (int j = 0; j < total; j++) {

      float lon = map(j, 0, total-1, 0, TWO_PI);

      float r = radius * noise(noise[i][j].x + updateNoise, noise[i][j].y + updateNoise);

      points[i][j].x = r * sin(lat) * cos(lon);
      points[i][j].y = r * sin(lat) * sin(lon);
      points[i][j].z = r * cos(lat);
    }
  }

  updateNoise += 0.01;
}
