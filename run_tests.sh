#!/bin/sh
# Runs the test suite with GNU Octave (set OCTAVE to the octave-cli executable if not on PATH)
cd "$(dirname "$0")/tests" && "${OCTAVE:-octave-cli}" --no-gui --quiet --eval "run_tests"
