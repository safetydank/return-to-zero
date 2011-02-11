/*
 * Copyright (c) 2004-2006 Derelict Developers
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * * Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 *
 * * Neither the names 'Derelict', 'DerelictSDL', nor the names of its contributors
 *   may be used to endorse or promote products derived from this software
 *   without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
module derelict.sdl.syswm;

private import derelict.sdl.sdlversion;

version(linux)
{
	version = Nix;
}
else version(Unix)
{
	version = Nix;
}

//==============================================================================
// TYPES
//==============================================================================
version(Windows)
{
    import derelict.util.wintypes;

    struct SDL_SysWMmsg
    {
        // this is named 'version' in SDL_syswm.h, but since version is a keyword
        // it 'ver' will have to do
        SDL_version ver;
        HWND hwnd;
        UINT msg;
        WPARAM wParam;
        LPARAM lParam;
    }

    struct SDL_SysWMinfo
    {
        // this is named 'version' in SDL_syswm.h, but since version is a keyword
        // it 'ver' will have to do
        SDL_version ver;
        HWND window;
        HGLRC hglrc;
    }
}

version(Nix)
{
    struct SDL_SysWMmsg;
    struct SDL_SysWMinfo;
}

//==============================================================================
// FUNCTIONS
//==============================================================================
extern(C):

typedef int function(SDL_SysWMinfo*) pfSDL_GetWMInfo;
pfSDL_GetWMInfo         SDL_GetWMInfo;