# ISC Bind DNS server add-on for Home Assistant

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fcmsj%2Faddon-bind)

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports i386 Architecture][i386-shield]

## About

Bind is a very commonly used DNS server, made by [Internet Systems Consortium](https://www.isc.org).

This add-on allows you to run Bind on Home Assistant OS. By default it will run as an open, recursive server - ie it will allow any machine which can talk to your Home Assistant machine, to use it as a DNS resolver.

You should think very carefully about whether you actually want an open recursive server running on your Home Assistant machine and if you don't know what any of these words mean, this add-on is almost certainly not for you.

## Customisation

Note: bind runs as the `named` user.

The add-on expects to use `/data` for all of its persistent data. There are various ways you can interact with this in Home Assistant (e.g. an SSH addon) if you wish to configure Bind further (e.g. to make it authoritative). The default layout of `/data` is:

| Path  | Type | Owner | Permissions | Purpose |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| `named.conf`  | File  | `root` | `rw-r--r--` | Main onfig file |
| `cache/` | Directory | `named` | `rwxr-xr-x` | Cache directory |
| `zones/` | Directory | `named` | `rwxr-xr-x` | (Optional) location for zone files |




[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg