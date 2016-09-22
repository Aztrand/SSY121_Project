
function [QIMatrix] = closest (I, Q)
ref = [-3, -1, 1, 3];

Iclosest = zeros(0,length(I));
for j = 1:1:length(I)
    dist_old = 3.0;
    for i = 1:1:4
        dist = abs(I(j)-ref(i));
        if (dist < dist_old)
            dist_old = dist;
            Iclosest(j) = ref(i);
        end
    end
end

Qclosest = zeros(0,length(Q));
for j = 1:1:length(Q)
    dist_old = 3.0;
    for i = 1:1:4
        dist = abs(Q(j)-ref(i));
        if (dist < dist_old)
            dist_old = dist;
            Qclosest(j) = ref(i);
        end
    end
end

QIMatrix = [Qclosest.', Iclosest.'];