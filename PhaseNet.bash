#!/bin/bash

args=$@

python ../PhaseNet/phasenet/predict.py --model_dir=../PhaseNet/model/190703-214543 --amplitude --plot_figure $args