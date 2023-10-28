% Relationships between the center and other colors
% Top, Right, Bottom, Left, Back
relationships = containers.Map;
relationships('w') = 'rbogy';
relationships('r') = 'ybwgo';
relationships('o') = 'wbygr';
relationships('b') = 'ryowg';
relationships('g') = 'rwoyb';
relationships('y') = 'rgobw';

% Color bounds
colorBounds = containers.Map;
colorBounds('w') = [0, 0, 0.6, 1, 1, 1];
colorBounds('r') = [0.95, 0.4167, 0.1389, 0.0556, 1, 1];
colorBounds('o') = [0.0556, 0.4167, 0.1389, 0.1389, 1, 1];
colorBounds('b') = [0.5556, 0.4167, 0.1389, 0.7222, 1, 1];
colorBounds('g') = [0.2778, 0.4167, 0.1389, 0.4444, 1, 1];
colorBounds('y') = [0.1389, 0.4167, 0.1389, 0.1944, 1, 1];

% Colors
colors = ['w', 'r', 'o', 'b', 'g', 'y'];

cube = zeros(3,3,6);
notDetected = 'wrobgy';
img1 = iread('file1.jpg', 'double');
DetectRubiksCube(cube, img1, 3)

% The code in this project is based on the above color relationships
% Detect the orientation of each face using the above relationships

disp(detectOrientation('w', 'g', 'r', relationships))


% Given the colors of the top, left, and right faces, detect the orientation
% Positive rotations are anticlockwise, negative rotations are clockwise
function rotations = detectOrientation(left, top, right, relationships)
arguments
    left char
    top char
    right char
    relationships containers.Map
end
rightRotations = 0;
leftRotations = 0;
if left == 'r'
    rightRotations = -1;
end
if left == 'o'
    rightRotations = 1;
end

leftRel = relationships(left);
for i = 1:4
    next = mod(i + 1,5);
    if next == 0
        next = 1;
    end
    if leftRel(i) == top && leftRel(next) == right
        leftRotations = i - 1;
    end
end

rotations = [leftRotations rightRotations];
end


function [newLeft, newTop, newRight] = ApplyOrientation(left, top, right, rotation)
arguments
    left (3,3) chars
    top (3,3) chars
    right (3,3) chars
    rotation (1,2) int8
end

newLeft = rot90(left, rotation(1));
newTop = rot90(top, rotation(1));
newRight = rot90(right, rotation(1));
newLeft = rot90(newLeft, rotation(2));

if rotation(2) == 1
    newRight = rot90(newRight, -1);
    newLeft = rot90(newLeft, 2);
elseif rotation(2) == -1
    newRight = rot90(newRight, 1);
    newTop = rot90(newTop, 2);
end
end

function newCube = DetectRubiksCube(cube, img, sigma)
arguments
    cube (3,3,6) uint8
    img (:,:,3) double
    sigma
end
% Detect the edges using DOG
GGu = kdgauss(sigma);

Iu = iconvolve( img, GGu);
Iv = iconvolve( img, GGu');
magDoG = sqrt( Iu.^2 + Iv.^2 );

% Binarize the images
edges = rgb2gray(magDoG);
edges = imbinarize(edges, 0.1);

figure;
imshow(magDoG);

% Get the contours of the image
contours = bwboundaries(edges, 8, 'noholes', 'xy');

% Get the lines in the Image
% Cell of arrays of lines in the image
% Each line is an array of 4 elements [x1, y1, x2, y2]
% { [x1, y1, x2, y2 ; x1, y1, x2, y2 ; x1, y1, x2, y2], [x1, y1, x2, y2]}
parallelLines = {[0 0 0 100]};
figure;
imshow(img);

for i = 1:length(contours)
    if numel(contours{i}) < 10
        continue;
    end
    shape = polyshape(contours{i}(:,2), contours{i}(:,1), 'SolidBoundaryOrientation','ccw');
    
    if shape.NumRegions ~= 1
        continue;
    end
    
    if area(shape) < 150
        continue;
    end
    
    points = reducepoly(shape.Vertices, 0.01);
    
    if length(points) < 3
        continue
    end
    
    lines = [points circshift(points,1)]';
    for l = lines
        l = l';
        
        
        lLength = sqrt((l(3) - l(1))^2 + (l(4)-l(2))^2);
        if lLength < 50
            continue;
        end
        
        for pl = 1:length(parallelLines)
            if isParallel(l, parallelLines{pl}(1,:))
                parallelLines{pl} = [parallelLines{pl}; l];
                break;
            elseif pl == length(parallelLines)
                parallelLines{end + 1} = [l];
            end
        end
    end
end
hold on;
% Go through each of the parallel lines and remove the lines that are too small
cols = 1:length(parallelLines);
cols = squeeze(label2rgb(cols));

for li = 1:length(parallelLines)
    l = parallelLines{li};
    for i = 1:size(l,1)
        line(l(i, [1,3]), l(i, [2,4]), 'Color', cols(li,:));
    end
    drawnow;
end
hold off;


% What is known about the rubiks cube.
% It is a cube like structure and 3 faces are visible since the expectation is that we are seing a corner.
% All the squares seen in a face are aligned in a grid. Can use this to determine the squares in a face.
% All the faces have 9 squares in a 3x3 grid. 3 faces join to create a corner of a cube.
% All shapes should approximate to a parallelogram.

end

function yes = isParallel(line1, line2, threshold)
arguments
    line1 (1,4) double
    line2 (1,4) double
    threshold double = 0.2
end
% Check if two lines are parallel
% Check if the slopes are the same
slope1 = (line1(4) - line1(2)) / (line1(3) - line1(1));
slope2 = (line2(4) - line2(2)) / (line2(3) - line2(1));
if abs(slope1 - slope2) < threshold
    yes = true;
    return;
end
yes = false;
end



















