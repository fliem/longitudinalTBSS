#! /bin/tcsh

# usage: tbss_long path2Data subjectNames
# e.g.: tbss_long ~/dataPath s01 s02 s03 s04
# expects a folder in dataPath called "origData"
# "origData" should contain the data (FA-volumes) for all subjects and timepoints
# this script will create a TBSS folder in the dataPath
#

# the standard FSL dti-commands (eddy current correctoin and dtifit) have
# to be performed prior to the execution of this script
# smoothing before running dtifit can be performed e.g. with fslmaths -fmedian

 
# dataPath
#	- origData
#			-s01_FA_TP1.nii.gz
#			-s01_FA_TP2.nii.gz
#			-s02_FA_TP1.nii.gz
#			-s02_FA_TP2.nii.gz
#			...

set halfregPath=`dirname $0`
set dataPath=$argv[1]
shift
set subj=($argv)

mkdir $dataPath/TBSS
mkdir $dataPath/TBSS/data
mkdir $dataPath/TBSS/TP1
mkdir $dataPath/TBSS/TP2

cd $dataPath

# calculate halfway image and calculate base images (1 per subject)
foreach s ($subj)
	echo $s
	cp $dataPath/origData/${s}* $dataPath/TBSS/data/
	sh ${halfregPath}/halfreg.sh $dataPath/TBSS/data/${s}_FA_TP1.nii.gz $dataPath/TBSS/data/${s}_FA_TP2.nii.gz $dataPath/TBSS/data/${s}_FA_TP1_halfway.nii.gz $dataPath/TBSS/data/${s}_FA_TP2_halfway.nii.gz
	rm mat1 mat2 halfmat1 halfmat2
	fslmaths $dataPath/TBSS/data/${s}_FA_TP1_halfway.nii.gz -add $dataPath/TBSS/data/${s}_FA_TP2_halfway.nii.gz -div 2 $dataPath/TBSS/data/${s}_FA_base.nii.gz
end

foreach s ($subj)
	cp $dataPath/TBSS/data/${s}_FA_base.nii.gz $dataPath/TBSS
	# rename halfway to make tbss_non_FA-conform
	cp $dataPath/TBSS/data/${s}_FA_TP1_halfway.nii.gz $dataPath/TBSS/TP1/${s}_FA_base.nii.gz
	cp $dataPath/TBSS/data/${s}_FA_TP2_halfway.nii.gz $dataPath/TBSS/TP2/${s}_FA_base.nii.gz
end

# run regular tbss routine
cd $dataPath/TBSS/
tbss_1_preproc *.nii.gz
tbss_2_reg -T
tbss_3_postreg -S
tbss_4_prestats 0.2

# run tbss with halfway warping
tbss_non_FA TP1
tbss_non_FA TP2





