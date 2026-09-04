#!/bin/sh
set -eu

config_dir=/lzcapp/var/moneyprinterturbo/config
config_file="$config_dir/config.toml"
mkdir -p "$config_dir"

if [ ! -s "$config_file" ]; then
  temporary_file="$config_dir/config.toml.tmp.$$"
  cp /lzcapp/pkg/content/runtime/config.example.toml "$temporary_file"
  chmod 600 "$temporary_file"
  mv -f "$temporary_file" "$config_file"
fi

ln -sfn "$config_file" /MoneyPrinterTurbo/config.toml
