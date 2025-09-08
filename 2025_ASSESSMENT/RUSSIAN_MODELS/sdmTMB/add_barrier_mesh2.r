add_barrier_mesh2<-function (spde_obj, barrier_sf, range_fraction = 0.2, proj_scaling = 1, 
    plot = FALSE) 
{
    if (!requireNamespace("sf", quietly = TRUE)) {
        cli_abort("The sf package must be installed to use this function.")
    }
    assertthat::assert_that(is.numeric(range_fraction), range_fraction <= 
        1, range_fraction > 0, length(range_fraction) == 1)
    assertthat::assert_that(is.numeric(proj_scaling), length(proj_scaling) == 
        1)
    assertthat::assert_that(inherits(barrier_sf, "sf"))
    assertthat::assert_that(inherits(spde_obj, "sdmTMBmesh"))
    assertthat::assert_that(is.logical(plot))
    mesh <- spde_obj$mesh
    tl <- length(mesh$graph$tv[, 1])
    pos_tri <- matrix(0, tl, 2)
    for (i in seq_len(tl)) {
        temp <- mesh$loc[mesh$graph$tv[i, ], ]
        pos_tri[i, ] <- colMeans(temp)[c(1, 2)]
    }
    mesh_sf <- as.data.frame(pos_tri)
    mesh_sf$X <- mesh_sf$V1 * proj_scaling
    mesh_sf$Y <- mesh_sf$V2 * proj_scaling
    mesh_sf <- sf::st_as_sf(mesh_sf, crs = sf::st_crs(barrier_sf), 
        coords = c("X", "Y"))
    intersected <- sf::st_intersects(mesh_sf, barrier_sf)
    water.triangles <- which(lengths(intersected) == 0)
    land.triangles <- which(lengths(intersected) > 0)
    if (plot) {
        plot(pos_tri[water.triangles, ], col = "grey40", asp = 1, 
            xlab = spde_obj$xy_cols[1], ylab = spde_obj$xy_cols[2])
        points(pos_tri[land.triangles, ], col = "red", pch = 4)
    }
    barrier_spde <- mesh2fem.barrier2(mesh, barrier.triangles = land.triangles)
    spde_obj$spde_barrier <- barrier_spde
    spde_obj$barrier_scaling <- c(1, range_fraction)
    spde_obj$mesh_sf <- mesh_sf
    spde_obj$barrier_triangles <- land.triangles
    spde_obj$normal_triangles <- water.triangles
    spde_obj
}
