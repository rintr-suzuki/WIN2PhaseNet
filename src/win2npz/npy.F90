!-- 2021-07-13 adjust tmp file name for parallel execution RS

module m_npy
   use endian_swap
   implicit none

   integer(4), parameter               :: p_un = 23
   character, parameter                :: magic_num = achar(147) ! x93
   character, parameter                :: major = achar(2)   !major *.npy version
   character, parameter                :: minor = achar(0)   !minor *.npy version
   logical, parameter                  :: use_big_endian = .False.
   character(len=*), parameter         :: zip_flag = "-q0"
   character(len=*), parameter         :: magic_str = "NUMPY"

   interface save_npy
      module procedure write_int64_vec, write_int64_mtx, &
         write_int32_vec, write_int32_mtx, &
         write_int16_vec, write_int16_mtx, &
         write_int8_vec, write_int8_mtx, &
         write_dbl_vec, write_dbl_mtx, &
         write_sng_vec, write_sng_mtx, &
         write_cmplx_sgn_vec, write_cmplx_sgn_mtx, &
         write_cmplx_dbl_vec, write_cmplx_dbl_mtx, &
         write_sng_3dT, write_dbl_3dT, &
         write_cmplx_dbl_3dT

   end interface save_npy

   interface add_npz
      module procedure addrpl_int8_vec, addrpl_int8_mtx, &
         addrpl_int16_vec, addrpl_int16_mtx, &
         addrpl_int32_vec, addrpl_int32_mtx, &
         addrpl_int64_vec, addrpl_int64_mtx, &
         addrpl_sng_vec, addrpl_sng_mtx, &
         addrpl_dbl_vec, addrpl_dbl_mtx, &
         addrpl_cmplx_dbl_vec, addrpl_cmplx_dbl_mtx, &
         addrpl_cmplx_sng_vec, addrpl_cmplx_sng_mtx
   end interface add_npz

   interface read_npy
      module procedure read_dbl_vec
   end interface read_npy

