require 'narra/youtube/helpers/cipher_io'
require 'narra/youtube/helpers/decipherer'
require 'narra/youtube/helpers/cipher_guesser'
require 'narra/youtube/helpers/decipher_coordinator'
require 'narra/youtube/helpers/video_resolver'
require 'narra/youtube/helpers/format_picker'

module ViddlYt
  def self.get_video_url(url)
    @cipher_io      = CipherIO.new
    coordinator     = DecipherCoordinator.new(Decipherer.new(@cipher_io), CipherGuesser.new)
    @video_resolver = VideoResolver.new(coordinator)
    @format_picker  = FormatPicker.new

    video = get_videos(url)
    
    return nil if video == nil
    
    format = @format_picker.pick_format(video)
    video.get_download_url(format.itag)
  end
  
  def self.get_videos(url)
    begin
      @video_resolver.get_video(url)
    rescue VideoResolver::VideoRemovedError
      puts "The video #{url} has been removed."
      nil
    rescue => e
      puts "Error getting the video: #{e.message}"
      nil
    end
  end
end
