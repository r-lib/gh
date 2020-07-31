#!/bin/sh
# prevents attempts by `git credential fill` to interact with user
exec echo ""
