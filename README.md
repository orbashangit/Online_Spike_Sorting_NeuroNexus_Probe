# Online Spike Sorting NeuroNexus Probe
An application for automating the spike sorting process of neurodata recorded from a NeuroNexus probe.

## Instructions for Successfully Recording and Streamlining Data Processing of NeuroNexus Probe Experiments

### Pre-recording Preparation
- Familiarize yourself with the probe and map the channels in the .cfg file to the correct configuration.
- Record the neural signal without applying a high-pass filter.

### Data File Format Conversion 
- Convert the raw data (CSC#.ncs files) to a single .dat file using 'mainBatchConvertNLXforKilosort.m' found in the 'NlxForKilosort-main' directory.
- Outputs include:
  - .mat files containing 1D arrays with samples in int16, one file per channel, stored in a folder named Temp inside OutFolder.
  - .dat file containing samples from all channels in int16 format, organized as N channels x N samples (one row per channel). This .dat file can be read in Kilosort for spike sorting. 
- For further details, refer to the README.md file in the 'NlxForKilosort-main' directory.

### Online Spike Sorting  
- Create a channel map .m file (see 'Channel_Maps_A1x32-Poly' for an example).
- Sign up at https://www.ontologic.ly/ and upload the .dat and channel map files.
- Run Kilosort 2.5, making sure to adjust the relevant hyperparameters.
- Use Phy on the Kilosort results, review the results, and merge/split/reassign relevant clusters.
- Download Kilosort and Phy results.

### (Optional) Reading Phy Results from .npy Files to .mat Files
- You can extract the relevant Phy results back to a MATLAB format by using 'readKilosortNpyFiles.m.' From there, you can begin analyzing your data.

