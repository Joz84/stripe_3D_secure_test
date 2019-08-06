class AddIntentIdToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :intent_id, :string
  end
end
