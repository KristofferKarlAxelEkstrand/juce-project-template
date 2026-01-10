#!/bin/bash
# .devcontainer/start-audio.sh
# Start virtual audio and MIDI for plugin testing in dev container
set -euo pipefail

echo "Starting JACK with dummy driver..."

# Start JACK with dummy (null) audio driver - no real hardware needed
jackd -d dummy -r 48000 -p 512 &
JACK_PID=$!
sleep 2

# Verify JACK started
if ! pgrep -x jackd > /dev/null; then
    echo "Error: Failed to start JACK"
    exit 1
fi

echo "MIDI ports available via ALSA sequencer"
echo "Use 'aconnect -l' to list MIDI connections"

echo ""
echo "Virtual audio/MIDI ready."
echo "  JACK sample rate: 48000 Hz"
echo "  JACK buffer size: 512 samples"
echo ""
echo "To stop: kill $JACK_PID"
