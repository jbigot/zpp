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

""" The Bash PreProcessor
"""

from __future__ import print_function
try:
    from builtins import bytes
except ImportError:
    from __builtin__ import bytes
from fileinput import FileInput
from optparse import OptionParser
from os import listdir, makedirs, symlink, unlink
from os.path import abspath, basename, dirname, exists, expanduser, isdir, join, relpath, samefile, splitext
from pkg_resources import Requirement, resource_listdir, resource_stream
from platform import system
from re import compile
from shutil import copyfile, copyfileobj, rmtree
from site import getuserbase, getusersitepackages
from subprocess import call
from sys import argv, exit, stderr
from tempfile import NamedTemporaryFile, mkdtemp
from uuid import uuid4

__version__ = '0.4.0'

EOCAT = 'EOCAT_'+str(uuid4()).replace('-','_')
TRIGGER_REGEX = compile('^\s*!\$SH\s+')

def parse_cmdline():
    def callback_def(option, opt_str, value, parser):
        (optname, _, valval) = value.partition('=')
        parser.values.defines[optname.strip()] = valval.strip()

    parser = OptionParser(description="Preprocesses BASH in-line commands in a source file", version=__version__, usage="%prog [Options...] <source> [<destination>]\n  use `%prog -h' for more info")
    parser.add_option('-I',
                    action='append',
                    dest='includes',
                    nargs=1,
                    default=list(),
                    metavar="DIR",
                    help='Add DIR to search list for source directives'
    )
    parser.add_option('-o',
                    dest='output',
                    metavar="FILE",
                    help='Place the preprocessed code in file FILE.'
    )
    parser.add_option('-D',
                    action='callback',
                    callback=callback_def,
                    dest='defines',
                    type="string",
                    default=dict(),
                    metavar='OPTION=VALUE',
                    help='Set the value of OPTION to VALUE'
    )
    (opts, args) = parser.parse_args()
    if len(args) < 1 or len(args) > 2:
        parser.print_help()
        exit(1)
    if len(args) > 1 and opts.output is not None:
        parser.error("The -o option and <destination> argument are mutually exclusive")
        exit(1)
    input = abspath(args[0])
    output = None
    if opts.output is not None:
        output = abspath(opts.output)
    elif len(args) > 1:
        output = abspath(args[1])
    else:
        (root, ext) = splitext(input)
        if ext.lower() == '.bpp':
            output = root
        else:
            output = input+'.unbpp'
    return (input, output, opts.includes, opts.defines)

def setup_dir(includes):
    tmpdir = mkdtemp(suffix='', prefix='bpp.tmp.')
    for res_name in resource_listdir(Requirement.parse('bpp==0.4.0'), 'bpp/include'):
        copyfileobj(resource_stream(Requirement.parse('bpp==0.4.0'), join('bpp/include', res_name)), open(join(tmpdir, res_name), 'wb'))
    for incdir in includes:
        if isdir(incdir):
            for incfile in listdir(incdir):
                if incfile[-7:] == '.bpp.sh':
                    src = abspath(join(incdir, incfile))
                    dst = join(tmpdir, basename(incfile))
                    if not exists(dst):
                        symlink(src, dst)
        else:
            print('Warning: include directory not found: "'+incdir+'"', file=stderr)
    return tmpdir

def handle_file(tmpdir, input, defines, output):
    with open(join(tmpdir, basename(input)+'.bash'), 'w') as tmpfile:
        inbash=True
        for var in defines:
            tmpfile.write(var+'='+defines[var]+"\n")
        with open(input, 'r') as infile:
            for line in infile:
                if TRIGGER_REGEX.match(line):
                    if not inbash:
                        tmpfile.write(EOCAT+"\n")
                        inbash=True
                    tmpfile.write(TRIGGER_REGEX.sub('', line, 1))
                else:
                    if inbash:
                        tmpfile.write("cat<<"+EOCAT+"\n")
                        inbash=False
                    tmpfile.write(line)
        if not inbash:
            tmpfile.write(EOCAT+"\n")
        tmpfile.close()

        if output == '-':
            result = call(['bash','-r', basename(tmpfile.name)], cwd=tmpdir)
        else:
            with open(output, 'w') as outfile:
                result = call(['bash','-r', basename(tmpfile.name)], stdout=outfile, cwd=tmpdir)

