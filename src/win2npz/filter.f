c.......10........20........30........40........50........60........70........80
c+	******************************************************************
c	**			filter.f				**
c	**								**
c	**	Subroutine package for filter				**
c	**		91-10-08	ver.0.0		by T.Matsuzawa	**
c	**		91-10-09	ver.0.1				**
c	**--------------------------------------------------------------**
c	** Object:	Filter						**
c	**--------------------------------------------------------------**
c	** Messages:							**
c	**	ButLoP	(FHiCut, NOrder, SampF)				**
c	**			Set Butterworth low-pass filter		**
c	**	ButBp 	(FLoCut, FHiCut, NOrder, SampF)			**
c	**			Set Butterworth band-pass filter	**
c	**	   Note: ButBp does not function completely !!		**
c	**								**
c	**	Respon	(FMin, FMax, DFreq, Amp, Phase)			**
c	**			Calculate the response of filter	**
c	**	Calc	(OrgDat, NData, IDirec, FilOut)			**
c	**			Calculate the output of the filter	**
c	**	Param	(Itype, Flow, Fhigh, Norder, Sampf)		**
c	**			Get filter parameter			**
c	**--------------------------------------------------------------**
c	** Arguments:							**
c	**	ButLop							**
c	**	    [INPUT]						**
c	**		FHiCut		Cut off freq. (higher)	[R*4]	**
c	**		NOrder		Order of the filter	[I*4]	**
c	**		SampF		Sampling freq. of data	[I*4]	**
c	**	ButBp							**
c	**	    [INPUT]						**
c	**		FLoCut		Cut off freq. (lower)	[R*4]	**
c	**		FHiCut		Cut off freq. (higher)	[R*4]	**
c	**		NOrder		Order of the filter	[I*4]	**
c	**		SampF		Sampling freq. of data	[I*4]	**
c	**	Respon							**
c	**	    [INPUT]						**
c	**		FMin		Minimum frequency	[R*4]	**
c	**		FMax		Maximum frequency	[R*4]	**
c	**		DFreq		Increment of frequency	[R*4]	**
c	**	    [INPUT & OUTPUT]					**
c	**		NFreq		Sample no. 		[R*4]	**
c	**	    [OUTPUT]						**
c	**		Amp()		Amplitude		[R*4]	**
c	**		Phase()		Phase (deg)		[R*4]	**
c	**	Calc							**
c	**	    [INPUT]						**
c	**		OrgDat()	Original data		[R*4]	**
c	**		NData		Total amount of data	[I*4]	**
c	**		IDirec		1:forward, -1:backward	[I*4]	**
c	**	    [OUTPUT]						**
c	**		FIlOut()	Filter output		[R*4]	**
c	**--------------------------------------------------------------**
c	** External files and/or lib. necessary to run this routine:	**
c	**	filter.inc libsaito.a					**
c	**--------------------------------------------------------------**
c	** Note:							**
c	**	This routine uses Saito's recursive filter.		**
c-	******************************************************************

	subroutine	Filter_ButLoP (FHiCut, NOrder, SampF)

	include		'filter.inc'
c		* Common variables to use
c				[write]		hfil_c(), mfil_c, gn_c, dt_c
c		* Subroutines to use		ButLop

	real*4		FHiCut, SampF
	integer*4	NOrder

c	* Local variables
	integer*4	nfil
	real*4		fp, fs, ap, as, raito

c	------------------------------------------------------------------
	flow_c	= 0.
	fhigh_c	= FHiCut
	norder_c= NOrder
	if (NOrder.le.0.) then
	    gn_c	= 0.
	    dt_c	= 0.
	    mfil_c	= 0
c;;;	    write (*,*)	' No filter '
	    return
	endif

	raito	= 1.3
	dt_c	= 1./SampF
	fp	= FHiCut*dt_c
	fs	= fp*raito
	ap	= 1.
	as	= raito**NOrder

	call	ButLop (hfil_c, mfil_c, gn_c, nfil, fp, fs, ap, as)
	norder_c= nfil

ctig	write (*,*)	' G0	= ', gn_c
ctig	write (*,*)	' NFil	= ', nfil
ctig	write (*,*)	' FP	= ', FHiCut
ctig	write (*,*)	' FS	= ', FHiCut*raito
ctig	write (*,*)	' AP	= ', ap
ctig	write (*,*)	' AS	= ', as
ctig	write (*,*)	' dt_c	= ', dt_c
ctig	write (*,*)	' Coefficients'
ctig	write (*,'(i5,2x,1p4e15.6)')
ctig     &			(i,hfil_c(i*4-3),hfil_c(i*4-2),hfil_c(i*4-1),
ctig     &			hfil_c(i*4),i=1,mfil_c)
	return
	end

c**************************************************************
	subroutine	Filter_ButBp (FLoCut, FHiCut, NOrder, SampF)

	include		'filter.inc'
c		* Common variables to use
c				[write]		hfil_c(), mfil_c, gn_c, dt_c
c		* Subroutines to use		ButPas

	real*4		FLoCut, FHiCut, SampF
	integer*4	NOrder

c	* Local variables
	integer*4	nfil
	real*4		fl, fh, fs, ap, as, raito

c	------------------------------------------------------------------
	flow_c	= FLoCut
	fhigh_c	= FHiCut
	norder_c= NOrder
	if (NOrder.le.0.) then
	    gn_c	= 0.
	    dt_c	= 0.
	    mfil_c	= 0
