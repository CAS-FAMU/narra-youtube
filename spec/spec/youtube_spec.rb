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

require 'spec_helper'

describe Narra::Youtube::Connector do
  before(:all) do
    @url = 'https://www.youtube.com/watch?v=oHg5SJYRHA0'
  end

  it 'should have accessible fields' do
    expect(Narra::Youtube::Connector.identifier).to match(:youtube)
    expect(Narra::Youtube::Connector.title).to match('NARRA YouTube Connector')
    expect(Narra::Youtube::Connector.description).to match('Allows NARRA to connects to the YouTube sources')
  end

  it 'should validate url' do
    expect(Narra::Youtube::Connector.valid?('https://www.youtube.com/watch?v=qM9f01YYDJ4')).to match(true)
    expect(Narra::Youtube::Connector.valid?('www.youtube.com/watch?v=tDyeiePort0')).to match(true)
    expect(Narra::Youtube::Connector.valid?('https://www.youtube.com/watch?v=tDyeiePort0&spfreload=10')).to match(true)
    expect(Narra::Youtube::Connector.valid?('https://www.youtube.com/watch?v=qM9f01YYDJ4asdasdasdadasdasdasdasdaasdasdad')).to match(true) #redirect to good url
    expect { Narra::Youtube::Connector.valid?('www.youtube.com/watchv=tDyeiePort0') }.to raise_error StandardError
    expect(Narra::Youtube::Connector.valid?('https://www.youtube.com/watch?vtDyeiePort0')).to match(false)
    expect(Narra::Youtube::Connector.valid?('http://www.youtube.com/watch?v=tDyeiePort0')).to match(true)    #redirect to https://
    expect {Narra::Youtube::Connector.valid?('https:www.youtube.youtu.be.com/watch?v=tDyeiePort0')}.to raise_error StandardError
    expect(Narra::Youtube::Connector.valid?('https://www.youtube.com/watch?v=2gz3DSiSymE&feature=iv&src_vid=VxlQ2gqiZ7k&annotation_id=annotation_620965849')).to match(true)
    expect(Narra::Youtube::Connector.valid?('https://www.youtube.com/watch?t=12&v=Hw6_jEmVnN8')).to match(true)
    expect(Narra::Youtube::Connector.valid?('https://youtu.be/gfM1H3qW9WE')).to match(true)
    expect(Narra::Youtube::Connector.valid?('http://1url.cz/Fvoy')).to match(true)
  end
  
  it 'should resolve url' do
    video = Narra::Youtube::Connector.resolve(@url)
    expect(video).to be_an(Array)
    expect(video.length).to match(1)
    expect(video[0][:url]).to match(@url)
    expect(video[0][:name]).to match("RickRoll'D")
    expect(video[0][:thumbnail]).to match("http://img.youtube.com/vi/oHg5SJYRHA0/0.jpg")
    expect(video[0][:type]).to match(:video)
    expect(video[0][:connector]).to match(:youtube)
  end
  
end
