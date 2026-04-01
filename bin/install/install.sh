#! /usr/bin/env bash

set -E

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
LOG_FILE="/tmp/rapptor-install.log"
ERROR_LOG_FILE="/tmp/rapptor-install.error.log"

export DEBIAN_FRONTEND=noninteractive

exec 3<> /dev/stdout
exec 4<> /dev/stderr
exec 1> "$LOG_FILE"
exec 2> "$ERROR_LOG_FILE"

apt-get-install ()
{
  if ! apt-get -qqy install $@; then
    logStart "Another process is blocking apt-get. Waiting for process to complete."
    if ! apt-get -y -o DPkg::Lock::Timeout=600 install $@; then
      E_CODE=$?
      logStart "Unable to install packages. Another process is blocking apt-get. Please wait for it to complete and try to install Rapptor again"
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
  logStart "Configuring instance data: "
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
    -t "$TEST_CERT_ARG"
  logEnd
}

disable_systemd_resolve()
{
  apt-get-install lsof
  if lsof -i :53 | grep systemd-resolve > /dev/null; then
    logStart "Disabling systemd-resolve: "
    echo DNSStubListener=no >> /etc/systemd/resolved.conf
    ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
    systemctl stop systemd-resolved
    logEnd
  fi
}

error()
{
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"

  logError

  if [[ -n "$message" ]] ; then
    logError \
      "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    logError \
      "Error on or near line ${parent_lineno}; exiting with status ${code}"
  fi

  cat "$ERROR_LOG_FILE" >&4

  logError
  logError
  logError "Rapptor failed to install"
  logError "Please file an issue at https://github.com/93million/rapptor/issues and include the output from this script"
  logError

  remove_logs

  exit "${code}"
}

exit_with_code()
{
  logError "$1"
  exit $2
}

install_app()
{
  logStart "Pulling Rapptor repository: "
  if [[ ! -z "$DEPLOY_USER" && ! -z "$DEPLOY_PASSWORD" ]]; then
    REPO_URI="https://$DEPLOY_USER:$DEPLOY_PASSWORD@$APP_REPO"
  else
    REPO_URI="https://$APP_REPO"
  fi

  if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
    git clone "$REPO_URI" "$INSTALL_DIR"
  fi
  cd "$INSTALL_DIR"
  git remote set-url origin "$REPO_URI"
  git fetch
  git checkout "$GIT_BRANCH"
  git reset --hard origin/$GIT_BRANCH
  logEnd
}

install_docker()
{
  if ! command -v docker > /dev/null; then
    logStart "Installing Docker: "
    apt-get update
    apt-get-install ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    if [[ $PLATFORM == "debian" ]]; then
      install_docker_debian
    elif [[ $PLATFORM == "ubuntu" ]]; then
      install_docker_ubuntu
    fi
    chmod a+r /etc/apt/keyrings/docker.asc
    apt-get update
    apt-get-install \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-buildx-plugin \
      docker-compose-plugin
    logEnd
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
  logStart "Installing Rapptor base apps: "
  docker compose -f "$COMPOSE_FILE" run \
    -T \
    --rm \
    rapptoros \
    npm --no-update-notifier --silent run cli -- \
    install \
    app.93million.wg-easy
  logEnd
}

install_git()
{
  if ! command -v git > /dev/null; then
    logStart "Installing git: "
    apt-get-install git
    logEnd
  fi
}

install_cli()
{
  mkdir -p "/usr/local/bin/"
  ln -fs "$INSTALL_DIR/bin/rapptor" "/usr/local/bin/rapptor"
}

logEnd()
{
  log 'done'
}

logStart()
{
  echo -n "$1" >&3
}

log()
{
  echo "$1" >&3
}

logError()
{
  echo "$1" >&4
}

output_setup_link()
{
  log "Generating setup link:"
  SETUP_LINK="$(
    docker compose -f "$COMPOSE_FILE" run \
      -qT \
      --rm \
      rapptoros \
      npm \
      run \
      --no-update-notifier \
      --silent \
      cli \
      -- \
      setuplink \
      -r
  )"
  cat "$INSTALL_DIR/bin/install/logo.txt" >&3
  log "================================================================================"
  log "                              RAPPTOR IS INSTALLED!"
  log "--------------------------------------------------------------------------------"
  log
  log "Follow this link to set up your instance (wait 60 seconds for app to start):"
  log
  log $SETUP_LINK
  log
  log "================================================================================"
}

pull_container_images()
{
  logStart "Pulling Rapptor images: "

  if [[ ! -z "$DEPLOY_USER" && ! -z "$DEPLOY_PASSWORD" && ! -z "$DOCKER_REGISTRY" ]]; then
    echo "$DEPLOY_PASSWORD" | docker login -u "$DEPLOY_USER" --password-stdin "$DOCKER_REGISTRY"
  fi

  docker compose -f "$COMPOSE_FILE" pull
  logEnd
}

remove_logs()
{
  rm "$LOG_FILE"
  rm "$ERROR_LOG_FILE"
}

start_app()
{
  logStart "Starting Rapptor: "
  docker compose -f "$COMPOSE_FILE" up --quiet-pull -d 
  logEnd
}

stop_app()
{
  logStart "Stopping Rapptor if running: "
  docker compose -f "$COMPOSE_FILE" down --remove-orphans
  logEnd
}

sync_certs()
{
  logStart "Syncing certs: "
  docker compose rm -s certcache
  docker compose -f "$COMPOSE_FILE" \
    run --remove-orphans \
    --rm \
    --name certcache-sync \
    -q \
    -p "53:53/tcp" \
    -p "53:53/udp" \
    certcache \
    sync
  logEnd
}

main()
{
  check_requirements
  log "Installing Rapptor"
  apt-get update
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
  stop_app
  sync_certs
  start_app
  output_setup_link
  remove_logs
}

trap 'error ${LINENO}' ERR

main "$@"
