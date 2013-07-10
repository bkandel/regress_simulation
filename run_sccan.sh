#!/bin/bash
ls img*.nii.gz > imgs.txt
sccan --imageset-to-matrix [imgs.txt,mask.nii.gz] -o mymat.mha
sccan --svd network[mymat.mha,mask.nii.gz,-0.2,demog.csv] -o out.nii.gz -n 4
