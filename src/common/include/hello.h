#ifndef HELLO_H
#define HELLO_H

#ifdef __cplusplus
extern "C" {
#endif
    /**
     * Print a hello message
     * @param name Name to greet
     */
    void hello(const char *name);

    /**
     * Add two numbers (simple function for testing)
     * @param a First number
     * @param b Second number
     * @return Sum of a and b
     */
    int add(int a, int b);

#ifdef __cplusplus
}
#endif

#endif /* HELLO_H */