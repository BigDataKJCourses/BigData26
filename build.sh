#!/bin/bash
# Stop the script if any command fails
set -e

echo "-------------------------------------------------------"
echo "--- Building Docker Images for BigData26 Lab ---"
echo "-------------------------------------------------------"

# Building Spark Image
echo "Building Spark image (4.1.1)..."
docker build -t bigdata26-spark-image:4.1.1 -f Dockerfile.spark .

# Building Flink Image
echo "Building Flink image (2.2.0)..."
docker build -t bigdata26-flink-image:2.2.0 -f Dockerfile.flink .

# Building Jupyter Image
echo "Building Jupyter image (Python 3.10)..."
docker build -t bigdata26-jupyter-image:python-3.10 -f Dockerfile.jupyter .

echo "-------------------------------------------------------"
echo "--- All images built successfully! ---"
echo "-------------------------------------------------------"
echo "You can now start the environment by running:"
echo "docker compose --profile <profile_name> up -d"
echo "-------------------------------------------------------"