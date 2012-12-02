require 'spec_helper'
require 'digest/sha2'

describe Swimmer do

  before do
    @valid_sha512 = Digest::SHA512.hexdigest("")
  end

  describe "Initializtion" do
    it "should initialize itself with a default hashcode" do
      swimmer = Swimmer.new
      swimmer.hashcode.should match($SHA512_REGEX)
    end

    it "should require a valid hashcode" do
      FactoryGirl.build(:swimmer, :hashcode => "").should_not be_valid
    end

    it "should reject hashcodes that are too short" do
      FactoryGirl.build(:swimmer, :hashcode => "123456789abcdef").should_not be_valid
    end

    it "should reject hashcodes that are too long" do
      FactoryGirl.build(:swimmer, :hashcode => "#{@valid_sha512}abcd").should_not be_valid
    end

    it "should reject hashcodes that have illegal characters" do
      FactoryGirl.build(:swimmer, :hashcode => "#{@valid_sha512.gsub('a','x')}").should_not be_valid
    end

    it "should allow hashcodes that are valid, 128-character long hex values" do
      FactoryGirl.build(:swimmer, :hashcode => "#{@valid_sha512}").should be_valid
    end
  end

  describe "mixing new entropy" do
    
    before do
      @swimmer = FactoryGirl.build(:swimmer)
    end

    it "should have a mix method" do
      @swimmer.should respond_to(:mix).with(1).argument
    end

    it "should fail when fresh_blood is nil" do
      expect { @swimmer.mix(nil) }.to raise_error(ArgumentError) 
    end

    it "should fail when fresh_blood is an empty string" do
      expect { @swimmer.mix("") }.to raise_error(ArgumentError) 
    end
    
    it "should contain a different value after fresh_blood is mixed in" do
      hash_before = @swimmer.hashcode
      @swimmer.mix(Time.now)
      @swimmer.hashcode.should_not eql(hash_before)
    end

    it "should behave deterministally" do
     
      sha512_empty_string = "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e"
      fresh_blood = "Hello World"
      
      @time_now = Time.new(2007,11,5,13,45,0, "-05:00")
      Time.stub!(:now).and_return(@time_now)
      
      expected_hash = "cae659b8c757d5f5dfb24eccf0a799a9539d1900c11c3dd5c597df34ab05346b84fb6d8e724f24d414cda3ee212f6353a8625d63fcfddb25a95f084d51ac7b58"
      
      @swimmer = FactoryGirl.build(:swimmer, :hashcode => sha512_empty_string)
      @swimmer.mix("Hello World")
      @swimmer.hashcode.should eql(expected_hash)
    end

    it "should only accept classes that define their own to_s method" do
      expect { @swimmer.mix(ClassWithNoToString.new) }.to raise_error(ArgumentError)
      expect { @swimmer.mix(ClassWithAToString.new) }.to_not raise_error
    end

    it "should not accept fresh_blood whose to_s method returns nil or an empty string" do
      expect { @swimmer.mix(ClassWithANilToString.new) }.to raise_error(ArgumentError)
      expect { @swimmer.mix(ClassWithAToString.new("")) }.to raise_error(ArgumentError)
      expect { @swimmer.mix(nil) }.to raise_error(ArgumentError)
    end

  end

end

class ClassWithNoToString

end

class ClassWithAToString

  attr_reader :msg

  def initialize(val="Hello World")
    @msg = val
  end

  def to_s
   @msg 
  end
end

class ClassWithANilToString
  def to_s
    nil
  end
end
