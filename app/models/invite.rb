class Invite < ApplicationRecord
  belongs_to :user, foreign_key: :sent_by
  has_secure_token
  before_validation :convert_phone_to

  after_create_commit :send_invite_to_user

  # validates :contact, telephone_number: {country: proc{|record| record.country.downcase}},allow_nil: true

  validates_inclusion_of :country, :in => TZInfo::Country.all.map(&:code), :message => "Country code %s is not included in the list",allow_nil: true


  def convert_phone_to
    phone_object = TelephoneNumber.parse(contact)
    unless phone_object.country
      self.country = user.country
      phone_object = TelephoneNumber.parse(contact, country.try(:downcase) || 'us')
    end
    self.country ||= phone_object.country.country_id
    self.contact = phone_object.international_number.delete(' ')
  end

  def send_invite_to_user
    InvitesTexter.send_invite(self).deliver_later
  end

end
