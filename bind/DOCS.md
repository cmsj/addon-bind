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