#This will automatically parse disks and expand them if placed in the start up script for the Machine.

function List-Disks {
	'list disk' | diskpart | 
		Where-Object { $_ -match 'disk (\d+)\s+online\s+\d+ .?b\s+\d+ [gm]b' } |
		ForEach-Object { $matches[1] }
}

function List-Partitions($disk) {
	"select disk $disk", "list partition" | diskpart |
		Where-Object { $_ -match 'partition (\d+)' } |
		ForEach-Object { $matches[1] }
}

function Extend-Partition($disk, $part) {
	"select disk $disk", "select partition $part", "extend" | diskpart | Out-Null
}

List-Disks | ForEach-Object {
	$disk = $_
	List-Partitions $disk | ForEach-Object {
		Extend-Partition $disk $_
	}
}
