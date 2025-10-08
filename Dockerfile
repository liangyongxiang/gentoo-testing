FROM gentoo/portage:latest as portage
FROM gentoo/stage3:amd64-desktop-systemd as production

COPY --from=portage /var/db/repos/gentoo/ /var/db/repos/gentoo

WORKDIR /
ENV PATH="/root/.local/bin:${PATH}"
RUN set -eux;                                                                               \
                                                                                            \
    eselect news read --quiet new >/dev/null 2&>1;                                          \
    echo 'FEATURES="-ipc-sandbox -network-sandbox -pid-sandbox"' >> /etc/portage/make.conf; \
    echo 'FEATURES="${FEATURES} getbinpkg"' >> /etc/portage/make.conf;                      \
    emerge --info;                                                                          \
    getuto;                                                                                 \
    emerge --verbose --quiet --jobs $(nproc) --autounmask y --autounmask-continue y         \
        app-eselect/eselect-repository                                                      \
        app-portage/eix                                                                     \
        app-portage/flaggie                                                                 \
        app-portage/genlop                                                                  \
        app-portage/gentoolkit                                                              \
        app-portage/iwdevtools                                                              \
        app-portage/mgorny-dev-scripts                                                      \
        app-portage/portage-utils                                                           \
        app-misc/jq                                                                         \
        dev-python/jq                                                                       \
        app-misc/neofetch                                                                   \
        dev-python/pip                                                                      \
        dev-util/pkgdev                                                                     \
        dev-util/pkgcheck                                                                   \
        dev-vcs/git;                                                                        \
                                                                                            \
    rm --recursive /var/db/repos/gentoo;                                                    \
    eselect repository add gentoo git https://github.com/gentoo-mirror/gentoo.git;                                                       \
    eselect repository enable gentoo-zh;                                                    \
    emerge --sync;                                                                \
    emerge --verbose --quiet --jobs $(nproc) --autounmask y --autounmask-continue y         \
        dev-python/nvchecker;                                                               \
    eselect repository remove -f gentoo-zh;                                                 \
    sed -i '/FEATURES="${FEATURES} getbinpkg"/d' /etc/portage/make.conf;                    \
    rm --recursive /var/cache/binpkgs/* /var/cache/distfiles/*;                             \
                                                                                            \
    nvchecker --version


CMD ["/bin/bash"]
