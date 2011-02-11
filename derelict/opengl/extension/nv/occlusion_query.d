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
 * * Neither the names 'Derelict', 'DerelictGL', nor the names of its contributors
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
module derelict.opengl.extension.nv.occlusion_query;

private
{
    import derelict.opengl.gltypes;
    import derelict.opengl.gl;
    import derelict.opengl.extension.loader;
    import derelict.util.wrapper;
}

private bool enabled = false;

struct NVOcclusionQuery
{
    static bool load(char[] extString)
    {
        if(extString.findStr("GL_NV_occlusion_query") == -1)
            return false;

        if(!glBindExtFunc(cast(void**)&glGenOcclusionQueriesNV, "glGenOcclusionQueriesNV"))
            return false;
        if(!glBindExtFunc(cast(void**)&glDeleteOcclusionQueriesNV, "glDeleteOcclusionQueriesNV"))
            return false;
        if(!glBindExtFunc(cast(void**)&glIsOcclusionQueryNV, "glIsOcclusionQueryNV"))
            return false;
        if(!glBindExtFunc(cast(void**)&glBeginOcclusionQueryNV, "glBeginOcclusionQueryNV"))
            return false;
        if(!glBindExtFunc(cast(void**)&glEndOcclusionQueryNV, "glEndOcclusionQueryNV"))
            return false;
        if(!glBindExtFunc(cast(void**)&glGetOcclusionQueryivNV, "glGetOcclusionQueryivNV"))
            return false;
        if(!glBindExtFunc(cast(void**)&glGetOcclusionQueryuivNV, "glGetOcclusionQueryuivNV"))
            return false;

        enabled = true;
        return true;
    }

    static bool isEnabled()
    {
        return enabled;
    }
}

version(DerelictGL_NoExtensionLoaders)
{
}
else
{
    static this()
    {
        DerelictGL.registerExtensionLoader(&NVOcclusionQuery.load);
    }
}

enum : GLenum
{
    GL_QUERY_COUNTER_BITS_ARB         = 0x8864,
    GL_CURRENT_QUERY_ARB              = 0x8865,
    GL_QUERY_RESULT_ARB               = 0x8866,
    GL_QUERY_RESULT_AVAILABLE_ARB     = 0x8867,
    GL_SAMPLES_PASSED_ARB             = 0x8914,
}

extern(System):

typedef void function(GLsizei, GLuint*) pfglGenOcclusionQueriesNV;
typedef void function(GLsizei, GLuint*) pfglDeleteOcclusionQueriesNV;
typedef GLboolean function(GLuint) pfglIsOcclusionQueryNV;
typedef void function(GLuint) pfglBeginOcclusionQueryNV;
typedef void function() pfglEndOcclusionQueryNV;
typedef void function(GLuint, GLenum, GLint*) pfglGetOcclusionQueryivNV;
typedef void function(GLuint, GLenum, GLuint*) pfglGetOcclusionQueryuivNV;
pfglGenOcclusionQueriesNV           glGenOcclusionQueriesNV;
pfglDeleteOcclusionQueriesNV        glDeleteOcclusionQueriesNV;
pfglIsOcclusionQueryNV              glIsOcclusionQueryNV;
pfglBeginOcclusionQueryNV           glBeginOcclusionQueryNV;
pfglEndOcclusionQueryNV             glEndOcclusionQueryNV;
pfglGetOcclusionQueryivNV           glGetOcclusionQueryivNV;
pfglGetOcclusionQueryuivNV          glGetOcclusionQueryuivNV;
