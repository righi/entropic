require 'digest/sha2'

class Swimmer < ActiveRecord::Base
  attr_accessible :hashcode
  after_initialize :init

  validates_format_of :hashcode, :with => $SHA512_REGEX

  def init
    self.hashcode ||= init_hash
  end

  def mix(fresh_blood)

    if (!fresh_blood.class.instance_methods(false).include?(:to_s))
      raise(ArgumentError, ":fresh_blood's class must define it's own to_s method.  (#{fresh_blood.class} does not.")
    end

    raise(ArgumentError, ":fresh_blood.to_s must not be nil or empty") unless !fresh_blood.to_s.blank? 


    result = ''
    # @lock.synchronize do
    result = self.hashcode = Digest::SHA512.hexdigest("#{self.hashcode}#{Time.now.to_s}#{fresh_blood}")
    # end
    result 
  end

  def to_s
    self.hashcode
  end

  private

  def init_hash
    Digest::SHA512.hexdigest("#{rand()}#{ObjectSpace.count_objects.to_s}#{GC.stat.to_s}#{Time.now}#{SecureRandom.hex(13)}")
  end

end
