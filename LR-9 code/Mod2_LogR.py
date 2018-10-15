"""
:File: Mod2_LogR.py
:Author: Jack A. Kosmicki
:Last updated: 2014-07-07

Given a ADOS module 2 file, calculate the individual's log-odds and 
probability of receiving a diagnosis of ASD.

Version 2.0 fixed an error in the formula for calculating the probability of the diagnosis.

Input File Format
        - rows: individuals
        - columns: scores
        - expected column names: the ADOS items should be A1, A2, A3, . . . , E3
        - delimiter: assumes the file is tab-delimited, but this can be changed using
                     the --sep option.  So if the file is .csv, use --sep ','

Usage:
    Mod2_LogR.py <ADOSmodule2File> <outputFile_Name> [options]

Options:
    --sep=SEP        File delimiter [default: \t]
                     Remember to include quotes (e.g. use ',' if .csv) 
    -h, --help       Print this message and exit.
    -v, --version    Print the version and exit.
"""

from __future__ import division
import sys
import pandas as pd
import numpy as np
from docopt import docopt


__version__ = 2.0
__author__ = 'Jack A. Kosmicki <jkosmicki@fas.harvard.edu>'
__date__ = '10/08/2014'


def main(inputFile, outputFile):
    """ Read in the input file.
        Create a pandas dataframe.
        Calculate log-odds of receiving a diagnosis of ASD.
        Calculate the probability receiving a diagnosis of ASD.
        Write out the results to a new output file.

        Parameters
        ----------
        inputFile: file with ADOS module 2 scores by individual
                    - rows: individuals
                    - columns: scores
        outputFile: file to write the results to
    """

    # read in the file
    mod2 = pd.read_csv(inputFile, header=0, sep=separator)

    # recode 8s as 3s
    mod2 = mod2.replace([7,8],0)

    # replace all NAs and weird values with 0s
    mod2 = mod2.replace([np.nan,900,888],0)

    # calculate log-odds of receiving a diagnosis of ASD 
    # using the 9-feature Logistic Regression model
    mod2['log-odds'] = (-15.8657 + 2.2539 * mod2['A5'] + 3.0323 * mod2['A8'] +
                        3.8820 * mod2['B1'] + 4.3625 * mod2['B3'] +
                        5.0750 * mod2['B6'] + 4.0215 * mod2['B8'] +
                        3.8299 * mod2['B10'] + 3.4053 * mod2['D2'] + 2.6616 * mod2['D4'])

    # calculate probability of a ASD diagnosis from the log-odds
    #        e^(log-odds)                      1
    #    --------------------   =    --------------------
    #      1 + e^(log-odds)            1 + e^-(log-odds)
    mod2['probability_of_ASD_diagnosis'] = 1/(1 + np.exp(-1 * mod2['log-odds']))

    # write out the results to a file
    mod2.to_csv(outputFile, index=False, sep=separator)


if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')

    print(args)
    separator = ','
    #separator = args['--sep']   # file separator e.g., [',' '\t' etc]

    main(args['<ADOSmodule2File>'], args['<outputFile_Name>'])