class CrmCampaignUiGrailsPlugin {
    def groupId = "grails.crm"
    def version = "1.2.5"
    def grailsVersion = "2.2 > *"
    def dependsOn = [:]
    def loadAfter = ['crmCampaign']
    def pluginExcludes = [
            "grails-app/views/error.gsp"
    ]
    def title = "GR8 CRM Campaign UI Plugin"
    def author = "Goran Ehrsson"
    def authorEmail = "goran@technipelago.se"
    def description = '''\
GR8 CRM Campaign Management User Interface
'''
    def documentation = "https://github.com/technipelago/grails-crm-campaign-ui"
    def license = "APACHE"
    def organization = [name: "Technipelago AB", url: "http://www.technipelago.se/"]
    def issueManagement = [system: "github", url: "https://github.com/technipelago/grails-crm-campaign-ui/issues"]
    def scm = [url: "https://github.com/technipelago/grails-crm-campaign-ui"]

    def features = {
        crmCampaign {
            description "Campaign Management"
            link controller: "crmCampaign", action: "index"
            permissions {
                guest "crmCampaign:index,list,show"
                partner "crmCampaign:index,list,show"
                user "crmCampaign:*"
                admin "crmCampaign,crmCampaignStatus:*", "productDiscountCampaign,informationCampaign:edit"
            }
        }
    }
}
