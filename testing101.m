clc
clear all

cam = webcam;

%preview(cam);

image_name= {'test1.jpg','test2.jpg','test3.jpg','test4.jpg','test5.jpg'};

for i= 1: 5
closePreview(cam)
pause(1)
preview(cam);

pause(2)

img = snapshot(cam);
%imshow(img)
temp1 = imresize(img,[100 100]);
imwrite(temp1,image_name{i})
boundry(image_name,i);
end

closePreview(cam);
% load SVM classifier
load('SVM_classifier.mat')
% test the images taken
image_bin_name={'testb_1.jpg','testb_2.jpg','testb_3.jpg','testb_4.jpg','testb_5.jpg'};
for j=1:5
SVM_pred_results(j) = test_SVM(image_bin_name,j);
end
SVM_pred_results

%test the images using the trained neural network

for j=1:5
neural_pred(j)= test_neural(image_bin_name,j);
end
