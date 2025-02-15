!-----------------------BEGIN NOTICE -- DO NOT EDIT-----------------------
! NASA Goddard Space Flight Center
! Land Information System Framework (LISF)
! Version 7.4
!
! Copyright (c) 2022 United States Government as represented by the
! Administrator of the National Aeronautics and Space Administration.
! All Rights Reserved.
!-------------------------END NOTICE -- DO NOT EDIT-----------------------

subroutine tile_to_top_pdm(n, t)
  use top_pdm 
  use jules50_lsmMod
  implicit none 
  integer :: n, t, pft 

  fexp_soilt(1,1)            = jules50_struc(n)%jules50(t)%fexp           ! Decay factor in Sat. Conductivity in water table layer
  gamtot_soilt(1,1)          = jules50_struc(n)%jules50(t)%gamtot         ! integrated complete gamma function dbc gamtot doesn't need to be in a module in this version, but left there for now for compatability.
  ti_mean_soilt(1,1)         = jules50_struc(n)%jules50(t)%ti_mean        ! Mean topographic index
  ti_sig_soilt(1,1)          = jules50_struc(n)%jules50(t)%ti_sig         ! Standard dev. of topographic index
  fsat_soilt(1,1)            = jules50_struc(n)%jules50(t)%fsat           ! Surface saturation fraction
  fwetl_soilt(1,1)           = jules50_struc(n)%jules50(t)%fwetl          ! Wetland fraction
  zw_soilt(1,1)              = jules50_struc(n)%jules50(t)%zw             ! Water table depth (m)
  drain_soilt(1,1)           = jules50_struc(n)%jules50(t)%drain          ! Drainage out of bottom (nshyd) soil layer (kg m-2/s)
  dun_roff_soilt(1,1)        = jules50_struc(n)%jules50(t)%dun_roff       ! Dunne part of sfc runoff (kg m-2/s)
  qbase_soilt(1,1)           = jules50_struc(n)%jules50(t)%qbase          ! Base flow (kg m-2/s)
  qbase_zw_soilt(1,1)        = jules50_struc(n)%jules50(t)%qbase_zw       ! Base flow from ZW layer (kg m-2/s)
  fch4_wetl_soilt(1,1)       = jules50_struc(n)%jules50(t)%fch4_wetl      ! Scaled wetland methane flux (10^-9 kg C/m2/s)
  fch4_wetl_cs_soilt(1,1)    = jules50_struc(n)%jules50(t)%fch4_wetl_cs_soilt ! Scaled wetland methane flux using soil carbon as substrate (kg C/m2/s).
  fch4_wetl_npp_soilt(1,1)   = jules50_struc(n)%jules50(t)%fch4_wetl_npp_soilt ! Scaled wetland methane flux using NPP as substrate (kg C/m2/s).
  fch4_wetl_resps_soilt(1,1) = jules50_struc(n)%jules50(t)%fch4_wetl_resps_soilt  ! Scaled wetland methane flux using soil respiration as substrate (kg C/m2/s) 
  inlandout_atm_gb(1)        = jules50_struc(n)%jules50(t)%inlandout_atm  ! TRIP inland basin outflow (for land points only)(kg m-2/s)
  sthzw_soilt(1,1)           = jules50_struc(n)%jules50(t)%sthzw          ! soil moist fraction in deep (water table) layer.
  a_fsat_soilt(1,1)          = jules50_struc(n)%jules50(t)%a_fsat         ! Fitting parameter for Fsat in LSH model
  c_fsat_soilt(1,1)          = jules50_struc(n)%jules50(t)%c_fsat         ! Fitting parameter for Fsat in LSH model
  a_fwet_soilt(1,1)          = jules50_struc(n)%jules50(t)%a_fwet         ! Fitting parameter for Fwet in LSH model
  c_fwet_soilt(1,1)          = jules50_struc(n)%jules50(t)%c_fwet         ! Fitting parameter for Fwet in LSH model
end subroutine tile_to_top_pdm


