<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="campaignName" value="${message(code: 'informationCampaign.label', default: 'Information')}"/>
    <title><g:message code="crmCampaign.settings.title" args="[campaignName, crmCampaign]"/></title>
</head>

<body>

<crm:header title="crmCampaign.settings.title" args="[campaignName, crmCampaign]"/>

<g:hasErrors bean="${crmCampaign}">
    <crm:alert class="alert-error">
        <ul>
            <g:eachError bean="${crmCampaign}" var="error">
                <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                        error="${error}"/></li>
            </g:eachError>
        </ul>
    </crm:alert>
</g:hasErrors>

<g:form action="edit">

    <g:hiddenField name="id" value="${crmCampaign.id}"/>
    <g:hiddenField name="version" value="${crmCampaign.version}"/>

    <h3>Denna kampanjtyp saknar inställningsmöjligheter</h3>

    <div class="form-actions">
        <crm:button visual="warning" icon="icon-ok icon-white" label="crmCampaign.button.save.label"/>
        <crm:button type="link" controller="crmCampaign" action="show" id="${crmCampaign.id}" icon="icon-remove"
                    label="crmCampaign.button.cancel.label"/>
    </div>
</g:form>
</body>
</html>
