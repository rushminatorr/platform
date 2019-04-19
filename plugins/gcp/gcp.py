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
    print 'Kubernetes cluster and edge nodes on GCP'

def up(**kwargs):
    if 'help' in kwargs:
        print 'Default arguments:'
        print '--bootstrap=false'
        print '--gen-creds=true'
        print '--cluster=true'
        print '--edge=true'
        return

    # Default args
    args = {}
    args['bootstrap'] = False
    args['gen-creds'] = True
    args['cluster'] = True
    args['edge'] = True

    # Parse input args
    for key, val in kwargs.items():
        args[key] = str2bool(val)

    # Bootstrap deps
    if args['bootstrap']:
        cmd('plugins/gcp/script/bootstrap.bash')
    
    # Gen keys and login to GCP
    if args['gen-creds']:
        cmd('plugins/gcp/script/init-gcp.bash')

    # Deploy Kubernetes cluster
    if args['cluster']:
        cmd('plugins/gcp/script/set-workspace.bash cluster')
        cmd('plugins/gcp/script/deploy-cluster.bash')
    
    # Deploy edge nodes
    if args['edge']:
        cmd('plugins/gcp/script/set-workspace.bash edge')
        cmd('plugins/gcp/script/deploy-edge.bash')

    cmd('cp plugins/gcp/creds/id_ecdsa conf/')
    cmd('cp plugins/gcp/creds/id_ecdsa.pub conf/')

def down(**kwargs):
    if 'help' in kwargs:
        print 'Default arguments:'
        print '--cluster=true'
        print '--edge=true'
        return

    # Default args
    args = {}
    args['cluster'] = True
    args['edge'] = True

    # Parse input args
    for key, val in kwargs.items():
        args[key] = str2bool(val)

    if args['cluster']:
        cmd('plugins/gcp/script/set-workspace.bash cluster')
        cmd('plugins/gcp/script/destroy.bash cluster')
    
    if args['edge']:
        cmd('plugins/gcp/script/set-workspace.bash edge')
        cmd('plugins/gcp/script/destroy.bash edge')

def test():
    cmd('gcloud container clusters list')

def describe():
    cmd('gcloud container clusters list')
    cmd('terraform output')