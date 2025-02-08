FROM docker.io/library/ubuntu:noble

ENV R_VERSION "4.4.2"
ENV R_HOME "/usr/local/lib/R"
ENV TZ "Asia/Tokyo"

COPY scripts/install_R_source.sh /rocker_scripts/install_R_source.sh
RUN /rocker_scripts/install_R_source.sh

ENV CRAN "https://p3m.dev/cran/__linux__/noble/latest"
ENV LANG en_US.UTF-8

COPY scripts/bin/ /rocker_scripts/bin/
COPY scripts/setup_R.sh /rocker_scripts/setup_R.sh
RUN <<EOF
if grep -q "1000" /etc/passwd; then
    userdel --remove "$(id -un 1000)";
fi
/rocker_scripts/setup_R.sh
EOF

ENV S6_VERSION "v2.1.0.2"
ENV RSTUDIO_VERSION "2024.12.0+467"
ENV DEFAULT_USER "rstudio"

COPY scripts/install_rstudio.sh /rocker_scripts/install_rstudio.sh
COPY scripts/install_s6init.sh /rocker_scripts/install_s6init.sh
COPY scripts/default_user.sh /rocker_scripts/default_user.sh
COPY scripts/init_set_env.sh /rocker_scripts/init_set_env.sh
COPY scripts/init_userconf.sh /rocker_scripts/init_userconf.sh
COPY scripts/pam-helper.sh /rocker_scripts/pam-helper.sh
RUN /rocker_scripts/install_rstudio.sh

EXPOSE 8787

COPY scripts/install_pandoc.sh /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_pandoc.sh

COPY scripts/install_quarto.sh /rocker_scripts/install_quarto.sh
RUN /rocker_scripts/install_quarto.sh

ENV NB_USER "rstudio"
ENV VIRTUAL_ENV "/opt/venv"
ENV PATH "${VIRTUAL_ENV}/bin:${PATH}"

COPY scripts/install_python.sh /rocker_scripts/install_python.sh
COPY scripts/install_texlive.sh /rocker_scripts/install_texlive.sh
COPY scripts/install_jupyter.sh /rocker_scripts/install_jupyter.sh
RUN /rocker_scripts/install_jupyter.sh

# ---
# from: https://github.com/rocker-jp/tidyverse
ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8
RUN sed -i '$d' /etc/locale.gen \
  && echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen ja_JP.UTF-8 \
	&& /usr/sbin/update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"
RUN /bin/bash -c "source /etc/default/locale"
RUN ln -sf  /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# Install ipaexfont
RUN apt-get update && apt-get install -y \
  fonts-ipaexfont libcurl4-openssl-dev libgit2-dev build-essential cmake libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev
# ---

# Install packages
COPY scripts/install_mypkgs.sh /rocker_scripts/install_mypkgs.sh
RUN /rocker_scripts/install_mypkgs.sh

USER ${NB_USER}

WORKDIR /home/${NB_USER}

COPY scripts /rocker_scripts

# copy default .Rprofile
COPY .Rprofile /home/${NB_USER}

EXPOSE 8888

CMD ["jupyter", "lab", "--ip", "0.0.0.0", "--no-browser", "--NotebookApp.token=''"]
