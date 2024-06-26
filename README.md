[![Build nginx unit php image](https://github.com/kohanaxworld/unit-php/actions/workflows/image.yml/badge.svg)](https://github.com/kohanaxworld/unit-php/actions/workflows/image.yml)

# unit-php
Alpine based Docker image for nginx-unit with PHP module

Ready-to-use images:
```shell
ghcr.io/kohanaxworld/unit-php
```

Supported PHP versions:
- PHP7.4
- PHP8.1
- PHP8.2

Check the [package](https://github.com/kohanaxworld/unit-php/pkgs/container/unit-php) for available tags.

Currently under active maintenance, so to be considered as unstable.


#### How to use
On container startup, unit is launched and then config.json is sent to the service.  
<br></br>
[Bundled config](rootfs/etc/unit/config.json) is suitable for running simple Laravel application in `/app`. Keep in mind persistent directories, if any.
```shell
docker run -it \
  -v "/path/to/your/laravel_app:/app" \
  ghcr.io/kohanaxworld/unit-php
```

And here's how to run with your own config:
```shell
docker run -it \
  -v "/path/to/your/unit_config.json:/etc/unit/config.json" \
  -v "/path/to/your/web_app:/app" \
  ghcr.io/kohanaxworld/unit-php
```

You can also override path to unit configuration file with `UNIT_CONFIGURATION_FILE` environment variable:
```shell
docker run -it \
  -e "UNIT_CONFIGURATION_FILE=/app/config/unit.json" \
  -v "/path/to/your/web_app:/app" \
  ghcr.io/kohanaxworld/unit-php
```

###### Extending the image

Example ```multistage``` Dockerfile:
```dockerfile
# First stage: Build root filesystem (copy files)
FROM scratch AS rootfs

COPY ["./app", "/app"]
COPY ["./unit.json", "/etc/unit/config.json"]



# Main stage
FROM ghcr.io/kohanaxworld/unit-php

# Copy prepared root filesystem (single layer)
COPY --from=rootfs ["/", "/"]

# Install PHP extensions with pecl: apcu and redis
# Install PHP extension: opcache, pdo and pdo_mysql
RUN set -eux \
    && apk add --update --no-cache alpine-sdk \
    && pear channel-update pear.php.net \
    && pecl channel-update pecl.php.net \
    && pecl install apcu redis \
    && docker-php-ext-enable apcu redis \
    && docker-php-ext-install -j "$(nproc)" opcache pdo pdo_mysql \
    && apk del alpine-sdk \
    && rm /tmp/* -rf
```


#### Supervisor
This image comes bundled with [just-containers/s6-overlay](https://github.com/just-containers/s6-overlay) from build [ghcr.io/kohanaxworld/s6-rootfs](https://github.com/kohanaxworld/s6-rootfs).
To control supervisor behavior, you can use [it's environment variables](https://github.com/just-containers/s6-overlay#customizing-s6-behaviour).
<br></br>

Do NOT attempt starting with docker built-in supervisor (Tini [--init]). S6 must run as PID 1.

#### Caveats
- Comes with PHP ZTS (Zend Thread Safety) enabled. The reason behind is that official PHP image, doesn't support PHP embed on Alpine based images. See: https://github.com/docker-library/php/pull/1355. It does, however on ZTS Alpine images.
