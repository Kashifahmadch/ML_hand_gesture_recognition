% load net
load('Neural_small.net');
img=imread('V_test.jpg');
[label,score] = classify(net,img);
label
