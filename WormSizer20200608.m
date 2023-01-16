%% Script WormSize 
% Code written by Jan Watteyne (jwatteyne@gmail.com or
% jan.watteyne@bio.kuleuven.be)
% Beware, Clears the workspace!

% Make sure the dependencies folder is taken up in the Path!
clear;
clc; % Clear command window.
clear figure; % Deletes current figures
fprintf('Running shape analysis script\n'); % Message sent to command window.
workspace; % Make sure the workspace panel with all the variables is showing.
%% load in image
% Select image
[FileName, PathName] = uigetfile('*.tif','Select example frame within folder','MultiSelect','on');
cd(PathName); % set PathName current directory

% Load in file pattern for easy access to each frame
filePattern = fullfile(PathName, '*.tif'); % Change to whatever pattern you need.
framelist = dir(filePattern);

%% Manually settings
prompt = {'Name expertimental condition','Enter the calibration factor (pixel/µm)'};
Ans = inputdlg(prompt,'Set Parameters',[1 50],{'N2', '0.7871'}); %Push kadertje

SaveName = Ans{1};
CalibrationFactor = str2double(Ans{2}); 

%% Use external GUI to fine-tune image processing parameters
h = ImSegm;
uiwait(h);
%uiwait %wait until gui is closed to proceed script
%% Load in each image and manual fine-tuning segmentation
DataStructure = [];

for Exp = 1:length(framelist) %cycle through each individual experiment
  
    % load in figure
    Im = imread(framelist(Exp).name);
    %Im = double(Im);
    
    % image processing
    SegmentedIm = WormSegmentationSobelDetection(Im, Fudgefactor, SEdil1, SEdil2, SEsmooth, SizeThr);
    
    % manually delete regions and separate worms if possible
    figure('units','normalized','outerposition',[0 0 1 1])
    imagesc(labeloverlay(Im, SegmentedIm)), title('Using the cursor, trace artefacts (fi eggs against worm body / worms touching / dust specs)')
    
    axis equal
    axis off
    
    finished = 'NO';
    i = 1;
    xy = {};
    AllRegionsToMask = zeros(size(Im));
    while strcmpi(finished,'NO')
        hFH = imfreehand();
        
        finished = questdlg('Finished?', ...
            'confirmation', ...
            'YES', 'NO', 'UNDO', 'NO');
        
        if strcmpi(finished, 'UNDO')
            delete(hFH(i))
            finished = 'NO';
        else
            MaskedRegion = hFH.createMask();
            AllRegionsToMask = AllRegionsToMask + MaskedRegion;
            i = i + 1;
        end
    end
    close all
    
    AllRegionsToMask(AllRegionsToMask ~= 0) = 1; % if you ever draw over the same pixel mutliple times
    AllRegionsToMask = logical(AllRegionsToMask);
    ManualCheckedIm = SegmentedIm;
    ManualCheckedIm(AllRegionsToMask) = 0;
    
    figure('units','normalized','outerposition',[0 0 1 1])
    %imagesc(imoverlay(mat2gray(Im), bwperim(ManualCheckedBW), [.3 1 .3])), title('all selected worm objects, click to continue')
    imagesc(labeloverlay(Im, ManualCheckedIm)), title('all selected worm objects, click to continue')
    axis off
    axis equal
    waitforbuttonpress
    close all
    
    % Save everything in DataStructure
    FileName = framelist(Exp).name;
    FileName = FileName(1:end-4); %trim .tif extension
    
    DataStructure(Exp).Name = FileName;
    DataStructure(Exp).OriginalIm = Im;
    DataStructure(Exp).SegmentendIm = SegmentedIm;
    DataStructure(Exp).ManualCheckedIm = ManualCheckedIm;
end

%% Skeletonization
for Exp = 1:length(DataStructure)
    
    Im = DataStructure(Exp).ManualCheckedIm;
    % save every worm blob with regionprops function
    DataStructure(Exp).props = regionprops(Im, {'Area', 'Centroid', 'BoundingBox','Image','Eccentricity'});
    
    for Worm = 1:length(DataStructure(Exp).props)
        WormIm = DataStructure(Exp).props(Worm).Image;
        try
            DataStructure(Exp).props(Worm).Skeleton = SkeletonJW(WormIm);
        catch
        end
    end
end

% Delete empty skeletonprops: something went wrong with skeletonization
for Exp = 1:length(DataStructure)
    propsToDelete = [];
    for Worm = 1:length(DataStructure(Exp).props)
        if isempty(DataStructure(Exp).props(Worm).Skeleton)
            propsToDelete = [propsToDelete, Worm];
        end
    end
    DataStructure(Exp).props(propsToDelete) = [];
