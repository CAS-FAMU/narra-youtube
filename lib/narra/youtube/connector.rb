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
# Authors: Petr Pulc, Petr Kubin
#

require 'narra/core'
require 'net/http'
require 'json'
require 'narra/youtube/helpers/viddlyt'

module Narra
  module Youtube

    class Connector < Narra::SPI::Connector

      # basic init
      # params: none
      @identifier = :youtube
      @title = 'NARRA YouTube Connector'
      @description = 'Allows NARRA to connects to the YouTube sources'


      # validation
      # params: url (string)
      # returns bool value ( true / false )
      def self.valid?(url)
        url = fetch(url)
      
        # check if valid YouTube watch url (TODO playlists and users not yet supported)
        !!(url =~ /^(?:http:\/\/|https:\/\/)?(www\.)?(youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))((\w|-){6,11})(\S*)?$/)
      end

      def self.resolve(url, key = '')
        final_url = Connector.fetch(url)
        key = "AIzaSyBVYtP85g7VCilGKbzkQqPCf8CxokAfvhU" if key == ''
        
        videoid = final_url.split('v=')[1].split('&')[0]
        uri = URI("https://www.googleapis.com/youtube/v3/videos?id=#{videoid}&key=#{key}&part=snippet,statistics,contentDetails,status")
        
        metadata = JSON.parse(Net::HTTP.get(uri))["items"][0]
        
        # return proxies
        [{
             url: final_url,
             name: metadata["snippet"]["title"],
             thumbnail: "http://img.youtube.com/vi/#{videoid}/0.jpg",
             type: :video,
             connector: @identifier,
             author: true,
             @identifier => {
                 final_url: final_url,
                 metadata: metadata
             }
         }]
      end


      # redirection test
      # params: uri_str (string), limit fixed to 20
      # returns new url with 200 status or ArgumentError
      def self.fetch(uri_str, limit = 20)
        # You should choose a better exception.
        raise ArgumentError, 'Too many HTTP redirects' if limit == 0
        raise ArgumentError, 'Invalid url passed' if uri_str.nil?
        
        redirect_history = []

        unless uri_str.start_with?('http://','https://')
          uri_str.prepend('http://')
        end
        for i in 0..limit
          return uri_str if redirect_history.include? uri_str
          uri = URI(uri_str)
          response = nil
          Net::HTTP.start(uri.host, uri.port,
            :use_ssl => uri.scheme == 'https') {|http|
            request = Net::HTTP::Head.new uri
            response = http.request request
          }
          return uri_str if response.is_a? Net::HTTPSuccess
          raise StandardError, 'HTTP code 4xx or 5xx' unless response.is_a? Net::HTTPRedirection
          redirect_history << uri_str
          uri_str = response['location']
        end
      end

      # initialization
      # (@options passed from resolver)
      # returns @youtube (json object)
      def initialization
        @final_url = @options[:final_url]
        @meta = @options[:metadata]
      end

      # name
      # params: none
      # returns name of video
      def name
        # jmeno video na youtube | title
        @meta["snippet"]["title"]
      end

      # type
      # params: none
      # returns :video
      def type
        :video
      end

      # metadata
      # params: none
      # returns Array
      def metadata
        d = []
        
        d << {name:'channelId', value:"#{@meta["snippet"]["channelId"]}"}
        d << {name:'channelTitle', value:"#{@meta["snippet"]["channelTitle"]}"}
        d << {name:'author', value:"#{@meta["snippet"]["channelTitle"]}"}
        d << {name:'publishedAt', value:"#{@meta["snippet"]["publishedAt"]}"}
        d << {name:'description', value:"#{@meta["snippet"]["description"]}"} unless "#{@meta["snippet"]["description"]}".empty?
        d << {name:'categoryId', value:"#{@meta["snippet"]["categoryId"]}"} unless "#{@meta["snippet"]["categoryId"]}".empty?
        d << {name:'liveBroadcastContent', value:"#{@meta["snippet"]["liveBroadcastContent"]}"}
        d << {name:'viewCount', value:"#{@meta["statistics"]["viewCount"]}"}
        d << {name:'likeCount', value:"#{@meta["statistics"]["likeCount"]}"}
        d << {name:'dislikeCount', value:"#{@meta["statistics"]["dislikeCount"]}"}
        d << {name:'favouriteCount', value:"#{@meta["statistics"]["favouriteCount"]}"} unless "#{@meta["statistics"]["favouriteCount"]}".empty?
        d << {name:'commentCount', value:"#{@meta["statistics"]["commentCount"]}"}
        d << {name:'duration', value:"#{@meta["contentDetails"]["duration"]}"}
        d << {name:'dimension', value:"#{@meta["contentDetails"]["dimension"]}"}
        d << {name:'definition', value:"#{@meta["contentDetails"]["definition"]}"}
        d << {name:'caption', value:"#{@meta["contentDetails"]["caption"]}"}
        d << {name:'licensedContent', value:"#{@meta["contentDetails"]["licensedContent"]}"}
        d << {name:'regionRestriction', value:"#{@meta["contentDetails"]["regionRestriction"]}"} unless "#{@meta["contentDetails"]["regionRestriction"]}".empty?
        d << {name:'blockedIn', value:"#{@regionRestriction["blocked"]}"} unless @meta["contentDetails"]["regionRestriction"].nil?
        d << {name:'uploadStatus', value:"#{@meta["status"]["processed"]}"} unless "#{@meta["status"]["processed"]}".empty?
        d << {name:'privacyStatus', value:"#{@meta["status"]["privacyStatus"]}"}
        d << {name:'license', value:"#{@meta["status"]["license"]}"}
        d << {name:'embeddable', value:"#{@meta["status"]["embeddable"]}"}
        d << {name:'publicStatsViewable', value:"#{@meta["status"]["publicStatsViewable"]}"}
        d << {name:'timestamp', value:"#{Time.now.getutc}"}

        #unused
        #@meta["snippet"]["id"]
      end
      
      def download_url
        ViddlYt.get_video_url @final_url
      end
    end
  end
end
