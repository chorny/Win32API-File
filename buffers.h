/* buffers.h -- Version 1.09 */

/* The following abbreviations are used at start of parameter names
 * to indicate the type of data:
 *	s	string (char * or WCHAR *) [PV]
 *	sw	wide string (WCHAR *) [PV]
 *	p	pointer (usually to some structure) [PV]
 *	a	array (packed array as in C) (usually of some structure) [PV]
 *		    called a "vector" or "vect" in some places.
 *	n	generic number [IV, UV, or NV]
 *	iv	signed integral value [IV]
 *	u	unsigned integral value [UV]
 *	d	floating-point number (double) [NV]
 *	b	boolean (bool) [IV]
 *	c	count of items [UV]
 *	l	length (in bytes) [UV]
 *	lw	length in WCHARs [UV]
 *	h	a handle [IV]
 *	r	record (structure) [PV]
 *	sv	Perl scalar (s, i, u, d, n, or rv) [SV]
 *	rv	Perl reference (usually to scalar) [RV]
 *	hv	reference to Perl hash [HV]
 *	av	reference to Perl array [AV]
 *	cv	Perl code reference [PVCV]
 *
 * Unusual combined types:
 *	pp	single pointer (to non-Perl data) packed into string [PV]
 *	pap	vector of pointers (to non-Perl data) packed into string [PV]
 *
 * Whether a parameter is for input data, output data, or both is usually
 * not reflected by the data type prefix.  In cases where this is not
 * obvious nor reflected in the variable name proper, you can use
 * the following in front of the data type prefix:
 *	i	an input parameter given to API (usually omitted)
 *	o	an Output parameter taken from API
 *	io	Input given to API then overwritten with Output taken from API
 */

/* Buffer arguments are usually followed by an argument (or two) specifying
 * their size and/or returning the size of data written.  The size can be
 * measured in bytes ["lSize"] or in characters [for (char *) buffers such as
 * for *A() routines, these sizes are also called "lSize", but are called
 * "lwSize" for (WCHAR *> buffers, UNICODE strings, such as for *W() routines].
 *
 * Before calling the actual C function, you must make sure the Perl variable
 * actually has a big enough buffer allocated, and, if the user didn't want
 * to specify a buffer size, set the buffer size to be correct.  This is what
 * the grow_*() macros are for.  They also handle special meanings of the
 * buffer size argument [described below].
 *
 * Once the actual C function returns, you must set the Perl variable to know
 * the size of the written data.  This is what the trunc_*() macros are for.
 *
 * The size sometimes does and sometimes doesn't include the trailing '\0'
 * [or L'\0'], so we always add or substract 1 in the appropriate places so
 * we don't care about this detail.
 *
 * A call may  1) request a pointer to the buffer size which means that
 * the buffer size will be overwritten with the size of the data written;
 * 2) have an extra argument which is a pointer to the place to write the
 * size of the written data;  3) provide the size of the written data in
 * the function's return value;  or  4) format the data so that the length
 * can be determined by examining the data [such as with '\0'-terminated
 * strings].  This obviously determines what you should use in the trunc_*()
 * macro to specify the size of the output value.
 *
 * The user can pass in an empty list reference, C<[]>, to indicate NULL for
 * the pointer to the buffer which means that they don't want that data.
 *
 * The user can pass in C<[]> or C<0> to indicate that they don't care about
 * the buffer size [we aren't programming in C here, after all] and just try
 * to get the data.  This will work if either the buffer already alloated for
 * the SV [scalar value] is large enough to hold the data or the API provides
 * an easy way to determine the required size.
 *
 * If the user passes in a numeric value for a buffer size, then the XS
 * code makes sure that the buffer is at least large enough to hold a value
 * of that size and then passes in how large the buffer is.  So the buffer
 * size passed to the API call is the larger of the size requested by the
 * user and the size of the buffer aleady allocated to the SV.
 *
 * The user can also pass in a string consisting of a leading "=" followed
 * by digits for a buffer size.  This means just use the size specified after
 * the equals sign, even if the allocated buffer is larger.  The XS code will
 * still allocate a large enough buffer before the first call.
 *
 * If the function is nice enough to tell us that a buffer was too small
 * [usually via ERROR_MORE_DATA] _and_ how large the buffer needs to be,
 * then the XS code should enlarge the buffer(s) and repeat the call [once].
 * This resizing is _not_ done for buffers whose size was specified with a
 * leading "=".
 *
 * Only grow_buf() and perhaps trunc_buf() can be used in a typemap file.
 * The other macros would be used in INPUT or INIT sections.
 *
 * Here is a made-up example that shows several cases:
 *
 * # GetDataW() API actually returns length of value written to sName.
 * bool
 * GetDataW( ioswName, ilwName, oswTxt, olwTxt, opStuff, opRec, ilRec, olRec )
 *	WCHAR *	ioswName
 *	DWORD	ilwName
 *	WCHAR *	oswTxt		= NULL;
 *	DWORD	&olwTxt		= init_buf_l($arg);
 *	void *	opStuff		= NULL;
 *	void *	opRec		= NULL;
 *	DWORD	ilRec
 *	DWORD	&olRec		= init_buf_l($arg);
 * PREINIT:
 *	DWORD	olwName;
 * INIT:
 *	grow_buf_lw( ioswName,ST(0), ilwName,ST(1) );
 *	grow_buf_lw( oswTxt,ST(2), olwTxt,ST(3) );
 *	grow_buf_typ( opStuff,ST(4), REALLY_LONG_STRUCT_TYPEDEF );
 *	grow_buf_l( opRec,ST(5), ilRec,ST(6) );
 * CODE:
 *	olwName= GetDataW( ioswName, ilwName, osTxt, &olwTxt, opStuff,
 *			opRec, ilRec, &olRec );
 *	if(  0 == olwName  &&  ERROR_MORE_DATA == GetLastError()
 *	 &&  ( autosize(ST(3)) || autosize(ST(6)) )  ) {
 *	    grow_buf_lw( osTxt,ST(2), olwTxt,ST(3) );
 *	    if(  autosize(ST(6))  )   ilRec= olRec;
 *	    grow_buf_l( opRec,ST(5), ilRec,ST(6) );
 *	    olwNameOut= GetDataW( ioswName, ilwName, oswTxt, olwTxt, opStuff,
 * 			opRec, ilRec, olRec );
 *	}
 *	RETVAL=  0 != olwNameOut;
 * OUTPUT:
 *	RETVAL
 *	ioswName	trunc_buf_lw( RETVAL, ioswName,ST(0), olwName );
 *	oswTxt		trunc_buf_lw( RETVAL, oswTxt,ST(2), olwTxt );
 *	olwTxt
 *	opStuff	trunc_buf_typ(RETVAL,opStuff,ST(4),REALLY_LONG_STRUCT_TYPEDEF);
 *	opRec		trunc_buf_l( RETVAL, opRec,ST(5), olRec );
 *	olRec
 */

