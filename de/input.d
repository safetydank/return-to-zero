import derelict.sdl.sdl;

/**
 * Input device interface.
 */
public interface Input 
{
  public void handleEvent(SDL_Event *event);
}

class MultipleInputDevice: Input 
{
 public:
  Input[] inputs;

  public void handleEvent(SDL_Event *event) {
    foreach (Input i; inputs)
      i.handleEvent(event);
  }
}

