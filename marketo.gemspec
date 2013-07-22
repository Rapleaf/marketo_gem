Gem::Specification.new do |gem|
  gem.name        = "marketo"
  gem.summary     = "A client for the marketo API"
  gem.description = <<-EOF
     Allows easy integration with marketo from ruby. You can synchronize leads and fetch them back by email.
     Forked from the Rapleaf Marketo API Gem, with updates for Marketo API 2.x and Savon 2.x.
  EOF
  gem.email        = "joey@grabcad.com"
  gem.authors      = ["Joseph George"]
  gem.homepage     = "https://github.com/jgeorge-gc/marketo_gem"
  gem.files        = Dir['lib/**/*.rb']
  gem.require_path = ['lib']
  gem.test_files   = Dir['spec/**/*_spec.rb']
  gem.version      = "0.0.9"
  gem.has_rdoc     = true
  gem.rdoc_options << '--title' << 'Marketo Client Gem, updated' << '--main' << 'Grabcad::Marketo::Client'

  gem.add_development_dependency('rspec', '>= 2.3.0')
  gem.add_dependency('savon', '~> 2.2')
end
