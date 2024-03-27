# WIN2PhaseNet
Tips of this tool

## Use DEBUG mode
You can use DEBUG mode for WIN2PhaseNet.bash and PhaseNet.bash to enter in the docker container.
Set "DEBUG" for the first argument and execute the bash file as the following.
```
$ ./WIN2PhaseNet.bash DEBUG
$ ./PhaseNet.bash DEBUG
```

## Notice for plot_figure option of PhaseNet
PhaseNet has `--plot_figure` option to output waveform figures with PhaseNet prediction.
Note that this option causes parallel processing to be performed **using all CPUs** in the operating environment.