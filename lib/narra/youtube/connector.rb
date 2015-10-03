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
# Authors: Petr Kubin
#

require 'narra/core'
require 'net/http'
require 'json'

module Narra
  module Youtube

    class Connector < Narra::SPI::Connector

      # basic init
      # params: none
      @identifier = :youtube
      @title = 'NARRA YouTube Connector'
      @description = 'Allows NARRA to connects to the YouTube sources'

      # redirection test
      # params: uri_str (string), limit fixed to 20
      # returns new url with 200 status or ArgumentError
      def self.fetch(uri_str, limit = 20)
        # You should choose a better exception.
        raise ArgumentError, 'too many HTTP redirects' if limit == 0
        raise ArgumentError, 'Invalid url passed' if uri_str.nil?
        # vytvořit pole
        redirect_history = []
        # nekonečkou smyčku
        unless uri_str.start_with?('http://','https://')
          uri_str.prepend('http://')
        end
        for i in 0..limit
          return uri_str if redirect_history.include? uri_str
          response = Net::HTTP.get_response(URI(uri_str))
          return uri_str if response.is_a? Net::HTTPSuccess
          raise StandardError, 'Error code between 4xx and 5xx' unless response.is_a? Net::HTTPRedirection
          redirect_history << uri_str
          uri_str = response['location']
        end
      end

      # validation
      # params: url (string)
      # returns bool value ( true / false )
      def self.valid?(url)
        url = fetch(url)
      rescue ArgumentError => a
        raise ArgumentError, 'Invalid url passed'
      rescue StandardError => e
        raise StandardError, 'Error code between 4xx and 5xx'
      else
        # this runs only when no exception was raised
        # regular expression of youtube url - validation test
        !!(url =~ /^(?:http:\/\/|https:\/\/)?(www\.)?(youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))((\w|-){6,11})(\S*)?$/)
      end

      # getId
      # params: url (string)
      # returns @videoid (string)
      def getId(url)
        pom = url.split('v=')
        pom[1].split('&')[0]
      end

      # initialize
      # params: url (string)
      # returns @youtube (json object)
      def initialize(url, key = '')
        unless key != ''
          @mykey = "AIzaSyBVYtP85g7VCilGKbzkQqPCf8CxokAfvhU"
        else
          @mykey = key
        end
        # all description from YouTube API
        url = self.class.fetch(url)
        @videoid = getId(url)
        uri = URI("https://www.googleapis.com/youtube/v3/videos?id=#{@videoid}&key=#{@mykey}&part=snippet,statistics,contentDetails,status")
        @youtube = Net::HTTP.get(uri)
        @my_hash = JSON.parse(@youtube)["items"][0]
      end

      # name
      # params: none
      # returns name of video
      def name
        # jmeno video na youtube | title
        @my_hash["snippet"]["title"]
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

        # snippet part
        #channelId
        @channelId = @my_hash["snippet"]["channelId"]
        #channelTitle
        @channelTitle = @my_hash["snippet"]["channelTitle"]
        #id
        @id = @my_hash["snippet"]["id"]
        #publishedAt
        @publishedAt = @my_hash["snippet"]["publishedAt"]
        #description
        @my_description = @my_hash["snippet"]["description"]
        #categoryId
        @categoryId = @my_hash["snippet"]["categoryId"]
        #liveBroadcastContent
        @liveBroadcastContent = @my_hash["snippet"]["liveBroadcastContent"]

        # statistics part
        #viewCount
        @viewCount = @my_hash["statistics"]["viewCount"]
        #likeCount
        @likeCount = @my_hash["statistics"]["likeCount"]
        #dislikeCount
        @dislikeCount = @my_hash["statistics"]["dislikeCount"]
        #favouriteCount
        @favoriteCount = @my_hash["statistics"]["favouriteCount"]
        #commentCount
        @commentCount = @my_hash["statistics"]["commentCount"]

        # content details part
        #duration
        @duration = @my_hash["contentDetails"]["duration"]
        #dimension
        @dimension = @my_hash["contentDetails"]["dimension"]
        #definition
        @definition = @my_hash["contentDetails"]["definition"]
        #caption
        @caption = @my_hash["contentDetails"]["caption"]
        #licensedContent
        @licensedContent = @my_hash["contentDetails"]["licensedContent"]
        #regionRestriction
        @regionRestriction = @my_hash["contentDetails"]["regionRestriction"]
        @blockedIn = @regionRestriction["blocked"] unless @regionRestriction.nil?

        # status part
        #uploadStatus
        @uploadStatus = @my_hash["status"]["processed"]
        #privacyStatus
        @privacyStatus = @my_hash["status"]["privacyStatus"]
        #licence
        @license = @my_hash["status"]["license"]
        #embeddable
        @embeddable = @my_hash["status"]["embeddable"]
        #publicStatsViewable
        @publicStatsViewable = @my_hash["status"]["publicStatsViewable"]

        #time when the metadata were added
        @time = Time.now.getutc

        data = []

        data << {name:'videoId', value:"#{@videoid}"}
        data << {name:'channelId', value:"#{@channelId}"}
        data << {name:'channelTitle', value:"#{@channelTitle}"}
        data << {name:'publishedAt', value:"#{@publishedAt}"}
        data << {name:'description', value:"#{@my_description}"} unless "#{@my_description}".empty?
        data << {name:'categoryId', value:"#{@categoryId}"} unless "#{@categoryId}".empty?
        data << {name:'liveBroadcastContent', value:"#{@liveBroadcastContent}"}
        data << {name:'viewCount', value:"#{@viewCount}"}
        data << {name:'likeCount', value:"#{@likeCount}"}
        data << {name:'dislikeCount', value:"#{@dislikeCount}"}
        data << {name:'favouriteCount', value:"#{@favouriteCount}"} unless "#{@favouriteCount}".empty?
        data << {name:'commentCount', value:"#{@commentCount}"}
        data << {name:'duration', value:"#{@duration}"}
        data << {name:'dimension', value:"#{@dimension}"}
        data << {name:'definition', value:"#{@definition}"}
        data << {name:'caption', value:"#{@caption}"}
        data << {name:'licensedContent', value:"#{@licensedContent}"}
        data << {name:'regionRestriction', value:"#{@regionRestriction}"} unless "#{@regionRestriction}".empty?
        data << {name:'blockedIn', value:"#{@blockedIn}"} unless "#{@blockedIn}".empty?
        data << {name:'uploadStatus', value:"#{@uploadStatus}"} unless "#{@uploadStatus}".empty?
        data << {name:'privacyStatus', value:"#{@privacyStatus}"}
        data << {name:'license', value:"#{@license}"}
        data << {name:'embeddable', value:"#{@embeddable}"}
        data << {name:'publicStatsViewable', value:"#{@publicStatsViewable}"}
        data << {name:'timestamp', value:"#{@time}"}
      end

      # download_url
      # params: none; must be called after valid? and initialize
      # returns URL for video stream
      def download_url
        env = ENV["NARRA_YOUTUBE_SERVER"]
        raise StandardError, 'Non existing video passed' if ( @videoid.nil? || env.nil? )
      rescue StandardError => e
        raise StandardError, 'Non existing video passed'
      else
        "#{env}/youtube_dl?id=#{@videoid}"
      end

      # download_url
      # params: none; must be called after valid? and initialize
      # returns URL for downloading video; login required!!
      def download_captions
        raise StandardError, 'This video has no title' if @caption == "false"
      rescue StandardError => e
        raise StandardError, 'This video has no title'
      else
        "https://www.googleapis.com/youtube/v3/captions/#{@videoid}"
      end

    end
  end
end
