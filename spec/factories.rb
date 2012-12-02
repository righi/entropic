FactoryGirl.define do
  factory :swimmer do
    hash_length = 128
    hashcode { (0...hash_length).map{ (('a'..'f').to_a + (0..9).to_a)[rand(16)] }.join }
  end
end
