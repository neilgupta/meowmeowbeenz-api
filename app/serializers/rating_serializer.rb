class RatingSerializer < ActiveModel::Serializer
  attributes :beenz, :updated_at
  has_one :reviewer
  has_one :reviewee

  # Output formatted json sample of this object for use in documentation
  def self.to_documentation(name1, name2, beenz1, beenz2, args = {})
    opts = {
      indentation: 0
    }.merge(args)

    spacing = "    #{'  '*opts[:indentation]}"
"{
#{spacing}  \"beenz\": #{1 + rand(5)}, # integer of beenz transacted
#{spacing}  \"updated_at\": #{UserSerializer.time_rand.to_json},
#{spacing}  \"reviewer\": #{UserSerializer.to_documentation(name1, {indentation: opts[:indentation] + 1, beenz: beenz1})},
#{spacing}  \"reviewee\": #{UserSerializer.to_documentation(name2, {indentation: opts[:indentation] + 1, beenz: beenz2})}
#{spacing}}"
  end
end
