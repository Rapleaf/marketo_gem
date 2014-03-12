Gem::Specification.new do |gem|
  gem.name        = "marketo"
  gem.summary     = "A client for the marketo API"
  gem.description = <<-EOF
     Allows easy integration with marketo from ruby. You can synchronize leads and fetch them back by email.
     By default this is configured for the SOAP wsdl file: http://app.marketo.com/soap/mktows/1_4?WSDL but this is
     configurable when you construct the client, e.g.
     client = Rapleaf::Marketo.new_client(<access_key>, <secret_key>, (api_subdomain = 'na-i'), (api_version = '1_5'), (document_version = '1_4'))
     More information at https://www.rapleaf.com/developers/marketo.
  EOF
  gem.email        = "james@rapleaf.com"
  gem.authors      = ["James O'Brien"]
  gem.homepage     = "https://www.rapleaf.com/developers/marketo"
  gem.files        = Dir['lib/**/*.rb']
  gem.require_path = ['lib']
  gem.test_files   = Dir['spec/**/*_spec.rb']
  gem.version      = "1.4.0"
  gem.has_rdoc     = true
  gem.rdoc_options << '--title' << 'Marketo Client Gem' << '--main' << 'Rapleaf::Marketo::Client'

  gem.add_development_dependency('rspec', '>= 2.3.0')
  gem.add_dependency('savon', '1.2.0')
end
