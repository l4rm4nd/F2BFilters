# F2BFilters
Dockerized Fail2ban with filters and actions for the following log formats of:

- [Nginx Proxy Manager](https://github.com/NginxProxyManager/nginx-proxy-manager)
- [Traefik (JSON & CLM)](https://github.com/traefik/traefik)
- [Vaultwarden](https://github.com/dani-garcia/vaultwarden)

> [!CAUTION]
> This repository is based on the use of iptables and not nftables!
> 
> Nftables do not support string matching. Therefore, we cannot block IP packets sent from reverse proxy to docker containers by inspecting the X-Forwarded-For header.
> 
> You have to switch your OS to use the legacy iptables. Read [here](https://wiki.debian.org/nftables?ref=blog.lrvt.de#Reverting_to_legacy_xtables).
>
> Alternatively, use the CloudFlare API to ban a threat actor's IP address. This is viable solution, if you already use CF and cannot use legacy iptables.

# Usage

````
# switch to legacy iptables and disable nftables (caution, know what you are doing)
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
sudo update-alternatives --set arptables /usr/sbin/arptables-legacy
sudo update-alternatives --set ebtables /usr/sbin/ebtables-legacy

# clone this repository
git clone https://github.com/l4rm4nd/F2BFilters

# change directory
cd F2BFilters

# adjust the docker-compose.yml as well as jail.d/, action.d/ and filter.d/ configs
# especially enable your preferred jails in the jail.d/jail.local config
# you can find example docker-compose.yml files for npm, vaultwarden and traefik in the examples directory

# run the fail2ban docker container
docker compose up -d
````

## Fail2ban Docker Container

This repository contains an example `docker-compose.yml` file to spawn up a dockerized fail2ban service. Ensure to bind mount your volume paths at `volumes:` containing the logs for Nginx Proxy Manager and Vaultwarden. Afterwards, the container can be started via `docker compose up -d`.

Note: The directory `/mnt/docker-volumes/fail2ban/data/` will hold the subdirs `jail.d`, `actions.d` and `filters.d`. These directories are automatically created when the fail2ban container starts. Place the data of this repository there and adjust the files accordingly to your needs.

## Fail2ban Configuration

The repository contains various `action.d` scripts and `filter.d` filters.

### Jail Config

The `jail.conf` file defines all active filters and actions. It is configured for incremental IP bans. If a threat actor is detected multiple times, the ban time will be increased by multipliers continuously.

The following jail configuration is provided:

- jail.conf


### Actions

Fail2ban actions define what happens when a filter match is hit or triggered by log lines.

The following actions are provided by this repository:

- action-ban-cloudflare.conf
  - Used to ban threat actor IP addresses on Cloudflare via API
- action-ban-docker-badbots.conf
  - Used to ban threat actors with malicious user agents
  - Requires DOCKER-USER chain, iptables 1.3.5 or later and kernel support for string matching
  - Note: nftables do not support iptable's string matching extension
- action-ban-docker-forceful-browsing.conf
  - Used to ban threat actors that cause a multitude of 401, 403, 404 etc. errors
  - Requires DOCKER-USER chain, iptables 1.3.5 or later and kernel support for string matching
  - Note: nftables do not support iptable's string matching extension
- action-ban-docker-vaultwarden-bruteforce.conf
  - Used to ban threat actors conducting brute-force attacks on the login of vaultwarden password manager
  - Requires DOCKER-USER chain, iptables 1.3.5 or later and kernel support for string matching
  - Note: nftables do not support iptable's string matching extension  
- telegram_notif.sh
  - Used to send notifications via Telegram messenger

### Filters

Fail2ban filters define the regex pattern that is used to monitor log files.

The following filters are provided by this repository:

- npm-general-badbots.conf
  - Filter to identify HTTP requests with well-known malicious user agents
- npm-general-forceful-browsing.conf
  - Filter to identify forceful browsing attacks (multitude of 404, 403 etc.) in NPM logs
- traefik-general-forceful-browsing.conf
  - Filter to identify forceful browsing attacks (multitude of 404, 403 etc.) in Traefik logs with user agent logging
- traefik-general-badbots.conf
  - Filter to identify HTTP requests with well-known malicious user agents
- vaultwarden_login_bruteforce.conf
  - Filter to identify brute-force attacks on the login area of vaultwarden (Bitwarden alternative written in Rust)
