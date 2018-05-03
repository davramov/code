function [ m ] = mass( v0, v, vex, m0 )

m = m0/exp((v-v0)/vex);

end

