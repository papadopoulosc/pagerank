#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <time.h>
#include "util.h"
//#include "mpi.h"
#include <stddef.h>
#include <string.h>
#include "pagerank_serial.h"
#include <mpi.h>
#include <math.h>
#include <assert.h>
#include <string.h>



typedef struct Foo {
    int a;
    int *b;
    int *c;
} Foo;

int main( int argc, char *argv[] ) {
    MPI_Init( &argc, &argv );
    int rank, size;
    MPI_Comm_rank( MPI_COMM_WORLD, &rank );
    MPI_Comm_size( MPI_COMM_WORLD, &size );

    int len = 3;
    Foo *array = (Foo *) malloc( len * sizeof( Foo ) );
    // let's assume for simplicity that each process already knows the sizes of the individual arrays (it would need to be transmitted otherwise)
    int lenB[] = { 1, 2, 3 };
    int lenC[] = { 5, 6, 7 };
    // now we create the data for the arrays
    int lenAllBs = 0, lenAllCs = 0;
    for ( int i = 0; i < len; i++ ) {
        lenAllBs += lenB[i];
        lenAllCs += lenC[i];
    }
    int *BandC = (int *)malloc( ( lenAllBs + lenAllCs ) * sizeof( int ) );
    // And we adjust the pointers
    array[0].b = BandC;
    array[0].c = BandC + lenAllBs;
    for ( int i = 1; i < len; i++ ) {
        array[i].b = array[i-1].b + lenB[i];
        array[i].c = array[i-1].c + lenC[i];
    }

    // Now we create the MPI structured type for Foo. Here a resized will suffice
    MPI_Datatype mpiFoo;
    MPI_Type_create_resized( MPI_INT, 0, sizeof( Foo ), &mpiFoo );
    MPI_Type_commit( &mpiFoo );

    // Ok, the preparation phase was long, but here comes the actual transfer
    if ( rank == 0 ) {
        // Only rank 0 has some meaningful data
        for ( int i = 0; i < len; i++ ) {
            array[i].a = i;
            for ( int j = 0; j < lenB[i]; j++ ) {
                array[i].b[j] = 10 * i + j;
            }
            for ( int j = 0; j < lenC[i]; j++ ) {
                array[i].c[j] = 100 * i + j;
            }
        }
        // Sending it to rank size-1
        // First the structure shells
        MPI_Send( array, len, mpiFoo, size - 1, 0, MPI_COMM_WORLD );
        // Then the pointed data
        MPI_Send( BandC, lenAllBs + lenAllCs, MPI_INT, size - 1, 0, MPI_COMM_WORLD );
    }
    if ( rank == size - 1 ) {
        // Receiving from 0
        // First the structure shells
        MPI_Recv( array, len, mpiFoo, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE );
        // Then the actual data
        MPI_Recv( BandC, lenAllBs + lenAllCs, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE );
        // And printing some
        printf( "array[1].a = %d, array[2].b[1] = %d, array[0].c[4]=%d\n", array[1].a, array[2].b[1], array[0].c[4] );
    }

    MPI_Type_free( &mpiFoo );
    free( BandC );
    free( array );

    MPI_Finalize();
    return 0;
}
