Gem::Specification.new do |s|
  s.name = 'toggl_cli'
  s.version = '1.1.0'
  s.files = ["lib/toggl_cli.rb"]
  s.summary = "A simple command line tool for toggl"
  s.authors = ["Blake Erickson"]
  s.license = 'MIT'
  s.homepage = 'https://github.com/oblakeerickson/toggl_cli'
  s.executables = ['toggl_cli']
  s.add_dependency 'togglv8', '~> 1.2'
end
