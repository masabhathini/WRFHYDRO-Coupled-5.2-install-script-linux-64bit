#!/bin/bash
start=`date`
START=$(date +"%s")

## WRF-Hydro installation with parallel process.
# Download and install required library and data files for WRF-Hydro.
# *** Tested on Ubuntu 20.04.4 LTS. &  Ubuntu 22.04 LTS***
# Built in 64-bit system
# Tested with current available libraries on 08/01/2022
# If newer libraries exist edit script paths for changes
#Estimated Run Time ~ 90 - 150 Minutes with 10mb/s downloadspeed.
#Special thanks to  Youtube's meteoadriatic and GitHub user jamal919

######################## DTC's MET & METplus ###########################
## See script for details

$HOME/WRFHYDRO-Coupled-5.2-install-script-linux-64bit/MET_self_install_script_Linux_64bit.sh

read -t 5 -p "Finished installing MET & METplus. I am going to wait for 5 seconds only ..."


#############################basic package managment############################
sudo apt -y update                                                                                                   
sudo apt -y upgrade                                                                                                    
sudo apt -y install apt gcc gfortran g++ libtool automake autoconf make m4 default-jre default-jdk csh ksh tcsh okular cmake time xorg openbox xauth git python3 python3-dev python2 python2-dev mlocate curl libcurl4-openssl-dev


##############################Directory Listing############################
export HOME=`cd;pwd`
mkdir $HOME/WRF-Hydro
export DIR=$HOME/WRF-Hydro/Libs
cd $HOME/WRF-Hydro
mkdir Downloads
mkdir WRFPLUS
mkdir $HOME/WRF-Hydro/Hydro-Basecode
mkdir WRFDA
mkdir Libs
mkdir Libs/grib2
mkdir Libs/NETCDF
mkdir Libs/MPICH

#############################Core Management####################################

export CPU_CORE=$(nproc)                                             #number of available cores on system
export CPU_6CORE="6"
export CPU_HALF=$(($CPU_CORE / 2))                                   #half of availble cores on system
export CPU_HALF_EVEN=$(( $CPU_HALF - ($CPU_HALF % 2) ))              #Forces CPU cores to even number to avoid partial core export. ie 7 cores would be 3.5 cores.

if [ $CPU_CORE -le $CPU_6CORE ]                                  #If statement for low core systems.  Forces computers to only use 1 core if there are 4 cores or less on the system.
then
  export CPU_HALF_EVEN="2"
else
  export CPU_HALF_EVEN=$(( $CPU_HALF - ($CPU_HALF % 2) )) 
fi


echo "##########################################"
echo "Number of cores being used $CPU_HALF_EVEN"
echo "##########################################"


##############################Downloading Libraries############################
cd Downloads
wget -c -4 https://github.com/madler/zlib/archive/refs/tags/v1.2.12.tar.gz
wget -c -4 https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-1_12_2.tar.gz
wget -c -4 https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.9.0.tar.gz
wget -c -4 https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.6.0.tar.gz
wget -c -4 https://github.com/pmodels/mpich/releases/download/v4.0.2/mpich-4.0.2.tar.gz
wget -c -4 https://download.sourceforge.net/libpng/libpng-1.6.37.tar.gz
wget -c -4 https://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.1.zip
wget -c -4 https://sourceforge.net/projects/opengrads/files/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz




#############################Compilers############################
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran
export F90=gfortran

#IF statement for GNU compiler issue
export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(/usr/bin/gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(/usr/bin/g++ -dumpfullversion | awk '{print$1}')

export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')

export version_10="10"

if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ]
then
  export fallow_argument=-fallow-argument-mismatch 
  export boz_argument=-fallow-invalid-boz
else 
  export fallow_argument=
  export boz_argument=
fi


export FFLAGS=$fallow_argument
export FCFLAGS=$fallow_argument


echo "##########################################"
echo "FFLAGS = $FFLAGS"
echo "FCFLAGS = $FCFLAGS"
echo "##########################################"



#############################zlib############################
#Uncalling compilers due to comfigure issue with zlib1.2.12
#With CC & CXX definied ./configure uses different compiler Flags