#ifndef Debug
# define	Debug(list)	/*Nothing*/
#endif

/* Is an argument C<[]>, meaning we should pass C<NULL>? */
#define null_arg(sv)	(  SvROK(sv)  &&  SVt_PVAV == SvTYPE(SvRV(sv))	\
			   &&  -1 == av_len((AV*)SvRV(sv))  )

#define PV_or_null(sv)	( null_arg(sv) ? NULL : SvPV(sv,na) )

/* Minimum buffer size to use when no buffer existed: */
#define MIN_GROW_SIZE	64

#ifdef Debug
/* Used in Debug() messages to show which macro call is involved: */
#define string(arg) #arg
#endif

/* Simplify using SvGROW() for byte-sized buffers: */
#define lSvGROW(sv,n)	(void *) SvGROW( sv, 0==(n) ? MIN_GROW_SIZE : (n)+1 )

/* Simplify using SvGROW() for WCHAR-sized buffers: */
#define lwSvGROW(sv,n)	(WCHAR *) SvGROW( sv, sizeof(WCHAR)*	\
			    ( 0==(n) ? MIN_GROW_SIZE : (n)+1 ) )

/* Whether the buffer size we got lets us change what buffer size we use: */
#define autosize(sv)	(!(  SvOK(sv)  &&  ! SvROK(sv)		\
			 &&  SvPV(sv,na)  &&  '=' == *SvPV(sv,na)  ))

/* Get the IV/UV for a parameter that might be C<[]> (null) or C<undef>: */
#define optIV(sv)	( null_arg(sv) ? 0 : !SvOK(sv) ? 0 : SvIV(sv) )
#define optUV(sv)	( null_arg(sv) ? 0 : !SvOK(sv) ? 0 : SvUV(sv) )

/* Initialize a buffer size argument of type (DWORD *): */
#define init_buf_pl( plSize, svSize )			STMT_START {	\
	if(  null_arg(svSize)  )					\
	    plSize= NULL;						\
	else								\
	    *( plSize= _alloca( sizeof(*plSize) ) )= autosize(svSize)	\
	      ? optUV(svSize) : strtoul( 1+SvPV(svSize,na), NULL, 10 );	\
    } STMT_END
