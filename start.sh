#!/bin/bash

#
# Properly tunes a Minecraft server to run efficiently under the
# OpenJ9 (https://www.eclipse.org/openj9) JVM.
#
# Licensed under the MIT license.
#
#
rm yapfa*.jar
curl -s https://api.github.com/repos/jgm/pandoc/releases/latest \
| grep "YAPFA-1.16.1-JDK14-*.jar" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -
mv YAPFA-1.16.1-JDK14-*.jar yapfa.jar
## BEGIN CONFIGURATION

# HEAP_SIZE: This is how much heap (in MB) you plan to allocate
#            to your server. By default, this is set to 4096MB,
#            or 4GB.
HEAP_SIZE=4096

# JAR_NAME:  The name of your server's JAR file. The default is
#            "paperclip.jar".
#
#            Side note: if you're not using Paper (http://papermc.io),
#            then you should really switch.
JAR_NAME=yapfa.jar

## END CONFIGURATION -- DON'T TOUCH ANYTHING BELOW THIS LINE!

## BEGIN SCRIPT

# Compute the nursery size.
NURSERY_MINIMUM=$(($HEAP_SIZE / 2))
NURSERY_MAXIMUM=$(($HEAP_SIZE * 4 / 5))

# Launch the server.
CMD="java -Xms${HEAP}M -Xmx${HEAP}M -Xmns${NURSERY_MIN}M -Xmnx${NURSERY_MAX}M -Xgc:concurrentScavenge -Xgc:dnssExpectedTimeRatioMaximum=3 -Xgc:scvNoAdaptiveTenure -Xdisableexplicitgc -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:-UseParallelGC -XX:-UseParallelOldGC -XX:-UseG1GC -XX:+UseZGC -XX:+IgnoreUnrecognizedVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+UseGCOverheadLimit -XX:+ParallelRefProcEnabled -XX:-OmitStackTraceInFastThrow -XX:+ShowCodeDetailsInExceptionMessages -XX:+UseCompressedOops -XX:+AlwaysPreTouch -XX:+UseAdaptiveGCBoundary -XX:-DontCompileHugeMethods -XX:+TrustFinalNonStaticFields -XX:+UseFastUnorderedTimeStamps -XX:+UseTransparentHugePages -XX:+UseLargePagesInMetaspace -XX:LargePageSizeInBytes=2M -XX:+UseLargePages -XX:-ZUncommit -XX:ZUncommitDelay=5 -XX:+ZCollectionInterval=5 -XX:ZAllocationSpikeTolerance=2.0 -Xjit:enableGPU -jar ${JAR_NAME} -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -Dibm.gpu.enable=all -Dibm.gpu.verbose=true"
echo "launching YAPFA with command line: ${CMD}"
${CMD}

## END SCRIPT