function [ imgOut ] = scallingImg( img )

minImg = min(min(img));
img = img - minImg;
maxImg = max(max(img));
imgOut = img/maxImg*256;

end

