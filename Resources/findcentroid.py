    
import struct
import png
import sys
import os.path
from types import *

versionstring = "0.1.0"

# --------- dot notation for python dictionaries
# From http://parand.com/say/index.php/2008/10/24/python-dot-notation-dictionary-access/

class dotdict(dict):
    def __getattr__(self, attr):
        return self.get(attr, None)
    __setattr__= dict.__setitem__
    __delattr__= dict.__delitem__

# --------- wmb data structure definitions
# From http://www.conitec.net/beta/prog_mdlhmp.html

LONG_TYPE = '<L'
SHORT_TYPE = '<h'
FLOAT_TYPE = '<f'
STRING4_TYPE = '<4s'
STRING16_TYPE = '<16s'
STRING20_TYPE = '<20s'
STRING44_TYPE = '<44s'


def read_struct(astruct, filehandle):
    if type(astruct) == StringType:
        line = filehandle.read(struct.calcsize(astruct))
        rval = struct.unpack(astruct, line)[0]
        return rval
    else:
        rval = {}
        for item in astruct:
            rval[item[0]]=read_struct(item[1], filehandle)
        return dotdict(rval)


def read_888_image_flipped(width, height, filehandle):
    bytes = [''] * height
    for j in reversed(range(height)):
        line = filehandle.read(3*width)
        bytes[j] = struct.unpack('<%dB'%(3*width), line)
        #print bytes[j]
    return bytes
            
def read_565_image(width, height, filehandle):
    bytes = []
    exbytes = []
    for j in range(height):
        line = filehandle.read(2*width)
        bytes.append(struct.unpack('<%dH'%width, line))
        line = []
        for i in list(bytes[j]):
            line.append((i>>11)<<3)
            line.append(((i>>5) & 0x3F)<<2)
            line.append((i & 0x1F)<<3)
        exbytes.append(tuple(line))
    return exbytes

def write_to_filechunk(length, filename, filehandle):
    chunk = filehandle.read(length)
    name = filter(lambda x: x!='\00', filename)
    f = open('%s.chunk' % name, 'wb')
    f.write(chunk)
    f.close()
    
    
    
def read_img_file(infile):
    
    # get the file and metadata
    r = png.Reader(filename = infile)
    p = r.asRGBA8()
    l = list(p[2])
    xdim = p[0]
    ydim = p[1]
    
    # find centroid
    xaccum = 0
    yaccum = 0
    count = 0
    
    for j in range(ydim):
        for i in range(xdim):
            if l[j][i*4+3] > 0:
                xaccum += i
                yaccum += j
                count += 1

    centx = xaccum / count
    centy = yaccum / count
    
    print infile, centx, centy
    return 

                
def main(args):
    read_img_file(args[0])

if __name__ == "__main__":
    main(sys.argv[1:])