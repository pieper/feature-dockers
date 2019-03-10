#!/bin/bash

# demo script for running whitematteranalysis
# in a container

cd /home/researcher

# First, assumes that the container has pre=installed
# whitematteranalysis, as illustrated at https://github.com/SlicerDMRI/whitematteranalysis

# TODO
# Download the fiber clustering atlas at https://github.com/SlicerDMRI/ORG-Atlases

curl 'http://slicer.kitware.com/midas3/download/?items=2142,1/dwi.raw.gz' > dwi.raw.gz
curl 'http://slicer.kitware.com/midas3/download/?items=2141,1/dwi.nhdr' > dwi.nhdr

DMRI_CLI_PREFIX="/opt/slicer/Slicer --launch ${S4EXT}/${DMRI}/lib/Slicer-4.10/cli-modules"
UKF_CLI_PREFIX="/opt/slicer/Slicer --launch ${S4EXT}/${UKF}/lib/Slicer-4.10/cli-modules"
 
# TODO: fix the launcher config so this is automatic
cp ${S4EXT}/${UKF}/lib/Slicer-4.10/qt-loadable-modules/libUKFBase.so /opt/slicer/bin

# Generate a brain mask
MASKING_CLI_PATH=${DMRI_CLI_PREFIX}/DiffusionWeightedVolumeMasking
$MASKING_CLI_PATH --baselineBValueThreshold 100 --removeislands dwi.nhdr b0.nrrd brain_mask.nrrd 

# Run UKF tractography
UKF_CLI_PATH=${UKF_CLI_PREFIX}/UKFTractography
$UKF_CLI_PATH --dwiFile dwi.nhdr --maskFile brain_mask.nrrd --tracts UKF_tractography.vtp --seedsPerVoxel 1 --numThreads 4 --numTensor 2 --recordFA --recordTrace
 
ls -lrt

exit

ATLAS_BASE_FOLDER=~/Desktop
 
# Run tractography registration
$1 wm_register_to_atlas_new.py -l 40 -mode rigid_affine_fast UKF_tractography.vtp $ATLAS_BASE_FOLDER/ORG-Atlases-1.0/ORG-RegAtlas-100HCP/registration_atlas.vtk tract_registration/
 
# Run fiber clustering
$1 wm_cluster_from_atlas.py -l 40 -j 4 tract_registration/UKF_tractography/output_tractography/UKF_tractography_reg.vtk $ATLAS_BASE_FOLDER/ORG-Atlases-1.0/ORG-800FC-100HCP/ fiber_clustering/
 
# Run outlier removal
$1 wm_cluster_remove_outliers.py fiber_clustering/UKF_tractography_reg $ATLAS_BASE_FOLDER/ORG-Atlases-1.0/ORG-800FC-100HCP/ fiber_clustering_outlier_removed
 
# Transform fiber clusters back to dwi space
SLICER_PATH=/Applications/Slicer4p10realease.app/Contents/MacOS/Slicer
$1 wm_harden_transform.py -i -t tract_registration/UKF_tractography/output_tractography/itk_txform_UKF_tractography.tfm fiber_clustering_outlier_removed/UKF_tractography_reg_outlier_removed/ fiber_clustering_outlier_removed_in_DWISpace/ $SLICER_PATH



echo done

