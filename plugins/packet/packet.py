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
    print ''
    print 'Kubernetes cluster and edge nodes on Packet'
    print ''
    print 'Usage:       python spin.py up packet'
    print '             python spin.py down packet'
    print '             python spin.py describe packet'
    print '             python spin.py test packet'
    print ''
    print 'Use --help on the up/down commands for more information'

def up(**kwargs):
    if 'help' in kwargs:
        print ''
        print 'Spin up infrastructure on Packet'
        print ''
        print 'Arguments:       --bootstrap     Default: false      Install dependancies'
        print '                 --gen-creds     Default: true       Generate new pub/priv key pair (overwrites previous)'
        print '                 --cluster       Default: true       Spin up Kubernetes cluster'
        print '                 --edge          Default: true       Spin up edge nodes'
        print ''
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
        cmd('plugins/packet/script/bootstrap.bash')
    
    # Gen keys and login to Pakcet
    if args['gen-creds']:
        cmd('plugins/packet/script/gen-creds.bash')

    # Deploy Kubernetes cluster
    if args['cluster']:
        cmd('plugins/packet/script/set-workspace.bash packet-cluster')
        cmd('plugins/packet/script/deploy-cluster.bash')
    
    # Deploy edge nodes
    if args['edge']:
        cmd('plugins/packet/script/set-workspace.bash packet-edge')
        cmd('plugins/packet/script/deploy-edge.bash')

    cmd('cp plugins/packet/creds/id_ecdsa conf/')
    cmd('cp plugins/packet/creds/id_ecdsa.pub conf/')

def down(**kwargs):
    if 'help' in kwargs:
        print ''
        print 'Spin down infrastructure on Packet'
        print ''
        print 'Arguments:       --cluster       Default: true       Spin down Kubernetes cluster'
        print '                 --edge          Default: true       Spin down edge nodes'
        print ''
        return

    # Default args
    args = {}
    args['cluster'] = True
    args['edge'] = True

    # Parse input args
    for key, val in kwargs.items():
        args[key] = str2bool(val)

    if args['cluster']:
        cmd('plugins/packet/script/set-workspace.bash packet-cluster')
        cmd('plugins/packet/script/destroy.bash cluster')
    
    if args['edge']:
        cmd('plugins/packet/script/set-workspace.bash packet-edge')
        cmd('plugins/packet/script/destroy.bash edge')

def test():
    cmd('echo TODO tests')

def describe():
    cmd('terraform output')