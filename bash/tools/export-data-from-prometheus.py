import csv
import requests
from datetime import datetime
import sys


url="http://3.144.1.128:9090/api/v1/query_range?query=kafka_network_requestmetrics_99thpercentile{request=%22Produce%22,name=%22TotalTimeMs%22}&start=2023-12-04T21:50:00.000Z&end=2023-12-04T23:10:00.000Z&step=30"


"""
Prometheus hourly data as csv.
"""
writer = csv.writer(sys.stdout, delimiter=";")

#now its hardcoded for hourly
response = requests.get(url)
results = response.json()['data']['result']

for result in results:

    # Build a list of all labelnames used.
    title = ''
    metric = result['metric']
    last_label = "instance"
    for label in metric:
        if label is not last_label:
            title = title + label + ":" + metric[label] + ","
    
    title = title + last_label + ":" + metric[last_label]

    # writer.writerow(['timestamp', 'value'])

    str_new = str(result['values']).replace("[", "").replace("]", "")
    value_array = str_new.split(",")
    index = 0
    while index < len(value_array) - 1:
        subl = []
        ts_value = value_array[index]
        t = datetime.utcfromtimestamp(float(ts_value))
        metric_value = value_array[index +1].replace('\'', "").replace("u", "").strip()
        index += 2
        subl.append(title)
        subl.append(t.strftime("%Y-%m-%dT%H:%M:%S"))
        subl.append(metric_value)
        writer.writerow(subl)






