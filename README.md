# WRFHYDRO-4.4-install-script
This is a script that installs all the libararies, software, programs, and geostatic data to run the Weather Research Forecast Model Hydro (WRF-4.4.1) with the option to run 3DVAR & 4DVAR observational data. 
Script assumes a clean directory with no other WRF configure files in the directory.
**This script does not install NETCDF4 to write compressed NetCDF4 files in parallel**

# Installation 
(Make sure to download folder into your Home Directory): $HOME


> git clone https://github.com/HathewayWill/WRFHYDRO-Coupled-5.2-install-script-linux-64bit.git

> cd $HOME/WRFHYDRO-Coupled-5.2-install-script-linux-64bit

> chmod 775 *.sh
>
> ./ WRFHYDRO_COUPLE_WRF_INSTALL.sh

# Please make sure to read the WRF_ARW_INSTALL.sh script before installing.  
I have provided comments on what the script is doing and information on configuration files.


# WRF installation with parallel process (dmpar).
Must be installed with GNU compiler, it will not work with other compilers.


-  ### *** Tested on Ubuntu 20.04.4 LTS & Ubuntu 22.04 LTS. ***
- Built in 64-bit system.
- Tested with current available libraries on 08/01/2022, execptions have been noted in the script documentation. 
- If newer libraries exist edit script paths for changes in future.

# Post-Processing Software Included
## RIP4
User Guide: https://www2.mmm.ucar.edu/wrf/users/docs/ripug.htm
## UPP v4.1
User Guide: https://dtcenter.org/sites/default/files/community-code/upp-users-guide-v4.1.pdf
## ARWpost v3.1
Added to $PATH and ~/.bashrc for easy access
## Model Evaluation Tools (MET) & Model Evaluation Tools Plus (MET Plus)
Added to $PATH and ~./bashrc for easy access
Users Guide (MET): https://met.readthedocs.io/en/main_v10.1/Users_Guide/index.html
Users Guide (MET Plus): https://metplus.readthedocs.io/en/v4.1.1/Users_Guide/index.html
## OpenGRADS v.2.2.1
Added to $PATH and ~/.bashrc for easy access
Users Guide: http://www.opengrads.org/manual/
## NCAR COMMAND LANGUAGE (NCL) v.6.6.2
 Installed via CONDA package using miniconda3
 Conda environment ncl_stable
 Users Guide: https://www.ncl.ucar.edu/Document/Manuals/NCL_User_Guide/
## WRF Python
 Installed via CONDA package using miniconda3
 Conda environment wrf-python
Users Guide: https://wrf-python.readthedocs.io/en/latest/index.html

## WRF Hydro GIS Preprocessor
 Installed via CONDA package using miniconda3
 Conda environment wrfh_gis_env
Users Guide: https://github.com/NCAR/wrf_hydro_gis_preprocessor & https://ral.ucar.edu/projects/wrf_hydro/pre-processing-tools

## WRFPortal & WRFDomainWizard
User Guide: https://esrl.noaa.gov/gsd/wrfportal/

### Sponsorships and donations accepted but NOT required
[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/HathewayWill)


# Estimated Run Time ~ 90 - 150 Minutes @ 10mbps download speed.
### - Special thanks to  Youtube's meteoadriatic, GitHub user jamal919, University of Manchester's  Doug L, University of Tunis El Manar's Hosni S.


