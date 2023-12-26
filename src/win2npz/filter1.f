c make_filter_foward    subroutine for filterling forward 

c--- subroutine for filterling forward
        subroutine make_filter_forward(nwave,buf,flo,fhi,norder)

        parameter (SAMP=100)
        integer         nwave,norder
        dimension       buf(nwave),buf2(nwave)
        real            sampfreq,flo,fhi
        save    sampfreq
c-------------
        do i=1,nwave
                buf2(i)=0.
        enddo
        sampfreq        = real(SAMP)
        call filter_butbp(flo,fhi,norder,sampfreq)
        call filter_calc(buf, nwave, 1, buf2)

        do i=1,nwave
          buf(i)=buf2(i)
        enddo

        return
        end

