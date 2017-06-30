require 'rails_helper'

RSpec.describe UserCalendar, type: :model do
  it{should belong_to :user}
  it{should belong_to :calendar}
  it{should belong_to :permission}
  it{should belong_to :color}
  it do
    should delegate_method(:email)
      .to(:user)
      .with_prefix(true)
      .with_arguments allow_nil: true
  end
end
