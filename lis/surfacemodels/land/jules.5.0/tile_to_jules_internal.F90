!-----------------------BEGIN NOTICE -- DO NOT EDIT-----------------------
! NASA Goddard Space Flight Center
! Land Information System Framework (LISF)
! Version 7.4
!
! Copyright (c) 2022 United States Government as represented by the
! Administrator of the National Aeronautics and Space Administration.
! All Rights Reserved.
!-------------------------END NOTICE -- DO NOT EDIT-----------------------

subroutine tile_to_jules_internal(n, t, pft)
  use jules_internal
  use jules50_lsmMod
  use jules_snow_mod, only: cansnowtile
  use jules_surface_types_mod,  only: npft, nnvg, ntype
  implicit none 
  integer :: n, t, pft

  if ((any(cansnowtile(1:npft)) .eqv. .true.).and. (pft .le. npft)) then
    unload_backgrnd_pft(1,pft) = jules50_struc(n)%jules50(t)%unload_backgrnd(pft)  
  else
    unload_backgrnd_pft(1,:) = jules50_struc(n)%jules50(t)%unload_backgrnd(:)  
  endif
end subroutine tile_to_jules_internal

