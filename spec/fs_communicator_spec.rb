require File.dirname(__FILE__) + '/spec_helper'

module HttpCommunicatorHelper
  
  def stub_net_objects
    @request = mock("Net::HTTP::Get|Post")
    @request.stub!(:[]=)
    @request.stub!(:body=)
    @http = mock("Net::HTTP")
    Net::HTTP.stub!(:new).and_return(@http)
    Net::HTTP::Get.stub!(:new).and_return(@request)
    Net::HTTP::Post.stub!(:new).and_return(@request)
    @http.stub!(:use_ssl=)
    @http.stub!(:ca_file=)
    @http.stub!(:verify_mode=)
    @http.stub!(:start)
  end
  
end

describe FsCommunicator do
  include HttpCommunicatorHelper
  describe "initializing" do
    it "should accept a hash of options" do
      lambda {
        com = FsCommunicator.new :domain => 'https://api.familysearch.org', :key => '1111-1111', :user_agent => "FsCommunicator/0.1"
      }.should_not raise_error
    end
    
    it "should set defaults to the Reference System" do
      com = FsCommunicator.new
      com.domain.should == 'http://www.dev.usys.org'
      com.key.should == ''
      com.user_agent.should == 'FsCommunicator/0.1 (Ruby)'
    end
    
    it "should set the domain, key, and user_agent to options hash" do
      options = {
        :domain => 'https://api.familysearch.org', 
        :key => '1111-1111', 
        :user_agent => "RSpecTest/0.1",
        :session => 'SESSID'
      }
      com = FsCommunicator.new options
      com.domain.should == options[:domain]
      com.key.should == options[:key]
      com.user_agent.should == options[:user_agent]
      com.session.should == options[:session]
    end
  end
  
  describe "GET on a URL" do
    before(:each) do
      options = {
        :domain => 'https://api.familysearch.org', 
        :key => '1111-1111', 
        :user_agent => "FsCommunicator/0.1",
        :session => 'SESSID'
      }
      @com = FsCommunicator.new options
      stub_net_objects
      @url = '/familytree/v1/person/KWQS-BBQ'
      @session_url = @url + "?sessionId=#{@com.session}"
    end
    
    def do_get(url, credentials = {})
      @com.get(url, credentials)
    end
    
    it "should initialize a Net::HTTP object to make the request" do
      Net::HTTP.should_receive(:new).with('api.familysearch.org',443).and_return(@http)
      do_get(@url)
    end
    
    it "should create a GET request with url containing a session" do
      Net::HTTP::Get.should_receive(:new).with(@session_url).and_return(@request)
      do_get(@url)
    end
    
    it "should tack a sessionId as an additional parameter if params already set" do
      url = "/familytree/v1/person/KWQS-BBQ?view=summary"
      Net::HTTP::Get.should_receive(:new).with(url+"&sessionId=#{@com.session}").and_return(@request)
      do_get(url)
    end
    
    it "should set the http object to use ssl if https" do
      @http.should_receive(:use_ssl=).with(true)
      do_get(@url)
    end
    
    it "should not set the http object to use ssl if no http" do
      @com.domain = 'http://www.dev.usys.org'
      @http.should_not_receive(:use_ssl=)
      do_get(@url)
    end
    
    it "should set the ca file to the entrust certificate (for FamilySearch systems)" do
      @http.should_receive(:ca_file=).with(File.join(File.dirname(__FILE__),'..','lib','assets','entrust-ca.crt'))
      do_get(@url)
    end
    
    it "should set the basic_authentication if the credentials passed as parameters" do
      @request.should_receive(:basic_auth).with('user','pass')
      @request.should_receive(:[]=).with('User-Agent',@com.user_agent)
      Net::HTTP::Get.should_receive(:new).with(@url+"?key=#{@com.key}").and_return(@request)
      do_get(@url,:username => 'user',:password => 'pass')
    end
    
    it "should make the request" do
      block = lambda{ |ht|
        ht.request('something')
      }
      @http.should_receive(:start)
      do_get(@url)
    end
    
  end
  
  describe "POST on a URL" do
    before(:each) do
      options = {
        :domain => 'https://api.familysearch.org', 
        :key => '1111-1111', 
        :user_agent => "FsCommunicator/0.1",
        :session => 'SESSID'
      }
      @com = FsCommunicator.new options
      stub_net_objects
      @url = '/familytree/v1/person/KWQS-BBQ'
      @session_url = @url + "?sessionId=#{@com.session}"
      @payload = "<familytree></familytree>"
    end
    
    def do_post(url, payload = '')
      @com.post(url, payload)
    end
    
    it "should initialize a Net::HTTP object to make the request" do
      Net::HTTP.should_receive(:new).with('api.familysearch.org',443).and_return(@http)
      do_post(@url)
    end
    
    it "should create a POST request with url containing a session" do
      Net::HTTP::Post.should_receive(:new).with(@session_url).and_return(@request)
      do_post(@url)
    end
    
    it "should tack a sessionId as an additional parameter if params already set" do
      url = "/familytree/v1/person/KWQS-BBQ?view=summary"
      Net::HTTP::Post.should_receive(:new).with(url+"&sessionId=#{@com.session}").and_return(@request)
      do_post(url)
    end
    
    it "should set the request's body to the payload attached" do
      @request.should_receive(:body=).with(@payload)
      @request.should_receive(:[]=).with('Content-Type','text/xml')
      do_post(@url,@payload)
    end
    
    it "should set the http object to use ssl if https" do
      @http.should_receive(:use_ssl=).with(true)
      do_post(@url)
    end
    
    it "should not set the http object to use ssl if no http" do
      @com.domain = 'http://www.dev.usys.org'
      @http.should_not_receive(:use_ssl=)
      do_post(@url)
    end
    
    it "should set the ca file to the entrust certificate (for FamilySearch systems)" do
      @http.should_receive(:ca_file=).with(File.join(File.dirname(__FILE__),'..','lib','assets','entrust-ca.crt'))
      do_post(@url)
    end
        
    it "should make the request" do
      block = lambda{ |ht|
        ht.request('something')
      }
      @http.should_receive(:start)
      do_post(@url)
    end
    
  end
  
end