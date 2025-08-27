#!/bin/bash

read -p "Enter the number of instances to run: " instances
read -p "Enter the command to run: " cmd

for ((i=1; i<=instances; i++)); do
  $cmd &
done

wait
echo "All $instances instances have completed."
