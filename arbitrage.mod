set ASSET;
set NODE;
param M{ASSET,NODE};

var v{n in NODE};
var v_m;
var w{n in NODE};

subject to ExpRet_Cons_1{a in ASSET}:sum{n in NODE}M[a,n]*(v[n]+1)=v_m;
subject to ExpRet_Cons_2{a in ASSET}:sum{n in NODE}(M[a,n]+1)*w[n]=1;
subject to v_cons{n in NODE}: v[n]>=0;
subject to w_cons{n in NODE}: w[n]>=0;

