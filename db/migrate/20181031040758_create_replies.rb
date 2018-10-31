class CreateReplies < ActiveRecord::Migration[5.2]
  def change
    create_table :replies do |t|
      t.string :word, null: false
      t.string :reply_message, null: false

      t.timestamps
    end
  end
end
