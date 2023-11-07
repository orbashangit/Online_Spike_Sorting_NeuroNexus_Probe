%% readKilosortNpyFiles
% this repository can be found at: https://github.com/kwikteam/npy-matlab
% You will need it to load the data in matlab.
%addpath(genpath('C:\Users\Nick\Documents\GitHub\npy-matlab'))


% this repository can be found at: https://github.com/cortex-lab/spikes
% It is not necessary for working with these data in general, but it is
% necessary for some of the functionality of this particular script.
%addpath(genpath('C:\Users\Nick\Documents\GitHub\spikes'))

%%
folderPath = 'E:\kilosort_ontologic\Kilosort 5 17 23 1_34 PM run5 HP50\Kilosort 5 17 23 1_34 PM run5 HP50';
cd (folderPath)
nShanks = 1;
Fs = 32000;
numOfChanels = 32;
channelPositions = readNPY('channel_positions.npy');
yc = channelPositions(:,2); xc = channelPositions(:,1);

% spike_clusters is a length nSpikes vector with the cluster identities of every
% spike
spikeClusters = readNPY('spike_clusters.npy')+1;
% ss is a length nSpikes vector with the spike time of every spike (in
% samples)
ss = readNPY('spike_times.npy');

% convert to times in seconds
st = double(ss)/Fs;


% spikeTemplates is like spike_clusters, except with the template numbers rather than
% cluster numbers. Each spike was extracted by one particular template
% (identified here), but when templates were merged in the manual sorting,
% the spikes of both take on a new cluster identity in clu. So
% spikeTemplates reflects the original output of the algorithm; clu is the
% result of manual sorting.
spikeTemplates = readNPY('spike_templates.npy')+1; % note: zero-indexed

% tempScalingAmps is a length nSpikes vector with the "amplitudes":
% each spike is extracted by a particular template after scaling the
% template by some factor - that factor is the amplitude. The actual
% amplitude of the spike is this amplitude multiplied by the size of the
% template itself - we compute these later.
spikeAmplitudes = readNPY('amplitudes.npy');

cluster_info = readtable('cluster_info.tsv','FileType', 'text', 'Delimiter', '\t');
clusterIDs = table2array(cluster_info(:,1))+1;
clusterChannels = table2array(cluster_info(:,6))+1; 
clusterDepths = table2array(cluster_info(:,7)); 
clusterGroups = table2array(cluster_info(:,4));
clusterAddedGroups = table2array(cluster_info(:,9));
clusterNspikes = table2array(cluster_info(:,10));
goodClusterIDs = clusterIDs(string(clusterGroups)=='good');
goodClusterrChannels = clusterChannels(string(clusterGroups)=='good');
goodClusterDepths = clusterDepths(string(clusterGroups)=='good');
goodClusterNspikes = clusterNspikes(string(clusterGroups)=='good');


channelClusterCount = zeros(numOfChanels,1);

%% 
% % Create an empty table to save as csv
clusterID = [];
clusterChannel = [];
clusterNum = [];
clusterDepth = [];
clusterGroup = [];
Nspikes = [];

clusterTable = table(clusterID', clusterChannel', clusterNum', clusterDepth', clusterGroup',Nspikes',...
    'VariableNames', {'ClusterID', 'ClusterChannel', 'ClusterNum', 'ClusterDepth', 'ClusterGroup','Nspikes'});

for i = 1:numel(goodClusterIDs)
    goodIdx = goodClusterIDs(i);
    currentChannel = goodClusterrChannels(i);
    currentClusterSpikeTimes = st(find(spikeClusters==goodIdx));
    channelClusterCount(currentChannel) = channelClusterCount(currentChannel) +  1;
    fileName = (("KS_SE"+currentChannel+"_SS_0"+channelClusterCount(currentChannel)+".txt"));
    writematrix(currentClusterSpikeTimes, fileName)


    newClusterID = goodIdx;  % Assign a new value for clusterID
    newClusterChannel = currentChannel;  % Assign a new value for clusterChannel
    newClusterNum = channelClusterCount(currentChannel);  % Assign a new value for clusterWithinChannel
    newClusterDepth = goodClusterDepths(i);  % Assign a new value for clusterDepth
    newClusterGroup = "good";  % Assign a new value for clusterGroup
    newNspikes = goodClusterNspikes(i);
    % Add the parameters to the table
    newRow = {newClusterID, newClusterChannel, newClusterNum, newClusterDepth, newClusterGroup,newNspikes};
    clusterTable = [clusterTable; newRow];
end
% Specify the file name and path
filename = 'clusterTable.csv';

% Save the table as a CSV file
writetable(clusterTable, filename);


% temps are the actual template waveforms. It is nTemplates x nTimePoints x
% nChannels (in this case 1536 x 82 x 374). These should be basically
% identical to the mean waveforms of each template
temps = readNPY('templates.npy');

% The templates are whitened; we will use this to unwhiten them into raw
% data space for more accurate measurement of spike amplitudes; you would
% also want to do the same for spike widths.
winv = readNPY('whitening_mat_inv.npy');

% compute some more things about spikes and templates; see function for
% documentation
%[spikeAmps, spikeDepths, templateYpos, tempAmps, tempsUnW,templateDuration, waveforms] = ...
%    templatePositionsAmplitudes(temps, winv, yc, spikeTemplates, spikeAmplitudes);


