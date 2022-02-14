<#

227 - Check Safe Attachments Policy Exists for all domains

#>

using module "..\ORCA.psm1"

class ORCA227 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA227()
    {
        $this.Control=227
        $this.Services=[ORCAService]::OATP
        $this.Area="Advanced Threat Protection Policies"
        $this.Name="Safe Attachments Policy Rules"
        $this.PassText="Each domain has a Safe Attachments policy applied to it"
        $this.FailRecommendation="Apply a Safe Attachments policy to every domain"
        $this.Importance="Office 365 ATP Safe Attachments policies are applied using rules. The recipient domain condition is the most effective way of applying the Safe Attachments policy, ensuring no users are left without protection. If polices are applied using group membership make sure you cover all users through this method. Applying polices this way can be challenging, users may left unprotected if group memberships are not accurate and up to date."
        $this.ExpandResults=$True
        $this.CheckType=[CheckType]::ObjectPropertyValue
        $this.ObjectType="Domain"
        $this.ItemName="Policy"
        $this.DataType="Priority"
        $this.ChiValue=[ORCACHI]::High
        $this.Links= @{
            "Security & Compliance Center - Safe attachments"="aka.ms/orca-atpp-action-safeattachment"
            "Order and precedence of email protection"="https://aka.ms/orca-atpp-docs-4"
            "Recommended settings for EOP and Office 365 ATP security"="https://aka.ms/orca-atpp-docs-7"
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

            ForEach($Rule in ($Config["SafeAttachmentsRules"] | Sort-Object Priority)) 
            {
                if($null -eq $Rule.SentTo -and $null -eq $Rule.SentToMemberOf -and $Rule.State -eq "Enabled")
                {
                    if($Rule.RecipientDomainIs -contains $AcceptedDomain.Name -and $Rule.ExceptIfRecipientDomainIs -notcontains $AcceptedDomain.Name)
                    {
                        # Policy applies to this domain

                        $Rules += New-Object -TypeName PSObject -Property @{
                            PolicyName=$($Rule.SafeAttachmentPolicy)
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
                # No policy is applying to this domain

                $ConfigObject = [ORCACheckConfig]::new()

                $ConfigObject.Object=$($AcceptedDomain.Name)
                $ConfigObject.ConfigItem="No Policy Applying"
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")            
    
                $this.AddConfig($ConfigObject)     
            }

        }

    }

}