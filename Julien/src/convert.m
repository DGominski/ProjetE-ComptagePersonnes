function [y] = convert(x)

    y = x - min(min((x)));
    y = y/max(max(y))*255;

end

