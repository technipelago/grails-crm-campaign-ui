class CrmCampaignUiGrailsPlugin {
    def groupId = "grails.crm"
    def version = "1.3.0"
    def grailsVersion = "2.2 > *"
    def dependsOn = [:]
    def loadAfter = ['crmCampaign']
    def pluginExcludes = [
            "grails-app/views/error.gsp"
    ]
    def title = "GR8 CRM Campaign Management User Interface"
    def author = "Goran Ehrsson"
    def authorEmail = "goran@technipelago.se"
    def description = '''\
This plugin is a companion plugin to crm-campaign, a plugin part of the GR8 CRM plugin suite.
It contains a Twitter Bootstrap based user interface for campaign management.
'''
    def documentation = "http://gr8crm.github.io/plugins/crm-campaign-ui/"
    def license = "APACHE"
    def organization = [name: "Technipelago AB", url: "http://www.technipelago.se/"]
    def issueManagement = [system: "github", url: "https://github.com/technipelago/grails-crm-campaign-ui/issues"]
    def scm = [url: "https://github.com/technipelago/grails-crm-campaign-ui"]
}
