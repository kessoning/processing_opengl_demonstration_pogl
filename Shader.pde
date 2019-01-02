// Import NIO from Java, for I/O operations, and to exchange data from Java to C# in the shader
import java.nio.*;

// Declare shader variables
float[] shaderPoints;              // The points to share with openGL
int  vertLoc;                      // Keeps the vertex location for the buffer
PGL     pgl;                       // PGL, Processing openGL
PShader sh;                        // Vertex and Fragment shader
FloatBuffer pointCloudBuffer;      // FloatBuffer of the openGL implementation
ByteBuffer byteBuf;                // ByteBuffer to share floats between Processing sketch and OpenGL
int vertexVboId;                   // Vertex Buffer Object ID

void initShader() {
  // Load the vertex and fragment shader
  sh = loadShader("frag.glsl", "vert.glsl");
  // Set the color, in the uniform float fragColor (check the shader code)
  sh.set("fragColor", 255.0/255.0, 255.0/255.0, 255.0/255.0, 255.0/255.0);

  // In openGL there are no vectors, or multivalue variables,
  // it will take every 3 values as x, y and z for each vertex.
  shaderPoints = new float[total*total*3];
  
  // Start new PGL
  PGL pgl = beginPGL();
  // Declare an int buffer, it  will identify our vertex buffer
  IntBuffer intBuffer = IntBuffer.allocate(1);
  // Generate 1 buffer, put the resulting identifier in vertexbuffer
  pgl.genBuffers(1, intBuffer);
  // The the ID from the int buffer
  vertexVboId = intBuffer.get(0);
  // End the PGL
  endPGL();
}

void updateShader() {
  
  // This will update the values in our shader, by sharing the buffer from Processing to OpenGL.
  // In the float array we will share the coordinates of the vertices. Each value is one f the x, y or z
  // coordinate from our vertices. THe index is to keep track of the actual value in the array
  int index = 0;

  for (int i = 0; i < total; i++) {
    for (int j = 0; j < total; j++) {
      shaderPoints[index+0] = points[i][j].x;  // X
      shaderPoints[index+1] = points[i][j].y;  // Y
      shaderPoints[index+2] = points[i][j].z;  // Z
      index += 3;                              // index increments by 3
    }
  }

  // Allocate the float array in a byte buffer
  byteBuf = ByteBuffer.allocateDirect(shaderPoints.length * Float.BYTES); //4 bytes per float
  // Order the byte byuffer
  byteBuf.order(ByteOrder.nativeOrder());
  // Converts the byte buffer in a float buffer
  pointCloudBuffer = byteBuf.asFloatBuffer();
  // Put the values in the float buffer
  pointCloudBuffer.put(shaderPoints);
  // Set the position to 0, starting point of the buffer
  pointCloudBuffer.position(0);
}

void showShader() {
  // Begin PGL
  pgl = beginPGL();
  // Bind the Shader
  sh.bind();
  // Set the vertex location, from the shader
  vertLoc = pgl.getAttribLocation(sh.glProgram, "vertex");

  // Enable the generic vertex attribute array specified by vertLoc
  pgl.enableVertexAttribArray(vertLoc);
  // Get the size of the float buffer
  int vertData = shaderPoints.length;

  // Binds the buffer object
  pgl.bindBuffer(PGL.ARRAY_BUFFER, vertexVboId);
  // Give our vertices to OpenGL.
  pgl.bufferData(PGL.ARRAY_BUFFER, Float.BYTES * vertData, pointCloudBuffer, PGL.DYNAMIC_DRAW);
  pgl.vertexAttribPointer(vertLoc,            // Gets the vertex location, must match the layout in the shader.
                          3,                  // Size, 3 values for each vertex from the float buffer
                          PGL.FLOAT,          // Type of the array / buffer
                          false,              // Normalized?
                          Float.BYTES * 3,    // Size of the float byte, 3 values for x, y and z
                          0                   // Stride
                          );

  // The following commands will talk about our 'vertexbuffer' buffer
  pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);
  // Draw the sphere
  pgl.drawArrays(PGL.POINTS,                  // Type of draw, in this case POINTS
                 0,                           // Starting from vertex 0
                 vertData                     // Drawing all the points from vertData, the array size
                 );
  // Disable the generic vertex attribute array specified by vertLoc
  pgl.disableVertexAttribArray(vertLoc);
  // Unbind the vertex
  sh.unbind();
  // End the POGL
  endPGL();
}
