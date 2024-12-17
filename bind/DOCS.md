## About

Bind is a very commonly used DNS server, made by [Internet Systems Consortium](https://www.isc.org).

This add-on allows you to run Bind on Home Assistant OS. By default it will run as an open, recursive server - ie it will allow any machine which can talk to your Home Assistant machine, to use it as a DNS resolver.

You should think very carefully about whether you actually want an open recursive server running on your Home Assistant machine and if you don't know what any of these words mean, this add-on is almost certainly not for you.

## Customisation

Note: bind runs inside the addon's container as the `named` user.

The add-on expects to use `/config` for `named.conf` and `zones/`, and `/data` for its cache files. There are various ways you can interact with this in Home Assistant (e.g. an SSH addon) if you wish to configure Bind further (e.g. to make it authoritative). The default layout is:

| Path  | Type | Owner | Permissions | Purpose |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| `/mnt/data/supervisor/addon_configs/de554ef4_bind/named.conf`  | File  | `root` | `rw-r--r--` | Main config file |
| `/mnt/data/supervisor/addon_configs/de554ef4_bind/zones/` | Directory | `named` | `rwxr-xr-x` | (Optional) location for zone files |
| `/mnt/data/supervisor/addons/data/de554ef4_bind/cache/` | Directory | `named` | `rwxr-xr-x` | Cache directory |

Depending on how you access files on your Home Assistant install, these paths may actually be accessible via `/addon_configs`/`/addons/data` or directly as `/config`/`/data`
