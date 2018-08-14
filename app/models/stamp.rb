class Stamp < ApplicationRecord
  attachment :image, destroy: false
end
