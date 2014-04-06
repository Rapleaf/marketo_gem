# -*- encoding: utf-8 -*-
# stub: marketo-api-ruby 0.8 ruby lib

Gem::Specification.new do |s|
  s.name = "marketo-api-ruby"
  s.version = "0.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Austin Ziegler"]
  s.date = "2014-04-07"
  s.description = "marketo-api-ruby provides a Ruby interface to\n{Marketo}[http://developers.marketo.com/documentation/soap/], using\n{savon}[https://github.com/savonrb/savon]. This release targets Marketo API\nversion {2.3}[http://app.marketo.com/soap/mktows/2_3?WSDL].\n\nThis version of marketo-api-ruby does not support stream positioning."
  s.email = ["halostatue@gmail.com"]
  s.extra_rdoc_files = ["Contributing.rdoc", "History.rdoc", "Licence.rdoc", "Manifest.txt", "README.rdoc", "Contributing.rdoc", "History.rdoc", "Licence.rdoc", "README.rdoc"]
  s.files = [".gemtest", "Contributing.rdoc", "Gemfile", "History.rdoc", "Licence.rdoc", "Manifest.txt", "README.rdoc", "Rakefile", "lib/marketo-api-ruby.rb", "lib/marketo_api.rb", "lib/marketo_api/campaigns.rb", "lib/marketo_api/client.rb", "lib/marketo_api/client_proxy.rb", "lib/marketo_api/lead.rb", "lib/marketo_api/leads.rb", "lib/marketo_api/lists.rb", "lib/marketo_api/mobject.rb", "lib/marketo_api/mobjects.rb", "spec/marketo/authentication_header_spec.rb", "spec/marketo/client_spec.rb", "spec/marketo/lead_key_spec.rb", "spec/marketo/lead_record_spec.rb", "spec/spec_helper.rb", "test/minitest_helper.rb", "test/test_marketorb.rb"]
  s.homepage = "https://github.com/halostatue/marketo-api-ruby"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.rubygems_version = "2.2.2"
  s.summary = "marketo-api-ruby provides a Ruby interface to {Marketo}[http://developers.marketo.com/documentation/soap/], using {savon}[https://github.com/savonrb/savon]"
  s.test_files = ["test/test_marketorb.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<savon>, ["~> 2.4"])
      s.add_runtime_dependency(%q<hashie>, ["~> 2.0"])
      s.add_development_dependency(%q<minitest>, ["~> 5.3"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<hoe-doofus>, ["~> 1.0"])
      s.add_development_dependency(%q<hoe-gemspec2>, ["~> 1.1"])
      s.add_development_dependency(%q<hoe-git>, ["~> 1.6"])
      s.add_development_dependency(%q<hoe-rubygems>, ["~> 1.0"])
      s.add_development_dependency(%q<hoe-travis>, ["~> 1.2"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.7"])
      s.add_development_dependency(%q<coveralls>, ["~> 0.7"])
      s.add_development_dependency(%q<hoe>, ["~> 3.11"])
    else
      s.add_dependency(%q<savon>, ["~> 2.4"])
      s.add_dependency(%q<hashie>, ["~> 2.0"])
      s.add_dependency(%q<minitest>, ["~> 5.3"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<hoe-doofus>, ["~> 1.0"])
      s.add_dependency(%q<hoe-gemspec2>, ["~> 1.1"])
      s.add_dependency(%q<hoe-git>, ["~> 1.6"])
      s.add_dependency(%q<hoe-rubygems>, ["~> 1.0"])
      s.add_dependency(%q<hoe-travis>, ["~> 1.2"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<simplecov>, ["~> 0.7"])
      s.add_dependency(%q<coveralls>, ["~> 0.7"])
      s.add_dependency(%q<hoe>, ["~> 3.11"])
    end
  else
    s.add_dependency(%q<savon>, ["~> 2.4"])
    s.add_dependency(%q<hashie>, ["~> 2.0"])
    s.add_dependency(%q<minitest>, ["~> 5.3"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<hoe-doofus>, ["~> 1.0"])
    s.add_dependency(%q<hoe-gemspec2>, ["~> 1.1"])
    s.add_dependency(%q<hoe-git>, ["~> 1.6"])
    s.add_dependency(%q<hoe-rubygems>, ["~> 1.0"])
    s.add_dependency(%q<hoe-travis>, ["~> 1.2"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<simplecov>, ["~> 0.7"])
    s.add_dependency(%q<coveralls>, ["~> 0.7"])
    s.add_dependency(%q<hoe>, ["~> 3.11"])
  end
end
