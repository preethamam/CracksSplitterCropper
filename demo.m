%//%************************************************************************%
%//%*                         Crack Splitter						       *%
%//%*           Splits the cracks with/without overlap region              *%
%//%*           Increases the crack dataset by spliiting the cracks        *%
%//%*                                                                      *%
%//%*             Name: Preetham Manjunatha    		                       *%
%//%*             Github link: https://github.com/preethamam               %*
%//%*             Submission Date: 01/26/2022                              *%
%//%************************************************************************%
%//%*             Viterbi School of Engineering,                           *%
%//%*             Sonny Astani Dept. of Civil Engineering,                 *%
%//%*             University of Southern california,                       *%
%//%*             Los Angeles, California.                                 *%
%//%************************************************************************%
clear; close all; clc;
Start = tic;
clcwaitbarz = findall(0,'type','figure','tag','TMWWaitbar');
delete(clcwaitbarz);

%% Inputs
tileHeight = 50;  % tile height
tileWidth = 100;  % tile width
overlapRatio = 0.2; % overlap bewteen adjacent tiles
difference_limit = 5; % Pixel difference
writeImage = 0;  % write/save spilt images

%% Load images
% Read image
color_image = imread('Pseudo_crack_01.png');
grey_image = rgb2gray(color_image);
binary_image = imbinarize(grey_image);
binary_image = bwmorph(binary_image,'thin',Inf);

%% Split cracks and save
cracksSplitter(tileHeight, tileWidth, overlapRatio, difference_limit, color_image, ...
                binary_image, writeImage)   

%% End
%--------------------------------------------------------------------------
clcwaitbarz = findall(0,'type','figure','tag','TMWWaitbar');
delete(clcwaitbarz);
Runtime = toc(Start);
