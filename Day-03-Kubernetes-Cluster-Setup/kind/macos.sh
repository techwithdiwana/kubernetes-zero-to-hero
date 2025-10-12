#!/usr/bin/env bash
set -euo pipefail
brew install kind
kind create cluster --name dev --config kind/kind-config.yaml
