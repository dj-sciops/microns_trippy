ARG PY_VER
FROM jupyter/docker-stacks-foundation:python-${PY_VER:-3.9}
# FROM mambaorg/micromamba:debian12-slim

USER root
RUN apt update && \
   apt install -y ssh git graphviz && \
   apt-get update && apt-get install ffmpeg libsm6 libxext6 -y && \
   pip install --upgrade pip && \
   pip install gateway_provisioners && \
   jupyter image-bootstrap install --languages python && \
   chown jovyan:users /usr/local/bin/bootstrap-kernel.sh && \
   chmod 0755 /usr/local/bin/bootstrap-kernel.sh && \
   chown -R jovyan:users /usr/local/bin/kernel-launchers && \
   mamba install -n base -y -c conda-forge graphviz && \
   mamba clean --all -y
CMD /usr/local/bin/bootstrap-kernel.sh
WORKDIR $HOME
USER jovyan

ARG DEPLOY_KEY
COPY --chown=jovyan $DEPLOY_KEY $HOME/.ssh/id_ed25519
RUN chmod u=r,g-rwx,o-rwx $HOME/.ssh/id_ed25519 && \
    ssh-keyscan github.com >> $HOME/.ssh/known_hosts

ARG REPO_OWNER
ARG REPO_NAME
ARG REPO_BRANCH

RUN git clone -b ${REPO_BRANCH} git@github.com:${REPO_OWNER}/${REPO_NAME}.git --recurse-submodules
RUN pip install -e ./${REPO_NAME}