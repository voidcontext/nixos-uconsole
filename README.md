# nixos-uconsole

NixOS module and base SD card image for clockworkPi uConsole.

## Status

For now, only devices using RaspberryPi Compute Module 4 are supported.

Many things just doesn't work at the moment, the sd image boots, but it can only be confirmed using
the HDMI output, and it's impossible to log in since the keyboard doesn't work.

|                   | Does it work? |
|------------------ | ------------- |
| boot              | ✓             |
| built-in display  | x             |
| backlight         | ✓             |
| hdmi output       | ✓             |
| built-in keyboard | x             |
| usb keyboard      | x             |
| bluetooth         | n/a           |
| wifi              | n/a           |

## Development

To build the image you'll need 2 machines: an `x86_64-linux` and an `aarch64-linux` build machine,
this is required to be able to offload the kernel compilation to a potentially stronger computer
using cross compilation. In the future this will be configurable.

```bash
nix build .\#images.sd-image-cm4 -L
```

Once the image is flashed into an SD card the `/boot/config.txt` needs to be updated, see 
[./config.txt](config.txt) (later this should be part of the build process).

## Sources

- Kernel patches from  : https://github.com/PotatoMania/uconsole-cm3
- Kernel config changes: https://jhewitt.net/uconsole

