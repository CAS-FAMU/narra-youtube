#
# Copyright (C) 2014 CAS / FAMU
#
# This file is part of Narra Core.
#
# Narra Core is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Narra Core is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Narra Core. If not, see <http://www.gnu.org/licenses/>.
#
# Authors: Petr Pulc, Petr Kubín
#

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'narra/youtube/version'

Gem::Specification.new do |spec|
  spec.name          = "narra-youtube"
  spec.version       = Narra::Youtube::VERSION
  spec.authors       = ["Petr Pulc", "Petr Kubín"]
  spec.email         = ["puclpetr@gmail.com", "kubinpe5@fit.cvut.cz"]
  spec.summary       = %q{NARRA YouTube Connector}
  spec.description   = %q{Allows NARRA to connects to the YouTube sources}
  spec.homepage      = "http://www.narra.eu"
  spec.license       = "GPL-3.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "rspec-mocks"
  spec.add_development_dependency "mongoid-tree"
  spec.add_development_dependency "mongoid-rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "factory_girl_rails"
  
  spec.add_runtime_dependency "rest-client"
  spec.add_runtime_dependency "multi_json"
end
