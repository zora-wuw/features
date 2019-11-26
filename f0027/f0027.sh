#!/bin/bash
source ~/anaconda3/etc/profile.d/conda.sh
conda activate sodalab
Xvfb :99 -ac -noreset &
export DISPLAY=:99
python3 f0027.py
