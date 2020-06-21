#!/bin/sh
#BSUB -J 37bus_cqc
#BSUB -q elektro
#BSUB -n 20
#BSUB -R "rusage[mem=8GB]"
#BSUB -M 250GB
#BSUB -W 24:00
#BSUB -u alherm@elektro.dtu.dk
#BSUB -B
#BSUB -N
#BSUB -o output_alex_run1.out
#BSUB -e error_alex_run1.err
#BSUB -R "span[hosts=1]"

gams congestion_market_quadratic_opf_branchflowgms.gms threads=$LSB_DJOB_NUMPROC save=run3