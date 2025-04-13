#include "hello.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    const char *name = argc > 1 ? argv[1] : "World";

    hello(name);

    int result = add(5, 7);
    printf("5 + 7 = %d\n", result);

    return EXIT_SUCCESS;
}