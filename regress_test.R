require(ANTsR)
mat.size <- 10
nsubjects <- 300
mymat <- array(rep(0, mat.size * mat.size * mat.size * nsubjects), 
               dim=c(mat.size, mat.size, mat.size, nsubjects))
signal.1 <- seq(-1, 1, length.out=nsubjects)^2
signal.2 <- sin(seq(0, 6 * pi, length.out=nsubjects)) # signal 2 uncorrelated with signal 1
outcome <-  signal.1 +  signal.2 + rnorm(nsubjects, sd=1)
plot(outcome)
for ( i in 1:nsubjects){
  mymat[, , , i] <- rnorm(mat.size * mat.size * mat.size, sd=0.5)
  mymat[1:2, 1:2, 1:2, i] <- signal.1[i] + rnorm(8, sd=1)
  mymat[(mat.size-1):(mat.size), (mat.size-1):(mat.size), 
        (mat.size-1):(mat.size), i] <- signal.2[i] + rnorm(8, sd=1)
}
true.mat <- array(rep(0, mat.size * mat.size * mat.size), dim=c(mat.size, mat.size, mat.size))
true.mat[1:2, 1:2, 1:2] <- 1
true.mat[(mat.size-1):mat.size, (mat.size-1):mat.size, (mat.size-1):mat.size] <- 1
antsImageWrite(as.antsImage(true.mat), 'true.nii.gz')
pval.mat <- array(rep(NA, mat.size * mat.size * mat.size), dim=c(mat.size, mat.size, mat.size))
for ( i in 1:mat.size ){
  for( j in 1:mat.size){
    for (k in 1:mat.size) {
      mytest <- cor.test(mymat[i, j, k, ], outcome)
      pval.mat[i, j, k] <- mytest$p.value
    }
  }
}
pval.mat.adj <- array(p.adjust(pval.mat, "fdr"), dim=c(mat.size, mat.size, mat.size))
antsImageWrite(as.antsImage(pval.mat.adj), 'pvals.nii.gz')
plotANTsImage(as.antsImage(pval.mat.adj))
for(i in 1:nsubjects){
  antsImageWrite(as.antsImage(mymat[, , ,  i]), paste('img', sprintf('%.03d', i), 
                                                   '.nii.gz', sep=''))
}
write.csv(data.frame(outcome=outcome), 'demog.csv', row.names=F)
mymask <- array(rep(1, mat.size * mat.size * mat.size), dim=c(mat.size, mat.size, mat.size))
antsImageWrite(as.antsImage(as.array(mymask)), 'mask.nii.gz')
antsImageWrite(as.antsImage(matrix(mymat, nrow=nsubjects, byrow=T)), 'inmat.nii.gz')
mydecom <- sparseRegression( matrix(mymat, nrow=nsubjects, byrow=TRUE), 
        demog=data.frame(outcome=outcome), outcome="outcome", mask=as.antsImage(mymask), 
                             nvecs=8)
for( i in 1:8){
  antsImageWrite(mydecom$eigenanatomyimages[[i]], paste('outvec', i, '.nii.gz', sep=''))
}