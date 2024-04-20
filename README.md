# vcpkg-scratch-win32

Here are my vcpkg scripts and ports.

I use them mainly for development under Cygwin+Win11, ie. works-for-me.

This vcpkg overlay repository mainly exists so I don't have to waste time
trying to get stuff into the main repo. Contribute if you like.

# WARNING

Use at your own risk. Threaded with a hot needle. Don't complain if a
stray rm -rf wipes your data. It's free, so ur also free to f off.

# LICENSE

Don't-care-license. Consider it public domain unless:

BUT BEWARE! Some of the ports may be based on stuff 'borrowed' from
https://github.com/Microsoft/vcpkg - so the licenses over there might apply.

vcpkg.sh and test_all.sh are definitely my own Frankstein creations, so
definitely public domain.

# vcpkg.sh

A wrapper for vcpkg.exe written for Cygwin BASH.

It allows you to declare vcpkg dependencies inside CMakeLists.txt files like:

```
# @VCPKGS:boost-algorithm,boost-dll,glad,glm,nanovg,pugl,utils,vstsdk@
```

Running it from a CMakeLists.txt-containing directory will pull vcpkgs ports
and try to build the project out-of-source. So it also solves that issue and
tries to make using cmake more convenient overall. Check the script for how
to set up.

# test_all.sh

Scans for CMakeLists.txt in subfolders of the current directory and runs vcpkg.sh
on them if the following tag is found:

```
# @TESTALL:ANY@
```

That allows to verify that a vcpkg upgrade is compatible with all tagged projects.
Set FAST=1 or FASTEST=1 to skip rebuilding packages or, additionally, even skip
a purge of the installed vcpkg packages before execution.

