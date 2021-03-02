#!/bin/bash
file=$1
host_ksql=$2
echo -e "\n\n⏳ Waiting for ksqlDB to be available before launching CLI\n"
while [ $(curl -s -o /dev/null -w %{http_code} http://'$host_ksql'8088/) -eq 000 ]
do
  echo -e $(date) "ksqlDB Server HTTP state: " $(curl -s -o /dev/null -w %{http_code} http://'$host_ksql':8088/) " (waiting for 200)"
  sleep 5
done

tr '\n' ' ' < $file | \
sed 's/;/;\'$'\n''/g' | \
while read stmt; do
    echo '{"ksql":"'$stmt'", "streamsProperties": {}}' | \
        curl -s -X "POST" "http://'$host_ksql':8088/ksql" \
             -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
             -d @- | \
        jq
done
