# WhiteMatterAnalysis customized docker

FROM stevepieper/slicer
MAINTAINER pieper@isomics.com

ARG S4EXT=/home/researcher/slicerExtensions
ENV S4EXT=$S4EXT
RUN mkdir $S4EXT

# UKF
RUN (cd $S4EXT; \ 
     wget "http://slicer.kitware.com/midas3/download/index?items=410389" -O ext.tar.gz && \
     tar xvfz ext.tar.gz; rm ext.tar.gz)
ENV UKF="27931-linux-amd64-UKFTractography-gitf21af73-2019-01-16"

# DMRI
RUN (cd $S4EXT; \ 
     wget "http://slicer.kitware.com/midas3/download/index?items=410339" -O ext.tar.gz && \
     tar xvfz ext.tar.gz; rm ext.tar.gz)
ENV DMRI="27931-linux-amd64-SlicerDMRI-git9d3e244-2019-01-30"

# configure slicer as needed
ENV SLICER_ARGUMENTS="--additional-module-paths \
			${S4EXT}/${UKF}/lib/Slicer-4.10/cli-modules \
			${S4EXT}/${UKF}/lib/Slicer-4.10/qt-loadable-modules \
			${S4EXT}/${UKF}/lib/Slicer-4.10/qt-scripted-modules \
			${S4EXT}/${DMRI}/lib/Slicer-4.10/cli-modules \
			${S4EXT}/${DMRI}/lib/Slicer-4.10/qt-loadable-modules \
			${S4EXT}/${DMRI}/lib/Slicer-4.10/qt-scripted-modules \
			"

# install pip
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python-pip \
    && \
  apt-get clean

# install dependencie explicitly (fails when loaded via setup.py)
RUN pip install cython
RUN pip install numpy
RUN pip install scipy
RUN pip install vtk
RUN pip install joblib
RUN pip install statsmodels
RUN pip install xlrd
RUN pip install matplotlib

# install whitematteranalysis (brings in pre-requisites)
#RUN pip install git+https://github.com/SlicerDMRI/whitematteranalysis.git

# check out repository to access scripts
RUN (cd /home/researcher; \
  git clone git://github.com/SlicerDMRI/whitematteranalysis; \
  ( cd whitematteranalysis; \
    python setup.py install \
    ) \
  )

COPY wmademo.sh /home/researcher
RUN chown -R researcher:researcher /home/researcher/wmademo.sh
