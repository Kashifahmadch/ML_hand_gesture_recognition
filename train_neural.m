Test_A = 'C:\Users\Kashi\Desktop\,l proj\ML_project';
Test_A_handle = imageDatastore(Test_A,'IncludeSubfolders',true,'LabelSource','foldernames');

figure;

%for i = 1:20
%    subplot(4,5,i);
%    imshow(im2bw(imread(Test_A_handle.Files{i}),0.4));
%end

labelCount = countEachLabel(Test_A_handle)

trainNumFiles = 35;
[trainDigitData,valDigitData] = splitEachLabel(Test_A_handle,trainNumFiles,'randomize');

layers = [
    imageInputLayer([100 100 1])

    convolution2dLayer(3,16,'Padding',1)
    batchNormalizationLayer
    reluLayer

    maxPooling2dLayer(2,'Stride',2)

    convolution2dLayer(3,32,'Padding',1)
    batchNormalizationLayer
    reluLayer

    maxPooling2dLayer(2,'Stride',2)

    convolution2dLayer(3,64,'Padding',1)
    batchNormalizationLayer
    reluLayer

    fullyConnectedLayer(6)
    softmaxLayer
    classificationLayer];


options = trainingOptions('sgdm','MaxEpochs',2,'ValidationData',valDigitData,'ValidationFrequency',30,'Verbose',false,...
    'Plots','training-progress');

net = trainNetwork(trainDigitData,layers,options);