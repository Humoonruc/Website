import logging
from multiprocessing import Pool
from bs4 import BeautifulSoup
import requests
import os
import random
import time
import re
import json
import docx

logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s - %(levelname)s - %(message)s')
# logging.basicConfig(filename='myProgramLog.txt', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
# logging.disable(logging.CRITICAL)


def main():
    pass


if __name__ == "__main__":
    logging.debug('Start of program\n')
    main()
    logging.debug('\nEnd of program')
