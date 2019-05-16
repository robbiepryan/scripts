#We will be testing XENAPI calls with python from here to the dev server
import XenAPI
import datetime

now = str(datetime.datetime.now())
#insert xenserver address here
session = XenAPI.Session('http://serveraddress')
try:
    session.xenapi.login_with_password("user", "password")

    print('Success ')


    
    #Get all VM's and list them
    vms = session.xenapi.VM.get_all()

    #Filter out Templates
    for vm in vms:

        record = session.xenapi.VM.get_record(vm)
        if not(record["is_a_template"]) and not (record["is_control_domain"]):
            name = record["name_label"]
            vm_uuid = record["uuid"]
            vbds = record["VBDs"]

            #Now get the associated VBDs attached to the VM
            for vbd in vbds:
                vbd_record = session.xenapi.VBD.get_record(vbd)

                #Sort through the VBD to find the Disk VDI's for the VMs
                if vbd_record["type"] == 'Disk':
                    vbd_uuid = vbd_record["uuid"]

                    #Start extracting VDI info
                    vdi = vbd_record["VDI"]

                    #Store the VDI record
                    vdi_record = session.xenapi.VDI.get_record(vdi)

                    #Store the UUID for the VDI
                    vdi_uuid = vdi_record["uuid"]
                    vdi_utilization = vdi_record["physical_utilisation"]
                    vdi_current_size = vdi_record["virtual_size"]
                    vdi_new_size = str(int(round((float(vdi_current_size) * 0.15) + float(vdi_current_size))))
                    print("Found VDI: ", vdi_uuid, "On: ", name, ": ", vm_uuid)
                    print("Old size was: ", vdi_current_size, "Auto Resize would bring it to: ", vdi_new_size)
                    print("Physical utilization:", vdi_utilization, "Reference old size for allocated above")
                    #Store the automatic back up name
                    backup_name = name + " " + now
                    session.xenapi.VM.snapshot(session.xenapi.VM.get_by_uuid(vm_uuid), backup_name)
                    session.xenapi.VM.shutdown(session.xenapi.VM.get_by_uuid(vm_uuid))
                    session.xenapi.VDI.resize(session.xenapi.VDI.get_by_uuid(vdi_uuid), vdi_new_size)
                    session.xenapi.VM.start(session.xenapi.VM.get_by_uuid(vm_uuid), False, False)
                    print("VDI has been resized")

#Finally close our xenapi session cleanly.
finally:
    session.xenapi.session.logout()
