TARGET=$1
echo "Target chosen: " $TARGET

if [ "$TARGET" = "ALL" ]; then
    #Build aarch64 binaries
    make -f Makefile clean
    make -f Makefile ARCH=arm64

    mv hashBench.elf $(pwd)/binaries/hashBench.arm64.elf
    echo "Completed building arm64 elf"
fi