cd $HOME/WRF-Hydro/Downloads
tar -xvzf v1.2.12.tar.gz
cd zlib-1.2.12/
CC= CXX= ./configure --prefix=$DIR/grib2
make -j $CPU_HALF_EVEN
make -j $CPU_HALF_EVEN install
#make check


##############################MPICH############################
cd $HOME/WRF-Hydro/Downloads
tar -xvzf mpich-4.0.2.tar.gz
cd mpich-4.0.2/
F90= ./configure --prefix=$DIR/MPICH --with-device=ch3 FFLAGS=$fallow_argument FCFLAGS=$fallow_argument

make -j $CPU_HALF_EVEN
make -j $CPU_HALF_EVEN install
#make check


export PATH=$DIR/MPICH/bin:$PATH

export MPIFC=$DIR/MPICH/bin/mpifort
export MPIF77=$DIR/MPICH/bin/mpifort
export MPIF90=$DIR/MPICH/bin/mpifort
export MPICC=$DIR/MPICH/bin/mpicc
export MPICXX=$DIR/MPICH/bin/mpicxx



#############################libpng############################
cd $HOME/WRF-Hydro/Downloads
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar -xvzf libpng-1.6.37.tar.gz
cd libpng-1.6.37/
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX ./configure --prefix=$DIR/grib2
make -j $CPU_HALF_EVEN
make -j $CPU_HALF_EVEN install
#make check

#############################JasPer############################
cd $HOME/WRF-Hydro/Downloads
unzip jasper-1.900.1.zip
cd jasper-1.900.1/
autoreconf -i
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX ./configure --prefix=$DIR/grib2
make -j $CPU_HALF_EVEN
make -j $CPU_HALF_EVEN install
#make check

export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include



#############################hdf5 library for netcdf4 functionality############################
cd $HOME/WRF-Hydro/Downloads
tar -xvzf hdf5-1_12_2.tar.gz
cd hdf5-hdf5-1_12_2
CC=$MPICC FC=$MPIFC F77=$MPIF77 F90=$MPIF90 CXX=$MPICXX ./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran
make -j $CPU_HALF_EVEN
make -j $CPU_HALF_EVEN install
#make check

export HDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH



##############################Install NETCDF C Library############################
cd $HOME/WRF-Hydro/Downloads
tar -xzvf v4.9.0.tar.gz
cd netcdf-c-4.9.0/
export CPPFLAGS=-I$DIR/grib2/include 
export LDFLAGS=-L$DIR/grib2/lib
export LIBS="-lhdf5_hl -lhdf5 -lz -lcurl -lgfortran -lgcc -lm -ldl"
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 ./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared
make -j $CPU_HALF_EVEN
make -j $CPU_HALF_EVEN install
#make check

export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF

##############################NetCDF fortran library############################
cd $HOME/WRF-Hydro/Downloads
tar -xvzf v4.6.0.tar.gz
cd netcdf-fortran-4.6.0/
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS="-I$DIR/NETCDF/include -I$DIR/grib2/include"
export LDFLAGS="-L$DIR/NETCDF/lib -L$DIR/grib2/lib"
export LIBS="-lnetcdf -lm -lcurl -lhdf5_hl -lhdf5 -lz -ldl"
CC=$MPICC FC=$MPIFC CXX=$MPICXX F90=$MPIF90 F77=$MPIF77 ./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared
make -j $CPU_HALF_EVEN
make -j $CPU_HALF_EVEN install
#make check





###############################NCEPlibs#####################################
#The libraries are built and installed with
# ./make_ncep_libs.sh -s MACHINE -c COMPILER -d NCEPLIBS_DIR -o OPENMP [-m mpi] [-a APPLICATION]
#It is recommended to install the NCEPlibs into their own directory, which must be created before running the installer. Further information on the command line arguments can be obtained with
# ./make_ncep_libs.sh -h

#If iand error occurs go to https://github.com/NCAR/NCEPlibs/pull/16/files make adjustment and re-run ./make_ncep_libs.sh
############################################################################


cd $HOME/WRF-Hydro/Downloads
git clone https://github.com/NCAR/NCEPlibs.git
cd NCEPlibs
mkdir $DIR/nceplibs


export JASPER_INC=$DIR/grib2/include
export PNG_INC=$DIR/grib2/include
export NETCDF=$DIR/NETCDF

