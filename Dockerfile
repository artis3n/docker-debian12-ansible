FROM debian:bookworm
LABEL maintainer="artis3n"

ARG DEBIAN_FRONTEND=noninteractive

ENV pip_packages "ansible"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    sudo systemd systemd-sysv \
    build-essential wget libffi-dev libssl-dev procps \
    python3-pip python3-dev python3-setuptools python3-apt \
    iproute2 \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc \
    && rm -Rf /usr/share/man \
    && apt-get clean

RUN python3 -m pip install --upgrade --no-cache-dir --break-system-packages pip setuptools \
    && pip3 install --no-cache-dir --break-system-packages $pip_packages

WORKDIR /
COPY initctl_faker .
RUN chmod +x initctl_faker && rm -fr /sbin/initctl && ln -s /initctl_faker /sbin/initctl

RUN mkdir -p /etc/ansible \
    && printf "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Make sure systemd doesn't start agettys on tty[1-6].
RUN rm -f /lib/systemd/system/multi-user.target.wants/getty.target

VOLUME ["/sys/fs/cgroup"]
CMD ["/lib/systemd/systemd"]
