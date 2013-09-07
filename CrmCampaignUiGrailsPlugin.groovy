class CrmCampaignUiGrailsPlugin {
    // Dependency group
    def groupId = "grails.crm"
    // the plugin version
    def version = "1.2.0-SNAPSHOT"
    // the version or versions of Grails the plugin is designed for
    def grailsVersion = "2.2 > *"
    // the other plugins this plugin depends on
    def dependsOn = [:]
    def loadAfter = ['crmCampaign']
    // resources that are excluded from plugin packaging
    def pluginExcludes = [
            "grails-app/views/error.gsp"
    ]

    def title = "Crm Campaign UI Plugin" // Headline display name of the plugin
    def author = "Göran Ehrsson"
    def authorEmail = "goran@technipelago.se"
    def description = '''\
Grails CRM Campaign Management User Interface
'''
    def documentation = "http://grails.org/plugin/crm-campaign-ui"
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
