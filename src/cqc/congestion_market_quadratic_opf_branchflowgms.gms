$ontext
This file runs the congestion management with asymmetric block offers, using a CQCP model of the optimal power flow.
$offtext

$eolcom //
option iterlim=999999999;     // avoid limit on iterations
option reslim=500000;            // timelimit for solver
option optcr=0.0;             // gap tolerance
Option optca = 0
option solprint=OFF;          // include solution print in .lst file
option limrow=10000;              // limit number of rows in .lst file
option limcol=10000;              // limit number of columns in .lst file
option threads = 24;
option miqcp=cplex

//$GDXIN InputFile_Ecogrid2.gdx
//$load t d Cdn Cup PDnmax PUpmax
//$GDXIN


$include 37bus_IEEE_linedata.gms

positive variables
                 //pup_TSO[t] 'Up-regulation bought from the transmission grid'
                 //pdn_TSO[t] 'Down-regulation bought from the transmission grid'
                 pup[gens,t] 'Up-regulation provided by conventional unit i at period t'
                 pdn[gens,t] 'Down-regulation provided by conventional unit i at period t [MWh]'
                 rup[d,c,t]'Up-regulation provided by demand response block d, unit c at period t [MWh]'
                 rdn[d,c,t] 'Down-regulation provided by demand response block d, unit c at period t [MWh]'
                 sup[t,n] 'Slack variable up-regulation (similar to load shedding) at period t [MWh]'
                 squp[t,n] 'slack variable up-regulation of reactive power (similar to load shedding)'
                 //sdn[t,n] 'Slack variable down-regulation (similar to wind spillage) at period t [MWh]'
                 y_up(gens,t)          'reacitve generation at generator upregulation'
                 y_dn[gens,t]    'reactive generation downregulation'
                 //s_sqr_up[gens,t]
                 //s_sqr_dn[gens,t]
;
binary variables v[d,c,t] 'online status of demand response block d, unit c at period t'
;
//parameter v[d,c,t];
//v[d,c,t] = 0;

variables
         z               'objective value'
         p_inj(n,t)
         //x(i,t)          'acitve generation at generator'
         //y(gens,t)          'reacitve generation at generator'
         //s_flow(n,j,t)   'apparent power flow from node n to j'
         p_flow(n,n,t)   'acitve power flow through line l at time t'
         q_flow(n,n,t)   'reactive power flow trough line l'
         //losses(t)
         voltsq(n,t)      'squqre voltage at bus n'
         //cur_sq(n,n,t)   'line current squared magnitude'
         q_inj(n,t)
         //line_flow(l,t)  'line flow in line l'
         pf_lin(n,j,t)   'linearized approximation of the real power flow'
         qf_lin(n,j,t)   'linearized apporximation of the reactive power flow'
         vsq_lin(n,t)    'linearized squared voltage approximation'
         //s_sqr(gens,t)   'injected apparent power squared'
;
variables
         //z               'objective value'
         //r(n,t)          'net active power import/export at node n at time t, positive for import'
         solver_time
;
//parameter net_node(n,t), LMP(n,t), test1(t,n), test2(t,n)
//;
equations
         objective
         //no_generation
         def_flow1
         def_flow2
         def_flow3
         def_flow4
         //def_lineflow
         flow_limit1
         flow_limit2
         //def_losses
         def_voltage
         volt_limit1
         volt_limit2
         inj_real
         inj_imag
         //inj_real2
         inj_imag2
         //gen_limit1
         //gen_limit2
         gen_limit3
         gen_limit4
         max_TSO_import
         max_TSO_export
         eq_1c
         eq_1d
         max_gen_downreg
         max_loadshed
         //max_windspil
         max_DR_up
         r_decl
         eq_1e
         eq_1f
         eq_1g
         eq_1h
         eq_1i
         eq_1j
         eq_1k
         eq_1l
         eq_1m
         eq_1n
         eq_1o
         eq_1p
         eq_1q
         eq_1r
         eq_1s

         lin_flow3
         lin_flow4
         lin_flow5
         lin_flow6
         suff_cond
         suff_cond2
         def_volt_lin

         //def_app_power_up
         //def_app_power_dn
;


