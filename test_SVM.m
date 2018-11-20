%testing a single thingy

function [hello] = test_SVM(img_name,j)
load('SVM_classifier.mat')
img = imread(img_name{j});
 %img=imread('hello_test.jpg');
 testFeatures = extractHOGFeatures(img, 'CellSize', cellSize);
hello = predict(classifier, testFeatures);
end