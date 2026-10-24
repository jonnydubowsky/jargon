# frozen_string_literal: true

class CreateTrails < ActiveRecord::Migration[8.1]
  def change
    create_table :trails do |t|
      t.string :name
      t.timestamps
    end

    create_table :trail_steps do |t|
      t.references :trail, null: false, foreign_key: true
      t.integer :position, null: false
      t.integer :action, null: false, default: 0
      t.references :subject, polymorphic: true
      t.string :query
      t.timestamps
    end

    add_index :trail_steps, %i[trail_id position], unique: true
  end
end
