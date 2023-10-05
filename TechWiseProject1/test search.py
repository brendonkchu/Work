import os
import site

def find_clidriver(start_path):
    for root, dirs, files in os.walk(start_path):
        if 'clidriver' in dirs:
            print("clidriver found at:", os.path.join(root, 'clidriver'))

# Search in the site-packages directory
site_packages_dir = site.getsitepackages()
for dir in site_packages_dir:
    find_clidriver(dir)