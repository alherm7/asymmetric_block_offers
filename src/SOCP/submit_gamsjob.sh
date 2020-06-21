#!/bin/sh
#BSUB -J 37bus_SOCP
#BSUB -q elektro
#BSUB -n 20
#BSUB -R "rusage[mem=8GB]"
#BSUB -M 250GB
#BSUB -W 45:00
#BSUB -u alherm@elektro.dtu.dk
#BSUB -B
#BSUB -N
#BSUB -o output_alex_run1.out
#BSUB -e error_alex_run1.err
#BSUB -R "span[hosts=1]"


/appl/gams/25.0.3/gams congestion_market_SOCP.gms --FileName=37bus_IEEE_linedata_48timesteps_8offers_4units.gms --gdxFileName="48step_8offer_sol" threads=$LSB_DJOB_NUMPROC save=run9
/appl/gams/25.0.3/gams congestion_market_SOCP.gms --FileName=37bus_IEEE_linedata_48timesteps_5offers_4units.gms --gdxFileName="48step_5offer_sol" threads=$LSB_DJOB_NUMPROC save=run10
/appl/gams/25.0.3/gams congestion_market_SOCP.gms --FileName=37bus_IEEE_linedata_48timesteps_4offers_4units.gms --gdxFileName="48step_4offer_sol" threads=$LSB_DJOB_NUMPROC save=run11
/appl/gams/25.0.3/gams congestion_market_SOCP.gms --FileName=37bus_IEEE_linedata_48timesteps_3offers_4units.gms --gdxFileName="48step_3offer_sol" threads=$LSB_DJOB_NUMPROC save=run12

/appl/gams/25.0.3/gams congestion_market_SOCP.gms --FileName=37bus_IEEE_linedata_35timesteps_8offers_4units.gms --gdxFileName="35step_8offer_sol" threads=$LSB_DJOB_NUMPROC save=run9
/appl/gams/25.0.3/gams congestion_market_SOCP.gms --FileName=37bus_IEEE_linedata_35timesteps_5offers_4units.gms --gdxFileName="35step_5offer_sol" threads=$LSB_DJOB_NUMPROC save=run10
/appl/gams/25.0.3/gams congestion_market_SOCP.gms --FileName=37bus_IEEE_linedata_35timesteps_4offers_4units.gms --gdxFileName="35step_4offer_sol" threads=$LSB_DJOB_NUMPROC save=run11
/appl/gams/25.0.3/gams congestion_market_SOCP.gms --FileName=37bus_IEEE_linedata_35timesteps_3offers_4units.gms --gdxFileName="35step_3offer_sol" threads=$LSB_DJOB_NUMPROC save=run12

/appl/gams/25.0.3/gams congestion_market_SOCP.gms --FileName=37bus_IEEE_linedata_24timesteps_8offers_4units.gms --gdxFileName="24step_8offer_sol" threads=$LSB_DJOB_NUMPROC save=run9
/appl/gams/25.0.3/gams congestion_market_SOCP.gms --FileName=37bus_IEEE_linedata_24timesteps_5offers_4units.gms --gdxFileName="24step_5offer_sol" threads=$LSB_DJOB_NUMPROC save=run10
/appl/gams/25.0.3/gams congestion_market_SOCP.gms --FileName=37bus_IEEE_linedata_24timesteps_4offers_4units.gms --gdxFileName="24step_4offer_sol" threads=$LSB_DJOB_NUMPROC save=run11
/appl/gams/25.0.3/gams congestion_market_SOCP.gms --FileName=37bus_IEEE_linedata_24timesteps_3offers_4units.gms --gdxFileName="24step_3offer_sol" threads=$LSB_DJOB_NUMPROC save=run12