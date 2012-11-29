require 'spec_helper'
require 'digest/sha2'

describe "API" do

  before do
    @uuid_regex = /^[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}$/
    @valid_sha512 = Digest::SHA512.hexdigest("")
  end

  def extract_json(callback_func_name) 
    regex = Regexp.new("^(#{callback_func_name}\\()(.*)(\\))$")
    JSON.parse(response.body.split(regex)[2])
  end

  describe "/api/uuid" do

    it "has a content-type of text/javascript" do
      get "/api/uuid?entropy=#{@valid_sha512}"
      response.header['Content-Type'].should match(/text\/javascript/)
    end

    it "requires an entropy param" do
      get "/api/uuid" # Missing required 'entropy' param
      response.status.should be(400)
    end

    it "requires that the entropy param be a valid SHA512 hex value, 128 characters in length" do
      entropy="123456789abcdef" # Too short
      get "/api/uuid?callback=xyz&entropy=#{entropy}"
      response.status.should be(400)

      entropy="#{@valid_sha512}123" # Too long
      get "/api/uuid?callback=xyz&entropy=#{entropy}"
      response.status.should be(400)

      entropy = @valid_sha512.gsub("a","x") # Illegal characters
      get "/api/uuid?callback=xyz&entropy=#{entropy}"
      response.status.should be(400)
    end

    it "returns proper json for errors" do
      get "/api/uuid?callback=xyz" # Missing required 'entropy' param
      json = extract_json("xyz")
      json.should have_key("error")
    end
    
    it "turns the jsonp param into a js function call with a propery uuid" do
      get "/api/uuid?callback=foobar&entropy=#{@valid_sha512}"
      response.status.should be(200)
      json = extract_json("foobar")
      json.should have_key("uuid")
      json["uuid"].should match(@uuid_regex)
    end
  end

end