//voltsq.fx('n1',t) = sqr(1);
//rup.fx(d,c,t) = 0;
objective ..
         z =e=
         sum([ns,t],Cupslack[t]*pup[ns,t] - Cdnslack[t]*pdn[ns,t])
         + sum([i,t],Cup[i,t]*pup[i,t] - Cdn[i,t]*pdn[i,t])
         + sum([c,d,t],CDRup[d,c,t]*rup[d,c,t]-CDRdn[d,c,t]*rdn[d,c,t])
         + sum([t,n],CSup*(sup[t,n] + squp[t,n]))
         + sum([ns,t],Cupslack[t]/qfactor*y_up[ns,t] - Cdnslack[t]/qfactor*y_dn[ns,t])
         + sum([i,t],Cup[i,t]/qfactor*y_up[i,t] - Cdn[i,t]/qfactor*y_dn[i,t]);

max_TSO_import[ns,t] ..  pup[ns,t] =l= PUpmax_slack[t];
max_TSO_export[ns,t] ..  pdn[ns,t] =l= PDnmax_slack[t];

def_flow1(n,j,t)$(conec(n,j) = 1) ..     (sqr(p_flow[n,j,t]) + sqr(q_flow[n,j,t]))*res(n,j) =l= p_flow(n,j,t) + p_flow(j,n,t);
def_flow2(n,j,t)$(conec(n,j) = 1) ..     (sqr(p_flow[n,j,t]) + sqr(q_flow[n,j,t]))*reac(n,j) =l= q_flow(n,j,t) + q_flow(j,n,t);

def_flow3(n,j,t)$(conec(n,j) = 0) ..     p_flow[n,j,t] =e= 0;
def_flow4(n,j,t)$(conec(n,j) = 0) ..     q_flow[n,j,t] =e= 0;
//def_lineflow(n,j,t) ..                   s_flow[n,j,t] =g= sqr(p_flow[n,j,t]) + sqr(q_flow[n,j,t]); //sum(n,p_inj(n,t)*PTDF(n,l)) =e= line_flow(l,t);
flow_limit1(n,j,t) ..                    -flow_limit(n,j) =l= p_flow[n,j,t];
flow_limit2(n,j,t) ..                    flow_limit(n,j) =g= p_flow[n,j,t];

def_voltage(n,j,t)$(conec(n,j) = 1 and ord(n) > ord(j)) ..   voltsq(j,t) =e= voltsq(n,t) - 2*(res[n,j]*p_flow[n,j,t] + reac[n,j]*q_flow[n,j,t]) ;

volt_limit1(n,t) ..                      sqr(0.9) =l= voltsq(n,t);
volt_limit2(n,t) ..                      voltsq(n,t) =l= sqr(1.1);

inj_real(n,t) ..                         p_inj(n,t) =e= sum(j, p_flow(n,j,t) );
inj_imag(n,t) ..                         q_inj(n,t) =e= sum(j, q_flow(n,j,t) );

//inj_real2(n,t) ..                        p_inj(n,t) =e= sum(i,x(i,t)*loc_i(n,i)) - dc(t,n);
inj_imag2(n,t) ..                        q_inj(n,t) =e= sum(ns, ( y_up[ns,t] - y_dn[ns,t] ) * loc_ns(ns,n) )
                                                         + sum(i, ( y_up[i,t] - y_dn[i,t] )*loc_i(n,i)) - dcq(t,n) + squp[t,n];

gen_limit3(gens,t) ..                    y_dn(gens,t) =l= y_dn_max(t,gens);
gen_limit4(gens,t) ..                    y_up(gens,t) =l= y_up_max(t,gens);


eq_1c(i,t) ..            pup[i,t] =l= PUpmax[i,t];
eq_1d(i,t) ..            pdn[i,t] =l= PDnmax[i,t];
max_gen_downreg(i,t) ..  gen_disp[t,i] - pdn[i,t] =g= 0;

max_loadshed(n,t) ..     sup[t,n] + sum([d,c],(rup[d,c,t] - rdn[d,c,t])*loc_c[c,n])=l= DC[t,n] + sum(c,DRL[t,c]*loc_c[c,n]);
//max_windspil(n,t) ..     sum(i,(gen_disp[t,i]-pdn[i,t])*loc_i[n,i] ) - sdn[t,n] =g= 0;

max_DR_up(c,t) ..        sum(d,rup[d,c,t]) =l= drl[t,c];

