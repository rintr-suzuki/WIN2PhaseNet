        subroutine  rmv_offset (wv,n)

cc      implicit real*8 (a-h,o-z)
        real*4  wv(*)

        sum=0.0
        do j=1,n
        sum=sum+wv(j)
        enddo

        wv_mean=sum/float(n)

        do j=1,n
        wv(j)=wv(j)-wv_mean
        enddo

        return
        end

