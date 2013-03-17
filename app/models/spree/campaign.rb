if RUBY_VERSION < '1.9'
  require 'fastercsv'
  CSV = FasterCSV
else
  require 'csv'
end

module Spree
  class Campaign < ActiveRecord::Base
    has_many :promotions

    with_options(:if => :period_mode_days?) do |v|
      v.validates :days, :numericality => { :only_integer => true, :greater_than => 0, :allow_blank => true }
      v.validates_presence_of :starts_at, :message => 'must be given if period mode is "days"'
    end

    after_create :create_promotions
    after_update :update_promotions

    before_validation :calculate_ends_at_for_days

    def coupons_available
      # OPTIMIZE: At least the inner sub query could probably be rewritten with a JOIN.
      conditions = <<-sql
        usage_limit IS NULL OR
        usage_limit > (
          SELECT COUNT(*) FROM #{Spree::Adjustment.table_name} sa
	        WHERE sa.originator_type = 'Spree::PromotionAction' AND sa.originator_id IN (
	          SELECT id FROM #{Spree::PromotionAction.table_name} spa WHERE spa.activator_id = #{Spree::Promotion.table_name}.id
	        )
        )
      sql
      promotions.where(conditions).count
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

    def period_mode_days?; period_mode == 'days'; end
    def period_mode_fixed_date?; period_mode == 'fixed_date'; end

    def calculate_ends_at_for_days
      return unless period_mode_days? && days.present? && starts_at.present?
      self.ends_at = starts_at + (days.to_i).days
    end

    def create_promotions
      number_of_coupons.to_i.times do |i|
        promotion = promotions.create!(
          :name => "#{name} ##{i + 1}",
          :usage_limit => 1,
          :event_name => 'spree.checkout.coupon_code_added',
          :code => Devise.friendly_token.first(10).upcase,
          :starts_at => starts_at,
          :expires_at => ends_at,
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

    def update_promotions
      promotions.update_all(:starts_at => starts_at, :expires_at => ends_at)
    end

  end
end
