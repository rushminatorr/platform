import subprocess
import os

def cmd(cmd_str):
    """Execute shell commands"""
    ret = subprocess.call(cmd_str.split())
    if ret != 0:
        raise Exception('Command failed: ' + cmd_str)

def up(bootstrap):
    if bootstrap:
        cmd('plugins/packet/script/bootstrap.bash')
    cmd('plugins/packet/script/deploy.bash')

def down():
    cmd('plugins/packet/script/destroy.bash')

def test():
    cmd('echo TODO: tests')

def describe():
    cmd('terraform output')