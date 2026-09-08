#!/bin/sh
set -eu

config_dir=/lzcapp/var/moneyprinterturbo/config
config_file="$config_dir/config.toml"
mkdir -p "$config_dir"

if [ ! -s "$config_file" ]; then
  # The API and WebUI containers start this script concurrently and commonly
  # have the same PID. Use a filesystem-generated name so they cannot clobber
  # each other's temporary configuration file on the shared /lzcapp/var mount.
  temporary_file=$(mktemp "$config_dir/config.toml.tmp.XXXXXX")
  trap 'rm -f "$temporary_file"' EXIT HUP INT TERM
  cp /lzcapp/pkg/content/runtime/config.example.toml "$temporary_file"
  chmod 600 "$temporary_file"
  mv -f "$temporary_file" "$config_file"
  trap - EXIT HUP INT TERM
fi

if grep -q '^endpoint = ""$' "$config_file"; then
  escaped_endpoint=$(printf '%s' "$MPT_PUBLIC_API_URL" | sed 's/[\\&|]/\\&/g')
  sed -i "s|^endpoint = \"\"$|endpoint = \"$escaped_endpoint\"|" "$config_file"
fi

if sed -n '/^\[app\]$/,/^\[/p' "$config_file" | grep -q '^api_key = ""$'; then
  escaped_api_key=$(printf '%s' "$MPT_API_KEY" | sed 's/[\\&|]/\\&/g')
  sed -i "/^\[app\]$/,/^\[/ s|^api_key = \"\"$|api_key = \"$escaped_api_key\"|" "$config_file"
fi

ln -sfn "$config_file" /MoneyPrinterTurbo/config.toml
