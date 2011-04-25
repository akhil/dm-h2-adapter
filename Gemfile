source "http://rubygems.org"
source "http://gemcutter.org"

# Specify your gem's dependencies in dm-h2-adapter.gemspec
#gemspec

do_options = {}
do_options[:git] = "#{DATAMAPPER}/do#{REPO_POSTFIX}" if ENV['DO_GIT'] == 'true'

gem 'do_h2', do_options.dup
gem 'dm-do-adapter'
gem 'rake'
gem 'rspec'
