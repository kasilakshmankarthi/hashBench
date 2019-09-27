ARCH=$1
DEV=$2
CORE=$3

echo "ARCH" $ARCH
echo  "DEVICE" $DEV
echo "CORE" $CORE

adb push ../binaries/hashBench.${ARCH}.elf /data/local/tmp/
adb shell chmod +x /data/local/tmp/hashBench.${ARCH}.elf

adb push envSetup.sh /data/local/tmp/
adb shell chmod +x /data/local/tmp/envSetup.sh
adb shell "su -c /data/local/tmp/envSetup.sh $DEV"

if [[ ${DEV} == "universal" || ${DEV} == "smdk" ]]; then
  if [[ ${CORE} == "big" ]]; then
     ###Cheetah
     freq=2470000
     cpu=6
  elif [[ ${CORE} == "medium" ]]; then
     freq=2314000
     cpu=5
  else
     freq=1950000
     cpu=0
  fi
fi

if [[ ${DEV} == "sd845" ]]; then
  if [[ ${CORE} == "big" ]]; then
     freq=2476800
     cpu=6
  elif [[ ${CORE} == "small" ]]; then
     freq=1766400
     cpu=0
  else
    echo "Not supported core: " ${CORE}
    exit
  fi
fi

if [[ ${DEV} == "mate20" ]]; then
  ###To push the A76 (plus) to 2.6GHz
  ###Push these to the device:
  adb push /sarc-c/spa_secondary/workloads/Geekbenchv5/5.0.0-Drop12/universal/v1/aarch64/geekbench.plar /data/local/tmp
  adb push /sarc-c/spa_secondary/workloads/Geekbenchv5/5.0.0-Drop12/universal/v1/aarch64/geekbench_aarch64 /data/local/tmp
  adb push /sarc-c/spa_secondary/workloads/Geekbenchv5/5.0.0-Drop12/universal/v1/aarch64/libstingray.so /data/local/tmp

  adb shell chmod +x /data/local/tmp/geekbench_aarch64

  if [[ ${CORE} == "big" ]]; then
    freq=2600000
    cpu=6

    ######Run a subtest (101.AES) on CPU6 for a long time (10k iterations):
    adb shell LD_LIBRARY_PATH=/data/local/tmp/ taskset -a 80 /data/local/tmp/geekbench_aarch64 --section 1 --workload 101 --iterations 10000&
    sleep 10
  elif [[ ${CORE} == "small" ]]; then
    freq=1805000
    cpu=0

    #####Run a subtest (101.AES) on CPU2-3 for a long time (10k iterations):
    adb shell LD_LIBRARY_PATH=/data/local/tmp/ taskset -a 0C /data/local/tmp/geekbench_aarch64 --section 1 --workload 101 --iterations 10000&
    sleep 10
  else
    echo "Not supported core: " ${CORE}
    exit
  fi
fi

rm -rf cpiter_*${CORE}.score

sizes=(
  "256"
  "128"
  "64"
  "42"
  "38"
  "32"
  "24"
  "16"
  "12"
  "8"
  "4"
  "2"
  "1"
)

adb shell "echo Running at freq: ${freq}"

for sz in ${sizes[@]}
do
  adb shell /data/local/tmp/hashBench.${ARCH}.elf --buff_sz ${sz} --cpu_to_lock ${cpu} --locked_freq ${freq} > cpiter_${DEV}_${sz}B_${CORE}.score

  ###Parse and show the results
  #grep "useconds_per_iteration" c*${DEV}_${CORE}.score | grep -Eo '.*:'
  grep  "cycles_per_iteration" c*${DEV}_${sz}B_${CORE}.score | grep -Eo '[0-9]*\.[0-9]*'
  echo "--------------------------"
done

if [[ ${DEV} == "mate20" ]]; then
    adb shell "su -c pkill -9 -f 'geekbench*'"
fi
