#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 15 12:32:56 2018

@author: baillard
"""

import matplotlib.pyplot as plt
import numpy as np
import copy
import pickle
from datetime import datetime
import sys

from obspy import UTCDateTime
from obspy.clients.fdsn import Client



#client_name='IRIS'
client_name='http://service.iris.edu'

client=Client(client_name)
starttime = UTCDateTime("2015-01-22T00:00:00")
duration = 10

st = client.get_waveforms(network='OO',station='AX*',location="*",channel='E*Z',
                                starttime=starttime,
                                endtime=starttime+duration)


st.plot()
trace=st[0]

trace_filter=copy.copy(trace)
trace_filter.filter('bandpass', freqmin=5.0, freqmax=50,corners=3, zerophase=True)

#fig,ax=plt.subplots()

trace_filter.plot()