def main():
    result=0
    (input, output, includes, defines) = parse_cmdline()
    tmpdir = setup_dir(includes)
    try:
        handle_file(tmpdir, input, defines, output)
    except Exception as e:
        print(e, file=stderr)
        result=-1
    rmtree(tmpdir)
    exit(result)

def do_install_helpers(prefix=None):
    if prefix is not None:
        pass
    elif samefile(abspath(getusersitepackages()), dirname(dirname(dirname(abspath(__file__))))):
        prefix = getuserbase()
    elif samefile(abspath(getuserbase()), dirname(dirname(abspath(argv[0])))):
        prefix = getuserbase()
    else:
        # expect to be installed to /bin and go up one directory
        prefix = dirname(dirname(abspath(argv[0])))
    
    if isdir(prefix) and samefile(prefix, '/'):
        prefix = join(prefix, 'usr')
    
    share_dir = join(prefix, 'share', 'bpp')
    cmake_dir = join(share_dir, 'cmake')
    
    print("running install_wrappers", file=stderr)
    
    if isdir(prefix) and isdir(getuserbase()) and samefile(prefix, getuserbase()):
        print("Registering in cmake user registry", file=stderr)
        if system() == 'Linux':
            cmake_dir = join(getuserbase(), 'share', 'bpp', 'cmake')
            cmake_registry = abspath(expanduser("~/.cmake/packages/"))
            if not isdir(cmake_registry):
                makedirs(cmake_registry)
            cmake_registry_file = join(cmake_registry, 'bpp-'+__version__)
            with open(cmake_registry_file, 'w') as bppfile:
                bppfile.write(str(cmake_dir)+"\n")
        else:
            print("Unsupported system type: "+system(), file=stderr)
            exit(1)
    if not isdir(cmake_dir):
        makedirs(cmake_dir)
    
    for res_name in resource_listdir(Requirement.parse('bpp==0.4.0'), 'bpp/cmake'):
        dst = join(cmake_dir, res_name)
        print('Installing '+res_name+' wrapper to '+cmake_dir, file=stderr)
        data_in = resource_stream(Requirement.parse('bpp==0.4.0'), join('bpp/cmake', res_name))
        with open(dst, 'wb') as data_out:
            if ( res_name == 'BppConfig.cmake' ):
                exe_path = abspath(argv[0])
                rel_cmake_path = relpath(dirname(exe_path), cmake_dir)
                try:
                    rel_cmake_path = bytes(rel_cmake_path, encoding='utf8')
                except:
                    rel_cmake_path = bytes(rel_cmake_path)
                for line in data_in:
                    if bytes(b'@PYTHON_INSERT_BPP_EXECUTABLE@') in line:
                        data_out.write(bytes(b'get_filename_component(BPP_EXECUTABLE "${_CURRENT_LIST_DIR}/'+rel_cmake_path+b'" ABSOLUTE)\n'))
                    else:
                        data_out.write(line)
            else:
                copyfileobj(data_in, data_out)
    
    for res_name in resource_listdir(Requirement.parse('bpp==0.4.0'), 'bpp'):
        if ( res_name[-3:] == '.mk' ):
            dst = join(share_dir, res_name)
            print('Installing '+res_name+' wrapper to '+share_dir, file=stderr)
            copyfileobj(resource_stream(Requirement.parse('bpp==0.4.0'), join('bpp', res_name)), open(dst, 'wb'))

def install_helpers():
    parser = OptionParser(description="Installs the cmake and makefile helpers for bpp", version=__version__, usage="%prog [Options...]\n  use `%prog -h' for more info")
    parser.add_option('--prefix',
                    nargs=1,
                    help='Install to PREFIX instead of autodiscovered path'
    )
    (opts, args) = parser.parse_args()
    if len(args) > 0:
        parser.print_help()
        exit(1)
    
    do_install_helpers(opts.prefix)
    
    
if __name__ == "__main__" :
    main()