#for loop to edit linux.gnu for nceplibs to install
#make if statement for gcc-9 or older
export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(/usr/bin/gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(/usr/bin/g++ -dumpfullversion | awk '{print$1}')

export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')

export version_10="10"

if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ]
then
  y="24 28 32 36 40 45 49 53 56 60 64 68 69 73 74 79"
  for X in $y; do
    sed -i "${X}s/= /= $fallow_argument $boz_argument /g" $HOME/WRF-Hydro/Downloads/NCEPlibs/macros.make.linux.gnu
  done
else
  echo "" 
  echo "Loop not needed"
fi

./make_ncep_libs.sh -s linux -c gnu -d $DIR/nceplibs -o 0 -m 1 -a upp




################################UPPv4.1######################################
#Previous verison of UPP
#WRF Support page recommends UPPV4.1 due to too many changes to WRF and UPP code
#since the WRF was written
#Option 8 gfortran compiler with distributed memory
#############################################################################
cd $HOME/WRF-Hydro
git clone -b dtc_post_v4.1.0 --recurse-submodules https://github.com/NOAA-EMC/EMC_post UPPV4.1 
cd UPPV4.1
mkdir postprd
export NCEPLIBS_DIR=$DIR/nceplibs
export NETCDF=$DIR/NETCDF

./configure  #Option 8 gfortran compiler with distributed memory


#make if statement for gcc-9 or older
export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(/usr/bin/gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(/usr/bin/g++ -dumpfullversion | awk '{print$1}')

export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')

export version_10="10"

if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ]
then
  z="58 63"
  for X in $z; do 
    sed -i "${X}s/(FOPT)/(FOPT) $fallow_argument $boz_argument  /g" $HOME/WRF-Hydro/UPPV4.1/configure.upp
  done
else
  echo "" 
  echo "Loop not needed"
fi


./compile
cd $HOME/WRF-Hydro/UPPV4.1/scripts
chmod +x run_unipost





######################## ARWpost V3.1  ############################
## ARWpost
##Configure #3
###################################################################
cd $HOME/WRF-Hydro/Downloads
wget -c http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz
tar -xvzf ARWpost_V3.tar.gz -C $HOME/WRF-Hydro
cd $HOME/WRF-Hydro/ARWpost
./clean -a
sed -i -e 's/-lnetcdf/-lnetcdff -lnetcdf/g' $HOME/WRF-Hydro/ARWpost/src/Makefile
export NETCDF=$DIR/NETCDF
./configure  

export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(/usr/bin/gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(/usr/bin/g++ -dumpfullversion | awk '{print$1}')

export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')

export version_10="10"

if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ]
then
  sed -i '32s/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4/-ffree-form -O -fno-second-underscore -fconvert=big-endian -frecord-marker=4 -fallow-argument-mismatch /g' configure.arwp
fi


sed -i -e 's/-C -P -traditional/-P -traditional/g' $HOME/WRF-Hydro/ARWpost/configure.arwp
./compile


export PATH=$HOME/WRF-Hydro/ARWpost/ARWpost.exe:$PATH


################################OpenGrADS######################################
#Verison 2.2.1 64bit of Linux
#############################################################################
cd $HOME/WRF-Hydro/Downloads
tar -xzvf opengrads-2.2.1.oga.1-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz -C $HOME/WRF-Hydro
cd $HOME/WRF-Hydro
mv $HOME/WRF-Hydro/opengrads-2.2.1.oga.1  $HOME/WRF-Hydro/GrADS
cd GrADS/Contents
wget -c https://github.com/regisgrundig/SIMOP/blob/master/g2ctl.pl
chmod +x g2ctl.pl
wget -c https://sourceforge.net/projects/opengrads/files/wgrib2/0.1.9.4/wgrib2-v0.1.9.4-bin-x86_64-glibc2.5-linux-gnu.tar.gz
tar -xzvf wgrib2-v0.1.9.4-bin-x86_64-glibc2.5-linux-gnu.tar.gz
cd wgrib2-v0.1.9.4/bin
mv wgrib2 $HOME/WRF-Hydro/GrADS/Contents
cd $HOME/WRF-Hydro/GrADS/Contentss
rm wgrib2-v0.1.9.4-bin-x86_64-glibc2.5-linux-gnu.tar.gz
rm -r wgrib2-v0.1.9.4


