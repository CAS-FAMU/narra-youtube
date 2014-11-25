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

require 'narra/spi'

module Narra
  module Youtube
    class Connector < Narra::SPI::Connector

      @identifier = :youtube
      @title = 'NARRA YouTube Connector'
      @description = 'Allows NARRA to connects to the YouTube sources'

      def self.valid?(url)
        # Nothing to do
        # This has to be overridden in descendants
      end

      def initialization
        # Nothing to do
        # This has to be overridden in descendants
      end

      def name
        # Nothing to do
        # This has to be overridden in descendants
      end

      def type
        # Nothing to do
        # This has to be overridden in descendants
      end

      def metadata
        # Nothing to do
        # This has to be overridden in descendants
      end

      def download_url
        # Nothing to do
        # This has to be overridden in descendants
      end

    end
  end
end
