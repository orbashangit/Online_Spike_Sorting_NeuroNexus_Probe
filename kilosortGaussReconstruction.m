MUCall = readtable('E:\MoltiTT\300323SE\run3\2023-03-30_16-46-05\clusterTable.csv'); 
ParentFolder = 'E:\MoltiTT\300323SE\run3\2023-03-30_16-46-05\slpsRun3';
DateRun = '300323SE_run3';
ClusterChannel = MUCall.ClusterChannel;
ClusterNum = num2str(MUCall.ClusterNum);
[MUCallSize,c] = size(MUCall);
for i = 1:7
    currentSubFolder = [strcat(DateRun,'_',num2str(ClusterChannel(i,:)),'_',ClusterNum(i))];
    slpLocation = [strcat(ParentFolder,'\',currentSubFolder,'\slp_ of_',currentSubFolder,'.mat')];
    slp = load(slpLocation);
    slp = slp.slp;
    [slp] = FGaussReconstruction(currentSubFolder,slpLocation,ParentFolder,slp);
 %  [slp] = FSTASigPredictions(clusID,MUC.Path{1},MUC.ExpType{1},MUC.Run,MUC.TTNum,MUC.ClusterNum,MUC.NeighboringCluster,MUC.Date,MUC.Region{1},MUC.Electrode{1},MUC.Concate,ParentFolder,slp);
    %save([ParentFolder 'slpList.mat'],'slpList')
    close all;
end