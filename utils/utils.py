import subprocess
import time

timestr = lambda x=None: time.asctime(time.localtime(x)) if x else time.asctime()

def oscall(cmd, get=False):
    """
        This function performs a OS subprocess call.
        All output is thrown away unless an error has occured or if @get is True
        Arguments:
            @cmd: the string command to run
            [get] : True means return (stdout, stderr)
        Returns:
            None if not @get and no error
            (stdout, retcode, stderr) if @get or yes error
    """
    # Since we are already in a deferred chain, use subprocess to block and make the call to mount right HERE AND NOW
    proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, errors = proc.communicate()
    if(proc.returncode or get):
        return (output, proc.returncode, errors)
    else:
        if(output and output != ""):
            print('-- "%s" stdout: "%s"\n' % (cmd, output.rstrip()))
        if(errors and errors != ""):
            print('-- "%s" stderr: "%s"' % (cmd, errors.rstrip()))
        return None

def timedur(x):
    """
        Print consistent string format of seconds passed.
        Example: 300 = '5 mins'
        Example: 86400 = '1 day'
        Example: 86705 = '1 day, 5 mins, 5 sec'
    """
    divs = [('days', 86400), ('hours', 3600), ('mins', 60)]
    x = float(x)
    res = []
    for lbl, sec in divs:
        if(x >= sec):
            rm, x = divmod(x, float(sec))
            # If exactly 1, remove plural of label
            if(rm == 1.0):
                res.append((lbl[:-1], int(rm)))
            else:
                res.append((lbl, int(rm)))

    # anything left over is seconds
    x = int(x)
    if(x == 1):
        res.append(("second", x))
    elif(x == 0):
        pass
    else:
        res.append(("seconds", x))

    return ", ".join(["%d %s" % (x[1], x[0]) for x in res])
