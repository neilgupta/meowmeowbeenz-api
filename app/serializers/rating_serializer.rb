class RatingSerializer < ActiveModel::Serializer
  attributes :beenz, :updated_at
  has_one :reviewer
  has_one :reviewee
end
