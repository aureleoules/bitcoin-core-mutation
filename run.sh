#!/bin/sh
set -e
cd bitcoin-core-mutation && \
    BITCOIN_CORE_PATH=/mutation/bitcoin python3 gen-mutators.py && \
    rm -rf /mutation/bitcoin/muts && \
    cp -r muts /mutation/bitcoin/muts

cd /mutation/bitcoin && analyze_mutants \
    $FILES_TO_MUTATE \
    "make -j$(nproc) && make check -j$(nproc) && ./test/functional/test_runner.py -F -j$(nproc)" \
    --mutantDir muts \
    --timeout 99999990 $OPTIONS
