#!/bin/bash
export HOME=`cd;pwd`
startmet=`date`
STARTMET=$(date +"%s")
#Basic Package Management for Model Evaluation Tools (MET)


sudo apt update
sudo apt upgrade
sudo apt install python3 python3-dev emacs flex bison libpixman-1-dev libjpeg-dev pkg-config libpng-dev unzip python2 python2-dev python3-pip pipenv gcc gfortran g++ libtool automake autoconf make m4 default-jre default-jdk csh ksh git libncurses5 libncurses6 mlocate 

#Downloading latest dateutil due to python3.8 running old version.
pip3 install python-dateutil==2.8

#Directory Listings
mkdir $HOME/WRF-Hydro
mkdir $HOME/WRF-Hydro/MET-10.1.2
mkdir $HOME/WRF-Hydro/MET-10.1.2/Downloads
mkdir $HOME/WRF-Hydro/METplus-4.1.3
mkdir $HOME/WRF-Hydro/METplus-4.1.3/Downloads



#Downloading MET and untarring files
#Note weblinks change often update as needed.
cd $HOME/WRF-Hydro/MET-10.1.2/Downloads
wget https://raw.githubusercontent.com/dtcenter/MET/main_v10.1/scripts/installation/compile_MET_all.sh

wget https://dtcenter.ucar.edu/dfiles/code/METplus/MET/installation/tar_files.tgz
wget https://github.com/dtcenter/MET/releases/download/v10.1.2/met-10.1.2.20220516.tar.gz

cp compile_MET_all.sh $HOME/WRF-Hydro/MET-10.1.2
tar -xvzf tar_files.tgz -C $HOME/WRF-Hydro/MET-10.1.2
cp met-10.1.2.20220516.tar.gz $HOME/WRF-Hydro/MET-10.1.2/tar_files
cd $HOME/WRF-Hydro/MET-10.1.2



cd $HOME/WRF-Hydro/MET-10.1.2
export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(/usr/bin/gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(/usr/bin/g++ -dumpfullversion | awk '{print$1}')

export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')

export version_10="10"

if [ $GCC_VERSION_MAJOR_VERSION -lt $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -lt $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -lt $version_10 ]
then
  sed -i 's/-fno-second-underscore -fallow-argument-mismatch/-fno-second-underscore -Wno-argument-mismatch/g' compile_MET_all.sh
fi



export PYTHON_VERSION=$(/usr/bin/python3 -V 2>&1|awk '{print $2}')
export PYTHON_VERSION_MAJOR_VERSION=$(echo $PYTHON_VERSION | awk -F. '{print $1}')
export PYTHON_VERSION_MINOR_VERSION=$(echo $PYTHON_VERSION | awk -F. '{print $2}')
export PYTHON_VERSION_COMBINED=$PYTHON_VERSION_MAJOR_VERSION.$PYTHON_VERSION_MINOR_VERSION


export FC=/usr/bin/gfortran
export F77=/usr/bin/gfortran
export F90=/usr/bin/gfortran
export gcc_version=$(gcc -dumpfullversion)
export TEST_BASE=$HOME/WRF-Hydro/MET-10.1.2
export COMPILER=gnu_$gcc_version
export MET_SUBDIR=${TEST_BASE}
export MET_TARBALL=met-10.1.2.20220516.tar.gz
export USE_MODULES=FALSE
export MET_PYTHON=/usr
export MET_PYTHON_CC=-I${MET_PYTHON}/include/python${PYTHON_VERSION_COMBINED}
export MET_PYTHON_LD=-L${MET_PYTHON}/lib/python${PYTHON_VERSION_COMBINED}/config-${PYTHON_VERSION_COMBINED}-x86_64-linux-gnu\ -L${MET_PYTHON}/lib\ -lpython${PYTHON_VERSION_COMBINED}\ -lcrypt\ -lpthread\ -ldl\ -lutil\ -lm
export SET_D64BIT=FALSE 





chmod 775 compile_MET_all.sh
./compile_MET_all.sh 

export PATH=$HOME/WRF-Hydro/MET-10.1.2/bin:$PATH            #Add MET executables to path

cd 
$HOME/WRFHYDRO-Coupled-5.2-install-script-linux-64bit/METplus_self_install_script_Linux_64bit.sh



endmet=`date`
ENDMET=$(date +"%s")
DIFF=$(($ENDMET-$STARTMET))
echo "Install Start Time: ${startmet}"
echo "Install End Time: ${endmet}"
echo "Install Duration: $(($DIFF / 3600 )) hours $((($DIFF % 3600) / 60)) minutes $(($DIFF % 60)) seconds"
