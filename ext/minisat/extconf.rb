require 'mkmf'

CONFIG["CXX"] ||= "g++"

system_minisat = have_library("minisat")
if system_minisat
  # dirty hack for mkmf
  with_cflags("-x c++") do
    system_minisat &&= have_header("minisat/core/Solver.h")
    false
  end
end
$defs << "-D __STDC_LIMIT_MACROS" << "-D __STDC_FORMAT_MACROS"

unless system_minisat
  # use bundled minisat
  MINISAT_DIR = File.join(File.dirname(__FILE__), "../../minisat/minisat/")

  minisat_include, _ = dir_config("minisat", MINISAT_DIR, "")
  $objs = ["minisat.o", "minisat-wrap.o", minisat_include + "core/Solver.o"]
end

# Specify static linkage of C++ library for MinGW
old_libs = $libs
raise unless have_library("stdc++")
if RbConfig::CONFIG['host_os'] =~ /mingw/
  $libs = old_libs + ' -Wl,-dn,-lstdc++'
end
create_makefile("minisat")
