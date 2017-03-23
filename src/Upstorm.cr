require "file"
require "process"
require "http/server"
require "./Upstorm/*"

module Upstorm

  # get user input from command line
  def get_user_input(message : String|Nil = nil, suppress_output = false)
    if message.nil?
      print "Enter a version ([q|quit] to exit): " if !suppress_output
    else
      print message if !suppress_output
    end
    STDIN.gets.to_s
  end

  # parse url w/ version 
  def parse_url(url : String, version : String)
      url.gsub("[[VERSION]]", version)
  end

  # sends a head request
  # check for a valid url response based on status code and content type
  def url_response(url : String, status_code : Int32, content_type : String)
    response = HTTP::Client.head(url)
    if response.status_code == status_code && !response.headers["Content-Type"].nil? &&
      response.headers["Content-Type"] == content_type
      true
    else
      false
    end
  end

end