function [imgSeuillee] = imgHysteresis2( img )
histogram(img);
h = histogram(img);
hData = h.Values;
N = length(hData);
n = 1:N;
for s=1:length(hData)
    J(s) =  (sum(n(1:s).*hData(1:s)))^2/sum(hData(1:s))+(sum(n(s+1:N).*hData(s+1:N)))^2/sum(hData(s+1:N));
end

[val threshold1] = max(J);
threshold1
[val indexMaxHist] = max(hData)
threshold2 = indexMaxHist+(indexMaxHist-threshold1)

threshold1 = indexMaxHist - 18;
threshold2 = indexMaxHist + 18;

imgSeuillee = (img > threshold2) + (threshold1 > img);
subplot(1,3,1);plot(J);
subplot(1,3,2);imagesc(imgSeuillee);colormap(gray);
subplot(1,3,3);histogram(img);

end



