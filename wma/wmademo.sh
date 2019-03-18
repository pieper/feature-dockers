#!/bin/bash

# demo script for running whitematteranalysis
# in a container

cd /home/researcher

SLICER_PATH=/opt/slicer/Slicer
WMA_PATH=whitematteranalysis/bin
DMRI_CLI_PREFIX="${SLICER_PATH} --launch ${S4EXT}/${DMRI}/lib/Slicer-4.10/cli-modules"
UKF_CLI_PREFIX="${SLICER_PATH} --launch ${S4EXT}/${UKF}/lib/Slicer-4.10/cli-modules"

# First, assumes that the container has pre=installed
# whitematteranalysis, as illustrated at https://github.com/SlicerDMRI/whitematteranalysis

#
# TODO: make these parameters of the process along with any other calculation options
#
# Download the fiber clustering atlas at https://github.com/SlicerDMRI/ORG-Atlases
curl -L 'https://github.com/SlicerDMRI/ORG-Atlases/releases/download/v1.0/ORG-2000FC-100HCP.tar.gz' > ORG-2000FC-100HCP.tar.gz
tar xfz ORG-2000FC-100HCP.tar.gz
curl -L 'https://github.com/SlicerDMRI/ORG-Atlases/releases/download/v1.0/ORG-RegAtlas-100HCP.tar.gz' > ORG-RegAtlas-100HCP.tar.gz
tar xfz ORG-RegAtlas-100HCP.tar.gz
# get the data to analyze
curl 'http://slicer.kitware.com/midas3/download/?items=2142,1/dwi.raw.gz' > dwi.raw.gz
curl 'http://slicer.kitware.com/midas3/download/?items=2141,1/dwi.nhdr' > dwi.nhdr

# TODO: fix the launcher config so this is automatic
cp ${S4EXT}/${UKF}/lib/Slicer-4.10/qt-loadable-modules/libUKFBase.so /opt/slicer/bin

# Generate a brain mask
MASKING_CLI_PATH=${DMRI_CLI_PREFIX}/DiffusionWeightedVolumeMasking
$MASKING_CLI_PATH --baselineBValueThreshold 100 --removeislands dwi.nhdr b0.nrrd brain_mask.nrrd

# Run UKF tractography
UKF_CLI_PATH=${UKF_CLI_PREFIX}/UKFTractography
$UKF_CLI_PATH --dwiFile dwi.nhdr --maskFile brain_mask.nrrd --tracts UKF_tractography.vtp \
  --seedsPerVoxel 1 --numThreads 4 --numTensor 2 --recordFA --recordTrace


ATLAS_BASE_FOLDER=.

# Run tractography registration
python ${WMA_PATH}/wm_register_to_atlas_new.py -l 40 -mode rigid_affine_fast \
  UKF_tractography.vtp \
  $ATLAS_BASE_FOLDER/ORG-RegAtlas-100HCP/registration_atlas.vtk \
  tract_registration/

# Run fiber clustering
python ${WMA_PATH}/wm_cluster_from_atlas.py -l 40 -j 4 \
  tract_registration/UKF_tractography/output_tractography/UKF_tractography_reg.vtk \
  $ATLAS_BASE_FOLDER/ORG-800FC-100HCP/ \
  fiber_clustering/

# Run outlier removal
python ${WMA_PATH}/wm_cluster_remove_outliers.py fiber_clustering/UKF_tractography_reg \
  $ATLAS_BASE_FOLDER/ORG-800FC-100HCP/ \
  fiber_clustering_outlier_removed

# Transform fiber clusters back to dwi space
python ${WMA_PATH}/wm_harden_transform.py -i \
  -t tract_registration/UKF_tractography/output_tractography/itk_txform_UKF_tractography.tfm \
  fiber_clustering_outlier_removed/UKF_tractography_reg_outlier_removed/ \
  fiber_clustering_outlier_removed_in_DWISpace/ \
  $SLICER_PATH



echo done

