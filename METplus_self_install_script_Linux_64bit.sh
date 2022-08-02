#!/bin/bash


#Basic Package Management for Model Evaluation Tools (METplus)

sudo apt-get update
sudo apt-get upgrade



#Directory Listings for Model Evaluation Tools (METplus
mkdir $HOME/WRF-Hydro
mkdir $HOME/WRF-Hydro/METplus-4.1.3
mkdir $HOME/WRF-Hydro/METplus-4.1.3/Sample_Data
mkdir $HOME/WRF-Hydro/METplus-4.1.3/Output
mkdir $HOME/WRF-Hydro/METplus-4.1.3/Downloads



#Downloading METplus and untarring files

cd $HOME/WRF-Hydro/METplus-4.1.3/Downloads
wget https://github.com/dtcenter/METplus/archive/refs/tags/v4.1.3.tar.gz
tar -xvzf v4.1.3.tar.gz -C $HOME/WRF-Hydro



# Insatlllation of Model Evaluation Tools Plus
cd $HOME/WRF-Hydro/METplus-4.1.3/parm/metplus_config

sed -i "s|MET_INSTALL_DIR = /path/to|MET_INSTALL_DIR = $HOME/WRF-Hydro/MET-10.1.2|" defaults.conf
sed -i "s|INPUT_BASE = /path/to|INPUT_BASE = $HOME/WRF-Hydro/METplus-4.1.3/Sample_Data|" defaults.conf
sed -i "s|OUTPUT_BASE = /path/to|OUTPUT_BASE = $HOME/WRF-Hydro/METplus-4.1.3/Output|" defaults.conf


# Downloading Sample Data

cd $HOME/WRF-Hydro/METplus-4.1.3/Downloads
wget https://dtcenter.ucar.edu/dfiles/code/METplus/METplus_Data/v4.1/sample_data-met_tool_wrapper-4.1.tgz
tar -xvzf sample_data-met_tool_wrapper-4.1.tgz -C $HOME/WRF-Hydro/METplus-4.1.3/Sample_Data


# Testing if installation of MET & METPlus was sucessfull
# If you see in terminal "METplus has successfully finished running." 
# Then MET & METPLUS is sucessfully installed

echo 'Testing MET & METPLUS Installation.'
$HOME/WRF-Hydro/METplus-4.1.3/ush/run_metplus.py -c $HOME/WRF-Hydro/METplus-4.1.3/parm/use_cases/met_tool_wrapper/GridStat/GridStat.conf 

export PATH=$HOME/WRF-Hydro/METplus-4.1.3/ush:$PATH