c;;;	    write (*,*)	' No filter '
	    return
	endif

	raito	= 1.3
	dt_c	= 1./SampF
	fl	= FLoCut*dt_c
	fh	= FHiCut*dt_c
	fs	= fh*raito
	ap	= 1.
	as	= raito**NOrder

	call	ButPas (hfil_c, mfil_c, gn_c, nfil, fl, fh, fs, ap, as)
	norder_c= nfil

ctig	write (*,*)	' G0	= ', gn_c
ctig	write (*,*)	' NFil	= ', nfil
ctig	write (*,*)	' FL	= ', FLoCut
ctig	write (*,*)	' FH	= ', FHiCut
ctig	write (*,*)	' FS	= ', FHiCut*raito
ctig	write (*,*)	' AP	= ', ap
ctig	write (*,*)	' AS	= ', as
ctig	write (*,*)	' dt_c	= ', dt_c
ctig	write (*,*)	' Coefficients'
ctig	write (*,'(i5,2x,1p4e15.6)')
ctig     &			(i,hfil_c(i*4-3),hfil_c(i*4-2),hfil_c(i*4-1),
ctig     &			hfil_c(i*4),i=1,mfil_c)
	return
	end

c==============================================================
	subroutine	Filter_ButLoPnm (FHiCut, NOrder, SampF)
c no message version
	include		'filter.inc'
c		* Common variables to use
c				[write]		hfil_c(), mfil_c, gn_c, dt_c
c		* Subroutines to use		ButLop

	real*4		FHiCut, SampF
	integer*4	NOrder

c	* Local variables
	integer*4	nfil
	real*4		fp, fs, ap, as, raito

c	------------------------------------------------------------------
	flow_c	= 0.
	fhigh_c	= FHiCut
	norder_c= NOrder
	if (NOrder.le.0.) then
	    gn_c	= 0.
	    dt_c	= 0.
	    mfil_c	= 0
	    return
	endif

	raito	= 1.3
	dt_c	= 1./SampF
	fp	= FHiCut*dt_c
	fs	= fp*raito
	ap	= 1.
	as	= raito**NOrder

	call	ButLop (hfil_c, mfil_c, gn_c, nfil, fp, fs, ap, as)
	norder_c= nfil

	return
	end

c**************************************************************
	subroutine	Filter_ButBpnm (FLoCut, FHiCut, NOrder, SampF)
c no message version
	include		'filter.inc'
c		* Common variables to use
c				[write]		hfil_c(), mfil_c, gn_c, dt_c
c		* Subroutines to use		ButPas

	real*4		FHiCut, SampF
	integer*4	NOrder

c	* Local variables
	integer*4	nfil
	real*4		fl, fh, fs, ap, as, raito

c	------------------------------------------------------------------
	flow_c	= FLoCut
	fhigh_c	= FHiCut
	norder_c= NOrder
	if (NOrder.le.0.) then
	    gn_c	= 0.
	    dt_c	= 0.
	    mfil_c	= 0
	    return
	endif

	raito	= 1.3
	dt_c	= 1./SampF
	fl	= FLoCut*dt_c
	fh	= FHiCut*dt_c
	fs	= fh*raito
	ap	= 1.
	as	= raito**NOrder

	call	ButPas (hfil_c, mfil_c, gn_c, nfil, fl, fh, fs, ap, as)
	norder_c= nfil

	return
	end

c	******************************************************************	
	subroutine	Filter_Respon	(FMin, FMax, DFreq, NFreq, 
     &						Amp, Phase)

	include		'filter.inc'
c		* Common variables to use
c				[read]		hfil_c(), mfil_c, gn_c, dt_c
c		* Subroutines to use		RecRes

	real*4		FMin, FMax, DFreq, Amp(*), Phase(*)
	integer*4	NFreq

c	*** Local variables ***
	real*4		todeg
	integer*4	ndum

c	------------------------------------------------------------------
	todeg	= 180./3.14159265
	ndum	= (FMax - FMin)/DFreq + 1.5
	if (ndum.lt.NFreq)	NFreq	= ndum

	call	RecRes (hfil_c, mfil_c, gn_c, FMin*dt_c, DFreq*dt_c, 
     &		Amp, Phase, NFreq)

	do 10 i = 1, NFreq
	    Amp(i)	= sqrt (Amp(i))
	    Phase(i)	= Phase(i)*todeg
   10	continue
	
	return
	end

c	******************************************************************	
	subroutine	Filter_Calc (OrgDat, NData, IDirec, FilOut)

	include		'filter.inc'
c		* Common variables to use
c				[read]		hfil_c(), mfil_c, gn_c
c		* Subroutines to use		TanDem

	integer*4	NData, IDirec
	real*4		OrgDat(*), FilOut(*)

c	------------------------------------------------

	if (mfil_c.eq.0) then		! No filter
	    do i = 1, NData
		FilOut(i)	= OrgDat(i)
	    enddo
	    return
	endif

	call	TanDem (OrgDat, FilOut, NData, hfil_c, mfil_c, IDirec)

	do 10 i = 1, NData
	    FilOut(i)	= FilOut(i)*gn_c
   10	continue

	return
	end

c==============================================================
	subroutine filter_param	(Itype, Flow, Fhigh, Norder, Sampf)
c output
	integer	Itype			! type of filter (dummy now)
	real*4	Flow			! low cut freq.
	real*4	Fhigh			! high cut freq.
	integer	Norder			! order of filter
	real	Sampf			! sampling freq.
c--------------------------------------------------------------
	include 'filter.inc'
c--------------------------------------------------------------
	Itype	= 1
	Flow	= flow_c
	Fhigh	= fhigh_c
	Norder	= norder_c
	if (dt_c.gt.0.) then
	    Sampf	= 1./dt_c
	else
	    Sampf	= 0.
	endif
	return
	end
