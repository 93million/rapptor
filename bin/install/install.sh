#! /usr/bin/env bash

set -e

APP_REPO_DEFAULT="github.com/93million/rapptor"
CERTCACHE_CERTBOT_EMAIL="certbot@93m.org"
GIT_BRANCH_DEFAULT="master"

CUSTOM_APP_STORE_REPO="${RAPPTOR_CUSTOM_APP_STORE_REPO}"
DEPLOY_USER=$RAPPTOR_DEPLOY_USER
DEPLOY_PASSWORD=$RAPPTOR_DEPLOY_PASSWORD
APP_REPO="${RAPPTOR_APP_REPO:-$APP_REPO_DEFAULT}"
DOCKER_REGISTRY=$RAPPTOR_DOCKER_REGISTRY
CUSTOM_IMAGE_URI="${RAPPTOR_CUSTOM_IMAGE_URI}"
TEST_CERT="${RAPPTOR_TEST_CERT}"
GIT_BRANCH="${RAPPTOR_GIT_BRANCH:-$GIT_BRANCH_DEFAULT}"

E_MISSING_ARGS=1
E_REQUIRES_ROOT=2
E_UNSUPPORTED_PLATFORM=3
INSTALL_DIR="/var/docker/rapptor"
ACCOUNTS_DIR="$INSTALL_DIR/accounts"
COMPOSE_FILE="$INSTALL_DIR/docker-compose.yml"
PLATFORM=$(test -f /etc/os-release && . /etc/os-release && echo "$ID" || true)

export DEBIAN_FRONTEND=noninteractive

apt-get-install ()
{
  if ! apt-get -qqy install $@ > /dev/null; then
    echo "Another process is blocking apt-get. Waiting for process to complete."
    if ! apt-get -y -o DPkg::Lock::Timeout=600 install $@; then
      E_CODE=$?
      echo "Unable to install packages. Another process is blocking apt-get. Please wait for it to complete and try to install Rapptor again" 1>&2
      exit $E_CODE
    fi
  fi
}

check_requirements()
{
  if [[ $PLATFORM != "debian" && $PLATFORM != "ubuntu" ]]; then
    exit_with_code "Platform must be Debian or Ubuntu" $E_UNSUPPORTED_PLATFORM
  fi

  if [ $( id -u ) -ne 0 ]; then
    exit_with_code "Script must be run as root" $E_REQUIRES_ROOT
  fi
}

create_docker_config()
{
  mkdir -p $INSTALL_DIR/docker

  if [[ ! -z "$DEPLOY_USER" && ! -z "$DEPLOY_PASSWORD" && ! -z "$DOCKER_REGISTRY" ]]; then
    echo "{\"auths\": {\"$DOCKER_REGISTRY\": {\"auth\": \"$(echo -n $DEPLOY_USER:$DEPLOY_PASSWORD | base64)\"}}}" \
      > $INSTALL_DIR/docker/config.json
  else
    echo '{}' > $INSTALL_DIR/docker/config.json
  fi
}

create_env_file()
{
  echo "RAPPTOR_CUSTOM_IMAGE_URI='$CUSTOM_IMAGE_URI'" > "$INSTALL_DIR/.env"
  echo "CERTCACHE_TEST_CERT='$TEST_CERT'" >> "$INSTALL_DIR/.env"
}

create_instance_data()
{
  if [[ $TEST_CERT == '1' ]]; then
    TEST_CERT_ARG="true"
  else
    TEST_CERT_ARG="false"
  fi
  echo -n "Configuring instance data: "
  docker compose -f "$COMPOSE_FILE" run \
    -T \
    --rm \
    rapptoros \
    npm --no-update-notifier --silent run cli -- \
    setinfo \
    -a "$CUSTOM_APP_STORE_REPO" \
    -c "$CERTCACHE_CERTBOT_EMAIL" \
    -i "$CUSTOM_IMAGE_URI" \
    -n "Setup Rapptor" \
    -r "$INSTALL_DIR" \
    -t "$TEST_CERT_ARG" \
    > /dev/null 2> /dev/null
  echo "done"
}

disable_systemd_resolve()
{
  apt-get-install lsof
  if lsof -i :53 | grep systemd-resolve > /dev/null; then
    echo -n "Disabling systemd-resolve: "
    echo DNSStubListener=no >> /etc/systemd/resolved.conf
    ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
    systemctl stop systemd-resolved
    echo "done"
  fi
}

