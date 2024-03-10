class Cafe < ApplicationRecord
  validates :title, presence: true
  validates :address, presence: true
  validates :title, uniqueness: { scope: :address }
end
