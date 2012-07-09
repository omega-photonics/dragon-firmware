#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
Created on Tue Jul 10 00:41:20 2012

@author: ii
"""

import datetime
import os
import commands

comment = ''.join(commands.getoutput("git log -1").splitlines()[4:])
datename = str(datetime.datetime.now()).replace(':', '-').replace(' ', '_') + '.bit'
os.rename('xilinx_pci_exp_ep.bit', datename)
os.system('scp "{}" upload@fs2.us.to:/home/upload/public_html/'.format(datename))

os.system("""ssh upload@fs2.us.to 'echo AddDescription \\"{}\\" \\"{}\\">>public_html/.htaccess' """.format(comment, datename))