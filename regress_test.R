require(ANTsR)
mat.size <- 10
nsubjects <- 300
mymat <- array(rep(0, mat.size * mat.size * mat.size * nsubjects), 
               dim=c(mat.size, mat.size, mat.size, nsubjects))
signal.1 <- runif(nsubjects)
signal.2 <- runif(nsubjects) 
outcome <-  pmax(signal.1 +  4 * signal.2 + rnorm(nsubjects, sd=1),0) # signal.2 dwarfs signal.1
plot(outcome)
for ( i in 1:nsubjects){
  mymat[, , , i] <- abs(rnorm(mat.size * mat.size * mat.size, sd=0.5))
  mymat[3:4, 3:4, 3:4, i] <- pmax(signal.1[i] + rnorm(8, sd=1), 0)
  mymat[(mat.size-3):(mat.size-2), 3:4, 
        3:4, i] <- pmax(signal.2[i] + rnorm(8, sd=1), 0)
}
true.mat <- array(rep(0, mat.size * mat.size * mat.size), dim=c(mat.size, mat.size, mat.size))
true.mat[3:4, 3:4, 3:4] <- 1
true.mat[(mat.size-3):(mat.size-2), 3:4, 3:4] <- 1
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
pval.mat.adj <- array(p.adjust(pval.mat, "bonferroni"), dim=c(mat.size, mat.size, mat.size))
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
# mydecom <- sparseRegression( matrix(mymat, nrow=nsubjects, byrow=TRUE), 
#         demog=data.frame(outcome=outcome), outcome="outcome", mask=as.antsImage(mymask), 
#                              nvecs=8)
# for( i in 1:8){
#   antsImageWrite(mydecom$eigenanatomyimages[[i]], paste('outvec', i, '.nii.gz', sep=''))
# }