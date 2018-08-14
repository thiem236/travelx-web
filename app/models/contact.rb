class Contact < ApplicationRecord
  belongs_to :user
  enum contact_type: [ :phone, :email ]

end
