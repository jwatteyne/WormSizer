function ImSegm = WormSegmentationSobelDetection(Im,Fudgefactor, SEdil1, SEdil2, SEsmooth, SizeThreshold)

% edge detection with Sobel method
% based on: https://nl.mathworks.com/help/images/detecting-a-cell-using-image-segmentation.html
[~,threshold] = edge(Im,'sobel');
BWs = edge(Im,'sobel',threshold * Fudgefactor);
%figure, imagesc(BWs)

% Dilate 
se1 = strel('line',SEdil1,SEdil2);
se2 = strel('line',SEdil1,0);

BWsdil = imdilate(BWs,[se1 se2]);
%imshow(BWsdil), title('Dilated Gradient Mask')

% Fill holes
BWdfill = imfill(BWsdil,'holes');
% imshow(BWdfill), title('Binary Image with Filled Holes')

% Remove objects against border: you won't be able to use these
%BWnobord = imclearborder(BWdfill,4);
%imshow(BWnobord), title('Cleared Border Image')

% Smooth the object
seD = strel('diamond', SEsmooth);
BWfinal = imerode(BWdfill,seD);
BWfinal = imerode(BWfinal,seD);
%imshow(BWfinal), title('Segmented Image');

% remove small objects (not worms):
ImSegm = bwareaopen(BWfinal, SizeThreshold);
end

