!-------------------------------------------------------------------------------------------------!
!> Read Win/Win32-formatted seismograph data and export to ascii files: synchronous version
!!
!! @copyright
!! Copyright (c) 2019 Takuto Maeda. All rights reserved. 
!!
!! @license 
!! This software is released under the MIT license. See LICENSE for details. 
!--
!-- 2020-11-02 add filtering NU
!-- 2021-07-13 adjust tmp file name for parallel execution RS

program win2npz

  use iso_fortran_env
  use m_win
  use m_winch
  use m_util
  use m_getopt

!---
  use m_npy
  use endian_swap
!---
  
  implicit none 
  !--

  integer                     :: nch, nw, nsec
  character(256), allocatable :: fn_win(:)
  character(4),   allocatable :: chid(:)
  integer,        allocatable :: dat(:,:), dat0(:,:)
  integer,        allocatable :: npts(:,:), sfreq(:)
  character(80)               :: d_out,filter
  integer, parameter          :: fsmax = 200 !maximum sampling frequency
  integer, parameter          :: fwmax = 200 !maximum wave length of 1 file (sec)
  logical                     :: is_test_mode

!c  integer(8)           :: b(3000,3)
!  integer(8),allocatable      :: b(:,:)
  real(8),allocatable      :: b(:,:)
  real,allocatable      :: b1(:),b2(:),b3(:)
  integer           :: j2,inpzfile,tim0,tim1
  !----
  integer :: yr, mo, dy, hr, mi, sc, jday
  character(20) ::npzfile
  integer       :: t_leng,length,overlap
  character(10),   allocatable :: stn(:),stn1(:)
  character(4),   allocatable :: chid_stn(:,:)
  integer :: ns,idatamax
  type(winch__hdr), allocatable :: ch_tbl(:)
  real,     allocatable :: R11(:),R12(:),R13(:)
  real,     allocatable :: R21(:),R22(:),R23(:)
  real,     allocatable :: R31(:),R32(:),R33(:)
  logical                       :: is_rot,is_flt
  integer       ::iresamp
  integer       ::norder
  real          ::flo,fhi

  !-----------------------------------------------------------------------------------------------!
  !> command-line option processing
  !--
  block

    integer :: i,ikey,ii,ierr
    character(80) :: fn_winlst
    character(80) :: fn_chlst
    character(80) :: fn_stnlst
    character(80) :: fn_chtbl
    character(80) :: fn_rottbl
    logical :: is_opt, is_all
    integer :: iof

!c filter setting
        flo=1
        fhi=4
        norder=-2


    call getopt('l', is_opt, fn_winlst, '' )

    if( is_opt ) then
      call util__readlst( fn_winlst, nw, fn_win )
    else
      nw = 1
      allocate( fn_win(1) )
      call getopt('w', is_opt, fn_win(1), '') 
      if( .not. is_opt ) call usage_stop()
    end if
    
    call getopt('c', is_opt, fn_chlst, '' )

    if( is_opt ) then
      call util__read_arglst( fn_chlst, nch, is_all, chid )
      ns=1
      if(nch .ne. 3) then
        print *,"channels should be 3 (EW,NS,UD)"
        stop
      end if
    else
      call getopt('k', is_opt, fn_chtbl, '' )
      if( .not. is_opt ) call usage_stop()
      call winch__read_tbl(fn_chtbl, ch_tbl)
      call getopt('s', is_opt, fn_stnlst, '') 
      if( .not. is_opt ) call usage_stop()
      if( is_opt ) then
       call util__readlst( fn_stnlst, ns, stn )
