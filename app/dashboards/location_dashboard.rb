require "administrate/base_dashboard"

class LocationDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    trip: Field::BelongsTo,
    city: Field::BelongsTo,
    attachments: Field::HasMany,
    id: Field::Number,
    name: Field::String,
    type: Field::String,
    note: Field::Text,
    pemark: Field::Number,
    city_name: Field::String,
    rate: Field::Number,
    lat: Field::String.with_options(searchable: false),
    long: Field::String.with_options(searchable: false),
    start_day: Field::Number,
    end_day: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    start_date: Field::Number,
    end_date: Field::Number,
    item_id: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :trip,
    :city,
    :attachments,
    :id,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :trip,
    :city,
    :attachments,
    :id,
    :name,
    :type,
    :note,
    :pemark,
    :city_name,
    :rate,
    :lat,
    :long,
    :start_day,
    :end_day,
    :created_at,
    :updated_at,
    :start_date,
    :end_date,
    :item_id,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :trip,
    :city,
    :attachments,
    :name,
    :type,
    :note,
    :pemark,
    :city_name,
    :rate,
    :lat,
    :long,
    :start_day,
    :end_day,
    :start_date,
    :end_date,
    :item_id,
  ].freeze

  # Overwrite this method to customize how locations are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(location)
  #   "Location ##{location.id}"
  # end
end
