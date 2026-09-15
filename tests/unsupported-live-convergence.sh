#!/usr/bin/env bash
# Live sync is intentionally not run: this test does not claim symlink repair.
set -euo pipefail

echo "SKIP: live symlink convergence is unsupported; native sync is not run in CI"
