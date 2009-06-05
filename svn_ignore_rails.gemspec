spec = Gem::Specification.new do |s|
  s.name = "svn_ignore_rails"
  s.version = "1.0.2"
  s.author = "Pol Llovet"
  s.email = "pol.llovet+code@gmail.com"
  s.homepage = "http://github.com/pol/svn_ignore_rails"
  s.platform = Gem::Platform::RUBY
  s.summary = "Rails generator for svn ignore rake tasks"
  s.description = "Rails generator for svn ignore rake tasks"
  s.files = %w(
    .document
    generators/svn_ignore
    generators/svn_ignore/svn_ignore_rails_generator.rb
    generators/svn_ignore/templates/svn_ignore.rake
    History.rdoc
    init.rb
    License.txt
    Manifest.txt
    Rakefile
    README.rdoc
    TODO.txt
    Upgrade.rdoc
  )
  s.extra_rdoc_files = %w( License.txt )
  s.require_paths = ["lib"]
  s.has_rdoc = true
  s.rdoc_options = %w'--inline-source --line-numbers README generators'
end