!c        print *,"ns= ",ns
!c        print *,"stn(1)= ",stn(1)
        allocate( chid_stn(ns,3) )
        allocate( stn1(ns*3) )
        allocate( chid(ns*3) )
        allocate( R11(ns) )
        allocate( R12(ns) )
        allocate( R13(ns) )
        allocate( R21(ns) )
        allocate( R22(ns) )
        allocate( R23(ns) )
        allocate( R31(ns) )
        allocate( R32(ns) )
        allocate( R33(ns) )
        nch=0
        do i=1,ns
          call  winch__st2chid(ch_tbl, stn(i), 'EW', chid_stn(i,1), ikey)
          if(ikey.eq.-1) then
                call  winch__st2chid(ch_tbl, stn(i), 'E',chid_stn(i,1), ikey)
          endif
          if(ikey.eq.-1) then
                call  winch__st2chid(ch_tbl, stn(i), 'X',chid_stn(i,1), ikey)
          endif
          if(ikey.eq.-1) then
                call  winch__st2chid(ch_tbl, stn(i), 'VX',chid_stn(i,1), ikey)
          endif
          if (ikey.eq.-1) then
              print *,"No channel data for ",stn(i), "EW"
              call usage_stop()
          endif

          call  winch__st2chid(ch_tbl, stn(i), 'NS', chid_stn(i,2), ikey)
          if(ikey.eq.-1) then
                call  winch__st2chid(ch_tbl, stn(i), 'N',chid_stn(i,2), ikey)
          endif
          if(ikey.eq.-1) then
                call  winch__st2chid(ch_tbl, stn(i), 'Y',chid_stn(i,2), ikey)
          endif
          if(ikey.eq.-1) then
                call  winch__st2chid(ch_tbl, stn(i), 'VY',chid_stn(i,2), ikey)
          endif
          if (ikey.eq.-1) then
              print *,"No channel data for ",stn(i), "NS"
              call usage_stop()
          endif
          call  winch__st2chid(ch_tbl, stn(i), 'UD', chid_stn(i,3), ikey)
          if(ikey.eq.-1) then
                call  winch__st2chid(ch_tbl, stn(i), 'U',chid_stn(i,3), ikey)
          endif
          if(ikey.eq.-1) then
                call  winch__st2chid(ch_tbl, stn(i), 'Z',chid_stn(i,3), ikey)
          endif
          if(ikey.eq.-1) then
                call  winch__st2chid(ch_tbl, stn(i), 'VZ',chid_stn(i,3), ikey)
          endif
          if (ikey.eq.-1) then
              print *,"No channel data for ",stn(i), "UD"
              call usage_stop()
          endif
!c        print *,"ikey= ",ikey
!c        print *,"chid_stn(i,1)= ",chid_stn(i,1),chid_stn(i,2),chid_stn(i,3)
!c          print *,"nch= ",nch
!c          print *,"chid_stn(i,1)=",chid_stn(i,1)
!c          print *,"stn= ",stn(i)
          nch=nch+1
          chid(nch)=chid_stn(i,1)
          stn1(nch)=stn(i)
          nch=nch+1
          chid(nch)=chid_stn(i,2)
          stn1(nch)=stn(i)
          nch=nch+1
          chid(nch)=chid_stn(i,3)
          stn1(nch)=stn(i)
!c          print *,"i=",i
!c          print *,"stn1=",stn1(nch)

        end do
      end if 
!c      print *,"nch===",nch
      ns=nch/3
!c      print *,"ns==",ns

!c      if( .not. is_opt ) call usage_stop()
    end if

    call getopt('t', is_opt, t_leng, 30 )
!c    print *,"t_leng= ",t_leng

    call getopt('o', is_opt, overlap, 0 )
!c    print *,"overlap= ",overlap

    call getopt('p', is_opt, iresamp, 1 )
!c    print *,"iresamp= ",iresamp

    call getopt('d', is_opt, d_out, '.' )
!c    print *,"d_out= ", d_out

    call getopt('r', is_rot, fn_rottbl, '' )
    if( is_rot ) then
!      allocate( chid(ns*3) )
      call getrot(fn_rottbl,ns,stn,R11,R12,R13,&
      R21,R22,R23,R31,R32,R33,ierr)
