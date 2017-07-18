class Team < ApplicationRecord
  include TeamAdmin

  belongs_to :organization
  has_many :user_teams, dependent: :destroy
  has_many :users, through: :user_teams
  has_many :event_teams, dependent: :destroy
  has_many :events, through: :event_teams

  delegate :name, to: :organization, prefix: true

  validates :name, presence: true, length: {maximum: 50},
    uniqueness: {case_sensitive: false}

  ATTR_PARAMS = [:name, :description, :organization_id].freeze
end
