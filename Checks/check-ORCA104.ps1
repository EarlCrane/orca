using module "..\ORCA.psm1"

class ORCA104 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA104()
    {
        $this.Control="ORCA-104"
        $this.Area="Anti-Spam Policies"
        $this.Name="High Confidence Phish Action"
        $this.PassText="High Confidence Phish action set to Quarantine message"
        $this.FailRecommendation="Change High Confidence Phish action to Quarantine message"
        $this.Importance="It is recommended to configure the High Confidence Phish detection action to Quarantine so that these emails are not visible to the end user from within Outlook. As Phishing emails are designed to look legitimate, users may mistakenly think that a phishing email in Junk is false-positive."
        $this.ExpandResults=$True
        $this.ItemName="Spam Policy"
        $this.DataType="Action"
        $this.ChiValue=[ORCACHI]::High
        $this.Links= @{
            "Security & Compliance Center - Anti-spam settings"="https://aka.ms/orca-antispam-action-antispam"
            "Recommended settings for EOP and Office 365 ATP security"="https://aka.ms/orca-atpp-docs-6"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {
        # Fail if HighConfidencePhishAction is not set to Quarantine

        ForEach($Policy in $Config["HostedContentFilterPolicy"]) 
        {

            # Check objects
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.ConfigItem=$($Policy.Name)
            $ConfigObject.ConfigData=$($Policy.HighConfidencePhishAction)
    
            If($Policy.HighConfidencePhishAction -eq "Quarantine") 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
            }
            Else 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            }

            If($Policy.HighConfidencePhishAction -eq "Redirect" -or $Policy.HighConfidencePhishAction -eq "Delete")
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Informational,"Fail")
                $ConfigObject.InfoText = "The $($Policy.HighConfidencePhishAction) option may impact the users ability to release emails and may impact user experience. Consider using the Quarantine option for High Confidence Phish."
            }


            # Add config to check
            $this.AddConfig($ConfigObject)

        }        

    }

}