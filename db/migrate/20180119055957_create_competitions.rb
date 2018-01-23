class CreateCompetitions < ActiveRecord::Migration[5.0]
  def change
    create_table :competitions do |t|
    	t.datetime :date_and_time_start
    	t.datetime :date_and_time_finish
    	t.string :hashtag
    	t.boolean :is_live?, default: true

      t.timestamps
    end
  end
end
