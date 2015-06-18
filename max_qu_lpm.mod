set ASSET;
set ROOT_NODE;
set MID_NODE;
set LEAF_NODE;

param PRED{MID_NODE union LEAF_NODE} symbolic in ROOT_NODE union MID_NODE;
param ret{ASSET,ROOT_NODE union MID_NODE union LEAF_NODE};
param prob{ROOT_NODE union MID_NODE union LEAF_NODE};
param time{ROOT_NODE union MID_NODE union LEAF_NODE};

param T;
param alpha{1..T};
param TW{1..T};

param W0;
param A;

var w{a in ASSET, n in ROOT_NODE union MID_NODE union LEAF_NODE} >=0;
var w_m{n in MID_NODE union LEAF_NODE} >=0;
var w_p{n in MID_NODE union LEAF_NODE} >=0;

maximize QU_LPM: sum{n in MID_NODE union LEAF_NODE}alpha[time[n]]*prob[n]*(sum{a in ASSET}w[a,n]-A*w_m[n]^2);

subject to Init_Wealth_Cons{n in ROOT_NODE}: sum{a in ASSET}w[a,n] = W0;
subject to Reinv_Cons{n in MID_NODE union LEAF_NODE}: sum{a in ASSET}(w[a,PRED[n]]*exp(ret[a,n]))=sum{a in ASSET}w[a,n];
subject to Target_Ref{n in MID_NODE union LEAF_NODE}: sum{a in ASSET}w[a,n]-w_p[n]+w_m[n]=TW[time[n]];
