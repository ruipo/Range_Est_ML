
# coding: utf-8

# In[ ]:


# Make and run OASM files for varying discrete source locations. 
# To Do: define bottom paramters and intervals
#        define outFileName
#        define water sound speed layers
#        input settings for each block


import numpy as np
import types
import os
import subprocess
import time
import random


# define options
options = 'B M Q D'

# define frequencies
freqs = np.array([850,850,1,0]) # [min freq, max freq, # of freqs, integration contour offset]

# define array
arrayfile="ICEX_32array.csv"

array = np.loadtxt(arrayfile, delimiter=",") # import array geometry from file

array_temp1 = [int(inc) for inc in array[:,3]]
array_temp2 = [int(inc) for inc in array[:,4]]

arr = np.ndarray(array.shape,dtype = object)
arr[:,0:3] = array[:,0:3]
arr[:,3] = array_temp1
arr[:,4] = array_temp2

    
# define signal replicas  


reps = types.SimpleNamespace()

reps.zs = np.array([1.26,1.26,1]) # depths of sampling of replicas
reps.xs = np.array([3,50,95]) # x-coord of sampling (0.0625 spacing)
reps.ys = np.array([0,0,1]) # y-coord of sampling

ii = 0

# define function to write a line
def line(var):
    s = ''
    for ii in range(len(var)):
        sii = '{'+str(ii)+'} '
        s = ''.join([s,sii])
    return s[0:-1].format(*var)


### start writing input files
allDirs = []
      
outFileName = 'ICEX_32array_oasm.dat'

if not os.path.isdir(outFileName[0:-4]):
    os.mkdir(outFileName[0:-4])
    
    allDirs.append(outFileName[0:-4])
    
    outFile = open(outFileName[0:-4] + '/' + outFileName, 'w')
    
    # Begin writing file:
    
    # Block 1: Title
    
    outFile.write(outFileName[0:-4] + '\n')
    
    # Block 2: Options
    
    outFile.write(options + '\n')

    # Block 3: Frequencies

    outFile.write(line(freqs) + '\n')

    outFile.write('\n')
    
    # Block 4: Array
    outFile.write(str(arr.shape[0]) + '\n')
    for irec in range(arr.shape[0]):
        outFile.write(line(arr[irec,:]) + '\n')  
    
    outFile.write('\n')

    # Block 5: Signal replicas
    
    outFile.write(line(reps.zs[0:-1]) + ' ' + str(int(reps.zs[-1])) + '\n')
    outFile.write(line(reps.xs[0:-1]) + ' ' + str(int(reps.xs[-1])) + '\n')
    outFile.write(line(reps.ys[0:-1]) + ' ' + str(int(reps.ys[-1])) + '\n')

'''
# Run OASM

baseDir = os.getcwd()

proc_list = []
logs = []

# print('Checking for OASM')
oasn_check = subprocess.Popen('which  oasm'.split())
oasn_check.wait()

# print(str(oasn_check.poll()==0))
# print(str(oasn_check.poll()))

if oasn_check.returncode == 0:
    print('OASN found!')
    for ii in range(len(allDirs)):
        os.chdir(baseDir + '/' + allDirs[ii])
        
        logs = open('oasn_log_'+str(ii+1)+'.txt','w')
        print(('oasn {'+str(ii)+'}').format(*allDirs))
        proc = subprocess.Popen(('oasn {'+str(ii)+'}').format(*allDirs).split(),stdout=logs,stderr=logs)
        proc.wait()
        print('  Return code: ' + str(proc.returncode))

        if not proc.returncode == 0:
            print('Trying once more: ')

            print(('oasn {'+str(ii)+'}').format(*allDirs))
            proc = subprocess.Popen(('oasn {'+str(ii)+'}').format(*allDirs).split(),stdout=logs,stderr=logs)
            proc.wait()
            print('  Return code: ' + str(proc.returncode))
	
        if proc.returncode == 0:
            os.rename(baseDir + '/' + allDirs[ii] + '/' + allDirs[ii] + '.chk', baseDir + '/chk_files/' + allDirs[ii] + '.chk')

        logs.close()
        time.sleep(0.05)

    
os.chdir(baseDir)
print('Done!')

'''

