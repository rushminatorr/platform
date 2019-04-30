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
    
    state = 'remote' 
    if args['local']:
        state = 'local'
        cmd('plugins/iofog/script/deploy-local.bash')
    else:
        cmd('plugins/iofog/script/deploy.bash')
    
    # Record state of deployment
    f = open('.iofog.state', 'w')
    f.write(state)
    f.close()

def down(**kwargs):
    # Read state of deployment
    f = open('.iofog.state', 'r')
    state = f.read()

    if state == "local":
        cmd('docker-compose -f plugins/iofog/local/docker-compose.yml down')
    elif state == "remote":
        cmd('plugins/iofog/script/destroy.bash')
    else:
        raise Exception('.iofog.state file corrupted')

def test():
    cmd('plugins/iofog/test/run.bash')

def describe():
    os.environ['KUBECONFIG'] = 'conf/kube.conf'
    cmd('kubectl get po,svc -n iofog')