export PATH=$HOME/WRF-Hydro/GrADS/Contents:$PATH


##################### NCAR COMMAND LANGUAGE           ##################
########### NCL compiled via Conda                    ##################
########### This is the preferred method by NCAR      ##################
########### https://www.ncl.ucar.edu/index.shtml      ##################

#Installing Miniconda3 to WRF-Hydro directory and updating libraries
source $HOME/WRFHYDRO-Coupled-5.2-install-script-linux-64bit/Miniconda3_Install.sh




#Installing NCL via Conda
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate base
conda create -n ncl_stable -c conda-forge ncl -y
conda activate ncl_stable
conda update -n ncl_stable --all -y
conda deactivate 
conda deactivate



############################## RIP4 #####################################
mkdir $HOME/WRF-Hydro/RIP4
cd $HOME/WRF-Hydro/Downloads
wget -c https://www2.mmm.ucar.edu/wrf/src/RIP_47.tar.gz
tar -xvzf RIP_47.tar.gz -C $HOME/WRF-Hydro/RIP4
cd $HOME/WRF-Hydro/RIP4/RIP_47
mv * ..
cd $HOME/WRF-Hydro/RIP4
rm -rd RIP_47
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda activate ncl_stable
conda install -c conda-forge ncl c-compiler fortran-compiler cxx-compiler -y


export RIP_ROOT=$HOME/WRF-Hydro/RIP4
export NETCDF=$DIR/NETCDF
export NCARG_ROOT=$HOME/WRF-Hydro/miniconda3/envs/ncl_stable


sed -i '349s|-L${NETCDF}/lib -lnetcdf $NETCDFF|-L${NETCDF}/lib $NETCDFF -lnetcdff -lnetcdf -lnetcdf -lnetcdff_C -lhdf5 |g' $HOME/WRF-Hydro/RIP4/configure

sed -i '27s|NETCDFLIB	= -L${NETCDF}/lib -lnetcdf CONFIGURE_NETCDFF_LIB|NETCDFLIB	= -L</usr/lib/x86_64-linux-gnu/libm.a> -lm -L${NETCDF}/lib CONFIGURE_NETCDFF_LIB -lnetcdf -lhdf5 -lhdf5_hl -lgfortran -lgcc -lz |g' $HOME/WRF-Hydro/RIP4/arch/preamble

sed -i '31s|-L${NCARG_ROOT}/lib -lncarg -lncarg_gks -lncarg_c -lX11 -lXext -lpng -lz CONFIGURE_NCARG_LIB| -L${NCARG_ROOT}/lib -lncarg -lncarg_gks -lncarg_c -lX11 -lXext -lpng -lz -lcairo -lfontconfig -lpixman-1 -lfreetype -lexpat -lpthread -lbz2 -lXrender -lgfortran -lgcc -L</usr/lib/x86_64-linux-gnu/> -lm -lhdf5 -lhdf5_hl |g' $HOME/WRF-Hydro/RIP4/arch/preamble

sed -i '33s| -O|-fallow-argument-mismatch -O |g' $HOME/WRF-Hydro/RIP4/arch/configure.defaults

sed -i '35s|=|= -L$HOME/WRF-Hydro/LIBS/grib2/lib -lhdf5 -lhdf5_hl |g' $HOME/WRF-Hydro/RIP4/arch/configure.defaults

./configure            #3  Will say that it fails but then command below will fix it.




./compile

conda deactivate
conda deactivate






##################### WRF Python           ##################
########### WRf-Python compiled via Conda  ##################
########### This is the preferred method by NCAR      ##################
##### https://wrf-python.readthedocs.io/en/latest/installation.html  ##################
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate base
conda create -n wrf-python -c conda-forge wrf-python -y
conda activate wrf-python
conda update -n wrf-python --all -y
conda deactivate
conda deactivate



########################## WRF Hydro GIS PreProcessor ##############################
#  Compiled with Conda
#  https://github.com/NCAR/wrf_hydro_gis_preprocessor
####################################################################################

