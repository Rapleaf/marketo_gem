Gem::Specification.new do |gem|
  gem.name        = "marketo"
  gem.summary     = "A client for using the marketo API"
  gem.description = <<-EOF
     Allows easy integration with marketo from ruby. You can synchronize leads and fetch them back by email. This is based on the SOAP wsdl file: http://app.marketo.com/soap/mktows/1_4?WSDL. More information at https://www.rapleaf.com/developers/marketo.
  EOF
  gem.email        = "james@rapleaf.com"
  gem.authors      = ["James O'Brien"]
  gem.homepage     = "https://www.rapleaf.com/developers/marketo"
  gem.files        = Dir['lib/**/*.rb']
  gem.require_path = ['lib']
  gem.test_files   = Dir['spec/**/*_spec.rb']
  gem.version      = "1.3.1"
  gem.has_rdoc     = true
  gem.rdoc_options << '--title' << 'Marketo Client Gem' << '--main' << 'Rapleaf::Marketo::Client'

  gem.add_development_dependency('rspec', '>= 2.3.0')
  gem.add_dependency('savon', '>= 0.8.3')
end
