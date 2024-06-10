{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.deodex.hardening;
in {
  options.deodex.hardening = {
    enable = mkEnableOption "Enable hardening settings.";
  };

  config = mkIf cfg.enable {
    # audit
    security.auditd.enable = true;
    security.audit = {
      enable = false; # TODO: reenable when ready
      # increase buffer size in case of high load events
      backlogLimit = 8192;
      # freak the fuck out if shit hits the fan
      failureMode = "panic";
      rules = [
        # log any "replace process with this executable"
        "-a exit,always -F arch=b64 -S execve"
        # log all failed file opens from denied permissions
        "-a exit,always -F arch=b64 -S open -S openat -F exit=-EACCES -k access"
        "-a exit,always -F arch=b64 -S open -S openat -F exit=-EPERM -k access"
        # disable further rules
        "-e 2"
      ];
    };

    # sudo
    security.sudo.execWheelOnly = true;

    # nix
    nix.settings.allowed-users = [ "root" "@wheel" ];

    # sshd
    services.openssh = {
      passwordAuthentication = false;
      extraConfig = ''
        AllowTcpForwarding yes
        X11Forwarding no
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
      '';
      #AuthenticationMethods publickey
    };

    services.sshguard.enable = true;

    # misc
    environment.noXlibs = true;
    users.mutableUsers = false;
  };
}
