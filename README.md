opengl-core
===========

OpenGL core profile and extension bindings for Ruby 2.x.


Installation
------------

### From RubyGems.org

    $ gem install opengl-core

And in your script:

    require 'opengl-core'

Job done, have fun. If you're a bad person and don't install your gems per
user, you may need to throw a `sudo` in there.


### From Source

Installing from source is a bit involved just because you need to generate the
OpenGL bindings before using them. To do this, simply clone the repository and
navigate to its root directory in a terminal. Once there, run `gen_from_xml.rb`:

    $ ./gen_from_xml.rb

This will pull down the Khronos GL XML spec files and proceed to generate the
appropriate OpenGL function bindings for the OpenGL core profile (3.2 and up,
no deprecated functions). If you'd like to generate bindings for non-core
functions, open `gen_from_xml.rb` in your text editor and change the
`GEN_GL3_AND_UP` constant's value to `false`. Attempting to use functions that
don't exist for a given context will result in errors, so keep that in mind.

Once the functions have been generated, you can proceed to build and install
the gem as per usual:

    $ gem build opengl-core.gemspec
    $ gem install opengl-core-1.0.0.gem

Afterward, all GL enums and commands will be under the `Gl` module (note the
lowercase L). Just `require 'opengl-core'` and you should be on your way. You
don't have to statically link to the GL libraries, they will be loaded at
runtime on first use.


Notes
-----

Your system's GL library and functions are loaded on a first-use basis, so the
first time you call `glClear`, the function will be loaded. This may change in
the future, but it's worth being aware of it. Later down the road I'll probably
add a function to load all possible GL symbols.

Bear in mind, also, that the GL commands are currently all just providing more
or less the same functionality they would in C or C++. This means that they do
expect pointers and such. You can allocate these using `Fiddle::Pointer.malloc`
and so on. _However_, in addition to this, each GL function is an alias of its
raw function. So, in the module, you have both `glClear` and `glClear__`, the
latter being the raw function and the former being a wrapper around it that
can be overridden.

I'd like to get some of these functions simplified down the road through an
optional module that can be loaded to override the functions, so the plan is to
slowly write friendlier functions that call into the raw functions. If you'd
like to contribute to this effort, please do so. Just push your changes to
GitHub and submit a pull request, or send me a patch with a cogent description
of the changes. Yes, I used the word "cogent."


License
-------

The OpenGL bindings are licensed under a simplified BSD license. This is to
keep things simple for the both of us, but if you need it simpler, just contact
me and we'll work something out.

    Copyright (c) 2013 - 2014, opengl-core project contributors.
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this
       list of conditions and the following disclaimer. 
    2. Redistributions in binary form must reproduce the above copyright notice,
       this list of conditions and the following disclaimer in the documentation
       and/or other materials provided with the distribution. 

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
    ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
