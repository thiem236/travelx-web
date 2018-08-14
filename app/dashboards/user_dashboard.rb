require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    invited_by: Field::Polymorphic,
    id: Field::Number,
    provider: Field::String,
    uid: Field::String,
    encrypted_password: Field::String,
    reset_password_token: Field::String,
    reset_password_sent_at: Field::DateTime,
    remember_created_at: Field::DateTime,
    sign_in_count: Field::Number,
    current_sign_in_at: Field::DateTime,
    last_sign_in_at: Field::DateTime,
    current_sign_in_ip: Field::String,
    last_sign_in_ip: Field::String,
    confirmed_at: Field::DateTime,
    confirmation_sent_at: Field::DateTime,
    gender: Field::String,
    name: Field::String,
    verified: Field::Boolean,
    oauth_token: Field::String,
    oauth_expires_at: Field::DateTime,
    image: Field::String,
    email: Field::String,
    password: Field::String.with_options(searchable: false),
    password_confirmation: Field::String.with_options(searchable: false),
    fb_id: Field::String,
    image_url: Field::String,
    profile_picture: RefileField,
    birthday: Field::DateTime,
    tokens: Field::String.with_options(searchable: false),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    invitation_token: Field::String,
    invitation_created_at: Field::DateTime,
    invitation_sent_at: Field::DateTime,
    invitation_accepted_at: Field::DateTime,
    invitation_limit: Field::Number,
    invitations_count: Field::Number,
    device_tokens: Field::JSON,
    country: SelectField.with_options(
        choices: TZInfo::Country.all.map{ |t| [t.name,t.code]}.sort{|a,b| a[0] <=> b[0]}
    ),
    contact: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :invited_by,
    :id,
    :provider,
    :fb_id,
    :uid,
    :country,
    :contact,
    :email,
    :verified,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :invited_by,
    :id,
    :provider,
    :uid,
    :confirmed_at,
    :confirmation_sent_at,
    :country,
    :contact,
    :gender,
    :name,
    :email,
    :fb_id,
    :profile_picture,
    :created_at,
    :updated_at,
    :invitation_created_at,
    :invitation_sent_at,
    :invitation_accepted_at,
    :invitation_limit,
    :device_tokens,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :email,
    :gender,
    :name,
    :contact,
    :password,
    :password_confirmation,
    :country,
    :profile_picture,
    :birthday,
    :verified,

  ].freeze

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(user)
  #   "User ##{user.id}"
  # end
end
