!----------------------------------------------------------------------------------------
subroutine sort(x, y, iy, sort_ascend)
! X(i)=Y(iY(i))
! sort_ascend: true for ascend
! Y is sorted in an ascending/descending order

real, intent(inout), dimension(:) :: x, y
logical, intent(in), optional :: sort_ascend
integer, intent(out), dimension(:) :: iy

integer :: i, N, iswap(1), iswap1, itemp
real :: temp, IIY(size(X))
!character(len=128) :: method='quick_sort'
character(len=128) :: method='selection_sort'
 
   Y=X
   N=size(X)
   do I=1, N
      IY(i)=i
      IIY(i)=real(i)
   end do

if(trim(method)=='quick_sort') then
! use dsort in slatec library
! note -r8 is assumed in compiling
   if(present(sort_ascend)) then
      if(sort_ascend) then
        call dsort(y,iiy,N,2)
      else
        call dsort(y,iiy,N,-2)
      endif
   else
      call dsort(y,iiy,N,2)
   endif
   iy=nint(iiy)
elseif(trim(method)=='selection_sort') then
   do I=1,N-1
      if(present(sort_ascend)) then
         if(sort_ascend) then
         ISWAP=MINLOC(Y(I:N))
         else
         ISWAP=MAXLOC(Y(I:N))
         endif
      else
         ISWAP=MINLOC(Y(I:N))
      endif
         ISWAP1=ISWAP(1)+I-1
         IF(ISWAP1.NE.I) THEN
            TEMP=Y(I)
            Y(I)=Y(ISWAP1)
            Y(ISWAP1)=TEMP
            ITEMP=IY(I)
            IY(I)=IY(ISWAP1)
            IY(ISWAP1)=ITEMP
         ENDIF
   end do
endif
end subroutine sort
