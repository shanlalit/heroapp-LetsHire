require 'carmen'

class Opening < ActiveRecord::Base
  include Carmen

  attr_accessible :title, :description,:department_id, :status, :country, :province, :city
  attr_accessible :hiring_manager_id, :recruiter_id, :participants, :participant_ids

  belongs_to :department
  belongs_to :hiring_manager, :class_name => "User", :foreign_key => :hiring_manager_id, :readonly => true
  belongs_to :recruiter, :class_name => "User", :foreign_key => :recruiter_id, :readonly => true

  has_many :opening_participants, :class_name => "OpeningParticipant", :readonly => true
  has_many :participants, :class_name => "User", :through => :opening_participants

  validates :title, :presence => true


  def status_str
    STATUS_STRINGS[status]
  end

  def full_address
    if country.nil?
      (city || "UNKNOWN")
    else
      Country.coded(country).try { |country_obj|
        sub_regions = country_obj.subregions
        province_obj = sub_regions.respond_to?(:coded) ?  sub_regions.coded(province) : nil
        logger.debug sub_regions.inspect
        logger.debug province
        if province_obj.nil?
          (city || "UNKNOWN") + ',' + (province || "UNKNOWN") + ', ' + country_obj.name
        else
          (city || "UNKNOWN") + ',' + province_obj.name.to_s + ',' + country_obj.name
        end
      }
    end
  end

  def published?
    status == STATUSES[:published]
  end

  private
  STATUSES = { :draft => 0, :published => 1, :closed => -1 }
  STATUS_STRINGS = STATUSES.invert
end
