FROM condaforge/mambaforge:latest

USER root

# Installing system dependencies
# libstdc++6 is a dependency that does not seem to show up in the docs, but the container will need it.

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
gcc \
build-essential \
wget \
kmod \
nano \
zlib1g-dev \
libssl-dev \
perl \
make \
gzip \
git \
software-properties-common \
curl \
tar \
ffmpeg \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# RUN apt update && \
#     apt -y upgrade && \
#     apt install -y ffmpeg && \
#     pip3 install --upgrade pip 

# Creating a Mamba venv and appending it to the .bashrc file
RUN mamba create -n gpt_env python=3.11 -y && \
echo "source activate gpt_env" >> /root/.bashrc

SHELL ["/bin/bash", "--login", "-c"]

############################################################
# Installing Poetry
############################################################

## Creating an installation directory
RUN mkdir /opt/poetry && \
curl -sSL https://install.python-poetry.org > /opt/poetry/install-poetry.py
WORKDIR /opt/poetry

## Doing this to ensure Poetry is installed at /opt/poetry, instead of in /~
RUN echo 'POETRY_HOME=/opt/poetry' >> /root/.bashrc && \
source /root/.bashrc
RUN export POETRY_HOME=/opt/poetry && python3 install-poetry.py 
## Adding Poetry to the PATH
ENV PATH /opt/poetry/bin:$PATH


WORKDIR /opt/app

COPY pyproject.toml poetry.lock ./

RUN source activate gpt_env && \
    pip install --upgrade pip poetry && \
    poetry install --no-root


EXPOSE 8501

COPY . /opt/app

# Adjusted to use Poetry to run Streamlit
CMD ["/bin/bash", "-c", "source activate gpt_env && poetry run streamlit run app.py"]
