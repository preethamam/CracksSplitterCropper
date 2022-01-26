classdef Points < handle
    properties
        row = 0;
        col = 0;
        parent
        starting_point = false;
        special_point = 0;
        visited = false;
    end
    methods
        function obj = Points(row,col)
         if nargin > 0
            obj.row = row;
            obj.col = col;
         end
      end
   end
end