class Rating < ActiveRecord::Base
  belongs_to :reviewer, class_name: "User",
                        foreign_key: "reviewer_id",
                        inverse_of: :meows_given
  belongs_to :reviewee, class_name: "User",
                        foreign_key: "reviewee_id",
                        inverse_of: :meows_received

  validates :reviewer, :presence => true
  validates :reviewee, :presence => true
  validates :beenz,    :presence => true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :weight,   :presence => true, numericality: { only_integer: true }
  validate :reviewer_cannot_be_reviewee

  def reviewer_cannot_be_reviewee
    errors.add(:reviewer, "can't give MeowMeowBeenz to self") if reviewer == reviewee
  end

  def beenz=(new_beenz)
    set_weight
    write_attribute(:beenz, new_beenz)
  end

  private

  def set_weight
    self.weight = case reviewer.beenz.floor
    when 5
      5 + reviewer.weight/20
    when 4
      4 + reviewer.weight/50
    when 3
      3 + reviewer.weight/80
    when 2
      2 + reviewer.weight/100
    else
      1
    end
  end

end
