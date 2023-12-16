
import os 
import subprocess

kafka_pod="kafka-3"
log_dir=f"/Users/fzheng/test-tmp/{kafka_pod}/"
tierstate_file="00000000000000000000.tierstate.adler"


current_dir=os.getcwd()
run_class="/Users/fzheng/github.com/zhengyd2014/ce-kafka/bin/kafka-run-class"

# List to store all  
# directories 
L = []

# print(f"start walk {log_dir}")
# Traversing through Test 
for root, dirs, files in os.walk(log_dir): 
    # Adding the empty directory to 
    # list 
    if (tierstate_file in files):
        L.append((root, dirs, files))

for f in L:
    root = f[0]
    directorys = root.split("/")
    d = directorys[len(directorys) - 1]

    dump_ftps_cmd = [run_class, "kafka.tier.tools.DumpTierPartitionState", f"{root}"]
    # print(f"rum cmd: {dump_ftps_cmd}")
    ftps = subprocess.run(dump_ftps_cmd, stdout=subprocess.PIPE, text=True)
    # print(type(ftps.stdout))
    outputArray = ftps.stdout.split("\n")
    # print(f"output: {outputArray}")

    if len(outputArray) > 3:
        header = outputArray[2]
    else:
        header = "No header"
    print(f"{kafka_pod} | {d} | {header}")

    