#!/bin/sh
#BSUB -J Papadopoulos-hello
#BSUB -o output_file
#BSUB -e error_file
#BSUB -n 8 
#BSUB -q ht-10g


tempfile1=hostlistrun
tempfile2=hostlist-tcp
echo $LSB_MCPU_HOSTS > $tempfile1
declare -a hosts
read -a hosts < ${tempfile1}
for ((i=0; i<${#hosts[@]}; i += 2)) ;
  do
   HOST=${hosts[$i]}
   CORE=${hosts[(($i+1))]}
   echo $HOST:$CORE >> $tempfile2
done
#####################################################
#####
###DO NOT EDIT ANYTHING ABOVE THIS LINE#########
#####################################################

mpirun -np 8 -prot -TCP -lsf ./pagerank_mpi web-Google.txt 916428 0.0001 0.85 >>results.txt


