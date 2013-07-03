#include "ruby.h"


/* @api private */
static VALUE plat_is_apple(VALUE self)
{
  #if defined(__APPLE__)
  return Qtrue;
  #else
  return Qfalse;
  #endif
}


/* @api private */
static VALUE plat_is_windows(VALUE self)
{
  #if defined(_WIN32) || defined(__MINGW32__) || defined(__CYGWIN__)
  return Qtrue;
  #else
  return Qfalse;
  #endif
}


/* @api private */
static VALUE plat_is_unix(VALUE self)
{
  #if defined(__unix) || defined(__unix__) || defined(unix) || defined(__APPLE__)
  return Qtrue;
  #else
  return Qfalse;
  #endif
}


/* @api private */
static VALUE plat_is_linux(VALUE self)
{
  #if defined(__linux__) || defined(linux) || defined(__linux)
  return Qtrue;
  #else
  return Qfalse;
  #endif
}


void Init_opengl_stub(void)
{
  VALUE module = rb_define_module("GlSym");
  rb_define_singleton_method(module, "apple?", plat_is_apple, 0);
  rb_define_singleton_method(module, "windows?", plat_is_windows, 0);
  rb_define_singleton_method(module, "unix?", plat_is_unix, 0);
  rb_define_singleton_method(module, "linux?", plat_is_linux, 0);
}
