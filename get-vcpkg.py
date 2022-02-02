
from os import mkdir, path
from sys import platform
from subprocess import run

VCPKG_DIR = 'vcpkg'
GIT_CLONE_COMMAND = 'git clone https://github.com/microsoft/vcpkg.git'

BOOTSTRAP_SUFFIX = '.bat' if platform == 'win32' else '.sh'
BOOTSTRAP_COMMAND = path.join(VCPKG_DIR, f'bootstrap-vcpkg.{BOOTSTRAP_SUFFIX}')

if not path.exists(VCPKG_DIR):
    print('cloning vcpkg...')
    run(GIT_CLONE_COMMAND)
    
    print('bootstrapping vcpkg...')
    run(BOOTSTRAP_COMMAND)

else:
    print(f'{VCPKG_DIR} already exists')

