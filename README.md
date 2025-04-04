
# cluster_image

This repository holds container images to be used for the workers on the EODC
cluster. Use the url "ghcr.io/eodcgmbh/cluster_image:XXXX.XX.XX" to specify the
image to use for the workers in the dask gateway cluster options.


### Example:

    # Specify the Docker image to use for the workers
    cluster_options.image = "ghcr.io/eodcgmbh/cluster_image:2025.2.0"