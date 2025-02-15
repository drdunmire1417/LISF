!-----------------------BEGIN NOTICE -- DO NOT EDIT-----------------------
! NASA Goddard Space Flight Center
! Land Information System Framework (LISF)
! Version 7.3
!
! Copyright (c) 2020 United States Government as represented by the
! Administrator of the National Aeronautics and Space Administration.
! All Rights Reserved.
!-------------------------END NOTICE -- DO NOT EDIT-----------------------
!BOP
! !ROUTINE: noahmp401_qc_Sig0obs
! \label{noahmp401_qc_Sig0obs}
!
! !REVISION HISTORY:
! 26/03/2021 Sara Modanesi: Initial specifications
! 02/04/2021 Sara Modanesi: added specifications for both Sig0VV and Sig0VH S1 obs and removed flag for veg. cover
!
! !INTERFACE:
subroutine noahmp401_qc_Sig0VVVHobs(n,k,OBS_State)
! !USES:
  use ESMF
  use LIS_coreMod
  use LIS_logMod,  only : LIS_verify
  use LIS_constantsMod, only : LIS_CONST_TKFRZ
  use LIS_DAobservationsMod
  use noahmp401_lsmMod
  use module_sf_noahmplsm_401  !, only: MAXSMC !MN
  use noahmp_tables_401


  implicit none
! !ARGUMENTS: 
  integer, intent(in)      :: n
  integer, intent(in)      :: k
  type(ESMF_State)         :: OBS_State
!
! !DESCRIPTION:
!
!  This subroutine performs any model-based QC of the observation 
!  prior to data assimilation. Here the backscatter observations
!  are flagged when LSM indicates that (1) rain is falling (2)
!  soil is frozen or (3) ground is fully or partially covered 
!  
!  The arguments are: 
!  \begin{description}
!  \item[n] index of the nest \newline
!  \item[OBS\_State] ESMF state container for observations \newline
!  \end{description}
!
!EOP
  type(ESMF_Field)         :: s_vvField,s_vhField

  real, pointer            :: s_vv(:),s_vh(:)
  integer                  :: t
  integer                  :: gid
  integer                  :: status
  real                     :: lat,lon

! mn
  integer                 :: SOILTYP           ! soil type index [-]
  real                     :: smc1(LIS_rc%npatch(n,LIS_rc%lsm_index))
  real                     :: smc2(LIS_rc%npatch(n,LIS_rc%lsm_index))
  real                     :: smc3(LIS_rc%npatch(n,LIS_rc%lsm_index))
  real                     :: smc4(LIS_rc%npatch(n,LIS_rc%lsm_index))
  real                     :: sh2o1(LIS_rc%npatch(n,LIS_rc%lsm_index))
  real                     :: sh2o2(LIS_rc%npatch(n,LIS_rc%lsm_index))
  real                     :: sh2o3(LIS_rc%npatch(n,LIS_rc%lsm_index))
  real                     :: sh2o4(LIS_rc%npatch(n,LIS_rc%lsm_index))
  real                     :: stc1(LIS_rc%npatch(n,LIS_rc%lsm_index))
  real                     :: stc2(LIS_rc%npatch(n,LIS_rc%lsm_index))
  real                     :: stc3(LIS_rc%npatch(n,LIS_rc%lsm_index))
  real                     :: stc4(LIS_rc%npatch(n,LIS_rc%lsm_index))
  real                     :: vegt(LIS_rc%npatch(n,LIS_rc%lsm_index))
  real                     :: SMCMAX(LIS_rc%npatch(n,LIS_rc%lsm_index))
  real                     :: SMCWLT(LIS_rc%npatch(n,LIS_rc%lsm_index))
  real                     :: slope(LIS_rc%npatch(n,LIS_rc%lsm_index))

  real                     :: rainf_obs(LIS_rc%obs_ngrid(k))
  real                     :: sneqv_obs(LIS_rc%obs_ngrid(k))
  real                     :: sca_obs(LIS_rc%obs_ngrid(k))
