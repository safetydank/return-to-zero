module game.score;

import core.util;
import core.logger;

import std.string;
import de.texture;
import de.vertexbuffer;
import de.vertex;
import de.text;
import de.math;

import derelict.opengl.gl;

import game.ship;

//  Fade-in score renderer
class Score
{
  ulong  _score;

  float _fadeTime;
  float _elapsed;

  Texture _fontTexture;
  TextLineRenderer _textRenderer;
  VertexBuffer!(BasicVertex) _vb_old;
  VertexBuffer!(BasicVertex) _vb_new;
  Vector _textColor;

  float _fadeRatio;

  bool _b_updated;
  Ship _ship;

  public this(Texture fontTexture, Ship ship, float fadeTime = 0.3)
  {
    _fadeTime = fadeTime;
    _elapsed = 0;

    _fontTexture = fontTexture;
    _vb_old = TextLineRenderer.createTextBuffer();
    _vb_new = TextLineRenderer.createTextBuffer();
    _textRenderer = new TextLineRenderer(_fontTexture, 16);
    _textRenderer.charWidth = 1.4f;
    _textColor = Vector.create(1,1,1,1);

    _ship = ship;
    reset();
  }

  public void reset()
  {
    _score = 0;
    _textRenderer.renderString("3/0", _vb_old);
    _textRenderer.renderString("3/0", _vb_new);
  }

  public void add(int points)
  {
    _score += points;
  }

  private void startRender()
  {
    static int oldScore = 0;

    swap(_vb_old, _vb_new);
    _textRenderer.renderString(format("%d/%d", _ship.wickets, _score), _vb_new);
    _elapsed = 0;
    _b_updated = (oldScore != _score);

    oldScore = _score;
  }

  public void move(float elapsed)
  {
    _elapsed += elapsed;

    if (_elapsed > _fadeTime)
      startRender();

    _fadeRatio = _elapsed / _fadeTime;
  }

  public void draw()
  {
    // glBlendFunc(GL_SRC_ALPHA, GL_ONE);

    _textRenderer.bind();
    if (_b_updated)
    {
      glColor4f(1.0, 1.0, 1.0, _fadeRatio);
      _vb_new.drawBatch();
      glColor4f(1.0, 1.0, 1.0, 1-_fadeRatio);
      _vb_old.drawBatch();
    }
    else
    {
      glColor4f(1.0, 1.0, 1.0, 1.0);
      _vb_old.drawBatch();
    }
    _textRenderer.unbind();
    glColor4f(1., 1., 1., 1.);

    // glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  }
}
