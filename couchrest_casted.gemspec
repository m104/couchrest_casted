# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name     = 'couchrest_casted'
  s.version  = `cat VERSION`.strip
  s.date     = '2012-01-10'
  s.authors  = ['Adam Collins']
  s.email    = 'adam@m104.us'
  s.homepage = 'https://github.com/m104/couchrest_casted'

  s.summary     = %q{Provides model casting methods for CouchRest::Database}
  s.description = %q{Adds methods to CouchRest::Database that automatically cast document JSON data as CouchRest::Model objects}

  s.require_paths = ['lib']
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.extra_rdoc_files = [
    'LICENSE',
    'VERSION',
    'README.md'
  ]

  s.required_rubygems_version = Gem::Requirement.new('> 1.3.1') if s.respond_to? :required_rubygems_version=

  s.add_dependency(%q<couchrest_model>, '~> 1.1')
  s.add_development_dependency(%q<rake>, '~> 0.9')
  s.add_development_dependency(%q<rspec>, '~> 2.8')
  s.add_development_dependency(%q<rdoc>, '~> 3.12')
end

