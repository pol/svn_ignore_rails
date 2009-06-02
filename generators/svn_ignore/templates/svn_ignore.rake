# This file is copied to ~/lib/tasks when you run 'ruby script/generate svn_ignore_rails'
# from the project root directory.
options = {}
ENV['OPTIONS'].split(',').each { |opt| options[opt.downcase.to_sym] = true } if ENV['OPTIONS']

namespace :svn do
  puts "Options: " + options.keys.join(',') unless options.empty?
  abort(help_text) if options[:help]

  desc "Remove and ignore config/initializers/site_keys.rb"
  task :remove_site_keys_rb do
    tasks = TaskQueue.new
    tasks.concat remove_file_with_example(File.join('config','initializers'),'site_keys.rb')
    tasks.add_msg "Committing..."
    tasks.add_cmd "svn commit #{RAILS_ROOT} -m 'Remove and ignore config/initializers/site_keys.rb'"
    tasks.run(options)
  end
  
  desc "Remove and ignore config/database.yml"
  task :remove_database_yml do
    tasks = TaskQueue.new
    tasks.concat remove_file_with_example('config','database.yml')
    tasks.add_msg "Committing..."
    tasks.add_cmd "svn commit #{RAILS_ROOT}"
    tasks.run(options)
  end

  desc "Remove and ignore config/deploy.rb"
  task :remove_deploy_rb do
    tasks = TaskQueue.new
    tasks.concat remove_file_with_example('config','deploy.rb')
    tasks.add_msg "Committing..."
    tasks.add_cmd "svn commit #{RAILS_ROOT} -m 'Remove and ignore config/database.yml'"
    tasks.run(options)
  end
  
  desc "Remove and ignore files from tmp/ (recursively, keep dirs)"
  task :remove_tmp do
    tasks = TaskQueue.new
    tasks.concat recursive_delete_and_ignore(File.join(RAILS_ROOT,'tmp'))
    tasks.add_msg "Committing..."
    tasks.add_cmd "svn commit #{RAILS_ROOT} -m 'Remove and ignore files from tmp/ (recursively, keep dirs)'"
    tasks.run(options)
  end
  
  desc "Remove and ignore files from log/ (recursively, keep dirs)"
  task :remove_log do
    tasks = TaskQueue.new
    tasks.concat recursive_delete_and_ignore(File.join(RAILS_ROOT,'log'))
    tasks.add_msg "Committing..."
    tasks.add_cmd "svn commit #{RAILS_ROOT} -m 'Remove and ignore files from log/ (recursively, keep dirs)'"
    tasks.run(options)
  end
  
  desc "Remove and ignore db/*.sqlite3"
  task :remove_sqlite3_database do
    tasks = TaskQueue.new
    tasks.concat remove_glob('db','*.sqlite3')
    tasks.add_msg "Committing..."
    tasks.add_cmd "svn commit #{RAILS_ROOT} -m 'Remove and ignore db/*.sqlite3'"
    tasks.run(options)
  end
  
  desc "Remove and ignore .git* (just in the root of the app)"
  task :remove_git do
    tasks = TaskQueue.new
    tasks.concat remove_glob('.','.git*')
    tasks.add_msg "Committing..."
    tasks.add_cmd "svn commit #{RAILS_ROOT} -m 'Remove and ignore .git* (just in the root of the app)'"
    tasks.run(options)
  end
  
  desc "Run each of the config file removal tasks"
  task :remove_config => ['remove_site_keys_rb','remove_database_yml','remove_deploy_rb']
  
  desc "Run all of the svn remove and ignore rake tasks"
  task :setup => ['remove_config','remove_tmp','remove_log','remove_sqlite3_database','remove_git']
  
  task :default => ['setup']
  
end

class TaskQueue < Array
  class Task < String 
    def message
      @command = false
      @message = true
      self
    end

    def command
      @message = false
      @command = true
      self
    end

    def message?
      @message
    end

    def command?
      @command
    end

    def to_vs
      (command? ? "Command: " : "Message: ") + self.to_s
    end
  end
  
  def add_msg(task)
    self << Task.new(task).message
  end

  def add_cmd(task)
    self << Task.new(task).command
  end

  def run(opt = nil)
    self.each do |t|
      if t.command?
        puts t.to_vs if opt[:verbose]
        system(t) unless opt[:simulate]
      else
        puts opt[:verbose] ? t.to_vs : t.to_s
      end
    end
  end
end

# recursively delete then ignore files
def recursive_delete_and_ignore(dir)
  tasks = TaskQueue.new
  tasks.add_msg "Removing and ignoring files from #{dir}"
  if File.directory?(dir)
    Dir.glob(dir + '/*').each do |d|
      if File.directory?(d) 
        tasks.concat recursive_delete_and_ignore(d)
      else
        tasks.add_cmd("svn rm --keep-local '#{d}'")
      end
    end
    tasks.add_cmd "svn propset svn:ignore '*' '#{dir}'"
  else
    tasks.add_msg "The #{dir} directory doesn't exist"
  end
  tasks
end

def remove_file_with_example(d,f)
  tasks = TaskQueue.new
  fp = File.join(RAILS_ROOT,d,f)
  tasks.add_msg "Copying #{f} to #{f}.example"
  if File.exists?(fp)
    tasks.add_cmd "svn cp #{fp} #{fp}.example"
    tasks.add_cmd "svn rm --keep-local #{fp}"
  else
    tasks.add_msg "The #{f} file doesn't exist"
  end  
  tasks.add_msg "Ignoring #{f}"
  ignores = [%x[svn propget svn:ignore '#{File.join(RAILS_ROOT,d)}'].strip, "#{f}"].select {|i| !i.blank? }.join('\n')
  tasks.add_cmd "echo -e #{ignores.dump} | svn propset svn:ignore -F - '#{File.join(RAILS_ROOT,d)}'"
  tasks
end

def remove_glob(d,f)
  tasks = TaskQueue.new
  fp = File.join(RAILS_ROOT,d,f)
  tasks.add_msg "Removing #{f} from #{d}"
  unless Dir.glob(fp).empty?
    tasks.add_cmd "svn rm --keep-local '#{fp}'"
  else
    tasks.add_msg "#{f} glob doesn't exist in #{d}"
  end
  tasks.add_msg "Ignoring #{f} on #{d}"
  tasks.add_cmd "svn propset svn:ignore '#{File.basename(fp)}' #{File.join(RAILS_ROOT,File.dirname(f))}"
  tasks
end

def help_text
  <<-help
    This script expects that you have a new rails app, and that everything
    has been submitted to the svn repo.

    The script will do the following:
    - recursively remove all files from log and recursively set ignore * on dirs
    - recursively remove all files from tmp and recursively set ignore * on dirs
    - move config/database.yml to config/database.yml.example and ignore database.yml
    - move config/deploy.rb to config/deploy.rb.example and ignore deploy.rb
    - remove db/*.sqlite3 and ignore them

    All file removal leaves the local copy (your local file is only deleted from the repo)

    Use the -s option to do a simulated run
    Use the --verbose option for verbose (show the commands being run)
  help
end