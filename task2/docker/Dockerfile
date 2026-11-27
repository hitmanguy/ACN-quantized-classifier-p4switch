FROM p4lang/p4c:latest
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      mininet iproute2 iputils-ping net-tools tcpdump tcpreplay bridge-utils python3-scapy \
    && rm -rf /var/lib/apt/lists/*
