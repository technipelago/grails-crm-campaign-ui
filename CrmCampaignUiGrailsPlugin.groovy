class CrmCampaignUiGrailsPlugin {
    def groupId = ""
    def version = "2.4.0"
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

    def doWithApplicationContext = { applicationContext ->
        def crmPluginService = applicationContext.crmPluginService
        def crmCoreService = applicationContext.crmCoreService
        def crmContentService = applicationContext.crmContentService
        boolean uploadMultipleFiles = application.config.crm.content.upload.multiple ?: false

        if (!crmPluginService.hasView('crmCampaign', 'show', 'tabs', [id: 'documents'])) {
            // crmCampaign:show << documents
            crmPluginService.registerView('crmCampaign', 'show', 'tabs',
                    [id: "documents", index: 500, permission: "crmCampaign:show", label: "crmCampaign.tab.documents.label", template: '/crmContent/embedded', plugin: "crm-content-ui", model: {
                        def result = crmContentService.findResourcesByReference(crmCampaign)
                        return [bean     : crmCampaign, list: result, totalCount: result.size(),
                                multiple: uploadMultipleFiles, status: 'shared',
                                reference: crmCoreService.getReferenceIdentifier(crmCampaign), openAction: 'open']
                    }]
            )
        }
    }
}
