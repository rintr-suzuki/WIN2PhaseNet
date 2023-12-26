c.......10........20........30........40........50........60........70........80
c+	******************************************************************
c	**			filter.inc				**
c	**								**
c	**	Parameters and common data for 'filter.f'		**
c	**		91-10-08	ver.0.0		by T.Matsuzawa	**
c	**--------------------------------------------------------------**
c	** Parameters:							**
c	**	NORDMX_C		Max. order of filter		**
c	** Common variables:						**
c	**	hfil_c()		Filter coefficients	[R*4]	**
c	**	mfil_c		Number of elemet filters	[I*4]	**
c	**	gn_c		Gain factor			[R*4]	**
c	**	dt_c		1./(sampling frequency)		[R*4]	**
c	**	flow_c		low cut freq			[R*4]	**
c	**	fhigh_c		high cut freq			[R*4]	**
c	**	norder_c	order of filter			[R*4]	**
c-	******************************************************************

	parameter	(NORDMX_C=50)

	real*4		hfil_c(NORDMX_C), gn_c, dt_c, flow_c, fhigh_c
	integer*4	mfil_c, norder_c

	common	/ Filter_Cmn /	hfil_c, mfil_c, gn_c, dt_c, flow_c, 
     &			fhigh_c, norder_c
