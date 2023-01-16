function [Skeleton] = SkeletonJW(Im)
% Skeletonization function (code draws heavily on that from WorMachine) - written by Jan Watteyne

        % -------------------------------------------
        % Find Skeleton using morphological operation
        % -------------------------------------------
        Skel = bwmorph(Im, 'thin', Inf);
        B = bwmorph(Skel, 'branchpoints');
        BP = sum(sum(B));
        iter = 1;
        %Smooth maximum 10 times or until a skeleton line is obtained with no branchpoints.
        while sum(sum(B))>0 && iter<=10
            Im = medfilt2(Im,[15 15]);
            Skel = bwmorph(Im,'thin', Inf);
            B = bwmorph(Skel, 'branchpoints');
            iter = iter + 1;
        end

        % ----------------------------------------
        % Retrieve coordinates Skeleton and Smooth
        % ----------------------------------------
        indexSkel = IndexSkel(Skel); %retrieve coordinates for each skeleton centroid (use external function WorMachine)
        
        xSkel = indexSkel(:, 1)';
        ySkel = indexSkel(:, 2)';
        
        % Smooth Skeleton with external RecSlidingWindow function
        numberCentroidsSkeleton = length(xSkel);
        NumberPixelsSmooth = round(numberCentroidsSkeleton/30);
        xSkelSmooth = RecSlidingWindow(xSkel, NumberPixelsSmooth);
        ySkelSmooth = RecSlidingWindow(ySkel, NumberPixelsSmooth);
        
        %plot(xSkel, ySkel), hold on, plot(xSkelSmooth, ySkelSmooth)
        
        indexSkelSmooth = [xSkelSmooth', ySkelSmooth'];
        
        
        % ----------------------------------------
        % Retrieve coordinates Contour and Smooth
        % ----------------------------------------
        Contour = edge(Im, 'Sobel'); %edge detection for worm contour, also possible to use 'Roberts' or 'Prewitt'
        [x, y] = find(Contour);
        Contour(x(1), y(1)) = 0; % 'delete the first point in the contour, so you can retrieve coordinates for all the rest
        
        indexContour = IndexSkel(Contour);
        xContour = indexContour(:, 1)';
        yContour = indexContour(:, 2)';
        
        % Smooth Contour with external RecSlidingWindow function
        xContourSmooth = RecSlidingWindow(xContour, NumberPixelsSmooth);
        yContourSmooth = RecSlidingWindow(yContour, NumberPixelsSmooth);
        
        %plot(xContour, yContour), hold on, plot(xContourSmooth, yContourSmooth)
        indexContourSmooth = [xContourSmooth', yContourSmooth'];
        
        % ----------------------------------------
        % Total length Smoothed Skeleton
        % ----------------------------------------
        lengthFromStart = cumsum([sqrt((xSkelSmooth(2:end)-xSkelSmooth(1:end-1)).^2 + (ySkelSmooth(2:end)-ySkelSmooth(1:end-1)).^2)]);
        totalSkelLength = lengthFromStart(end);
        
        % ----------------------------------------------------------
        % Width at x number of equally spaced points of the skeleton
        % ----------------------------------------------------------
        % get x number of equally spaced points on the skeleton
        NumberOfSegments = 30;
        SegmentLength = round(linspace(0, totalSkelLength, NumberOfSegments));
        
        % remove beginning and end point (we won't use those, too much
        % variation)
        SegmentLength = SegmentLength(2:end-1);
        
        lengthOneSegment = round(nanmean(diff(SegmentLength)));
        
        % get the indices of the points on the Skeleton that are closests
        % to these distances https://nl.mathworks.com/matlabcentral/answers/152301-find-closest-value-in-array
        V = SegmentLength';
        N = (1:length(xSkelSmooth))';
        A = repmat(N,[1 length(V)]);
        [~,indexSegment] = min(abs(A-V'));
        indexSegment(end) = [];
        
        % get the indices of Segment Middles
        xSegments = xSkelSmooth(indexSegment);
        ySegments = ySkelSmooth(indexSegment);
                 
                    %plot(xSkelSmooth, ySkelSmooth), hold on, scatter(xSegments, ySegments)
               
        % get width at each of these points 
        [xyOnContour,distance,~] = distance2curve(indexContourSmooth, [xSegments' ySegments']); %use external function
        
%         plot(indexContourSmooth(:,1), indexContourSmooth(:,2))
%         hold on
%         plot(xSkelSmooth,ySkelSmooth)
%         scatter(xSegments, ySegments)
%         plot(xyOnContour(:,1),xyOnContour(:,2),'g*')
%         
%         waitforbuttonpress
%         close all

        % ---------------------------------------------------------------
        % Mean width in middle of the animal
        % ---------------------------------------------------------------   
        middleIndex = round(length(distance)/2);
        
        numberOfSegmentWidthsToTakeInMiddle = 8;
        MeanMiddleDistance = nanmean(distance(middleIndex-(numberOfSegmentWidthsToTakeInMiddle/2):middleIndex+(numberOfSegmentWidthsToTakeInMiddle/2)));  
        
        % ---------------------------------------------------------------
        % Volume of each segment: add everything up for total worm volume
        % ---------------------------------------------------------------
        VolumeEach = nan(1, length(distance));
        for Segment = 2:(length(distance)-1)
            Ra = distance(Segment);
            Rb = distance(Segment+1);
            
            %volume of a 'frustum'. Cfr. https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3579787/
            VolumeEach(Segment) = (pi * lengthOneSegment *(Ra^2 + (Ra * Rb) + Rb^2))/3;
        end

        totalVolume = nansum(VolumeEach);
        
        % Save important variables in Skeleton Structure
        Skeleton.indexSkelSmooth = indexSkelSmooth; 
        Skeleton.indexContourSmooth = indexContourSmooth; 
        Skeleton.totalSkelLength = totalSkelLength;
        Skeleton.MeanMiddleDistance = MeanMiddleDistance;
        Skeleton.indexSegment = indexSegment;
        Skeleton.xyOnContour = xyOnContour;
        Skeleton.Width = distance*2;
        Skeleton.totalVolume = totalVolume;
end

