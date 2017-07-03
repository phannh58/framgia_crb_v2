class Setting < ApplicationRecord
  belongs_to :owner, polymorphic: true

  validates :timezone_name, presence: true
end
