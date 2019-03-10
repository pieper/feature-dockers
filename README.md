# feature-dockers
Docker files for feature analysis routines (e.g. white matter analysis and sift-rank)


## WMA

`docker run -it --name wma stevepieper/wma`

## for testing

`./build.sh; docker rm -f wma; docker run -it --name wma stevepieper/wma /home/researcher/wmademo.sh`

## Thanks

Supported in part by the Neuroimage Analysis Center (NAC) https://nac.spl.harvard.edu/

NAC is a Biomedical Technology Resource Center supported by the National Institute of Biomedical Imaging and Bioengineering (NIBIB) (P41 EB015902). It was supported by the National Center for Research Resources (NCRR) (P41 RR13218) through December 2011.
