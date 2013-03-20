<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmCampaign.label', default: 'Campaign')}"/>
    <title><g:message code="crmCampaign.create.title" args="[entityName]"/></title>
</head>

<body>

<crm:header title="crmCampaign.create.title" args="[entityName]"/>

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

<g:form action="create">

    <f:with bean="crmCampaign">
        <div class="row-fluid">

            <div class="span7">
                <div class="row-fluid">
                    <f:field property="handlerName">
                        <g:select name="handlerName" from="${campaignTypes}" class="span6"
                                  optionValue="${{ message(code: it + '.label', default: it) }}"/>
                    </f:field>
                    <f:field property="name" input-class="span11" input-autofocus=""/>
                    <f:field property="description">
                        <g:textArea name="description" value="${crmCampaign.description}" rows="4" cols="50"
                                    class="span11"/>
                    </f:field>
                </div>
            </div>

            <div class="span5">
                <f:field property="number">
                    <g:textField name="number" value="${crmCampaign.number}" class="input-small"/>
                </f:field>
                <f:field property="code" input-class="input-small"/>
                <f:field property="status" input-class="input-large"/>
            </div>

        </div>

        <div class="form-actions">
            <crm:button visual="primary" icon="icon-ok icon-white" label="crmCampaign.button.save.label"/>
        </div>

    </f:with>

</g:form>

</body>
</html>
