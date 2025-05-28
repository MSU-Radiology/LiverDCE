classdef RoiVoxelCoordinates
    % RoiVoxelCoordinates class     Class for performing transformations of an image mask representing a region 
    %                               between its mask form and a coordinate form where the rows contain the X, Y, and Z 
    %                               coordinates of the voxels that are within the ROI
    %
    % Copyright (C) 2025   Michigan State University
    % Author:  Matt Latourette

    %% Static Methods
    methods (Static)
        %% GetAsMap
        function coordmap = GetAsMap(mask)
            % coordmap(row, column, slice, 1) -> X coordinates
            % coordmap(row, column, slice, 2) -> Y coordinates
            % coordmap(row, column, slice, 3) -> Z coordinates (slice location)
            % zeros for all voxels not in the ROI
            coordmap = zeros([size(mask), 3]);
            for x = 1:size(mask,1)
                coordmap(x,:,:,1) = x;
            end
            for y = 1:size(mask,2)
                coordmap(:,y,:,2) = y;
            end
            for z = 1:size(mask,3)
                coordmap(:,:,z,3) = z;
            end
            coordmap = coordmap.*repmat(double(mask), 1, 1, 1, 3);
        end

        %% GetAsFlatList
        function coords = GetAsFlatList(mask)
            coordMap = RoiVoxelCoordinates.GetAsMap(mask);
            coords = reshape(coordMap(repmat(mask, 1, 1, 1, 3)), [], 3);
        end

        %% CreateParametricMapFromFlatList
        function parametricMap = CreateParametricMapFromFlatList(imageStack, coords, parametricFlatList)
            % imageStack is a 3D matrix in row, column, slice order
            % coords are the flat list indices and corresponding row, colum, slice values of their spatial locations
            % parametricFlatList is the flat list in index, value order
            parametricMap = zeros(size(imageStack));
            for idx = 1:size(parametricFlatList,1)
                mapIdxs = num2cell(coords(idx,:));
                parametricMap(mapIdxs{:}) = parametricFlatList(idx);
            end
        end
    end
end



