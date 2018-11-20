
function [label score] = test_neural(img_name,j)
load('Neural_small.mat');
img = imread(img_name{j});
[label,score] = classify(net,img);
end