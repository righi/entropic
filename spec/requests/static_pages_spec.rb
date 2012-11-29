require 'spec_helper'

describe "StaticPages" do
  
  describe "Home Page" do
    it "Should exist" do
      get "/index.html"
      response.status.should be(200) 

      get "/"
      response.status.should be(200) 
    end
  end

  describe "About Page" do
    it "Should exist" do
      get "/about/"
      response.status.should be(200) 
    end
  end
end