/* In INPUT section put ": init_buf_pl($var,$arg);" after variable name. */

/* Initialize a buffer size argument of type DWORD: */
#define init_buf_l( svSize )						\
	(  null_arg(svSize) ? 0 : autosize(svSize) ? optUV(svSize)	\
	   : strtoul( 1+SvPV(svSize,na), NULL, 10 )  )
/* In INPUT section put "= init_buf_l($arg);" after variable name. */

/* Lengths in WCHARs are initialized the same as lengths in bytes: */
#define init_buf_plw	init_buf_pl
#define init_buf_lw	init_buf_l

/* grow_buf_pl() and grow_buf_plw() are included so you can define
 * parameters of type "DWORD *", for example.  In practice, it is
 * better to define such parameters as "DWORD &". */

/* Grow a buffer where we have a pointer to its size in bytes: */
#define	grow_buf_pl( sBuf,svBuf, plSize,svSize )	STMT_START {	\
	Debug(("grow_buf_pl( %s==0x%lX,[%s:%ld/%ld, %s==0x%lX:%ld,[%s )\n",\
	  string(sBuf),sBuf,strchr(string(svBuf),'('),SvPOK(svBuf)?	\
	  SvCUR(svBuf):-1,SvPOK(svBuf)?SvLEN(svBuf):-1,string(plSize),	\
	  plSize,plSize?*plSize:-1,strchr(string(svSize),'(')));	\
	if(  ! null_arg(svBuf)  ) {					\
	    if(  NULL == plSize  )					\
		*( plSize= (DWORD *) _alloca( sizeof(DWORD) ) )= 0;	\
	    if(  ! SvOK(svBuf)  )    sv_setpvn(svBuf,"",0);		\
	    sBuf= (void *) SvPV_force( svBuf, na );			\
	    sBuf= lSvGROW( svBuf, *plSize );				\
	    if(  autosize(svSize)  )   *plSize= SvLEN(svBuf) - 1;	\
	    Debug(("more buf_pl( %s==0x%lX,[%s:%ld/%ld, %s==0x%lX:%ld,[%s )\n",\
	      string(sBuf),sBuf,strchr(string(svBuf),'('),SvPOK(svBuf)?	\
	      SvCUR(svBuf):-1,SvPOK(svBuf)?SvLEN(svBuf):-1,string(plSize),\
	      plSize,plSize?*plSize:-1,strchr(string(svSize),'(')));	\
	} } STMT_END

/* Grow a buffer where we have a pointer to its size in WCHARs: */
#define	grow_buf_plw( sBuf,svBuf, plwSize,svSize )	STMT_START {	\
	if(  ! null_arg(svBuf)  ) {					\
	    if(  NULL == plwSize  )					\
		*( plwSize= (DWORD *) _alloca( sizeof(DWORD) ) )= 0;	\
	    if(  ! SvOK(svBuf)  )    sv_setpvn(svBuf,"",0);		\
	    sBuf= (WCHAR *) SvPV_force( svBuf, na );			\
	    sBuf= lwSvGROW( svBuf, *plwSize );				\
	    if(  autosize(svSize)  )					\
		*plwSize= SvLEN(svBuf)/sizeof(WCHAR) - 1;		\
	} } STMT_END

/* Grow a buffer where we have its size in bytes: */
#define	grow_buf_l( sBuf,svBuf, lSize,svSize )		STMT_START {	\
	if(  ! null_arg(svBuf)  ) {					\
	    if(  ! SvOK(svBuf)  )    sv_setpvn(svBuf,"",0);		\
	    sBuf= (void *) SvPV_force( svBuf, na );			\
	    sBuf= lSvGROW( svBuf, lSize );				\
	    if(  autosize(svSize)  )   lSize= SvLEN(svBuf) - 1;		\
	} } STMT_END

/* Grow a buffer where we have its size in WCHARs: */
#define	grow_buf_lw( swBuf,svBuf, lwSize,svSize )	STMT_START {	\
	if(  ! null_arg(svBuf)  ) {					\
	    if(  ! SvOK(svBuf)  )    sv_setpvn(svBuf,"",0);		\
	    swBuf= (WCHAR *) SvPV_force( svBuf, na );			\
	    swBuf= lwSvGROW( svBuf, lwSize );				\
	    if(  autosize(svSize)  )					\
	    	lwSize= SvLEN(svBuf)/sizeof(WCHAR) - 1;			\
	} } STMT_END