!  real                     :: shdfac_obs(LIS_rc%obs_ngrid(k)) !commented for now
  real                     :: t1_obs(LIS_rc%obs_ngrid(k))
  real                     :: smcwlt_obs(LIS_rc%obs_ngrid(k))
  real                     :: smcmax_obs(LIS_rc%obs_ngrid(k))
  real                     :: smc1_obs(LIS_rc%obs_ngrid(k))
  real                     :: smc2_obs(LIS_rc%obs_ngrid(k))
  real                     :: smc3_obs(LIS_rc%obs_ngrid(k))
  real                     :: smc4_obs(LIS_rc%obs_ngrid(k))
  real                     :: sh2o1_obs(LIS_rc%obs_ngrid(k))
  real                     :: sh2o2_obs(LIS_rc%obs_ngrid(k))
  real                     :: sh2o3_obs(LIS_rc%obs_ngrid(k))
  real                     :: sh2o4_obs(LIS_rc%obs_ngrid(k))
  real                     :: stc1_obs(LIS_rc%obs_ngrid(k))
  real                     :: stc2_obs(LIS_rc%obs_ngrid(k))
  real                     :: stc3_obs(LIS_rc%obs_ngrid(k))
  real                     :: stc4_obs(LIS_rc%obs_ngrid(k))
  real                     :: vegt_obs(LIS_rc%obs_ngrid(k))
  real                     :: slope_obs(LIS_rc%obs_ngrid(k))

  integer                  :: VV_agri_mask_start_doy
  integer                  :: VV_agri_mask_end_doy
  integer                  :: VV_mask_start_doy
  integer                  :: VV_mask_end_doy
  integer                  :: VH_mask_start_doy
  integer                  :: VH_mask_end_doy
!-----this part is derived from ./lis/dataassim/obs/s1_sigma/read_S1_sigma.F90
  call ESMF_StateGet(OBS_State,"Observation01",s_vvField,&
       rc=status) !
  call LIS_verify(status,&
       "ESMF_StateGet failed in noahmp401_qc_Sig0obs s_vv")

  call ESMF_StateGet(OBS_State,"Observation02",s_vhField,&
       rc=status) !
  call LIS_verify(status,&
       "ESMF_StateGet failed in noahmp401_qc_Sig0obs s_vh")

  call ESMF_FieldGet(s_vvField,localDE=0,farrayPtr=s_vv,rc=status)
  call LIS_verify(status,& 
       "ESMF_FieldGet failed in noahmp401_qc_Sigobs s_vv")

  call ESMF_FieldGet(s_vhField,localDE=0,farrayPtr=s_vh,rc=status)
  call LIS_verify(status,&
       "ESMF_FieldGet failed in noahmp401_qc_Sigobs s_vh")

!---------------------------------------------------------------------------  

  do t=1, LIS_rc%npatch(n,LIS_rc%lsm_index)
     smc1(t) = noahmp401_struc(n)%noahmp401(t)%smc(1)
     smc2(t) = noahmp401_struc(n)%noahmp401(t)%smc(2)
     smc3(t) = noahmp401_struc(n)%noahmp401(t)%smc(3)
     smc4(t) = noahmp401_struc(n)%noahmp401(t)%smc(4)

     sh2o1(t) = noahmp401_struc(n)%noahmp401(t)%sh2o(1)
     sh2o2(t) = noahmp401_struc(n)%noahmp401(t)%sh2o(2)
     sh2o3(t) = noahmp401_struc(n)%noahmp401(t)%sh2o(3)
     sh2o4(t) = noahmp401_struc(n)%noahmp401(t)%sh2o(4)
!--------------------------------------------------------------------------------------------------------- 
       ! MN  NOTE:sstc contain soil and snow temperature first snow 
       !          temperature and then soil temeprature.
       !          But the number of snow layers changes from 0 to 3 
