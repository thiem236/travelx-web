class Location < ApplicationRecord
  self.inheritance_column = nil
  extend Enumerize
  belongs_to :trip
  belongs_to :city
  has_many :attachments, dependent: :nullify
  enumerize :type, in: AppConstants::Location::TYPE, predicates: true, scope: true

  default_value_for :rate, 0

end
