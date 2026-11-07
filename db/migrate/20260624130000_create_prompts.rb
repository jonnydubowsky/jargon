# frozen_string_literal: true

class CreatePrompts < ActiveRecord::Migration[8.1]
  def change
    create_table :prompts do |t|
      t.string :key, null: false
      t.text :content, null: false
      t.timestamps
    end

    add_index :prompts, :key, unique: true
  end
end
