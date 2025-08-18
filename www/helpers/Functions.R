# Continuity cutoff with respect to sample size 
cutoffcont <- function(n){
  
  # Cutoff for continuity f(n)=a*log10(n)+b, f(10)=0.75, , f(50)=0.4, f(100)=0.25
  
  b=125
  a=-50
  
  if (n<=50) {  
    cut <- min(1,round((a*log10(n)+b)/100,2))
  } else {
    
    # 20 unique values for sample sizes greater than 50
    cut <- 20/n
  }
  return(cut)
}

# Variables can be: Pure continuous or continuous with max 3 replications or other discrete distribution which can be approximated by continuous 
continuous <- function(col){
  
  dt <- data.table(col)
  reps <- na.omit(dt[,.N,by=col])
  
  if ( (all(reps[,2]<=3)) || 
       (length(unique(na.omit(col))) / length(na.omit(col)) >= cutoffcont(length(na.omit(col))))   ){
    return(TRUE)
  } else {return(FALSE)
  }
}

# LOOP Function from GitHub (https://github.com/jhmadsen/DDoutlier/blob/master/R/OutlierFunctionLibrary.R 16/05/2025), without using the not available package 
LOOP <- function(dataset, k=10, lambda=3){
  
  n <- nrow(dataset)
  dataset <- as.matrix(dataset)
  
  if(!is.numeric(k)){stop('k input must be numeric')}
  if(k>=n||k<1){stop('k input must be less than number of observations and greater than 0')}
  if(!is.numeric(lambda)){stop('lambda input must be numeric')}
  if(!is.numeric(dataset)){stop('dataset input is not numeric')}
  
  dist.obj <- dbscan::kNN(dataset, k)
  
  nnSD <- apply(dist.obj$dist, 1, function(x){sqrt((sum(x^2)/k))})
  pdist <- lambda*nnSD
  
  plof <- NULL
  
  for(i in 1:n){
    plof[i] <- (nnSD[i]/mean(nnSD[dist.obj$id[i,]]))-1}
  
  nplof <- lambda*sqrt(sum(plof^2)/n)
  loop <- pracma::erf(plof/(nplof*sqrt(2)))
  loop[loop<0] <- 0
  
  return(loop)
  
}

# Compute outliers by knn proximity based method, liberal 
knnoutlier <- function(data){
  data <- data[complete.cases(data),]
  outliers_scores <- LOOP(data, k=10, lambda=3)
  outliers <- which(outliers_scores > 0.90, arr.ind = TRUE)
  return(outliers)
} 


# Check normality of one variable 
normality <- function(col){
  
  qq <- qqnorm(col,plot=FALSE)
  qqcor <- with(qq,cor(x,y))
  
  if (qqcor >=0.975){
    return(TRUE)
  } else {
    return(FALSE)
  }
}
  

# p-value format
pformat <- function(p){
  if (is.na(p)){
    return(NA)
  } else if (p<0.001){ 
    return("<0.001")
  } else return (round(p,3))
}



