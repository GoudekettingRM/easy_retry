# frozen_string_literal: true

require_relative 'lib/easy_retry/version'

Gem::Specification.new do |spec|
  spec.name = 'easy_retry'
  spec.version = EasyRetry::VERSION
  spec.authors = ['Robin Goudeketting, Peter Duijnstee']
  spec.email = ['robin@goudeketting.nl']

  spec.summary = 'Easily retry a block of code a predetermined number of times'
  spec.description = 'Easily retry a block of code a predetermined number of times'
  spec.homepage = 'https://github.com/GoudekettingRM/easy_retry'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/GoudekettingRM/easy_retry'
  spec.metadata['changelog_uri'] = 'https://github.com/GoudekettingRM/easy_retry/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'logger', '~> 1.5.1'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