!c    print *,"rotate"
    endif
    call getopt('f', is_flt, filter, '' )
    if( is_flt ) then
        open(newunit=iof,file=filter,action='read', status='old', iostat=ierr)
        read(iof,*)flo
        read(iof,*)fhi
        read(iof,*)norder
        print *,"filter= ",flo,fhi,norder
        close(iof)
    end if

    call getopt('Z', is_test_mode)

  end block
  !-----------------------------------------------------------------------------------------------!
  !-----------------------------------------------------------------------------------------------!
  !> Read the data
  !--
  block
    integer :: i, j
    integer :: tim
    !----
!c    print *,"nch=",nch

!c    print *," sfreq(nch)= ", sfreq(nch)
!c    print *,"fsmax,nw,nch=",fsmax,nw,nch
    allocate( sfreq(nch) )
!c    allocate( dat(fsmax*60*nw,nch) ) !! initial size
    allocate( dat(fsmax*fwmax*nw,nch) ) !! initial size
    dat(:,:) = 0

    do i=1, nw
      call win__read_file(fn_win(i), chid, sfreq, nsec, tim, dat0, npts)
      if (i.eq.1) tim0=tim
      do j=1, nch
        if( sfreq(j)*nsec > fsmax*fwmax ) then
           print *,"Warning: Sampling frequency is too high",sfreq(j)
           print *,"Warning: Waveform length is too long",nsec
           stop
        endif
        if( sfreq(j) > 0 ) then
!c           print *,"nsec=",nsec
           dat( (i-1)*sfreq(j)*nsec+1:i*sfreq(j)*nsec, j) = dat0(1:sfreq(j)*nsec,j)
        end if
      end do   

    end do
  end block
  !-----------------------------------------------------------------------------------------------!

  !-----------------------------------------------------------------------------------------------!
  !> Export
  !--  
  block
    integer :: i, j, io, k
    character(80) :: fn_asc, fn_asc0
    real(8),allocatable      :: x(:),y(:),z(:)
    character(4) :: yr_
    integer :: yr2
    !----

        inpzfile=int(nsec*nw/(t_leng-overlap))
        if(mod(nsec*nw,t_leng-overlap).ne.0) inpzfile=inpzfile+1
!c        print *,"inpzfile= ",inpzfile
!-----------
    do k=1,ns ! for all stations
!        print *,"k= ",k
!        print *,"sfreq((k-1)*3+1)==",sfreq((k-1)*3+1)
!        print *,"sfreq((k-1)*3+2)==",sfreq((k-1)*3+2)
!        print *,"sfreq((k-1)*3+3)==",sfreq((k-1)*3+3)
     if(sfreq((k-1)*3+1) > 0 .and. sfreq((k-1)*3+2) > 0 .and.&
 &      sfreq((k-1)*3+3) > 0) then
      length=t_leng*sfreq((k-1)*3+1)
!c      if(iresamp.ne.0)then ! resampling
        length=int(length/iresamp)
!c      end if
!c      idatamax=sfreq((k-1)*3+1)*nsec*nw
      idatamax=int(sfreq((k-1)*3+1)*nsec*nw/iresamp)
!c        print *,"length=",length
!c        length=length+1
      allocate( b(length,3) ) !! initial size
      if(norder.gt.0)then
         allocate( b1(length) ) !! initial size
         allocate( b2(length) ) !! initial size
         allocate( b3(length) ) !! initial size
      endif
      if(is_rot)then
          allocate( x(length) ) !! initial size
          allocate( y(length) ) !! initial size
          allocate( z(length) ) !! initial size
      end if
      do i=1,inpzfile
        if(i.ne.inpzfile)then
!         length=t_leng*sfreq((k-1)*3+1)
         if(norder.gt.0)then
           b1(j)=dat((j-1)*iresamp+1+(i-1)*length*iresamp,(k-1)*3+3)
           b2(j)=dat((j-1)*iresamp+1+(i-1)*length*iresamp,(k-1)*3+2)
           b3(j)=dat((j-1)*iresamp+1+(i-1)*length*iresamp,(k-1)*3+1)
         else
          do j=1,length
