class CreateSpreeCampaigns < ActiveRecord::Migration
  def change
    create_table :spree_campaigns do |t|
      t.string :name
      t.integer :number_of_coupons
      t.decimal :value, :precision => 8, :scale => 2
    end

    add_column Spree::Promotion.table_name, :campaign_id, :integer
    add_index Spree::Promotion.table_name, :campaign_id
  end
end
