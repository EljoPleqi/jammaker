class CreateRecepies < ActiveRecord::Migration[6.1]
  def change
    create_table :recipies do |t|
      t.string :title
      t.integer :duration
      t.string :ingredients

      t.timestamps
    end
  end
end