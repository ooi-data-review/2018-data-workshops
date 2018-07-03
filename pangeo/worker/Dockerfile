FROM jupyter/base-notebook
USER root

RUN conda update -y conda
RUN pip install --upgrade pip

# Dumb init
RUN wget -q -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

RUN conda install --yes -c conda-forge \
    av=0.4.0 \
    cmocean \
    cytoolz \
    dask=0.17.2 \
    distributed=1.21.4 \
    fastparquet \
    git \
    google-cloud-storage \
    imagehash \
    lz4 \
    netcdf4 \
    nomkl \
    numba \
    numcodecs \
    numpy \
    obspy \
    pandas \
    pytables \
    python-blosc \
    scikit-image \
    scipy \
    xarray \
    zict \
    && conda clean -tipsy

RUN apt-get update \
  && apt-get install -yq --no-install-recommends libfuse-dev fuse \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN pip install pyasn1 click urllib3 --upgrade

RUN pip install git+https://github.com/tjcrone/zarr@10738c84c62c83ce8e9ef64d9b53491157d97013 \
                git+https://github.com/dask/gcsfs@2fbdc27e838a531ada080886ae778cb370ae48b8 \
                --no-cache-dir \
                --upgrade

RUN pip install numpngw \
                azure-storage-blob

RUN pip install git+https://github.com/tjcrone/pycamhd@8bdc18647ec20b0a49dc140d3f71b8ef9dba17a9

ENV OMP_NUM_THREADS=1
ENV DASK_TICK_MAXIMUM_DELAY=5s

USER root
COPY prepare.sh /usr/bin/prepare.sh
RUN chmod +x /usr/bin/prepare.sh
RUN mkdir /opt/app
RUN mkdir /gcs

ENTRYPOINT ["/usr/local/bin/dumb-init", "/usr/bin/prepare.sh"]
