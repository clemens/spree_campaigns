if RUBY_VERSION < '1.9'
  require 'fastercsv'
  CSV = FasterCSV
else
  require 'csv'
end

module Spree
  class Campaign < ActiveRecord::Base
    has_many :promotions

    after_create :create_promotions

    def coupons_available
      promotions.reject(&:usage_limit_exceeded?).count
    end

    def coupons_total
      promotions.count
    end

    def to_csv
      CSV.generate(:col_sep => ';', :headers => true, :force_quotes => true) do |csv|
        # header row
        csv << ['Campaign', 'Code', 'Used?']
        # data rows
        promotions.each do |promotion|
          csv << [name, promotion.code, promotion.usage_limit_exceeded? ? 'Yes' : 'No']
        end
      end
    end

  private

    def create_promotions
      number_of_coupons.to_i.times do |i|
        promotion = promotions.create!(
          :name => "#{name} ##{i + 1}",
          :usage_limit => 1,
          :event_name => 'spree.checkout.coupon_code_added',
          :code => Devise.friendly_token.first(10).upcase,
        )
        Spree::Promotion::Rules::ItemTotal.create!(:preferred_operator => 'gte', :preferred_amount => value) do |rule|
          rule.promotion = promotion
        end
        Spree::Promotion::Actions::CreateAdjustment.create! do |action|
          action.promotion = promotion
          action.calculator = Spree::Calculator::FlatRate.new(:preferred_amount => value)
        end
      end
    end

  end
end
