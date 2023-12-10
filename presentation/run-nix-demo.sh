#!/usr/bin/env bash

set -e

cleanup() {
    echo "Cleaning up tmux session..."
    tmux kill-session -t run-nix-demo
    echo "Done."
}

trap cleanup EXIT

# Run the backend and frontend side-by-side
tmux new-session -d -s run-nix-demo -f <(echo "set-option -g 'tmux-integral-cmd' on")
tmux split-window -h -t run-nix-demo

tmux send-keys -t run-nix-demo:0.0 'cd backend && clear && echo "Press Ctrl+B D to stop both servers." && npm start' C-m
tmux send-keys -t run-nix-demo:0.1 'cd frontend && clear && npm run dev' C-m

tmux attach -t run-nix-demo
