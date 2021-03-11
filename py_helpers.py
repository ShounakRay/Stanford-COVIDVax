# @Author: Shounak Ray <Ray>
# @Date:   25-Feb-2021 22:02:04:048  GMT-0700
# @Email:  rijshouray@gmail.com
# @Filename: py_helpers.py
# @Last modified by:   Ray
# @Last modified time: 11-Mar-2021 15:03:40:408  GMT-0700
# @License: [Private IP]

from collections import Counter

import numpy as np
import pandas as pd


def manip_data(df, attr, max=20, min=0):

    def prepend_row(df, key):
        df.loc[-1] = [key for dummy in range(len(df.columns))]
        df.index = df.index + 1
        df.sort_index(inplace=True)

        return df

    df = pd.DataFrame(df)

    df = df.infer_objects()

    df = df[['location', attr]]

    a, b = 10, 50
    x, y = df[attr].min(), df[attr].max()
    df[attr] = (df[attr] - x) / (y - x) * (b - a) + a

    df.to_html('testcov.html')

    df = pd.pivot_table(df, values=attr, columns='location').reset_index(drop=True)

    # To use the fmsb package, I have to add 2 lines to the dataframe: the max and min of each topic to show on the plot!
    df = prepend_row(df, 0)
    df = prepend_row(df, 20)

    df.reset_index(drop=True, inplace=True)

    return df

#

#
