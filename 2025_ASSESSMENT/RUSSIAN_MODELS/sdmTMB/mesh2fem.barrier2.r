#' Function to compute flat area approximation
#' @rdname polyUtils
#' @aliases flatArea
#' @return the area of a triangle

flatArea <- function(tr) {
  e0 <- tr[3, ] - tr[2, ]
  e1 <- tr[1, ] - tr[3, ]
  s0 <- e0[2] * e1[3] - e0[3] * e1[2]
  s1 <- e0[3] * e1[1] - e0[1] * e1[3]
  s2 <- e0[1] * e1[2] - e0[2] * e1[1]
  return(sqrt(s0 * s0 + s1 * s1 + s2 * s2) * 0.5)
}

#' Function to compute the stiffness contribution from a triangle.
#' @rdname polyUtils
#' @aliases Stiffness
#' @return the stiffness matrix for a triangle
Stiffness <- function(tr) {
  e <- cbind(tr[3, ] - tr[2, ],
             tr[1, ] - tr[3, ],
             tr[2, ] - tr[1, ])
  return(0.25 * crossprod(e))
}

mesh2fem.barrier2<-function (mesh, barrier.triangles = NULL) 
{



    if (is.null(barrier.triangles)) {
        warning("No 'barrier.triangles', using 'mesh2fem(mesh, order = 2)'!")
        return(mesh2fem(mesh = mesh, order = 2L))
    }
    else {
        if (is.list(barrier.triangles)) {
            ntv1 <- nrow(mesh$graph$tv)
            for (i in 1:length(barrier.triangles)) {
                barrier.triangles[[i]] <- unique(sort(barrier.triangles[[i]]))
                stopifnot(all(barrier.triangles[[i]] %in% (1:ntv1)))
            }
            itv <- c(list(setdiff(1:ntv1, unlist(barrier.triangles))), 
                barrier.triangles)
            ntv <- sapply(itv, length)
        }
        else {
            barrier.triangles <- unique(sort(barrier.triangles))
            itv <- list(setdiff(1:nrow(mesh$graph$tv), barrier.triangles), 
                barrier.triangles)
            ntv <- sapply(itv, length)
        }
    }
    stopifnot(fm_manifold(mesh, c("S", "R")))
    Rmanifold <- fm_manifold(mesh, "R") + 0L
    dimension <- fm_manifold_dim(mesh)
    stopifnot(dimension > 1)
    if (TRUE) {
        hh <- fmesher::fm_fem(mesh, order = 1)$ta
    }
    else {
        if (Rmanifold == 0) {
            R.i <- sqrt(rowSums(mesh$loc^2))
            hh <- sapply(1:nrow(mesh$graph$tv), function(i) {
                it <- mesh$graph$tv[i, ]
                s2trArea(mesh$loc[it, ], R.i[1])
            })
        }
        else {
            hh <- sapply(1:nrow(mesh$graph$tv), function(i) {
                it <- mesh$graph$tv[i, ]
                Heron(mesh$loc[it, 1], mesh$loc[it, 2])
            })
        }
    }
    n <- nrow(mesh$loc)
    c1aux <- matrix(1, 3, 3) + diag(3)
    ii0 <- rep(1:3, each = 3)
    jj0 <- rep(1:3, 3)
    res <- list(I = Diagonal(n, x = rep(0, n)), D = vector("list", 
        2L), C = vector("list", 2L), hdim = 0L)
    for (o in 1:length(itv)) {
        c0 <- double(n)
        ii <- integer(ntv[o] * 9L)
        jj <- integer(ntv[o] * 9L)
        g1x <- double(ntv[o] * 9L)
        c1x <- double(ntv[o] * 9L)
        ng <- nc <- 0
        for (j in itv[[o]]) {
            it <- mesh$graph$tv[j, ]
            h <- hh[j]
            fa <- flatArea(mesh$loc[it, ])
            g1x[ng + 1:9] <- Stiffness(mesh$loc[it, ])/fa
            c0[it] <- c0[it] + h/3
            c1x[nc + 1:9] <- h * c1aux/12
            ii[ng + 1:9] <- it[ii0]
            jj[ng + 1:9] <- it[jj0]
            nc <- nc + 9L
            ng <- ng + 9L
        }
        ijx <- which((ii > 0) | (jj > 0))
        res$I <- res$I + Matrix::sparseMatrix(i = ii[ijx], j = jj[ijx], 
            x = c1x[ijx], dims = c(n, n))
        res$D[[o]] <- Matrix::sparseMatrix(i = ii[ijx], 
            j = jj[ijx], x = g1x[ijx], dims = c(n, n))
        res$C[[o]] <- c0
        res$hdim <- res$hdim + 1L
    }
    return(res)
}