contains
   subroutine run_sys(cmd, stat)
      implicit none
      character(len=*), intent(in)     :: cmd
      integer(4), intent(out)          :: stat

      call execute_command_line(cmd, wait=.True., exitstat=stat)
   end subroutine run_sys

   subroutine addrpl_cmplx_sng_vec(zipfile, var_name, vec)
      implicit none
      complex(4), intent(in)           :: vec(:)
      character(len=*), intent(in)     :: zipfile, var_name
      character(len=:), allocatable    :: npy_name
      integer(4)                       :: succ

      npy_name = trim(var_name)//".npy"

      call save_npy(npy_name, vec)
      ! just store and be quite while zipping
      call run_sys("zip "//zip_flag//" "//zipfile &
                   //" "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute zip command"
      endif

      call run_sys("rm "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute rm command"
      endif
   end subroutine addrpl_cmplx_sng_vec

   subroutine addrpl_cmplx_sng_mtx(zipfile, var_name, mtx)
      implicit none
      complex(4), intent(in)           :: mtx(:, :)
      character(len=*), intent(in)     :: zipfile, var_name
      character(len=:), allocatable    :: npy_name
      integer(4)                       :: succ

      npy_name = trim(var_name)//".npy"

      call save_npy(npy_name, mtx)
      ! just store and be quite while zipping
      call run_sys("zip "//zip_flag//" "//zipfile &
                   //" "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute zip command"
      endif

      call run_sys("rm "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute rm command"
      endif
   end subroutine addrpl_cmplx_sng_mtx

   subroutine addrpl_cmplx_dbl_vec(zipfile, var_name, vec)
      implicit none
      complex(8), intent(in)           :: vec(:)
      character(len=*), intent(in)     :: zipfile, var_name
      character(len=:), allocatable    :: npy_name
      integer(4)                       :: succ

      npy_name = trim(var_name)//".npy"

      call save_npy(npy_name, vec)
      ! just store and be quite while zipping
      call run_sys("zip "//zip_flag//" "//zipfile &
                   //" "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute zip command"
      endif

      call run_sys("rm "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute rm command"
      endif
   end subroutine addrpl_cmplx_dbl_vec

   subroutine addrpl_cmplx_dbl_mtx(zipfile, var_name, mtx)
      implicit none
      complex(8), intent(in)           :: mtx(:, :)
      character(len=*), intent(in)     :: zipfile, var_name
      character(len=:), allocatable    :: npy_name
      integer(4)                       :: succ

      npy_name = trim(var_name)//".npy"

      call save_npy(npy_name, mtx)
      ! just store and be quite while zipping
      call run_sys("zip "//zip_flag//" "//zipfile &
                   //" "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute zip command"
      endif

      call run_sys("rm "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute rm command"
      endif
   end subroutine addrpl_cmplx_dbl_mtx

   subroutine addrpl_dbl_vec(zipfile, var_name, vec)
      implicit none
      real(8), intent(in)           :: vec(:)
      character(len=*), intent(in)     :: zipfile, var_name
      character(len=:), allocatable    :: npy_name
      integer(4)                       :: succ

      npy_name = trim(var_name)//".npy"

      call save_npy(npy_name, vec)
      ! just store and be quite while zipping
      call run_sys("zip "//zip_flag//" "//zipfile &
                   //" "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute zip command"
      endif

      call run_sys("rm "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute rm command"
      endif
   end subroutine addrpl_dbl_vec

   subroutine addrpl_dbl_mtx(zipfile, var_name, mtx)
      implicit none
      real(8), intent(in)           :: mtx(:, :)
      character(len=*), intent(in)     :: zipfile, var_name
      character(len=:), allocatable    :: npy_name
      integer(4)                       :: succ

      npy_name = trim(var_name)//".npy"

      call save_npy(npy_name, mtx)
      ! just store and be quite while zipping
      call run_sys("zip "//zip_flag//" "//zipfile &
                   //" "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute zip command"
      endif

      call run_sys("rm "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute rm command"
      endif
   end subroutine addrpl_dbl_mtx

   subroutine addrpl_sng_vec(zipfile, var_name, vec)
      implicit none
      real(4), intent(in)           :: vec(:)
      character(len=*), intent(in)     :: zipfile, var_name
      character(len=:), allocatable    :: npy_name
      integer(4)                       :: succ

      npy_name = trim(var_name)//".npy"

      call save_npy(npy_name, vec)
      ! just store and be quite while zipping
      call run_sys("zip "//zip_flag//" "//zipfile &
                   //" "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute zip command"
      endif

      call run_sys("rm "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute rm command"
      endif
   end subroutine addrpl_sng_vec

   subroutine addrpl_sng_mtx(zipfile, var_name, mtx)
      implicit none
      real(4), intent(in)           :: mtx(:, :)
      character(len=*), intent(in)     :: zipfile, var_name
      character(len=:), allocatable    :: npy_name
      integer(4)                       :: succ

      npy_name = trim(var_name)//".npy"

      call save_npy(npy_name, mtx)
      ! just store and be quite while zipping
      call run_sys("zip "//zip_flag//" "//zipfile &
                   //" "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute zip command"
      endif

      call run_sys("rm "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute rm command"
      endif
   end subroutine addrpl_sng_mtx

   subroutine addrpl_int8_vec(zipfile, var_name, vec)
      implicit none
      integer(1), intent(in)           :: vec(:)
      character(len=*), intent(in)     :: zipfile, var_name
      character(len=:), allocatable    :: npy_name
      integer(4)                       :: succ

      npy_name = trim(var_name)//".npy"

      call save_npy(npy_name, vec)
      ! just store and be quite while zipping
      call run_sys("zip "//zip_flag//" "//zipfile &
                   //" "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute zip command"
      endif

      call run_sys("rm "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute rm command"
      endif
   end subroutine addrpl_int8_vec

   subroutine addrpl_int8_mtx(zipfile, var_name, mtx)
      implicit none
      integer(1), intent(in)           :: mtx(:, :)
      character(len=*), intent(in)     :: zipfile, var_name
      character(len=:), allocatable    :: npy_name
      integer(4)                       :: succ

      npy_name = trim(var_name)//".npy"

      call save_npy(npy_name, mtx)
      ! just store and be quite while zipping
      call run_sys("zip "//zip_flag//" "//zipfile &
                   //" "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute zip command"
      endif

      call run_sys("rm "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute rm command"
      endif
   end subroutine addrpl_int8_mtx

   subroutine addrpl_int16_vec(zipfile, var_name, vec)
      implicit none
      integer(2), intent(in)           :: vec(:)
      character(len=*), intent(in)     :: zipfile, var_name
      character(len=:), allocatable    :: npy_name
      integer(4)                       :: succ

      npy_name = trim(var_name)//".npy"

      call save_npy(npy_name, vec)
      ! just store and be quite while zipping
      call run_sys("zip "//zip_flag//" "//zipfile &
                   //" "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute zip command"
      endif

      call run_sys("rm "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute rm command"
      endif
   end subroutine addrpl_int16_vec

   subroutine addrpl_int16_mtx(zipfile, var_name, mtx)
      implicit none
      integer(2), intent(in)           :: mtx(:, :)
      character(len=*), intent(in)     :: zipfile, var_name
      character(len=:), allocatable    :: npy_name
      integer(4)                       :: succ

      npy_name = trim(var_name)//".npy"

      call save_npy(npy_name, mtx)
      ! just store and be quite while zipping
      call run_sys("zip "//zip_flag//" "//zipfile &
                   //" "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute zip command"
      endif

      call run_sys("rm "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute rm command"
      endif
   end subroutine addrpl_int16_mtx

   subroutine addrpl_int32_vec(zipfile, var_name, vec)
      implicit none
      integer(4), intent(in)           :: vec(:)
      character(len=*), intent(in)     :: zipfile, var_name
      character(len=:), allocatable    :: npy_name
      integer(4)                       :: succ

      npy_name = trim(var_name)//".npy"

      call save_npy(npy_name, vec)
      ! just store and be quite while zipping
      call run_sys("zip "//zip_flag//" "//zipfile &
                   //" "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute zip command"
      endif

      call run_sys("rm "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute rm command"
      endif
   end subroutine addrpl_int32_vec

   subroutine addrpl_int32_mtx(zipfile, var_name, mtx)
      implicit none
      integer(4), intent(in)           :: mtx(:, :)
      character(len=*), intent(in)     :: zipfile, var_name
      character(len=:), allocatable    :: npy_name
      integer(4)                       :: succ

      npy_name = trim(var_name)//".npy"

      call save_npy(npy_name, mtx)
      ! just store and be quite while zipping
      call run_sys("zip "//zip_flag//" "//zipfile &
                   //" "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute zip command"
      endif

      call run_sys("rm "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute rm command"
      endif
   end subroutine addrpl_int32_mtx

   subroutine addrpl_int64_vec(zipfile, var_name, vec)
      implicit none
      integer(8), intent(in)           :: vec(:)
      character(len=*), intent(in)     :: zipfile, var_name
      character(len=:), allocatable    :: npy_name
      integer(4)                       :: succ

      npy_name = trim(var_name)//".npy"

      call save_npy(npy_name, vec)
      ! just store and be quite while zipping
      call run_sys("zip "//zip_flag//" "//zipfile &
                   //" "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute zip command"
      endif

      call run_sys("rm "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute rm command"
      endif
   end subroutine addrpl_int64_vec

   subroutine addrpl_int64_mtx(zipfile, var_name, mtx)
      implicit none
      integer(8), intent(in)           :: mtx(:, :)
      character(len=*), intent(in)     :: zipfile, var_name
      character(len=:), allocatable    :: npy_name
      integer(4)                       :: succ

      npy_name = trim(var_name)//".npy"

      call save_npy(npy_name, mtx)
      ! just store and be quite while zipping
      call run_sys("zip "//zip_flag//" "//zipfile &
                   //" "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute zip command"
      endif

      call run_sys("rm "//npy_name, succ)
      if (succ /= 0) then
         write (*, *) "Can't execute rm command"
      endif
   end subroutine addrpl_int64_mtx

   Subroutine write_cmplx_sgn_mtx(filename, mtx)
      Implicit None
      character(len=*), intent(in)     :: filename
      complex(4), intent(in)           :: mtx(:, :)
      character(len=*), parameter      :: var_type = "<c8"
      integer(4)                       :: header_len, s_mtx(2), i, j

      s_mtx = shape(mtx)
      header_len = len(dict_str(var_type, s_mtx))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (p_un) Swap_Endian(header_len)
      else
         write (p_un) header_len
      endif
      write (p_un) dict_str(var_type, s_mtx)

      if (use_big_endian .eqv. Big_Endian()) then
         write (p_un) mtx
      else
         do j = 1, size(mtx, 2)
            do i = 1, size(mtx, 1)
               write (p_un) Swap_Endian(mtx(i, j))
            enddo
         enddo
      endif

      close (unit=p_un)
   End Subroutine write_cmplx_sgn_mtx

   Subroutine write_cmplx_sgn_vec(filename, vec)
      Implicit None
      character(len=*), intent(in)     :: filename
      complex(4), intent(in)           :: vec(:)
      character(len=*), parameter      :: var_type = "<c8"
      integer(4)                       :: header_len, s_vec(1), i

      s_vec = shape(vec)
      header_len = len(dict_str(var_type, s_vec))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (p_un) Swap_Endian(header_len)
      else
         write (p_un) header_len
      endif

      write (p_un) dict_str(var_type, s_vec)

      if (use_big_endian .eqv. Big_Endian()) then
         write (p_un) vec
      else
         do i = 1, size(vec)
            write (p_un) Swap_Endian(vec(i))
         enddo
      endif
      close (unit=p_un)
   End Subroutine write_cmplx_sgn_vec

   Subroutine write_cmplx_dbl_3dT(filename, tensor)
      Implicit None
      character(len=*), intent(in)     :: filename
      complex(8), intent(in)           :: tensor(:, :, :)
      character(len=*), parameter      :: var_type = "<c16"
      integer(4)                       :: header_len, i, j, k

      header_len = len(dict_str(var_type, shape(tensor)))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (*, *) "3D tensors not implemented on BigEndian"
         write (*, *) "write in issue if you need it"
         stop 7
      else
         write (p_un) header_len
      endif

      write (p_un) dict_str(var_type, shape(tensor))
      write (p_un) tensor
      close (unit=p_un)
   End Subroutine write_cmplx_dbl_3dT

   Subroutine write_cmplx_dbl_mtx(filename, mtx)
      Implicit None
      character(len=*), intent(in)     :: filename
      complex(8), intent(in)           :: mtx(:, :)
      character(len=*), parameter      :: var_type = "<c16"
      integer(4)                       :: header_len, s_mtx(2), i, j

      s_mtx = shape(mtx)
      header_len = len(dict_str(var_type, s_mtx))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (p_un) Swap_Endian(header_len)
      else
         write (p_un) header_len
      endif

      write (p_un) dict_str(var_type, s_mtx)

      if (use_big_endian .eqv. Big_Endian()) then
         write (p_un) mtx
      else
         do j = 1, size(mtx, 2)
            do i = 1, size(mtx, 1)
               write (p_un) Swap_Endian(mtx(i, j))
            enddo
         enddo
      endif
      close (unit=p_un)
   End Subroutine write_cmplx_dbl_mtx

   Subroutine write_cmplx_dbl_vec(filename, vec)
      Implicit None
      character(len=*), intent(in)     :: filename
      complex(8), intent(in)           :: vec(:)
      character(len=*), parameter      :: var_type = "<c16"
      integer(4)                       :: header_len, s_vec(1), i

      s_vec = shape(vec)
      header_len = len(dict_str(var_type, s_vec))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (p_un) Swap_Endian(header_len)
      else
         write (p_un) header_len
      endif

      write (p_un) dict_str(var_type, s_vec)

      if (use_big_endian .eqv. Big_Endian()) then
         write (p_un) vec
      else
         do i = 1, size(vec)
            write (p_un) Swap_Endian(vec(i))
         enddo
      endif
      close (unit=p_un)
   End Subroutine write_cmplx_dbl_vec

   Subroutine write_sng_3dT(filename, tensor)
      Implicit None
      character(len=*), intent(in)     :: filename
      real(4), intent(in)              :: tensor(:, :, :)
      character(len=*), parameter      :: var_type = "<f4"
      integer(4)                       :: header_len, i, j, k

      header_len = len(dict_str(var_type, shape(tensor)))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (*, *) "3D tensors not implemented on BigEndian"
         write (*, *) "write in issue if you need it"
         stop 7
      else
         write (p_un) header_len
      endif

      write (p_un) dict_str(var_type, shape(tensor))
      write (p_un) tensor
      close (unit=p_un)
   End Subroutine write_sng_3dT

   Subroutine write_sng_mtx(filename, mtx)
      Implicit None
      character(len=*), intent(in)     :: filename
      real(4), intent(in)              :: mtx(:, :)
      character(len=*), parameter      :: var_type = "<f4"
      integer(4)                       :: header_len, s_mtx(2), i, j

      s_mtx = shape(mtx)
      header_len = len(dict_str(var_type, s_mtx))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (p_un) Swap_Endian(header_len)
      else
         write (p_un) header_len
      endif

      write (p_un) dict_str(var_type, s_mtx)

      if (use_big_endian .eqv. Big_Endian()) then
         write (p_un) mtx
      else
         do j = 1, size(mtx, 2)
            do i = 1, size(mtx, 1)
               write (p_un) Swap_Endian(mtx(i, j))
            enddo
         enddo
      endif
      close (unit=p_un)
   End Subroutine write_sng_mtx

   Subroutine write_sng_vec(filename, vec)
      Implicit None
      character(len=*), intent(in)     :: filename
      real(4), intent(in)              :: vec(:)
      character(len=*), parameter      :: var_type = "<f4"
      integer(4)                       :: header_len, s_vec(1), i

      s_vec = shape(vec)
      header_len = len(dict_str(var_type, s_vec))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (p_un) Swap_Endian(header_len)
      else
         write (p_un) header_len
      endif

      write (p_un) dict_str(var_type, s_vec)

      if (use_big_endian .eqv. Big_Endian()) then
         write (p_un) vec
      else
         do i = 1, size(vec)
            write (p_un) Swap_Endian(vec(i))
         enddo
      endif
      close (unit=p_un)
   End Subroutine write_sng_vec

   Subroutine write_dbl_3dT(filename, tensor)
      Implicit None
      character(len=*), intent(in)     :: filename
      real(8), intent(in)              :: tensor(:, :, :)
      character(len=*), parameter      :: var_type = "<f8"
      integer(4)                       :: header_len, i, j, k

      header_len = len(dict_str(var_type, shape(tensor)))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (*, *) "3D tensors not implemented on BigEndian"
         write (*, *) "write in issue if you need it"
         stop 7
      else
         write (p_un) header_len
      endif

      write (p_un) dict_str(var_type, shape(tensor))
      write (p_un) tensor
      close (unit=p_un)
   End Subroutine write_dbl_3dT

   Subroutine write_dbl_mtx(filename, mtx)
      Implicit None
      character(len=*), intent(in)     :: filename
      real(8), intent(in)              :: mtx(:, :)
      character(len=*), parameter      :: var_type = "<f8"
      integer(4)                       :: header_len, s_mtx(2), i, j

      s_mtx = shape(mtx)
      header_len = len(dict_str(var_type, s_mtx))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (p_un) Swap_Endian(header_len)
      else
         write (p_un) header_len
      endif

      write (p_un) dict_str(var_type, s_mtx)

      if (use_big_endian .eqv. Big_Endian()) then
         write (p_un) mtx
      else
         do j = 1, size(mtx, 2)
            do i = 1, size(mtx, 1)
               write (p_un) Swap_Endian(mtx(i, j))
            enddo
         enddo
      endif
      close (unit=p_un)
   End Subroutine write_dbl_mtx

   Subroutine write_dbl_vec(filename, vec)
      Implicit None
      character(len=*), intent(in)     :: filename
      real(8), intent(in)              :: vec(:)
      character(len=*), parameter      :: var_type = "<f8"
      integer(4)                       :: header_len, s_vec(1), i

      s_vec = shape(vec)
      header_len = len(dict_str(var_type, s_vec))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (p_un) Swap_Endian(header_len)
      else
         write (p_un) header_len
      endif

      write (p_un) dict_str(var_type, s_vec)

      if (use_big_endian .eqv. Big_Endian()) then
         write (p_un) vec
      else
         do i = 1, size(vec)
            write (p_un) Swap_Endian(vec(i))
         enddo
      endif
      close (unit=p_un)
   End Subroutine write_dbl_vec

   Subroutine write_int64_mtx(filename, mtx)
      Implicit None
      character(len=*), intent(in)     :: filename
      integer(8), intent(in)           :: mtx(:, :)
      character(len=*), parameter      :: var_type = "<i8"
      integer(4)                       :: header_len, s_mtx(2), i, j

      s_mtx = shape(mtx)
      header_len = len(dict_str(var_type, s_mtx))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (p_un) Swap_Endian(header_len)
      else
         write (p_un) header_len
      endif

      write (p_un) dict_str(var_type, s_mtx)

      if (use_big_endian .eqv. Big_Endian()) then
         write (p_un) mtx
      else
         do j = 1, size(mtx, 2)
            do i = 1, size(mtx, 1)
               write (p_un) Swap_Endian(mtx(i, j))
            enddo
         enddo
      endif
      close (unit=p_un)
   End Subroutine write_int64_mtx

   Subroutine write_int64_vec(filename, vec)
      Implicit None
      character(len=*), intent(in)     :: filename
      integer(8), intent(in)           :: vec(:)
      character(len=*), parameter      :: var_type = "<i8"
      integer(4)                       :: header_len, s_vec(1), i

      s_vec = shape(vec)
      header_len = len(dict_str(var_type, s_vec))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (p_un) Swap_Endian(header_len)
      else
         write (p_un) header_len
      endif

      write (p_un) dict_str(var_type, s_vec)

      if (use_big_endian .eqv. Big_Endian()) then
         write (p_un) vec
      else
         do i = 1, size(vec)
            write (p_un) Swap_Endian(vec(i))
         enddo
      endif
      close (unit=p_un)
   End Subroutine write_int64_vec

   Subroutine write_int32_mtx(filename, mtx)
      Implicit None
      character(len=*), intent(in)     :: filename
      integer(4), intent(in)           :: mtx(:, :)
      character(len=*), parameter      :: var_type = "<i4"
      integer(4)                       :: header_len, s_mtx(2), i, j

      s_mtx = shape(mtx)
      header_len = len(dict_str(var_type, s_mtx))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (p_un) Swap_Endian(header_len)
      else
         write (p_un) header_len
      endif
      write (p_un) dict_str(var_type, s_mtx)

      if (use_big_endian .eqv. Big_Endian()) then
         write (p_un) mtx
      else
         do j = 1, size(mtx, 2)
            do i = 1, size(mtx, 1)
               write (p_un) Swap_Endian(mtx(i, j))
            enddo
         enddo
      endif
      close (unit=p_un)
   End Subroutine write_int32_mtx

   Subroutine write_int32_vec(filename, vec)
      Implicit None
      character(len=*), intent(in)     :: filename
      integer(4), intent(in)           :: vec(:)
      character(len=*), parameter      :: var_type = "<i4"
      integer(4)                       :: header_len, s_vec(1), i

      s_vec = shape(vec)
      header_len = len(dict_str(var_type, s_vec))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (p_un) Swap_Endian(header_len)
      else
         write (p_un) header_len
      endif
      write (p_un) dict_str(var_type, s_vec)

      if (use_big_endian .eqv. Big_Endian()) then
         write (p_un) vec
      else
         do i = 1, size(vec)
            write (p_un) Swap_Endian(vec(i))
         enddo
      endif
      close (unit=p_un)
   End Subroutine write_int32_vec

   Subroutine write_int16_mtx(filename, mtx)
      Implicit None
      character(len=*), intent(in)     :: filename
      integer(2), intent(in)           :: mtx(:, :)
      character(len=*), parameter      :: var_type = "<i2"
      integer(4)                       :: header_len, s_mtx(2), i, j

      s_mtx = shape(mtx)
      header_len = len(dict_str(var_type, s_mtx))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (p_un) Swap_Endian(header_len)
      else
         write (p_un) header_len
      endif
      write (p_un) dict_str(var_type, s_mtx)

      if (use_big_endian .eqv. Big_Endian()) then
         write (p_un) mtx
      else
         do j = 1, size(mtx, 2)
            do i = 1, size(mtx, 1)
               write (p_un) Swap_Endian(mtx(i, j))
            enddo
         enddo
      endif
      close (unit=p_un)
   End Subroutine write_int16_mtx

   Subroutine write_int16_vec(filename, vec)
      Implicit None
      character(len=*), intent(in)     :: filename
      integer(2), intent(in)           :: vec(:)
      character(len=*), parameter      :: var_type = "<i2"
      integer(4)                       :: header_len, s_vec(1), i

      s_vec = shape(vec)
      header_len = len(dict_str(var_type, s_vec))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (p_un) Swap_Endian(header_len)
      else
         write (p_un) header_len
      endif
      write (p_un) dict_str(var_type, s_vec)

      if (use_big_endian .eqv. Big_Endian()) then
         write (p_un) vec
      else
         do i = 1, size(vec)
            write (p_un) Swap_Endian(vec(i))
         enddo
      endif
      close (unit=p_un)
   End Subroutine write_int16_vec

   Subroutine write_int8_mtx(filename, mtx)
      Implicit None
      character(len=*), intent(in)     :: filename
      integer(1), intent(in)           :: mtx(:, :)
      character(len=*), parameter      :: var_type = "<i1"
      integer(4)                       :: header_len, s_mtx(2), i, j

      s_mtx = shape(mtx)
      header_len = len(dict_str(var_type, s_mtx))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (p_un) Swap_Endian(header_len)
      else
         write (p_un) header_len
      endif
      write (p_un) dict_str(var_type, s_mtx)

      if (use_big_endian .eqv. Big_Endian()) then
         write (p_un) mtx
      else
         do j = 1, size(mtx, 2)
            do i = 1, size(mtx, 1)
               write (p_un) Swap_Endian(mtx(i, j))
            enddo
         enddo
      endif
      close (unit=p_un)
   End Subroutine write_int8_mtx

   Subroutine write_int8_vec(filename, vec)
      Implicit None
      character(len=*), intent(in)     :: filename
      integer(1), intent(in)           :: vec(:)
      character(len=*), parameter      :: var_type = "<i1"
      integer(4)                       :: header_len, s_vec(1), i

      s_vec = shape(vec)
      header_len = len(dict_str(var_type, s_vec))

      open (unit=p_un, file=filename, form="unformatted", &
            access="stream")
      write (p_un) magic_num, magic_str, major, minor
      if (Big_Endian()) then
         write (p_un) Swap_Endian(header_len)
      else
         write (p_un) header_len
      endif
      write (p_un) dict_str(var_type, s_vec)

      if (use_big_endian .eqv. Big_Endian()) then
         write (p_un) vec
      else
         do i = 1, size(vec)
            write (p_un) Swap_Endian(vec(i))
         enddo
      endif
      close (unit=p_un)
   End Subroutine write_int8_vec

   function dict_str(var_type, var_shape) result(str)
      implicit none
      character(len=*), intent(in)   :: var_type
      integer(4), intent(in)         :: var_shape(:)
      character(len=:), allocatable  :: str
      integer(4)                     :: cnt

      cnt = len("{'descr': '")
      cnt = cnt + len(var_type)
      cnt = cnt + len("', 'fortran_order': True, 'shape': (")
      cnt = cnt + len(shape_str(var_shape))
      cnt = cnt + len(",), }")
      do while (mod(cnt + 10, 16) /= 0)
         cnt = cnt + 1
      enddo

      allocate (character(cnt) :: str)

      str = "{'descr': '"//var_type// &
            "', 'fortran_order': True, 'shape': ("// &
            shape_str(var_shape)//"), }"

      do while (mod(len(str) + 11, 16) /= 0)
         str = str//" "
      enddo

      str = str//achar(10)

   end function dict_str

   function shape_str(var_shape) result(fin_str)
      implicit none
      integer(4), intent(in)        :: var_shape(:)
      character(len=:), allocatable :: str, small_str, fin_str
      integer(4)                    :: i, length, start, halt

      length = 14*size(var_shape)
      allocate (character(length) :: str)
      allocate (character(14)     :: small_str)
      str = " "

      do i = 1, size(var_shape)
         start = (i - 1)*length + 1
         halt = i*length + 1
         write (small_str, "(I13,A)") var_shape(i), ","
         str = trim(str)//adjustl(small_str)
      enddo

      fin_str = trim(str)
   end function shape_str

   function get_header(unitnum) result(header)
      use iso_c_binding
      implicit none
      integer, intent(in)             :: unitnum
      character(len=6)                :: magic
      character(len=1)                :: byte_tmp
      character(len=:), allocatable   :: header
      integer                         :: major, minor, header_size, stat
      integer(kind=c_int16_t)         :: int16
      integer(kind=c_int32_t)         :: int32

      read (17, iostat=stat) magic
      call check_stat(stat, __LINE__)

      if (magic /= achar(147)//"NUMPY") then
         write (*, *) "not a .npy file"
         stop
      endif

      read (17, iostat=stat) byte_tmp
      call check_stat(stat, __LINE__)
      major = ichar(byte_tmp)
      read (17, iostat=stat) byte_tmp
      call check_stat(stat, __LINE__)
      minor = ichar(byte_tmp)

      if (major == 1) then
         read (17, iostat=stat) int16
         call check_stat(stat, __LINE__)
         header_size = int16
      elseif (major == 2) then
         read (17, iostat=stat) int32
         call check_stat(stat, __LINE__)
         header_size = int32
      endif

      allocate (character(header_size) :: header)
      read (17, iostat=stat) header
      call check_stat(stat, __LINE__)
   end function get_header

   subroutine parse_header(header_str, descr, dims, fortran_order)
      implicit none
      character(len=*), intent(in)     :: header_str
      character(len=:), allocatable    :: descr_str, fort_str, shape_str, descr
      integer, allocatable             :: dims(:)
      logical, intent(out)             :: fortran_order

      integer                          :: descr_idx, fort_idx, shape_idx, n_entries

      descr_idx = index(header_str, "'descr':")
      fort_idx = index(header_str, "'fortran_order':")
      shape_idx = index(header_str, "'shape':")

      descr_str = get_keystr(header_str(descr_idx:fort_idx - 1))
      descr = descr_str(2:len(descr_str) - 1)

      fort_str = get_keystr(header_str(fort_idx:shape_idx - 1))
      if (fort_str == "True") then
         fortran_order = .True.
      elseif (fort_str == "False") then
         fortran_order = .False.
      else
         stop 8
      endif

      dims = interp_shape(get_keystr(header_str(shape_idx:)))
   end subroutine parse_header

   subroutine check_stat(stat, line)
      implicit none
      integer, intent(in) :: stat, line
      if (stat /= 0) then
         write (*, "('iostat =',I4,' at line ',I4)") stat, line
         stop 7
      endif
   end subroutine

   function get_keystr(input_str) result(out_str)
      implicit none
      character(len=*), intent(in)    :: input_str
      character(len=:), allocatable   :: out_str
      integer                         :: col, last_comma

      col = index(input_str, ":") + 1
      last_comma = index(input_str, ",", back=.True.)

      out_str = adjustl(trim(input_str(col:last_comma)))
      out_str = out_str(1:len(out_str) - 2)
   end function get_keystr

   function interp_shape(shape_str) result(dims)
      implicit none
      character(len=*), intent(in)   :: shape_str
      character(len=:), allocatable  :: work_str, num_str
      integer, allocatable           :: dims(:)
      integer                        :: idx

      work_str = shape_str(2:len(shape_str))
      allocate (dims(0))
      idx = -1

      do while (idx /= 0)
         idx = index(work_str, ",")
         num_str = work_str(1:idx - 1)
         if (len(num_str) > 0) dims = [dims, str2int(num_str)]
         work_str = work_str(idx + 1:len(work_str))
      enddo
   end function interp_shape

   function str2int(str) result(int)
      implicit none
      character(len=*), intent(in) :: str
      integer                      :: int
      integer                      :: stat

      read (str, *, iostat=stat) int
      if (stat /= 0) then
         write (*, *) "str reading failed", str
         stop 9
      endif
   end function str2int

   subroutine read_dbl_vec(filename, vec)
      implicit none
      character(len=*), intent(in)    :: filename
      real(8), allocatable            :: vec(:)
      
      character(len=:), allocatable   :: descr, header
      logical                         :: fortran_order
      integer                         :: stat
      integer, allocatable            :: dims(:)

      open (unit=17, file=filename, access="stream", form="unformatted", iostat=stat)

      header = get_header(17)
      call parse_header(header, descr, dims, fortran_order)

      if ("<f8" /= descr) then
         write (*, *) filename, " is not double"
         stop 17
      endif

      if(size(dims) /= 1) then
         write (*,*) filename, "is not 1D"
         stop 18
      endif

      allocate (vec(dims(1)))
      read (17) vec

      close (17)

   end subroutine read_dbl_vec
end module m_npy
