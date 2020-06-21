

sets
        losscuts 'number of cuts to iterate over'                /1*10/
;
alias(losscuts, lc, loc);



sets
        t 'set of indices of time periods t'                     /t1*t40/
        d 'set of indices of demand response blockoffers d'           /d1*d4/
;
sets
         n       'set of busses in the system'                           /n1*n6/
         reg     'set of regulating units'                               /c1*c3,i1*i3,s/
         gens(reg) 'slack and generators combined'                       /s,i1*i2/
         ns(gens)   'subest of n the Slack Bus'                          /s/
         l       'set of all lines'                                      /l1*l5/
         c(reg)       'set of demand response units'                     /c1*c3/
         i(gens)       'set of regular generators'                        /i1*i2/
;
alias(t, tau);
alias(n,j,h);

parameters Cup[i,t] 'up-regulation offer price of regulating bid i and time t by conventional units [$/MWh]'
           Cdn[i,t] 'Down-regulation offer price of regulating bid i at time t by conventional units [$/MWh]'
           CDRup[d,c,t] 'Up-regulation offer price of demand response unit c, block d, time t (load reduction) [$/MWh]'
           CDRdn[d,c,t] 'Down-regulation offer price of demand respnse unit c, block d, time t (load increase) [$/MWh]'
           PUpmax[i,t] 'Up-regulation quantity offer of regulating bid i, time t [MWh]'
           PDnmax[i,t] 'Down-regulation quantity offer of regulating bid i, time t [MWh]'
           P_DR_resp[d,c] 'Prescribed power output or consumption during response unit c, block d [MW]'
           P_DR_reb[d,c] 'Prescribed power output or consumption during rebound unit c, block d [MW]'
           Tresp[d,c] 'Response duration of demand response block d unit c [min]'
           Treb[d,c] 'Rebound duration of demand response block d, unit c [min]'
           Trec[d,c] 'Recover duration of demand response block d, unit c [min]'
           A[d,c] 'Orientation parameter of demand response block d, unit c. Equal to 1 if commences with up-regulation followed by down-regulation, equal to 0 otherwise'
           On[c,t] 'Availability of demand response unit c, at time t'
           Cupslack[t]   'Energy price at the slack bus (import from TSO)'
           Cdnslack[t]   'Sellback price to the slack bus (export to TSO)'
           PUpmax_slack[t]  'Max energy import from slack bus'
           PDnmax_slack[t]  'Max energy sellback to slack bus'
           slack_disp[t]         'power dispatch at the slack bus from the day-ahead market'
                 /t1*t11         15
                 t12*t26         50
                 t27*t40         2/
           gen_disp[t,i]         'power dispatch of the regular generators from the day-ahead market'
                 /t1*t11 . i1    10
                 t1*t11  . i2    9
                 t12*t26 . i1    60
                 t12*t26 . i2    13
                 t27*t40 . i1    2
                 t27*t40 . i2    2/
                 //t1*t15  . i3    15
                 //t16*t29 . i3    70
                 //t30*t40 . i3    6/
           K(l)    'kVA capacity of line l'
           / l1  1000
             l2  1000
             l3  40
             l4  1000
             l5  1000/
         y_up_max(t,gens)        'maximal reactive power up-regulation of the slackbus and the regular generators'
         y_dn_max(t,gens)        'maximal reactive power down-regulation of the slackbus and the regular generators'
         dcq(t,n)                'consumer houshold reactive demand'
         B[l]                  'line shunt suseptance of line l to ground'
                 /l1     0.1
                 l2      0.1
                 l3      0.1
                 l4      0.1
                 l5      0.1/
         G[l]                  'line shunt conductance of line l to ground'
                 /l1     0.1
                 l2      0.1
                 l3      0.1
                 l4      0.1
                 l5      0.1/
         V_low   /0.9/
         V_hi    /1.1/
;
scalar CSup /3000/
       CSdn /-3000/
       qfactor 'price factor of the reactive power' /10000/
;

parameter NL_conec(n,j,l) 'mapping parameter of line l to node n to j'
         /n1.n2.l1       1
         n2.n3.l2        1
         n3.n4.l3        1
         n4.n5.l4        1
         n5.n6.l5        1/
;
parameter flow_limit(n,j) 'The apparent power line flow limit from line n to j';
flow_limit(n,j) = sum(l,K(l)*NL_conec(n,j,l));
flow_limit(n,j) = flow_limit(n,j) + flow_limit(j,n);

parameters       B_nodal[n,j] 'the shunt suseptance from node n to j'
                 G_nodal[n,j] 'shunt conductance to ground of line from node n to j'
