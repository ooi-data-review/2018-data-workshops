FROM jupyter/base-notebook

USER root

RUN apt-get update \
  && apt-get install -yq gpg

RUN echo "deb http://packages.cloud.google.com/apt cloud-sdk-xenial main" > /etc/apt/sources.list.d/google-cloud-sdk.list

RUN wget https://packages.cloud.google.com/apt/doc/apt-key.gpg -q -O - | sudo apt-key add -

RUN apt-get update \
  && apt-get install -yq --no-install-recommends libfuse-dev nano fuse vim git jq less openssh-client google-cloud-sdk \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
USER $NB_USER

RUN conda update -y conda
RUN pip install --upgrade pip

RUN conda install --yes -c ioam -c conda-forge \
    av=0.4.0 \
    bokeh=0.12.14 \
    cmocean \
    cytoolz \
    datashader \
    dask=0.17.2 \
    distributed=1.21.4 \
    erddapy \
    fastparquet \
    folium \
    google-cloud-storage \
    imagehash \
    ipywidgets \
    jupyterlab=0.31.12 \
    julia \
    holoviews \
    lz4 \
    matplotlib \
    nb_conda_kernels \
    netcdf4 \
    nomkl \
    numba \
    numcodecs \
    numpy \
    obspy \
    pandas \
    pydrive \
    pytables \
    python-blosc \
    scipy \
    scikit-image \
    seawater \
    seaborn \
    tornado \
    xarray \
    zict \
    && conda clean -tipsy

RUN pip install fusepy click jedi kubernetes --upgrade --no-cache-dir

RUN pip install dask-kubernetes==0.2.0 \
                git+https://github.com/tjcrone/zarr@10738c84c62c83ce8e9ef64d9b53491157d97013 \
                git+https://github.com/dask/gcsfs@2fbdc27e838a531ada080886ae778cb370ae48b8 \
                git+https://github.com/jupyterhub/nbserverproxy \
                --no-cache-dir \
                --upgrade

RUN pip install numpngw \
                azure-storage-blob

RUN pip install git+https://github.com/tjcrone/pycamhd@8bdc18647ec20b0a49dc140d3f71b8ef9dba17a9

RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager@0.34.0 \
                                 @jupyterlab/hub-extension@0.8.1 \
                                 @pyviz/jupyterlab_holoviews@0.4.0 \
                                 jupyterlab_bokeh@0.4.1

RUN jupyter serverextension enable --py nbserverproxy --sys-prefix

USER root
COPY prepare.sh /usr/bin/prepare.sh
RUN chmod +x /usr/bin/prepare.sh
RUN mkdir /pre-home && chown -R $NB_USER /pre-home
COPY worker-template.yaml /pre-home

ENV DASK_TICK_MAXIMUM_DELAY=5s
ENV DASKERNETES_DIAGNOSTICS_LINK {JUPYTERHUB_SERVICE_PREFIX}proxy/{port}/status
ENV DASKERNETES_WORKER_TEMPLATE_PATH /home/$NB_USER/worker-template.yaml
ENV DASKERNETES_WORKER_NAME dask-{JUPYTERHUB_USER}-{uuid}
ENV DASK_DIAGNOSTICS_LINK {JUPYTERHUB_SERVICE_PREFIX}proxy/{port}/status
ENV DASK_KUBERNETES_WORKER_TEMPLATE_PATH /home/$NB_USER/worker-template.yaml
ENV DASK_KUBERNETES_WORKER_NAME dask-{JUPYTERHUB_USER}-{uuid}

RUN mkdir /gcs && chown -R $NB_USER /gcs
RUN mkdir /opt/app

# fix .ssh permissions
RUN printf "\n#fix .ssh permissions\nif [ -f /home/$NB_USER/.ssh/id_rsa ]; then\n   chmod 400 \"/home/$NB_USER/.ssh/id_rsa\"\nfi\nif [ -f /home/$NB_USER/.ssh/id_rsa.pub ]; then\n   chmod 444 \"/home/$NB_USER/.ssh/id_rsa.pub\"\nfi\nif [ -f /home/$NB_USER/.ssh/known_hosts ]; then\n   chmod 600 \"/home/$NB_USER/.ssh/known_hosts\"\nfi\n" >> /etc/bash.bashrc

# Add NB_USER to sudo
RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
RUN sed -ri "s#Defaults\s+secure_path=\"([^\"]+)\"#Defaults secure_path=\"\1:$CONDA_DIR/bin\"#" /etc/sudoers
USER $NB_USER

ENTRYPOINT ["tini", "--", "/usr/bin/prepare.sh"]
CMD ["start.sh jupyter lab"]
