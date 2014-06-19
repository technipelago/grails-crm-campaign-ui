grails.project.work.dir = "target"

grails.project.repos.default = "crm"

grails.project.dependency.resolution = {
    inherits("global") {}
    log "warn"
    legacyResolve false
    repositories {
        grailsHome()
        mavenRepo "http://labs.technipelago.se/repo/plugins-releases-local/"
        mavenRepo "http://labs.technipelago.se/repo/crm-releases-local/"
        grailsCentral()
        mavenCentral()
    }
    dependencies {
        test "org.spockframework:spock-grails-support:0.7-groovy-2.0"
    }

    plugins {
        build(":tomcat:$grailsVersion",
                ":release:2.2.1",
                ":rest-client-builder:1.0.3") {
            export = false
        }
        runtime ":hibernate:$grailsVersion"

        test(":spock:0.7") {
            export = false
            exclude "spock-grails-support"
        }
        test(":codenarc:0.21") { export = false }
        test(":code-coverage:1.2.6") { export = false }

        compile "grails.crm:crm-core:latest.integration"
        compile "grails.crm:crm-campaign:latest.integration"
        compile "grails.crm:crm-content:latest.integration"

        compile "grails.crm:crm-security:latest.integration"
        compile "grails.crm:crm-ui-bootstrap:latest.integration"
        compile "grails.crm:crm-tags:latest.integration"

        compile ":selection:latest.integration"
        compile ":selection-repository:latest.integration"
        compile ":decorator:latest.integration"

        compile ":ckeditor:4.4.1.0"
    }
}

//grails.plugin.location.'crm-campaign' = "../crm-campaign"
