class CreateCaves < ActiveRecord::Migration[7.1]
  def change
    create_table :caves do |t|
      t.string :title
      t.string :address
      t.string :gmaps_url
      t.string :picture
      t.jsonb :informations
      t.string :criterion, array: true

      t.timestamps
    end
  end
end
