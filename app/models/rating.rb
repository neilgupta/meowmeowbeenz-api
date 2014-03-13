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
      # 5's must rule fairly (Every 20 beenz received is an extra vote, but every 20 reviews given is a lost vote)
      [5 + reviewer.weight/20 - reviewer.meows_given.count/20, 1].max
    when 4
      4 + reviewer.weight/50 # 4's are almost there! (Every 50 beenz received earns a 4 an extra vote)
    when 3
      3 + reviewer.weight/100 # A happy 3 is a future 4 (Every 100 beenz received earns a 3 an extra vote)
    when 2
      2 # Twice as good as a 1, aka not much better
    else
      1 # 1's are garbage...
    end
  end

end
