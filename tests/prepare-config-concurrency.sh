#!/bin/sh
set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test_root=$(mktemp -d /tmp/moneyprinterturbo-config-test.XXXXXX)
trap 'rm -rf "$test_root"' EXIT HUP INT TERM

mkdir -p "$test_root/runtime" "$test_root/app"
cp "$repository_root/content/runtime/prepare-config.sh" \
  "$repository_root/content/runtime/config.example.toml" \
  "$test_root/runtime/"

# Redirect the runtime-only absolute paths into the isolated test directory.
sed -i 's#config_dir=/lzcapp/var/moneyprinterturbo/config#config_dir=$TEST_CONFIG_DIR#' \
  "$test_root/runtime/prepare-config.sh"
sed -i 's#/lzcapp/pkg/content/runtime/config.example.toml#$TEST_RUNTIME_DIR/config.example.toml#' \
  "$test_root/runtime/prepare-config.sh"
sed -i 's#/MoneyPrinterTurbo/config.toml#$TEST_APP_DIR/config.toml#' \
  "$test_root/runtime/prepare-config.sh"

iteration=1
while [ "$iteration" -le 25 ]; do
  config_dir="$test_root/run-$iteration/config"
  mkdir -p "$config_dir"

  run_prepare() {
    TEST_CONFIG_DIR="$config_dir" \
      TEST_RUNTIME_DIR="$test_root/runtime" \
      TEST_APP_DIR="$test_root/app" \
      MPT_PUBLIC_API_URL=https://example.test/api \
      MPT_API_KEY=test-api-key \
      unshare --user --map-root-user --pid --fork \
      sh "$test_root/runtime/prepare-config.sh"
  }

  run_prepare & first_pid=$!
  run_prepare & second_pid=$!
  wait "$first_pid"
  wait "$second_pid"

  test -s "$config_dir/config.toml"
  test "$(grep -c '^endpoint = "https://example.test/api"$' "$config_dir/config.toml")" -eq 1
  test "$(grep -c '^api_key = "test-api-key"$' "$config_dir/config.toml")" -eq 1
  test "$(grep -c '^api_key = ""$' "$config_dir/config.toml")" -eq 5
  test -z "$(find "$config_dir" -maxdepth 1 -type f -name 'config.toml.tmp.*' -print -quit)"

  iteration=$((iteration + 1))
done

echo "prepare-config concurrent initialization: 25/25 passed"
