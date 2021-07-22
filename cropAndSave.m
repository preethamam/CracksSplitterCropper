% path to input folder
imgFolder = '../data/Testing/Dataset III/Thin_FewStrands';

% path to output folder
resFolder = '../data/Testing/Dataset III/Thin_FewStrandsCrop';

% check if folder exists
if ~isfolder(imgFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s', imgFolder);
    uiwait(warndlg(errorMessage));
    return;
end

% create result folder if not exists
if ~exist(resFolder, 'dir')
    fprintf(1, 'Folder %s not found. Creating a new folder\n', resFolder);
    mkdir(resFolder)
end

% pattern search for all JPG or PNG files
jpgFiles = fullfile(imgFolder, '*.jpg');
pngFiles = fullfile(imgFolder, '*.png');
imgFiles = [dir(jpgFiles); dir(pngFiles)];

cropH = 480;
cropW = 640;

for k = 1:length(imgFiles)
    
    baseFileName = imgFiles(k).name;
    fullFileName = fullfile(imgFolder, baseFileName);
    
    image = imread(fullFileName);
    [h, w, c] = size(image);
    fprintf(1, 'Now reading %s - [%d %d %d]\n', fullFileName, h, w, c);
    
    if w > 640
        count = 0;
        
        for i=0:cropH:h
            count = count + 1;
            
            for j=0:cropW:w
                
                if((i + cropH) < h && (j + cropW) < w)
                    cropImage = imcrop(image ,[i j cropH cropW]);
                    [ch, cw, ~] = size(cropImage);
                    
                    % ignore empty or small crops
                    if isempty(cropImage) || (ch * cw) < 50000
                        continue
                    end
                    
                    % save cropped image to specified directory
                    imwrite(cropImage, horzcat(resFolder, '\', baseFileName(1:end-4), '-', num2str(count),'.png'));
                end
            end
        end
        
        fprintf(1, 'cropped into %d images\n', count);
    else
        imwrite(image, horzcat(resFolder, '\', baseFileName(1:end-4),'.png'));
    end
    
    %   imshow(imageArray);  % Display image.
end