I = imread('V_test.jpg');
imshow(I)
title('Original Image')
mask = zeros(size(I));
mask(25:end-25,25:end-25) = 1;
figure
imshow(mask)
title('Initial Contour Location')
bw = activecontour(I,mask,300);
figure
imshow(bw)
title('Segmented Image')
I = imread('toyobjects.png');
imshow(I)
hold on
title('Original Image');