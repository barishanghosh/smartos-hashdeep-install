/* SmartOS/Illumos assert.h workaround
 *
 * On SmartOS/Illumos with -D_FORTIFY_SOURCE=2, the assert macro
 * expands to call __assert() which isn't properly linked.
 * This provides a working assert implementation.
 *
 * NOTE: Like the system assert.h, this file intentionally does NOT have
 * include guards so it can be re-included after each <assert.h> inclusion.
 */

#include <stdio.h>
#include <stdlib.h>

#ifdef __sun
/* Undefine the broken assert from system assert.h */
#undef assert

/* Define a working assert for SmartOS/Illumos */
#ifdef NDEBUG
#define assert(x) ((void)0)
#else
#define assert(x) \
    ((void)((x) || \
     (fprintf(stderr, "Assertion failed: %s, file %s, line %d\n", \
              #x, __FILE__, __LINE__), \
      abort(), 0)))
#endif

#endif /* __sun */
