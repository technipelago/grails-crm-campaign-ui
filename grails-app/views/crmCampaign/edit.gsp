<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmCampaign.label', default: 'Campaign')}"/>
    <title><g:message code="crmCampaign.edit.title" args="[entityName, crmCampaign]"/></title>
</head>

<body>

<crm:header title="crmCampaign.edit.title" subtitle="${message(code: crmCampaign.handlerName + '.label', default: crmCampaign.handlerName)}" args="[entityName, crmCampaign]"/>

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

<g:form>

    <g:hiddenField name="id" value="${crmCampaign.id}"/>
    <g:hiddenField name="version" value="${crmCampaign.version}"/>

    <f:with bean="crmCampaign">

        <div class="row-fluid">

            <div class="span7">
                <div class="row-fluid">
                    <g:if test="${crmCampaign.handlerName}">
                        <div class="control-group">
                            <label class="control-label"><g:message code="crmCampaign.handlerName.label" default="Type"/></label>
                            <div class="controls">
                                <h2>${message(code: crmCampaign.handlerName + '.label', default: crmCampaign.handlerName)}</h2>
                            </div>
                        </div>
                    </g:if>
                    <f:field property="name" input-class="span11" input-autofocus=""/>
                    <f:field property="description">
                        <g:textArea name="description" value="${crmCampaign.description}" rows="4" cols="50"
                                    class="span11"/>
                    </f:field>
                </div>
            </div>

            <div class="span5">
                <f:field property="number" input-class="input-small"/>
                <f:field property="code" input-class="input-small"/>
                <f:field property="status" input-class="input-large"/>
            </div>

        </div>

        <div class="form-actions">
            <crm:button action="edit" visual="primary" icon="icon-ok icon-white" label="crmCampaign.button.save.label"/>
        </div>

    </f:with>

</g:form>

</body>
</html>