r_decl(n,t) ..           p_inj(n,t) =e= sum([d,c],(rup[d,c,t] - rdn[d,c,t]) * loc_c(c,n)) - sum(c, drl[t,c] * loc_c[c,n])
                         + sum(i,gen_disp[t,i]*loc_i[n,i] )  + sum(i, (pup[i,t] - pdn[i,t]) * loc_i[n,i])
                         + sum(ns, slack_disp[t] * loc_ns[ns,n] )+ sum(ns, (pup[ns,t] - pdn[ns,t]) *loc_ns[ns,n])
                         - dc[t,n] + sup[t,n];

lin_flow3(n,j,t)$(conec(n,j) = 1 and ord(n) > ord(j)) ..
         pf_lin[n,j,t] =e= p_inj[n,t] + sum((h)$(conec(h,n) eq 1 and ord(h) > ord(n)),pf_lin[h,n,t]);
lin_flow4(n,j,t)$(conec(n,j) = 0) ..     pf_lin[n,j,t] =e= 0;

lin_flow5(n,j,t)$(conec(n,j) = 1 and ord(n) > ord(j)) ..
         qf_lin[n,j,t] =e= q_inj[n,t] + sum((h)$(conec(h,n) eq 1 and ord(h) > ord(n)),qf_lin[h,n,t]);
lin_flow6(n,j,t)$(conec(n,j) = 0) ..     qf_lin[n,j,t] =e= 0;

suff_cond(n,j,t)$(conec(n,j) = 1 and ord(n) > ord(j)) ..
                                 pf_lin(n,j,t)*res[n,j]+qf_lin[n,j,t]*reac[n,j] =l= 0.01;

def_volt_lin(n,j,t)$(conec(n,j) = 1 and ord(n) > ord(j)) .. vsq_lin(j,t) =e= vsq_lin(n,t) - 2*((pf_lin[n,j,t]*res[n,j]+qf_lin[n,j,t]*reac[n,j])) ;
suff_cond2(n,t) ..                       vsq_lin(n,t) =l= sqr(1.1);


eq_1e(d,c,t)$(A(d,c) eq 1) .. rup[d,c,t] =l= P_DR_resp[d,c]*v[d,c,t];
eq_1f(d,c,t)$(A(d,c) eq 1) .. rdn[d,c,t] =l= P_DR_reb[d,c]*v[d,c,t];

eq_1g(d,c,t)$(A(d,c) eq 1) ..
         sum((tau)$(ord(t) <= ord(tau) and ord(tau) <= ( ord(t) + Tresp[d,c] - 1)), rup[d,c,tau])
         =g= Tresp[d,c] * P_DR_resp[d,c]*(v[d,c,t] - v[d,c,t-1]$(ord(t)>1));

eq_1h(d,c,t)$(A(d,c) eq 1 and ord(t) <= (card(t) - Tresp[d,c])) ..
         sum((tau)$(ord(t) + Tresp[d,c] <= ord(tau) and ord(tau) <= (ord(t) + Tresp[d,c] + Treb[d,c] - 1)), rdn[d,c,tau])
         =g= Treb[d,c]*P_DR_reb[d,c]*(v[d,c,t] - v[d,c,t - 1]$(ord(t)>1));

eq_1i(d,c,t)$(A(d,c) = 1) ..
         sum(tau$( ord(t) <= ord(tau) and ord(tau) <= ord(t) + Tresp[d,c] -1), rdn[d,c,tau])
         =l= Treb[d,c]*P_DR_reb[d,c]*(1-(v[d,c,t] - v[d,c,t-1]$(ord(t)>1)));

eq_1j(d,c,t)$(A(d,c) = 1 and ord(t) <= card(t) - Tresp[d,c]) ..
         sum(tau$( ord(t) + Tresp[d,c] <= ord(tau) and ord(tau) <= ord(t) + Tresp[d,c] + Treb[d,c] - 1), rup[d,c,tau])
         =l= Tresp[d,c]*P_DR_resp[d,c]*(1-(v[d,c,t] - v[d,c,t-1]$(ord(t)>1)));

eq_1k(d,c,t)$(A(d,c) = 0) .. rdn[d,c,t] =l= P_DR_resp[d,c]*v[d,c,t];
eq_1l(d,c,t)$(A(d,c) = 0) .. rup[d,c,t] =l= P_DR_reb[d,c]*v[d,c,t];

