import subprocess
import os

def cmd(cmd_str):
    """Execute shell commands"""
    ret = subprocess.call(cmd_str.split())
    if ret != 0:
        raise Exception('Command failed: ' + cmd_str)

def up(bootstrap):
    if bootstrap:
        cmd('plugins/gcp/script/bootstrap.bash')
    cmd('plugins/gcp/script/deploy.bash')

def down():
    cmd('plugins/gcp/script/destroy.bash')

def test():
    cmd('gcloud container clusters list')

def describe():
    cmd('gcloud container clusters list')
    cmd('terraform output')