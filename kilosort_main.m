try
  addpath(genpath('/opt/kilosort-25')) % path to kilosort folder
  addpath(genpath('/opt/npy-matlab/npy-matlab')) % for converting to Phy

  ops.trange    = [0 Inf]; % time range to sort
  ops.NchanTOT  = 385; % total number of channels in your recording

  % sample rate
  ops.fs = 32000;  

  % frequency for high pass filtering (150)
  ops.fshigh = 50;   

  % threshold on projections (like in Kilosort1, can be different for last pass like [10 4])
  ops.Th = [10 4];  

  % how important is the amplitude penalty (like in Kilosort1, 0 means not used, 10 is average, 50 is a lot) 
  ops.lam = 10;  

  % splitting a cluster at the end requires at least this much isolation for each sub-cluster (max = 1)
  ops.AUCsplit = 0.9; 

  % minimum spike rate (Hz), if a cluster falls below this for too long it gets removed
  ops.minFR = 0.02; 

  % number of samples to average over (annealed from first to second value) 
  ops.momentum = [20 400]; 

  % spatial constant in um for computing residual variance of spike
  ops.sigmaMask = 30; 

  % threshold crossings for pre-clustering (in PCA projection space)
  ops.ThPre = 8; 

  % spatial scale for datashift kernel
  ops.sig = 20;

  % type of data shifting (0 = none, 1 = rigid, 2 = nonrigid)
  ops.nblocks = 5;


  %% danger, changing these settings can lead to fatal errors
  % options for determining PCs
  ops.spkTh           = -1 * 6;      % spike threshold in standard deviations (-6)
  ops.reorder         = 1;       % whether to reorder batches for drift correction. 
  ops.nskip           = 25;  % how many batches to skip for determining spike PCs

  ops.GPU                 = 1; % has to be 1, no CPU version yet, sorry
  % ops.Nfilt             = 1024; % max number of clusters
  ops.nfilt_factor        = 4; % max number of clusters per good channel (even temporary ones)
  ops.ntbuff              = 64;    % samples of symmetrical buffer for whitening and spike detection
  ops.NT                  = 64*1024+ ops.ntbuff; % must be multiple of 32 + ntbuff. This is the batch size (try decreasing if out of memory). 
  ops.whiteningRange      = 32; % number of channels to use for whitening each channel
  ops.nSkipCov            = 25; % compute whitening matrix from every N-th batch
  ops.scaleproc           = 200;   % int16 scaling of whitened data
  ops.nPCs                = 3; % how many PCs to project the spikes into
  ops.useRAM              = 0; % not yet available

  %%
  ops.fproc   = fullfile('./temp_wh.dat'); % proc file on a fast SSD
  ops.chanMap = load(fullfile('chanMap.mat'));
  ops.fbinary = fullfile('recording.dat');

  % mark excluded channels as disconnected
  % the given excluded channels are a 0-indexed comma dilimeted string
  parsedChannelExclusions = str2num('');
  for excludedChannel = parsedChannelExclusions
      ops.chanMap.connected(excludedChannel + 1) = false;
  end

  % preprocess data to create temp_wh.dat
  rez = preprocessDataSub(ops);
  %
  % NEW STEP TO DO DATA REGISTRATION
  rez = datashift2(rez, 1); % last input is for shifting data

  % ORDER OF BATCHES IS NOW RANDOM, controlled by random number generator
  iseed = 1;
                  
  % main tracking and template matching algorithm
  rez = learnAndSolve8b(rez, iseed);

  % final merges
  rez = find_merges(rez, 1);

  % final splits by SVD
  rez = splitAllClusters(rez, 1);

  % decide on cutoff
  rez = set_cutoff(rez);
  % eliminate widely spread waveforms (likely noise)
  rez.good = get_good_units(rez);

  fprintf('found %d good units \n', sum(rez.good>0))

  % write to Phy
  fprintf('Saving results to Phy  \n')
  rezToPhy(rez, './');

  %% if you want to save the results to a Matlab file...

  % discard features in final rez file (too slow to save)
  rez.cProj = [];
  rez.cProjPC = [];

  % final time sorting of spikes, for apps that use st3 directly
  [~, isort]   = sortrows(rez.st3);
  rez.st3      = rez.st3(isort, :);

  % Ensure all GPU arrays are transferred to CPU side before saving to .mat
  rez_fields = fieldnames(rez);
  for i = 1:numel(rez_fields)
      field_name = rez_fields{i};
      if(isa(rez.(field_name), 'gpuArray'))
          rez.(field_name) = gather(rez.(field_name));
      end
  end

  % save final results as rez2
  fprintf('Saving final results in rez2  \n')
  fname = fullfile('./rez2.mat');
  save(fname, 'rez', '-v7.3');
catch error
  fprintf(getReport(error, 'extended'));
  quit(1);
end
quit(0);
