$u1 = Get-ADUser -Identity "bchuc" -Properties *
$u2 = Get-ADUser -Identity "jstern" -Properties *

# Compare all property keys that exist on either user
$allProps = ($u1.PropertyNames + $u2.PropertyNames) | Select-Object -Unique | Sort-Object

foreach ($prop in $allProps) {
    $val1 = $u1.$prop
    $val2 = $u2.$prop
    
    if ($val1 -ne $val2) {
        [PSCustomObject]@{
            Property = $prop
            User1    = $val1
            User2    = $val2
        }
    }
}
