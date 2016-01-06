# GR8 CRM - Campaign Management UI Plugin

CRM = [Customer Relationship Management](http://en.wikipedia.org/wiki/Customer_relationship_management)

GR8 CRM is a set of [Grails Web Application Framework](http://www.grails.org/)
plugins that makes it easy to develop web application with CRM functionality.
With CRM we mean features like:

- Contact Management
- Task/Todo Lists
- Project Management


## Campaign Management User Interface

This plugin provides a Twitter Bootstrap based user interface for campaign management in GR8 CRM.
It depends on the [crm-campaign](https://github.com/technipelago/grails-crm-campaign) plugin for services and persistence.


The plugin supports the following types of campaigns:

- Banners campaigns. Render ads/banners on a web page and control what should be displayed and when from the campaign
- Information campaigns. Render different content depending on the visitors origin (utm_source, campaign query parameter, etc)
- Product discount. If you use the **crm-product** plugin you can apply different discounts depending on campaign setup
- Email marketing. Compose HTML emails and send to target groups. With support for open/click statistics.

Read more about the **crm-campaign-ui** plugin at [gr8crm.github.io](http://gr8crm.github.io/plugins/crm-campaign-ui/)
