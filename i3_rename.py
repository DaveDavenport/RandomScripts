#!/usr/bin/env python
# Needs: https://github.com/ziberna/i3-py

import i3
import subprocess

def i3rnwps():
    rnwps = {}
    wps = i3.get_workspaces()
    for wp in wps:
        workspace = i3.filter(num=wp['num'])
        if not workspace:
            continue
        workspace = workspace[0]
        windows = i3.filter(workspace, nodes=[])
        instances = {}
        # Adds windows and their ids to the rnwps dictionary
        if len(windows) == 1:
            win =windows[0]
            if win.has_key('window_properties'):
                rnwps[workspace['name']] = "%i: %s" % (workspace['num'], win['window_properties']['class'])
        elif len(windows) == 0: 
            rnwps[workspace['name']] = "%i: Empty" % (workspace['num'])
        else:
            names={}
            for win in windows:
                if win.has_key('window_properties'):
                    if not names.has_key(win['window_properties']['class']):
                        names[win['window_properties']['class']]=1
                    else:
                        names[win['window_properties']['class']]=names[win['window_properties']['class']]+1
            str="%i: " %(workspace['num'])
            for name in names.keys():
               str+="%ix%s " %(names[name], name)
            rnwps[workspace['name']] = str 
    return rnwps

def rename():
    rnwps = i3rnwps()
    print rnwps
    for desk in rnwps.keys():
        print(desk)
        if desk != rnwps[desk]:
            i3.rename('workspace', "\"%s\"" % (desk),'to', rnwps[desk])

def watch(a,b,c):
    print(a)
    rename()

if __name__ == '__main__':
    #subscription = i3.Subscription(watch, 'workspace')
    rename()