conda init bash
conda activate base
conda create -n wrfh_gis_env -c conda-forge python=3.6 gdal netCDF4 numpy pyproj whitebox=1.5.0
conda activate wrfh_gis_env
conda update -n wrfh_gis_env --all
conda deactivate
conda deactivate

cd $HOME/WRF-Hydro
git clone https://github.com/NCAR/wrf_hydro_gis_preprocessor.git  $HOME/WRF-Hydro/WRF-Hydro-GIS-PreProcessor


############################# WRF HYDRO V5.2.0 #################################
# Version 5.2.0
# Standalone mode
################################################################################
export NETCDF_INC=$DIR/NETCDF/include
export NETCDF_LIB=$DIR/NETCDF/lib

cd $HOME/WRF-Hydro/Downloads
wget -c https://github.com/NCAR/wrf_hydro_nwm_public/archive/refs/tags/v5.2.0.tar.gz -O WRFHYDRO.5.2.tar.gz
tar -xvzf WRFHYDRO.5.2.tar.gz -C $HOME/WRF-Hydro/Hydro-Basecode


#Modifying WRF-HYDRO Environment
#Echo commands use due to lack of knowledge
cd $HOME/WRF-Hydro/Hydro-Basecode/wrf_hydro_nwm_public-5.2.0/trunk/NDHMS/template

sed -i 's/SPATIAL_SOIL=0/SPATIAL_SOIL=1/g' setEnvar.sh                      # Spatially distributed parameters for NoahMP: 0=Off, 1=On.
sed -i 's/WRF_HYDRO_NUDGING=0/WRF_HYDRO_NUDGING=1/g' setEnvar.sh                     # Streamflow nudging: 0=Off, 1=On.
echo " " >> setEnvar.sh
echo "# Large netcdf file support: 0=Off, 1=On." >> setEnvar.sh
echo "export WRFIO_NCD_LARGE_FILE_SUPPORT=1" >> setEnvar.sh
cp -r setEnvar.sh $HOME/WRF-Hydro/Hydro-Basecode/wrf_hydro_nwm_public-5.2.0/trunk/NDHMS


read -t 5 -p "I am going to wait for 5 seconds only ..."

############################ WRF 4.4  #################################
## WRF v4.4
## Downloaded from git tagged releases
# option 34, option 1 for gfortran and distributed memory w/basic nesting
# large file support enable with WRFiO_NCD_LARGE_FILE_SUPPORT=1
########################################################################
cd $HOME/WRF-Hydro/Downloads
wget -c https://github.com/wrf-model/WRF/releases/download/v4.4/v4.4.tar.gz -O WRF-4.4.tar.gz
tar -xvzf WRF-4.4.tar.gz -C $HOME/WRF-Hydro
cd $HOME/WRF-Hydro/WRFV4.4
export WRFIO_NCD_LARGE_FILE_SUPPORT=1

#Replace old version of WRF-Hydro distributed with WRF with updated WRF-Hydro source code
rm -r $HOME/WRF-Hydro/WRFV4.4/hydro/
cp -r $HOME/WRF-Hydro/Hydro-Basecode/wrf_hydro_nwm_public-5.2.0/trunk/NDHMS $HOME/WRF-Hydro/WRFV4.4/hydro

cd $HOME/WRF-Hydro/WRFV4.4/hydro
source setEnvar.sh
cd $HOME/WRF-Hydro/WRFV4.4

./clean -a
./configure # option 34, option 1 for gfortran and distributed memory w/basic nesting
./compile -j $CPU_HALF_EVEN em_real

export WRF_DIR=$HOME/WRF-Hydro/WRFV4.4

read -t 5 -p "I am going to wait for 5 seconds only ..."

############################WPSV4.4#####################################
## WPS v4.4
## Downloaded from git tagged releases
#Option 3 for gfortran and distributed memory 
########################################################################

cd $HOME/WRF-Hydro/Downloads
wget -c https://github.com/wrf-model/WPS/archive/refs/tags/v4.4.tar.gz -O WPS-4.4.tar.gz
tar -xvzf WPS-4.4.tar.gz -C $HOME/WRF-Hydro
cd $HOME/WRF-Hydro/WPS-4.4
./clean -a
./configure #Option 3 for gfortran and distributed memory 
./compile


