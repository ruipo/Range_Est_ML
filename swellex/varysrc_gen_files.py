

# Make and run OASN files for varying discrete source locations. 
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
options = 'N J 0'

# define frequencies
freqs = np.array([109,109,1,0]) # [min freq, max freq, # of freqs, integration contour offset]
#9m dpeth: 109 163 232 385
#54m depth:112 148 201 283
# define sound speed layers
sspfile="swellex_ssp.csv"

layers = np.loadtxt(sspfile, delimiter=",") # import ssp for envrironment from file

#roughness_layer = 3
#roughness_param = [-0.2, 19.1, 2.5]

# define array
arrayfile="vla_array.csv"

array = np.loadtxt(arrayfile, delimiter=",") # import ssp for envrironment from file

array_temp1 = [int(inc) for inc in array[:,3]]
array_temp2 = [int(inc) for inc in array[:,4]]

arr = np.ndarray(array.shape,dtype = object)
arr[:,0:3] = array[:,0:3]
arr[:,3] = array_temp1
arr[:,4] = array_temp2


# define sources
src = types.SimpleNamespace()

src.src = np.array([0, 0, 0, 1]) # [surf. noise src strength, white noise level, deep src level, # of discr. srcs]

if src.src[0] != 0: #if there is sea surface noise
    src.seacs = np.array([1400,1e8]) # [cmins, cmaxs]
    src.seawav = np.array([400,400,100]) # [samples in cont., discr, evanes.]

if src.src[2] != 0: #if there is deep noise source
    src.dscs = np.array([1400,1e8]) # [cmins, cmaxs]
    src.dswav = np.array([400,400,100]) # [samples in cont., discr, evanes.]
    
if src.src[3] != 0: #if there is discrete source
    # [depth(m), x-coord(km), y-coord(km), source level]
    src_ycoor = 0
    src_xcoor = np.linspace(0,10,1001)
    src_zcoor = 9 #54
    src_level = 155
    
    src.ndcs = np.array([1300,1600]) # [cmins, cmaxs]
    src.ndwav = np.array([-1,0,0]) # [# of sampling points,first sampling point, last sampling point]; [-1,0,0] for auto
    
    #repeat for each discrete source
    
# define signal replicas  

if 'R' in options:
    reps = types.SimpleNamespace()

    reps.zs = np.array([50,50,1]) # depths of sampling of replicas
    reps.xs = np.array([1,1,1]) # x-coord of sampling 
    reps.ys = np.array([0,0,1]) # y-coord of sampling

    reps.cvals = np.array([1400,1e8]) # [cmins, cmaxs]
    reps.wavs = np.array([-1,0,0]) # [# of sampling points,first sampling point, last sampling point]; [-1,0,0] for auto

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

for ii in range(src_xcoor.shape[0]): # for each source location
    for jj in range(1): # create 30 small random perturbations to the location
        
        outFileName = str(round(src_xcoor[ii],2)) + 'km' + '.dat'

        if not os.path.isdir(outFileName[0:-4]):
            os.mkdir(outFileName[0:-4])

        allDirs.append(outFileName[0:-4])

        outFile = open(outFileName[0:-4] + '/' + outFileName, 'w')

        # Begin writing file:

        # Block 1: Title
        outFile.write('ICEX_32array ' + outFileName[0:-4] + '\n')

        # Block 2: Options
        outFile.write(options + '\n')

        # Block 3: Frequencies
        outFile.write(line(freqs) + '\n')

        outFile.write('\n')

        # Block 4: Environment

        #number of layers
        outFile.write(str(layers.shape[0]) + '\n')

        #environment layers
        layers[np.isnan(layers)] = 0.

        for kk in range(layers.shape[0]):
            outFile.write(line(layers[kk,:]) + '\n')
                

        outFile.write('\n')

        # Block 5: Array
        outFile.write(str(arr.shape[0]) + '\n')
        for irec in range(arr.shape[0]):
            outFile.write(line(arr[irec,:]) + '\n')  

        outFile.write('\n')

        # Block 6: Sources
        outFile.write(line(src.src) + '\n')
        
        outFile.write('\n')

        # Block 7: Sea Surface
        if src.src[0] != 0: #if there is sea surface noise
            outFile.write(line(src.seacs) + '\n')
            outFile.write(line(src.seawav) + '\n')
            
            outFile.write('\n')

        # Block 8: Deep Noise
        if src.src[2] != 0: #if there is deep noise source
            outFile.write(line(src.dscs) + '\n')
            outFile.write(line(src.dswav) + '\n')
            
            outFile.write('\n')            
            
        # Block 9: Discrete Sources
        if src.src[3] != 0: #if there is discrete source  
            disc_src = np.array([src_zcoor,src_xcoor[ii],src_ycoor,src_level])
            outFile.write(line(disc_src) + '\n')
            outFile.write(line(src.ndcs) + '\n')
            outFile.write(line(src.ndwav) + '\n')

            outFile.write('\n')

        # Block 10: Signal replicas
        if 'R' in options:
            outFile.write(line(reps.zs[0:-1]) + ' ' + str(int(reps.zs[-1])) + '\n')
            outFile.write(line(reps.xs[0:-1]) + ' ' + str(int(reps.xs[-1])) + '\n')
            outFile.write(line(reps.ys[0:-1]) + ' ' + str(int(reps.ys[-1])) + '\n')

            outFile.write('\n')

            outFile.write(line(reps.cvals) + '\n')
            outFile.write(line(reps.wavs) + '\n')


# Run OASN

baseDir = os.getcwd()

os.chdir(baseDir)
if not os.path.isdir('chk_files'):
    os.mkdir('chk_files')

proc_list = []
logs = []

# print('Checking for OASN')
oasn_check = subprocess.Popen('which  oasn'.split())
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


