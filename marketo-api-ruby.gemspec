# -*- encoding: utf-8 -*-
# stub: marketo-api-ruby 0.9.1 ruby lib

Gem::Specification.new do |s|
  s.name = "marketo-api-ruby"
  s.version = "0.9.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Austin Ziegler"]
  s.date = "2014-06-10"
  s.description = "MarketoAPI (marketo-api-ruby) provides a native Ruby interface to the\n{Marketo SOAP API}[http://developers.marketo.com/documentation/soap/], using\n{savon}[https://github.com/savonrb/savon]. While understanding the Marketo SOAP\nAPI is necessary for using marketo-api-ruby, it is an explicit goal that\nworking with MarketoAPI not feel like working with a hinky Java port.\n\nThis is release 0.9.1, targeting Marketo API version\n{2.3}[http://app.marketo.com/soap/mktows/2_3?WSDL], fixing a +syncLead+ problem\nwhere +Id+, +Email+, and +ForeignSysPersonId+ are inconsistent with other\n+syncLead+ parameters. This fixes an issue with Marketo campaign methods.\n\nPlease note that Ruby 1.9.2 is not officially supported, but MarketoAPI will\ninstall on any version of Ruby 1.9.2 or later."
  s.email = ["halostatue@gmail.com"]
  s.extra_rdoc_files = ["Contributing.rdoc", "History.rdoc", "Licence.rdoc", "Manifest.txt", "README.rdoc", "Contributing.rdoc", "History.rdoc", "Licence.rdoc", "README.rdoc"]
  s.files = [".coveralls.yml", ".gemtest", ".hoerc", ".travis.yml", "Contributing.rdoc", "Gemfile", "History.rdoc", "Licence.rdoc", "Manifest.txt", "README.rdoc", "Rakefile", "lib/marketo-api-ruby.rb", "lib/marketo_api.rb", "lib/marketo_api/campaigns.rb", "lib/marketo_api/client.rb", "lib/marketo_api/client_proxy.rb", "lib/marketo_api/lead.rb", "lib/marketo_api/leads.rb", "lib/marketo_api/lists.rb", "lib/marketo_api/mobject.rb", "lib/marketo_api/mobjects.rb", "test/integration/test_leads.rb", "test/marketo_api/test_campaigns.rb", "test/marketo_api/test_client.rb", "test/marketo_api/test_lead.rb", "test/marketo_api/test_leads.rb", "test/marketo_api/test_lists.rb", "test/marketo_api/test_mobject.rb", "test/marketo_api/test_mobjects.rb", "test/minitest_helper.rb", "test/test_marketo_api.rb"]
  s.homepage = "https://github.com/ClearFit/marketo-api-ruby"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.rubygems_version = "2.2.1"
  s.summary = "MarketoAPI (marketo-api-ruby) provides a native Ruby interface to the {Marketo SOAP API}[http://developers.marketo.com/documentation/soap/], using {savon}[https://github.com/savonrb/savon]"
  s.test_files = ["test/integration/test_leads.rb", "test/marketo_api/test_campaigns.rb", "test/marketo_api/test_client.rb", "test/marketo_api/test_lead.rb", "test/marketo_api/test_leads.rb", "test/marketo_api/test_lists.rb", "test/marketo_api/test_mobject.rb", "test/marketo_api/test_mobjects.rb", "test/test_marketo_api.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<savon>, ["~> 2.4"])
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
      s.add_development_dependency(%q<hoe>, ["~> 3.12"])
    else
      s.add_dependency(%q<savon>, ["~> 2.4"])
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
      s.add_dependency(%q<hoe>, ["~> 3.12"])
    end
  else
    s.add_dependency(%q<savon>, ["~> 2.4"])
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
    s.add_dependency(%q<hoe>, ["~> 3.12"])
  end
end
