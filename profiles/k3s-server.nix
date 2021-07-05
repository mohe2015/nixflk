{
    services.k3s = {
        enable = true;
        role = "server";
        disableAgent = true;
    };

    # https://rancher.com/docs/k3s/latest/en/installation/installation-requirements/#networking
    networking.firewall.allowedTCPPorts = [ 6443 ];
    networking.firewall.allowedUDPPorts = [ 8472 ];
}