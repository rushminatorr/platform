import subprocess
import os

def cmd(cmd_str):
    """Execute shell commands"""
    ret = subprocess.call(cmd_str.split())
    if ret != 0:
        raise Exception('Command failed: ' + cmd_str)

def str2bool(v):
  if isinstance(v, bool):
      return v
  return v.lower() in ("yes", "true")

def help():
    print 'ioFog Kubernetes and Agent nodes'

def up(**kwargs):
    if 'help' in kwargs:
        print 'Default arguments:'
        print '--bootstrap=false'
        return

    # Default args
    args = {}
    args['bootstrap'] = False

    # Parse input args
    for key, val in kwargs.items():
        args[key] = str2bool(val)

    if args['bootstrap']:
        cmd('plugins/iofog/script/bootstrap.bash')
    cmd('plugins/iofog/script/deploy.bash')

def down():
    cmd('plugins/iofog/script/destroy.bash')

def test():
    cmd('kubectl get pods -n iofog')

def describe():
    os.environ['KUBECONFIG'] = 'conf/kube.conf'
    cmd('kubectl get po,svc -n iofog')