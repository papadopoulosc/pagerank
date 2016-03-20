CC = gcc
FLG = -O4
NAME = pagerank_openmp

pagerank_serial: pagerank_openmp.c pagerank_serial.h

	$(CC) pagerank_openmp.c -fopenmp -lm -o $(NAME)

clean:
	rm -f *.o *.out *.exe
	rm -f *.bin
