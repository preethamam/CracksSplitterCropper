clc;
clear;
close all;

% path to input folder
imgFolder = '../data/Testing/Dataset III/Thin_FewStrandsCrop';

% check if folder exists
if ~isfolder(imgFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s', imgFolder);
    uiwait(warndlg(errorMessage));
    return;
end

% pattern search for all JPG or PNG files
jpgFiles = fullfile(imgFolder, '*.jpg');
pngFiles = fullfile(imgFolder, '*.png');
imgFiles = [dir(jpgFiles); dir(pngFiles)];

for k = 1:length(imgFiles)
    
    baseFileName = imgFiles(k).name;
    fullFileName = fullfile(imgFolder, baseFileName);
    
    % read RGB image
    imageRGB = imread(fullFileName);
    [h, w, c] = size(imageRGB);
    fprintf(1, 'Now reading %s - [%d %d %d]\n',fullFileName, h, w, c);
    
    % convert RGB to Grayscale
    imageGray = rgb2gray(imageRGB);
    
    imageV = imadjust(imageGray);
    
    % use V component for analysis of default parameters
    [gradThresh, numIter] = imdiffuseest(imageV);
    
    % apply anisotropic diffusion filter
    %     imageFiltered = imdiffusefilt(imageV,'NumberOfIterations',150);
    
    imageFiltered = imdiffusefilt(imageV,'GradientThreshold', ...
        gradThresh,'NumberOfIterations',numIter);%'ConductionMethod','quadratic');
    
    % binarize image using adaptive threshold
    T = adaptthresh(imageV,'ForegroundPolarity','dark','Statistic','gaussian');
    imageBW = imbinarize(imageV, T);
    
    T = adaptthresh(imageFiltered,'ForegroundPolarity','dark','Statistic','gaussian');
    filteredBW = imbinarize(imageFiltered, T);
    
    figure(k);
    subplot(2,2,1),imshow(imageV);
    title('Contrast Enhanced Input Image');
    
    subplot(2,2,2),imshow(imageFiltered);
    title('Anisotropic Filter Output'); 
    
    subplot(2,2,3),imshow(imageBW);
    title('Binarized Input Image');
    
    subplot(2,2,4),imshow(filteredBW);
    title('Binarized Filtered Image');
    drawnow;
end