end
%% Use calibration factor to modify main variables  TODO: aanpassen
for Exp = 1:length(DataStructure)
    for Worm = 1:length(DataStructure(Exp).props)
        DataStructure(Exp).props(Worm).AreaInum = DataStructure(Exp).props(Worm).Area*nthroot(1/CalibrationFactor, 2);
        DataStructure(Exp).props(Worm).Skeleton.totalSkelLengthInum = DataStructure(Exp).props(Worm).Skeleton.totalSkelLength/CalibrationFactor;   
        DataStructure(Exp).props(Worm).Skeleton.MeanMiddleDistanceInum = DataStructure(Exp).props(Worm).Skeleton.MeanMiddleDistance/CalibrationFactor;   
        DataStructure(Exp).props(Worm).Skeleton.totalVolumeInum = DataStructure(Exp).props(Worm).Skeleton.totalVolume*nthroot(1/CalibrationFactor, 3);
    end
end

%% Save figure of all worm skeletons for review
for Exp = 1:length(DataStructure)
    
[nrow, ncol] = getClosestFactors(length(DataStructure(Exp).props));
fig = figure('units','normalized','outerposition',[0 0 1 1]);

for Worm = 1:length(DataStructure(Exp).props)
    
    subplot(nrow, ncol, Worm)
    
    indexSkelSmooth = DataStructure(Exp).props(Worm).Skeleton.indexSkelSmooth;
    indexContourSmooth = DataStructure(Exp).props(Worm).Skeleton.indexContourSmooth;
    indexSegment = DataStructure(Exp).props(Worm).Skeleton.indexSegment;
    xyOnContour = DataStructure(Exp).props(Worm).Skeleton.xyOnContour;        
    totalVolume = DataStructure(Exp).props(Worm).Skeleton.totalVolumeInum;   
    totalSkelLength = DataStructure(Exp).props(Worm).Skeleton.totalSkelLengthInum;
        
    plot(indexContourSmooth(:,1), indexContourSmooth(:,2))
    hold on
    plot(indexSkelSmooth(:,1),indexSkelSmooth(:,2))
    scatter(indexSkelSmooth(indexSegment,1), indexSkelSmooth(indexSegment,2))   
    line([xyOnContour(:,1),indexSkelSmooth(indexSegment,1)]',[xyOnContour(:,2),indexSkelSmooth(indexSegment,2)]','color','b')
    
    title(sprintf('Nr %d, Length %0.0f, Volume %0.0f', Worm, round(totalSkelLength),round(totalVolume)))
    axis equal
    axis off
end

%save figure as jpg - to manually double check afterwards
set(gcf,'color','w');
FileName = DataStructure(Exp).Name;

SaveFileName = [FileName ' - Skeletons','.jpg'];   % use path if you want to save to same directory
SaveFileName = fullfile(fileparts(filePattern), SaveFileName);
saveas(fig, SaveFileName)

close all
end
%% Save all data in excel file
header = {'Experiment', 'Worm Nr', 'Worm area (Pixels)', 'Worm area (µm)', 'SkeletonLength (Pixels)', 'SkeletonLength (µm)', 'MiddleWidth (Pixels)', 'MiddleWidth (µm)', 'Worm volume (Pixels^3)', 'Worm volume (µm^3)'};

AllData = [];
ExpName = {};
for Exp = 1:length(DataStructure)
    Name = DataStructure(Exp).Name;
    
    DataExp = nan(length(DataStructure(Exp).props), 9);
    ExpName = [ExpName; repelem({Name}, length(DataStructure(Exp).props))'];
    for Worm = 1:length(DataStructure(Exp).props)
        area = DataStructure(Exp).props(Worm).Area;
        areaInmm = DataStructure(Exp).props(Worm).AreaInum;
        totalSkelLength = DataStructure(Exp).props(Worm).Skeleton.totalSkelLength;
        totalSkelLengthInmm = DataStructure(Exp).props(Worm).Skeleton.totalSkelLengthInum;
        MiddleWidth = DataStructure(Exp).props(Worm).Skeleton.MeanMiddleDistance;
        MiddleWidthInmm = DataStructure(Exp).props(Worm).Skeleton.MeanMiddleDistanceInum;
        totalVolume = DataStructure(Exp).props(Worm).Skeleton.totalVolume;
        totalVolumeInmm = DataStructure(Exp).props(Worm).Skeleton.totalVolumeInum;
        
        DataExp(Worm, 1) = Worm;
        DataExp(Worm, 2) = area;
        DataExp(Worm, 3) = areaInmm;
        DataExp(Worm, 4) = totalSkelLength;
        DataExp(Worm, 5) = totalSkelLengthInmm;
        DataExp(Worm, 6) = MiddleWidth;
        DataExp(Worm, 7) = MiddleWidthInmm;
        DataExp(Worm, 8) = totalVolume;
        DataExp(Worm, 9) = totalVolumeInmm;
    end
    AllData = [AllData; DataExp];
end
DataToExport = [ExpName, num2cell(AllData)];
DataToExport = [header; DataToExport];

SaveFileName = [SaveName ' - Data'];   % use path if you want to save to same directory
SaveFileName = fullfile(fileparts(filePattern), SaveFileName);
xlswrite(SaveFileName,DataToExport)

fprintf('Analysis done\n'); % Message sent to command window.