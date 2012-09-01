Gem::Specification.new do |s|
  s.name        = "hellno"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Norbert Crombach"]
  s.email       = ["norbert.crombach@primetheory.org"]
  s.homepage    = "http://github.com/norbert/hellno"
  s.summary     = %q{Unofficial Amen API client.}

  s.rubyforge_project = "hellno"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = s.files.grep(/^test\//)
  s.require_paths = ["lib"]

  s.add_dependency 'faraday'
  s.add_dependency 'faraday_middleware'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'webmoca'
end
