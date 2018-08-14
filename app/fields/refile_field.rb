require "administrate/field/base"

class RefileField < Administrate::Field::Base
  def to_s
    data
  end

  def direct
    options.fetch(:direct, false)
  end

  def presigned
    options.fetch(:presigned, false)
  end

  def multiple
    options.fetch(:multiple, false)
  end
end
