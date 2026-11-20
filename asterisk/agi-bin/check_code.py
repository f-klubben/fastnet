#!/usr/bin/env python3
import sys

# --- read the AGI environment (a block of "agi_xxx: value" lines ending in a blank line)
env = {}
while True:
    line = sys.stdin.readline().strip()
    if line == "":
        break
    key, _, value = line.partition(":")
    env[key.strip()] = value.strip()

code = sys.argv[1] if len(sys.argv) > 1 else ""

# --- placeholder logic: replace with your real check (database, API, etc.)
VALID = {"1234": "bowman", "9999": "expired"}
result = VALID.get(code, "invalid")

# --- send a command to Asterisk and read its reply
def agi(cmd):
    sys.stdout.write(cmd + "\n")
    sys.stdout.flush()
    return sys.stdin.readline().strip()

agi(f'SET VARIABLE AGI_RESULT "{result}"')
