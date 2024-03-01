class Cafe < ApplicationRecord
  validates :title, presence: true
  validates :address, presence: true
end
