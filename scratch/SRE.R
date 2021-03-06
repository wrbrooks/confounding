# Setting up spatial random effect basis functions

#--------------------------
# Use bisquare basis:
bisquare <- function(d, bw)
{
  indx <- which(d < bw)
  resp <- rep(0, length(d))
  resp[indx] <- (1 - (d[indx]/bw)^2)^2
  
  return(resp)
}


#---------------------------
# Set up the spatial basis functions
SRE <- function(loc) {
  XX <- range(loc$x)
  YY <- range(loc$y)
  
  # Set up three different spatial resolutions:
  n.1 <- 16
  len.xx <- (n.1 / (diff(YY) / diff(XX))) %>% sqrt %>% round
  len.yy <- (n.1 / (diff(XX) / diff(YY))) %>% sqrt %>% round
  xx <- seq(min(loc$x), max(loc$x), len=len.xx)
  yy <- seq(min(loc$y), max(loc$y), len=len.yy)
  min.1 <- min(xx[2] - xx[1], yy[2] - yy[1])
  points.1 <- data.frame(x=rep(xx, times=len.yy), y=rep(yy, each=len.xx))
  dist.1 <- sqrt(outer(loc$x, points.1$x, '-')^2 + outer(loc$y, points.1$y, '-')^2)
  SRE <- apply(dist.1, 2, function(z) bisquare(z, 1.5*min.1))
  
  
  n.2 <- round(3 * n.1)
  len.xx <- (n.2 / (diff(YY) / diff(XX))) %>% sqrt %>% round
  len.yy <- (n.2 / (diff(XX) / diff(YY))) %>% sqrt %>% round
  xlim <- c(0.05, 0.95) * diff(XX) + min(XX)
  ylim <- c(0.05, 0.95) * diff(YY) + min(YY)
  xx <- seq(xlim[1], xlim[2], len=len.xx)
  yy <- seq(ylim[1], ylim[2], len=len.yy)
  min.2 <- min(xx[2] - xx[1], yy[2] - yy[1])
  points.2 <- data.frame(x=rep(xx, times=len.yy), y=rep(yy, each=len.xx))
  dist.2 <- sqrt(outer(loc$x, points.2$x, '-')^2 + outer(loc$y, points.2$y, '-')^2)
  SRE <- cbind(SRE, apply(dist.2, 2, function(z) bisquare(z, 1.5*min.2)))
  
  
  n.3 <- round(3 * n.2)
  len.xx <- (n.3 / (diff(YY) / diff(XX))) %>% sqrt %>% round
  len.yy <- (n.3 / (diff(XX) / diff(YY))) %>% sqrt %>% round
  xlim <- c(0.02, 0.98) * diff(XX) + min(XX)
  ylim <- c(0.02, 0.98) * diff(YY) + min(YY)
  xx <- seq(xlim[1], xlim[2], len=len.xx)
  yy <- seq(ylim[1], ylim[2], len=len.yy)
  min.3 <- min(xx[2] - xx[1], yy[2] - yy[1])
  points.3 <- data.frame(x=rep(xx, times=len.yy), y=rep(yy, each=len.xx))
  dist.3 <- sqrt(outer(loc$x, points.3$x, '-')^2 + outer(loc$y, points.3$y, '-')^2)
  SRE <- cbind(SRE, apply(dist.3, 2, function(z) bisquare(z, 1.5*min.3)))
  
  # Remove any random effect components that are orthgonal to the points
  indx <- which(colSums(SRE)==0)
  if (length(indx)>0) SRE <- SRE[,-indx]
  
  
  
  # Resolution 4 is used for the grid to estimate K and tau
  n.4 <- round(4 * n.3)
  len.xx <- (n.4 / (diff(YY) / diff(XX))) %>% sqrt %>% round
  len.yy <- (n.4 / (diff(XX) / diff(YY))) %>% sqrt %>% round
  xlim <- XX
  ylim <- YY
  xx <- seq(xlim[1], xlim[2], len=len.xx)
  yy <- seq(ylim[1], ylim[2], len=len.yy)
  min.4 <- min(xx[2] - xx[1], yy[2] - yy[1])
  points.4 <- data.frame(x=rep(xx, times=len.yy), y=rep(yy, each=len.xx))
  dist.4 <- sqrt(outer(loc$x, points.4$x, '-')^2 + outer(loc$y, points.4$y, '-')^2)
  bins <- apply(dist.4, 2, function(z) ifelse(z < 1.5*min.4, 1, 0))
  
  # Remove any empty bins
  indx <- which(colSums(bins)==0)
  if (length(indx)>0) bins <- bins[,-indx]
  
  return(list(SRE=SRE, bins=bins))
}