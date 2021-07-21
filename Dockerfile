FROM ubuntu:21.04

ENV DEBIAN_FRONTEND=noninteractive

# create non-root user 
ARG UID
ARG GID
RUN groupadd -g $GID -o otg
RUN useradd -m -u $UID -g $GID -o -s /bin/bash otg

# install dependencies
RUN apt-get update && \
    apt-get remove -y -o APT::Immediate-Configure=0 libgcc1 && \
    apt-get install -y ant curl unzip parallel wget bzip2 gcc-9-base libgcc-9-dev libc6-dev && \
    apt-get clean;

# fix Java certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# create directories and change the owner to user `otg`
RUN mkdir -p /coloc /configs/ /data /output /software/gcta && \
    chown -R otg:otg /coloc /configs /data /output /software/gcta

# switch to user otg
USER otg
WORKDIR /home/otg

# create conda/mamba environment
COPY ./environment.yaml /home/otg
RUN wget -qO- https://micromamba.snakepit.net/api/micromamba/linux-64/0.15.2 | tar -xvj bin/micromamba && \
    /home/otg/bin/micromamba env create --name coloc --file /home/otg/environment.yaml --root-prefix /home/otg/micromamba --yes
ENV PATH="/home/otg/bin:/home/otg/micromamba/envs/coloc/bin:${PATH}"

# set JAVA_HOME (useful for Docker commandline)
ENV JAVA_HOME='/home/otg/micromamba/envs/coloc'

# install GCTA
RUN wget https://cnsgenomics.com/software/gcta/bin/gcta_1.92.3beta3.zip --no-check-certificate -P /software/gcta && \
    unzip /software/gcta/gcta_1.92.3beta3.zip -d /software/gcta && \
    rm /software/gcta/gcta_1.92.3beta3.zip
ENV PATH="/software/gcta/gcta_1.92.3beta3:${PATH}"

# copy all files of the repo
COPY ./ /coloc/

# make user `otg` owner of all files in coloc
USER root
RUN chown -R otg:otg /coloc
USER otg

# set default directory
WORKDIR /coloc

# default command
CMD ["/bin/bash"]
