FROM base/archlinux:2018.01.01

RUN pacman --sync --refresh && \
    pacman --sync --noconfirm \
      curl \
      gcc \
      eclipse \
      make \
      python \
      vim \
      xorg-server-xvfb

ARG ECLIM_VERSION
RUN curl \
      --location \
      --output /opt/eclim_$ECLIM_VERSION.bin \
      https://github.com/ervandew/eclim/releases/download/$ECLIM_VERSION/eclim_$ECLIM_VERSION.bin && \
    chmod +x /opt/eclim_$ECLIM_VERSION.bin && \
    /opt/eclim_$ECLIM_VERSION.bin \
      --yes \
      --eclipse=/usr/lib/eclipse \
      --vimfiles=/usr/share/vim/vimfiles \
      --plugins=jdt && \
    rm /opt/eclim_$ECLIM_VERSION.bin

# Inject our own g:EclimCommand setting.
RUN sed --in-place "s|let command = a:home . 'bin/eclim'|let command = get(g:, 'EclimCommand', a:home . 'bin/eclim')|" /usr/share/vim/vimfiles/eclim/autoload/eclim/client/nailgun.vim

# eclimd requires a running X server to function, so we launch it in a virtual X server environment.
ENTRYPOINT ["/usr/bin/xvfb-run", "/usr/lib/eclipse/eclimd"]
