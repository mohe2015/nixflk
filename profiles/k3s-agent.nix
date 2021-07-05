{
    # TODO FIXME secrets
    environment.etc."secrets/k3s".source = /etc/nixos/secrets/k3s;
    
    services.k3s = {
        enable = true;
        role = "agent";
        serverAddr = "https://192.168.2.128:6443";
        tokenFile = "/etc/secrets/k3s";
    };
    
    # https://rancher.com/docs/k3s/latest/en/installation/installation-requirements/#networking
    networking.firewall.allowedTCPPorts = [ 10250 ];
    networking.firewall.allowedUDPPorts = [ 8472 ];
}