using module "..\ORCA.psm1"

class ORCA140 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA140()
    {
        $this.Control=140
        $this.Area="Anti-Spam Policies"
        $this.Name="High Confidence Spam Action"
        $this.PassText="High Confidence Spam action set to Quarantine message"
        $this.FailRecommendation="Change High Confidence Spam action to Quarantine message"
        $this.Importance="It is recommended to configure High Confidence Spam detection action to Quarantine message."
        $this.ExpandResults=$True
        $this.ItemName="Anti-Spam Policy"
        $this.DataType="Action"
        $this.ChiValue=[ORCACHI]::Medium
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
    
        ForEach($Policy in $Config["HostedContentFilterPolicy"]) 
        {

            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.Object=$Policy.Name
            $ConfigObject.ConfigItem=$($Policy.Name)
            $ConfigObject.ConfigData=$($Policy.HighConfidenceSpamAction)
    
            # Fail if HighConfidenceSpamAction is not set to Quarantine
    
            If($Policy.HighConfidenceSpamAction -eq "Quarantine") 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
            } 
            else 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            }

            # For either Delete or Quarantine we should raise an informational
            If($Policy.HighConfidenceSpamAction -eq "Delete" -or $Policy.HighConfidenceSpamAction -eq "Redirect")
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Informational,"Fail")
                $ConfigObject.InfoText = "The $($Policy.HighConfidenceSpamAction) option may impact the users ability to release emails and may impact user experience."
            }

            # Add config to check
            $this.AddConfig($ConfigObject)
            
        }        

    }

}