
function [QIMatrix] = closest (IQ)
ref = [(-3 + 3i) (-3 +1i) (-3 -3i) (-3 -1i) (-1 + 3i) (-1 +1i) (-1 -3i) (-1 -1i) (+3 + 3i) (+3 +1i) (+3 -3i) (+3 -1i) (+1 + 3i) (+1 +1i) (+1 -3i) (+1 -1i)];

closest = zeros(0,length(IQ));
for j = 1:1:length(IQ)
    dist_old = 3.0;
    for i = 1:1:length(ref)
        dist = abs(IQ(j)-ref(i));
        if (dist < dist_old)
            dist_old = dist;
            closest(j) = ref(i);
        end
    end
end



QIMatrix = closest;