!          print *,i,j
           b(j,3)=dble(dat((j-1)*iresamp+1+(i-1)*length*iresamp,(k-1)*3+3))
           b(j,2)=dble(dat((j-1)*iresamp+1+(i-1)*length*iresamp,(k-1)*3+2))
           b(j,1)=dble(dat((j-1)*iresamp+1+(i-1)*length*iresamp,(k-1)*3+1))
          end do
         end if
!         print *,"check"
        else
!         print *,"check2"
         do j=1,length
!          print *,"2",i,j
         if(norder.gt.0)then
           if(((j-1)*iresamp+1+(i-1)*length).le.idatamax)then
           b1(j)=dat((j-1)*iresamp+1+(i-1)*length*iresamp,(k-1)*3+3)
           b2(j)=dat((j-1)*iresamp+1+(i-1)*length*iresamp,(k-1)*3+2)
           b3(j)=dat((j-1)*iresamp+1+(i-1)*length*iresamp,(k-1)*3+1)
           else
           b1(j)=0.0
           b2(j)=0.0
           b3(j)=0.0
           end if
         else
          if(((j-1)*iresamp+1+(i-1)*length).le.idatamax)then
           b(j,3)=dble(dat((j-1)*iresamp+1+(i-1)*length*iresamp,(k-1)*3+3))
           b(j,2)=dble(dat((j-1)*iresamp+1+(i-1)*length*iresamp,(k-1)*3+2))
           b(j,1)=dble(dat((j-1)*iresamp+1+(i-1)*length*iresamp,(k-1)*3+1))
          else
           b(j,3)=0.0
           b(j,2)=0.0
           b(j,1)=0.0
          end if
          end if
         end do
        endif
        if(norder.gt.0) then
          call rmv_offset(b1,length)
          call rmv_offset(b2,length)
          call rmv_offset(b3,length)
          call make_filter_forward (length,b1,flo,fhi,norder)
          call make_filter_forward (length,b2,flo,fhi,norder)
          call make_filter_forward (length,b3,flo,fhi,norder)
          do j=1,length
                b(j,3)=dble(b1(j))
                b(j,2)=dble(b2(j))
                b(j,1)=dble(b3(j))
          end do
        end if
        if(is_rot)then
          do j=1,length
            x(j)=b(j,1)
            y(j)=b(j,2)
            z(j)=b(j,3)
          enddo
!c          call rotate (b(j,1),b(j,2),b(j,3),length,&
!c           R11(k),R12(k),R13(k),R21(k),R22(k),R23(k),R31(k),R32(k),R33(k))
          call rotate (x,y,z,length,&
           R11(k),R12(k),R13(k),R21(k),R22(k),R23(k),R31(k),R32(k),R33(k))
          do j=1,length
            b(j,1)=x(j)
            b(j,2)=y(j)
            b(j,3)=z(j)
          enddo
!c          print *,"rot end"
        endif

!c        print *,"rot end 2"
!c        tim0=tim0+(i-1)*length/sfreq(1)
!c        tim1=tim0+(i-1)*length/sfreq((k-1)*3+1)-(i-1)*overlap
        tim1=tim0+(i-1)*length*iresamp/sfreq((k-1)*3+1)-(i-1)*overlap !c +10 for trg data
        call util__localtime(tim1, yr, mo, dy, hr, mi, sc, jday)

!c        print *,"rot end 3"
        write (yr_, '(i4)') yr
        read (yr_(3:4), *) yr2
        write(npzfile,123)yr2, mo, dy, hr, mi, sc
!c        print *,"npzfile=",npzfile
123     format(6i2.2)
        fn_asc = trim(d_out) //'/'//trim(npzfile)//'_'//trim(stn1((k-1)*3+1))//'.npz'
        fn_asc0 = 'data_'//trim(npzfile)//'_'//trim(stn1((k-1)*3+1))
