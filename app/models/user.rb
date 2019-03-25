class User < ActiveRecord::Base
  include SearchCop

  search_scope :search do
    attributes :id, :name, :contact, :country, :email, :fb_id, :birthday, :city
  end

  has_friendship
  # Include default devise modules.
  devise :invitable, :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2, :facebook]
  include DeviseTokenAuth::Concerns::User
  attachment :profile_picture
  attachment :cover_picture

  has_many :private_stamps, foreign_key: :user_id, dependent: :destroy
  has_many :trips, dependent: :destroy, foreign_key: :created_by
  has_many :cities, dependent: :destroy
  has_many :posts, dependent: :destroy, foreign_key: :created_by
  has_many :user_trips, dependent: :destroy


  has_many :trip_invited,-> { where('user_trips.status = ?','invited') }, class_name: 'Trip',through: :user_trips,source: :user
  has_many :trip_accepted,-> { where('user_trips.status = ?','accepted') }, class_name: 'Trip',through: :user_trips,source: :user
  has_many :trip_ignored,-> { where('user_trips.status = ?','ignored') }, class_name: 'Trip',through: :user_trips,source: :user

  has_many :invites, dependent: :destroy,foreign_key: :sent_by

  has_many :notifications, dependent: :destroy
  has_many :notification_sends, class_name: 'Notification', source: :user, foreign_key: :sender_id
  has_many :contacts, dependent: :destroy
  before_create :generate_base32
  after_create_commit :add_friend_invite_user
  before_save :convert_phone_to
  jsonb_accessor :setting,
                allow_notification: :boolean,
                allow_tag_me: :boolean,
                 receive_message: :boolean

  validate :validate_phone_number
  validates_inclusion_of :country, :in => TZInfo::Country.all.map(&:code),
                         :message => "Country code %s is not included in the list",
                         allow_blank: true

  SECRET_KEY="o47jzkqcg7jfrjpt"
  has_secure_token :auth_token



  def validate_phone_number
    if contact.present? && country.present? && TelephoneNumber.invalid?(contact, country)
      errors.add(:contact, "The phone number is not valid for the country")
    end
  end

  def active_for_authentication?
    # Uncomment the below debug statement to view the properties of the returned self model values.
    # logger.debug self.to_yaml

    super && verified?
  end

  def convert_phone_to
    if contact.present?
      phone_object = TelephoneNumber.parse(contact, country.try(:downcase))
      self.contact = phone_object.international_number.delete(' ')
    end

  end

  def generate_base32
    self.otp_secret = ROTP::Base32.random_base32
  end


  def is_not_accept_invited?
    invitation_created_at.present? && invitation_accepted_at.nil?
  end


  def generate_verification_code_and_send
    update_columns(verification_code: generate_current_code, verified: false)
    UsersMailer.send_verification_code(self).deliver_now
  end

  def generate_verification_code_and_send_reset_pass
    update_columns(verification_code: generate_current_code)
    UsersMailer.send_pass_reset_code(self).deliver_now
  end

  def verify!(code)
    if code.to_s == generate_current_code && verification_code == code.to_s
      self.verified = true
      self.verification_code = nil
      save
      return true
    end
    raise StandardError.new("error code")
  end

  def verify_reset_pass(code)
    if code.to_s == generate_current_code && verification_code == code.to_s
      self.verification_code = nil
      regenerate_auth_token
      save
      return true
    end
    raise StandardError.new("error code")
  end

  def accept_trip(trip_id)
    user_trip = user_trips.find_by(trip_id: trip_id)
    user_trip.status = "accepted"
    user_trip.save!
  end

  def auto_add_friend(user)
    if user.pending_friends.find_by(id: id)
      return self.accept_request(user)
    end
    if friend_request(user)
      return user.accept_request(self)
    end
    false
  end

  def friend_has_contact?(user)
    user.contacts.where(contact: [email, contact]).present?
  end

  def add_friend_invite_user
    if invited_by_id
      invite = User.find(invited_by_id)
      if invite.friend_request(self)
        self.accept_request(invite)
      end
    end
  end

  def generate_current_code
      ROTP::TOTP.new(self.otp_secret ,interval: 1800).now
  end

  def send_notification_invite_trip(trip, sender)
    payload = {
        content_available: true,
        mutable_content: true,
        badge: 1,
        notification:
            {
                body: "#{sender.name} invited you to join #{trip.name} trip",
                sound: "default",
                message:  "#{sender.name} invited you to join #{trip.name} trip",
            },
        data: {push_type: 'Trip'}
    }
    token  = device_tokens.first
    payload[:to] = token['device_token'] rescue ""
    payload[:badge] = push_badge
    Notification.create!(
        device_id: if token then token['device_token'] else "" end ,
        device:  if token then token['device_name'] else "" end ,
        user_id: id,
        sender_id: sender.id,
        body: payload,
        noti_type: 'invite_trip',
        obj: trip,
        title: "#{sender.name} invited you to join #{trip.name} trip",
        model_type: 'Trip',
        able_type: 'Trip',
        able_id: trip.id,
        push_device: true
    )
    self.push_badge = push_badge + 1
    save!

  end

  def notification_accepted_trip(trip, sender)
    payload = {
        content_available: true,
        mutable_content: true,
        badge: 1,
        notification:
            {
                body: "#{sender.name} Have accepted to join your trip",
                sound: "default",
                message:  "#{sender.name} have accepted to join your trip}"
            },
        data: {push_type: 'Trip'}
    }
    token  = device_tokens.first
    payload[:to] = token['device_token'] rescue ""
    payload[:badge] = push_badge
    Notification.create!(
        device_id: if token then token['device_token'] else "" end ,
        device:  if token then token['device_name'] else "" end ,
        user_id: id,
        sender_id: sender.id,
        body: payload,
        push_device: true,
        noti_type: 'trip_accepted',
        title: "Have accepted to join your trip",
        obj: trip,
        model_type: 'Trip',
        able_type: 'Trip',
        able_id: trip.id,
    )
    self.push_badge = push_badge + 1
    save!

  end

  def notification_ignored_trip(trip, sender)
    payload = {
        content_available: true,
        mutable_content: true,
        badge: 1,
        notification:
            {
                body: "#{sender.name} ignored you to #{trip.name}",
                sound: "default",
                message:  "#{sender.name} ignored you to #{trip.name}",
            },
        data: {push_type: 'Trip'}
    }
    token  = device_tokens.first
    payload[:to] = token['device_token'] rescue ""
    payload[:badge] = push_badge
    Notification.create!(
        device_id: if token then token['device_token'] else "" end ,
        device:  if token then token['device_name'] else "" end ,
        user_id: id,
        sender_id: sender.id,
        body: payload,
        push_device: true,
        title: "You ignored you to #{trip.name}",
        noti_type: 'trip_rejected',
        obj: trip,
        model_type: 'Trip',
        able_type: 'Trip',
        able_id: trip.id,
    )
    self.push_badge = push_badge + 1
    save!

  end

  def self.get_user_by_contact(contact)
    contact = unless contact.start_with?('0','+')
                '+' + contact
              else
                contact
              end

    User.find_by(contact: contact)
  end

  def reset_badge!
    self.push_badge = 1
    save!
  end

end
