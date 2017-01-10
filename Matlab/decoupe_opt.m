function [array, decoupepos] = decoupe_opt(A, DD, wL, wH, step, pt1, pt2, pt3, pt4)
[H L] = size(A);
m1 = (pt2(1)-pt1(1))/(pt2(2)-pt1(2));
m2 = (pt4(1)-pt3(1))/(pt4(2)-pt3(2));
index = 1;
for h = 1 : step : H-wH 
    x1 = round(m1*(h-pt1(2)) + pt1(1));
    x2 = round(m2*(h-pt3(2)) + pt3(1));
    if x2 > L - wL
        for l = x1 : step : L - wL
            if DD(h,l) == 1
                array(:,:,index) = A(h:(h+wH-1),l:(l+wL-1));
                decoupepos(1,index) = h;
                decoupepos(2,index) = l;
                index = index + 1;
            end
        end
    else
        for l = x1 : step : x2
            if DD(h,l) == 1
                array(:,:,index) = A(h:(h+wH-1),l:(l+wL-1));
                decoupepos(1,index) = h;
                decoupepos(2,index) = l;
                index = index + 1;
            end
        end
    end

end

end

