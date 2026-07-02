#!/bin/bash

echo Now patching codex
$PREFIX/bin/patchelf --set-rpath $PREFIX/x86_64-conda-linux-gnu/sysroot/lib64/:$PREFIX/x86_64-conda-linux-gnu/sysroot/usr/lib64  $PREFIX/bin/codex
$PREFIX/bin/patchelf --set-interpreter $PREFIX/x86_64-conda-linux-gnu/sysroot/lib64/ld-linux-x86-64.so.2 $PREFIX/bin/codex
echo Finished patching codex
