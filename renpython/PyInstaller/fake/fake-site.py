import sys

def init():
    
    path = sys.executable
    
    i = len(path) - 1
    
    while i:
        if path[i] in "/\\":
            break
        i -= 1

    path = path[:i] + "/../pythonlib2.7"
        
    print path

    sys.path.append(path)
    import os.path
    sys.path.pop()
    
    exe_path = os.path.abspath(sys.executable)
    exe_dir = os.path.dirname(exe_path)
    lib_dir = os.path.dirname(exe_dir)
    
    sys.path.append(os.path.join(lib_dir, "pythonlib2.7"))
    
init()

    