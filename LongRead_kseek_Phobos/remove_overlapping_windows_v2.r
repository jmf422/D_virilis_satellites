#!/usr/bin/env Rscript

# Created by Elissa Cosgrove and Jullien Flynn

# run this script with:
# Rscript --vanilla remove_overlapping_windows_v2.r m54138_170527_151828.test2 test_v2_out.txt

args <- commandArgs(trailingOnly=TRUE)

in.file.name <- args[1]
out.file.name <- args[2]

dat.in <- read.delim(in.file.name, as.is=T, header=F)
row.ct <- nrow(dat.in)

# identify overlapping cases:
overlap.idx <- which(dat.in$V2[-row.ct] > dat.in$V1[-1] & dat.in$V2[-row.ct] < dat.in$V2[-1])

if (length(overlap.idx) > 0)
{
	non.overlap.idx <- setdiff(1:row.ct, sort(unique(c(overlap.idx, overlap.idx + 1))))
	non.overlap.dat <- dat.in[non.overlap.idx, ]
	
	break.pts <- which(diff(overlap.idx) > 1)
	if (length(break.pts) > 0)
	{
		break.pts.2 <- c(0, break.pts, length(overlap.idx))
		overlap.sets <- split(overlap.idx, rep(1:(length(break.pts.2)-1), times=diff(break.pts.2)))
	} else
	{
		overlap.sets <- list(overlap.idx)
	}

	out.dat <- lapply(overlap.sets, function(c.set)
	{
		c.idx <- c(c.set, max(c.set) + 1)
		c.dat <- dat.in[c.idx, ]
		c.kp <- c.dat[which.max(c.dat$V4), ]
		c.kp$V1 <- min(c.dat$V1)
		c.kp$V2 <- max(c.dat$V2)
		c.kp$V3 <- (c.kp$V2 - c.kp$V1) + 1
		return(c.kp)
	})
	out.dat <- do.call(rbind, out.dat)
	
	final.dat <- rbind(non.overlap.dat, out.dat)
	final.dat <- final.dat[order(final.dat$V1), ]
} else
{
	final.dat <- dat.in
}

# check for any remaining overlaps
overlap.chk <- which(final.dat$V2[-nrow(final.dat)] > final.dat$V1[-1] & final.dat$V2[-nrow(final.dat)] < final.dat$V2[-1])
if (length(overlap.chk) > 0)
{
	print("still overlaps; check for fully nested segments")
}

write.table(final.dat, file=out.file.name, row.names=F, col.names=F, sep="\t", quote=F)
