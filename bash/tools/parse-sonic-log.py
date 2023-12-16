

import argparse
import re

# example input:
# start_timestamp = 1681842588626
# filename = "/Users/fzheng/Downloads/On_demand_report_2023-04-18T18_45_44.744Z_3a070280-de19-11ed-827f-cdee1442a4a8.csv"

def extract_timestamp(start_ts, filename):
    with open(filename, 'r') as f:
        for line in f:
            m = re.search(r'timestamp:(\d+)', line)
            if m:
                timestamp = int(m.group(1))
                diff = timestamp - start_ts
                print(f"{diff} ms - {line.strip()}")


def parse_args():
    parser = argparse.ArgumentParser(description='Parse log file')
    parser.add_argument('start_timestamp', type=int, help='Start timestamp')
    parser.add_argument('filename', type=str, help='Log file')
    return parser.parse_args()

if __name__ == '__main__':
    args = parse_args()
    extract_timestamp(args.start_timestamp, args.filename)





