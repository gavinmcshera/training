# Turn On ICMPv4
New-NetFirewallRule -Name Allow_ICMPv4 -DisplayName "Allow ICMPv4" -Protocol ICMPv4 -Enabled True -Profile Any -Action Allow
# Allow tcp 8080 for the Default Web Site
New-NetFirewallRule -Name "Default Website 8080" -Description "Binding to 8080" -DisplayName "Default Website 8080" -Enabled:True -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8080
