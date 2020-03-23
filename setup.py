#!/usr/bin/env python

################################################################################
# Copyright (c) 2013-2019, Julien Bigot - CEA (julien.bigot@cea.fr)
# All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
################################################################################

from os.path import dirname, join
from setuptools import setup
from setuptools.command.develop import develop
from setuptools.command.install import install
from sys import path

class PostDevelopCommand(develop):
    """Post-installation for development mode."""
    def run(self):
        develop.run(self)
        path.insert(0, self.install_purelib)
        import bpp
        bpp.do_install_helpers(self.install_data)

class PostInstallCommand(install):
    """Post-installation for installation mode."""
    def run(self):
        install.run(self)
        path.insert(0, self.install_purelib)
        import bpp
        bpp.do_install_helpers(self.install_data)

setup(
    name = "bpp",
    version = "0.4.0",
    zip_safe = True,
    packages = [ 'bpp' ],
    include_package_data=True,
    package_data={
        "": ["cmake/*", "*.mk"],
    },
    entry_points = {
        "console_scripts": [
            "bpp = bpp:main",
            "bpp-setuphelpers = bpp:install_helpers",
        ],
    },
    cmdclass={
        'develop': PostDevelopCommand,
        'install': PostInstallCommand,
    },

    author = "Julien Bigot",
    author_email = "julien.bigot@cea.fr",
    description = "a Bash Pre-Processor for Fortran. BPP is useful in order to build clean Fortran90 interfaces. It allows to generate Fortran code for all types, kinds, and array ranks supported by the compiler.",
    long_description = open(join(dirname(__file__), 'README.md'), 'r').read(),
    long_description_content_type = "text/markdown",
    license = "MIT",
    keywords = "bash Fortran pre-processor",
    project_urls = {
        "Source Code": "https://github.com/pdidev/bpp/",
    },
    classifiers = [
        "OSI Approved :: MIT License",
        "Development Status :: 5 - Production/Stable",
        "Environment :: Console",
    ]
)
