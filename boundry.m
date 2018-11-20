function boundry(img_name,i)

close all;  % Close all figures (except those of imtool.)
image_bin_name={'testb_1.jpg','testb_2.jpg','testb_3.jpg','testb_4.jpg','testb_5.jpg'};
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 20;


folder = 'C:\Users\Kashi\Desktop\,l proj\ML_project';

baseFileName = img_name{i};

fullFileName = fullfile(folder, baseFileName);
% Check if file exists.
if ~exist(fullFileName, 'file')
	% File doesn't exist -- didn't find it there.  Check the search path for it.
	fullFileNameOnSearchPath = baseFileName; % No path this time.
	if ~exist(fullFileNameOnSearchPath, 'file')
		% Still didn't find it.  Alert user.
		errorMessage = sprintf('Error: %s does not exist in the search path folders.', fullFileName);
		uiwait(warndlg(errorMessage));
		return;
	end
end
grayImage = imread(fullFileName);
% Get the dimensions of the image.  
% numberOfColorBands should be = 1.
[rows, columns, numberOfColorBands] = size(grayImage);
if numberOfColorBands > 1
	% It's not really gray scale like we expected - it's color.
	% Convert it to gray scale by taking only the green channel.
	grayImage = grayImage(:, :, 2); % Take green channel.
end

gradientImage = imgradient(grayImage);
% Put a white line along the bottom, right, 
% and left side to "close off" the hand and arm.
gradientImage(:,1) = 255; % Make column 1 white.
gradientImage(end,:) = 255; % Make last row white.
gradientImage(:,end) = 255; % Make last column white.
%gradientImage
temp2 = imresize(gradientImage,[100 100]);
   
%[pixelCount, grayLevels] = hist(gradientImage(:), 100);

binaryImage = gradientImage > 60;
% Fill Holes
binaryImage = imfill(binaryImage, 'holes');
% Remove tiny regions.
binaryImage = bwareaopen(binaryImage, 1000);

biggestBlob = ExtractNLargestBlobs(binaryImage, 1);

temp1 = imresize(biggestBlob,[100 100]);
imwrite(temp1,image_bin_name{i});
% Function to return the specified number of largest or smallest blobs in a binary image.

function binaryImage = ExtractNLargestBlobs(binaryImage, numberToExtract)
try
	% Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
	[labeledImage, numberOfBlobs] = bwlabel(binaryImage);
	blobMeasurements = regionprops(labeledImage, 'area');
	% Get all the areas
	allAreas = [blobMeasurements.Area];
	if numberToExtract > 0
		% For positive numbers, sort in order of largest to smallest.
		% Sort them.
		[sortedAreas, sortIndexes] = sort(allAreas, 'descend');
	elseif numberToExtract < 0
		% For negative numbers, sort in order of smallest to largest.
		% Sort them.
		[sortedAreas, sortIndexes] = sort(allAreas, 'ascend');
		% Need to negate numberToExtract so we can use it in sortIndexes later.
		numberToExtract = -numberToExtract;
	else
		% numberToExtract = 0.  Shouldn't happen.  Return no blobs.
		binaryImage = false(size(binaryImage));
		return;
	end
	% Extract the "numberToExtract" largest blob(a)s using ismember().
	biggestBlob = ismember(labeledImage, sortIndexes(1:numberToExtract));
	% Convert from integer labeled image into binary (logical) image.
	binaryImage = biggestBlob > 0;
catch ME
	errorMessage = sprintf('Error in function ExtractNLargestBlobs().\n\nError Message:\n%s', ME.message);
	fprintf(1, '%s\n', errorMessage);
	uiwait(warndlg(errorMessage));
end