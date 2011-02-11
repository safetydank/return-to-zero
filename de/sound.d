/*  Adapted from Kenta Cho's sound manager class  
 *  Copyright 2005 Kenta Cho. Some rights reserved.
 */

import derelict.sdl.sdl;
import derelict.sdl.mixer;

import de.resourcecache;
import core.logger;
import core.rand;

class SoundManager
{
  static
  {
    bool b_init = false;
    ResourceCache!(Wave) _waves;
    ResourceCache!(Music) _music;
    bit[char[]] seMark;
    bool bgmDisabled = false;
    bool seDisabled = false;

    const int RANDOM_BGM_START_INDEX = 1;
    Rand rand;
    char[][] bgmFileName;
    char[] currentBgm;
    int prevBgmIdx;
    int nextIdxMv;
  }

  public static void init(ResourceCache!(Wave) waves, ResourceCache!(Music) music)
  {
    Logger.instance.message("Initialized sound manager");
    rand = new Rand;
    _waves = waves;
    _music = music;

    b_init = true;
  }

  public static void setRandSeed(long seed) 
  {
    rand.setSeed(seed);
  }

  public static void playBgm(char[] name) {
    currentBgm = name;
    if (bgmDisabled)
      return;
    Music.haltMusic();
    _music[name].play();
  }

//  public static void playBgm() {
//    int bgmIdx = rand.nextInt(bgm.length - RANDOM_BGM_START_INDEX) + RANDOM_BGM_START_INDEX;
//    nextIdxMv = rand.nextInt(2) * 2 - 1;
//    prevBgmIdx = bgmIdx;
//    playBgm(bgmFileName[bgmIdx]);
//  }
//
//  public static void nextBgm() {
//    int bgmIdx = prevBgmIdx + nextIdxMv;
//    if (bgmIdx < RANDOM_BGM_START_INDEX)
//      bgmIdx = bgm.length - 1;
//    else if (bgmIdx >= bgm.length)
//        bgmIdx = RANDOM_BGM_START_INDEX;
//    prevBgmIdx = bgmIdx;
//    playBgm(bgmFileName[bgmIdx]);
//  }
//
//  public static void playCurrentBgm() {
//    playBgm(currentBgm);
//  }
//
  public static void fadeBgm() {
    Music.fadeMusic();
  }

  public static void haltBgm() {
    Music.haltMusic();
  }

  public static void playSe(char[] name) {
    if (seDisabled)
      return;
    seMark[name] = true;
  }

  public static void playMarkedSe() {
    char[][] keys = seMark.keys;
    foreach (char[] key; keys) {
      if (seMark[key]) {
        _waves[key].play();
        seMark[key] = false;
      }
    }
  }

  public static void disableSe() {
    seDisabled = true;
  }

  public static void enableSe() {
    seDisabled = false;
  }

  public static void disableBgm() {
    bgmDisabled = true;
  }

  public static void enableBgm() {
    bgmDisabled = false;
  }
}

/**
 * Initialize and close SDL_mixer.
 */
class SoundMixer 
{
  public static bool noSound = false;

  public static void init() 
  {
    if (noSound)
      return;

    int    audioRate = 44100;
    Uint16 audioFormat = AUDIO_S16;
    int    audioChannels = 2;
    int    audioBuffers = 4096;

    if (SDL_InitSubSystem(SDL_INIT_AUDIO) < 0) 
    {
      noSound = true;
      return;
      throw new Error
        ("Unable to initialize SDL_AUDIO: " ~ std.string.toString(SDL_GetError()));
    }

    if (Mix_OpenAudio(audioRate, audioFormat, audioChannels, audioBuffers) < 0) 
    {
      noSound = true;
      return; 
      throw new Error
        ("Couldn't open audio: " ~ std.string.toString(SDL_GetError()));
    }
    else
      Mix_QuerySpec(&audioRate, &audioFormat, &audioChannels);

    Logger.instance.message("Initialized sound manager");
  }

  public static void close() 
  {
    if (noSound)
      return;

    if (Mix_PlayingMusic())
      Mix_HaltMusic();

    Mix_CloseAudio();
  }

  public static void channelVolume(int ch, float vol)
  {
    Mix_Volume(ch, cast(int) (vol * MIX_MAX_VOLUME));
  }
}

/**
 * Music / Wave.
 */
public interface Sound 
{
  public void load(char[] name);
  public void load(char[] name, int ch);
  public void free();
  public void play();
  public void fade();
  public void halt();
}

class Music: Sound 
{
  public:
    static int fadeOutSpeed = 1280;
    static char[] dir = "../sounds";

    public static Music create(char[] name)
    {
      Music m = new Music();
      m.load(name);;
      return m;
    }

  private:
    Mix_Music* music;

    public void load(char[] name) 
    {
      if (SoundMixer.noSound)
        return;

      char[] fileName = dir ~ "/" ~ name;
      music = Mix_LoadMUS(std.string.toStringz(fileName));
      if (!music) 
      {
        SoundMixer.noSound = true;
        return;
        throw new Error("Couldn't load: " ~ fileName ~ 
            " (" ~ std.string.toString(Mix_GetError()) ~ ")");
      }
    }

    public void load(char[] name, int ch) 
    {
      load(name);
    }

    public void free() 
    {
      if (music) {
        halt();
        Mix_FreeMusic(music);
      }
    }

    public void play() 
    {
      if (SoundMixer.noSound)
        return;
      Mix_PlayMusic(music, -1);
    }

    public void playOnce() 
    {
      if (SoundMixer.noSound)
        return;

      Mix_PlayMusic(music, 1);
    }

    public void fade() {
      Music.fadeMusic();
    }

    public void halt() {
      Music.haltMusic();
    }

    public static void fadeMusic() 
    {
      if (SoundMixer.noSound)
        return;

      Mix_FadeOutMusic(fadeOutSpeed);
    }

    public static void haltMusic() 
    {
      if (SoundMixer.noSound)
        return;

      if (Mix_PlayingMusic())
        Mix_HaltMusic();
    }
}

class Wave : Sound 
{
  public static char[] dir = "../sounds";
  private Mix_Chunk* chunk;
  private int chunkChannel;

  public static Wave create(char[] name, int ch = 0)
  {
    Wave w = new Wave();
    w.load(name, ch);
    return w;
  }

  public void load(char[] name) 
  {
    load(name, 0);
  }

  public void load(char[] name, int ch) 
  {
    if (SoundMixer.noSound)
      return;

    char[] fileName = dir ~ "/" ~ name;
    chunk = Mix_LoadWAV(fileName);
    if (!chunk) 
    {
      SoundMixer.noSound = true;
      return;
      throw new Error("Couldn't load: " ~ fileName ~ 
          " (" ~ std.string.toString(Mix_GetError()) ~ ")");
    }
    chunkChannel = ch;
  }

  public void free() 
  {
    if (chunk) {
      halt();
      Mix_FreeChunk(chunk);
    }
  }

  public void play() 
  {
    if (SoundMixer.noSound)
      return;

    Mix_PlayChannel(chunkChannel, chunk, 0);
  }

  public void halt() 
  {
    if (SoundMixer.noSound)
      return;

    Mix_HaltChannel(chunkChannel);
  }

  public void fade() 
  {
    halt();
  }
}

