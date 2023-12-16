
import os 

# log_dir="/tmp"
# target_file="00000000000000000000.log"

log_dir="/mnt/data/data0/logs"
target_file="00000000000000000000.tierstate.adler"
#target_file="00000000000000000000.tierstate.mutable.adler"


current_dir=os.getcwd()

# List to store all  
# directories 
L = []
    
# Traversing through Test 
for root, dirs, files in os.walk(log_dir): 
    
    # Adding the empty directory to 
    # list 
    if (target_file in files):
        L.append((root, dirs, files))


print("List of all sub-directories and files:") 
for f in L:
    root = f[0]
    directorys = root.split("/")
    d = directorys[len(directorys) - 1]

    # run mkdir cmd
    mkdir_cmd=f"mkdir {d}"
    print(mkdir_cmd)
    os.system(mkdir_cmd)

    # run cp file cmd
    cp_cmd = f"cp {root}/{target_file} {current_dir}/{d}/{target_file}"
    print(cp_cmd)
    os.system(cp_cmd)