eq_1m(d,c,t)$(A(d,c) eq 0) ..
         sum((tau)$(ord(t) <= ord(tau) and ord(tau) <= ( ord(t) + Tresp[d,c] - 1)), rdn[d,c,tau])
         =g= Tresp[d,c] * P_DR_resp[d,c]*(v[d,c,t] - v[d,c,t-1]$(ord(t)>1));

eq_1n(d,c,t)$(A(d,c) eq 0 and ord(t) <= card(t) - Tresp[d,c]) ..
         sum((tau)$(ord(t) + Tresp[d,c] <= ord(tau) and ord(tau) <= ord(t) + Tresp[d,c] + Treb[d,c] - 1), rup[d,c,tau])
         =g= Treb[d,c]*P_DR_reb[d,c]*(v[d,c,t] - v[d,c,t - 1]$(ord(t)>1));

eq_1o(d,c,t)$(A(d,c) = 0) ..
         sum(tau$( ord(t) <= ord(tau) and ord(tau) <= (ord(t) + Tresp[d,c] -1) ), rup[d,c,tau])
         =l= Treb[d,c]*P_DR_reb[d,c]*(1-(v[d,c,t] - v[d,c,t-1]$(ord(t)>1)));

eq_1p(d,c,t)$(A(d,c) = 0 and ord(t) <= card(t) - Tresp[d,c]) ..
         sum(tau$( ord(t) + Tresp[d,c] <= ord(tau) and ord(tau) <= (ord(t) + Tresp[d,c] + Treb[d,c] - 1)), rdn[d,c,tau])
         =l= Tresp[d,c]*P_DR_resp[d,c]*(1-(v[d,c,t] - v[d,c,t-1]$(ord(t)>1)));


eq_1q(d,c,t)$(ord(t) le (card(t)-Tresp(d,c)-Treb(d,c)-Trec(d,c)+1)) ..
         sum(tau$(ord(t) + Tresp[d,c] + Treb[d,c] <= ord(tau) and ord(tau) <= ord(t) + Tresp[d,c] + Treb[d,c] + Trec[d,c] - 1), 1- v[d,c,tau])
         =g= Trec[d,c] * (v[d,c,t] - v[d,c,t-1]$(ord(t)>1));

eq_1r(c,t) .. sum(d, v[d,c,t]) =l= On[c,t];

eq_1s(d,c,tau)$(ord(tau) = card(t) - (Tresp[d,c] + Treb[d,c])) ..
         1 - (v[d,c,tau+1] - v[d,c,tau])
         =l= 2*(1 - sum(t$(ord(t) eq card(t)),v(d,c,t)));


model dlmp /all/
;

dlmp.optFile = 1;

solve dlmp using miqcp minimizing z
;
//flow(l,t) = sum(n,PTDF(n,l) * (r.l(n,t) - dc(t,n)));
//line_inj(n,t) = sum(l,PTDF(n,l)* flow.l(l,t));
//net_node(n,t) = sum(i,x.l(i,t)*loc_i(n,i)) - dc(t,n);
//LMP(n,t) =  power_balance.m(t) - sum((l), transmission_constr1.m(t,l) * PTDF(n,l)) + sum((l),transmission_constr2.m(t,l) * PTDF(n,l));
//test1(t,n) = sum(l,transmission_constr1.m(t,l) * PTDF(n,l));
//test2(t,n) = sum(l,transmission_constr2.m(t,l) * PTDF(n,l));
parameter voltages(n,t), volt_lin(n,t);

voltages(n,t) = sqrt(voltsq.l(n,t));
//volt_lin(n,t) = sqrt(vsq_lin.l(n,t));

parameter r_fin[d,reg,t], p_TSO_fin[t], p_fin[reg,t];
parameter LMP(n,t)
;

//flow(l,t) = sum(n,PTDF(n,l) * r.l(n,t) );
//net_node(n,t) = x.l(n,t) - dc(t,n);
//LMP(n,t) =  power_balance.m(t) - sum((l), transmission_constr1.m(t,l) * PTDF(n,l)) + sum((l),transmission_constr2.m(t,l) * PTDF(n,l));
//test1(t,n) = sum(l,transmission_constr1.m(t,l) * PTDF(n,l));
//test2(t,n) = sum(l,transmission_constr2.m(t,l) * PTDF(n,l));
r_fin[d,c,t] = rup.L[d,c,t] - rdn.L[d,c,t];
solver_time.l = dlmp.resusd;
p_TSO_fin[t] = pup.l['s',t] - pdn.l['s',t];
p_fin[i,t] = pup.l[i,t] - pdn.l[i,t];

