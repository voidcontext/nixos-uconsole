# nixos-uconsole-cm4

NixOS module and base SD card image for clockworkPi uConsole using RasberryPi Compute Module 4.

## Status

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
this to be able to offload the kernel compilation to a potentially stronger computer using cross
compilation. In the future this will be configurable.

```bash
nix build .\#images.sd-image-cm4 -L
```

## Sources

Kernel patches from  : https://github.com/PotatoMania/uconsole-cm3
Kernel config changes: https://jhewitt.net/uconsole

