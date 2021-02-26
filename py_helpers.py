# @Author: Shounak Ray <Ray>
# @Date:   25-Feb-2021 22:02:04:048  GMT-0700
# @Email:  rijshouray@gmail.com
# @Filename: py_helpers.py
# @Last modified by:   Ray
# @Last modified time: 26-Feb-2021 00:02:86:866  GMT-0700
# @License: [Private IP]

from collections import Counter

import numpy as np
import pandas as pd


def manip_data(df):
    df = pd.DataFrame(df)

    df.to_html('test.html')
    # df.to_csv('testcov.csv')
    return True

#

#
