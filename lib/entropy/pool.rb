require 'digest/sha2'

module Entropy
  class Pool
    def self.instance
      @__instance__ ||= new
    end

    def initialize
      @hash = Digest::SHA512.hexdigest("#{rand()}#{ObjectSpace.count_objects.to_s}#{GC.stat.to_s}#{Time.now}#{SecureRandom.hex(13)}")
      @lock = Mutex.new
    end

    def mix(fresh_blood)
      result = ''
      @lock.synchronize do
        result = @hash = Digest::SHA512.hexdigest("#{@hash}#{Time.now}#{fresh_blood}")
      end
      result 
    end

  end

end
