# @Author: Shounak Ray <Ray>
# @Date:   25-Feb-2021 22:02:04:048  GMT-0700
# @Email:  rijshouray@gmail.com
# @Filename: py_helpers.py
# @Last modified by:   Ray
# @Last modified time: 14-Mar-2021 23:03:45:457  GMT-0600
# @License: [Private IP]

# This is a library that I use which returns the frequency
#   of values in a column
# from collections import Counter

# Basic python library for numerical analysis
# import numpy as np

# Library which allows me to make tables AKA DataFrames
import pandas as pd


def manip_data(df, attr, top_n=10, norm_max=50, norm_min=10):
    """This returns a manipulated version of the data which
    that is required for the radar plot in R.

    Parameters
    ----------
    df : pandas.core.DataFrame
        The original dataset (from R)
    attr : str
        The name of the column for the provided radar plot.
    top_n : int
        What the top 'n' countries this function should return data for?
    norm_max : int
        Maximum bound for the normalized column data.
        This is relative and unitness, just a scalar.
    norm_min : int
        Minimum bound for the normalized column data.
        This is relative and unitness, just a scalar.

    Returns
    -------
    pandas.core.DataFrame
        This returns a pandas table, which I convert to an R
        data.frame. SEE `radar.r`

    """

    def prepend_row(df, key):
        """This is local utility function which – as the name
        suggests, simply prepends a row where all the values are
        `key` to the inputted DataFrame.

        Parameters
        ----------
        df : pandas.core.DataFrame
            The inputted DataFrame. This one isn't from R, but
            rather an intermediate calculated in `manip_data`.
        key : int
            The value that the row should only contain.

        Returns
        -------
        pandas.core.DataFrame
            The new DataFrame with the prepended row.

        """

        # Adds the specified row to index -1 of the DataFrame
        df.loc[-1] = [key for dummy in range(len(df.columns))]
        # Pushes all the index assignment by one.
        df.index = df.index + 1
        # Sorts the DataFrame
        df.sort_index(inplace=True)

        return df

    # Casts the R data.frame to a pandas DataFrame
    # NOTE: This is probably optional since `reticulate` likely automatically
    #   does this during the function call
    df = pd.DataFrame(df)
    # Automatically determine the data types for each column
    # NOTE: This is probably optional since pandas likely automatically
    #   does this during ingestion
    df = df.infer_objects()

    # FORMAT OF DATAFRAME AT THIS POINT (lots of columns, lots of rows)
    #   location	iso_code	date	    total_vaccinations   MORE METRICS
    # 0	Albania	    ALB	        2021-03-10	21613.0              MORE VALUES
    # 1	Algeria	    DZA	        2021-02-19	75000.0              MORE VALUES
    # 2	Andorra	    AND	2       021-03-10	4914.0               MORE VALUES
    # N MORE        MORE        MORE        MORE                 MORE VALUES

    # Selects two columns, namely `location` and the specified
    #   `attr` column for which the DataFrame should be made
    df = df[['location', attr]]

    # FORMAT OF DATAFRAME AT THIS POINT (two columns, top_n rows)
    #   location    total_vaccinations
    # 0	Albania     21613.0
    # 1	Algeria     75000.0
    # 2	Andorra     4914.0
    # N MORE        MORE VALUES

    # Sort the dataframe in ascending order based on the `attr` column
    df = df.sort_values(attr).reset_index(drop=True)
    # Slices the dataframe to only get the top "n" countries
    df = df.head(top_n)

    # FORMAT OF DATAFRAME AT THIS POINT (two columns, top_n rows)
    #       location	           total_vaccinations
    # 0 	Saint Helena           107.0
    # 1 	Trinidad and Tobago    440.0
    # 2 	Montserrat     	       652.0
    # N     SOME OTHER COUNTRIES   SOME OTHER ORIGINAL VALUES

    # Normalizes the column so every value is between norm_min and norm_max
    # > Assigns the maximum and minimum values found in the `attr` column to x
    #   and y respectively
    x, y = df[attr].min(), df[attr].max()
    df[attr] = (df[attr] - x) / (y - x) * (norm_max - norm_min) + norm_min

    # FORMAT OF DATAFRAME AT THIS POINT (two columns, top_n rows)
    #       location	           total_vaccinations
    # 0 	Saint Helena           10.000000
    # 1 	Grenada	               10.000005
    # 2 	Trinidad and Tobago	   10.000041
    # 3 	Montserrat	           10.000066
    # 4 	Egypt	               10.000147
    # N     SOME OTHER COUNTRIES   SOME OTHER NORMALIZED VALUES

    # Pivots the DataFrame where the the row represents attr and the columns
    #   represents the different countries
    df = pd.pivot_table(df, values=attr, columns='location').reset_index(drop=True)

    # Removes the name `location` of the column level
    # NOTE: This is a Python nuance and preference, doesn't matter for R
    df.columns.name = None

    # FORMAT OF DATAFRAME AT THIS POINT (top_n columns, one row)
    #   Albania	    Algeria	    Andorra	     SOME MORE COUNTRIES
    # 0	10.002422	10.008435	10.000541	 SOME MORE NORMALIZED VALUES

    # To use the fmsb package, I have to add 2 lines to the dataframe: the max and
    #   min of each topic to show on the plot!
    df = prepend_row(df, 0)

    # FORMAT OF DATAFRAME AT THIS POINT (top_n columns, two rows)
    #   Albania	    Algeria	    Andorra	    SOME MORE COUNTRIES
    # 0 0.0000000   0.0000000   0.0000000   0.0000000
    # 1	10.002422	10.008435	10.000541	SOME MORE NORMALIZED VALUES

    df = prepend_row(df, norm_max)

    # FORMAT OF DATAFRAME AT THIS POINT (top_n columns, three rows)
    #   Albania	    Algeria	    Andorra	    SOME MORE COUNTRIES
    # 0 50.000000   50.000000   50.000000   50.000000
    # 1 0.0000000   0.0000000   0.0000000   0.0000000
    # 2	10.002422	10.008435	10.000541	SOME MORE NORMALIZED VALUES

    df.to_html('testcov.html')

    return df

#

#
