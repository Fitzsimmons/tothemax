FactoryGirl.define do
  factory :analysis_result do
    sequence(:username) {|n| "User#{n}"}
    most_recent_known_id 3
    count({ "5" => 2, "3" => 1 })
  end
end
