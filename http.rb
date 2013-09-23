require File.dirname(__FILE__) + '/query'
require 'net/http'
require 'json'
require 'base64'
require 'mime/types'

module Request
  extend self

  TYPE = {json: 'application/json',
          form: 'application/x-www-form-urlencoded',
          html: 'text/html'}

  def self.create url
    Client.new(url)
  end

  class Client
    attr_accessor :data, :headers, :files
    attr_reader :client, :url

    def initialize(url)
      @data = {}
      @headers = {}
      @files = []
      self.url = url
      @client = Net::HTTP.new(uri.hostname, uri.port)
    end

    def url= url
      # if not schema is given, default is `http`
      @url = (url['://'] ? '' : 'http://') << url
    end

    def uri
      @uri ||= URI(url).tap do |u|
        # If the url is something like this: http://user:password@localhost",
        # we setup the basic authorization header.
        auth(u.user, u.password) if u.user and u.password
      end
    end

    def auth user, pass
      # setup basic auth header
      set "Authorization" => "Basic #{Base64.encode64(user + ":" + pass).chop}"
    end

    def get
      # Reformat the url based on the query,
      # then send a get request.
      unless data.empty?
        url << "?" unless url["?"]
        url << data.to_query
        @uri = nil
      end
      client.get uri.request_uri, headers
    end

    def post
      # According the `Content-Type` header,
      # convert the hash data to url query string or json.
      if not files.empty? or @multi
        m = Multipart.create(files, data)
        client.post uri.request_uri, m.body, headers.merge(m.header)
      elsif headers['Content-Type'] == TYPE[:json]
        client.post uri.request_uri, data.to_json, headers
      else
        client.post uri.request_uri, data.to_query, headers
      end
    end

    def query option
      data.merge! option
      self
    end
    alias_method :send, :query

    def set option
      headers.merge! option
      self
    end
    alias_method :header, :set

    def upload field, file, filename = nil
      # application/octet-stream
      file = File.open(file)
      @files << [field, file, filename || file.path]
      self
    end
    alias_method :attach, :upload

    def write body
      @body ||= ''
      @body << body
      self
    end

    def type t
      # Set `Content-Type` header
      tp = t.to_sym
      t = TYPE[tp] if TYPE[tp]
      set "Content-Type" => t
    end

    def multi
      @multi = true
    end

    def json
      # Set Content-Type = application/json
      type TYPE[:json]
    end

    def form
      # Set Content-Type = application/x-www-form-urlencoded
      type TYPE[:form]
    end
  end

  module Multipart
    BOUNDARY = "--ruby-request--"
    DEFAULT_MIME = "application/octet-stream"

    def self.create files, data
      Fields.new(files, data)
    end

    class Fields
      def initialize files, data
        @files = files || []
        @params = data || []
      end

      def body
        return @body if @body
        @body = '' << @files.inject("") { |acc, file|
          acc << Attachment.new(*file).part
        } << @params.inject("") { |acc, param|
          acc << Param.new(*param).part
        } << "--#{BOUNDARY}--\r\n\r\n"
      end

      def header
        @header ||= {"Content-Length" => @body.bytesize.to_s,
                     "Content-Type"   => "multipart/form-data; boundary=#{BOUNDARY}"}
      end
    end

    class Attachment < Struct.new(:field, :file, :filename)
      def part
        return @part if @part
        type = ::MIME::Types.type_for(filename).first || DEFAULT_MIME
        @part = ''
        @part << "--#{BOUNDARY}\r\n"
        @part << "Content-Disposition: form-data; name=\"#{field}\"; filename=\"#{filename}\"\r\n"
        @part << "Content-Type: #{type}\r\n\r\n"
        @part << "#{file.read}\r\n"
        @part << "--#{BOUNDARY}--\r\n\r\n"
      end
    end

    class Param < Struct.new(:field, :value)
      def part
        return @part if @part
        @part = ''
        @part << "--#{BOUNDARY}\r\n"
        @part << "Content-Disposition: form-data; name=\"#{field}\"\r\n"
        @part << "\r\n"
        @part << "#{value}\r\n"
      end
    end
  end
end

# API
# def request url
#   Request::Client.new(url)
# end
# url = "http://httpbin.org/headers"

url = "http://localhost:4567/upload"
p Request.create(url).send(x: 1).attach("file", "./Gemfile").post.body


# p request(url).get.body
# p JSON.parse(request(url).json.query("p" => 12).get.body)
# url = "http://localhost:4567/headers"
# p JSON.parse(request(url).json.query("p" => 12).get.body)
# p JSON.parse(request(url).query("p" => 12).post.body)
