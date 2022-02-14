<#

ORCA-117

Checks to determine if SafeLinks action for unknown potentially malicious URLs in messages is on.

#>

using module "..\ORCA.psm1"

class ORCA117 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA117()
    {
        $this.Control=117
        $this.Services=[ORCAService]::OATP
        $this.Area="Advanced Threat Protection Policies"
        $this.Name="Action for unknown potentially malicious URLs in messages"
        $this.PassText="Safe Links policy action is enabled"
        $this.FailRecommendation="Enable Safe Links policy action for unknown potentially malicious URLs in messages"
        $this.Importance="When Safe Links policy action is eanbled URLs in messages will be rewritten and checked against a list of known malicious links when user clicks on the link."
        $this.ExpandResults=$True
        $this.CheckType=[CheckType]::ObjectPropertyValue
        $this.ObjectType="Safe Links policy"
        $this.ChiValue=[ORCACHI]::Medium
        $this.ItemName="Setting"
        $this.DataType="Current Value"
        $this.Links= @{
            "Security & Compliance Center - Safe links"="aka.ms/orca-atpp-action-safelinksv2"
            "Recommended settings for EOP and Office 365 ATP security"="https://aka.ms/orca-atpp-docs-7"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {

        $Enabled = $False

        ForEach($Policy in $Config["SafeLinksPolicy"]) 
        {
            # Check objects
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.Object=$($Policy.Name)
            $ConfigObject.ConfigItem="IsEnabled"
            $ConfigObject.ConfigData=$Policy.IsEnabled

            # Determine if Safe Links policy action for unknown potentially malicious URLs in messages is enabled
            If($Policy.IsEnabled -eq $true) 
            {
                $Enabled = $True
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
            } 
            Else 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            }

            $this.AddConfig($ConfigObject)
        }

        If($Enabled -eq $False)
        {

            # No policy enabling
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.Object ="All"
            $ConfigObject.ConfigItem="IsEnabled"
            $ConfigObject.ConfigData="False"
            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")

            $this.AddConfig($ConfigObject)

        }    

    }

}