# let the gocd dog wake up first
setup() {

  retries=0
  max_retries=120

  # tolerate that commands fail
  set +e

  until curl -f http://gocd-agent:8152/health/latest/isConnectedToServer >/dev/null; do
    ((retries++))
    if [ "$retries" = "$max_retries" ]; then
      echo "GoCD doesn't seem to come up" >&1
      exit 1
    fi
    sleep 1
  done

  set -e

}

@test "agent registered with the master" {
  curl -f http://gocd-agent:8152/health/latest/isConnectedToServer | grep OK
}
