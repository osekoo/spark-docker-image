#!/bin/bash

if [ "${SPARK_MODE}" == "master" ]; then
  ${SPARK_HOME}/sbin/start-master.sh

elif [ "${SPARK_MODE}" == "worker" ]; then
  ${SPARK_HOME}/sbin/start-worker.sh "$SPARK_MASTER_URL" && wait

elif [ "${SPARK_MODE}" == "client" ]; then
  cd /app || exit

  if [ "$APP_SBT_BUILD" == "true" ]; then
    if [ "$APP_SBT_CLEAN" == "true" ]; then
      rm -rf /app/target
      rm -rf /app/project/target
      sbt clean
    fi
    sbt package
  fi

  if [ "$APP_DEPLOY_MODE" == "" ]; then
    APP_DEPLOY_MODE=client
  fi

  ${SPARK_HOME}/bin/spark-submit \
                      --deploy-mode "$APP_DEPLOY_MODE" \
                      --master "$SPARK_MASTER_URL" \
                      --executor-cores "$SPARK_WORKER_CORES" \
                      --executor-memory "$SPARK_WORKER_MEMORY" \
                      --num-executors "$SPARK_WORKERS" \
                      --packages "$APP_DEPENDENCIES" \
                      --jars "$APP_JARS" \
                      --files "$APP_FILES" \
                      --class "$APP_CLASS" \
                      "$APP_PACKAGE" \
                      "$APP_ARGS"

else
  echo "Undefined spark mode '${SPARK_MODE}'"
fi
