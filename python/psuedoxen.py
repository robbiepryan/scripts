#This will outline the psuedo code I think would work for the operation to function


#This function will check production VM's VDI's and check availble space, if necessary it will automatically add space or notify


#vdiUpgrade will take in a uuid object to perform the upgrade on

#function vdiUpgrade (vdi_uuid):
    #INSERT VDIUPGRADE STUFF HERE

#vdiCheck will ideally take in an object with the properties of that VDI's UUID to run some analysis before deciding if it will be eligible for automatic upgrade or notification

#function vdiCheck (vdi_uuid):
    ##Get the percentage of free space on the VDI
    #free_space_percent = ((vdi_uuid.max_size - vdi_uuid.used_size) / vdi_uuid.max_size))

    #if free_space_percent < .15:
        #vdiUpgrade(vdi_uuid)

        #or

        #vdiNotify(vdi_uuid)
    