!c        fn_asc = trim(d_out) //'/'//trim(npzfile)//'.'//stn1((k-1)*3+1)//'.npz'
!c        print *,fn_asc
!c        fn_asc = trim(d_out) //'/'//trim(fn_win(1))//'-a.npz'
        call add_npz(fn_asc, fn_asc0, b) !c ""
!c        print *,"write!"
!c
      end do
      if(norder.gt.0) then
        deallocate(b1)
        deallocate(b2)
        deallocate(b3)
      end if
      if(is_rot)then
        deallocate(x)
        deallocate(y)
        deallocate(z)
      end if
      deallocate(b)
     else
        print *,"Error: Data for ",stn(k)," could note be found."
     end if
    end do

  end block
  !-----------------------------------------------------------------------------------------------!
  
contains
  !-----------------------------------------------------------------------------------------------!
  subroutine usage_stop()

    write(error_unit,'(A)') 'usage:  win2npz.x <-l winlst|-w winfile> <-c chid|lst | -k chtbl -s stnlst>&
& [-d dir] [-t time length] [-o window overlap] [-r rotation table] &
& [-f filter setting file]'
    stop
  end subroutine usage_stop      
  
  subroutine getrot(fn,ns,stn,R11,R12,R13,&
       R21,R22,R23,R31,R32,R33,ierr)

    character(*), intent(in) :: fn  !< filename
    character(*), intent(in) :: stn(:) !< filename
    integer,      intent(in) :: ns !number of stations in the list
    real,     intent(out) :: R11(:),R12(:),R13(:)
    real,     intent(out) :: R21(:),R22(:),R23(:)
    real,     intent(out) :: R31(:),R32(:),R33(:)

    integer :: io, ierr, n
    integer :: i,j,ifound
    character(7)        :: dummy
    character(1)        :: ck

    character(97),allocatable   :: line(:)
    ierr=0
    open(newunit=io,file=fn,action='read', status='old', iostat=ierr)
    call util__countline(io, n)
!c    print *,"n= ",n
    allocate(line(n))
    if(n.ge.2)then
      read(io,'(a)')line(1)
      do i=2, n
        read(io,'(a)')line(i)
      end do
    end if
    do j=1,ns
        ifound=0
        do i=2,n
          if(line(i)(7:7).ne.' ') then
            if(stn(j).eq.line(i)(1:7))then
                ifound=1
!c                print *,line
                read(line(i),*)dummy,R11(j),R12(j),R13(j),&
                    R21(j),R22(j),R23(j),R31(j),R32(j),R33(j)
!c                print *,dummy
            end if
          else
            print *,"Please check the rotation table"
            stop
          end if
        enddo
        if(ifound.eq.0)then
           ierr=1
           print *,"Error: rotation constant for ",stn(j), "could not be found."
        endif
    enddo

    return
  end subroutine getrot

  subroutine  rotate (jbufx,jbufy,jbufz,imaxfre,&
         R11,R12,R13,R21,R22,R23,R31,R32,R33)

   integer             :: imaxfre
   real(8), intent(inout) :: jbufx(imaxfre),jbufy(imaxfre),jbufz(imaxfre)
   real(8)       tmpE(imaxfre),tmpN(imaxfre),tmpU(imaxfre)
   real         :: R11,R12,R13,R21,R22,R23,R31,R32,R33
   integer      :: i

        do i=1,imaxfre
          tmpE(i) = R11*jbufx(i) + R12*jbufy(i) + R13*jbufz(i)
          tmpN(i) = R21*jbufx(i) + R22*jbufy(i) + R23*jbufz(i)
          tmpU(i) = R31*jbufx(i) + R32*jbufy(i) + R33*jbufz(i)
        enddo
        do i=1,imaxfre
          jbufx(i)=tmpE(i)
          jbufy(i)=tmpN(i)
          jbufz(i)=tmpU(i)
        enddo

    return
  end subroutine rotate


end program win2npz
!-------------------------------------------------------------------------------------------------!
