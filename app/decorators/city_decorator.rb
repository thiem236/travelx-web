class CityDecorator < Draper::Decorator
  delegate_all

  def created_at
    object.created_at.to_i
  end
end
