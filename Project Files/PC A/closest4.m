function [QIMatrix] = closest4 (IQ)
ref = [(1 + 1i) (1 - 1i) (-1 -1i) (-1 + 1i)]; %/sqrt(2) ?
closest = zeros(0,length(IQ));
for j = 1:1:length(IQ)
    dist_old = 1.0;
    for i = 1:1:length(ref)
        dist = abs(IQ(j)-ref(i));
        if (dist < dist_old)
            dist_old = dist;
            closest(j) = ref(i);
        end
    end
end



QIMatrix = closest;