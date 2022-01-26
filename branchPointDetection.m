function strand_collection = branchPointDetection(image)
%//%************************************************************************%
%//%*                     Branch Point Detection						   *%
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
% Usage: strand_collection = branchPointDetection(binary_image_thinned)
% Inputs: image                 - Thinned binary image
% 
% Outputs: strand_collection    - Crack strands (points and distance)
%
% Authors: Preetham Manjunatha, Ph.D.
%          Mohsin Sheikh
%

%--------------------------------------------------------------------------------------------------
% Image information
%--------------------------------------------------------------------------------------------------
BW_thin = image;
rows = size(image,1);
columns = size(image,2);
BW_bp   = bwmorph(image,'branchpoints');
[rowBP, colBP] = find(BW_bp);
branch_points    = [rowBP, colBP]; %#ok<*NASGU>

BW_ep    = bwmorph(image, 'endpoints');
[rowEP, colEP] = find(BW_ep);
end_points       = [rowEP, colEP];

%--------------------------------------------------------------------------------------------------
% Initialization
%--------------------------------------------------------------------------------------------------
current_strand_flag = false;
strand_collection = {};
points_collection = containers.Map;
non_visited_points = [branch_points; end_points];
temp = branch_points;

for i=1:size(temp,1)
    temp_reference = Points;
    temp_reference.row = temp(i,1);
    temp_reference.col = temp(i,2);
    temp_reference.special_point = 1;
    points_collection(mat2str(temp(i,:))) = temp_reference;
end
temp = end_points;
for i=1:size(temp,1)
    temp_reference = Points;
    temp_reference.row = temp(i,1);
    temp_reference.col = temp(i,2);
    temp_reference.special_point = 2;
    points_collection(mat2str(temp(i,:))) = temp_reference;
end

