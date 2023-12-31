% Use BatchConvertNLXforKilosort to read .ncs files from multiple recordings with 64 channels each. 
% Set MakeMat to 0 if you don't want to make .mat files, because you've done it previously.
% FileList is a tab-delimited text file with the following columns: 
% InFolder - path to folder with recording (all the .ncs files are here)
% OutFolder - path where output .dat files will be stored. Mat files are stored in a folder called Temp inside this folder. 
% RatID - rat ID
% RecDate - recording date
% BadChans - list of bad channels. Bad channels will not be read/processed and contain only zeros in the final .dat file. If there are no bad channels, set to 0. 
 
% Output filenames are combined RatID, RecDate, and channel number (where appropriate). 
% 
% The BatchConvertNLXforKilosort script calls ConvertNLXforKilosort_v5.m, which calls readEegDataForKilosort, which in turn requires Nlx2MatCSC.mex provided by Neuralynx. 
% 
% Outputs are: 
% .mat files containing 1D array with samples in int16, one file per channel. Stored in a folder called Temp inside OutFolder. 
% .dat file containing samples from all channels in int16, organized as N channels x N samples (one row per channel). This .dat file can be read in Kilosort for spikesorting. 
% To change sampling rate and/or the length of sections written to .dat, edit line 24 and 25 in ConvertNLXforKilosort_v5. 


MakeMat = 1; 
FileList = 'E:\kilosort_ontologic\NlxForKilosort-main\NlxForKilosort-main\FileListExample.txt'; 

InList = fopen(FileList);
InFiles = textscan(InList,'%s%s%s%s%s');
fclose(InList);
 
for f = 1:size(InFiles{1},1)

InFolder = InFiles{1}{f};
OutFolder = InFiles{2}{f};
RatID = InFiles{3}{f};
RecDate = InFiles{4}{f};
BadChans = InFiles{5}{f}; BadChans = str2num(BadChans);

disp(['file ',num2str(f),' of ',num2str(size(InFiles{1},1))])
disp(['processing ',InFolder])

%[~,~] = ConvertNLXforKilosort_v2(InFolder,OutFolder,RatID,RecDate);
[~,~] = ConvertNLXforKilosort(InFolder,OutFolder,RatID,RecDate,BadChans,MakeMat);
disp(['completed ',InFolder])

end
