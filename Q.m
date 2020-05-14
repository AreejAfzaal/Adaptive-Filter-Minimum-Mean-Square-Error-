clc
clear
close

%reading original image
image = double(imread('cameraman.tif'))/255;
subplot(2, 2, 1);
imshow(image);
title('Original Image');

%adding noise to the image
noisyImage = imnoise(image, 'gaussian', 0, 0.05);
subplot(2, 2, 2);
imshow(noisyImage);
title('Noisy Image');
[rows, cols, colors] = size(noisyImage);
 
%dimensions of the window
N = 3;

%applying zero padding on boundary
rows1 = rows + 2;
cols1 = cols + 2;
img = zeros(rows1, cols1);
x = 2;
y = 2;
for i = 1 : rows
    for j = 1 : cols
        img(x, y) = noisyImage(i, j);
        y = y + 1;
    end
    y = 2;
    x = x + 1;
end 

%applying window to caclulate mean and local variance
size_arr = rows*cols;
mean = zeros(1,size_arr);
meanSquared = zeros(1,size_arr);
localVar = zeros(1, size_arr);
index = 0;
for i = 1 : rows
    for j = 1 : cols
        sum = 0;
        sumSq = 0;
        k = i;
        l = j;
        index = index + 1;
        for x = 1 : N
            for y = 1 : N
                sum = sum + img(k, l);
                sumSq = sumSq + (img(k, l)^2);
                l = l + 1;
            end
            l = j;
            k = k + 1;
        end
        mean(index) = sum/(N*N);
        meanSquared(index) = sumSq/(N*N);
        %local variance = mean(W^2) - mean(W)^2
        localVar(index) = meanSquared(index) - (mean(index)^2);
    end
end

%calculating noise variance
noiseVar = var(img(:));
disp(noiseVar);

%converting localVar and mean into 2D arrays
localVartemp = zeros(rows, cols);
meantemp = zeros(rows, cols);
ind = 0;
for i = 1 : rows
    for j = 1 : cols
        ind = ind + 1;
        localVartemp(i, j) = localVar(ind);
        meantemp(i, j) = mean(ind);
    end
end

%comparing the noiseVar and localVar
for i = 1 :  rows
    for j = 1: cols
        if noiseVar > localVartemp(i, j)
            localVartemp(i, j) = noiseVar;
        end
    end
end

%applying the final formula
NewImg = zeros(rows, cols);
for i = 1 : rows
    for j = 1 : cols
        %sigma_N/sigma_L
        NewImg(i, j) = noiseVar/localVartemp(i, j);
        %d(r, c) - m_L
        NewImg(i, j) = NewImg(i, j) * (noisyImage(i, j) - meantemp(i, j));
    end
end
%d(r, c)- calculated bracket
NewImg = noisyImage-NewImg;

%displaying the final image
subplot(2, 2, 3);
imshow(NewImg);
title('Adaptive Filter Applied');