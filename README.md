# hashdeep installation for SmartOS Global Zone (GZ)

This repository contains fixes for building and installing hashdeep on SmartOS Global Zone.

## The problems

hashdeep has four compilation issues on SmartOS/Illumos:

1. **Missing assert.h / __assert error**: On SmartOS with -D_FORTIFY_SOURCE=2, assert() expands to __assert() which isn't linked
2. **algorithm_t initialization**: The `algorithm_t` array cannot be default-constructed
3. **Strict compiler flags**: `-Weffc++` and `-Werror` treat style warnings as fatal errors
4. **C++11 literal spacing**: PRI macros (PRId64, PRIu64, etc.) need space before them in string literals

## Solution

1. Include smartos_assert.h workaround header that provides a working assert implementation
2. Initialize the `hashes` array with `= {}` syntax
3. Remove strict warning flags from the build configuration
4. Add spaces between string literals and PRI macros (e.g., `"%" PRId64` instead of `"%"PRId64`)

I do not knwo how to make patches, so I made short scripts instead.

## Installation

`install-hashdeep.sh` will git clone `hashdeep`, apply all fixes, and compile automatically:

### Steps

In a SmartOS Global Zone (GZ):

```
cd /opt
curl -L https://raw.githubusercontent.com/barishanghosh/smartos-hashdeep-install/master/install-hashdeep.sh | bash
```

This will clone `https://github.com/jessek/hashdeep.git`, apply the fixes and compile it.

Make sure to have all the pkgsrc tools available, including `gmake`, `gsed`, etc.

Note: I am quite new to SmartOS, `pkgsrc` and coding. but I would be happy to learn how to make a `pkgsrc` package from this.