error()
{
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    echo "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
  fi
  exit "${code}"
}

exit_with_code()
{
  echo $1 >&2
  exit $2
}

install_app()
{
  echo -n "Pulling Rapptor repository: "
  if [[ ! -z "$DEPLOY_USER" && ! -z "$DEPLOY_PASSWORD" ]]; then
    REPO_URI="https://$DEPLOY_USER:$DEPLOY_PASSWORD@$APP_REPO"
  else
    REPO_URI="https://$APP_REPO"
  fi

  if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
    git clone "$REPO_URI" "$INSTALL_DIR" > /dev/null 2> /dev/null
  fi
  cd "$INSTALL_DIR"
  git remote set-url origin "$REPO_URI"
  git fetch > /dev/null 2> /dev/null
  git checkout "$GIT_BRANCH" > /dev/null 2> /dev/null
  git reset --hard origin/$GIT_BRANCH > /dev/null 2> /dev/null
  echo "done"
}

install_docker()
{
  if ! command -v docker > /dev/null; then
    echo -n "Installing Docker: "
    apt-get update > /dev/null
    apt-get-install ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    if [[ $PLATFORM == "debian" ]]; then
      install_docker_debian
    elif [[ $PLATFORM == "ubuntu" ]]; then
      install_docker_ubuntu
    fi
    chmod a+r /etc/apt/keyrings/docker.asc
    apt-get update > /dev/null
    apt-get-install \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-buildx-plugin \
      docker-compose-plugin
    echo "done"
  fi
}

install_docker_debian()
{

  curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
}

install_docker_ubuntu()
{
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
}

install_apps() {
  echo -n "Installing Rapptor base apps: "
  docker compose -f "$COMPOSE_FILE" run \
    -T \
    --rm \
    rapptoros \
    npm --no-update-notifier --silent run cli -- \
    install \
    app.93million.wg-easy \
    > /dev/null 2> /dev/null
  echo "done"
}

install_git()
{
  if ! command -v git > /dev/null; then
    echo -n "Installing git: "
    apt-get-install git
    echo "done"
  fi
}

install_cli()
{
  mkdir -p "/usr/local/bin/"
  ln -fs "$INSTALL_DIR/bin/rapptor" "/usr/local/bin/rapptor"
}

output_setup_link()
{
    echo "Generating setup link:"
    SETUP_LINK="$(docker compose -f "$COMPOSE_FILE" run -T --rm rapptoros npm run --no-update-notifier --silent cli -- setuplink 2> /dev/null)"
    cat "$INSTALL_DIR/bin/install/logo.txt"
    echo "================================================================================"
    echo "                              RAPPTOR IS INSTALLED!"
    echo "--------------------------------------------------------------------------------"
    echo
    echo "Follow this link to set up your instance (wait 60 seconds for app to start):"
    echo
    echo $SETUP_LINK
    echo
    echo "================================================================================"
}

pull_container_images()
{
  echo -n "Pulling Rapptor images: "

  if [[ ! -z "$DEPLOY_USER" && ! -z "$DEPLOY_PASSWORD" && ! -z "$DOCKER_REGISTRY" ]]; then
    echo "$DEPLOY_PASSWORD" | docker login -u "$DEPLOY_USER" --password-stdin "$DOCKER_REGISTRY" \
      > /dev/null 2> /dev/null
  fi

  docker compose -f "$COMPOSE_FILE" pull > /dev/null 2> /dev/null
  echo "done"
}

start_app()
{
  echo -n "Starting Rapptor: "
  docker compose -f "$COMPOSE_FILE" down --remove-orphans > /dev/null 2> /dev/null
  docker compose -f "$COMPOSE_FILE" up -d  > /dev/null 2> /dev/null
  echo "done"
}

main()
{
  check_requirements
  echo "Installing Rapptor"
  apt-get update > /dev/null
  disable_systemd_resolve
  install_docker
  install_git
  install_app
  install_cli
  create_env_file
  create_docker_config
  pull_container_images
  create_instance_data
  install_apps
  start_app
  output_setup_link
}

trap 'error ${LINENO}' ERR

main "$@"
