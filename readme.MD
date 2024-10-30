# Nix Home Manager Repository

This repository contains the configuration for my Nix Home Manager setup.

## Installation

Install nix, e.g. [DeterminateSystems nix installer](https://github.com/DeterminateSystems/nix-installer)
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
  sh -s -- install
```

To install Home Manager, follow the instructions in the [official documentation](https://github.com/nix-community/home-manager#installation) or the minimum steps below:


```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

Once Home Manager is installed, you can clone the configuration and build/activate it using:

```bash
git clone https://github.com/Ogglord/home-manager ~/.config/home-manager
home-manager build
## or switch directly
home-manager switch
```

You might want to add the following to your .profile at least initially until nix manages your shell
```bash
source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
```

Subsequent updates are simplified with my justfile

```bash
just switch
```

