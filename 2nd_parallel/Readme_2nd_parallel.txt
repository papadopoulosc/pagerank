Papadopoulos Charalampos
HPC project update 2
Readme
*********************************************8

You must have the following modules loaded:
Currently Loaded Modulefiles:
1) gnu-4.4-compilers 2) fftw-3.3.3 3) platform-mpi
You then enter the 2nd_parallel folder and do:
>> make clean
>> make
The current bash script is named sub.bash and is configured to run with 8 processes.
You can then do:
>>bsub <sub.bash
After the job is complete you may see the results in results.txt
Alternatively, instead of doing bsub <sub.bash you can do:
>>./script
This script runs automatically the bsub.bash for 10 times and computes the average execution time, which is printed on the screen after 60 seconds of sleep time