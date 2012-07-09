#!/bin/sh

#
# PCI Express Endpoint VCS Run Script
#

/bin/rm *.dat
/bin/rm *.log
/bin/rm vcs.key
/bin/rm -rf simv*
/bin/rm -rf csrc

vcs   +alwaystrigger +v2k +cli \
      -PP \
      -lca \
      +define+VCS \
      +incdir+../.+../../source \
      +incdir+../.+../../example_design \
      -f xilinx_lib_vcs.f \
      -f ../source_rtl.f \
      -f board_rtl_x01.f

if (test -e ./simv); then
  ./simv +TESTNAME=sample_smoke_test0
fi