%--------------------------------------------------------------------------------------------------
% Crack pixel traversal
%--------------------------------------------------------------------------------------------------
while(~isempty(non_visited_points))
    current_point = non_visited_points(end,:);
    non_visited_points = non_visited_points(1:end-1,:);
    if(~isKey(points_collection, mat2str(current_point)))
        temp = Points;
        temp.row = current_point(1);
        temp.col = current_point(2);
        points_collection(mat2str(current_point)) = temp_reference;
    end
    current_point_reference = points_collection(mat2str(current_point));
    if(~current_point_reference.visited)
        current_point_reference.visited = 1;
        [neighbour_points, count] = detect_neighbour_points(BW_thin, current_point);
        non_visited_neighbour_points = [];
        for i=1:size(neighbour_points, 1)
            if(~isKey(points_collection, mat2str(neighbour_points(i,:))))
                temp = Points;
                temp.row = neighbour_points(i,1);
                temp.col = neighbour_points(i,2);
                points_collection(mat2str(neighbour_points(i,:))) = temp;
            end
            if(~points_collection(mat2str(neighbour_points(i,:))).visited)
                non_visited_neighbour_points(end+1,:) = neighbour_points(i,:);
            end
        end
        if(count == 1)
            if(isempty(non_visited_neighbour_points) && current_strand_flag)
                current_strand.points(end+1,:) = current_point;
                current_strand_flag = 0;
            elseif(isempty(non_visited_neighbour_points) &&  ~current_strand_flag)
                current_strand = Strand;
                current_strand.points(end+1,:) = current_point;
                strand_collection{end+1} = current_strand;
                current_strand_flag = 1;
                for i=1:size(neighbour_points,1)
                    if points_collection(mat2str(neighbour_points(i,:))).special_point == 1
                        current_strand.points(end+1,:) = current_point;
                        current_strand_flag = 0;
                        break
                    end
                end
            else
                current_strand = Strand;
                current_strand.points(end+1,:) = current_point;
                current_strand_flag = 1;
                strand_collection{end+1} = current_strand;
                non_visited_points = [non_visited_points; non_visited_neighbour_points];
            end
        end
        if(count == 2)
            if (~isempty(non_visited_neighbour_points) && ~current_strand_flag)
                current_strand = Strand;
                current_strand_flag = 1;
                current_strand.points(end+1,:) = current_point_reference.parent;
                current_strand.points(end+1,:) = current_point;
                strand_collection{end+1} = current_strand;
                for i = 1:size(non_visited_neighbour_points,1)
                    temp_reference = points_collection(mat2str(non_visited_neighbour_points(i,:)));
                    if (temp_reference.starting_point && ~isempty(temp_reference.parent))
                        if isequal(temp_reference.parent, current_point_reference.parent)
                            current_strand_flag = 0;
                            non_visited_points = [non_visited_points; non_visited_neighbour_points];
                        else
                        temp = non_visited_neighbour_points(i,:);
                        non_visited_neighbour_points(i,:) = [];
                        non_visited_points = [non_visited_points; non_visited_neighbour_points];
                        non_visited_points(end+1, :) = temp;
                        end
                    else
                        temp = non_visited_neighbour_points(i,:);
                        non_visited_neighbour_points(i,:) = [];
                        non_visited_points = [non_visited_points; non_visited_neighbour_points];
                        non_visited_points(end+1, :) = temp;
                    end
                end
            elseif(~isempty(non_visited_neighbour_points) && current_strand_flag)
                current_strand.points(end+1,:) = current_point;
                non_visited_points = [non_visited_points; non_visited_neighbour_points];
                if size(non_visited_neighbour_points,1) == 2
                    for i = 1:size(neighbour_points,1)
                        Cnp = intersect(branch_points,neighbour_points(i,:),'stable','rows');
                        if(~isempty(Cnp))
                            current_point_reference.parent(end+1,:) = neighbour_points(i,:);
                            current_strand.points(end+1,:) = neighbour_points(i,:);
                            current_strand_flag = 0;
                            break
                        end
                    end
                end
            elseif(isempty(non_visited_neighbour_points) && current_strand_flag)
                for i = 1:size(neighbour_points,1)
                    Cnp = intersect(branch_points,neighbour_points(i,:),'stable','rows');
                    if ~isempty(Cnp)
                        current_point_reference.parent(end+1,:) = Cnp;
                        current_strand.points(end+1,:) = Cnp;
                        current_strand_flag = 0;
                        break
                    end
                end
            end
        end
        if count > 2
            if (current_point_reference.special_point && current_strand_flag)
                current_strand.points(end+1,:) = current_point;
                for i = 1:size(neighbour_points,1)
                    temp_reference = points_collection(mat2str(neighbour_points(i,:)));
                    temp_reference.starting_point = 1;
                    temp_reference.parent(end+1,:) = current_point;
                end
                current_strand_flag = 0;
                non_visited_points = [non_visited_points; non_visited_neighbour_points];
            elseif(current_point_reference.special_point && ~current_strand_flag)
                current_strand = Strand;
                current_strand.points(end+1,:) = current_point;
                strand_collection{end+1} = current_strand;
                current_strand_flag = 1;
                for i = 1:size(neighbour_points,1)
                    temp_reference = points_collection(mat2str(neighbour_points(i,:)));
                    temp_reference.starting_point = 1;
                    temp_reference.parent(end+1,:) = current_point;
                end
                non_visited_points = [non_visited_points; non_visited_neighbour_points];
            elseif(~current_point_reference.special_point && ~current_strand_flag)
                current_strand = Strand;
                current_strand.points(end+1,:) = current_point_reference.parent(end,:);
                current_strand_flag = 1;
                strand_collection{end+1} = current_strand;
                current_strand.points(end+1,:) = current_point;
                temp_branch_neighbours = [];
                temp_non_branch_neighbours = [];
                temp_branch_points = [];
                for i = 1:size(non_visited_neighbour_points,1)
                    Cnp = intersect(branch_points,non_visited_neighbour_points(i,:),'stable','rows');
                    if points_collection(mat2str(non_visited_neighbour_points(i,:))).starting_point
                        temp_branch_neighbours(end+1,:) = non_visited_neighbour_points(i,:);
                    elseif ~isempty(Cnp)
                        temp_branch_points(end+1,:) = non_visited_neighbour_points(i,:);
                    else
                        temp_non_branch_neighbours(end+1,:) = non_visited_neighbour_points(i,:);
                    end
                end
                non_visited_points = [non_visited_points; temp_branch_neighbours; temp_non_branch_neighbours; temp_branch_points];
                if isempty(non_visited_neighbour_points)
                    for i=1:size(neighbour_points, 1)
                        if points_collection(mat2str(neighbour_points(i,:))).special_point && ~isequal(neighbour_points(i,:),current_point_reference.parent)
                            current_strand.points(end+1,:) = neighbour_points(i,:);
                            current_strand_flag = 0;
                            break
                        end    
                    end
                end
            elseif(~current_point_reference.special_point && current_strand_flag)
                current_strand.points(end+1,:) = current_point;
                branch_point_visited_flag = 0;
                for i = 1:size(non_visited_neighbour_points,1)
                    Cnp = intersect(branch_points,non_visited_neighbour_points(i,:),'stable','rows');
                    if(~isempty(Cnp))
                        branch_point_visited_flag = 1;
                        non_visited_neighbour_points(i,:) = [];
                        non_visited_points = [non_visited_points; non_visited_neighbour_points];
                        non_visited_points(end+1,:) = Cnp;
                        break
                    end 
                end
                starting_point_neighbour_flag = 0;
                if ~branch_point_visited_flag
                    for i = 1:size(non_visited_neighbour_points,1)
                        if ~points_collection(mat2str(non_visited_neighbour_points(i,:))).starting_point
                            starting_point_neighbour_flag = 1;
                            temp = non_visited_neighbour_points(i,:);
                            non_visited_neighbour_points(i,:) = [];
                            non_visited_points = [non_visited_points; non_visited_neighbour_points];
                            non_visited_points(end+1,:) = temp;
                            break
                        end
                    end
                end
                if (~branch_point_visited_flag && ~isempty(current_point_reference.parent) && ~starting_point_neighbour_flag)
                    current_strand.points(end+1,:) = current_point_reference.parent(end,:);
                    current_strand_flag = 0;
                    non_visited_points = [non_visited_points; non_visited_neighbour_points];
                elseif(~branch_point_visited_flag && isempty(current_point_reference.parent) && ~starting_point_neighbour_flag)
                    non_visited_points = [non_visited_points, non_visited_neighbour_points];
                    for i = 1:size(neighbour_points,1)
                        temp_reference = points_collection(mat2str(neighbour_points(i,:)));
                        if ~isempty(temp_reference.parent)
                            if temp_reference.visited
                                current_strand.points(end+1,:) = neighbour_points(i,:);
                                current_strand.points(end+1,:) = temp_reference.parent;
                                current_strand_flag = 0;
                            else
                                temp = non_visited_neighbour_points(i,:);
                                non_visited_points = [non_visited_points; non_visited_neighbour_points];
                                non_visited_points(end+1,:) = temp;
                            end
                            break
                        end
                    end
                end 
            end
        end
        
    end    
end

%--------------------------------------------------------------------------------------------------
% Auxillary functions
%--------------------------------------------------------------------------------------------------
% Neighbor pixels detection
function [neighbourPnts, count] = detect_neighbour_points(BW_thin, current_node)
    neighbourPnts = [];
    count = 0;
    row = current_node(1);
    col = current_node(2);
    for ii = max(row - 1, 1): min(row + 1, rows)
        for jj = max(col - 1, 1): min(col + 1, columns)
            if (BW_thin(ii,jj) == true && ~ (ii == row && jj == col))
                count = count + 1;
                neighbourPnts(count,:) = [ii,jj];
               
            end
        end
    end
end
end