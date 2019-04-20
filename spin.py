import os
import fire
from pluginbase import PluginBase

def subdirs(dir):
  """Get list of immediate subdirs"""
  return [dir + '/' + name for name in os.listdir(dir)
    if os.path.isdir(os.path.join(dir, name))]

plugin_base = PluginBase(package='spin.plugins')
plugin_source = plugin_base.make_plugin_source(searchpath=subdirs('plugins'))

class spin(object):
  """Class for spinning up infrastructure, platforms, and services"""

  def list(self):
    """List all available plugins"""
    for dir in subdirs('plugins'):
      print dir.replace('plugins/', '')

  def help(self, plugin):
    """Print help information for plugin"""
    plug = plugin_source.load_plugin(plugin)
    plug.help()

  def up(self, plugin, **kwargs):
    """Spin up plugin"""
    plug = plugin_source.load_plugin(plugin)
    plug.up(**kwargs)

  def down(self, plugin, **kwargs):
    """Spin down plugin"""
    plug = plugin_source.load_plugin(plugin)
    plug.down(**kwargs)
  
  def test(self, plugin):
    """Test deployment of plugin"""
    plug = plugin_source.load_plugin(plugin)
    plug.test()

  def describe(self, plugin):
    """Get status of spun up plugin"""
    plug = plugin_source.load_plugin(plugin)
    plug.describe()

if __name__ == '__main__':
  fire.Fire(spin)