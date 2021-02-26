# @Author: Shounak Ray <Ray>
# @Date:   25-Feb-2021 22:02:04:048  GMT-0700
# @Email:  rijshouray@gmail.com
# @Filename: py_helpers.py
# @Last modified by:   Ray
# @Last modified time: 25-Feb-2021 23:02:59:590  GMT-0700
# @License: [Private IP]

import pandas as pd


def manip_data(df):
    df = pd.DataFrame(df)

    df.to_html('test.html')
    # df.to_csv('testcov.csv')
    return True

#

#
