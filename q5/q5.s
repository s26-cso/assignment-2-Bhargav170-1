#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

typedef struct
{
    char operation_name[10];
    void *library_in_cache;
    int (*func)(int, int); //function pointer :)
} Cache;

Cache cache[1];
int cache_size = 0;

int main()
{
    char operation_name[10];
    int num1, num2;

    while (scanf("%s %d %d", operation_name, &num1, &num2) == 3)
    {

        // construct library name
        char libname[20] = "./lib";   //it will reach a maximum of 15 characters (6 for lib 5 for operation_name 3 for .so and null treminator).
        strcat(libname, operation_name);
        strcat(libname, ".so");

        int found = -1;

        for (int i = 0; i < cache_size; i++)
        {
            if (strcmp(cache[i].operation_name, operation_name) == 0)
            {
                found = i;
                break;
            }
        }

        if (found != -1)
        {
            int result = cache[found].func(num1, num2);
            printf("%d\n", result);
            continue;
        }
        if (cache_size == 1)
        {
            dlclose(cache[0].library_in_cache);
            cache_size = 0;
        }

        // load library
        void *library_in_cache = dlopen(libname, RTLD_LAZY);

        //  get function pointer
        int (*func)(int, int);
        *(void **)(&func) = dlsym(library_in_cache, operation_name);

        strcpy(cache[cache_size].operation_name, operation_name);
        cache[cache_size].library_in_cache = library_in_cache;
        cache[cache_size].func = func;
        cache_size++;

        //call function
        int result = func(num1, num2);

        //print result
        printf("%d\n", result);
    }

    //close library
    for (int i = 0; i < cache_size; i++)
    {
        dlclose(cache[i].library_in_cache);
    }

    // Initially, the cache was designed to hold multiple libraries simultaneously. However, due to memory constraints, it was modified to store only one library at a time. The structure still supports extending it back to a multi-cache system if constraints are relaxed.
    // Caching of a single file have been used to avoid memory loss due to reopening a file multipple times, and at the same time maintain the memory limitt of 2GB. (2*1.5=3GB space will be taken up if cache sttores 2 open file at the same time).
    
    /*Control flow for the program: input-> check cache-> if found (use)-> loop continues-> close all.
                                                                | Else
                                                                V
                                                            dlopen - dlsym - store in cache - use   */

    return 0;
}
