function [ velocity ] = velocity_inst( time,altitude_m )
%velocity = zeros(size(time));
velocity(1)=0;
for i = 1:(size(time)-1)
   velocity(i+1) = (altitude_m(i+1)-altitude_m(i))/(time(i+1)-time(i));
end



end