;
B_nodal[n,j] = sum(l,B[l]*NL_conec(n,j,l));
B_nodal[n,j] = B_nodal[n,j] + B_nodal[j,n];
G_nodal[n,j] = sum(l,G[l]*NL_conec(n,j,l));
G_nodal[n,j] = G_nodal[n,j] + G_nodal[j,n];



P_DR_resp['d1','c1']=13;
P_DR_resp['d1','c2']=17;
P_DR_resp['d1','c3']=12;
P_DR_resp['d2','c1']=17;
P_DR_resp['d2','c2']=8 ;
P_DR_resp['d2','c3']=15;
P_DR_resp['d3','c1']=10;
P_DR_resp['d3','c2']=13;
P_DR_resp['d3','c3']=11;
P_DR_resp['d4','c1']=17;
P_DR_resp['d4','c2']=15;
P_DR_resp['d4','c3']=13;
//P_DR_resp['d1','c4'] = 12;
//P_DR_resp['d2','c4'] = 11;
//P_DR_resp['d3','c4'] = 18;
//P_DR_resp['d4','c4'] = 18;

P_DR_reb['d1','c1']=17;
P_DR_reb['d1','c2']=8 ;
P_DR_reb['d1','c3']=15;
P_DR_reb['d2','c1']=13;
P_DR_reb['d2','c2']=17;
P_DR_reb['d2','c3']=12;
P_DR_reb['d3','c1']=10;
P_DR_reb['d3','c2']=15;
P_DR_reb['d3','c3']=13;
P_DR_reb['d4','c1']=10;
P_DR_reb['d4','c2']=13;
P_DR_reb['d4','c3']=11;
//P_DR_reb['d1','c4'] = 10;
//P_DR_reb['d2','c4'] = 10;
//P_DR_reb['d3','c4'] = 12;
//P_DR_reb['d4','c4'] = 12;

Tresp['d1','c1']=13;
Tresp['d1','c2']=9 ;
Tresp['d1','c3']=15;
Tresp['d2','c1']=9 ;
Tresp['d2','c2']=29;
Tresp['d2','c3']=11;
Tresp['d3','c1']=20;
Tresp['d3','c2']=13;
Tresp['d3','c3']=18;
Tresp['d4','c1']=9 ;
Tresp['d4','c2']=11;
Tresp['d4','c3']=14;
//Tresp['d1','c4'] = 12;
//Tresp['d2','c4'] = 11;
//Tresp['d3','c4'] = 6;
//Tresp['d4','c4'] = 6;

Treb['d1','c1']=9 ;
Treb['d1','c2']=29;
Treb['d1','c3']=11;
Treb['d2','c1']=13;
Treb['d2','c2']=9 ;
Treb['d2','c3']=15;
Treb['d3','c1']=21;
Treb['d3','c2']=11;
Treb['d3','c3']=14;
Treb['d4','c1']=20;
Treb['d4','c2']=13;
Treb['d4','c3']=18;
//Treb['d1','c4'] = 12;
//Treb['d2','c4'] = 11;
//Treb['d3','c4'] = 13;
//Treb['d4','c4'] = 13;

Trec['d1','c1']=2;
Trec['d1','c2']=2;
Trec['d1','c3']=2;
Trec['d2','c1']=2;
Trec['d2','c2']=2;
Trec['d2','c3']=2;
Trec['d3','c1']=2;
Trec['d3','c2']=2;
Trec['d3','c3']=2;
Trec['d4','c1']=2;
Trec['d4','c2']=2;
Trec['d4','c3']=2;
//Trec['d1','c4']=1;
//Trec['d2','c4']=1;
//Trec['d3','c4']=1;
//Trec['d4','c4']=1;

A['d1','c1']=1;
A['d1','c3']=1;
A['d2','c2']=1;
A['d3','c1']=1;
A['d3','c2']=1;
A['d3','c3']=1;
//A['d1','c4'] = 1;
//A['d3','c4'] = 1;


On[c,t] = 1;

Cup[i,t] = 35;
Cdn[i,t] = 10;

PUpmax[i,t] = 80;
Pdnmax[i,t] = 80;

Cupslack[t] = 21;
Cdnslack[t] = 19;

CDRup[d,c,t] = 25;
CDRdn[d,c,t] = 16;

PUpmax_slack[t] = 100;
Pdnmax_slack[t] = 100;

y_up_max(t,gens) = 100;
y_dn_max(t,gens) = 100;

