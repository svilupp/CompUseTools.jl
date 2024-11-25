#!/bin/bash

# Kill any existing Chrome instances
pkill -f chrome
pkill -f chromium

# Start Chrome in headless mode
chromium-browser --remote-debugging-port=9222 --headless --no-sandbox &

# Wait for Chrome to initialize
sleep 5

# Run the test script
julia --project=. examples/test_annotate_page.jl

# Cleanup
pkill -f chrome
pkill -f chromium
