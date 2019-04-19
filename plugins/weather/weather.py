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
    print 'Weather app on ioFog Kubernetes'

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

    os.environ['KUBECONFIG'] = 'conf/kube.conf'

    if args['bootstrap']:
        cmd('kubectl --help')
        print 'Nothing to bootstrap for Weather App'
    
    cmd('kubectl apply -f plugins/weather/weather.yml')

def down():
    os.environ['KUBECONFIG'] = 'conf/kube.conf'
    cmd('kubectl delete -f plugins/weather/weather.yml')

def test():
    os.environ['KUBECONFIG'] = 'conf/kube.conf'
    cmd('plugins/weather/script/test.bash')

def describe():
    os.environ['KUBECONFIG'] = 'conf/kube.conf'
    cmd('kubectl get pods -n iofog')
    cmd('kubectl describe pods -l app=weather-demo -n iofog')