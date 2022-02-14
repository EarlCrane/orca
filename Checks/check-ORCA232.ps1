<#

232 - Check for duplicate anti-malware policies

#>

using module "..\ORCA.psm1"

class ORCA232 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA232()
    {
        $this.Control=232
        $this.Area="Malware Filter Policy"
        $this.Name="Malware Filter Policy Policy Rules"
        $this.PassText="Each domain has a malware filter policy applied to it, or the default policy is being used"
        $this.FailRecommendation="Check your malware filter policies for duplicate rules. Some policies and settings may not be applying."
        $this.Importance="Exchange Online Protection malware filter policies are applied using rules. The default policy applies in the absence of a custom policy. When creating custom policies, there may be duplication of settings and depending on the rules and priority, some policies or settings may not even apply. It's important in this circumstance to check that the desired settings are applied to the right users."
        $this.ExpandResults=$True
        $this.CheckType=[CheckType]::ObjectPropertyValue
        $this.ObjectType="Domain"
        $this.ItemName="Policy"
        $this.DataType="Priority"
        $this.ChiValue=[ORCACHI]::Medium
        $this.Links= @{
            "Security & Compliance Center - Anti-malware policies"="https://aka.ms/orca-mfp-action-antimalware"
            "Order and precedence of email protection"="https://aka.ms/orca-atpp-docs-4"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {

        ForEach($AcceptedDomain in $Config["AcceptedDomains"]) 
        {

            # Set up the config object

            $Rules = @()

            # Go through each Safe Links Policy

            ForEach($Rule in ($Config["MalwareFilterRule"] | Sort-Object Priority)) 
            {
                if($null -eq $Rule.SentTo -and $null -eq $Rule.SentToMemberOf -and $Rule.State -eq "Enabled")
                {
                    if($Rule.RecipientDomainIs -contains $AcceptedDomain.Name -and $Rule.ExceptIfRecipientDomainIs -notcontains $AcceptedDomain.Name)
                    {
                        # Policy applies to this domain

                        $Rules += New-Object -TypeName PSObject -Property @{
                            PolicyName=$($Rule.MalwareFilterPolicy)
                            Priority=$($Rule.Priority)
                        }

                    }
                }

            }

            If($Rules.Count -gt 0)
            {
                $Count = 0

                ForEach($r in ($Rules | Sort-Object Priority))
                {

                    $Count++

                    $ConfigObject = [ORCACheckConfig]::new()

                    $ConfigObject.Object=$($AcceptedDomain.Name)
                    $ConfigObject.ConfigItem=$($r.PolicyName)
                    $ConfigObject.ConfigData=$($r.Priority)

                    If($Count -eq 1)
                    {
                        # First policy based on priority is a pass
                        $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
                    }
                    else
                    {
                        # Additional policies based on the priority should be listed as informational
                        $ConfigObject.InfoText = "There are multiple policies that apply to this domain, only the policy with the lowest priority will apply. This policy may not apply based on a lower priority."
                        $ConfigObject.SetResult([ORCAConfigLevel]::Informational,"Fail")
                    }    

                    $this.AddConfig($ConfigObject)
                }
            } 
            elseif($Rules.Count -eq 0)
            {
                <#
                    No policy is applying to this domain

                    For anti malware policies this is OK because we fall back to the default
                #>
                
                $ConfigObject = [ORCACheckConfig]::new()

                $ConfigObject.Object=$($AcceptedDomain.Name)
                $ConfigObject.ConfigItem="Default"
                $ConfigObject.ConfigData="Default"
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")

                $this.AddConfig($ConfigObject)
            }

        }

    }

}