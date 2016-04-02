all: pagerank_mpi.cpp
	mpiCC -o pagerank_mpi pagerank_mpi.cpp 

clean:
	rm *~ times.txt results.txt mpi_output_file mpi_error_file hostlist* results pagerank_mpi output_file error_file core*


