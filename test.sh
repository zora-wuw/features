#!/usr/bin/env bash

echo "[DEFAULT]" > config.ini
echo "CSV-File-Path=SportClubs.csv" >> config.ini
echo "JSON-File-Path=SportClubs.json" >> config.ini
PATH="/var/lib/jenkins/jnotebook/bin:$PATH"
export PATH
jupyter nbconvert --to script ../SODA_Features/f0017/f0017.ipynb
mv ../SODA_Features/f0017/f0017.py .
python3 f0017.py