!---------------------------------------------------------------------------------------------------------
     stc1(t) = noahmp401_struc(n)%noahmp401(t)%tslb(1)
     stc2(t) = noahmp401_struc(n)%noahmp401(t)%tslb(2)
     stc3(t) = noahmp401_struc(n)%noahmp401(t)%tslb(3)
     stc4(t) = noahmp401_struc(n)%noahmp401(t)%tslb(4)


     vegt(t) = noahmp401_struc(n)%noahmp401(t)%vegetype

     SOILTYP = NOAHMP401_struc(n)%noahmp401(t)%soiltype        
     SMCMAX(t)  = SMCMAX_TABLE(SOILTYP) 
     !SMCWLT(t) = NoahMP401_struc(n)%noahmp401(t)%param%smcwlt
     SMCWLT(t) = SMCWLT_TABLE(SOILTYP)
     slope(t) = LIS_surface(n,LIS_rc%lsm_index)%tile(t)%slope
  enddo

  call LIS_convertPatchSpaceToObsSpace(n,k,&       
       LIS_rc%lsm_index, &
       noahmp401_struc(n)%noahmp401(:)%prcp,&
       rainf_obs)  ! MN prcp is total precip 
  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       noahmp401_struc(n)%noahmp401(:)%sneqv,&
       sneqv_obs)
  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       noahmp401_struc(n)%noahmp401(:)%snowc,&
       sca_obs)
!  call LIS_convertPatchSpaceToObsSpace(n,k,&  !out-commented for now
!       LIS_rc%lsm_index, &
!       noahmp401_struc(n)%noahmp401(:)%fveg,&
!       shdfac_obs)
  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       noahmp401_struc(n)%noahmp401(:)%tg,&
       t1_obs)
  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       smcmax, &
       smcmax_obs)
  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       smcwlt,&
       smcwlt_obs)
  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       smc1,&
       smc1_obs)
  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       smc2,&
       smc2_obs)
  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       smc3,&
       smc3_obs)
  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       smc4,&
       smc4_obs)
  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       sh2o1,&
       sh2o1_obs)
  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       sh2o2,&
       sh2o2_obs)
  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       sh2o3,&
       sh2o3_obs)
  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       sh2o4,&
       sh2o4_obs)
  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       stc1,&
       stc1_obs)
  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       stc2,&
       stc2_obs)
  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       stc3,&
       stc3_obs)
  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       stc4,&
       stc4_obs)

  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       vegt,&
       vegt_obs)

  call LIS_convertPatchSpaceToObsSpace(n,k,&
       LIS_rc%lsm_index, &
       slope,&
       slope_obs)

  do t = 1,LIS_rc%obs_ngrid(k)
!------------------start loop considering s_vv--------------------------
     if(s_vv(t).ne.LIS_rc%udef) then 
! MN: check for rain
        if(rainf_obs(t).gt.3E-6) then   ! Var name Noah401 --> rainf 
           s_vv(t) = LIS_rc%udef