parameter reg_fin[reg,t], input_data[reg,t];

reg_fin[reg,t] = sum(d,r_fin[d,reg,t]) + p_fin[reg,t];
reg_fin[ns,t] = reg_fin[ns,t] + p_TSO_fin[t];


input_data['s',t] =  slack_disp[t];
input_data[i,t] = gen_disp[t,i];
input_data[c,t] = -drl[t,c];

//parameter s_flow_root(n,j,t);
//s_flow_root(n,j,t) = sqrt(s_flow.l(n,j,t));

parameter loss_p(n,j,t), loss_q(n,j,t);
loss_p(n,j,t) = p_flow.l(n,j,t) + p_flow.l(j,n,t);
loss_q(n,j,t) = q_flow.l(n,j,t) + q_flow.l(j,n,t);


parameter final_dispatch(reg,t);
final_dispatch(reg,t) = input_data(reg,t) + reg_fin(reg,t);
$ontext
parameter final_injection_p(n,t);
final_injection_p(n,t) = sum(i,final_dispatch[i,t]*loc_i[n,i]) + sum(ns,final_dispatch['s',t]*loc_ns(ns,n)) + sum(c,final_dispatch[c,t]*loc_c[c,n]);

parameter final_injection_q(n,t);
final_injection_q(n,t) = q_inj.l(n,t) - dcq(t,n);
$offtext

parameter check_suff_cond[n,j,t];

check_suff_cond[n,j,t] = pf_lin.l(n,j,t)*res[n,j]+qf_lin.l[n,j,t]*reac[n,j];

//sum_cons = sum((t), losses.l(t)) + sum((n,t), dc(t,n));
//all_gen_sum = sum((i,t), x.l(i,t)) + sum(t, Ps.l(t));
display z.l, p_flow.l, q_flow.l, voltages, y_up.l, y_dn.l, pup.l, pdn.l, rup.l, rdn.l, v.l, sup.l, squp.l,
flow_limit, p_inj.l, q_inj.l, def_flow1.l, def_flow2.l, solver_time.l,
loss_p, loss_q, pf_lin.l, qf_lin.l, check_suff_cond;

//display power_balance.m, transmission_constr2.m, transmission_constr1.m;

execute_unload "congestion_management_cqc.gdx" z.L rup.L rdn.L pdn.L pup.L r_fin drl LMP p_TSO_fin p_fin reg_fin input_data A P_DR_resp P_DR_reb Tresp Treb voltages p_flow q_flow q_inj final_dispatch p_inj q_inj 
sup.l squp.l;

$ontext
execute 'gdxxrw.exe congestion_management_cqc.gdx par=reg_fin rng=sheet1!A1'
execute 'gdxxrw.exe congestion_management_cqc.gdx var=p_flow rng=sheet1!A9'
execute 'gdxxrw.exe congestion_management_cqc.gdx var=q_flow rng=sheet1!A23'
execute 'gdxxrw.exe congestion_management_cqc.gdx var=q_inj rng=sheet1!A35'
execute 'gdxxrw.exe congestion_management_cqc.gdx par=input_data rng=sheet1!A45'
execute 'gdxxrw.exe congestion_management_cqc.gdx par=voltages rng=sheet1!A60'
execute 'gdxxrw.exe congestion_management_cqc.gdx par=final_dispatch rng=sheet1!A70'
$offtext

execute 'gdxxrw.exe congestion_management_cqc.gdx par=reg_fin rng=sheet1!A1'
execute 'gdxxrw.exe congestion_management_cqc.gdx par=input_data rng=sheet1!A20'
execute 'gdxxrw.exe congestion_management_cqc.gdx par=voltages rng=sheet1!A40'
execute 'gdxxrw.exe congestion_management_cqc.gdx var=p_flow rng=sheet1!A80'
execute 'gdxxrw.exe congestion_management_cqc.gdx var=q_flow rng=sheet1!A160'
execute 'gdxxrw.exe congestion_management_cqc.gdx var=q_inj rng=sheet1!A240'
