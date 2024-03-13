trigger orelinventorytransactioncreatetriggerforclosedlost on Opportunity (after update) {
 If(trigger.isupdate && Trigger.isafter)
    { 
        orelinventorytransactioncreate.oppcloselost(trigger.new,trigger.old);
    }
}