!           print*, 'rainf ',gid,t,NOAHMP401_struc(n)%noahmp401(t)%prcp
! MN: check for frozen soil
        elseif(abs(smc1_obs(t)- &
             sh2o1_obs(t)).gt.0.0001) then
           s_vv(t) = LIS_rc%udef
        elseif(abs(smc2_obs(t)- &
             sh2o2_obs(t)).gt.0.0001) then
           s_vv(t) = LIS_rc%udef
        elseif(abs(smc3_obs(t)- &
             sh2o3_obs(t)).gt.0.0001) then
           s_vv(t) = LIS_rc%udef
        elseif(abs(smc4_obs(t)- &
             sh2o4_obs(t)).gt.0.0001) then
           s_vv(t) = LIS_rc%udef
        elseif(stc1_obs(t).le.LIS_CONST_TKFRZ) then
           s_vv(t) = LIS_rc%udef
        elseif(stc2_obs(t).le.LIS_CONST_TKFRZ) then
           s_vv(t) = LIS_rc%udef
        elseif(stc3_obs(t).le.LIS_CONST_TKFRZ) then
           s_vv(t) = LIS_rc%udef
        elseif(stc4_obs(t).le.LIS_CONST_TKFRZ) then
           s_vv(t) = LIS_rc%udef 
        elseif(t1_obs(t).le.LIS_CONST_TKFRZ) then ! Var name Noah401 --> t1
           s_vv(t) = LIS_rc%udef
        elseif(vegt_obs(t).le.4) then !forest types ! Var name Noah401 --> vegt
           s_vv(t) = LIS_rc%udef
        elseif(vegt_obs(t).eq.13) then !urban ! Var name Noah401 --> vegt
           s_vv(t) = LIS_rc%udef
        elseif(vegt_obs(t).eq.17) then !water ! Var name Noah401 --> vegt
           s_vv(t) = LIS_rc%udef
 ! MN: check for snow  
        elseif(sneqv_obs(t).gt.0.001) then 
           s_vv(t) = LIS_rc%udef
        elseif(sca_obs(t).gt.0.0001) then  ! Var name sca 
           s_vv(t) = LIS_rc%udef
 ! MB: check for slope, S1 backscatter and water cloud model not reliable for SM and LAI updating over mountains
        elseif(slope_obs(t).gt.0.1) then
           s_vv(t) = LIS_rc%udef
        endif
     endif
!------------------start loop considering s_vh--------------------------
     if(s_vh(t).ne.LIS_rc%udef) then
! MN: check for rain
        if(rainf_obs(t).gt.3E-6) then   ! Var name Noah401 --> rainf 
           s_vh(t) = LIS_rc%udef
!           print*, 'rainf ',gid,t,NOAHMP401_struc(n)%noahmp401(t)%prcp
! MN: check for frozen soil
        elseif(abs(smc1_obs(t)- &
             sh2o1_obs(t)).gt.0.0001) then
           s_vh(t) = LIS_rc%udef
        elseif(abs(smc2_obs(t)- &
             sh2o2_obs(t)).gt.0.0001) then
           s_vh(t) = LIS_rc%udef
        elseif(abs(smc3_obs(t)- &
             sh2o3_obs(t)).gt.0.0001) then
           s_vh(t) = LIS_rc%udef
        elseif(abs(smc4_obs(t)- &
             sh2o4_obs(t)).gt.0.0001) then
           s_vh(t) = LIS_rc%udef
        elseif(stc1_obs(t).le.LIS_CONST_TKFRZ) then
           s_vh(t) = LIS_rc%udef
        elseif(stc2_obs(t).le.LIS_CONST_TKFRZ) then
           s_vh(t) = LIS_rc%udef
        elseif(stc3_obs(t).le.LIS_CONST_TKFRZ) then
           s_vh(t) = LIS_rc%udef
        elseif(stc4_obs(t).le.LIS_CONST_TKFRZ) then
           s_vh(t) = LIS_rc%udef
        elseif(t1_obs(t).le.LIS_CONST_TKFRZ) then ! Var name Noah401 --> t1
           s_vh(t) = LIS_rc%udef
        elseif(vegt_obs(t).le.4) then !forest types ! Var name Noah401 --> vegt
           s_vh(t) = LIS_rc%udef
        elseif(vegt_obs(t).eq.13) then !urban ! Var name Noah401 --> vegt
           s_vh(t) = LIS_rc%udef
        elseif(vegt_obs(t).eq.17) then !water ! Var name Noah401 --> vegt
           s_vh(t) = LIS_rc%udef
 ! MN: check for snow  
        elseif(sneqv_obs(t).gt.0.001) then
           s_vh(t) = LIS_rc%udef
        elseif(sca_obs(t).gt.0.0001) then  ! Var name sca 
           s_vh(t) = LIS_rc%udef
 ! MB: check for slope, S1 backscatter and water cloud model not reliable for SM and LAI updating over mountains
        elseif(slope_obs(t).gt.0.1) then
           s_vh(t) = LIS_rc%udef
        endif
     endif
  enddo

end subroutine noahmp401_qc_Sig0VVVHobs

