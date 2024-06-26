# The official device tree overlays
# extracted from https://github.com/clockworkpi/uConsole/blob/b6920b37a0ea0319e8c16f7e96b552d32ff40ce8/Code/patch/cm4/20230630/0001-patch-cm4.patch
[
  # {
  #   name = "devterm-bt";
  #   filter = "bcm2711-rpi-cm4.dtb";
  #   dtsText = ''
  #     /dts-v1/;
  #     /plugin/;

  #     /{
  #     	compatible = "brcm,bcm2711";

  #     	fragment@0 {
  #     		target = <&uart0>;
  #     		__overlay__ {
  #     			pinctrl-names = "default";
  #     			pinctrl-0 = <&uart0_pins &bt_pins>;
  #     			status = "okay";
  #     		};
  #     	};

  #     	fragment@1 {
  #     		target = <&gpio>;
  #     		__overlay__ {
  #     			uart0_pins: uart0_pins {
  #     				brcm,pins = <14 15 16 17>;
  #     				brcm,function = <4 4 7 7>;
  #     				brcm,pull = <0 2 0 2>;
  #     			};

  #     			bt_pins: bt_pins {
  #     				brcm,pins = <5 6 7>;
  #     				brcm,function = <1 0 1>;
  #     				brcm,pull = <0 2 0>;
  #     			};
  #     		};
  #     	};

  #     	fragment@2 {
  #     		target-path = "/aliases";
  #     		__overlay__ {
  #     			serial1 = "/soc/serial@7e201000";
  #     			serial0 = "/soc/serial@7e215040";
  #     		};
  #     	};
  #     };
  #   '';
  # }
  {
    name = "devterm-misc";
    filter = "bcm2711-rpi-cm4.dtb";
    dtsText = ''
      /dts-v1/;
      /plugin/;

      /{
      	compatible = "brcm,bcm2711";

      	fragment@0 {
      		target = <&i2c1>;
      		__overlay__ {
      			#address-cells = <1>;
      			#size-cells = <0>;
      			pinctrl-names = "default";
      			pinctrl-0 = <&i2c1_pins>;
      			status = "okay";

      			adc101c: adc@54 {
      				reg = <0x54>;
      				compatible = "ti,adc101c";
      				status = "okay";
      			};
      		};
      	};

      	fragment@1 {
      		target = <&spi4>;
      		__overlay__ {
      			pinctrl-names = "default";
      			pinctrl-0 = <&spi4_pins &spi4_cs_pins>;
      			cs-gpios = <&gpio 4 1>;
      			status = "okay";

      			spidev4_0: spidev@0 {
      				compatible = "spidev";
      				reg = <0>;      /* CE0 */
      				#address-cells = <1>;
      				#size-cells = <0>;
      				spi-max-frequency = <125000000>;
      				status = "okay";
      			};
      		};
      	};

      	fragment@2 {
      		target = <&uart1>;
      		__overlay__ {
      			pinctrl-names = "default";
      			pinctrl-0 = <&uart1_pins>;
      			status = "okay";
      		};
      	};

      	fragment@3 {
      		target = <&gpio>;
      		__overlay__ {

      			i2c1_pins: i2c1 {
      				brcm,pins = <44 45>;
      				brcm,function = <6>;
      			};

      			spi4_pins: spi4_pins {
      				brcm,pins = <6 7>;
      				brcm,function = <7>;
      			};

      			spi4_cs_pins: spi0_cs_pins {
      				brcm,pins = <4>;
      				brcm,function = <1>;
      			};

      			uart1_pins: uart1_pins {
      				brcm,pins = <14 15>;
      				brcm,function = <2>;
      				brcm,pull = <0 2>;
      			};

      		};
      	};

      	fragment@4 {
      		target-path = "/chosen";
      		__overlay__ {
      			bootargs = "8250.nr_uarts=1";
      		};
      	};

      };
    '';
  }

  {
    name = "devterm-panel-uc";
    filter = "bcm2711-rpi-cm4.dtb";
    dtsText = ''
      /dts-v1/;
      /plugin/;

      / {
      	compatible = "brcm,bcm2711";

      	fragment@0 {
      		target=<&dsi1>;
      		__overlay__ {
      			#address-cells = <1>;
      			#size-cells = <0>;
      			status = "okay";

      			port {
      				dsi_out_port: endpoint {
      					remote-endpoint = <&panel_dsi_port>;
      				};
      			};

      			panel_cwu50: panel@0 {
      				compatible = "clockwork,cwu50";
      				reg = <0>;
      				reset-gpio = <&gpio 8 1>;
      				backlight = <&ocp8178_backlight>;
      				rotation = <90>;

      				port {
      					panel_dsi_port: endpoint {
      						remote-endpoint = <&dsi_out_port>;
      					};
      				};
      			};
      		};
      	};

      	fragment@1 {
      		target-path = "/";
      		__overlay__  {
      			ocp8178_backlight: backlight@0 {
      				compatible = "ocp8178-backlight";
      				backlight-control-gpios = <&gpio 9 0>;
      				default-brightness = <5>;
      			};
      		};
      	};

      };
    '';
  }
  {
    name = "devterm-pmu";
    filter = "bcm2711-rpi-cm4.dtb";
    dtsText = ''
      /dts-v1/;
      /plugin/;

      / {
      	compatible = "brcm,bcm2711";

      	fragment@0 {
      		target = <&i2c0if>;
      		__overlay__ {
      			#address-cells = <1>;
      			#size-cells = <0>;
      			pinctrl-0 = <&i2c0_pins>;
      			pinctrl-names = "default";
      			status = "okay";

      			axp22x: pmic@34 {
      				interrupt-controller;
      				#interrupt-cells = <1>;
      				compatible = "x-powers,axp223";
      				reg = <0x34>; /* i2c address */
      				interrupt-parent = <&gpio>;
      				interrupts = <2 8>;  /* IRQ_TYPE_EDGE_FALLING */
      				irq-gpios = <&gpio 2 0>;

      				regulators {

      					x-powers,dcdc-freq = <3000>;

      					reg_aldo1: aldo1 {
      						regulator-always-on;
      						regulator-min-microvolt = <3300000>;
      						regulator-max-microvolt = <3300000>;
      						regulator-name = "audio-vdd";
      					};

      					reg_aldo2: aldo2 {
      						regulator-always-on;
      						regulator-min-microvolt = <3300000>;
      						regulator-max-microvolt = <3300000>;
      						regulator-name = "display-vcc";
      					};

      					reg_dldo2: dldo2 {
      						regulator-always-on;
      						regulator-min-microvolt = <3300000>;
      						regulator-max-microvolt = <3300000>;
      						regulator-name = "dldo2";
      					};

      					reg_dldo3: dldo3 {
      						regulator-always-on;
      						regulator-min-microvolt = <3300000>;
      						regulator-max-microvolt = <3300000>;
      						regulator-name = "dldo3";
      					};

      					reg_dldo4: dldo4 {
      						regulator-always-on;
      						regulator-min-microvolt = <3300000>;
      						regulator-max-microvolt = <3300000>;
      						regulator-name = "dldo4";
      					};

      				};

      				battery_power_supply: battery-power-supply {
      					compatible = "x-powers,axp221-battery-power-supply";
      					monitored-battery = <&battery>;
      				};

      				ac_power_supply: ac_power_supply {
      					compatible = "x-powers,axp221-ac-power-supply";
      				};

      			};
      		};
      	};

      	fragment@1 {
      		target = <&i2c0if>;
      		__overlay__ {
      			compatible = "brcm,bcm2708-i2c";
      		};
      	};

      	fragment@2 {
      		target-path = "/aliases";
      		__overlay__ {
      			i2c0 = "/soc/i2c@7e205000";
      		};
      	};

      	fragment@3 {
      		target-path = "/";
      		__overlay__  {
      			battery: battery@0 {
      				compatible = "simple-battery";
      				constant-charge-current-max-microamp = <2100000>;
      				voltage-min-design-microvolt = <3300000>;
      			};
      		};
      	};

      };
    '';
  }
  # {
  #   name = "devterm-wifi";
  #   filter = "bcm2711-rpi-cm4.dtb";
  #   dtsText = ''
  #     /dts-v1/;
  #     /plugin/;

  #     /* Enable SDIO from MMC interface via various GPIO groups */

  #     /{
  #     	compatible = "brcm,bcm2711";

  #     	fragment@0 {
  #     		target = <&mmc>;
  #     		sdio_ovl: __overlay__ {
  #     			pinctrl-0 = <&sdio_ovl_pins>;
  #     			pinctrl-names = "default";
  #     			non-removable;
  #     			bus-width = <4>;
  #     			status = "okay";
  #     		};
  #     	};

  #     	fragment@1 {
  #     		target = <&gpio>;
  #     		__overlay__ {
  #     			sdio_ovl_pins: sdio_ovl_pins {
  #     				brcm,pins = <22 23 24 25 26 27>;
  #     				brcm,function = <7>; /* ALT3 = SD1 */
  #     				brcm,pull = <0 2 2 2 2 2>;
  #     			};
  #     		};
  #     	};

  #     	fragment@2 {
  #     		target-path = "/";
  #     		__overlay__  {
  #     			wifi_pwrseq: wifi-pwrseq {
  #     				compatible = "mmc-pwrseq-simple";
  #     				reset-gpios = <&gpio 3 0>;
  #     			};
  #     		};
  #     	};

  #     };
  #   '';
  # }
]
