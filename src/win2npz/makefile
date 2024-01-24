## Makefile for win package
##
## @copyright
## Copyright (c) 2019 Takuto Maeda. All rights reserved. 
##
## @license 
## This software is released under the MIT license. See LICENSE for details. 

FC = /usr/local/bin/gfortran
#FC = /usr/bin/gfortran
#FC = gfortran
FFLAGS = -pthread -ffast-math -Ofast -march=native
#FFLAGS = -fbounds-check -fbacktrace -O0
all: ./win2npz.x

.SUFFIXES: 
.SUFFIXES: .f90 .o .F90 .f

.f90.o:
	$(FC) -c $(FFLAGS) $<
.F90.o:
	$(FC) -c $(FFLAGS) $<
.f.o:
	$(FC) -c $(FFLAGS) $<

win2npz.o: win2npz.f90 m_win.o m_getopt.o endian_swap.o npy.o m_winch.o filter.o filter1.o saito.o rmv_offset.o

#fwin2sac.o: fwin2sac.f90 m_win.o m_getopt.o m_system.o m_util.o m_wsac.o m_util.o m_winch.o
#fwck.o: fwck.f90 m_win.o
m_getopt.o: m_getopt.f90 m_system.o
m_winch.o: m_winch.f90 m_win.o
#m_wsac.o: m_wsac.f90 m_util.o
m_win.o: m_win.f90 m_util.o

#../fchinf.x: fchinf.o m_win.o m_getopt.o m_system.o m_util.o m_winch.o m_util.o
#	$(FC) $(FFLAGS) $^ -o $@

#../fwck.x: fwck.o m_win.o m_util.o
#	$(FC) $(FFLAGS) $^ -o $@

#../fdewin_a.x: fdewin_a.o m_win.o m_getopt.o m_system.o m_util.o
#	$(FC) $(FFLAGS) $^ -o $@

#../fdewin_s.x: fdewin_s.o m_win.o m_getopt.o m_system.o m_util.o
#	$(FC) $(FFLAGS) $^ -o $@

#./fwin2sac.x: fwin2sac.o m_win.o m_getopt.o m_system.o m_util.o m_wsac.o m_util.o m_winch.o
#	$(FC) $(FFLAGS) $^ -o $@

./win2npz.x: win2npz.o m_win.o m_getopt.o m_system.o m_util.o endian_swap.o npy.o m_winch.o filter.o filter1.o saito.o rmv_offset.o
	$(FC) $(FFLAGS) $^ -o $@

clean:
	/bin/rm -f *.mod *.o ./*.x
