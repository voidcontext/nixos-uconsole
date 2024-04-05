# nixos-uconsole

NixOS module and base SD card image for clockworkPi uConsole.

## Status

For now, only devices using RaspberryPi Compute Module 4 are supported.

Many things just doesn't work at the moment, the sd image boots, but it can only be confirmed using
the HDMI output, and it's impossible to log in since the keyboard doesn't work.

|                   | Does it work? |
|------------------ | ------------- |
| boot              | ✓             |
| built-in display  | ✓             |
| backlight         | ✓             |
| hdmi output       | ✓             |
| built-in keyboard | ✓             |
| usb keyboard      | ?             |
| bluetooth         | ?             |
| wifi              | x             |

## Development

The kernels are available in 2 versions:

as normal `aarch64-linux` build, e.g:

```bash
nix build .\#packages.aarch64-linux.\"sd-image-cm4-6.1-potatomania\" -L
```

and with a config where the kernel is cross built on `x86_64-linux`, e.g:

```bash
nix build .\#packages.aarch64-linux.\"sd-image-cm4-6.1-potatomania-cross-build\" -L
```

For cross building you'll need 2 machines: an `x86_64-linux` and an `aarch64-linux` build machine.
This is useful when you want to offload the kernel compilation to a potentially stronger computer
using cross compilation.

Once the image is flashed into an SD card the `/boot/config.txt` needs to be updated and copied over
from the relevant kernel's directory.

The available images, and NixOS modules are all discoverable using `nix flake show`.

## Sources

- Kernel patches from  : https://github.com/PotatoMania/uconsole-cm3
- Kernel config changes: https://jhewitt.net/uconsole

