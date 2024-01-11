# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG JUPYTERHUB_VERSION
FROM quay.io/jupyterhub/jupyterhub:$JUPYTERHUB_VERSION

# Install dockerspawner, nativeauthenticator
# hadolint ignore=DL3013
RUN python3 -m pip install --no-cache-dir \
    dockerspawner \
    jupyterhub-nativeauthenticator \
    sparkmagic \
    spylon-kernel==0.4.1 \
    pyiceberg[pyarrow,duckdb,pandas]==0.5.1 \
    jupysql==0.10.5 \
    matplotlib==3.8.2 \
    scipy==1.11.4 \
    duckdb-engine==0.9.4 \
    spark

CMD ["jupyterhub", "-f", "/srv/jupyterhub/jupyterhub_config.py"]
