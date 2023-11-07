!----------------------------------------------------------------------------------------

subroutine tracer_eq_1var_2d(lon, lat, lonb, latb, q_tracer, qz, Qe, Ae, dQedY, sort_ascend)
!--------------------------------------------------------------------------------------------------------
!
! Hybrid Modified Lagrangian-Mean (MLM) and Eulerian diagnostics
! both Eulerian and Lagrangian variables are output at the input latitudinal grids
!
! input variables: lon, lat   : grid box centers (radian)
!                  lonb, latb : grid box boundaries (radian)
!                  q_tracer   : 2d tracer, stored in the format of q_tracer(lon,lat)
!                  sort_ascend: the direction of sorting q_tracer, default=.true.
!
! output variables: qz: Eulerian-mean q
!                   Qe: Lagrangian-mean Q
!                   Ae: wave activity
!                   dQedY: Lagrangian gradient of Q (per radian)
!
!--------------------------------------------------------------------------------------------------------

real, intent(in), dimension(:) :: lon,lat,lonb,latb
real, intent(in), dimension(:,:) :: q_tracer
real, intent(out), dimension(:) :: qz, Qe, Ae, dQedY
logical, intent(in), optional :: sort_ascend

real, dimension(size(latb)) :: sin_latb
real, dimension(size(latb)) :: dMb, qdMb, qdMe, dMe
real, dimension(size(latb)) :: qzb, qeb
real, dimension(size(lat)) :: cos_lat, sin_lat, qe2, qz2
real :: dX(size(lon)), dY(size(lat))
real, dimension(size(lon),size(lat)) :: dM2, qdM2
real, dimension(size(lon)*size(lat)) :: q1, q_sort, dM1, dM1_sort
integer, dimension(size(lon)*size(lat)) :: q_pos
integer:: n, nn, ni, nj, i, j, num_point
real :: eps0

  ni=size(lon);
  nj=size(lat);
  num_point=ni*nj;
    
  sin_latb=sin(latb);
  cos_lat=cos(lat);
  sin_lat=sin(lat);

!!! calculate the mass for each grid box
  dX=abs(lonb(2:(ni+1))-lonb(1:ni));
  dY=abs(sin_latb(2:(nj+1))-sin_latb(1:nj));
  
  do j=1, nj
    do i=1, ni
      dM2(i,j)=dX(i)*dY(j)
    end do
  end do
  qdM2=q_tracer*dM2
  qz=sum(qdM2,1)/sum(dM2,1);
  
!!! Eulerian integrals between lat(j-1) and lat(j) for j=1,...,nj+1
  dMb(nj+1)  = sum(dM2(:,nj),1)*0.5
  qdMb(nj+1) = sum(qdM2(:,nj),1)*0.5
  dMb(1)     = sum(dM2(:,1),1)*0.5
  qdMb(1)    = sum(qdM2(:,1),1)*0.5
  dMb(2:nj)  = sum(dM2(:,1:(nj-1)),1)*0.5 + sum(dM2(:,2:nj),1)*0.5
  qdMb(2:nj) = sum(qdM2(:,1:(nj-1)),1)*0.5 + sum(qdM2(:,2:nj),1)*0.5
   
! Lagrangian integrals between the two Q contours that have the equivalent latitudes of lat(j-1) and lat(j)
! sort the tracer field first and then the Lagrangian integral reduces to summation
! by default, reshape the columns (constant latitude) first
  q1=reshape(q_tracer,(/num_point/))
  dM1=reshape(dM2,(/num_point/))
  
  if(present(sort_ascend)) then
    call compute_sort(q1, q_sort, q_pos, sort_ascend)
  else
    call compute_sort(q1, q_sort, q_pos)
  endif
  do n=1, num_point
    dM1_sort(n)=dM1(q_pos(n))
  end do
  
  n = num_point
  dMe(1:(nj+1))  = 0.
  qdMe(1:(nj+1)) = 0.
  do j=(nj+1),2,-1
    do while ((dMe(j)<dMb(j)).and.(n>=1))
      dMe(j)  = dMe(j)  + dM1_sort(n)
      qdMe(j) = qdMe(j) + q_sort(n)*dM1_sort(n)
      n = n-1
    end do
      qe(j-1)  = q_sort(n+1)
      dMe(j-1) = dMe(j)-dMb(j)
      qdMe(j-1)= q_sort(n+1)*dMe(j-1)
      qdMe(j)  = qdMe(j)-qdMe(j-1)
      dMe(j)   = dMe(j)-dMe(j-1)
  end do
  dMe(1) = dMe(1) + sum(dM1_sort(1:n))
  qdMe(1)= qdMe(1) + sum(q_sort(1:n)*dM1_sort(1:n))
  
  dQedY(1) = (Qe(1)-Qe(2))/(sin_lat(1)-sin_lat(2))*cos_lat(1)
  dQedY(nj)= (Qe(nj-1)-Qe(nj))/(sin_lat(nj-1)-sin_lat(nj))*cos_lat(nj)
  dQedY(2:(nj-1)) = (Qe(1:(nj-2))-Qe(3:nj))/(sin_lat(1:(nj-2))-sin_lat(3:nj))*cos_lat(2:(nj-1));
  
! Wave activity
  Ae(nj) = qdMe(nj+1)-qdMb(nj+1)
  do j = nj-1,1,-1
    Ae(j) = Ae(j+1)+(qdMe(j+1)-qdMb(j+1))
  end do
  Ae = Ae*RADIUS/(2*pi)/cos_lat

end subroutine tracer_eq_1var_2d

subroutine tracer_eq_1var_3d(lon, lat, lonb, latb, q_tracer, qz, Qe, Ae, dQedY, sort_ascend)
real, intent(in), dimension(:) :: lon,lat,lonb,latb
real, intent(in), dimension(:,:,:) :: q_tracer
real, intent(out), dimension(:,:) :: qz, Qe, Ae, dQedY
logical, intent(in), optional :: sort_ascend

integer :: k

  do k=1, size(q_tracer,3)
    if(present(sort_ascend)) then
        call tracer_eq_1var_2d(lon, lat, lonb, latb, q_tracer(:,:,k), qz(:,k), Qe(:,k), Ae(:,k), &
        dQedY(:,k), sort_ascend)
    else
        call tracer_eq_1var_2d(lon, lat, lonb, latb, q_tracer(:,:,k), qz(:,k), Qe(:,k), Ae(:,k), &
        dQedY(:,k))
    endif
  end do

end subroutine tracer_eq_1var_3d
