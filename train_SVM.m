% SVM multi
clc
clear all
Test_A = 'C:\Users\Kashi\Desktop\,l proj\ML_project';
Test_A_handle = imageDatastore(Test_A,'IncludeSubfolders',true,'LabelSource','foldernames');

figure;

%for i = 1:20
%    subplot(4,5,i);
%    imshow(im2bw(imread(Test_A_handle.Files{i}),0.4));
%end

labelCount = countEachLabel(Test_A_handle)

trainNumFiles = 35;
[trainingSet,testSet] = splitEachLabel(Test_A_handle,trainNumFiles,'randomize');


img = readimage(trainingSet, 175);

% Extract HOG features and HOG visualization
[hog_2x2, vis2x2] = extractHOGFeatures(img,'CellSize',[2 2]);
[hog_4x4, vis4x4] = extractHOGFeatures(img,'CellSize',[4 4]);
[hog_8x8, vis8x8] = extractHOGFeatures(img,'CellSize',[8 8]);

% Show the original image
figure;
subplot(2,3,1:3); imshow(img);

% Visualize the HOG features
subplot(2,3,4);
plot(vis2x2);
title({'CellSize = [2 2]'; ['Length = ' num2str(length(hog_2x2))]});

subplot(2,3,5);
plot(vis4x4);
title({'CellSize = [4 4]'; ['Length = ' num2str(length(hog_4x4))]});

subplot(2,3,6);
plot(vis8x8);
title({'CellSize = [8 8]'; ['Length = ' num2str(length(hog_8x8))]});

cellSize = [4 4];
hogFeatureSize = length(hog_4x4);

% Loop over the trainingSet and extract HOG features from each image. A
% similar procedure will be used to extract features from the testSet.

numImages = numel(trainingSet.Files);
trainingFeatures = zeros(numImages, hogFeatureSize, 'single');

for i = 1:numImages
    img = readimage(trainingSet, i);

   % img = rgb2gray(img);

    % Apply pre-processing steps
   % img = imbinarize(img);

    trainingFeatures(i, :) = extractHOGFeatures(img, 'CellSize', cellSize);
end

% Get labels for each image.
trainingLabels = trainingSet.Labels;

% fitcecoc uses SVM learners and a 'One-vs-One' encoding scheme.
classifier = fitcecoc(trainingFeatures, trainingLabels);

% Extract HOG features from the test set. The procedure is similar to what
% was shown earlier and is encapsulated as a helper function for brevity.
%[testFeatures, testLabels] = extractHOGFeatures(testSet, hogFeatureSize, cellSize);
numImages2 = numel(testSet.Files);
trainingFeatures = zeros(numImages, hogFeatureSize, 'single');

for i = 1:numImages2
    img = readimage(testSet, i);
    testFeatures(i, :) = extractHOGFeatures(img, 'CellSize', cellSize);
end

% Get labels for each image.
testLabels = testSet.Labels;

% Make class predictions using the test features.
predictedLabels = predict(classifier, testFeatures);
