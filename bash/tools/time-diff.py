
import sys
import datetime
print (sys.argv)


# time1="Apr 4, 2023 @ 00:17:48.243"
# time2="Apr 4, 2023 @ 00:23:55.451"

input_file="/tmp/input-timestamp.txt"

time1 = None
time2 = None

def convert_to_timestamp(date_str):
    dt = datetime.datetime.strptime(date_str, '%b %d, %Y @ %H:%M:%S.%f')
    return int(dt.timestamp() * 1000)

print(f"open file: {input_file}")
with open(input_file) as f:
    for line in f.readlines():
        print(f"read {line}")
        time1 = time2
        time2 = line.strip()
        
        if time1 is not None:
            timestamp1 = convert_to_timestamp(time1)
            timestamp2 = convert_to_timestamp(time2)
            print (f"time1: {timestamp1}, time2 : {timestamp2}, diff: {timestamp2 - timestamp1}")



