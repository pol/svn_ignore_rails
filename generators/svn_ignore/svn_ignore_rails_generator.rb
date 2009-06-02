require 'rbconfig'

# This generator adds a rake task to a Rails project for svn file ignores
class SvnIgnoreRailsGenerator < Rails::Generator::Base
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])
  
  def initialize(runtime_args, runtime_options = {})
    Dir.mkdir('lib/tasks') unless File.directory?('lib/tasks')
    super
  end
  
  def manifest
    record do |m|
      script_options     = { :chmod => 0755, :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : options[:shebang] }

      m.directory 'lib/tasks'
      m.template  'svn_ignore.rake', 'lib/tasks/svn_ignore.rake'
    end
  end
  
protected
  
  def banner
    "Usage: #{$0} svn_ignore_rails"
  end
  
end