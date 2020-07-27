#!/bin/bash

#
# Properly tunes a Minecraft server to run efficiently under the
# OpenJ9 (https://www.eclipse.org/openj9) JVM and other YAPFA Stuff.
#
# Licensed under the MIT license.
#
#

## BEGIN CONFIGURATION

# HEAP_SIZE: This is how much heap (in MB) you plan to allocate
#            to your server. By default, this is set to 4096MB,
#            or 4GB.
HEAP_SIZE=$1

# JAR_NAME:  The name of your server's JAR file.
JAR_NAME=$2
## END CONFIGURATION -- DON'T TOUCH ANYTHING BELOW THIS LINE!
echo "Downloading latest script. This will be used next launch."
curl https://raw.githubusercontent.com/budgidiere/yapfa-egg/master/start.sh > start.sh

echo "Downloading latest jar. This will be used this launch."
rm yapfa*.jar
curl -s https://api.github.com/repos/jgm/pandoc/releases/latest \
| grep "YAPFA-1.16.1-JDK14-*.jar" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -
mv YAPFA-1.16.1-JDK14-*.jar $JAR_NAME

## BEGIN SCRIPT

# Compute the nursery size.
NURSERY_MINIMUM=$(($HEAP_SIZE / 2))
NURSERY_MAXIMUM=$(($HEAP_SIZE * 4 / 5))

# Launch the server.
if [ 24576 < $HEAP_SIZE ]
then
	CMD="java -Xms${HEAP}M -Xmx${HEAP}M -Xmns${NURSERY_MIN}M -Xmnx${NURSERY_MAX}M -Xgc:concurrentScavenge -Xgc:dnssExpectedTimeRatioMaximum=3 -Xgc:scvNoAdaptiveTenure -Xdisableexplicitgc -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:-UseParallelGC -XX:+IgnoreUnrecognizedVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+UseGCOverheadLimit -XX:+ParallelRefProcEnabled -XX:-OmitStackTraceInFastThrow -XX:+ShowCodeDetailsInExceptionMessages -XX:+AlwaysPreTouch -XX:+UseAdaptiveGCBoundary -XX:-DontCompileHugeMethods -XX:+TrustFinalNonStaticFields -XX:+UseFastUnorderedTimeStamps -XX:+UseTransparentHugePages -XX:+UseLargePagesInMetaspace -XX:LargePageSizeInBytes=2M -XX:+UseLargePages -Xjit:enableGPU -Xshareclasses -XX:-IgnoreUnrecognizedXXColonOptions -Xnocompressedrefs -jar ${JAR_NAME} -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -Dibm.gpu.enable=all -Dibm.gpu.verbose=true -Dterminal.jline=false -Dterminal.ansi=true"
fi
if [ 24576 > $HEAP_SIZE ]
then
	CMD="java -Xms${HEAP}M -Xmx${HEAP}M -Xmns${NURSERY_MIN}M -Xmnx${NURSERY_MAX}M -Xgc:concurrentScavenge -Xgc:dnssExpectedTimeRatioMaximum=3 -Xgc:scvNoAdaptiveTenure -Xdisableexplicitgc -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:-UseParallelGC -XX:+IgnoreUnrecognizedVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+UseGCOverheadLimit -XX:+ParallelRefProcEnabled -XX:-OmitStackTraceInFastThrow -XX:+ShowCodeDetailsInExceptionMessages -XX:+AlwaysPreTouch -XX:+UseAdaptiveGCBoundary -XX:-DontCompileHugeMethods -XX:+TrustFinalNonStaticFields -XX:+UseFastUnorderedTimeStamps -XX:+UseTransparentHugePages -XX:+UseLargePagesInMetaspace -XX:LargePageSizeInBytes=2M -XX:+UseLargePages -Xjit:enableGPU -Xshareclasses -XX:-IgnoreUnrecognizedXXColonOptions -Xcompressedrefs -jar ${JAR_NAME} -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -Dibm.gpu.enable=all -Dibm.gpu.verbose=true -Dterminal.jline=false -Dterminal.ansi=true"
fi
echo "Checking CUDA version and host GPU."
nvcc --version | exit 0
nvidia-smi | exit 0
echo "Launching YAPFA with command line: ${CMD}"
${CMD}

## END SCRIPT