#!/bin/bash
ls img*.nii.gz > imgs.txt
SPARSITY=0.025
CLUSTER=8
sccan --imageset-to-matrix [imgs.txt,mask.nii.gz] -o mymat.mha
sccan --svd network[mymat.mha,mask.nii.gz,0.025,demog.csv] -o out.nii.gz -n 4 --PClusterThresh $CLUSTER
