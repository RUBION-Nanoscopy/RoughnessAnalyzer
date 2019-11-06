function icon = get_icon(name)
% GET_ICON returns the icon spcified by name
%
% Icons are taken from the breeze theme

[directory, ~, ~] = fileparts(mfilename('fullpath'));

icon = imread(fullfile( directory, sprintf('%s.png', name)));

icon = double(icon);
icon = icon/255;
icon(icon == 0) = NaN;
