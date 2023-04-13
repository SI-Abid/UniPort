# read all the .dart files in the current directory and subdirectories and count the number of lines of code
# ignore comments and blank lines

import os
import re

def count_lines(file_name):
    """Count the number of lines of code in a file"""
    with open(file_name, 'r') as f:
        lines = f.readlines()
    line_count = len(lines)
    # for line in lines:
    #     line = line.strip()
    #     if line and not line.startswith('//'):
    #         line_count += 1
    return line_count

def main():
    """Count the number of lines of code in all the .dart files in the lib directory and its subdirectories"""
    total_lines = 0
    files_count = 0
    for root, dirs, files in os.walk('./lib'):
        for file_name in files:
            if file_name.endswith('.dart'):
                files_count += 1
                tmp = count_lines(os.path.join(root, file_name))
                print('{}: {}'.format(file_name, tmp))
                total_lines += tmp
    print('Total lines of code: {}'.format(total_lines))
    print('Total files: {}'.format(files_count))
    
if __name__ == '__main__':
    main()