#!/bin/bash

# @echo off
# start chrome --profile-directory="Person 1" %*


# Start Chrome with the "Person 1" profile and pass all arguments
echo opening chrome with the link provided

start chrome --profile-directory="Person 1" "$@"
