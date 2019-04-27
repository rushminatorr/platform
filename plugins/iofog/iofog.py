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
        print '--local=false'
        return

    # Default args
    args = {}
    args['bootstrap'] = False
    args['local'] = False

    # Parse input args
    for key, val in kwargs.items():
        args[key] = str2bool(val)

    if args['bootstrap']:
        cmd('plugins/iofog/script/bootstrap.bash')
    
    if args['local']:
        cmd('plugins/iofog/script/deploy-local.bash')
    else:
        cmd('plugins/iofog/script/deploy.bash')

def down(**kwargs):
    if 'help' in kwargs:
        print 'Default arguments:'
        print '--local=false'
        return

    # Default args
    args = {}
    args['local'] = False

    # Parse input args
    for key, val in kwargs.items():
        args[key] = str2bool(val)

    if args['local']:
        cmd('docker-compose -f plugins/iofog/local/docker-compose.yml down')
    else:
        cmd('plugins/iofog/script/destroy.bash')

def test():
    cmd('plugins/iofog/test/run.bash')

def describe():
    os.environ['KUBECONFIG'] = 'conf/kube.conf'
    cmd('kubectl get po,svc -n iofog')