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
module derelict.sdl.cpuinfo;

private import derelict.sdl.types;

extern(C):

typedef SDL_bool function() pfSDL_HasRDTSC;
typedef SDL_bool function() pfSDL_HasMMX;
typedef SDL_bool function() pfSDL_HasMMXExt;
typedef SDL_bool function() pfSDL_Has3DNow;
typedef SDL_bool function() pfSDL_Has3DNowExt;
typedef SDL_bool function() pfSDL_HasSSE;
typedef SDL_bool function() pfSDL_HasSSE2;
typedef SDL_bool function() pfSDL_HasAltiVec;
pfSDL_HasRDTSC          SDL_HasRDTSC;
pfSDL_HasMMX            SDL_HasMMX;
pfSDL_HasMMXExt         SDL_HasMMXExt;
pfSDL_Has3DNow          SDL_Has3DNow;
pfSDL_Has3DNowExt       SDL_Has3DNowExt;
pfSDL_HasSSE            SDL_HasSSE;
pfSDL_HasSSE2           SDL_HasSSE2;
pfSDL_HasAltiVec        SDL_HasAltiVec;