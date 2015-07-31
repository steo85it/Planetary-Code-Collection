pure real(8) function flux_noatm(R,decl,latitude,HA,surfaceSlope,azFac)
!***********************************************************************
!   flux:  program to calculate incoming solar flux without atmosphere
!     R: distance from sun (AU)
!     decl: planetocentric solar declination (radians)
!     latitude: (radians)
!     HA: hour angle (radians from noon, clockwise)
!     surfaceSlope: >0, (radians) 
!     azFac: azimuth of topographic gradient (radians east of north)
!***********************************************************************
  implicit none
  real(8), parameter :: So=1365.  ! solar constant
  real(8), parameter :: pi=3.1415926535897931, d2r=pi/180.
  real(8), intent(IN) :: R,decl,latitude,HA,surfaceSlope,azFac
  real(8) c1,s1,sinbeta,cosbeta,sintheta,azSun,buf
  
  c1=cos(latitude)*cos(decl)
  s1=sin(latitude)*sin(decl)
  ! beta = 90 minus incidence angle for horizontal surface
  ! beta = elevation of sun above (horizontal) horizon 
  sinbeta = c1*cos(HA) + s1
  
  cosbeta = sqrt(1-sinbeta**2)
  ! ha -> az (option 1)
  !azSun=asin(-cos(decl)*sin(ha)/cosbeta)
  ! ha -> az (option 2)
  buf = (sin(decl)-sin(latitude)*sinbeta)/(cos(latitude)*cosbeta)
  ! buf can be NaN if cosbeta = 0
  if (buf>+1.) buf=1.d0; if (buf<-1.) buf=-1.d0; ! damn roundoff
  azSun = acos(buf)
  if (sin(HA)>=0) azSun=2*pi-azSun
  ! ha -> az (option 3)  without beta
  !azSun=sin(latitude)*cos(decl)*cos(ha)-cos(latitude)*sin(decl)
  !azSun=atan(sin(ha)*cos(decl)/azSun)

  ! theta = 90 minus incidence angle for sloped surface
  sintheta = cos(surfaceSlope)*sinbeta + &
       &     sin(surfaceSlope)*cosbeta*cos(azSun-azFac)
  if (cosbeta==0.) sintheta = cos(surfaceSlope)*sinbeta
  sintheta = max(sintheta,0.d0)  ! horizon
  if (sinbeta<0.) sintheta=0.  ! horizontal horizon at infinity
  
  flux_noatm = sintheta*So/(R**2)
  
  !write(6,'(99(1x,f6.2))') decl/d2r,HA/d2r,flux_noatm, &
  !     &     asin(sintheta)/d2r,asin(sinbeta)/d2r,azSun/d2r,buf
end function flux_noatm

