module de.shader;

import de.math;
import de.texture;

import core.logger;
import derelict.opengl.gl;

class TextureShader : Shader
{
  const char[] fshader = "
uniform vec4      Color;
uniform sampler2D TextureIn;

void main (void)
{
  gl_FragColor = Color * texture2D(TextureIn, gl_TexCoord[0].xy);         
}
";

  public this()
  {
    super(DEFAULT_VSHADER, fshader);
  }
}

class BlurShader : Shader
{
  const char[] fshader = "
uniform float     Persistence;
uniform sampler2D TextureIn;
// uniform vec4      Color;

uniform float coefficients[5];
uniform vec2 offsets[5];

void main(void)
{
    float d = 0.1;
    vec4 c = vec4(0, 0, 0, 0);
    vec2 tc = gl_TexCoord[0].st;

    c += coefficients[0] * texture2D(TextureIn, tc + offsets[0]);
    c += coefficients[1] * texture2D(TextureIn, tc + offsets[1]);
    c += coefficients[2] * texture2D(TextureIn, tc + offsets[2]);
    c += coefficients[3] * texture2D(TextureIn, tc + offsets[3]);
    c += coefficients[4] * texture2D(TextureIn, tc + offsets[4]);

    gl_FragColor = c * Persistence;
}
";

  public this()
  {
    super(DEFAULT_VSHADER, fshader);
  }
}

class Shader
{
  GLuint _prog;
  GLuint prog() { return _prog; }

  bool _b_bound;

  protected const char[] DEFAULT_VSHADER = "
void main(void)
{
    gl_TexCoord[0] = gl_MultiTexCoord0;
    gl_Position    = ftransform();
}
";


  public this(char[] verts, char[] frags)
  out
  {
    assert(_prog);
  }
  body
  {
    GLchar buf[256];
    GLuint vertShader, fragShader, program;
    GLint success;

    char* vertz = toStringz(verts);
    char* fragz = toStringz(frags);

    vertShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertShader, 1, cast(GLchar**) &vertz, null);
    glCompileShader(vertShader);
    glGetShaderiv(vertShader, GL_COMPILE_STATUS, &success);
    if (!success)
    {
        glGetShaderInfoLog(vertShader, buf.length, null, buf.ptr);
        Logger.instance.message(buf);
        throw new Error("Unable to compile vertex shader.\n");
    }

    fragShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragShader, 1, cast(GLchar**) &fragz, null);
    glCompileShader(fragShader);
    glGetShaderiv(fragShader, GL_COMPILE_STATUS, &success);
    if (!success)
    {
        glGetShaderInfoLog(fragShader, buf.length, null, buf.ptr);
        Logger.instance.message(buf);
        throw new Error("Unable to compile fragment shader.\n");
    }

    program = glCreateProgram();
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);

    glLinkProgram(program);
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (!success)
    {
        glGetProgramInfoLog(program, buf.length, null, buf.ptr);
        Logger.instance.message(buf);
        throw new Error("Unable to link shaders.\n");
    }
    else
    {
        Logger.instance.message("Compiled shader");
    }

    _prog = program;
    _b_bound = false;
  }

  public void bind()
  {
    glUseProgram(_prog);
    _b_bound = true;
  }

  public void unbind()
  {
    glUseProgram(0);
    _b_bound = false;
  }

  public GLint getUniformLocation(char* name)
  {
    return glGetUniformLocation(_prog, name);
  }

  //  Assign an int uniform
  public void opIndexAssign(int v, char* key)
  in
  {
    assert(_b_bound == true);
  }
  body
  {
    GLint loc = getUniformLocation(key);
    glUniform1i(loc, v);
  }

  //  Assign a single float uniform
  public void opIndexAssign(float v, char* key)
  in
  {
    assert(_b_bound == true);
  }
  body
  {
    GLint loc = getUniformLocation(key);
    glUniform1f(loc, v);
  }

  //  Assign a 4 component vector uniform
  public void opIndexAssign(Vector v, char* key)
  in
  {
    assert(_b_bound == true);
  }
  body
  {
    // GLchar* name = toStringz(key);
    GLint loc = getUniformLocation(key);
    assert(loc != -1);
    glUniform4f(loc, v.x, v.y, v.z, v.w);
  }

  //  Bind and assign a texture as a uniform sampler
  public void opIndexAssign(Texture tex, char* key)
  in
  {
    assert(_b_bound == true);
  }
  body
  {
    tex.bind();
    GLint loc = getUniformLocation(key);
    glUniform1i(loc, 0);
  }

  //  Assign a uniform floating point array
  public void opIndexAssign(float[] f, char* key)
  in
  {
    assert(_b_bound == true);
    assert(_prog);
  }
  body
  {
    GLint loc = getUniformLocation(key);
    assert(loc != -1);
    glUniform1fv(loc, f.length, f.ptr);
  }

  public void setUniform2fv(char* key, float[] fv)
  in
  {
    assert(_b_bound == true);
    assert(_prog);
  }
  body
  {
    GLint loc = getUniformLocation(key);
    assert(loc != -1);
    glUniform2fv(loc, fv.length / 2, fv.ptr);
  }

  void checkError()
  {
    GLenum err;

    do
    {
      err = glGetError();
      if (err == GL_INVALID_VALUE)
        Logger.instance.message("error: GL_INVALID_VALUE");
      else if (err == GL_INVALID_OPERATION)
        Logger.instance.message("error: GL_INVALID_OPERATION");
      else
        Logger.instance.message(format("error: %d", cast(int) err));
    } while (err != GL_NO_ERROR);
  }
}

