class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :reviewee_id
      t.integer :reviewer_id
      t.integer :beenz
      t.integer :weight

      t.timestamps
    end

    add_index :ratings, [:reviewer_id, :reviewee_id], :unique => true
  end
end