/* Grow a buffer that contains the declared fixed data type: */
#define	grow_buf( pBuf,svBuf, pType )			STMT_START {	\
	if(  null_arg(svBuf)  ) {					\
	    pBuf= (pType) NULL;						\
	} else {							\
	    if(  ! SvOK(svBuf)  )    sv_setpvn(svBuf,"",0);		\
	    (void) SvPV_force( svBuf, na );				\
	    pBuf= (pType) SvGROW( svBuf, sizeof(*pBuf) );		\
	} } STMT_END

/* Grow a buffer that contains a fixed data type other than that declared: */
#define	grow_buf_typ( pBuf,svBuf, Type )		STMT_START {	\
	if(  ! null_arg(svBuf)  ) {					\
	    if(  ! SvOK(svBuf)  )    sv_setpvn(svBuf,"",0);		\
	    (void) SvPV_force( svBuf, na );				\
	    pBuf= (Type *) SvGROW( svBuf, sizeof(Type) );		\
	} } STMT_END

/* Grow a buffer that contains a list of items of the declared data type: */
#define	grow_vect( pBuf,svBuf, cItems )			STMT_START {	\
	if(  null_arg(svBuf)  ) {					\
	    pBuf= NULL;							\
	} else {							\
	    if(  ! SvOK(svBuf)  )    sv_setpvn(svBuf,"",0);		\
	    (void) SvPV_force( svBuf, na );				\
	    pBuf= (pType) SvGROW( svBuf, sizeof(*pBuf)*cItems );	\
	} } STMT_END

#define	trunc_buf_pl( bOkay, sBuf,svBuf, plSize )			\
	trunc_buf_l( bOkay, sBuf,svBuf, *plSize )

#define	trunc_buf_plw( bOkay, swBuf,svBuf, plwSize )			\
	trunc_buf_lw( bOkay, swBuf,svBuf, *plwSize )

/* Set data length for a buffer where we have a its size in bytes: */
#define	trunc_buf_l( bOkay, sBuf,svBuf, lSize )		STMT_START {	\
	if(  bOkay  &&  NULL != sBuf  ) {				\
	    SvPOK_only( svBuf );					\
	    SvCUR_set( svBuf, lSize );					\
	} } STMT_END

/* Set data length for a buffer where we have a its size in WCHARs: */
#define	trunc_buf_lw( bOkay, sBuf,svBuf, lwSize )	STMT_START {	\
	if(  bOkay  &&  NULL != sBuf  ) {				\
	    SvPOK_only( svBuf );					\
	    SvCUR_set( svBuf, (lwSize)*sizeof(WCHAR) );			\
	} } STMT_END

/* Set data length for a buffer that contains the declared fixed data type: */
#define	trunc_buf( bOkay, pBuf,svBuf )			STMT_START {	\
	if(  bOkay  &&  NULL != pBuf  ) {				\
	    SvPOK_only( svBuf );					\
	    SvCUR_set( svBuf, sizeof(*pBuf) );				\
	} } STMT_END

/* Set data length for a buffer that contains some other fixed data type: */
#define	trunc_buf_typ( bOkay, pBuf,svBuf, Type )	STMT_START {	\
	if(  bOkay  &&  NULL != pBuf  ) {				\
	    SvPOK_only( svBuf );					\
	    SvCUR_set( svBuf, sizeof(Type) );				\
	} } STMT_END

/* Set length for buffer that contains list of items of the declared type: */
#define	trunc_vect( bOkay, pBuf,svBuf, cItems )		STMT_START {	\
	if(  bOkay  &&  NULL != pBuf  ) {				\
	    SvPOK_only( svBuf );					\
	    SvCUR_set( svBuf, sizeof(*pBuf)*cItems );			\
	} } STMT_END

/* Set data length for a buffer where a '\0'-terminate string was stored: */
#define	trunc_buf_z( bOkay, sBuf,svBuf )		STMT_START {	\
	if(  bOkay  &&  NULL != sBuf  ) {				\
	    SvPOK_only( svBuf );					\
	    SvCUR_set( svBuf, strlen(sBuf) );				\
	} } STMT_END

/* Set data length for a buffer where a L'\0'-terminate string was stored: */
#define	trunc_buf_zw( bOkay, sBuf,svBuf )		STMT_START {	\
	if(  bOkay  &&  NULL != sBuf  ) {				\
	    SvPOK_only( svBuf );					\
	    SvCUR_set( svBuf, wcslen(sBuf)*sizeof(WCHAR) );		\
	} } STMT_END
