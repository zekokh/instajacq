class CreatePublications < ActiveRecord::Migration[5.0]
  def change
    create_table :publications do |t|
    	t.integer :date
    	t.string :url
    	t.string :code
    	t.string :owner
    	t.string :marked_1
    	t.string :marked_2
    	t.string :marked_3
    	t.boolean :is_live?, default: true
    	t.boolean :is_blocked?, default: false

      t.timestamps
    end
  end
end
