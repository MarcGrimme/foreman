class GroupParameter < Parameter
  belongs_to :hostgroup, :foreign_key => :reference_id
  audited :except => [:priority], :associated_with => :hostgroup, :allow_mass_assignment => true
  validates_uniqueness_of :name, :scope => :reference_id

  private
  def enforce_permissions operation
    # We get called again with the operation being set to create
    return true if operation == "edit" and new_record?

    current = User.current

    if current.allowed_to?("#{operation}_params".to_sym)
      if current.hostgroups.empty? or current.hostgroups.include? hostgroup
        return true
      end
    end

    errors.add(:base, _("You do not have permission to %s this group parameter") % operation)
    false
  end
end
