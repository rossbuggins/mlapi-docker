# NOTES
# Python 3.9 doesn't play ball
# Requirements.txt has specific versions.
# Open CV 4.7 seems ok

FROM debian:11 AS BUILD

RUN apt-get -y update \
    && apt-get install -y \
    wget \
    git \
#     python3 \
#     python3-pip \
    curl \
    cmake \
    gcc \
    g++ \
    #python3-dev \
    #python3-numpy \
    libpng-dev \
    libjpeg-dev \
    libopenexr-dev \
    libtiff-dev \
    libwebp-dev \
    libopenblas-dev \
    liblapack-dev \
    libblas-dev \
    libev-dev \
    libevdev2 \
    libgeos-dev \
    ca-certificates \
    ffmpeg \
    libsm6 \
    libxext6 \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer1.0-dev \
    zlib1g \
    libssl-dev \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    liblzma-dev \
    tk-dev \
    libgtk-3-dev \
    pkg-config \
    && update-ca-certificates

# BUILD AND INSTALL PYTHON
ENV PYTHON_VERSION=3.8.10
ENV PYTHON_MAJOR=3
ENV PYTHONPATH=/opt/python/3.8.10/lib/python3.8/site-packages

RUN curl -O https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
   && tar -xvzf Python-${PYTHON_VERSION}.tgz

WORKDIR /Python-${PYTHON_VERSION}

RUN ./configure \
    --prefix=/opt/python/${PYTHON_VERSION} \
    --enable-optimizations \
    --enable-ipv6 \
    --with-lto \
    --with-computed-gotos \
    --with-system-ffi \
    --enable-shared \
    LDFLAGS=-Wl,-rpath=/opt/python/${PYTHON_VERSION}/lib,--disable-new-dtags \
    && make \
    && make install

ENV PATH "/opt/python/$PYTHON_VERSION/bin:$PATH"

RUN python3 -m pip install --upgrade pip setuptools wheel

RUN python3 -m site

# GET THE PYTHON MLAPI AND INSTALL DEPENDANCIES

WORKDIR /
RUN  git clone https://github.com/pliablepixels/mlapi 
WORKDIR /mlapi

COPY  ./requirements.txt   ./requirements.txt 
RUN pip3 install --no-cache-dir -r requirements.txt 

# GET, BUILD AND INSTALL OPENCV

WORKDIR /
RUN git clone https://github.com/opencv/opencv-python.git

WORKDIR /opencv-python
RUN git submodule init \
    && git submodule update /opencv-python/opencv \
    && git submodule update /opencv-python/opencv_contrib

WORKDIR /opencv-python/opencv
RUN git fetch --all --tags \
    && git checkout tags/4.7.0 -b myver

WORKDIR /opencv-python/opencv_contrib
RUN git fetch --all --tags \
    && git checkout tags/4.7.0 -b myver

WORKDIR /opencv-python

RUN mkdir build
WORKDIR /opencv-python/build
RUN cmake \
    -DCMAKE_INSTALL_PREFIX=/opt/python/3.8.10 \
    -DOPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules ../opencv \
    -DBUILD_opencv_python3=ON \
    -DPYTHON_INCLUDE=/opt/python/3.8.10/include/python3.8 \
    -DPYTHON_LIBRARY=/opt/python/3.8.10/lib/libpython3.8.so \
    -DPYTHON_PACKAGES_PATH=/opt/python/3.8.10/lib/python3.8/site-packages \
    -DOPENCV_PYTHON3_INSTALL_PATH=/opt/python/3.8.10/lib/python3.8/site-packages \
    -DPYTHON_EXECUTABLE=/opt/python/3.8.10/bin/python3

RUN make -j8
RUN make install

# GET BUILD AND INSTALL DLIB

WORKDIR /
RUN git clone https://github.com/davisking/dlib.git dlib
WORKDIR /dlib
RUN git fetch --all --tags && git checkout tags/v19.24 -b myver
RUN python3 setup.py install

# Install Face recognition after Dlib (have removed from requirements)
RUN pip3 install --no-cache-dir face-recognition

# GET THE MODELS

WORKDIR /mlapi
RUN  chmod 0777 get_models.sh && \
     ./get_models.sh

RUN mkdir -p /mlapi/images
RUN mkdir -p /mlapi/known_faces
RUN mkdir -p /mlapi/unknown_faces

# FUDGE FIX YOLO WITH THIS VERSION

COPY ./yolo.py /opt/python/3.8.10/lib/python3.8/site-packages/pyzm/ml/yolo.py

COPY ./entrypoint.sh /mlapi/entrypoint.sh
RUN chmod 0777 entrypoint.sh

COPY ./stream.py /mlapi/stream.py

CMD ["./entrypoint.sh", ""]