table res(n,j)  'resistance of line l'
                 n1      n2      n3      n4      n5      n6
         n1              0.001
         n2      0.001           0.001
         n3              0.001           0.001
         n4                      0.001           0.001
         n5                              0.001           0.001
         n6                                      0.001
;
table reac(n,j)  'resistance of line l'
                 n1      n2      n3      n4      n5      n6
         n1              0.0005
         n2      0.0005          0.0005
         n3              0.0005          0.0005
         n4                      0.0005          0.0005
         n5                              0.0005          0.0005
         n6                                      0.0005
;



table conec(n,j) 'incidence matrix'
                 n1      n2      n3      n4      n5      n6
         n1              1
         n2      1               1
         n3              1               1
         n4                      1               1
         n5                              1               1
         n6                                      1
;

table dc(t,n) 'consumer houshold demand at node n and time t'
        n1       n2      n3      n4      n5      n6
t1      0        0       0       0       0       0
t2      0        0       0       0       0       0
t3      0        0       0       0       0       0
t4      0        0       0       0       0       0
t5      0        0       0       0       0       0
t6      0        0       0       0       0       0
t7      0        0       0       0       0       0
t8      0        0       0       0       0       0
t9      0        0       0       0       0       0
t10     0        0       0       0       0       0
t11     0        0       0       0       0       0
t12     0        0       0       0       0       0
t13     0        0       0       0       0       0
t14     0        0       0       0       0       0
t15     0        0       0       0       0       0
t16     0        0       0       0       0       0
t17     0        0       0       0       0       0
t18     0        0       0       0       0       0
t19     0        0       0       0       0       0
t20     0        0       0       0       0       0
t21     0        0       0       0       0       0
t22     0        0       0       0       0       0
t23     0        0       0       0       0       0
t24     0        0       0       0       0       0
t25     0        0       0       0       0       0
t26     0        0       0       0       0       0
t27     0        0       0       0       0       0
t28     0        0       0       0       0       0
t29     0        0       0       0       0       0
t30     0        0       0       0       0       0
t31     0        0       0       0       0       0
t32     0        0       0       0       0       0
t33     0        0       0       0       0       0
t34     0        0       0       0       0       0
t35     0        0       0       0       0       0
t36     0        0       0       0       0       0
t37     0        0       0       0       0       0
t38     0        0       0       0       0       0
t39     0        0       0       0       0       0
t40     0        0       0       0       0       0
;
table drl(t,c) 'demand response loads scheduled from day-ahead market'
         c1      c2      c3
t1       2       30      2
t2       2       30      2
t3       2       30      2
t4       2       30      2
t5       2       30      2
t6       2       30      2
t7       2       30      2
t8       2       30      2
t9       2       30      2
t10      2       30      2
t11      2       30      2
t12      46      32      45
t13      46      32      45
t14      46      32      45
t15      46      32      45
t16      46      32      45
t17      46      32      45
t18      46      32      45
t19      46      32      45
t20      46      32      45
t21      46      32      45
t22      46      32      45
t23      46      32      45
t24      46      32      45
t25      46      32      45
t26      46      32      45
t27      2       1       3
t28      2       1       3
t29      2       1       3
t30      2       1       3
t31      2       1       3
t32      2       1       3
t33      2       1       3
t34      2       1       3
t35      2       1       3
t36      2       1       3
t37      2       1       3
t38      2       1       3
t39      2       1       3
t40      2       1       3
;

dcq(t,n) = 0;


table loc_c[c,n] 'location of demand response units'
         n1      n2      n3      n4      n5      n6
c1               1
c2                                       1
c3                                               1
;

table    loc_i(n,i) 'location of conventional generator i'
                 i1      i2
         n1
         n2
         n3      1
         n4              1
;
table loc_ns[ns,n] 'location of the slack bus'
         n1      n2      n3      n4      n5      n6
s        1
;

parameter pf 'Maximum allowed power factor';
pf = 0.9;

parameter cut_active(lc) '1 if the loss cut is active, else 0'
;
cut_active(lc) = 0;

parameter flow_fix(lc,n,j,t) 'the loss cut constant flow',
         loss_fix(lc,n,t)        'fixed losses fromt the cuts'
         flow_fix_q(lc,n,j,t)   'the constant reactive power flow from the previous iteration'
         loss_fix_q(lc,n,t)      'fixed reactive power losses from the cuts'
;
flow_fix(lc,n,j,t) = 0;
loss_fix(lc,n,t) = 0;
flow_fix_q(lc,n,j,t) = 0;
loss_fix_q(lc,n,t) = 0;
