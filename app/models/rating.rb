class Rating < ActiveRecord::Base
  belongs_to :reviewer, class_name: "User",
                        foreign_key: "reviewer_id",
                        inverse_of: :meows_given
  belongs_to :reviewee, class_name: "User",
                        foreign_key: "reviewee_id",
                        inverse_of: :meows_received

  validates :reviewer, :presence => true
  validates :reviewee, :presence => true
  validates :beenz,    :presence => true, numericality: true
  validates :weight,   :presence => true, numericality: true

  def beenz=(new_beenz)
    set_weight
    write_attribute(:beenz, new_beenz)
  end

  private

  def set_weight
    self.weight = case reviewer.beenz.floor
    when 5
      16
    when 4
      8
    when 3
      4
    when 2
      2
    else
      1
    end
  end

end
