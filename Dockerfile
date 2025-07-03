FROM docker.io/library/ubuntu:noble

# 基本環境変数の設定（Rやタイムゾーン、ロケール、ユーザー関連）
ENV R_VERSION="4.4.2" \
    R_HOME="/usr/local/lib/R" \
    TZ="Asia/Tokyo" \
    CRAN="https://p3m.dev/cran/__linux__/noble/latest" \
    LANG="ja_JP.UTF-8" \
    LC_ALL="ja_JP.UTF-8" \
    S6_VERSION="v2.1.0.2" \
    RSTUDIO_VERSION="2024.12.0+467" \
    DEFAULT_USER="rstudio" \
    VIRTUAL_ENV="/opt/venv" \
    PATH="${VIRTUAL_ENV}/bin:${PATH}"

# 必要なパッケージのインストール（キャッシュクリア付き）
RUN apt update && apt install -y \
    curl \
    fonts-ipaexfont \
    libcurl4-openssl-dev \
    libgit2-dev \
    build-essential \
    cmake \
    libharfbuzz-dev \
    libfribidi-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    zlib1g-dev \
    libxml2-dev \
  && rm -rf /var/lib/apt/lists/*

# R のソースからのインストールスクリプトの実行
COPY scripts/install_R_source.sh /rocker_scripts/install_R_source.sh
RUN /rocker_scripts/install_R_source.sh

# ロケールとタイムゾーンの設定
RUN sed -i '$d' /etc/locale.gen \
  && echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen ja_JP.UTF-8 \
  && /usr/sbin/update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" \
  && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# 各種スクリプトの配置と実行
COPY scripts/bin/ /rocker_scripts/bin/
COPY scripts/setup_R.sh /rocker_scripts/setup_R.sh
RUN /bin/bash -c 'if grep -q "1000" /etc/passwd; then userdel --remove "$(id -un 1000)"; fi && /rocker_scripts/setup_R.sh'

COPY scripts/install_rstudio.sh /rocker_scripts/install_rstudio.sh
COPY scripts/install_s6init.sh /rocker_scripts/install_s6init.sh
COPY scripts/default_user.sh /rocker_scripts/default_user.sh
COPY scripts/init_set_env.sh /rocker_scripts/init_set_env.sh
COPY scripts/init_userconf.sh /rocker_scripts/init_userconf.sh
COPY scripts/pam-helper.sh /rocker_scripts/pam-helper.sh
RUN /rocker_scripts/install_rstudio.sh

COPY scripts/install_pandoc.sh /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_pandoc.sh

COPY scripts/install_quarto.sh /rocker_scripts/install_quarto.sh
RUN /rocker_scripts/install_quarto.sh

COPY scripts/install_python.sh /rocker_scripts/install_python.sh
#COPY scripts/install_texlive.sh /rocker_scripts/install_texlive.sh
COPY scripts/install_jupyter.sh /rocker_scripts/install_jupyter.sh
RUN /rocker_scripts/install_jupyter.sh

RUN apt update \
  && apt -y install libfontconfig-dev \
  libharfbuzz-dev \
  libfribidi-dev \
  libtiff-dev \
  libcurl4-openssl-dev\
  curl \
  default-jdk \
  && rm -rf /var/lib/apt/lists/*
RUN Rscript -e 'install.packages(c("remotes", "pak", "radiant", "miniUI", "ragg"))'

# ユーザー設定関連のファイル配置
COPY --chown=rstudio:rstudio .Rprofile /home/${DEFAULT_USER}
COPY scripts /rocker_scripts

# Jupyter Lab のポートを公開
EXPOSE 8888

# rstudioユーザーにsudo権限を付与
#RUN echo 'rstudio ALL=(ALL) ALL' >> /etc/sudoers
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# コンテナ実行時のユーザーと作業ディレクトリの設定
USER ${DEFAULT_USER}
ENV HOME /home/${DEFAULT_USER}
ENV PATH "${VIRTUAL_ENV}/bin:${HOME}/.jbang/bin:${PATH}"
WORKDIR /home/${DEFAULT_USER}

# Javaカーネルのインストール
RUN curl -Ls https://sh.jbang.dev | bash -s - app setup
RUN /home/rstudio/.jbang/bin/jbang trust add https://github.com/jupyter-java/
RUN /home/rstudio/.jbang/bin/jbang install-kernel@jupyter-java

# RStudio Server用のフォントをインストール
COPY fonts /home/${DEFAULT_USER}/.config/rstudio/

# RStudio Serverのポートを公開
EXPOSE 8787

# コンテナ起動時は Jupyter Lab をホームディレクトリで起動する
#ENTRYPOINT ["jupyter", "lab", "--ip", "0.0.0.0", "--no-browser", "--NotebookApp.token=''"]
CMD ["jupyter", "lab", "--ip", "0.0.0.0", "--no-browser", "--NotebookApp.token=''"]