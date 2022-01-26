function cracksSplitter(tileHeight, tileWidth, overlapRatio, ...
                        difference_limit, binary_image, writeImage) 
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
%
%************************************************************************%
%
% Usage: metrics  = multiclass_metrics_common(confmat)
% Inputs: confmat  - confusion matrix -- N x N matrix
% 
% Outputs: metrics - metrics.Precision = Precision;
%                    metrics.Recall = Recall;
%                    metrics.Accuracy = Accuracy;
%                    metrics.Specificity = Specificity;
%                    metrics.F1score = F1score;
%
% Authors: Preetham Manjunatha, Ph.D.
%          Mohsin Sheikh
%

% Get image sizes    
[image_rows, image_cols] = size(binary_image);

% Obtain crack strands 
strand_collection = branchPointDetection(binary_image);

% Save image counter 
image_counter = 0;

% Display figure
figure; imshow(binary_image)
hold on;
for i = 1:length(strand_collection) 
    current_strand = strand_collection{i};
    start_point = current_strand.points(1,:);
    create_bounding_box(start_point, image_rows, image_cols, writeImage, image_counter, ...
                        tileWidth, tileHeight)
    end_point = current_strand.points(end,:);
    for point = 1:length(current_strand.points)
        if( current_strand.points(point,:) == end_point)
            special_box_end_point(start_point,current_strand.points(point,:), image_rows, ...
                image_cols, writeImage, image_counter, tileWidth, tileHeight)
            break
        end
        l = abs(current_strand.points(point,2) - start_point(2));
        w = abs(current_strand.points(point,1) - start_point(1));
        if(overlapRatio ~= 0 && (((tileWidth-l)==0) || ((tileHeight-w)==0)))
            disp("point does not exist");
            break
        end
        if((((tileWidth-l)*(tileHeight-w))-tileHeight*tileWidth*overlapRatio)<=difference_limit)
            create_bounding_box(current_strand.points(point,:), image_rows, image_cols , ...
                writeImage, image_counter, tileWidth, tileHeight)
            start_point = current_strand.points(point,:);
        end
    end
end

end

%--------------------------------------------------------------------------------------------------
% Auxillary functions
%--------------------------------------------------------------------------------------------------
% End point is already exists
function special_box_end_point(start_point, point, image_rows, image_cols, writeImage, image_counter, tileWidth, tileHeight)
    if((abs(start_point(2)-point(2)) < tileWidth/2) && (abs(start_point(1)-point(1)) < tileHeight/2))
        disp("need to create new box, end point is already included")
        return
    end
    create_bounding_box(point, image_rows, image_cols, writeImage, image_counter, tileWidth, tileHeight)
end

% Bounding box maker
function create_bounding_box(point, image_rows, image_cols, writeImage, image_counter, tileWidth, tileHeight)
    top_left  = [(point(1)-tileHeight/2) , (point(2)-tileWidth/2)];
    if(top_left(1)<0)
        top_left(1) = 0;
    end
    if( top_left(2) < 0)
         top_left(2) = 0 ;
    end
    if(top_left(1)+tileHeight >= image_rows)
        top_left(1) = image_rows-tileHeight-1;
    end
    if(top_left(2)+tileWidth >= image_cols)
        top_left(2) = image_cols-1-tileWidth;
    end
    
    % Write cropped images
    if writeImage
        J = imcrop( color_image,[top_left(2) top_left(1) tileWidth tileHeight]);
        imwrite(J,sprintf('croped_image_%d.png',image_counter),'png')
        image_counter = image_counter + 1;
    end
    rectangle('Position', [top_left(2) top_left(1) tileWidth tileHeight], 'EdgeColor', 'r');        
end
