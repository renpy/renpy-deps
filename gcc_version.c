/* Test for GCC > 3.2.0 */
#if __GNUC__ > 4 || (__GNUC__ == 4 && (__GNUC_MINOR__ >=1 ))
#define OK
#else
#error GCC is older than version 4.1
#endif

