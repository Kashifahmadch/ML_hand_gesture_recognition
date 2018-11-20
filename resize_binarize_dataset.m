clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 20;


Test_A = 'C:\Users\Kashi\Desktop\,l proj\ML_project';
Test_A_handle = imageDatastore(Test_A,'IncludeSubfolders',true,'LabelSource','foldernames');

figure;

for i = 1:2
    subplot(4,5,i);
    imshow(im2bw(imread(Test_A_handle.Files{i}),0.4));
end

labelCount = countEachLabel(Test_A_handle)

for i=1:3755
    img = readimage(Test_A_handle,i);
    
    grayImage = img;
% Get the dimensions of the image.  
% numberOfColorBands should be = 1.
[rows, columns, numberOfColorBands] = size(grayImage);
if numberOfColorBands > 1
	% It's not really gray scale like we expected - it's color.
	% Convert it to gray scale by taking only the green channel.
	grayImage = grayImage(:, :, 2); % Take green channel.
end
% Display the original gray scale image.
subplot(2, 3, 1);
imshow(grayImage, []);
title('Original Grayscale Image', 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off') 
% Let's compute and display the histogram.
[pixelCount, grayLevels] = imhist(grayImage);
subplot(2, 3, 2); 
bar(grayLevels, pixelCount);
grid on;
title('Histogram of original image', 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.
% Get the gradient image to find the edges of the hand.
gradientImage = imgradient(grayImage);
% Put a white line along the bottom, right, 
% and left side to "close off" the hand and arm.
gradientImage(:,1) = 255; % Make column 1 white.
gradientImage(end,:) = 255; % Make last row white.
gradientImage(:,end) = 255; % Make last column white.
 %temp2 = imresize(gradientImage,[100 100]);
   % [temp temp2] = generate_skinmap(Test_A_handle.Files{i});
  %  imwrite(temp2,Test_A_handle.Files{i})
% Display the image.
subplot(2, 3, 3);
imshow(gradientImage, []);
axis on;
title('gradient Image', 'FontSize', fontSize);
% Let's compute and display the histogram.
[pixelCount, grayLevels] = hist(gradientImage(:), 100);
subplot(2, 3, 4); 
bar(grayLevels, pixelCount);
grid on;
title('Histogram of gradient image', 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.
binaryImage = gradientImage > 60;
% Fill Holes
binaryImage = imfill(binaryImage, 'holes');
% Remove tiny regions.
binaryImage = bwareaopen(binaryImage, 1000);
% Display the image.
subplot(2, 3, 5);
imshow(binaryImage, []);
title('Binary Image', 'FontSize', fontSize);
%---------------------------------------------------------------------------
% Extract the largest area using our custom function ExtractNLargestBlobs().
% This is the meat of the demo!
biggestBlob = ExtractNLargestBlobs(binaryImage, 1);

    temp1 = imresize(biggestBlob,[100 100]);
   % [temp temp2] = generate_skinmap(Test_A_handle.Files{i});
    imwrite(temp1,Test_A_handle.Files{i})
end
% Display the image.
%subplot(2, 3, 6);
%imshow(biggestBlob, []);
%temp1 = imresize(biggestBlob,[100 100]);
%imwrite(temp1,'hello_test.jpg')
%title('Final Image', 'FontSize', fontSize);
%---------------------------------------------------------------------------
%==============================================================================================
% Function to return the specified number of largest or smallest blobs in a binary image.
% If numberToExtract > 0 it returns the numberToExtract largest blobs.
% If numberToExtract < 0 it returns the numberToExtract smallest blobs.
% Example: return a binary image with only the largest blob:
%   binaryImage = ExtractNLargestBlobs(binaryImage, 1)
% Example: return a binary image with the 3 smallest blobs:
%   binaryImage = ExtractNLargestBlobs(binaryImage, -3)
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
end