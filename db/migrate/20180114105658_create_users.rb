class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
    	t.string :name
    	t.string :nickname
    	t.string :url
      t.string :user_id
    	t.integer :number
    	t.boolean :is_live?, default: true
    	t.boolean :is_blocked?, default: false

      t.timestamps
    end
  end
end
