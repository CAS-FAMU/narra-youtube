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
# Authors:
#

require 'spec_helper'

describe Narra::Youtube::Connector do
  before(:each) do
    # test url
    @url = 'http://www.youtube.com'
  end

  it 'can be instantiated' do
    expect(Narra::Youtube::Connector.new(@url)).to be_an_instance_of(Narra::Youtube::Connector)
  end

  it 'should have accessible fields' do
    expect(Narra::Youtube::Connector.identifier).to match(:youtube)
    expect(Narra::Youtube::Connector.title).to match('NARRA YouTube Connector')
    expect(Narra::Youtube::Connector.description).to match('Allows NARRA to connects to the YouTube sources')
  end
end
