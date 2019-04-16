import subprocess
import os

def cmd(cmd_str):
    """Execute shell commands"""
    ret = subprocess.call(cmd_str.split())
    if ret != 0:
        raise Exception('Command failed: ' + cmd_str)

def up(bootstrap):
    if bootstrap:
        cmd('plugins/iofog/script/bootstrap.bash')
    cmd('plugins/iofog/script/deploy.bash')

def down():
    cmd('plugins/iofog/script/destroy.bash')

def test():
    cmd('kubectl get pods -n iofog')

def describe():
    os.environ['KUBECONFIG'] = 'conf/kube.conf'
    cmd('kubectl get po,svc -n iofog')