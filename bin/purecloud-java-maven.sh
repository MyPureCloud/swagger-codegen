#!/bin/sh

# Delete output dir
rm -rf dists/purecloud/java

SCRIPT="$0"

while [ -h "$SCRIPT" ] ; do
  ls=`ls -ld "$SCRIPT"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    SCRIPT="$link"
  else
    SCRIPT=`dirname "$SCRIPT"`/"$link"
  fi
done

if [ ! -d "${APP_DIR}" ]; then
  APP_DIR=`dirname "$SCRIPT"`/..
  APP_DIR=`cd "${APP_DIR}"; pwd`
fi

executable="./modules/swagger-codegen-cli/target/swagger-codegen-cli.jar"

if [ ! -f "$executable" ]
then
  mvn clean package
fi

rm -rf dists/purecloud/java
mkdir -p dists/purecloud/java/src/main/java/com/mypurecloud/sdk/

cp -R /git/sdkv1/purecloud_api_sdk_common/resources/sdk/purecloudjava/extensions/ dists/purecloud/java/src/main/java/com/mypurecloud/sdk

# if you've executed sbt assembly previously it will use that instead.
export JAVA_OPTS="${JAVA_OPTS} -XX:MaxPermSize=256M -Xmx1024M -DloggerPath=conf/log4j.properties"
ags="$@ generate -i https://api.mypurecloud.com/api/v2/docs/swagger -l purecloudjava -o dists/purecloud/java -c bin/config/purecloud-java.json -t /git/sdkv1/purecloud_api_sdk_common/resources/sdk/purecloudjava/templates"

java $JAVA_OPTS -jar $executable $ags

# Set directory to output
cd dists/purecloud/java

# Compile
mvn package

# Sign
#mvn verify -Dgpg.passphrase=XXXX

# This will package, verify, and deploy to sonatype
#mvn deploy