read -t 5 -p "I am going to wait for 5 seconds only ..."

############################WRFPLUS 4DVAR###############################
## WRFPLUS v4.4 4DVAR
## Downloaded from git tagged releases
## WRFPLUS is built within the WRF git folder
## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice. 
#Option 18 for gfortran/gcc and distribunted memory 
########################################################################
cd $HOME/WRF-Hydro/Downloads
tar -xvzf WRF-4.4.tar.gz -C $HOME/WRF-Hydro/WRFPLUS
cd $HOME/WRF-Hydro/WRFPLUS/WRFV4.4
mv * $HOME/WRF-Hydro/WRFPLUS
cd $HOME/WRF-Hydro/WRFPLUS
rm -r WRFV4.4/
export NETCDF=$DIR/NETCDF
export HDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
./clean -a
./configure wrfplus  #Option 18 for gfortran/gcc and distribunted memory 
./compile -j $CPU_HALF_EVEN wrfplus   
export WRFPLUS_DIR=$HOME/WRF-Hydro/WRFPLUS




read -t 5 -p "I am going to wait for 5 seconds only ..."
############################WRFDA 4DVAR###############################
## WRFDA v4.4 4DVAR
## Downloaded from git tagged releases
## WRFDA is built within the WRFPLUS folder
## Does not include RTTOV Libarary for radiation data.  If wanted will need to install library then reconfigure
##Note: if you intend to run both 3DVAR and 4DVAR experiments, it is not necessary to compile the code twice. 
#Option 18 for gfortran/gcc and distribunted memory 
########################################################################
cd $HOME/WRF-Hydro/Downloads
tar -xvzf WRF-4.4.tar.gz -C $HOME/WRF-Hydro/WRFDA
cd $HOME/WRF-Hydro/WRFDA/WRFV4.4
mv * $HOME/WRF-Hydro/WRFDA
cd $HOME/WRF-Hydro/WRFDA
rm -r WRFV4.4/
export NETCDF=$DIR/NETCDF
export HDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH
export WRFPLUS_DIR=$HOME/WRF-Hydro/WRFPLUS
./clean -a
./configure -j $CPU_HALF_EVEN 4dvar #Option 18 for gfortran/gcc and distribunted memory 
./compile all_wrfvar



read -t 5 -p "I am going to wait for 5 seconds only ..."
############################OBSGRID###############################
## OBSGRID
## Downloaded from git tagged releases
## Option #2
########################################################################
cd $HOME/WRF-Hydro/
git clone https://github.com/wrf-model/OBSGRID.git
cd $HOME/WRF-Hydro/OBSGRID

./clean -a
source $Miniconda_Install_DIR/etc/profile.d/conda.sh
conda init bash
conda activate ncl_stable


export HOME=`cd;pwd`
export DIR=$HOME/WRF-Hydro/Libs
export NETCDF=$DIR/NETCDF

./configure   #Option 2

sed -i '45s/-C -P -traditional/-P -traditional/g' configure.oa
sed -i '27s|=	-L${NETCDF}/lib -lnetcdf -lnetcdff|=	-L</usr/lib/x86_64-linux-gnu/> -lm -L${NETCDF}/lib -lnetcdf -lnetcdff -lhdf5 -lhdf5_hl -lgfortran -lgcc -lz |g' configure.oa
sed -i '31s|-lncarg -lncarg_gks -lncarg_c -lX11 -lm -lcairo|-lncarg -lncarg_gks -lncarg_c -lX11 -lXext -lpng -lcairo -lfontconfig -lpixman-1 -lfreetype -lgfortran -lgcc -L</usr/lib/x86_64-linux-gnu/> -lm -lhdf5 -lhdf5_hl |g' configure.oa
sed -i '42s|=|=	-L$HOME/WRF-Hydro/LIBS/grib2/lib -lhdf5 -lhdf5_hl -lm |g' configure.oa

sed -i '44s/=	/=	-fallow-argument-mismatch /g' configure.oa
sed -i '39s/-frecord-marker=4/-frecord-marker=4 -fallow-argument-mismatch /g' configure.oa



./compile

conda deactivate
conda deactivate

