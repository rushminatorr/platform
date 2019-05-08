import subprocess
import os
import yaml

def exportImages():
    """Read image config and export env vars"""
    with open("plugins/iofog/config.yml", 'r') as stream:
        images = ['controller', 'connector', 'operator', 'scheduler', 'kubelet']
        conf = yaml.safe_load(stream)
        for image in images:
            os.environ[image.upper() + "_IMG"] = conf['images'][image]

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
    
    # Record state of deployment
    f = open('.iofog.state', 'w')
    state = 'remote' 
    if args['local']:
        state = 'local'
        f.write(state)
        f.close()
        cmd('plugins/iofog/script/deploy-local.bash')
    else:
        f.write(state)
        f.close()
        # TODO: (Serge) Integrate images.yml with local deployment once CI builds Docker images
        exportImages()
        cmd('plugins/iofog/script/deploy.bash')
    

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
    # Read config to determine Test Runner image
    runner = ''
    with open('plugins/iofog/config.yml', 'r') as f:
        conf = yaml.safe_load(f)
        runner = conf['images']['runner']
    
    # Update docker-compose files to use Test Runner image
    compose_filenames = [ 'docker-compose.yml', 'docker-compose-local.yml' ]
    for file_name in compose_filenames:
        dir = 'plugins/iofog/test/'
        compose = dict()
        with open(dir + file_name, 'r') as f:
            compose = yaml.safe_load(f)
        compose['services']['test-runner']['image'] = runner
        with open(dir + file_name, 'w') as f:
            yaml.dump(compose, f)

    cmd('plugins/iofog/test/run.bash')

def describe():
    os.environ['KUBECONFIG'] = 'conf/kube.conf'
    cmd('kubectl get po,svc -n iofog')