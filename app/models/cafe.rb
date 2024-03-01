class Cafe < ApplicationRecord
  validates :title, presence: true
  validates :gmaps_url, presence: true
end
