require "administrate/base_dashboard"

class TripDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    # attachments: Field::HasMany,
    user: Field::BelongsTo,
    id: Field::Number,
    name: Field::String,
    trip_schedule: Field::JSON,
    cover_picture_id: Field::String,
    cover_picture_filename: Field::String,
    cover_picture_size: Field::Number,
    lat: Field::String.with_options(searchable: false),
    long: Field::String.with_options(searchable: false),
    created_by: Field::Number,
    start_date: UnixTimeField.with_options(format: "%Y-%m-%d"),
    end_date: UnixTimeField.with_options(format: "%Y-%m-%d"),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    # :attachments,
      :id,
      :name,
      :start_date,
      :end_date,
    :user,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    # :attachments,
    :user,
    :id,
    :name,
    :trip_schedule,
    :lat,
    :long,
    :created_by,
    :start_date,
    :end_date,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    # :attachments,
    :name,
    :created_by,
    :start_date,
    :end_date,
  ].freeze

  # Overwrite this method to customize how trips are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(trip)
  #   "Trip ##{trip.id}"
  # end
end