######################## WPS Domain Setup Tools ########################
## DomainWizard
cd $HOME/WRF-Hydro/Downloads
wget -c http://esrl.noaa.gov/gsd/wrfportal/domainwizard/WRFDomainWizard.zip
mkdir $HOME/WRF-Hydro/WRFDomainWizard
unzip WRFDomainWizard.zip -d $HOME/WRF-Hydro/WRFDomainWizard
chmod +x $HOME/WRF-Hydro/WRFDomainWizard/run_DomainWizard


######################## WPF Portal Setup Tools ########################
## WRFPortal
cd $HOME/WRF-Hydro/Downloads
wget -c https://esrl.noaa.gov/gsd/wrfportal/portal/wrf-portal.zip
mkdir $HOME/WRF-Hydro/WRFPortal
unzip wrf-portal.zip -d $HOME/WRF-Hydro/WRFPortal
chmod +x $HOME/WRF-Hydro/WRFPortal/runWRFPortal


######################### Text file for locations of all pre/post processor ############






######################## Static Geography Data inc/ Optional ####################
# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
# These files are large so if you only need certain ones comment the others off
# All files downloaded and untarred is 200GB
# https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
#################################################################################
cd $HOME/WRF-Hydro/Downloads
mkdir $HOME/WRF-Hydro/GEOG
mkdir $HOME/WRF-Hydro/GEOG/WPS_GEOG

#Mandatory WRF Preprocessing System (WPS) Geographical Input Data Mandatory Fields Downloads

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
tar -xvzf geog_high_res_mandatory.tar.gz -C $HOME/WRF-Hydro/GEOG/

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz
tar -xvzf geog_low_res_mandatory.tar.gz -C $HOME/WRF-Hydro/GEOG/
mv $HOME/WRF-Hydro/GEOG/WPS_GEOG_LOW_RES/ $HOME/WRF-Hydro/GEOG/WPS_GEOG


# WPS Geographical Input Data Mandatory for Specific Applications
wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_thompson28_chem.tar.gz
tar -xvzf geog_thompson28_chem.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_noahmp.tar.gz
tar -xvzf geog_noahmp.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c  https://www2.mmm.ucar.edu/wrf/src/wps_files/irrigation.tar.gz
tar -xvzf irrigation.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_px.tar.gz
tar -xvzf geog_px.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_urban.tar.gz
tar -xvzf geog_urban.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_ssib.tar.gz
tar -xvzf geog_ssib.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/lake_depth.tar.bz2
tar -xvf lake_depth.tar.bz2 -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/topobath_30s.tar.bz2                                                
tar -xvf topobath_30s.tar.bz2 -C $HOME/WRF-Hydro/GEOG/WPS_GEOG


wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/gsl_gwd.tar.bz2
tar -xvf gsl_gwd.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG


#Optional WPS Geographical Input Data 


wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_older_than_2000.tar.gz
tar -xvzf geog_older_than_2000.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s_with_lakes.tar.gz
tar -xvzf modis_landuse_20class_15s_with_lakes.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_alt_lsm.tar.gz
tar -xvzf geog_alt_lsm.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/nlcd2006_ll_9s.tar.bz2
tar -xvf nlcd2006_ll_9s.tar.bz2 -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/updated_Iceland_LU.tar.gz
tar -xvf updated_Iceland_LU.tar.gz -C $HOME/WRF-Hydro/GEOG/WPS_GEOG

wget -c https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_15s.tar.bz2
tar -xvf modis_landuse_20class_15s.tar.bz2 -C $HOME/WRF-Hydro/GEOG/WPS_GEOG







##########################  Export PATH and LD_LIBRARY_PATH ################################
cd $HOME

echo "export PATH=$DIR/bin:$PATH" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=$DIR/lib:$LD_LIBRARY_PATH" >> ~/.bashrc




#####################################BASH Script Finished##############################
end=`date`
END=$(date +"%s")
DIFF=$(($END-$START))
echo "Install Start Time: ${start}"
echo "Install End Time: ${end}"
echo "Install Duration: $(($DIFF / 3600 )) hours $((($DIFF % 3600) / 60)) minutes $(($DIFF % 60)) seconds"
echo "Congratulations! You've successfully installed all required files to run the Weather Research Forecast Model verison 4.4."
echo "Thank you for using this script"


 
