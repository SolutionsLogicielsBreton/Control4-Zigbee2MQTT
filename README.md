# Control4 – Zigbee2MQTT Bridge

> DISCLAIMER: This software is neither affiliated with nor endorsed by
Control4, MQTT, or Zigbee2MQTT.

This driver lets a Control4 system control Zigbee devices that are managed
by [Zigbee2MQTT](https://www.zigbee2mqtt.io/).  
It does so by connecting to an MQTT broker and translating between
Control4’s device objects and the topics used by Zigbee2MQTT.

---

## Table of Contents

1. [Overview](#overview)
2. [System Requirements](#system-requirements)
3. [Features](#features)
4. [Getting Started](#getting-started)
5. [Device Support](#device-support)
6. [Custom Drivers](#custom-drivers)
7. [Installation & Setup](#installation--setup)

---

## Overview

The **Z2MQTT_Bridge.c4z** driver connects your Control4 system to any
standard MQTT broker (including those used by Zigbee2MQTT).  
Once the bridge is configured, you can add device‑specific drivers that
translate between Control4 objects and Zigbee2MQTT topics.

---

## System Requirements

| Requirement | Minimum |
|-------------|---------|
| Control4 OS  | 3.3+ |
| MQTT broker | Any broker reachable on your local network (e.g., Mosquitto) |
| Zigbee2MQTT | Installed & configured to use that same broker |

> **Tip:** The bridge will automatically reconnect if the broker
> temporarily goes offline.

---

## Features

- Dedicated or generic drivers for Zigbee devices  
- Works with any MQTT broker – no vendor lock‑in  
- Username/password authentication supported  
- Compatible with MQTT 3.1, 3.1.1, and 5.0  
- Automatic reconnection on disconnect  
- Message caching so late‑joining devices receive missed updates

---

## Getting Started

1. **Download the bridge driver** (latest release)  

   ```text
   https://github.com/SolutionsLogicielsBreton/Control4-Zigbee2MQTT/releases/latest/download/Z2MQTT_Bridge.c4z
   ```

2. **Add it to your Control4 project** in Composer Pro.  
3. **Open the driver’s configuration tab** and enter:
   - MQTT broker hostname / IP
   - Port (default 1883)
   - Optional username & password
4. **Save** and confirm the connection was successful

---

## Device Support

Device drivers follow this naming convention:

```
Z2MQTT_<VENDOR>_<MODEL>.c4z
```

*Example:*  
`Tuya TS0601` → `Z2MQTT_TUYA_TS0601.c4z`

You can find your device’s vendor and model in the Zigbee2MQTT UI or on the
[Supported Devices list](https://www.zigbee2mqtt.io/supported-devices/).

If no dedicated driver exists, generic drivers are available that provide
basic support for many sensor types.  Philips Hue devices use a slightly
different naming scheme but are listed in the same directory.

---

## Custom Drivers

Most drivers are **unencrypted** and can be used as templates:

1. For example, *rename `Z2MQTT_GENERIC_CONTACT_SENSOR.c4z` → `Z2MQTT_GENERIC_CONTACT_SENSOR.zip`*
2. Using software like 7zip, open the archive **without unzipping** and edit the `driver.xml` and `driver.lua` files to add your device’s
   properties, topics, or custom logic.
3. Save your changes
4. Rename back to `.c4z` and import into Composer Pro.

> **Tip:** If you’re familiar with compiling Control4 drivers, you can create your own using the source files including in this repository.

---

## Installation & Setup

### Driver Installation

1. Download the latest [`Z2MQTT_Bridge.c4z`](https://github.com/SolutionsLogicielsBreton/Control4-Zigbee2MQTT/blob/main/drivers/Z2MQTT_Bridge.c4z).
2. Add it to your Control4 project.
3. Configure the bridge as described in the documentation tab of the driver in Composer Pro.
4. After the bridge is running, download and add the device drivers you want
   from the [`/drivers`](https://github.com/SolutionsLogicielsBreton/Control4-Zigbee2MQTT/tree/main/drivers) directory to your project in Composer Pro.
