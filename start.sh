#
# Properly tunes a Minecraft server to run efficiently under the
# OpenJ9 (https://www.eclipse.org/openj9) JVM and other YAPFA Stuff.
#
# Licensed under the MIT license.
#
#
function memory_limit
{
  awk -F: '/^[0-9]+:memory:/ {
    filepath="/sys/fs/cgroup/memory"$3"/memory.limit_in_bytes";
    getline line < filepath;
    print line
  }' /proc/self/cgroup
}
## BEGIN CONFIGURATION

# HEAP_SIZE: This is how much heap (in MB) you plan to allocate
#            to your server. By default, this is set to 4096MB,
#            or 4GB.
#MEM_TOTAL=$(awk -F":" '$1~/MemTotal/{print $2}' /proc/meminfo )
#MEM_TOTALLE=${MEM_TOTAL::-3}
MEM_TOTALMB=$(($(memory_limit) / 1000))
HEAP_SIZE=$(($MEM_TOTALMB * 90 / 100))

# JAR_NAME:  The name of your server's JAR file.
JAR_NAME=yapfa.jar
## END CONFIGURATION -- DON'T TOUCH ANYTHING BELOW THIS LINE!
echo "Downloading latest script. This will be used next launch."
wget -N https://raw.githubusercontent.com/budgidiere/yapfa-egg/master/start.sh


echo "Downloading latest jar. This will be used this launch."
#rm $JAR_NAME
wget -N https://github.com/USER/PROJECT/releases/latest/download/YAPFA-1.16.1-JDK14-paperclip.jar -o $JAR_NAME

## BEGIN SCRIPT

# Compute the nursery size.
NURSERY_MINIMUM=$(($HEAP_SIZE / 2))
NURSERY_MAXIMUM=$(($HEAP_SIZE * 4 / 5))

# Launch the server.
if [ 24576 < $HEAP_SIZE ]
then
	CMD="java -Xms${HEAP_SIZE}M -Xmx${HEAP_SIZE}M -Xmns${NURSERY_MINIMUM}M -Xmnx${NURSERY_MAXIMUM}M -Xgc:concurrentScavenge -Xgc:dnssExpectedTimeRatioMaximum=3 -Xgc:scvNoAdaptiveTenure -Xdisableexplicitgc -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:-UseParallelGC -XX:+IgnoreUnrecognizedVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+UseGCOverheadLimit -XX:+ParallelRefProcEnabled -XX:-OmitStackTraceInFastThrow -XX:+ShowCodeDetailsInExceptionMessages -XX:+AlwaysPreTouch -XX:+UseAdaptiveGCBoundary -XX:-DontCompileHugeMethods -XX:+TrustFinalNonStaticFields -XX:+UseFastUnorderedTimeStamps -XX:+UseTransparentHugePages -XX:+UseLargePagesInMetaspace -XX:LargePageSizeInBytes=2M -XX:+UseLargePages -Xjit:enableGPU -Xshareclasses -XX:-IgnoreUnrecognizedXXColonOptions -Xnocompressedrefs -jar ${JAR_NAME} -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -Dibm.gpu.enable=all -Dibm.gpu.verbose=true -Dterminal.jline=false -Dterminal.ansi=true"
fi
if [ 24576 > $HEAP_SIZE ]
then
	CMD="java -Xms${HEAP_SIZE}M -Xmx${HEAP_SIZE}M -Xmns${NURSERY_MINIMUM}M -Xmnx${NURSERY_MAXIMUM}M -Xgc:concurrentScavenge -Xgc:dnssExpectedTimeRatioMaximum=3 -Xgc:scvNoAdaptiveTenure -Xdisableexplicitgc -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:-UseParallelGC -XX:+IgnoreUnrecognizedVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+UseGCOverheadLimit -XX:+ParallelRefProcEnabled -XX:-OmitStackTraceInFastThrow -XX:+ShowCodeDetailsInExceptionMessages -XX:+AlwaysPreTouch -XX:+UseAdaptiveGCBoundary -XX:-DontCompileHugeMethods -XX:+TrustFinalNonStaticFields -XX:+UseFastUnorderedTimeStamps -XX:+UseTransparentHugePages -XX:+UseLargePagesInMetaspace -XX:LargePageSizeInBytes=2M -XX:+UseLargePages -Xjit:enableGPU -Xshareclasses -XX:-IgnoreUnrecognizedXXColonOptions -Xcompressedrefs -jar ${JAR_NAME} -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -Dibm.gpu.enable=all -Dibm.gpu.verbose=true -Dterminal.jline=false -Dterminal.ansi=true"
fi
echo "Checking CUDA version and host GPU."
nvcc --version | echo "Error checking CUDA version."
nvidia-smi | echo "Error checking GPU"
echo "Launching YAPFA with command line: ${CMD}"
${CMD}

## END SCRIPT
