function [array, decoupepos] = decoupe2(A, wL, wH, step, pt1, pt2, pt3, pt4)
[H L] = size(A);
index = 1;
for h = 1 : step : H-wH
    x1 = round((pt2(1)-pt1(1))/(pt2(2)-pt1(2))*(h-pt1(2)) + pt1(1));
    x2 = round((pt4(1)-pt3(1))/(pt4(2)-pt3(2))*(h-pt3(2)) + pt3(1));
    if x2 > L - wL
        for l = x1 : step : L - wL
            array(:,:,index) = A(h:(h+wH-1),l:(l+wL-1));
            decoupepos(1,index) = h;
            decoupepos(2,index) = l;
            index = index + 1;
        end
    else
        for l = x1 : step : x2
            array(:,:,index) = A(h:(h+wH-1),l:(l+wL-1));
            decoupepos(1,index) = h;
            decoupepos(2,index) = l;
            index = index + 1;
        end
    end

end

end

