# -*- ruby -*-

require "rubygems"
require "hoe"

Hoe.plugin :doofus
Hoe.plugin :gemspec2
Hoe.plugin :git
Hoe.plugin :heroku
Hoe.plugin :minitest
Hoe.plugin :travis
Hoe.plugin :email unless ENV['CI'] or ENV['TRAVIS']

spec = Hoe.spec "marketo-api-ruby" do
  developer('Austin Ziegler', 'halostatue@gmail.com')
  self.need_tar = false
  self.require_ruby_version '>= 1.9.2'

  license 'MIT'

  self.history_file = 'History.rdoc'
  self.readme_file = 'README.rdoc'
  self.extra_rdoc_files = FileList["*.rdoc"].to_a

  self.extra_deps << ['savon', '~> 2.4']

  self.extra_dev_deps << ['hoe-doofus', '~> 1.0']
  self.extra_dev_deps << ['hoe-gemspec2', '~> 1.1']
  self.extra_dev_deps << ['hoe-git', '~> 1.6']
  self.extra_dev_deps << ['hoe-rubygems', '~> 1.0']
  self.extra_dev_deps << ['hoe-travis', '~> 1.2']
  self.extra_dev_deps << ['minitest', '~> 5.3']
  self.extra_dev_deps << ['rake', '~> 10.0']
  self.extra_dev_deps << ['simplecov', '~> 0.7']
  self.extra_dev_deps << ['coveralls', '~> 0.7']
end

namespace :test do
  desc "Submit test coverage to Coveralls"
  task :coveralls do
    spec.test_prelude = [
      'require "psych"',
      'require "simplecov"',
      'require "coveralls"',
      'SimpleCov.formatter = Coveralls::SimpleCov::Formatter',
      'SimpleCov.start("test_frameworks") { command_name "Minitest" }',
      'gem "minitest"'
    ].join('; ')
    Rake::Task['test'].execute
  end

  desc "Generate a test coverage report"
  task :coverage do
    spec.test_prelude = [
      'require "simplecov"',
      'SimpleCov.start("test_frameworks") { command_name "Minitest" }',
      'gem "minitest"'
    ].join('; ')
    Rake::Task['test'].execute
  end
end

Rake::Task['travis'].prerequisites.replace(%w(test:coveralls))

# vim: syntax=ruby
