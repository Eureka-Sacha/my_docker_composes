# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG JUPYTERHUB_VERSION
FROM quay.io/jupyterhub/jupyterhub:$JUPYTERHUB_VERSION

RUN apt-get update && apt-get -y install gcc libkrb5-dev
# Install dockerspawner, nativeauthenticator
# hadolint ignore=DL3013
RUN python3 -m pip install --no-cache-dir \
    dockerspawner \
    jupyterhub-nativeauthenticator \
    sparkmagic \
    spylon-kernel \
    pyiceberg[pyarrow,duckdb,pandas] \
    jupysql \
    matplotlib \
    scipy \
    duckdb-engine \
    spark

CMD ["jupyterhub", "-f", "/srv/jupyterhub/jupyterhub_config.py"]
