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

  def up(self, plugin, bootstrap = False):
    """Spin up plugin"""
    plug = plugin_source.load_plugin(plugin)
    plug.up(bootstrap)

  def down(self, plugin):
    """Spin down plugin"""
    plug = plugin_source.load_plugin(plugin)
    plug.down()
  
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