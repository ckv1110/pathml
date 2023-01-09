FROM nvidia/cuda:11.8.0-devel-ubuntu22.04
MAINTAINER Chun Kiet Vong
LABEL Version 0.2.0

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Set environment variables for conda and openjdk
ENV PATH="/opt/miniconda3/bin:${PATH}"
ARG PATH="/opt/miniconda3/bin:${PATH}"
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre/"
ARG JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre/"
ENV SHELL="/bin/bash"

COPY setup.py README.md /opt/pathml/
COPY pathml/ /opt/pathml/pathml
COPY tests/ /opt/pathml/tests

# apt-get essentials and dependencies
RUN	apt-get update && apt-get install -y --no-install-recommends \
	openslide-tools \
    g++ \
    gcc  \
    libpixman-1-0 \
    libblas-dev \
    liblapack-dev \
    wget \
    openjdk-8-jre \
    openjdk-8-jdk \
	apt-utils \
	git \
	software-properties-common && \
	wget https://repo.anaconda.com/miniconda/Miniconda3-py38_4.10.3-Linux-x86_64.sh &&\
	bash Miniconda3-py38_4.10.3-Linux-x86_64.sh -bfp /opt/miniconda3/ && \
	rm -f Miniconda3-py38_4.10.3-Linux-x86_64.sh && \
	rm -rf /var/lib/apt/lists/* && \
	mkdir /var/inputdata && \
	mkdir /var/outputdata
	

# conda and pip install prerequisites (last line installs segmentation_models)
RUN conda install -y -c anaconda cudatoolkit=11.0 && \
	conda install -y -c intel mpi4py && \
	conda install -y -c conda-forge dask-mpi && \
	pip3 install pip==21.3.1 && \
	pip3 install numpy==1.19.5 spams==2.6.2.5 imutils && \
	pip3 install python-bioformats==4.0.0 scipy scikit-image matplotlib Cython imgaug ipykernel openslide-python tqdm deepcell pytest && \
	pip3 install /opt/pathml/ && \
	pip3 install git+https://github.com/qubvel/segmentation_models.pytorch && \
	pip3 install -U albumentations && \
	pip3 install fastnumbers && \
	pip3 install bokeh==2.4.3 && \
	pip3 install pytorch-lightning
	

# Set up JupyterLab
RUN pip3 install jupyter -U && pip3 install jupyterlab
EXPOSE 8888
ENTRYPOINT ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--no-browser"]
# CMD ["python"]

