

#!/bin/bash

set -x

psc_file="/tmp/psc.yaml"

# export kafka psc into a file
kubectl -n ${KFK} get psc -o yaml > ${psc_file}

# find the first line of timeout_seconds, and increment its value by 1
line_of_first_timeout=$(grep -n timeout_seconds /tmp/psc.yaml | grep -v apiVersion| head -1)
line_number=$(echo $line_of_first_timeout | cut -d: -f1)
old_value=$(echo $line_of_first_timeout | cut -d: -f3)
new_value=$(($old_value + 1))
sed -i.bu "${line_number}s/timeout_seconds:${old_value}/timeout_seconds: ${new_value}/g" ${psc_file}
echo "changed timeout_seconds value from ${old_value} to ${new_value}"

# apply the changed psc
kubectl -n ${KFK} apply -f ${psc_file}
echo "applied new psc for rolling kafka cluster: ${KFK}"

set +x

# Exit successfully
exit 0