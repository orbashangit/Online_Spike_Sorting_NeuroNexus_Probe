folderPath = 'E:\MoltiTT\300323SE\run1\2023-03-30_13-06-24';
date = '300323SE';
run = 'run5';
cd (folderPath)
clusterTable = readtable('clusterTable.csv');

clusterID = clusterTable.ClusterID;
clusterChannel = clusterTable.ClusterChannel;
clusterNum = clusterTable.ClusterNum;
clusterDepth = clusterTable.ClusterDepth;
mkdir(folderPath, 'slps');
% need for first run to initialize light time params
%[exp] = readExpDescFile(pwd); fileIndx = 1;
%lp = initLightParam(exp, fileIndx, 1); lp = readLpData(lp, [-10 10], [0 0 0],[clusterChannel(1),clusterNum(1)]);



for i  = 15
    %% initialaise cluster parameters
    slp = [];
    newClusterID = clusterID(i);
    newClusterChannel = clusterChannel(i);
    newClusterNum = clusterNum(i);
    newClusterDepth = clusterDepth(i);
    cluster = [newClusterChannel,newClusterNum];
    ParentFolder = (strcat(folderPath,'\slps')); 
    NewSubFolder = [strcat(date,'_',run,'_',num2str(newClusterChannel),'_',num2str(newClusterNum))];
    saveFolder = [strcat(ParentFolder,'\',NewSubFolder,'\')];
    %% Load lp
    [exp] = readExpDescFile(pwd); fileIndx = 1;
    lp = initLightParam(exp, fileIndx, 1); lp = readLpData(lp, [-10 10], [1 1 1],cluster);



    %% Initial Analysis
    hotSpotMap
    hsm = gcf;

    totalReps = min(size(lp.eventsLog,1), length(lp.LightSpikesFR_unSorted));
    numSpots = mean(lp.stimuliDistribution);
    spotSize = lp.stimuliSize(1);

    % responses
    lfr = round(lp.LightSpikesFR_unSorted*lp.statTimeRange(2)/1000);
    spikes = lfr-(lp.fr_expectedSpikeCount*lp.statTimeRange(2)/1000);

    % patterns - stimuli without the borders
    patterns = cutEventsLog(lp);
    patterns = patterns./max(patterns);

    [zsta, rsta, sta] = shuffNormSTA(lp, 5);
    sz = size(sta);

    % Just running verifySTA on whole thing - can run with different intervals
    % to find the best portion of your experiment.
    [verifyScore] = verifySTA(lp);
    vr = gcf;

    %% Display figures
    % Label first panel:
    figure(hsm)
    hold all
    subplot(2,3,1)
    title({[newClusterID '; ' fileIndxStr(lp) ' cluster ' num2str(cluster)], ...
        [num2str(spotSize) ' pixels; ' num2str(numSpots) ' spots; '...
        ]},'Interpreter','none')
    hold off

    % Iterative ranked STA - I think clearer for initial view than plain
    % normalised; replaces sixth panel
    subplot(2,3,6)
    plotSTA(lp,rsta,1)
    title({'ranked STA', 'adjusted z-scores'})

    %% save HotSpotMap
    mkdir(ParentFolder,NewSubFolder)

    set(hsm,'units','normalized','outerposition',[0 0 1 1])
    saveas(hsm,[saveFolder 'hotSpotMap'],'png');

    % save verifySTA
    set(vr,'units','normalized','outerposition',[0 0 1 1])
    saveas(vr,[saveFolder 'verifySTA'],'png');



    %% Save results
    slp.clusID = newClusterID;
    slp.folder = saveFolder;
    slp.lptitle = NewSubFolder;
    slp.totalReps = totalReps;
    slp.depth = newClusterDepth;
    slp.sta = sta;
    slp.rsta = rsta;
    slp.zsta = zsta;
    slp.spikes = spikes;
    slp.patterns = patterns;
    slp.sz = sz;
    slp.lpmat = [patterns spikes'];
    slp.lpmat = [sz zeros(1, size(patterns,2) - 1); slp.lpmat];
    slp.st = lp.st;
    slp.phase = lp.phase;
    slp.phase2 = lp.phase2;
    slp.pPhase = lp.pPhase;

    % Prep for further analysis:
    slp.corrmat = [];
    slp.numgvec = [];
    slp.centres = [];
    slp.GausSigCorr = [];
    slp.gausRec = [];
    slp.gausparam = [];

    save([saveFolder 'slp_ of_' NewSubFolder '.mat'],'slp')
    close all

end