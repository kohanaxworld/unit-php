group "default" {
  targets = [
    "1_29_0_PHP74",
    "1_32_1_PHP81",
    "1_32_1_PHP82"
  ]
}

target "build-dockerfile" {
  dockerfile = "Dockerfile"
}

target "build-platforms" {
  platforms = ["linux/amd64"]
}

target "build-common" {
  pull = true
}

variable "REGISTRY_CACHE" {
  default = "ghcr.io/kohanaxworld/unit-php-cache"
}

######################
# Define the functions
######################

# Get the arguments for the build
function "get-args" {
  params = [unit_version, php_version, alpine_version]
  result = {
    UNIT_VERSION = unit_version
    PHP_VERSION = php_version
    PHP_ALPINE_VERSION =  notequal(alpine_version, "") ? alpine_version : "3.19"
  }
}

# Get the cache-from configuration
function "get-cache-from" {
  params = [version]
  result = [
    "type=registry,ref=${REGISTRY_CACHE}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Get the cache-to configuration
function "get-cache-to" {
  params = [version]
  result = [
    "type=registry,mode=max,ref=${REGISTRY_CACHE}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Get list of image tags and registries
# Takes a version and a list of extra versions to tag
# eg. get-tags("1.29.1", ["1.29", "latest"])
function "get-tags" {
  params = [version, extra_versions]
  result = concat(
    [
      "ghcr.io/kohanaxworld/unit-php:${version}"
    ],
    flatten([
      for extra_version in extra_versions : [
        "ghcr.io/kohanaxworld/unit-php:${extra_version}"
      ]
    ])
  )
}

##########################
# Define the build targets
##########################

target "1_29_0_PHP74" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("1.29.0-PHP7.4")
  cache-to   = get-cache-to("1.29.0-PHP7.4")
  tags       = get-tags("1.29.0-PHP7.4", [])
  args       = get-args("1.29.0", "7.4", "3.16")
}

target "1_32_1_PHP81" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("1.32.1-PHP8.1")
  cache-to   = get-cache-to("1.32.1-PHP8.1")
  tags       = get-tags("1.32.1-PHP8.1", [])
  args       = get-args("1.32.1", "8.1", "")
}

target "1_32_1_PHP82" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("1.32.1-PHP8.2")
  cache-to   = get-cache-to("1.32.1-PHP8.2")
  tags       = get-tags("1.32.1-PHP8.2", ["1.32-PHP8.2", "1.32", "1.32.1", "latest"])
  args       = get-args("1.32.1", "8.2", "")
}
