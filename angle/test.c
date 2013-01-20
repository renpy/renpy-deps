#include <stdio.h>
#include <SDL.h>
#include <SDL_syswm.h>
#include "EGL/egl.h"
#include "GLES2/gl2.h"

GLuint programObject;

GLuint LoadShader ( GLenum type, const char *shaderSrc ) {
   GLuint shader;
   GLint compiled;
   
   // Create the shader object
   shader = glCreateShader ( type );

   if ( shader == 0 )
        return 0;

   // Load the shader source
   glShaderSource ( shader, 1, &shaderSrc, NULL );
   
   // Compile the shader
   glCompileShader ( shader );

   // Check the compile status
   glGetShaderiv ( shader, GL_COMPILE_STATUS, &compiled );

   if ( !compiled ) 
   {
      GLint infoLen = 0;

      glGetShaderiv ( shader, GL_INFO_LOG_LENGTH, &infoLen );
      
      if ( infoLen > 1 )
      {
         char* infoLog = malloc (sizeof(char) * infoLen );

         glGetShaderInfoLog ( shader, infoLen, NULL, infoLog );
         printf( "Error compiling shader:\n%s\n", infoLog );            
         
         free ( infoLog );
      }

      glDeleteShader ( shader );
      return 0;
   }

   return shader;

}

///
// Initialize the shader and program object
//
int Init() {
   GLbyte vShaderStr[] =  
      "attribute vec4 vPosition;    \n"
      "void main()                  \n"
      "{                            \n"
      "   gl_Position = vPosition;  \n"
      "}                            \n";
   
   GLbyte fShaderStr[] =  
      "precision mediump float;\n"\
      "void main()                                  \n"
      "{                                            \n"
      "  gl_FragColor = vec4 ( 1.0, 0.0, 0.0, 1.0 );\n"
      "}                                            \n";

   GLuint vertexShader;
   GLuint fragmentShader;
   GLint linked;

   // Load the vertex/fragment shaders
   vertexShader = LoadShader ( GL_VERTEX_SHADER, vShaderStr );
   fragmentShader = LoadShader ( GL_FRAGMENT_SHADER, fShaderStr );

   // Create the program object
   programObject = glCreateProgram ( );
   
   if ( programObject == 0 )
      return 0;

   glAttachShader ( programObject, vertexShader );
   glAttachShader ( programObject, fragmentShader );

   // Bind vPosition to attribute 0   
   glBindAttribLocation ( programObject, 0, "vPosition" );

   // Link the program
   glLinkProgram ( programObject );

   // Check the link status
   glGetProgramiv ( programObject, GL_LINK_STATUS, &linked );

   if ( !linked ) 
   {
      GLint infoLen = 0;

      glGetProgramiv ( programObject, GL_INFO_LOG_LENGTH, &infoLen );
      
      if ( infoLen > 1 )
      {
         char* infoLog = malloc (sizeof(char) * infoLen );

         glGetProgramInfoLog ( programObject, infoLen, NULL, infoLog );
         printf("Error linking program:\n%s\n", infoLog );            
         
         free ( infoLog );
      }

      glDeleteProgram ( programObject );
      return FALSE;
   }

   glClearColor ( 0.0f, 0.0f, 1.0f, 1.0f );
   return TRUE;
}

///
// Draw a triangle using the shader pair created in Init()
//
void Draw ( )
{
   GLfloat vVertices[] = {  0.0f,  0.5f, 0.0f, 
                           -0.5f, -0.5f, 0.0f,
                            0.5f, -0.5f, 0.0f };
      
   // Set the viewport
   glViewport ( 0, 0, 640, 480 );
   
   // Clear the color buffer
   glClear ( GL_COLOR_BUFFER_BIT );

   // Use the program object
   glUseProgram ( programObject );

   // Load the vertex data
   glVertexAttribPointer ( 0, 3, GL_FLOAT, GL_FALSE, 0, vVertices );
   glEnableVertexAttribArray ( 0 );

   glDrawArrays ( GL_TRIANGLES, 0, 3 );
}




int main(int argc, char **argv) {

    SDL_Event event;
    SDL_Surface *screen;
    SDL_SysWMinfo wminfo;
    EGLDisplay display;
    EGLint major, minor;
    EGLint num_config;
    EGLConfig config;
    EGLSurface surface;
    EGLContext context;
    
    const EGLint attrs[] = {
         EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
         EGL_NONE
     };

    const EGLint context_attrs[] = {
        EGL_CONTEXT_CLIENT_VERSION, 2,
        EGL_NONE
    };
    
    int err;

    err = SDL_Init(SDL_INIT_VIDEO|SDL_INIT_TIMER);

    screen = SDL_SetVideoMode(640, 480, 32, 0);
    SDL_Flip(screen);

    SDL_VERSION(&wminfo.version);
    SDL_GetWMInfo(&wminfo);

    display = eglGetDisplay(GetDC(wminfo.window));
    eglInitialize(display, &major, &minor);
    
    printf("Error %x.\n", eglGetError());

    eglBindAPI(EGL_OPENGL_ES_API);
    
    printf("Error %x.\n", eglGetError());

    eglChooseConfig(display, attrs, &config, 1, &num_config);

    printf("Error %x.\n", eglGetError());

    surface = eglCreateWindowSurface(display, config, wminfo.window, NULL);

    printf("Error. %x\n", eglGetError());

    context = eglCreateContext(display, config, EGL_NO_CONTEXT, context_attrs);

    printf("Error. %x\n", eglGetError());

    eglMakeCurrent(display, surface, surface, context);

    printf("Error. %x\n", eglGetError());

    Init();
    
    while(1) {
        Draw();

        eglSwapBuffers(display, surface);

        printf("Error. %x\n", eglGetError());

        SDL_WaitEvent(&event);

        if (event.type == SDL_QUIT) {
            break;
        }
    }
    
}
