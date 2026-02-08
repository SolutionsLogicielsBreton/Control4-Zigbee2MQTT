# <span style="color:#660066">Overview</span>

> DISCLAIMER: This software is neither affiliated with nor endorsed by
> Control4, MQTT, or Zigbee2MQTT.

The Zigbee2MQTT driver connects Control4 to an MQTT broker to communicate with Zigbee2MQTT.

The bridge then sends messages to the child drivers to control specific devices.

<div style="page-break-after: always"></div>

# <span style="color:#660066">System Requirements</span>

- Control4 OS 3.3+
- Zigbee2MQTT installed and configured to an MQTT broker accessible on the local network

# <span style="color:#660066">Features</span>

- Connects to any standard MQTT broker
- Supports username/password authentication
- Automatic reconnection on disconnect
- Message caching for late-subscribing devices

# <span style="color:#660066">How do I know if my device is supported?</span>

The device drivers usually are named with the following naming convention:
Z2MQTT + Vendor + Model

So for a `Tuya TS0601` you would be looking for a driver named `Z2MQTT_TUYA_TS0601.c4z`

**You can find your model and vendor in Zigbee2MQTT, or on their site https://www.zigbee2mqtt.io/supported-devices/#**

If a driver specific to your device isn't available, generic drivers exist that should provide basic support for most types of sensors.

**Philips Hue devices have device drivers with a friendlier naming convention**

# <span style="color:#660066">There doesn't seem to be a driver for my device, can I write my own?</span>

Yes! I recommend starting with one of the generic drivers as template.

Looking at the `driver.xml` and `driver.lua` files, how to modify them to support the extra properties of your device should be pretty straightforward.

**If you don't know how compile a driver, you can simply open and edit the files within the `.c4z` directly as they are actually `.zip` files.

<div style="page-break-after: always"></div>

# <span style="color:#660066">Installer Setup</span>

## Driver Installation

1.  Download the latest `Z2MQTT_Bridge.c4z` driver from this repository and add it to your Control4 project.

2.  Follow the documentation in the documentation tab of the driver in Composer Pro to configure it properly.

3.  Once properly connected download and add the device drivers you need from this repository `/drivers`
