require "administrate/field/base"

class UnixTimeField < Administrate::Field::Base
  def to_s
    Time.zone.at(data).strftime(format)
  end

  private

  def format
    options.fetch(:format) || '%Y-%m-%d %H:%M:%S'
  end
end
