FROM hadrieng/docker_base

MAINTAINER Hadrien Gourlé <gourlehadrien@gmail.com>

# installs r
RUN apt-get install -y r-base

# installs nonpareil
RUN git clone git://github.com/lmrodriguezr/nonpareil.git && \
    cd nonpareil && \
    make && \
    make install && \
    cd .. && \
    rm -rf nonpareil

#installs scythe
RUN git clone https://github.com/vsbuffalo/scythe.git && \
    cd scythe && \
    make all && \
    cd .. && \
    rm -rf scythe

#installs sickle
RUN git clone https://github.com/najoshi/sickle.git && \
    cd sickle && \
    make && \
    mv sickle /usr/bin/ && \
    cd .. && \
    rm -rf sickle/
