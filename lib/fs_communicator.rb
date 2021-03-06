require 'net/https'
require 'uri'

class FsCommunicator
  attr_accessor :domain, :key, :user_agent, :session
  
  def initialize(options = {})
    # merge default options with options hash
    o = {
      :domain => 'http://www.dev.usys.org',
      :key => '',
      :user_agent => 'FsCommunicator/0.1 (Ruby)',
      :session => nil
    }.merge(options)
    @domain = o[:domain]
    @key = o[:key]
    @user_agent = o[:user_agent]
    @session = o[:session]
  end
  
  def post(url,payload)
    uri = URI.parse(self.domain+url)
    full_url = set_extra_params(uri)
    request = Net::HTTP::Post.new(full_url)
    request.body = payload
    request['Content-Type'] = "text/xml"
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == 'https'
      http.use_ssl = true 
      http.ca_file = File.join File.dirname(__FILE__), 'assets','entrust-ca.crt'
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end
    res = http.start do |ht|
      ht.request(request)
    end
  end
  
  def get(url,credentials = {})
    uri = URI.parse(self.domain+url)
    full_url = set_extra_params(uri,credentials)
    request = Net::HTTP::Get.new(full_url)
    if credentials[:username] && credentials[:password]
      request.basic_auth credentials[:username], credentials[:password]
      request['User-Agent'] = self.user_agent
    end
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == 'https'
      http.use_ssl = true 
      http.ca_file = File.join File.dirname(__FILE__), 'assets','entrust-ca.crt'
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end
    res = http.start do |ht|
      ht.request(request)
    end
  end
  
  private
  def set_extra_params(uri,credentials = {})
    if credentials[:username] && credentials[:password]
      sessionized_url = add_key(uri)
    else
      sessionized_url = add_session(uri)
    end
  end
  
  def add_session(uri)
    if uri.query
      uri.query << '&sessionId=' + self.session
    else
      uri.query = 'sessionId=' + self.session
    end
    uri.request_uri
  end
  
  def add_key(uri)
    if uri.query
      uri.query << '&key=' + self.key
    else
      uri.query = 'key=' + self.key
    end
    uri.request_uri
  end
end